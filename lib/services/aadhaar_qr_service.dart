import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';
import 'package:xml/xml.dart';

// ── Exceptions ────────────────────────────────────────────────────────────────

class QrFormatException implements Exception {
  final String message;
  const QrFormatException(this.message);
  @override
  String toString() => message;
}

class SignatureInvalidException implements Exception {
  @override
  String toString() => 'QR signature could not be verified.';
}

class ParseException implements Exception {
  final String message;
  const ParseException(this.message);
  @override
  String toString() => message;
}

// ── Result ────────────────────────────────────────────────────────────────────

class AadhaarVerificationResult {
  final String name;
  final int? age;
  final String maskedUid; // "XXXX-XXXX-1234"

  const AadhaarVerificationResult({
    required this.name,
    required this.age,
    required this.maskedUid,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class AadhaarQrService {
  static RSAPublicKey? _publicKey;
  static bool _keyLoadAttempted = false;

  /// Load UIDAI public key from assets once; returns null if key is a
  /// placeholder or otherwise unparseable (verification is then skipped).
  static Future<RSAPublicKey?> _loadPublicKey() async {
    if (_keyLoadAttempted) return _publicKey;
    _keyLoadAttempted = true;
    try {
      final pem = await rootBundle.loadString('assets/uidai_public_key.pem');
      _publicKey = _parsePem(pem);
    } catch (_) {
      _publicKey = null;
    }
    return _publicKey;
  }

  static RSAPublicKey _parsePem(String pem) {
    final lines = pem
        .split('\n')
        .where((l) =>
            l.isNotEmpty &&
            !l.startsWith('-----') &&
            !l.startsWith('Obtain') &&
            !l.startsWith('Place') &&
            !l.startsWith('The ') &&
            !l.startsWith('https') &&
            !l.startsWith('PLACEHOLDER'))
        .join('');
    final bytes = base64.decode(lines);

    // SubjectPublicKeyInfo: SEQUENCE { AlgorithmIdentifier, BIT STRING }
    final spkiParser = ASN1Parser(Uint8List.fromList(bytes));
    final spki = spkiParser.nextObject() as ASN1Sequence;
    final bitStr = spki.elements![1] as ASN1BitString;

    // BIT STRING value bytes: first byte = unused-bits count (0 for keys), rest = key DER
    final keyBytes = bitStr.valueBytes!.sublist(1);
    final keyParser = ASN1Parser(keyBytes);
    final keySeq = keyParser.nextObject() as ASN1Sequence;
    final modulus = (keySeq.elements![0] as ASN1Integer).integer!;
    final exponent = (keySeq.elements![1] as ASN1Integer).integer!;
    return RSAPublicKey(modulus, exponent);
  }

  static bool _verifySignature(
      Uint8List data, Uint8List signature, RSAPublicKey pubKey) {
    try {
      final signer = Signer('SHA-256/RSA');
      signer.init(false, PublicKeyParameter<RSAPublicKey>(pubKey));
      return signer.verifySignature(data, RSASignature(signature));
    } catch (_) {
      return false;
    }
  }

  // ── Public entry point ─────────────────────────────────────────────────────

  /// Parse and optionally verify an Aadhaar QR string.
  /// Throws [QrFormatException], [SignatureInvalidException], or [ParseException].
  static Future<AadhaarVerificationResult> verify(String qrData) async {
    qrData = qrData.trim();

    // Old XML format
    if (qrData.startsWith('<')) {
      return _parseOldXml(qrData);
    }

    // New Secure QR format: very large integer string (typically 1000+ digits)
    if (RegExp(r'^\d{50,}$').hasMatch(qrData)) {
      return _parseSecureQr(qrData);
    }

    throw const QrFormatException('This does not appear to be an Aadhaar QR code.');
  }

  // ── Old XML format ─────────────────────────────────────────────────────────

  static AadhaarVerificationResult _parseOldXml(String xmlStr) {
    try {
      final doc = XmlDocument.parse(xmlStr);
      final root = doc.rootElement;

      final name =
          root.getAttribute('name') ?? root.getAttribute('n') ?? '';
      final dob =
          root.getAttribute('dob') ?? root.getAttribute('yob') ?? '';
      final uid =
          root.getAttribute('uid') ?? root.getAttribute('u') ?? '';

      if (name.isEmpty) throw const ParseException('Name not found in QR data.');

      final last4 = uid.length >= 4 ? uid.substring(uid.length - 4) : uid;
      return AadhaarVerificationResult(
        name: name.trim(),
        age: _ageFromDob(dob),
        maskedUid: _formatMasked(last4),
      );
    } on ParseException {
      rethrow;
    } catch (e) {
      throw ParseException('Could not read QR data: $e');
    }
  }

  // ── New Secure QR format ───────────────────────────────────────────────────

  static Future<AadhaarVerificationResult> _parseSecureQr(
      String qrData) async {
    final bigInt = BigInt.parse(qrData);
    final bytes = _bigIntToBytes(bigInt);
    return _parseSecureQrBytes(bytes);
  }

  static Future<AadhaarVerificationResult> _parseSecureQrBytes(
      Uint8List bytes) async {
    if (bytes.length < 33) {
      throw const QrFormatException('QR data is too short.');
    }

    // Last 256 bytes = RSA-2048 signature; remainder = signed payload
    final bool hasSignature = bytes.length > 256;
    final payload =
        hasSignature ? bytes.sublist(0, bytes.length - 256) : bytes;
    final signature =
        hasSignature ? bytes.sublist(bytes.length - 256) : Uint8List(0);

    // RSA verification — skipped gracefully if key not configured
    if (hasSignature) {
      final pubKey = await _loadPublicKey();
      if (pubKey != null) {
        if (!_verifySignature(payload, signature, pubKey)) {
          throw SignatureInvalidException();
        }
      }
    }

    // Decompress (zlib) — some older secure QRs aren't compressed
    Uint8List decompressed;
    try {
      decompressed = Uint8List.fromList(zlib.decode(payload));
    } catch (_) {
      decompressed = payload;
    }

    // 0xFF-delimited fields:
    // [0] email_hash  [1] mobile_hash  [2] timestamp
    // [3] name        [4] dob          [5] gender     [6] care-of
    // [7] district    [8] landmark     [9] house      [10] location
    // [11] pin        [12] po          [13] state     [14] street
    // [15] sub-dist   [16] vtc         [17] phone_4   [18] email_4
    // [19] uid_last4  [20] photo (optional)
    final fields = _splitOn(decompressed, 0xFF);
    if (fields.length < 4) {
      throw const ParseException('QR data has too few fields.');
    }

    final name = _str(fields, 3);
    final dob = _str(fields, 4);
    final uid4 = _str(fields, 19).trim();

    if (name.isEmpty) throw const ParseException('Name field is empty.');

    return AadhaarVerificationResult(
      name: name.trim(),
      age: _ageFromDob(dob),
      maskedUid: _formatMasked(uid4),
    );
  }

  /// Fallback entry point for BYTE-mode QRs where the scanner returns raw
  /// binary bytes instead of a numeric string. Skips the BigInt step.
  static Future<AadhaarVerificationResult> verifyFromBytes(
      Uint8List rawBytes) async {
    if (rawBytes.length < 33) {
      throw const QrFormatException('QR data is too short.');
    }
    final asString = utf8.decode(rawBytes, allowMalformed: true).trim();
    if (asString.startsWith('<')) {
      return _parseOldXml(asString);
    }
    return _parseSecureQrBytes(rawBytes);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _str(List<Uint8List> fields, int index) {
    if (index >= fields.length) return '';
    return utf8.decode(fields[index], allowMalformed: true);
  }

  static List<Uint8List> _splitOn(Uint8List data, int delimiter) {
    final result = <Uint8List>[];
    int start = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == delimiter) {
        result.add(data.sublist(start, i));
        start = i + 1;
      }
    }
    result.add(data.sublist(start));
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    return Uint8List.fromList(List.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    ));
  }

  /// Derive age from DOB string. Handles DD-MM-YYYY, YYYY-MM-DD, YYYY.
  static int? _ageFromDob(String dob) {
    if (dob.isEmpty) return null;
    try {
      final now = DateTime.now();
      DateTime birth;
      if (RegExp(r'^\d{4}$').hasMatch(dob)) {
        birth = DateTime(int.parse(dob));
      } else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dob)) {
        final p = dob.split('-');
        birth =
            DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dob)) {
        birth = DateTime.parse(dob);
      } else {
        return null;
      }
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return (age > 0 && age < 120) ? age : null;
    } catch (_) {
      return null;
    }
  }

  static String _formatMasked(String last4) {
    if (last4.isEmpty) return 'XXXX-XXXX-XXXX';
    return 'XXXX-XXXX-${last4.padLeft(4, 'X')}';
  }
}

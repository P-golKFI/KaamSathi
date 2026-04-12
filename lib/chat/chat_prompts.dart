/// All possible prompt keys in the chat system.
/// Each key maps to a specific pre-written message.
enum PromptKey {
  // Employer opening prompts
  employerWorkAvailable,
  employerAreYouAvailable,
  employerLetsTalk,

  // Helper opening prompts
  helperInterestedInJob,
  helperLetsTalk,

  // Reply prompts
  yesInterestedLetsDiscuss,
  sorryNotAvailable,
  yesImAvailable,
  sureShareNumbers,
  fewMoreQuestions,
  sorryNotInterested,
  greatAvailableSoon,
  shareMoreDetailsCall,
  positionFilled,
  greatCanWeTalk,
  areYouAvailableSoon,
  discussOnCall,
  checkJobPost,

  // Always-available
  notInterested,
}

/// A single prompt option shown to the user.
class ChatPrompt {
  final PromptKey key;
  final String text;
  final bool endsChat;
  final bool triggersShareFlow;

  const ChatPrompt({
    required this.key,
    required this.text,
    this.endsChat = false,
    this.triggersShareFlow = false,
  });
}

/// Returns the opening prompts when someone initiates a new conversation.
/// [initiatorRole] is "employer" or "helper".
/// [location] is the employer's city, auto-filled into the prompt.
List<ChatPrompt> getOpeningPrompts({
  required String initiatorRole,
  String? location,
}) {
  if (initiatorRole == 'employer') {
    return [
      ChatPrompt(
        key: PromptKey.employerWorkAvailable,
        text:
            'I have work available near ${location ?? "your area"}. Are you interested?',
      ),
      ChatPrompt(
        key: PromptKey.employerAreYouAvailable,
        text: 'Are you available for work?',
      ),
      ChatPrompt(
        key: PromptKey.employerLetsTalk,
        text: "I'd like to discuss a job opportunity. Can we talk?",
      ),
    ];
  } else {
    return [
      ChatPrompt(
        key: PromptKey.helperInterestedInJob,
        text: "I'm interested in this job.",
      ),
      ChatPrompt(
        key: PromptKey.helperLetsTalk,
        text: "I'd like to discuss this opportunity. Can we talk?",
      ),
    ];
  }
}

/// Given the last received message's prompt key, returns the smart reply
/// options to show. Returns null if the chat has ended or no replies apply.
///
/// [currentUserRole] is needed for the "fewMoreQuestions" case, which
/// re-shows opening prompts for the current user's role.
/// [location] is for re-showing employer opening prompts with city.
List<ChatPrompt>? getSmartReplies({
  required PromptKey lastReceivedKey,
  required String currentUserRole,
  String? location,
}) {
  switch (lastReceivedKey) {
    // Employer opening: "I have work available near..."
    case PromptKey.employerWorkAvailable:
      return [
        const ChatPrompt(
          key: PromptKey.yesInterestedLetsDiscuss,
          text: "Yes, I'm interested. Let's discuss.",
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotAvailable,
          text: "Sorry, I'm not available.",
          endsChat: true,
        ),
      ];

    // Employer opening: "Are you available for work?"
    case PromptKey.employerAreYouAvailable:
      return [
        const ChatPrompt(
          key: PromptKey.yesImAvailable,
          text: "Yes, I'm available.",
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotAvailable,
          text: "Sorry, I'm not available.",
          endsChat: true,
        ),
      ];

    // Either side: "Can we talk?"
    case PromptKey.employerLetsTalk:
    case PromptKey.helperLetsTalk:
      return [
        const ChatPrompt(
          key: PromptKey.sureShareNumbers,
          text: "Sure! Let's share numbers.",
          triggersShareFlow: true,
        ),
        const ChatPrompt(
          key: PromptKey.fewMoreQuestions,
          text: "I have a few more questions first.",
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotInterested,
          text: "Sorry, I'm not interested.",
          endsChat: true,
        ),
      ];

    // Helper opening: "I'm interested in this job."
    case PromptKey.helperInterestedInJob:
      return [
        const ChatPrompt(
          key: PromptKey.greatAvailableSoon,
          text: "Great! Are you available to start soon?",
        ),
        const ChatPrompt(
          key: PromptKey.shareMoreDetailsCall,
          text: "Let me share more details. Can we talk?",
        ),
        const ChatPrompt(
          key: PromptKey.positionFilled,
          text: "Sorry, this position has been filled.",
          endsChat: true,
        ),
      ];

    // Reply: "Yes, I'm interested. Let's discuss."
    case PromptKey.yesInterestedLetsDiscuss:
      return [
        const ChatPrompt(
          key: PromptKey.greatCanWeTalk,
          text: "Great! Can we talk on the phone?",
        ),
        const ChatPrompt(
          key: PromptKey.areYouAvailableSoon,
          text: "Are you available to start soon?",
        ),
      ];

    // Reply: "Yes, I'm available."
    case PromptKey.yesImAvailable:
      return [
        const ChatPrompt(
          key: PromptKey.greatCanWeTalk,
          text: "Great! Can we talk on the phone?",
        ),
        const ChatPrompt(
          key: PromptKey.shareMoreDetailsCall,
          text: "Let me share more details. Can we talk?",
        ),
      ];

    // Reply: "Great! Are you available to start soon?"
    // or "Are you available to start soon?"
    case PromptKey.greatAvailableSoon:
    case PromptKey.areYouAvailableSoon:
      return [
        const ChatPrompt(
          key: PromptKey.yesImAvailable,
          text: "Yes, I'm available.",
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotAvailable,
          text: "Sorry, I'm not available.",
          endsChat: true,
        ),
      ];

    // Reply: "Let me share more details. Can we talk?"
    // or "Great! Can we talk on the phone?"
    case PromptKey.shareMoreDetailsCall:
    case PromptKey.greatCanWeTalk:
      return [
        const ChatPrompt(
          key: PromptKey.sureShareNumbers,
          text: "Sure! Let's share numbers.",
          triggersShareFlow: true,
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotInterested,
          text: "Sorry, I'm not interested.",
          endsChat: true,
        ),
      ];

    // Reply: "Let's discuss on a call." or "Check the job post"
    case PromptKey.discussOnCall:
    case PromptKey.checkJobPost:
      return [
        const ChatPrompt(
          key: PromptKey.sureShareNumbers,
          text: "Sure! Let's share numbers.",
          triggersShareFlow: true,
        ),
        const ChatPrompt(
          key: PromptKey.sorryNotInterested,
          text: "Sorry, I'm not interested.",
          endsChat: true,
        ),
      ];

    // Reply: "I have a few more questions first."
    // Re-show opening prompts for the current user's role
    case PromptKey.fewMoreQuestions:
      return getOpeningPrompts(
        initiatorRole: currentUserRole,
        location: location,
      );

    // Chat-ending prompts — no replies
    case PromptKey.sorryNotAvailable:
    case PromptKey.sorryNotInterested:
    case PromptKey.positionFilled:
    case PromptKey.notInterested:
      return null;

    // "Sure! Let's share numbers." triggers the share flow, not replies
    case PromptKey.sureShareNumbers:
      return null;
  }
}

/// Parse a string prompt key from Firestore back to the enum.
PromptKey? parsePromptKey(String? value) {
  if (value == null) return null;
  try {
    return PromptKey.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return null;
  }
}

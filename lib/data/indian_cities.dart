const Map<String, List<String>> citiesByState = {
  'Andhra Pradesh': [
    'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Tirupati',
    'Rajahmundry', 'Kakinada', 'Kadapa', 'Anantapur', 'Eluru', 'Ongole',
    'Nandyal', 'Machilipatnam', 'Adoni', 'Tenali', 'Proddatur', 'Chittoor',
    'Hindupur', 'Bhimavaram', 'Srikakulam', 'Vizianagaram',
  ],
  'Arunachal Pradesh': [
    'Itanagar', 'Naharlagun', 'Pasighat', 'Tezpur',
  ],
  'Assam': [
    'Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon', 'Tinsukia',
    'Tezpur', 'Bongaigaon', 'Dhubri', 'North Lakhimpur', 'Diphu', 'Karimganj',
  ],
  'Bihar': [
    'Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia', 'Darbhanga',
    'Bihar Sharif', 'Arrah', 'Begusarai', 'Katihar', 'Munger', 'Chhapra',
    'Bettiah', 'Motihari', 'Saharsa', 'Sasaram', 'Hajipur', 'Dehri',
    'Siwan', 'Maner', 'Jehanabad', 'Aurangabad',
  ],
  'Chhattisgarh': [
    'Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg', 'Rajnandgaon',
    'Jagdalpur', 'Raigarh', 'Ambikapur', 'Dhamtari', 'Chhatarpur',
  ],
  'Goa': [
    'Panaji', 'Vasco da Gama', 'Margao', 'Mapusa', 'Ponda', 'Bicholim',
  ],
  'Gujarat': [
    'Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar',
    'Gandhinagar', 'Junagadh', 'Anand', 'Nadiad', 'Morbi', 'Mehsana',
    'Surendranagar', 'Bharuch', 'Navsari', 'Valsad', 'Gandhidham', 'Botad',
    'Porbandar', 'Amreli', 'Godhra', 'Patan', 'Kalol', 'Deesa',
  ],
  'Haryana': [
    'Faridabad', 'Gurugram', 'Panipat', 'Ambala', 'Yamunanagar', 'Rohtak',
    'Hisar', 'Karnal', 'Sonipat', 'Panchkula', 'Bhiwani', 'Bahadurgarh',
    'Sirsa', 'Rewari', 'Kaithal', 'Palwal', 'Kurukshetra', 'Jhajjar', 'Fatehabad',
  ],
  'Himachal Pradesh': [
    'Shimla', 'Solan', 'Dharamshala', 'Baddi', 'Palampur', 'Mandi',
    'Kullu', 'Nahan', 'Una', 'Hamirpur', 'Bilaspur',
  ],
  'Jharkhand': [
    'Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro Steel City', 'Deoghar',
    'Hazaribagh', 'Giridih', 'Ramgarh', 'Phusro', 'Medininagar',
    'Chaibasa', 'Dumka', 'Palamu', 'Chirkunda',
  ],
  'Karnataka': [
    'Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi', 'Kalaburagi',
    'Davangere', 'Ballari', 'Tumakuru', 'Shivamogga', 'Vijayapura', 'Bidar',
    'Raichur', 'Hospet', 'Udupi', 'Hassan', 'Dharwad', 'Chikkamagaluru',
    'Bagalkot', 'Chitradurga', 'Mandya', 'Gadag', 'Kolar', 'Robertsonpet',
  ],
  'Kerala': [
    'Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Kollam', 'Thrissur',
    'Alappuzha', 'Palakkad', 'Malappuram', 'Kottayam', 'Kannur',
    'Kasaragod', 'Pathanamthitta', 'Idukki', 'Wayanad', 'Aluva',
    'Thodupuzha', 'Perinthalmanna', 'Tirur', 'Chalakudy', 'Vadakara',
  ],
  'Madhya Pradesh': [
    'Indore', 'Bhopal', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar',
    'Dewas', 'Satna', 'Ratlam', 'Rewa', 'Murwara', 'Singrauli',
    'Burhanpur', 'Khandwa', 'Bhind', 'Chhindwara', 'Guna', 'Shivpuri',
    'Vidisha', 'Chhatarpur', 'Damoh', 'Mandsaur', 'Khargone',
  ],
  'Maharashtra': [
    'Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Solapur',
    'Amravati', 'Nanded', 'Kolhapur', 'Thane', 'Pimpri-Chinchwad',
    'Vasai-Virar', 'Bhiwandi', 'Kalyan', 'Ulhasnagar', 'Latur', 'Akola',
    'Malegaon', 'Navi Mumbai', 'Chandrapur', 'Jalgaon', 'Dhule',
    'Ahmednagar', 'Satara', 'Sangli', 'Ratnagiri', 'Osmanabad',
    'Parbhani', 'Ichalkaranji', 'Jalna', 'Ambarnath', 'Panvel',
    'Badlapur', 'Beed', 'Alibag', 'Shirdi',
  ],
  'Manipur': [
    'Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur',
  ],
  'Meghalaya': [
    'Shillong', 'Tura', 'Jowai', 'Nongstoin',
  ],
  'Mizoram': [
    'Aizawl', 'Lunglei', 'Saiha', 'Champhai',
  ],
  'Nagaland': [
    'Dimapur', 'Kohima', 'Mokokchung', 'Tuensang',
  ],
  'Odisha': [
    'Bhubaneswar', 'Cuttack', 'Rourkela', 'Brahmapur', 'Sambalpur',
    'Puri', 'Balasore', 'Bhadrak', 'Baripada', 'Bargarh', 'Angul',
    'Jharsuguda', 'Dhenkanal', 'Kendujhar', 'Rayagada', 'Sundargarh',
  ],
  'Punjab': [
    'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda',
    'Mohali', 'Pathankot', 'Hoshiarpur', 'Moga', 'Firozpur',
    'Batala', 'Abohar', 'Phagwara', 'Khanna', 'Muktsar', 'Sangrur',
    'Kapurthala', 'Ropar', 'Faridkot', 'Barnala',
  ],
  'Rajasthan': [
    'Jaipur', 'Jodhpur', 'Kota', 'Bikaner', 'Ajmer', 'Udaipur',
    'Bhilwara', 'Alwar', 'Bharatpur', 'Sikar', 'Sri Ganganagar',
    'Pali', 'Beawar', 'Hanumangarh', 'Dhaulpur', 'Tonk', 'Baran',
    'Jhalawar', 'Chittorgarh', 'Barmer', 'Jhunjhunu', 'Nagaur',
    'Sawai Madhopur', 'Gangapur City', 'Mount Abu',
  ],
  'Sikkim': [
    'Gangtok', 'Namchi', 'Geyzing', 'Mangan',
  ],
  'Tamil Nadu': [
    'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem',
    'Tirunelveli', 'Tiruppur', 'Vellore', 'Erode', 'Thoothukudi',
    'Dindigul', 'Thanjavur', 'Ranipet', 'Sivakasi', 'Karur',
    'Udhagamandalam', 'Hosur', 'Nagercoil', 'Kancheepuram',
    'Cuddalore', 'Kumbakonam', 'Pollachi', 'Rajapalayam',
    'Pudukkottai', 'Namakkal', 'Tiruvannamalai', 'Ambattur',
    'Tambaram', 'Avadi', 'Tirupathur', 'Perambalur',
  ],
  'Telangana': [
    'Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam',
    'Ramagundam', 'Mahbubnagar', 'Nalgonda', 'Mancherial', 'Adilabad',
    'Suryapet', 'Miryalaguda', 'Jagtial', 'Siddipet', 'Kamareddy',
    'Sangareddy', 'Medak', 'Bodhan', 'Kothagudem', 'Secunderabad',
  ],
  'Tripura': [
    'Agartala', 'Udaipur', 'Dharmanagar', 'Kailasahar',
  ],
  'Uttar Pradesh': [
    'Lucknow', 'Kanpur', 'Agra', 'Ghaziabad', 'Noida', 'Prayagraj',
    'Varanasi', 'Meerut', 'Bareilly', 'Aligarh', 'Moradabad',
    'Saharanpur', 'Gorakhpur', 'Firozabad', 'Jhansi', 'Mathura',
    'Muzaffarnagar', 'Rampur', 'Shahjahanpur', 'Farrukhabad',
    'Hapur', 'Etawah', 'Mirzapur', 'Bulandshahr', 'Hardoi',
    'Lakhimpur', 'Unnao', 'Rae Bareli', 'Sitapur', 'Jaunpur',
    'Bijnor', 'Amroha', 'Bahraich', 'Gonda', 'Sultanpur', 'Faizabad',
    'Ayodhya', 'Ballia', 'Banda', 'Deoria', 'Basti', 'Azamgarh',
    'Greater Noida', 'Vrindavan',
  ],
  'Uttarakhand': [
    'Dehradun', 'Haridwar', 'Roorkee', 'Haldwani', 'Kashipur',
    'Rishikesh', 'Rudrapur', 'Nainital', 'Kotdwar', 'Uttarkashi',
    'Almora', 'Pithoragarh', 'Mussoorie',
  ],
  'West Bengal': [
    'Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri',
    'Bardhaman', 'Malda', 'Baharampur', 'Habra', 'Kharagpur',
    'Shantipur', 'Raiganj', 'Cooch Behar', 'Medinipur', 'Haldia',
    'Balurghat', 'Bangaon', 'Darjeeling', 'Kalimpong', 'Krishnanagar',
    'Barasat', 'Bally', 'Uttarpara', 'Naihati', 'Ranaghat',
    'Berhampore', 'Jalpaiguri', 'Bankura', 'Hooghly',
  ],
  'Delhi': [
    'Delhi', 'New Delhi', 'Dwarka', 'Rohini', 'Pitampura',
    'Janakpuri', 'Laxmi Nagar', 'Shahdara', 'Karol Bagh',
  ],
  'Chandigarh': [
    'Chandigarh',
  ],
  'Puducherry': [
    'Puducherry', 'Karaikal', 'Mahe', 'Yanam',
  ],
  'Jammu and Kashmir': [
    'Srinagar', 'Jammu', 'Anantnag', 'Sopore', 'Baramulla',
    'Kupwara', 'Pulwama', 'Udhampur', 'Kathua', 'Poonch',
  ],
  'Ladakh': [
    'Leh', 'Kargil',
  ],
  'Andaman and Nicobar Islands': [
    'Port Blair',
  ],
  'Dadra and Nagar Haveli and Daman and Diu': [
    'Silvassa', 'Daman', 'Diu',
  ],
  'Lakshadweep': [
    'Kavaratti',
  ],
};

// Flat list kept for backward-compatibility (employer city browse search).
final List<String> indianCities =
    citiesByState.values.expand((c) => c).toList();

/// Search cities filtered by [state] when provided, otherwise searches all.
List<String> searchCities(String query, {String? state}) {
  if (query.trim().isEmpty) return [];
  final q = query.trim().toLowerCase();
  final pool = (state != null && citiesByState.containsKey(state))
      ? citiesByState[state]!
      : indianCities;
  return pool.where((city) => city.toLowerCase().contains(q)).take(8).toList();
}

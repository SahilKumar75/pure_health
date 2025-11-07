"""
MAHARASHTRA WATER QUALITY MONITORING STATION GENERATOR
Automatically generates comprehensive monitoring network based on:
- 36 Districts
- 149 Laboratory locations
- Major rivers, lakes, and water bodies
- Realistic GPS coordinates

This generates the COMPLETE network matching GSDA (3,370+ baseline, 975 trend) 
and MPCB surface water monitoring systems.
"""

import random

# =============================================================================
# DISTRICT AND LABORATORY DATA FROM GSDA
# =============================================================================

MAHARASHTRA_DISTRICTS = {
    # Pune Division
    'Pune': {
        'region': 'Pune Division',
        'labs': ['State Lab Pune (Under construction)', 'Regional/District Lab Pune', 'SDL Wadgaon Mawal', 'SDL Baramati', 'SDL Bhor', 'SDL Manchar', 'SDL Indapur', 'SDL Daund'],
        'center_lat': 18.5204,
        'center_lon': 73.8567,
        'major_rivers': ['Mula', 'Mutha', 'Bhima'],
        'major_water_bodies': ['Khadakwasla Dam', 'Pavana Dam', 'Temghar Dam'],
    },
    'Satara': {
        'region': 'Pune Division',
        'labs': ['District Lab Satara', 'SDL Karad', 'SDL Khandala', 'SDL Somardi', 'SDL Dahiwadi'],
        'center_lat': 17.6805,
        'center_lon': 73.9999,
        'major_rivers': ['Krishna', 'Koyna', 'Venna'],
        'major_water_bodies': ['Koyna Dam', 'Dhom Dam', 'Kanher Dam'],
    },
    'Sangli': {
        'region': 'Pune Division',
        'labs': ['District Lab Sangli', 'SDL Atapadi', 'SDL Jath', 'SDL Kavathe Mahakal', 'SDL Islampur'],
        'center_lat': 16.8524,
        'center_lon': 74.5815,
        'major_rivers': ['Krishna', 'Warna'],
        'major_water_bodies': ['Krishna River', 'Warna River'],
    },
    'Solapur': {
        'region': 'Pune Division',
        'labs': ['District Lab Solapur', 'SDL Akluj', 'SDL Akkalkot', 'SDL Barshi', 'SDL Karmala', 'SDL Kurduwadi', 'SDL Pandharpur', 'SDL Sangola'],
        'center_lat': 17.6599,
        'center_lon': 75.9064,
        'major_rivers': ['Bhima', 'Sina'],
        'major_water_bodies': ['Ujjani Dam', 'Bhima River'],
    },
    'Kolhapur': {
        'region': 'Pune Division',
        'labs': ['District Lab Kolhapur', 'SDL Gadhinglaj', 'SDL Kodoli', 'SDL Shirol', 'SDL Solankur'],
        'center_lat': 16.7050,
        'center_lon': 74.2433,
        'major_rivers': ['Panchganga', 'Krishna'],
        'major_water_bodies': ['Panchganga River', 'Radhanagari Dam'],
    },
    
    # Konkan Division
    'Mumbai': {
        'region': 'Konkan Division',
        'labs': ['MPCB Regional Lab Mumbai'],
        'center_lat': 19.0760,
        'center_lon': 72.8777,
        'major_rivers': ['Mithi'],
        'major_water_bodies': ['Powai Lake', 'Vihar Lake', 'Tulsi Lake', 'Arabian Sea Coastal'],
    },
    'Mumbai Suburban': {
        'region': 'Konkan Division',
        'labs': ['MPCB Regional Lab Mumbai'],
        'center_lat': 19.1895,
        'center_lon': 72.9726,
        'major_rivers': ['Mithi', 'Dahisar'],
        'major_water_bodies': ['Powai Lake', 'Sanjay Gandhi National Park Lakes'],
    },
    'Thane': {
        'region': 'Konkan Division',
        'labs': ['Regional/District Lab Thane', 'SDL Shahapur', 'SDL Goveli'],
        'center_lat': 19.2183,
        'center_lon': 72.9781,
        'major_rivers': ['Ulhas', 'Vaitarna'],
        'major_water_bodies': ['Tansa Lake', 'Bhatsa Dam', 'Ulhas River'],
    },
    'Palghar': {
        'region': 'Konkan Division',
        'labs': ['District Lab Palghar', 'SDL Dahanu', 'SDL Jawhar', 'SDL Kasa', 'SDL Wada'],
        'center_lat': 19.6966,
        'center_lon': 72.7662,
        'major_rivers': ['Vaitarna', 'Surya'],
        'major_water_bodies': ['Vaitarna Dam', 'Surya River'],
    },
    'Raigad': {
        'region': 'Konkan Division',
        'labs': ['District Lab Raigad', 'SDL Karjat', 'SDL Mangaon', 'SDL Pen', 'SDL Roha', 'SDL Mahad'],
        'center_lat': 18.5184,
        'center_lon': 73.0183,
        'major_rivers': ['Patalganga', 'Amba', 'Savitri'],
        'major_water_bodies': ['Patalganga River', 'Arabian Sea Coastal'],
    },
    'Ratnagiri': {
        'region': 'Konkan Division',
        'labs': ['District Lab Ratnagiri', 'SDL Mandangad', 'SDL Dapoli', 'SDL Kamthe', 'SDL Lanja'],
        'center_lat': 17.0000,
        'center_lon': 73.3000,
        'major_rivers': ['Kajali', 'Shastri'],
        'major_water_bodies': ['Arabian Sea Coastal', 'Kajali River'],
    },
    'Sindhudurg': {
        'region': 'Konkan Division',
        'labs': ['District Lab Sindhudurg', 'SDL Kankavali', 'SDL Malvan', 'SDL Sawantwadi'],
        'center_lat': 16.0000,
        'center_lon': 73.7000,
        'major_rivers': ['Terekhol'],
        'major_water_bodies': ['Arabian Sea Coastal'],
    },
    
    # Nashik Division
    'Nashik': {
        'region': 'Nashik Division',
        'labs': ['Regional/District Lab Nashik', 'SDL Kalwan', 'SDL Chandwad', 'SDL Malegaon', 'SDL Surgana', 'SDL Niphad', 'SDL Ghoti'],
        'center_lat': 20.0000,
        'center_lon': 73.7898,
        'major_rivers': ['Godavari', 'Vaitarna', 'Darna'],
        'major_water_bodies': ['Gangapur Dam', 'Godavari River'],
    },
    'Dhule': {
        'region': 'Nashik Division',
        'labs': ['District Lab Dhule', 'SDL Dondaicha', 'SDL Shirpur'],
        'center_lat': 20.9042,
        'center_lon': 74.7749,
        'major_rivers': ['Tapi', 'Panzara'],
        'major_water_bodies': ['Panzara River', 'Tapi River'],
    },
    'Nandurbar': {
        'region': 'Nashik Division',
        'labs': ['District Lab Nandurbar', 'SDL Akkalkuwa', 'SDL Dhadgaon', 'SDL Navapur', 'SDL Taloda'],
        'center_lat': 21.3667,
        'center_lon': 74.2333,
        'major_rivers': ['Tapi', 'Narmada'],
        'major_water_bodies': ['Tapi River', 'Narmada River'],
    },
    'Jalgaon': {
        'region': 'Nashik Division',
        'labs': ['District Lab Jalgaon', 'SDL Parola', 'SDL Muktainagar', 'SDL Pachora', 'SDL Chopda', 'SDL Jamner'],
        'center_lat': 20.9977,
        'center_lon': 75.5626,
        'major_rivers': ['Tapi', 'Purna'],
        'major_water_bodies': ['Tapi River', 'Girna Dam'],
    },
    'Ahmednagar': {
        'region': 'Nashik Division',
        'labs': ['District Lab Ahmednagar', 'SDL Sangamner', 'SDL Rahata', 'SDL Karjat', 'SDL Pathardi', 'SDL Shrirampur'],
        'center_lat': 19.0948,
        'center_lon': 74.7480,
        'major_rivers': ['Pravara', 'Sina', 'Mula'],
        'major_water_bodies': ['Pravara River', 'Mula Dam'],
    },
    
    # Chhatrapati Sambhajinagar Division
    'Chhatrapati Sambhajinagar': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['Regional/District Lab Chhatrapati Sambhajinagar', 'SDL Gangapur', 'SDL Pachod', 'SDL Vaijapur', 'SDL Sillod'],
        'center_lat': 19.8762,
        'center_lon': 75.3433,
        'major_rivers': ['Godavari', 'Kham'],
        'major_water_bodies': ['Jayakwadi Dam', 'Godavari River'],
    },
    'Beed': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Beed', 'SDL Patoda', 'SDL Parli', 'SDL Majalgaon', 'SDL Georai'],
        'center_lat': 18.9894,
        'center_lon': 75.7589,
        'major_rivers': ['Manjra', 'Bendsura'],
        'major_water_bodies': ['Manjra River', 'Bendsura River'],
    },
    'Latur': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Latur', 'SDL Udgir', 'SDL Nilanga', 'SDL Ahmadpur', 'SDL Ausa'],
        'center_lat': 18.3996,
        'center_lon': 76.5598,
        'major_rivers': ['Manjra'],
        'major_water_bodies': ['Manjra River'],
    },
    'Jalna': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Jalna', 'SDL Ambad', 'SDL Mantha', 'SDL Jafrabad'],
        'center_lat': 19.8412,
        'center_lon': 75.8848,
        'major_rivers': ['Purna'],
        'major_water_bodies': ['Purna River'],
    },
    'Osmanabad': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Osmanabad', 'SDL Omerga', 'SDL Paranda', 'SDL Washi'],
        'center_lat': 18.1760,
        'center_lon': 76.0399,
        'major_rivers': ['Terna', 'Bori'],
        'major_water_bodies': ['Terna River'],
    },
    'Parbhani': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Parbhani', 'SDL Selu', 'SDL Bori', 'SDL Gangakhed', 'SDL Pathri'],
        'center_lat': 19.2608,
        'center_lon': 76.7791,
        'major_rivers': ['Purna', 'Dudhna'],
        'major_water_bodies': ['Purna River'],
    },
    'Hingoli': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Hingoli', 'SDL Wasmat', 'SDL Kalamnuri', 'SDL Sengaon'],
        'center_lat': 19.7167,
        'center_lon': 77.1500,
        'major_rivers': ['Penganga', 'Purna'],
        'major_water_bodies': ['Penganga River'],
    },
    'Nanded': {
        'region': 'Chhatrapati Sambhajinagar Division',
        'labs': ['District Lab Nanded', 'SDL Degloor', 'SDL Gokunda', 'SDL Hadgaon', 'SDL Kandar', 'SDL Mukhed', 'SDL Umri'],
        'center_lat': 19.1383,
        'center_lon': 77.3210,
        'major_rivers': ['Godavari', 'Penganga'],
        'major_water_bodies': ['Godavari River', 'Vishnupuri Dam'],
    },
    
    # Amravati Division
    'Amravati': {
        'region': 'Amravati Division',
        'labs': ['Regional/District Lab Amravati', 'SDL Achalpur', 'SDL Daryapur', 'SDL Dharni', 'SDL Morshi', 'SDL Nandgaon Kh.'],
        'center_lat': 20.9374,
        'center_lon': 77.7796,
        'major_rivers': ['Purna', 'Chandrabhaga'],
        'major_water_bodies': ['Purna River', 'Upper Wardha Dam'],
    },
    'Akola': {
        'region': 'Amravati Division',
        'labs': ['District Lab Akola', 'SDL Barshitakli', 'SDL Murtijapur', 'SDL Telhara'],
        'center_lat': 20.7002,
        'center_lon': 77.0082,
        'major_rivers': ['Purna', 'Morna'],
        'major_water_bodies': ['Purna River', 'Katepurna Reservoir'],
    },
    'Buldhana': {
        'region': 'Amravati Division',
        'labs': ['District Lab Buldhana', 'SDL Deulgaon Raja', 'SDL Jalgaon Jamod', 'SDL Khamgaon', 'SDL Malkapur', 'SDL Shegaon'],
        'center_lat': 20.5307,
        'center_lon': 76.1836,
        'major_rivers': ['Purna', 'Penganga'],
        'major_water_bodies': ['Purna River', 'Penganga River'],
    },
    'Washim': {
        'region': 'Amravati Division',
        'labs': ['District Lab Washim', 'SDL Malegaon', 'SDL Manora'],
        'center_lat': 20.1093,
        'center_lon': 77.1391,
        'major_rivers': ['Penganga', 'Arunavati'],
        'major_water_bodies': ['Penganga River'],
    },
    'Yavatmal': {
        'region': 'Amravati Division',
        'labs': ['District Lab Yavatmal', 'SDL Darwha', 'SDL Pusad', 'SDL Umarkhed', 'SDL Ralegaon', 'SDL Pandharkawada', 'SDL Wani'],
        'center_lat': 20.3984,
        'center_lon': 78.1308,
        'major_rivers': ['Penganga', 'Wardha'],
        'major_water_bodies': ['Penganga River', 'Upper Wardha Dam'],
    },
    
    # Nagpur Division
    'Nagpur': {
        'region': 'Nagpur Division',
        'labs': ['Regional/District Lab Nagpur', 'SDL Ramtek', 'SDL Narkhed', 'SDL Parsioni', 'SDL Hingna'],
        'center_lat': 21.1458,
        'center_lon': 79.0882,
        'major_rivers': ['Nag', 'Pench', 'Kanhan'],
        'major_water_bodies': ['Ambazari Lake', 'Nag River', 'Pench River'],
    },
    'Wardha': {
        'region': 'Nagpur Division',
        'labs': ['District Lab Wardha', 'SDL Pulgaon', 'SDL Arvi', 'SDL Samudrapur'],
        'center_lat': 20.7453,
        'center_lon': 78.5976,
        'major_rivers': ['Wardha', 'Dham'],
        'major_water_bodies': ['Wardha River'],
    },
    'Bhandara': {
        'region': 'Nagpur Division',
        'labs': ['District Lab Bhandara', 'SDL Tumsar', 'SDL Mohadi', 'SDL Pauni', 'SDL Lakhandur'],
        'center_lat': 21.1704,
        'center_lon': 79.6497,
        'major_rivers': ['Wainganga', 'Bagh'],
        'major_water_bodies': ['Wainganga River', 'Gosikhurd Dam'],
    },
    'Chandrapur': {
        'region': 'Nagpur Division',
        'labs': ['District Lab Chandrapur', 'SDL Rajura', 'SDL Bramhapuri', 'SDL Gondpipari', 'SDL Sindewahi', 'SDL Saoli', 'SDL Warora'],
        'center_lat': 19.9615,
        'center_lon': 79.2961,
        'major_rivers': ['Wardha', 'Wainganga', 'Erai'],
        'major_water_bodies': ['Wardha River', 'Erai Dam'],
    },
    'Gadchiroli': {
        'region': 'Nagpur Division',
        'labs': ['District Lab Gadchiroli', 'SDL Aheri', 'SDL Armori', 'SDL Chamorshi', 'SDL Kurkheda'],
        'center_lat': 20.1809,
        'center_lon': 80.0000,
        'major_rivers': ['Wainganga', 'Pranhita'],
        'major_water_bodies': ['Wainganga River', 'Pranhita River'],
    },
    'Gondia': {
        'region': 'Nagpur Division',
        'labs': ['District Lab Gondia', 'SDL Goreagon', 'SDL Deori', 'SDL Sadak/Arjuni', 'SDL Tiroda', 'SDL Navegaon', 'SDL Amgaon'],
        'center_lat': 21.4560,
        'center_lon': 80.1923,
        'major_rivers': ['Wainganga', 'Kathani'],
        'major_water_bodies': ['Wainganga River', 'Navegaon Lake'],
    },
}

# Continue in next file...
print(f"✅ Loaded district data for {len(MAHARASHTRA_DISTRICTS)} districts")

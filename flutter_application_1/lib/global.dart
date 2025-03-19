// const String API_BASE_URL = "http://10.0.2.2:8000";
const String API_BASE_URL = "https://lawngreen-chough-960104.hostingersite.com";

const String baseUrl = 'http://10.0.2.2:8000';
const Map<String, String> endpoints = {
  'Articulation': '$baseUrl/predict/articulation',
  'Childhood Apraxia': '$baseUrl/predict/apraxia',
  'Disfluency Disorder': '$baseUrl/predict/disfluency',
  'Phonological Disorder': '$baseUrl/predict/phonological',
};

int? globalUserId;
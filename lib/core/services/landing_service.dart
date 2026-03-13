import 'api_client.dart';

/// Servicio para obtener contenido de la Landing Page
class LandingService {
  final ApiClient _api;
  
  LandingService({ApiClient? api}) : _api = api ?? ApiClient();
  
  /// Obtiene los slides del carrusel
  Future<ApiResponse<List<Map<String, dynamic>>>> getCarouselSlides() async {
    return _api.get<List<Map<String, dynamic>>>(
      '/landing/carousel',
      fromJson: (json) {
        // Backend returns {slides: [...]}
        if (json is Map && json.containsKey('slides')) {
          final list = json['slides'] as List;
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }
  
  /// Obtiene las características/features
  Future<ApiResponse<List<Map<String, dynamic>>>> getFeatures() async {
    return _api.get<List<Map<String, dynamic>>>(
      '/landing/features',
      fromJson: (json) {
        // Backend returns {features: [...]}
        if (json is Map && json.containsKey('features')) {
          final list = json['features'] as List;
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }
  
  /// Obtiene la sección About
  Future<ApiResponse<Map<String, dynamic>>> getAboutSection() async {
    return _api.get<Map<String, dynamic>>(
      '/landing/about',
      fromJson: (json) {
        // Backend returns {about: {...}}
        if (json is Map && json.containsKey('about') && json['about'] != null) {
          return Map<String, dynamic>.from(json['about']);
        }
        if (json is Map) {
          return Map<String, dynamic>.from(json);
        }
        return <String, dynamic>{};
      },
    );
  }
  
  /// Obtiene información de contacto
  Future<ApiResponse<Map<String, dynamic>>> getContactInfo() async {
    return _api.get<Map<String, dynamic>>(
      '/landing/contact',
      fromJson: (json) {
        // Backend returns {contact: {...}}
        if (json is Map && json.containsKey('contact') && json['contact'] != null) {
          return Map<String, dynamic>.from(json['contact']);
        }
        if (json is Map) {
          return Map<String, dynamic>.from(json);
        }
        return <String, dynamic>{};
      },
    );
  }
  
  /// Obtiene todo el contenido de la landing page de una sola vez
  Future<LandingApiContent> getAllContent() async {
    final results = await Future.wait([
      getCarouselSlides(),
      getFeatures(),
      getAboutSection(),
      getContactInfo(),
    ]);
    
    return LandingApiContent(
      slides: results[0].isSuccess 
          ? (results[0].data as List<Map<String, dynamic>>?) ?? []
          : [],
      features: results[1].isSuccess 
          ? (results[1].data as List<Map<String, dynamic>>?) ?? []
          : [],
      about: results[2].isSuccess 
          ? (results[2].data as Map<String, dynamic>?) ?? {}
          : {},
      contact: results[3].isSuccess 
          ? (results[3].data as Map<String, dynamic>?) ?? {}
          : {},
    );
  }
  
  void dispose() {
    _api.dispose();
  }
}

/// Contenedor para todo el contenido de la landing page (API)
class LandingApiContent {
  final List<Map<String, dynamic>> slides;
  final List<Map<String, dynamic>> features;
  final Map<String, dynamic> about;
  final Map<String, dynamic> contact;
  
  const LandingApiContent({
    required this.slides,
    required this.features,
    required this.about,
    required this.contact,
  });
  
  bool get hasSlides => slides.isNotEmpty;
  bool get hasFeatures => features.isNotEmpty;
  bool get hasAbout => about.isNotEmpty;
  bool get hasContact => contact.isNotEmpty;
}

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Resultado de la subida de imagen
class ImageUploadResult {
  final bool success;
  final String? url;
  final String? error;
  final Uint8List? bytes;
  
  const ImageUploadResult({
    required this.success,
    this.url,
    this.error,
    this.bytes,
  });
  
  factory ImageUploadResult.success(String url, {Uint8List? bytes}) => ImageUploadResult(
    success: true,
    url: url,
    bytes: bytes,
  );
  
  factory ImageUploadResult.failure(String error) => ImageUploadResult(
    success: false,
    error: error,
  );
}

/// Especificaciones de imagen requeridas
class ImageSpecs {
  final int width;
  final int height;
  final List<String> allowedFormats;
  final int maxSizeKb;
  
  const ImageSpecs({
    this.width = 400,
    this.height = 400,
    this.allowedFormats = const ['jpg', 'jpeg', 'png'],
    this.maxSizeKb = 500,
  });
  
  double get aspectRatio => width / height;
  
  /// Especificaciones por defecto para aulas y landing page
  static const standard = ImageSpecs(
    width: 400,
    height: 400,
    allowedFormats: ['jpg', 'jpeg', 'png'],
    maxSizeKb: 500,
  );
}

/// Servicio para manejar imágenes (mock - sin Firebase)
/// TODO: Implementar con Firebase Storage cuando esté configurado
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();
  
  final ImagePicker _picker = ImagePicker();
  
  /// Selecciona una imagen del dispositivo
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      return null;
    }
  }
  
  /// Valida que la imagen cumpla con las especificaciones
  Future<String?> validateImage(XFile image, ImageSpecs specs) async {
    // Validar formato
    final extension = image.path.split('.').last.toLowerCase();
    if (!specs.allowedFormats.contains(extension)) {
      return 'Formato no permitido. Use: ${specs.allowedFormats.join(", ")}';
    }
    
    // Validar tamaño
    final bytes = await image.readAsBytes();
    final sizeKb = bytes.length / 1024;
    if (sizeKb > specs.maxSizeKb) {
      return 'La imagen es muy grande. Máximo: ${specs.maxSizeKb}KB';
    }
    
    return null; // Sin errores
  }
  
  /// Procesa una imagen seleccionada (mock - retorna URL temporal)
  /// En producción, esto subiría a Firebase Storage
  Future<ImageUploadResult> processImage({
    required XFile image,
    required String folder,
    String? customName,
    ImageSpecs specs = ImageSpecs.standard,
  }) async {
    try {
      // Validar imagen
      final validationError = await validateImage(image, specs);
      if (validationError != null) {
        return ImageUploadResult.failure(validationError);
      }
      
      // Leer bytes para preview local
      final bytes = await image.readAsBytes();
      
      // Generar URL mock (en producción sería la URL de Firebase)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = image.path.split('.').last.toLowerCase();
      final mockUrl = 'local://$folder/img_$timestamp.$extension';
      
      return ImageUploadResult.success(mockUrl, bytes: bytes);
    } catch (e) {
      return ImageUploadResult.failure('Error al procesar imagen: $e');
    }
  }
  
  /// Selecciona y procesa una imagen en un solo paso
  Future<ImageUploadResult> pickAndProcess({
    required String folder,
    ImageSource source = ImageSource.gallery,
    ImageSpecs specs = ImageSpecs.standard,
  }) async {
    final image = await pickImage(source: source);
    if (image == null) {
      return ImageUploadResult.failure('No se seleccionó ninguna imagen');
    }
    
    return processImage(
      image: image,
      folder: folder,
      specs: specs,
    );
  }
  
  /// Obtiene los bytes de una imagen para preview
  Future<Uint8List?> getImageBytes(XFile image) async {
    try {
      return await image.readAsBytes();
    } catch (e) {
      return null;
    }
  }
}

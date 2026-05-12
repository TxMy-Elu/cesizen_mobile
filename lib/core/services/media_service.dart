import 'package:url_launcher/url_launcher.dart';

const _supabaseHost = 'pcabklncvqwqrlhnrwda.supabase.co';

/// Vérifie si l'URL est hébergée sur Supabase Storage
bool isSupabaseUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.host == _supabaseHost || uri.host.endsWith('.supabase.co');
  } catch (_) {
    return false;
  }
}

/// Construit l'URL complète d'un média :
/// - URL absolue → retournée telle quelle
/// - Chemin relatif → préfixé avec l'URL de l'API
String resolveMediaUrl(String? media, {String apiBase = 'http://localhost:8080'}) {
  if (media == null || media.isEmpty) return '';
  if (media.startsWith('http')) return media;
  return '$apiBase$media';
}

/// Ouvre le média dans le navigateur externe.
/// Fonctionne pour les URLs Supabase (publiques) et les URLs backend.
Future<void> openMedia(String mediaUrl) async {
  final uri = Uri.parse(mediaUrl);
  final canOpen = await canLaunchUrl(uri);
  if (!canOpen) {
    throw Exception('Impossible d\'ouvrir : $mediaUrl');
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

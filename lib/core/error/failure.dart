class Failure implements Exception {
  Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String? readableApiMessage(String raw) {
  var text = raw.trim();
  if (text.length >= 2 && text.startsWith('"') && text.endsWith('"')) {
    text = text.substring(1, text.length - 1).trim();
  }
  if (text.isEmpty) return null;
  if (text.startsWith('Request failed')) return null;
  if (text.startsWith('{') || text.startsWith('<')) return null;
  if (text.length > 160) return null;
  return text;
}

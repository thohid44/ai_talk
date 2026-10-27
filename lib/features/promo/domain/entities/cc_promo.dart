class CcPromo {
  const CcPromo({
    required this.id,
    this.text,
    this.imageUrl,
    this.linkUrl,
    this.buttonText,
    this.buttonColor,
  });

  final String id;
  final String? text;
  final String? imageUrl;
  final String? linkUrl;
  final String? buttonText;
  final String? buttonColor;

  bool get isVisible {
    return (text != null && text!.isNotEmpty) ||
        (imageUrl != null && imageUrl!.isNotEmpty) ||
        (linkUrl != null && linkUrl!.isNotEmpty);
  }
}

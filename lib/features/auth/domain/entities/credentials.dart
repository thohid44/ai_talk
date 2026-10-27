class Credentials {
  const Credentials({required this.result, required this.token});

  final bool result;
  final String token;

  bool get isSuccess => result && token.trim().isNotEmpty;
}

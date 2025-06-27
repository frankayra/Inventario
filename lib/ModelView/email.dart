bool isValidEmail(String email) {
  final regex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");
  return regex.hasMatch(email);
}

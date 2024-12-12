class Validation {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (value.length < 6 || value.length > 30) {
      return 'Email should be between 6 and 30 characters';
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]{1,10}@(?!.*--)[a-zA-Z0-9-]{1,10}(?<!-)(\.[a-zA-Z0-9-]{2,10})+$");
    if (!emailRegex.hasMatch(value)) {
      return 'Email is incorrect';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6 || value.length > 10) {
      return 'Password should be between 6 and 10 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain a digit';
    }
    return null;
  }
}

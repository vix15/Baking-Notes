class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un correo electrónico';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor ingresa un correo electrónico válido';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    
    return null;
  }
  
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    
    if (double.tryParse(value) == null) {
      return 'Por favor ingresa un número válido';
    }
    
    return null;
  }
  
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numberValidation = validateNumber(value, fieldName);
    
    if (numberValidation != null) {
      return numberValidation;
    }
    
    final number = double.parse(value!);
    
    if (number <= 0) {
      return '$fieldName debe ser mayor que cero';
    }
    
    return null;
  }
}
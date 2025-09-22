class PhoneUtils {
  /// Нормализация: всегда возвращаем в формате +7...
  static String normalize(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), ''); // убираем всё кроме цифр

    if (digits.startsWith('8')) {
      digits = '7' + digits.substring(1);
    }

    if (!digits.startsWith('7')) {
      // если вообще какой-то левый формат
      throw Exception('Неверный формат номера');
    }

    return '+$digits';
  }
}

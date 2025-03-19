const String FNAME = 'user_firstName';
const String LNAME = 'user_lastName';
const String ID = 'user_id';
const String AGE = 'user_age';
const String EMAIL = 'user_email';
const String NUMBER = 'user_number';
const String CITY = 'city';
const String GENDER = 'gender';
const String FAV = 'isFavorite';
const String HOBBY = 'hobby';
const String PASSWORD = 'password';
const String LOGIN_TEXT = 'LOGIN';
const String REGISTER_TEXT = 'REGISTER';
const String PREF_ID = 'user_id';
const String PREF_IS_WIDGET_SELECTED = 'isWidgetSelected';

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printResultText(String text) {
  print('\x1B[31m$text\x1B[0m');
}

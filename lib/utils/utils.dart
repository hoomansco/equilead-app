int getAge(DateTime birthDate) {
  var now = DateTime.now();
  var age = now.year - birthDate.year;
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

// capitalize the first letter of every word
String capitalize(String s) {
  return s.split(' ').map((word) {
    if (word.isEmpty) {
      return '';
    }
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

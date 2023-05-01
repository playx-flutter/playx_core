///Helper method to capitalize first character of a string.
String capitalizeFirstChar(String str) {
  return '${str[0].toUpperCase()}${str.substring(1)}';
}

///Helper method to capitalize first character of each word of string.
String capitalizeFirstCharForEachWord(String str) {
  return str
      .split(' ')
      .map((s) => s.isEmpty ? '' : capitalizeFirstChar(s))
      .join(' ');
}

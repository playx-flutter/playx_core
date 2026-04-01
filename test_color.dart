import 'dart:ui';

void main() {
  const c = Color(0xFF112233);
  print(c.a);
  print(c.r);
  print(c.g);
  print(c.b);
  print(c.toARGB32().toRadixString(16));
}

import 'package:flutter_test/flutter_test.dart';

import 'package:mynotes/services/auth_service.dart';

void main() {
  test('messageFromCode traduit les erreurs courantes', () {
    expect(
      AuthService.messageFromCode('email-already-in-use'),
      contains('existe déjà'),
    );
    expect(
      AuthService.messageFromCode('invalid-credential'),
      contains('incorrect'),
    );
  });
}

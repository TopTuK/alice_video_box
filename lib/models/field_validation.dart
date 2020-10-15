mixin FieldValidationMixin {
  bool isFieldEmpty(String fieldText) => fieldText?.isEmpty ?? true;

  bool validateEmailField(String email) {
    if (email == null) return false;

    // email validation rgexp: https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'
      )
      .hasMatch(email);
  }
}

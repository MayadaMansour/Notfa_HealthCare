import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class NameInitialsWidget extends StatelessWidget {
  final String firstName;
  final String? lastName;
  final int? fontSize;
  final Color? color;

  NameInitialsWidget({required this.firstName, this.lastName, this.fontSize, this.color})
      : assert(firstName.isNotEmpty, '${locale.lblFirstName}${locale.lblCanNotBeEmpty}'),
        assert(lastName != null || lastName.validate().isEmpty, '${locale.lblLastName}${locale.lblCanNotBeEmpty}');

  @override
  Widget build(BuildContext context) {
    if (lastName != null) {
      return Text('${firstName[0]}${lastName.validate()[0]}', style: boldTextStyle(color: color ?? textPrimaryColorGlobal, size: fontSize ?? textBoldSizeGlobal.toInt()));
    }
    return Text(firstName[0], style: boldTextStyle(color: color ?? textPrimaryColorGlobal, size: fontSize ?? textBoldSizeGlobal.toInt()));
  }
}

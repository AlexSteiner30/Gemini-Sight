import 'dart:typed_data';

import 'package:app/helper/ble.dart';
import 'package:app/pages/sign_in.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> contacts(String name) async {
  String message = 'contacts¬$authentication_key¬';

  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    Contact? contact = contacts.firstWhere(
        (contact) => contact.displayName?.toLowerCase() == name.toLowerCase());

    if (contact.phones!.isNotEmpty) {
      message += contact.phones?.first.value ??
          "I coudn't find any matching phone number with $name";
    } else {
      message += "I coudn't find any matching contact with $name";
    }
  } else {
    message += 'Please grant me permission to access your contacts';
  }

  Uint8List return_value = Uint8List.fromList(message.codeUnits);

  write_data(return_value);
}

Future<void> call(String phone_number) async {
  Uint8List return_value =
      Uint8List.fromList('call¬$authentication_key¬'.codeUnits);

  launchUrlString("tel://$phone_number");
  write_data(return_value);
}

Future<void> text(String phone_number, message) async {
  Uint8List return_value =
      Uint8List.fromList('text¬$authentication_key¬'.codeUnits);
  await sendSMS(message: message, recipients: [phone_number]);
  write_data(return_value);
}

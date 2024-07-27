import 'package:app/pages/sign_in.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> contacts(String name) async {
  String return_value = 'contacts¬$authentication_key¬';

  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    Contact? contact = contacts.firstWhere(
        (contact) => contact.displayName?.toLowerCase() == name.toLowerCase());

    if (contact.phones!.isNotEmpty) {
      return_value += contact.phones?.first.value ??
          "I coudn't find any matching phone number with $name";
    } else {
      return_value += "I coudn't find any matching contact with $name";
    }
  } else {
    return_value += 'Please grant me permission to access your contacts';
  }
}

Future<void> call(String phone_number) async {
  String return_value = 'call¬$authentication_key¬';

  launchUrlString("tel://$phone_number");
}

Future<void> text(String phone_number, message) async {
  String return_value = 'text¬$authentication_key¬';
  await sendSMS(message: message, recipients: [phone_number]);
}

// send return value w ble

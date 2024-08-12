import 'package:app/helper/ble.dart';
import 'package:app/pages/sign_in.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Function to find a contact by name and perform an action based on whether the contact has a phone number.
///
/// Parameters:
///   - String name: The name of the contact to find.
Future<void> contacts(String name) async {
  String message = 'contacts|$authentication_key|';

  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    Contact? contact = contacts.firstWhere(
        (contact) => contact.displayName?.toLowerCase() == name.toLowerCase());

    if (contact.phones!.isNotEmpty) {
      message += contact.phones?.first.value ??
          "I couldn't find any matching phone number with $name";
    } else {
      message += "I couldn't find any matching contact with $name";
    }
  } else {
    message += 'Please grant me permission to access your contacts';
  }

  write_data(message);
}

/// Function to initiate a phone call to the given phone number.
///
/// Parameters:
///   - String phone_number: The phone number to call.
Future<void> call(String phone_number) async {
  launchUrlString("tel://$phone_number");
  write_data('call|$authentication_key|');
}

/// Function to send an SMS to the given phone number with a provided message.
///
/// Parameters:
///   - String phone_number: The recipient's phone number.
///   - String message: The message to send.
Future<void> text(String phone_number, String message) async {
  await sendSMS(message: message, recipients: [phone_number]);
  write_data('text|$authentication_key|');
}

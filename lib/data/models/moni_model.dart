enum ChatSender { user, bot}

class MoniModel {
  final String text;
  final ChatSender sender;
  final DateTime time;

  MoniModel({
    required this.text,
    required this.sender,
    required this.time,
  });
}
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:kivicare_flutter/utils/colors.dart';
// import 'package:mime/mime.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

// class ChatRoom extends StatefulWidget {
//   const ChatRoom({super.key});
//
//   @override
//   State<ChatRoom> createState() => _ChatRoomState();
// }

// class _ChatRoomState extends State<ChatRoom> {
//   List<types.Message> _messages = [];
//   final _user = const types.User(
//     id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//   }
//
//   void _addMessage(
//     types.Message message,
//   ) {
//     setState(() {
//       _messages.insert(
//         0,
//         message,
//       );
//     });
//   }
//
//   void _handleAttachmentPressed() {
//     showModalBottomSheet<void>(
//       // constraints: BoxConstraints(maxHeight: 100,maxWidth: 100),
//       context: context,
//       builder: (BuildContext context) => SafeArea(
//         child: Container(
//           height: 150,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Row(
//                 children: [
//                   IconButton(onPressed: () {}, icon: Icon(Icons.photo)),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _handleImageSelection();
//                     },
//                     child: const Align(
//                       alignment: AlignmentDirectional.centerStart,
//                       child:
//                           Text('Photo', style: TextStyle(color: Colors.grey)),
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   IconButton(onPressed: () {}, icon: Icon(Icons.file_open)),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _handleFileSelection();
//                     },
//                     child: const Align(
//                       alignment: AlignmentDirectional.centerStart,
//                       child: Text('File', style: TextStyle(color: Colors.grey)),
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   IconButton(onPressed: () {}, icon: Icon(Icons.cancel)),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Align(
//                       alignment: AlignmentDirectional.centerStart,
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleFileSelection() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );
//
//     if (result != null && result.files.single.path != null) {
//       final message = types.FileMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         id: const Uuid().v4(),
//         mimeType: lookupMimeType(result.files.single.path!),
//         name: result.files.single.name,
//         size: result.files.single.size,
//         uri: result.files.single.path!,
//       );
//
//       _addMessage(message);
//     }
//   }
//
//   void _handleImageSelection() async {
//     final result = await ImagePicker().pickImage(
//       imageQuality: 70,
//       maxWidth: 1440,
//       source: ImageSource.gallery,
//     );
//
//     if (result != null) {
//       final bytes = await result.readAsBytes();
//       final image = await decodeImageFromList(bytes);
//
//       final message = types.ImageMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         height: image.height.toDouble(),
//         id: const Uuid().v4(),
//         name: result.name,
//         size: bytes.length,
//         uri: result.path,
//         width: image.width.toDouble(),
//       );
//
//       _addMessage(message);
//     }
//   }
//
//   void _handleMessageTap(BuildContext _, types.Message message) async {
//     if (message is types.FileMessage) {
//       var localPath = message.uri;
//       if (message.uri.startsWith('http')) {
//         try {
//           final index =
//               _messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (_messages[index] as types.FileMessage).copyWith(
//             isLoading: true,
//           );
//           setState(() {
//             _messages[index] = updatedMessage;
//           });
//           final client = http.Client();
//           final request = await client.get(Uri.parse(message.uri));
//           final bytes = request.bodyBytes;
//           final documentsDir = (await getApplicationDocumentsDirectory()).path;
//           localPath = '$documentsDir/${message.name}';
//           if (!File(localPath).existsSync()) {
//             final file = File(localPath);
//             await file.writeAsBytes(bytes);
//           }
//         } finally {
//           final index =
//               _messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (_messages[index] as types.FileMessage).copyWith(
//             isLoading: null,
//           );
//
//           setState(() {
//             _messages[index] = updatedMessage;
//           });
//         }
//       }
//
//       await OpenFilex.open(localPath);
//     }
//   }
//
//   void _handlePreviewDataFetched(
//     types.TextMessage message,
//     types.PreviewData previewData,
//   ) {
//     final index = _messages.indexWhere((element) => element.id == message.id);
//     final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
//       previewData: previewData,
//     );
//
//     setState(() {
//       _messages[index] = updatedMessage;
//     });
//   }
//
//   void _handleSendPressed(types.PartialText message) {
//     final textMessage = types.TextMessage(
//       author: _user,
//       showStatus: true,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: const Uuid().v4(),
//       text: message.text,
//     );
//     _addMessage(textMessage);
//   }
//
//   void _loadMessages() async {
//     final response = await rootBundle.loadString('assets/messages.json');
//     final messages = (jsonDecode(response) as List)
//         .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
//         .toList();
//
//     setState(() {
//       _messages = messages;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: Chat(
//           messages: _messages,
//           onAttachmentPressed: _handleAttachmentPressed,
//           onMessageTap: _handleMessageTap,
//           onPreviewDataFetched: _handlePreviewDataFetched,
//           onSendPressed: _handleSendPressed,
//           showUserAvatars: true,
//           showUserNames: true,
//           user: _user,
//           emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
//           theme: DefaultChatTheme(
//             backgroundColor: background,
//             dateDividerTextStyle: TextStyle(color: Colors.black),
//             dateDividerMargin: EdgeInsets.all(10),
//             deliveredIcon: Icon(Icons.send),
//             inputBackgroundColor: primaryColor,
//             inputBorderRadius: BorderRadius.circular(2),
//             inputTextColor: Colors.white,
//             primaryColor: Colors.grey,
//             secondaryColor: Colors.grey,
//           ),
//         ),
//       );
// }

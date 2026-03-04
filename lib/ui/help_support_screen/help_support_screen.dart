import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/ChatVideoContainer.dart';
import 'package:customer/model/conversation_model.dart';
import 'package:customer/model/inbox_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/chat_screen/FullScreenImageViewer.dart';
import 'package:customer/ui/chat_screen/FullScreenVideoViewer.dart';
import 'package:customer/ui/chat_screen/chat_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class HelpSupportScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userProfileImage;
  final String? token;
  final bool? isShowAppbar;

  const HelpSupportScreen({super.key, this.isShowAppbar, this.userId, this.userName, this.userProfileImage, this.token});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  UserModel userModel = UserModel();

  @override
  void initState() {
    super.initState();

    setSeen();
  }

  Future<void> startRecording() async {
    if (await record?.hasPermission() == true) {
      final dir = await getTemporaryDirectory();
      recordedFilePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await record?.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
            numChannels: 1,
          ),
          path: recordedFilePath!);
    }
  }

  Future<void> setSeen() async {
    // await Preferences.setString(Preferences.notificationPlayload, '');
    FireStoreUtils.setSeen();
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value?.id != null) {
        userModel = value!;
      }
    });
  }

  AudioRecorder? record = AudioRecorder();
  bool isStartRecording = false;
  String? recordedFilePath;

  Future<String?> stopRecording() async {
    return await record?.stop();
  }

  final player = AudioPlayer();
  Future<void> playVoice(String url) async {
    await player.setUrl(url);
    player.play();
  }

  @override
  void dispose() {
    FireStoreUtils.stopSeenListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      appBar: widget.isShowAppbar == true
          ? AppBar(
              elevation: 2,
              title: Text('Help & Support'.tr, maxLines: 2, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
              leading: InkWell(
                  onTap: () {
                    Get.offAll(DashBoardScreen());
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  )),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(CollectionName.chat).doc(FireStoreUtils.getCurrentUid()).collection("thread").orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Constant.loader(isDarkTheme: themeChange.getThem());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return SizedBox();
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                          reverse: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            ConversationModel inboxModel = ConversationModel.fromJson(docs[index].data() as Map<String, dynamic>);
                            return chatItemView(inboxModel.senderId == FireStoreUtils.getCurrentUid(), inboxModel);
                          });
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                    controller: _messageController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        filled: true,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: isStartRecording == true
                                  ? themeChange.getThem()
                                      ? AppColors.darksecondprimary
                                      : AppColors.lightsecondprimary
                                  : themeChange.getThem()
                                      ? AppColors.darkTextFieldBorder
                                      : AppColors.textFieldBorder,
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: isStartRecording == true
                                  ? themeChange.getThem()
                                      ? AppColors.darksecondprimary
                                      : AppColors.lightsecondprimary
                                  : themeChange.getThem()
                                      ? AppColors.darkTextFieldBorder
                                      : AppColors.textFieldBorder,
                              width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: isStartRecording == true
                                  ? themeChange.getThem()
                                      ? AppColors.darksecondprimary
                                      : AppColors.lightsecondprimary
                                  : themeChange.getThem()
                                      ? AppColors.darkTextFieldBorder
                                      : AppColors.textFieldBorder,
                              width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: isStartRecording == true
                                  ? themeChange.getThem()
                                      ? AppColors.darksecondprimary
                                      : AppColors.lightsecondprimary
                                  : themeChange.getThem()
                                      ? AppColors.darkTextFieldBorder
                                      : AppColors.textFieldBorder,
                              width: 1),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onLongPress: () async {
                                setState(() => isStartRecording = true);
                                await startRecording();
                              },
                              onLongPressUp: () async {
                                setState(() => isStartRecording = false);
                                final path = await stopRecording();
                                if (path != null) {
                                  ShowToastDialog.showLoader("Please wait");
                                  String? url = await Constant().uploadVoiceMessage(path);
                                  final duration = await player.setFilePath(path);
                                  _sendMessage(_messageController.text, Url(url: url), '', 'voice', voiceTimer: duration?.inSeconds);
                                  ShowToastDialog.closeLoader();
                                  _messageController.clear();
                                  setState(() {});
                                }
                              },
                              child: Icon(Icons.mic,
                                  color: isStartRecording == true
                                      ? themeChange.getThem()
                                          ? AppColors.darksecondprimary
                                          : AppColors.lightsecondprimary
                                      : themeChange.getThem()
                                          ? AppColors.background
                                          : AppColors.darkTextFieldBorder),
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (_messageController.text.isNotEmpty) {
                                    _sendMessage(_messageController.text, null, '', 'text');
                                    _messageController.clear();
                                    setState(() {});
                                  } else {
                                    ShowToastDialog.showToast("Please enter text".tr);
                                  }
                                },
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                )),
                          ],
                        ),
                        prefixIcon: IconButton(
                          onPressed: () async {
                            _onCameraClick();
                          },
                          icon: Icon(Icons.camera_alt,
                              color: isStartRecording == true
                                  ? themeChange.getThem()
                                      ? AppColors.darksecondprimary
                                      : AppColors.lightsecondprimary
                                  : themeChange.getThem()
                                      ? AppColors.background
                                      : AppColors.darkTextFieldBorder),
                        ),
                        hintText: isStartRecording == true ? 'Start Recording...'.tr : 'Start typing ...'.tr,
                        hintStyle: TextStyle(
                            fontWeight: isStartRecording == true ? FontWeight.bold : FontWeight.w600,
                            color: isStartRecording == true
                                ? themeChange.getThem()
                                    ? AppColors.darksecondprimary
                                    : AppColors.lightsecondprimary
                                : null)),
                    onSubmitted: (value) async {
                      if (_messageController.text.isNotEmpty) {
                        _sendMessage(_messageController.text, null, '', 'text');
                        _messageController.clear();
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatItemView(bool isMe, ConversationModel data) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: isMe
          ? Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      data.messageType == "text"
                          ? Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text(
                                data.message.toString(),
                                style: TextStyle(
                                    color: data.senderId == FireStoreUtils.getCurrentUid()
                                        ? themeChange.getThem()
                                            ? Colors.black
                                            : Colors.white
                                        : Colors.black),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: data.messageType == "image"
                                  ? ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: 50,
                                        maxWidth: 200,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                        child: Stack(alignment: Alignment.center, children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(FullScreenImageViewer(
                                                imageUrl: data.url!.url,
                                              ));
                                            },
                                            child: Hero(
                                              tag: data.url!.url,
                                              child: CachedNetworkImage(
                                                imageUrl: data.url!.url,
                                                placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ))
                                  : data.messageType == "voice"
                                      ? VoiceBubble(
                                          url: data.url!.url,
                                          durationSec: data.recordingTimer ?? 0,
                                          isme: isMe,
                                        )
                                      : ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 50,
                                            maxWidth: 200,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              log("data.url?.videoThumbnail :: ${data.videoThumbnail}");
                                              Get.to(FullScreenVideoViewer(
                                                heroTag: data.id.toString(),
                                                videoUrl: data.url!.url,
                                              ));
                                            },
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                              child: Stack(alignment: Alignment.center, children: [
                                                Hero(
                                                  tag: data.url!.url,
                                                  child: CachedNetworkImage(
                                                    imageUrl: data.videoThumbnail ?? '',
                                                    placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                  ),
                                                ),
                                                Icon(Icons.play_arrow, size: 40)
                                              ]),
                                            ),
                                          )),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            height: Responsive.width(5, context),
                            width: Responsive.width(5, context),
                            imageUrl: userModel.profilePic.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                            errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Constant.dateAndTimeFormatTimestamp(data.createdAt), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400)),
                      if (data.senderId == widget.userId)
                        data.seen == true
                            ? Text("✓✓",
                                style: GoogleFonts.poppins(fontSize: 10, color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary, fontWeight: FontWeight.w400))
                            : Text("✓", style: GoogleFonts.poppins(fontSize: 10, color: AppColors.subTitleColor, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    data.messageType == "text"
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                              color: Colors.grey.shade300,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              data.message.toString(),
                              style: GoogleFonts.poppins(color: Colors.black),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: data.messageType == "image"
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 50,
                                      maxWidth: 200,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                      child: Stack(alignment: Alignment.center, children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(FullScreenImageViewer(
                                              imageUrl: data.url!.url,
                                            ));
                                          },
                                          child: Hero(
                                            tag: data.url!.url,
                                            child: CachedNetworkImage(
                                              imageUrl: data.url!.url,
                                              placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ))
                                : data.messageType == "voice"
                                    ? VoiceBubble(
                                        url: data.url!.url,
                                        durationSec: data.recordingTimer ?? 0,
                                        isme: isMe,
                                      )
                                    : ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 50,
                                          maxWidth: 200,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(FullScreenVideoViewer(
                                              heroTag: data.id.toString(),
                                              videoUrl: data.url!.url,
                                            ));
                                          },
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                            child: Stack(alignment: Alignment.center, children: [
                                              Hero(
                                                tag: data.url!.url,
                                                child: CachedNetworkImage(
                                                  imageUrl: data.videoThumbnail ?? '',
                                                  placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                                ),
                                              ),
                                              Icon(Icons.play_arrow, size: 40)
                                            ]),
                                          ),
                                        )),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                    Text(Constant.dateAndTimeFormatTimestamp(data.createdAt), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _sendMessage(String message, Url? url, String videoThumbnail, String messageType, {int? voiceTimer}) async {
    List<String> senderReceiverId = [Constant.adminType!, widget.userId!];
    InboxModel inboxModel = InboxModel(
      senderReceiverId: senderReceiverId,
      senderId: widget.userId,
      receiverId: Constant.adminType,
      lastSenderId: widget.userId,
      createdAt: Timestamp.now(),
      lastMessage: _messageController.text,
      chatType: Constant.currentUserType,
      type: 'adminchat',
    );

    await FireStoreUtils.addInAdminBox(inboxModel);

    ConversationModel conversationModel = ConversationModel(
        id: const Uuid().v4(),
        message: message,
        senderId: FireStoreUtils.getCurrentUid(),
        receiverId: Constant.adminType,
        createdAt: Timestamp.now(),
        url: url,
        messageType: messageType,
        videoThumbnail: videoThumbnail,
        recordingTimer: voiceTimer,
        seen: false);

    if (url != null) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent an image";
      } else if (url.mime.contains('video')) {
        conversationModel.message = "sent an Video";
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "Sent a voice message";
      } else if (messageType == 'voice') {
        conversationModel.message = "Sent a voice message";
      }
    }

    await FireStoreUtils.addAdminChat(conversationModel);

    // Map<String, dynamic> playLoad = <String, dynamic>{
    //   "type": "chat",
    //   "driverId": widget.driverId,
    //   "customerId": widget.customerId,
    //   "orderId": widget.orderId,
    // };

    // SendNotification.sendOneNotification(
    //     title: "${widget.driverName} ${messageType == "image" ? messageType == "video" ? "sent video to you" : "sent image to you" : "sent message to you"}",
    //     body: conversationModel.message.toString(),
    //     token: widget.token.toString(),
    //     payload: playLoad);
  }

  final ImagePicker _imagePicker = ImagePicker();

  void _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Media'.tr,
        style: GoogleFonts.poppins(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Choose image from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(galleryVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child: Text("Choose video from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child: Text("Take a Photo".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(recordedVideo.path));
              if (videoContainer != null) {
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              } else {
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child: Text("Record video".tr),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel'.tr,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}

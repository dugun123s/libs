import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart';

import '../constatnt/Constant.dart';
import '../constatnt/global.dart';
import '../helper/sizeconfig.dart';
import 'chat.dart';
import 'groupChat/groupChat.dart';
import 'groupChat/createGroup.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late String userId = '';
  late List<DocumentSnapshot> chatList = [];

  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollBottomBarController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isScrollingDown = false;
  bool selectAll = false;
  List<String> selectPeerId = [];
  List<String> groupUsersId = [];
  List<String> groupUsersNames = [];
  List<String> groupUsersImages = [];
  bool callfunction = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    myScroll();
  }

  Future<void> _initializeUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await getPhoto();
      await getLocalImages();
      await _getToken();
    }
  }

  Future<void> getPhoto() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userID = prefs.getString('key') ?? '';
        globalImage = prefs.getString('photo') ?? '';
        globalName = prefs.getString('nick') ?? '';
        mobNo = '';
        fullMob = '';
      });
    }
  }

  Future<void> getLocalImages() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('localImage')) {
      setState(() {
        localImage = prefs.getStringList('localImage') ?? [];
      });
    }
  }

  Future<void> _getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('FCM Token: $token');
    }
  }

  void myScroll() {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          setState(() {});
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTitle(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollBottomBarController,
              child: friendListToMessage(userId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        top: MediaQuery.of(context).padding.top + 10,
        right: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(15.0),
        ),
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onSearchTextChanged,
          style: const TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(15.0),
            ),
            filled: true,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            hintText: "Ara",
            contentPadding: const EdgeInsets.only(top: 10.0),
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 25.0),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Sohbetler",
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            fontWeight: FontWeight.bold,
            fontFamily: "MontserratBold",
            color: appColorBlack,
          ),
        ),
      ),
    );
  }

  Widget friendListToMessage(String userData) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chatList")
          .doc(userData)
          .collection(userData)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CupertinoActivityIndicator());
        }

        chatList = snapshot.data!.docs;
        return chatList.isEmpty
            ? _buildEmptyChatList()
            : ListView.builder(
                itemCount: chatList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final chatType = chatList[index].get('chatType') as String?;
                  return chatType == "group"
                      ? buildGroupItem(chatList, index)
                      : buildItem(chatList, index);
                },
              );
      },
    );
  }

  Widget _buildEmptyChatList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 4),
          Text(
            "Sohbet Listen Boş",
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 5,
              fontWeight: FontWeight.bold,
              fontFamily: "MontserratBold",
              color: appColorBlack,
            ),
          ),
          const SizedBox(height: 15),
          Image.asset("assets/images/noimage.jpeg", width: 200),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Sohbet listende kimse yok mesajlaşman için shuffle listesine göz at",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(List<DocumentSnapshot> chatList, int index) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(chatList[index].id)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        if (!userSnapshot.hasData) {
          return Container();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return Container();

        final nickname = userData['nick'] as String? ?? '';

        if (controller.text.isNotEmpty &&
            !nickname.toLowerCase().contains(controller.text.toLowerCase())) {
          return Container();
        }

        return _buildChatListItem(chatList[index], userData);
      },
    );
  }

  Widget _buildChatListItem(
      DocumentSnapshot chat, Map<String, dynamic> userData) {
    return Column(
      children: [
        const Divider(height: 10),
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                label: 'More',
                backgroundColor: Colors.grey[400] ?? Colors.grey,
                foregroundColor: Colors.black,
                icon: Icons.more_horiz,
                onPressed: (_) => _showOptionsModal(chat, userData),
              ),
            ],
          ),
          child: _buildChatListTile(chat, userData),
        ),
      ],
    );
  }

  Widget _buildChatListTile(
      DocumentSnapshot chat, Map<String, dynamic> userData) {
    return ListTile(
      leading: _buildAvatar(userData),
      title: Text(
        userData['nick'] as String? ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: appColorBlack,
        ),
      ),
      subtitle: _buildSubtitle(chat, userData),
      trailing: _buildTrailingWidget(chat),
      onTap: () => _navigateToChat(chat, userData),
      onLongPress: () => _showOptionsModal(chat, userData),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> userData) {
    return Container(
      height: 50,
      width: 50,
      child: DashedCircle(
        gapSize: 20,
        dashes: 20,
        color: Color(math.Random().nextInt(0xFFFFFFFF) | 0xFF000000),
        child: Padding(
          padding: const EdgeInsets.all(0.75),
          child: CircleAvatar(
            backgroundImage: NetworkImage(userData['photo'] as String? ?? ''),
            backgroundColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(DocumentSnapshot chat, Map<String, dynamic> userData) {
    if (userData['status'] == 'typing' && userData['inChat'] == userID) {
      return Text(
        'typing..',
        style: TextStyle(color: appColorBlue, fontSize: 13),
      );
    }

    final type = chat.get('type') as String?;
    final content = chat.get('content') as String?;

    return msgTypeWidget(type, content);
  }

  Widget _buildTrailingWidget(DocumentSnapshot chat) {
    final timestamp = chat.get('timestamp') as Timestamp?;
    final badge = int.tryParse(chat.get('badge') as String? ?? '0') ?? 0;
    final isPinned =
        chat.get('pin') != null && chat.get('pin').toString().isNotEmpty;
    final isMuted = chat.get('mute') == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timestamp != null
              ? format(timestamp.toDate(), locale: 'en_short')
              : '',
          style: TextStyle(
            color: badge > 0 ? Colors.blue : Colors.grey,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge > 0) _buildBadgeCounter(badge),
            if (isPinned) Icon(Icons.push_pin, color: Colors.grey, size: 16),
            if (isMuted) Icon(Icons.volume_off, color: Colors.grey, size: 17),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeCounter(int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      alignment: Alignment.center,
      height: 20,
      width: 20,
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget msgTypeWidget(String? type, String? content) {
    switch (type) {
      case 'image':
        return Row(
          children: const [
            Icon(Icons.photo, color: Colors.grey, size: 15),
            SizedBox(width: 5),
            Text('Photo', style: TextStyle(color: Colors.grey)),
          ],
        );
      case 'video':
        return Row(
          children: const [
            Icon(Icons.videocam, color: Colors.grey, size: 15),
            SizedBox(width: 5),
            Text('Video', style: TextStyle(color: Colors.grey)),
          ],
        );
      default:
        return Text(
          content ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        );
    }
  }

  void _navigateToChat(DocumentSnapshot chat, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => Chat(
          peerName: userData['nick'] as String? ?? '',
          peerID: chat.id,
          archive: chat.get('archive') as bool? ?? false,
          pin: chat.get('pin')?.toString().isNotEmpty == true
              ? '2549518301000'
              : '',
          mute: chat.get('mute') as bool? ?? false,
          chatListTime: chat.get('timestamp'),
          currentUserId: userId,
          peerToken:
              userData['token'] as String? ?? '', // Added required parameter
        ),
      ),
    );
  }

  void _showOptionsModal(DocumentSnapshot chat, Map<String, dynamic> userData) {
    _settingModalBottomSheetNormal(
      context,
      userId,
      chat.id,
      chat.get('archive') as bool? ?? false,
      chat.get('timestamp') as Timestamp?,
      chat.get('pin'),
      chat.get('mute') as bool? ?? false,
      userData['nick'] as String? ?? '',
    );
  }

  Future<void> _settingModalBottomSheetNormal(
    BuildContext context,
    String currentUserId,
    String peerId,
    bool archive,
    Timestamp? timestamp,
    dynamic pin,
    bool mute,
    String peerName,
  ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.archive_outlined,
                      color: Colors.black87, size: 20),
                ),
                title: Text(archive ? 'Arşivden Çıkar' : 'Arşive Ekle'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('chatList')
                      .doc(currentUserId)
                      .collection(currentUserId)
                      .doc(peerId)
                      .update({'archive': !archive});
                },
              ),
              ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.push_pin_outlined,
                      color: Colors.black87, size: 20),
                ),
                title: Text(pin != null && pin.toString().isNotEmpty
                    ? 'Sabitlemeyi Kaldır'
                    : 'Sohbeti Sabitle'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('chatList')
                      .doc(currentUserId)
                      .collection(currentUserId)
                      .doc(peerId)
                      .update({
                    'pin': pin != null && pin.toString().isNotEmpty
                        ? ''
                        : timestamp?.toString() ?? DateTime.now().toString(),
                  });
                },
              ),
              ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    mute ? Icons.volume_up : Icons.volume_off_outlined,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
                title: Text(mute ? 'Bildirimleri Aç' : 'Bildirimleri Kapat'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('chatList')
                      .doc(currentUserId)
                      .collection(currentUserId)
                      .doc(peerId)
                      .update({'mute': !mute});
                },
              ),
              ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                ),
                title: const Text('Sohbeti Sil',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(currentUserId, peerId, peerName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildGroupItem(List<DocumentSnapshot> chatList, int index) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groop')
          .doc(chatList[index].id)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) return Container();

        final groupData = snapshot.data!.data() as Map<String, dynamic>?;
        if (groupData == null) return Container();

        final groupName = groupData['groupName'] as String? ?? '';
        if (controller.text.isNotEmpty &&
            !groupName.toLowerCase().contains(controller.text.toLowerCase())) {
          return Container();
        }

        return _buildGroupListItem(chatList[index], groupData);
      },
    );
  }

  Widget _buildGroupListItem(
      DocumentSnapshot chat, Map<String, dynamic> groupData) {
    return Column(
      children: [
        const Divider(height: 10),
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                label: 'More',
                backgroundColor: Colors.grey[400] ?? Colors.grey,
                foregroundColor: Colors.black,
                icon: Icons.more_horiz,
                onPressed: (_) => _showGroupOptionsModal(chat, groupData),
              ),
            ],
          ),
          child: _buildGroupListTile(chat, groupData),
        ),
      ],
    );
  }

  Widget _buildGroupListTile(
      DocumentSnapshot chat, Map<String, dynamic> groupData) {
    final List<dynamic> joins = groupData['joins'] as List<dynamic>? ?? [];
    final List<dynamic> muteds = groupData['muteds'] as List<dynamic>? ?? [];
    final List<dynamic> pins = groupData['pins'] as List<dynamic>? ?? [];

    return ListTile(
      leading: _buildGroupAvatar(groupData['groupImage'] as String?),
      title: Text(
        groupData['groupName'] as String? ?? '',
        style: TextStyle(fontWeight: FontWeight.bold, color: appColorBlack),
      ),
      subtitle: _buildSubtitle(chat, {'status': '', 'inChat': ''}),
      trailing: _buildTrailingWidget(chat),
      onTap: () => _navigateToGroupChat(chat, groupData, joins, muteds, pins),
      onLongPress: () => _showGroupOptionsModal(chat, groupData),
    );
  }

  void _showGroupOptionsModal(
      DocumentSnapshot chat, Map<String, dynamic> groupData) {
    _settingModalBottomSheetNormal(
      context,
      userId,
      chat.id,
      chat.get('archive') as bool? ?? false,
      chat.get('timestamp') as Timestamp?,
      groupData['pins']?.contains(userId),
      groupData['muteds']?.contains(userId) ?? false,
      groupData['groupName'] as String? ?? '',
    );
  }

  void _navigateToGroupChat(
    DocumentSnapshot chat,
    Map<String, dynamic> groupData,
    List<dynamic> joins,
    List<dynamic> muteds,
    List<dynamic> pins,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GroupChat(
          joined: joins.contains(userId),
          joins: joins.cast<String>(),
          currentuser: userId,
          currentusername: globalName,
          currentuserimage: globalImage,
          peerID: chat.id,
          peerUrl: groupData['groupImage'] as String? ?? '',
          peerName: groupData['groupName'] as String? ?? '',
          archive: chat.get('archive') as bool? ?? false,
          mute: muteds.contains(userId),
          muteds: muteds.cast<String>(),
          pins: pins.cast<String>(),
          peerToken: '',
          pin: '',
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      String currentUserId, String peerId, String peerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sohbeti Sil'),
          content: Text(
              '$peerName ile olan sohbeti silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('chatList')
                    .doc(currentUserId)
                    .collection(currentUserId)
                    .doc(peerId)
                    .delete();
              },
            ),
          ],
        );
      },
    );
  }

  void onSearchTextChanged(String text) {
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollBottomBarController.dispose();
    super.dispose();
  }
}

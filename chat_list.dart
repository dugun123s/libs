import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:diemchat/Screens/widgets/groopLength.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:diemchat/Screens/archiveChatList.dart';

import 'package:diemchat/Screens/saveContact.dart';
// import 'package:diemchat/Screens/search.dart';
import 'package:diemchat/Screens/contactinfo.dart';
import 'package:diemchat/Screens/groupChat/groupChat.dart';
import 'package:diemchat/Screens/newchat.dart';
import 'package:diemchat/constatnt/Constant.dart';
import 'package:diemchat/constatnt/global.dart';
import 'package:diemchat/helper/sizeconfig.dart';
import 'package:diemchat/story/editor.dart';
import 'package:timeago/timeago.dart';
import 'chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:bot_toast/bot_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'groupChat/createGroup1.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String userId;
  final FirebaseDatabase database = new FirebaseDatabase();
  TextEditingController controller = new TextEditingController();
  bool selectAll = false;
  var selectPeerId = [];

  var groupUsersId = [];
  var groupUsersNames = [];
  var groupUsersImages = [];
  bool callfunction = true;

  //APP BAR SCROLL
  bool _showAppbar = true;
  ScrollController _scrollBottomBarController = new ScrollController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isScrollingDown = false;
  Future getPhoto() async {
    userID = _auth.currentUser.uid;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalImage = prefs.getString("photo");
    globalName = prefs.getString("nick");
    userID = prefs.getString("key");

    setState(() {});
  }

  @override
  void initState() {
    getPhoto();
    getLocalImages();

    setState(() {
      userId = _auth.currentUser.uid;

      userID = "";
      globalName = "";
      globalImage = "";
      mobNo = "";
      fullMob = "";
    });

    _getToken();
    myScroll();
    super.initState();
  }

  getLocalImages() async {
    localImage.clear();
    SharedPreferences preferences1 = await SharedPreferences.getInstance();
    if (preferences1.containsKey("localImage")) {
      setState(() {
        localImage = preferences1.getStringList('localImage');
        print("😆😆😆😆😆😆");
        print(localImage);
      });
    }
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  void showBottomBar() {
    setState(() {});
  }

  void hideBottomBar() {
    setState(() {});
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          hideBottomBar();
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          showBottomBar();
        }
      }
    });
  }

  _getToken() {
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        print(token);
      });
    });
  }

  List chatList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollBottomBarController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, top: MediaQuery.of(context).padding.top),
                    child: Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 5, left: 5),
                        child: Container(
                          decoration: new BoxDecoration(
                              color: Colors.green,
                              borderRadius: new BorderRadius.all(
                                Radius.circular(15.0),
                              )),
                          height: 40,
                          child: Center(
                            child: TextField(
                              controller: controller,
                              onChanged: onSearchTextChanged,
                              style: TextStyle(color: Colors.grey),
                              decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.grey[200]),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15.0),
                                  ),
                                ),
                                filled: true,
                                hintStyle: new TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                                hintText: "Ara",
                                contentPadding: EdgeInsets.only(top: 10.0),
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 15),
                    child: CustomText(
                      text: "Sohbetler",
                      alignment: Alignment.centerLeft,
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MontserratBold",
                      color: appColorBlack,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40)),
                        ),
                        child: friendListToMessage(userId)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget friendListToMessage(String userData) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chatList")
          .doc(userData)
          .collection(userData)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          chatList = snapshot.data.docs;
          return Container(
            width: MediaQuery.of(context).size.width,
            child: snapshot.data.docs.length > 0
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      return chatList[index]['chatType'] == "group"
                          ? buildGroupItem(chatList, index)
                          : buildItem(chatList, index);
                    },
                  )
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 4,
                              bottom: 15),
                          child: CustomText(
                            text: "Sohbet Listen Boş",
                            alignment: Alignment.center,
                            fontSize: SizeConfig.blockSizeHorizontal * 5,
                            fontWeight: FontWeight.bold,
                            fontFamily: "MontserratBold",
                            color: appColorBlack,
                          ),
                        ),
                        Image.asset(
                          "assets/images/noimage.jpeg",
                          width: 200,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Sohbet listende kimse yok mesajlaşman için shuffle listesine göz at",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  Widget buildItem(List<DocumentSnapshot> chatList, int index) {
    return chatList[index].id == null
        ? Container()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(chatList[index].id)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.hasData) {
                return controller.text == ""
                    ? Column(
                        children: <Widget>[
                          new Divider(
                            height: 10.0,
                          ),
                          Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Row(
                              children: [
                                selectAll == true
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: selectPeerId
                                                .contains(chatList[index].id)
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.remove(
                                                        chatList[index].id);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: appColorBlue,
                                                ))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.add(
                                                        chatList[index].id);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: appColorGrey,
                                                )),
                                      )
                                    : Container(),
                                Expanded(
                                  child: new ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => Chat(
                                                      peerName: userSnapshot
                                                          .data["nick"],
                                                      peerID:
                                                          chatList[index].id,
                                                      archive: chatList[index]
                                                                  ['archive'] !=
                                                              null
                                                          ? chatList[index]
                                                              ['archive']
                                                          : false,
                                                      pin: chatList[index]
                                                                      ['pin'] !=
                                                                  null &&
                                                              chatList[index][
                                                                          'pin']
                                                                      .length >
                                                                  0
                                                          ? '2549518301000'
                                                          : '',
                                                      mute: chatList[index]
                                                                  ['mute'] !=
                                                              null
                                                          ? chatList[index]
                                                              ['mute']
                                                          : false,
                                                      chatListTime:
                                                          chatList[index]
                                                              ['timestamp'],
                                                      currentUserId: userId,
                                                    )));
                                      },
                                      onLongPress: () {
                                        // getIds(chatList[index].id);

                                        _settingModalBottomSheetNormal(
                                          context,
                                          userId,
                                          chatList[index].id,
                                          chatList[index]['archive'] != null
                                              ? chatList[index]['archive']
                                              : false,
                                          chatList[index]['timestamp'],
                                          chatList[index]['pin'],
                                          chatList[index]['mute'] != null
                                              ? chatList[index]['mute']
                                              : false,
                                          userSnapshot.data["nick"],
                                        );
                                      },
                                      leading: new Stack(
                                        children: <Widget>[
                                          InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context,
                                                  userSnapshot.data["nick"],
                                                  userSnapshot.data["photo"],
                                                  chatList[index].id,
                                                );
                                              },
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: DashedCircle(
                                                      gapSize: 20,
                                                      dashes: 20,
                                                      color: getRandomColor(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.75),
                                                        child: CircleAvatar(
                                                          //radius: 60,
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          backgroundImage:
                                                              new NetworkImage(
                                                                  userSnapshot
                                                                          .data[
                                                                      "photo"]),
                                                        ),
                                                      ),
                                                    ),
                                                  ))),
                                        ],
                                      ),
                                      title: Text(
                                        userSnapshot.data["nick"] ?? "",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appColorBlack),
                                      ),
                                      subtitle: userSnapshot.data["status"] ==
                                                  "typing" &&
                                              userSnapshot.data["inChat"] ==
                                                  userID
                                          ? CustomText(
                                              text: 'typing..',
                                              alignment: Alignment.centerLeft,
                                              fontSize: 13,
                                              color: appColorBlue,
                                            )
                                          : msgTypeWidget(
                                              chatList[index]['type'],
                                              chatList[index]['content'])),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: new Text(
                                          chatList[index]['timestamp'] == null
                                              ? ""
                                              : format(
                                                  chatList[index]['timestamp']
                                                      .toDate(),
                                                  locale: 'en_short'),
                                          style: new TextStyle(
                                              color: int.parse(chatList[index]
                                                          ['badge']) >
                                                      0
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          int.parse(chatList[index]['badge']) >
                                                  0
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue,
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  width: 20,
                                                  child: Text(
                                                    chatList[index]['badge'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 12),
                                                  ),
                                                )
                                              : Container(child: Text("")),
                                          chatList[index]['pin'] != null &&
                                                  chatList[index]['pin']
                                                          .toString()
                                                          .length >
                                                      0
                                              ? Icon(Icons.push_pin,
                                                  color: Colors.grey, size: 16)
                                              : Container(),
                                          chatList[index]['mute'] == true
                                              ? Icon(Icons.volume_off,
                                                  color: Colors.grey, size: 17)
                                              : Container()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'More',
                                color: Colors.grey[400],
                                foregroundColor: Colors.black,
                                icon: Icons.more_horiz,
                                onTap: () {
                                  _settingModalBottomSheetNormal(
                                    context,
                                    userId,
                                    chatList[index].id,
                                    chatList[index]['archive'] != null
                                        ? chatList[index]['archive']
                                        : false,
                                    chatList[index]['timestamp'],
                                    chatList[index]['pin'] != null
                                        ? chatList[index]['pin']
                                        : '',
                                    chatList[index]['mute'] != null
                                        ? chatList[index]['mute']
                                        : false,
                                    userSnapshot.data["nick"],
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : !userSnapshot.data["nick"]
                            .toString()
                            .toLowerCase()
                            .contains(controller.text.toLowerCase().trim())
                        ? Container()
                        : Column(
                            children: <Widget>[
                              new Divider(
                                height: 10.0,
                              ),
                              Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                child: Row(
                                  children: [
                                    selectAll == true
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: selectPeerId.contains(
                                                    chatList[index].id)
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectPeerId.remove(
                                                            chatList[index].id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: appColorBlue,
                                                    ))
                                                : InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectPeerId.add(
                                                            chatList[index].id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      color: appColorGrey,
                                                    )),
                                          )
                                        : Container(),
                                    Expanded(
                                      child: new ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) => Chat(
                                                          peerName: userSnapshot
                                                              .data["nick"],
                                                          peerID:
                                                              chatList[index]
                                                                  .id,
                                                          archive: chatList[
                                                                          index]
                                                                      [
                                                                      'archive'] !=
                                                                  null
                                                              ? chatList[index]
                                                                  ['archive']
                                                              : false,
                                                          pin: chatList[index][
                                                                          'pin'] !=
                                                                      null &&
                                                                  chatList[index]
                                                                              [
                                                                              'pin']
                                                                          .length >
                                                                      0
                                                              ? '2549518301000'
                                                              : '',
                                                          mute: chatList[index][
                                                                      'mute'] !=
                                                                  null
                                                              ? chatList[index]
                                                                  ['mute']
                                                              : false,
                                                          chatListTime:
                                                              chatList[index]
                                                                  ['timestamp'],
                                                          currentUserId: userId,
                                                        )));
                                          },
                                          onLongPress: () {
                                            // getIds(chatList[index].id);

                                            _settingModalBottomSheetNormal(
                                              context,
                                              userId,
                                              chatList[index].id,
                                              chatList[index]['archive'] != null
                                                  ? chatList[index]['archive']
                                                  : false,
                                              chatList[index]['timestamp'],
                                              chatList[index]['pin'],
                                              chatList[index]['mute'] != null
                                                  ? chatList[index]['mute']
                                                  : false,
                                              userSnapshot.data["nick"],
                                            );
                                          },
                                          leading: new Stack(
                                            children: <Widget>[
                                              InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context,
                                                      userSnapshot.data["nick"],
                                                      userSnapshot
                                                          .data["photo"],
                                                      chatList[index].id,
                                                    );
                                                  },
                                                  child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        child: DashedCircle(
                                                          gapSize: 20,
                                                          dashes: 20,
                                                          color:
                                                              getRandomColor(),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(0.75),
                                                            child: CircleAvatar(
                                                              //radius: 60,
                                                              foregroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              backgroundImage:
                                                                  new NetworkImage(
                                                                      userSnapshot
                                                                              .data[
                                                                          "photo"]),
                                                            ),
                                                          ),
                                                        ),
                                                      ))),
                                            ],
                                          ),
                                          title: Text(
                                            userSnapshot.data["nick"] ?? "",
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: appColorBlack),
                                          ),
                                          subtitle: userSnapshot
                                                          .data["status"] ==
                                                      "typing" &&
                                                  userSnapshot.data["inChat"] ==
                                                      userID
                                              ? CustomText(
                                                  text: 'typing..',
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  fontSize: 13,
                                                  color: appColorBlue,
                                                )
                                              : msgTypeWidget(
                                                  chatList[index]['type'],
                                                  chatList[index]['content'])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: new Text(
                                              chatList[index]['timestamp'] ==
                                                      null
                                                  ? ""
                                                  : format(
                                                      chatList[index]
                                                              ['timestamp']
                                                          .toDate(),
                                                      locale: 'en_short'),
                                              style: new TextStyle(
                                                  color: int.parse(
                                                              chatList[index]
                                                                  ['badge']) >
                                                          0
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Container(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              int.parse(chatList[index]
                                                          ['badge']) >
                                                      0
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.blue,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      height: 20,
                                                      width: 20,
                                                      child: Text(
                                                        chatList[index]
                                                            ['badge'],
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 12),
                                                      ),
                                                    )
                                                  : Container(child: Text("")),
                                              chatList[index]['pin'] != null &&
                                                      chatList[index]['pin']
                                                              .toString()
                                                              .length >
                                                          0
                                                  ? Icon(Icons.push_pin,
                                                      color: Colors.grey,
                                                      size: 16)
                                                  : Container(),
                                              chatList[index]['mute'] == true
                                                  ? Icon(Icons.volume_off,
                                                      color: Colors.grey,
                                                      size: 17)
                                                  : Container()
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: 'More',
                                    color: Colors.grey[400],
                                    foregroundColor: Colors.black,
                                    icon: Icons.more_horiz,
                                    onTap: () {
                                      _settingModalBottomSheetNormal(
                                        context,
                                        userId,
                                        chatList[index].id,
                                        chatList[index]['archive'] != null
                                            ? chatList[index]['archive']
                                            : false,
                                        chatList[index]['timestamp'],
                                        chatList[index]['pin'] != null
                                            ? chatList[index]['pin']
                                            : '',
                                        chatList[index]['mute'] != null
                                            ? chatList[index]['mute']
                                            : false,
                                        userSnapshot.data["nick"],
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          );
              }
              return Container();
            },
          );
  }

  getRandomColor() {
    return Color.fromRGBO(math.Random().nextInt(200),
        math.Random().nextInt(200), math.Random().nextInt(200), 1);
  }

  Widget buildGroupItem(List<DocumentSnapshot> chatList, int index) {
    return chatList[index].id == null
        ? Container()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groop")
                .doc(chatList[index].id)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                return controller.text == ""
                    ? Column(
                        children: <Widget>[
                          new Divider(
                            height: 10.0,
                          ),
                          Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Row(
                              children: [
                                selectAll == true
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: selectPeerId
                                                .contains(chatList[index].id)
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.remove(
                                                        chatList[index].id);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: appColorBlue,
                                                ))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectPeerId.add(
                                                        chatList[index].id);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: appColorGrey,
                                                )),
                                      )
                                    : Container(),
                                Expanded(
                                  child: new ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => GroupChat(
                                                      joined: snapshot
                                                          .data['joins']
                                                          .contains(userId),
                                                      joins: snapshot
                                                          .data['joins'],
                                                      currentuser: userId,
                                                      currentusername:
                                                          globalName,
                                                      currentuserimage:
                                                          globalImage,
                                                      peerID:
                                                          chatList[index].id,
                                                      peerUrl: snapshot
                                                          .data['groupImage'],
                                                      peerName: snapshot
                                                          .data['groupName'],
                                                      archive: false,
                                                      mute: false,
                                                      muteds: snapshot
                                                          .data['muteds'],
                                                      pins:
                                                          snapshot.data['pins'],
                                                    )));
                                      },
                                      onLongPress: () {
                                        //getIds(chatList[index].id);

                                        _settingModalBottomSheetGroop(
                                          context,
                                          userId,
                                          chatList[index].id,
                                          false,
                                          chatList[index]['timestamp'],
                                          snapshot.data["pins"].contains(userId)
                                              ? true
                                              : false,
                                          snapshot.data["muteds"]
                                                  .contains(userId)
                                              ? true
                                              : false,
                                          "",
                                        );
                                      },
                                      leading: new Stack(
                                        children: <Widget>[
                                          InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context,
                                                  chatList[index]['name'],
                                                  chatList[index]
                                                      ['profileImage'],
                                                  chatList[index].id,
                                                );
                                              },
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: snapshot.data[
                                                                  "groupImage"]
                                                              .toString()
                                                              .length >
                                                          3
                                                      ? Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: DashedCircle(
                                                            gapSize: 20,
                                                            dashes: 20,
                                                            color:
                                                                getRandomColor(),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      0.75),
                                                              child:
                                                                  CircleAvatar(
                                                                //radius: 60,
                                                                foregroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                backgroundImage:
                                                                    new NetworkImage(
                                                                        snapshot
                                                                            .data['groupImage']),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color:
                                                                      Colors.grey[
                                                                          400],
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child: DashedCircle(
                                                            gapSize: 20,
                                                            dashes: 20,
                                                            color:
                                                                getRandomColor(),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      0.75),
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/${snapshot.data['groupImage']}.png",
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          )))),
                                        ],
                                      ),
                                      title: new Text(
                                        snapshot.data['groupName'],
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          msgTypeWidget(snapshot.data['type'],
                                              snapshot.data['content']),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            height: 47,
                                            padding:
                                                const EdgeInsets.only(left: 0),
                                            child: ListView.builder(
                                                itemCount: snapshot
                                                    .data["joins"].length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.all(3),
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder:
                                                    (context, int index) {
                                                  return GroopLength(
                                                    type: null,
                                                    userId: snapshot
                                                        .data["joins"][index],
                                                  );
                                                }),
                                          )
                                        ],
                                      )),
                                ),
                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("groop")
                                        .doc(chatList[index].id)
                                        .collection(chatList[index].id)
                                        .where("seen", arrayContains: userId)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot>
                                            snapshotBadge) {
                                      if (snapshotBadge.hasData) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3),
                                                child: new Text(
                                                  chatList[index]
                                                              ['timestamp'] ==
                                                          null
                                                      ? ""
                                                      : format(
                                                          chatList[index]
                                                                  ['timestamp']
                                                              .toDate(),
                                                          locale: 'en_short'),
                                                  style: new TextStyle(
                                                      color: snapshotBadge.data
                                                                  .docs.length >
                                                              0
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              Container(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  snapshotBadge.data.docs
                                                              .length >
                                                          0
                                                      ? Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.blue,
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          height: 20,
                                                          width: 20,
                                                          child: Text(
                                                            snapshotBadge.data
                                                                .docs.length
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                fontSize: 12),
                                                          ),
                                                        )
                                                      : Container(
                                                          child: Text("")),
                                                  snapshot.data['pins']
                                                          .contains(userId)
                                                      ? Icon(Icons.push_pin,
                                                          color: Colors.grey,
                                                          size: 16)
                                                      : Container(),
                                                  snapshot.data['muteds']
                                                          .contains(userId)
                                                      ? Icon(Icons.volume_off,
                                                          color: Colors.grey,
                                                          size: 17)
                                                      : Container()
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    })
                              ],
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'More',
                                color: Colors.grey[400],
                                foregroundColor: Colors.black,
                                icon: Icons.more_horiz,
                                onTap: () {
                                  _settingModalBottomSheetGroop(
                                    context,
                                    userId,
                                    chatList[index].id,
                                    chatList[index]['archive'] != null
                                        ? chatList[index]['archive']
                                        : false,
                                    chatList[index]['timestamp'],
                                    snapshot.data['pins'].contains(userId)
                                        ? true
                                        : false,
                                    snapshot.data['muteds'].contains(userId)
                                        ? true
                                        : false,
                                    "",
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : !snapshot.data["groupName"]
                            .toString()
                            .toLowerCase()
                            .contains(controller.text.toLowerCase().trim())
                        ? Container()
                        : Column(
                            children: <Widget>[
                              new Divider(
                                height: 10.0,
                              ),
                              Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                child: Row(
                                  children: [
                                    selectAll == true
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: selectPeerId.contains(
                                                    chatList[index].id)
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectPeerId.remove(
                                                            chatList[index].id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: appColorBlue,
                                                    ))
                                                : InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectPeerId.add(
                                                            chatList[index].id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      color: appColorGrey,
                                                    )),
                                          )
                                        : Container(),
                                    Expanded(
                                      child: new ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        GroupChat(
                                                          joined: snapshot
                                                              .data['joins']
                                                              .contains(userId),
                                                          joins: snapshot
                                                              .data['joins'],
                                                          currentuser: userId,
                                                          currentusername:
                                                              globalName,
                                                          currentuserimage:
                                                              globalImage,
                                                          peerID:
                                                              chatList[index]
                                                                  .id,
                                                          peerUrl:
                                                              snapshot.data[
                                                                  'groupImage'],
                                                          peerName:
                                                              snapshot.data[
                                                                  'groupName'],
                                                          archive: false,
                                                          mute: false,
                                                          muteds: snapshot
                                                              .data['muteds'],
                                                          pins: snapshot
                                                              .data['pins'],
                                                        )));
                                          },
                                          onLongPress: () {
                                            //getIds(chatList[index].id);

                                            _settingModalBottomSheetGroop(
                                              context,
                                              userId,
                                              chatList[index].id,
                                              false,
                                              chatList[index]['timestamp'],
                                              snapshot.data["pins"]
                                                      .contains(userId)
                                                  ? true
                                                  : false,
                                              snapshot.data["muteds"]
                                                      .contains(userId)
                                                  ? true
                                                  : false,
                                              "",
                                            );
                                          },
                                          leading: new Stack(
                                            children: <Widget>[
                                              InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context,
                                                      chatList[index]['name'],
                                                      chatList[index]
                                                          ['profileImage'],
                                                      chatList[index].id,
                                                    );
                                                  },
                                                  child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      child: snapshot.data[
                                                                      "groupImage"]
                                                                  .toString()
                                                                  .length >
                                                              3
                                                          ? Container(
                                                              height: 50,
                                                              width: 50,
                                                              child:
                                                                  DashedCircle(
                                                                gapSize: 20,
                                                                dashes: 20,
                                                                color:
                                                                    getRandomColor(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.75),
                                                                  child:
                                                                      CircleAvatar(
                                                                    //radius: 60,
                                                                    foregroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    backgroundImage:
                                                                        new NetworkImage(
                                                                            snapshot.data['groupImage']),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 50,
                                                              width: 50,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      400],
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child:
                                                                  DashedCircle(
                                                                gapSize: 20,
                                                                dashes: 20,
                                                                color:
                                                                    getRandomColor(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.75),
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/images/${snapshot.data['groupImage']}.png",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              )))),
                                            ],
                                          ),
                                          title: new Text(
                                            snapshot.data['groupName'],
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              msgTypeWidget(
                                                  snapshot.data['type'],
                                                  snapshot.data['content']),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                height: 30,
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: ListView.builder(
                                                    itemCount: snapshot
                                                        .data["joins"].length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      return StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(snapshot
                                                                          .data[
                                                                      "joins"]
                                                                  [index])
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Container(
                                                                height: 30,
                                                                width: 30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                                child:
                                                                    DashedCircle(
                                                                  gapSize: 20,
                                                                  dashes: 20,
                                                                  color:
                                                                      getRandomColor(),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            0.8),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          20,
                                                                      foregroundColor:
                                                                          Theme.of(context)
                                                                              .primaryColor,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey,
                                                                      backgroundImage:
                                                                          new NetworkImage(
                                                                        snapshot
                                                                            .data["photo"],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                              height: 30,
                                                              width: 30,
                                                              child:
                                                                  DashedCircle(
                                                                gapSize: 20,
                                                                dashes: 20,
                                                                color:
                                                                    getRandomColor(),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.75),
                                                                  child:
                                                                      CircleAvatar(
                                                                    //radius: 60,
                                                                    foregroundColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    }),
                                              )
                                            ],
                                          )),
                                    ),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("groop")
                                            .doc(chatList[index].id)
                                            .collection(chatList[index].id)
                                            .where("seen",
                                                arrayContains: userId)
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshotBadge) {
                                          if (snapshotBadge.hasData) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3),
                                                    child: new Text(
                                                      chatList[index][
                                                                  'timestamp'] ==
                                                              null
                                                          ? ""
                                                          : format(
                                                              chatList[index][
                                                                      'timestamp']
                                                                  .toDate(),
                                                              locale:
                                                                  'en_short'),
                                                      style: new TextStyle(
                                                          color: snapshotBadge
                                                                      .data
                                                                      .docs
                                                                      .length >
                                                                  0
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      snapshotBadge.data.docs
                                                                  .length >
                                                              0
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 20,
                                                              width: 20,
                                                              child: Text(
                                                                snapshotBadge
                                                                    .data
                                                                    .docs
                                                                    .length
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text("")),
                                                      snapshot.data['pins']
                                                              .contains(userId)
                                                          ? Icon(Icons.push_pin,
                                                              color:
                                                                  Colors.grey,
                                                              size: 16)
                                                          : Container(),
                                                      snapshot.data['muteds']
                                                              .contains(userId)
                                                          ? Icon(
                                                              Icons.volume_off,
                                                              color:
                                                                  Colors.grey,
                                                              size: 17)
                                                          : Container()
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return Container();
                                        })
                                  ],
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: 'More',
                                    color: Colors.grey[400],
                                    foregroundColor: Colors.black,
                                    icon: Icons.more_horiz,
                                    onTap: () {
                                      _settingModalBottomSheetGroop(
                                        context,
                                        userId,
                                        chatList[index].id,
                                        chatList[index]['archive'] != null
                                            ? chatList[index]['archive']
                                            : false,
                                        chatList[index]['timestamp'],
                                        snapshot.data['pins'].contains(userId)
                                            ? true
                                            : false,
                                        snapshot.data['muteds'].contains(userId)
                                            ? true
                                            : false,
                                        "",
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          );
              }
              return Container();
            });
  }

  Widget msgTypeWidget(int type, String content) {
    return new Container(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type == 1
              ? Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 17,
                    ),
                    Text(
                      "  Photo",
                      maxLines: 2,
                      style: new TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                )
              : type == 4
                  ? Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 17,
                        ),
                        Text(
                          "  Video",
                          maxLines: 2,
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  : type == 5
                      ? Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.grey,
                              size: 17,
                            ),
                            Text(
                              "  File",
                              maxLines: 2,
                              style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      : type == 6
                          ? Row(
                              children: [
                                Icon(
                                  Icons.audiotrack,
                                  color: Colors.grey,
                                  size: 17,
                                ),
                                Text(
                                  "  Audio",
                                  maxLines: 2,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            )
                          : !content.contains(":")
                              ? Text(
                                  content,
                                  maxLines: 2,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                )
                              : Text(
                                  content.split(":")[0] +
                                      ":" +
                                      content.split(":")[1],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
        ],
      ),
    );
  }

  void _settingModalBottomSheetNormal(
    context,
    userId,
    peerId,
    arch,
    timestamp,
    pin,
    mute,
    peerName,
  ) {
    print(peerId);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                pin.toString() != ""
                    ? ListTile(
                        title: Center(child: new Text('Unpin')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("chatList")
                              .doc(userId)
                              .collection(userId)
                              .doc(peerId)
                              .update({'pin': '', 'timestamp': pin});
                        })
                    : ListTile(
                        title: Center(child: new Text('Pin')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("chatList")
                              .doc(userId)
                              .collection(userId)
                              .doc(peerId)
                              .update({
                            'pin': timestamp,
                            'timestamp': DateTime.parse("2050-02-27")
                          });
                        }),
                mute == true
                    ? ListTile(
                        title: Center(child: new Text('Unmute')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .update({
                            'muteds': FieldValue.arrayRemove([userId]),
                          });
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Mute')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .update({
                            'muteds': FieldValue.arrayUnion([userId]),
                          });
                        },
                      ),
                ListTile(
                  title: Center(
                    child: new Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    FirebaseFirestore.instance
                        .collection("chatList")
                        .doc(userId)
                        .collection(userId)
                        .doc(peerId)
                        .delete();
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.grey[300],
                      child: Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _settingModalBottomSheetGroop(
    context,
    userId,
    peerId,
    arch,
    timestamp,
    pin,
    mute,
    peerName,
  ) {
    print(peerId);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                pin
                    ? ListTile(
                        title: Center(child: new Text('Unpin')),
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .collection(peerId)
                              .orderBy("timestamp", descending: true)
                              .get()
                              .then((value) async {
                            await FirebaseFirestore.instance
                                .collection("chatList")
                                .doc(userId)
                                .collection(userId)
                                .doc(peerId)
                                .update(
                                    {"timestamp": value.docs[0]["timestamp"]});
                            await FirebaseFirestore.instance
                                .collection("groop")
                                .doc(peerId)
                                .update({
                              'pins': FieldValue.arrayRemove([userId]),
                            });
                            Navigator.pop(context);
                          });
                        })
                    : ListTile(
                        title: Center(child: new Text('Pin')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("chatList")
                              .doc(userId)
                              .collection(userId)
                              .doc(peerId)
                              .update(
                                  {"timestamp": DateTime.parse("2050-02-27")});
                          FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .update({
                            'pins': FieldValue.arrayUnion([userId]),
                          });
                        }),
                mute == true
                    ? ListTile(
                        title: Center(child: new Text('Unmute')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .update({
                            'muteds': FieldValue.arrayRemove([userId]),
                          });
                        },
                      )
                    : ListTile(
                        title: Center(child: new Text('Mute')),
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection("groop")
                              .doc(peerId)
                              .update({
                            'muteds': FieldValue.arrayUnion([userId]),
                          });
                        },
                      ),
                ListTile(
                  title: Center(
                    child: new Text(
                      'Exit Group',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    print(userId);
                    await FirebaseFirestore.instance
                        .collection("groop")
                        .doc(peerId)
                        .update({
                      "joins": FieldValue.arrayRemove([userId])
                    });
                    FirebaseFirestore.instance
                        .collection("chatList")
                        .doc(userId)
                        .collection(userId)
                        .doc(peerId)
                        .delete();
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.grey[300],
                      child: Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showDialog(BuildContext context, name, image, id) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Barrier",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: SizeConfig.safeBlockVertical * 100,
            width: SizeConfig.screenWidth,
            child: Column(
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        )),
                    height: SizeConfig.safeBlockVertical * 30,
                    width: SizeConfig.screenWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0)),
                      child: image.length > 0
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 50,
                            ),
                    )),
                Material(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0)),
                    ),
                    height: SizeConfig.blockSizeVertical * 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 8),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeVertical * 2.5,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => Chat(
                                            peerName: name,
                                            peerID: id,
                                            currentUserId: userId)));
                              },
                              elevation: 1,
                              fillColor: Colors.white,
                              child: Image.asset(
                                "assets/images/chat.png",
                                height: 27,
                                color: appColorBlue,
                              ),
                              shape: CircleBorder(),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ContactInfo(
                                            id: id,
                                            currentUser: userId,
                                          )),
                                );
                              },
                              elevation: 1,
                              fillColor: Colors.white,
                              child: Icon(
                                Icons.info,
                                size: 25.0,
                                color: appColorBlue,
                              ),
                              shape: CircleBorder(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            margin: EdgeInsets.only(bottom: 45, left: 18, right: 18, top: 200),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  Widget friendName(AsyncSnapshot friendListSnapshot, int index) {
    return Container(
      width: 200,
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(children: <TextSpan>[
          TextSpan(
            text:
                "${friendListSnapshot.data["firstname"]} ${friendListSnapshot.data["lastname"]}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          )
        ]),
      ),
    );
  }

  Widget messageButton(AsyncSnapshot friendListSnapshot, int index) {
    // ignore: deprecated_member_use
    return RaisedButton(
      color: Colors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Text(
        "Message",
        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
      ),
      onPressed: () {},
    );
  }

  // getOnlineStatus() {
  //   database
  //       .reference()
  //       .child('user')
  //       .orderByChild("status")
  //       .equalTo("Online")
  //       .onValue
  //       .listen((event) {
  //     var snapshot = event.snapshot;
  //     snapshot.value.forEach((key, values) {
  //       setState(() {
  //         array.add(values["userId"]);
  //         friendListToMessage(userId);
  //       });
  //     });
  //   });
  // }

  getUser() async {
    database.reference().child('user').child(userId).once().then((peerData) {
      setState(() {
        userID = userId;
        globalName = peerData.value['name'];
        globalImage = peerData.value['img'];
        mobNo = peerData.value['mobile'];
        fullMob = peerData.value['countryCode'] + peerData.value['mobile'];
      });
    });

    setState(() {});
  }

  onSearchTextChanged(String text) async {
    setState(() {});
  }
}

List<DocumentSnapshot> _searchResult = [];

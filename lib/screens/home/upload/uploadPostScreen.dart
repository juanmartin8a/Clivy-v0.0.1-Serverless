import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:tflite/tflite.dart';
import 'package:untitled_startup/models/user.dart';
import 'package:untitled_startup/screens/home/classes/tabbarIndicator.dart';
import 'package:untitled_startup/screens/home/upload/postSettings.dart';
import 'package:untitled_startup/screens/home/upload/predictionOverlay.dart';
import 'package:untitled_startup/screens/home/upload/videogames.dart';
import 'package:untitled_startup/services/cacheClass/cacheManager.dart';
import 'package:untitled_startup/services/database.dart';

class UploadPostScreen extends StatefulWidget {
  final Map<String, dynamic> myInfo;
  final double statusBar;
  UploadPostScreen({this.statusBar, this.myInfo});
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> with SingleTickerProviderStateMixin {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://untitledstartup-3e326.appspot.com');
  UploadTask _uploadTask;
  TaskSnapshot _taskSnapshot;
  bool isUploading = false;

  ScrollController _galleryScrollController = ScrollController();

  ScrollController _customScrollViewController = ScrollController();
  TabController _tabController;
  List<AssetEntity> assets = [];
  int currentPageAsset = 0;
  int lastPage;
  Map<dynamic, dynamic> assetWidgets = {};
  File theFile;
  bool isImage;
  double imageWidth;
  double imageHeight;
  double maxImageHeight;
  bool isLoading = false;

  FocusNode focusNode = FocusNode();

  RichTextController _captionController;
  String theCaption = '';

  bool commentsEnabled = true;
  var theCategories;
  String videogame = '';

  PageController _pageController = PageController();
  int currentPage = 0;

  List outputs;

  double paddingTopPorcentage = 0;

  Map<String, dynamic> videogameCategories = {
    'League of Legends': ['moba', 'action'],
    'Grand Theft Auto V': ['driving', 'adventure', 'fps', 'shooter', 'sports'],
    'Fortnite': ['survival', 'shooter', 'action', 'openWorld'],
    'Rust': ['adventure', 'shooter', 'fps', 'rpg'],
    'Minecraft': ['adventure', 'simulation', 'arcade', 'mmo', 'survival'],
    'COD: Warzone': ['fps', 'shooter'],
    'VALORANT': ['shooter', 'fps'],
    'CSGO': ['fps', 'shooter', 'action'],
    'Apex Legends': ['fps', 'shooter', 'action'],
    'Rainbow Six Siege': ['fps', 'shooter', 'action'],
    'FIFA': ['sports'],
    'Dota 2': ['moba', 'action'],
    'World of Warcraft': ['rpg', 'adventure', 'mmo', 'action'],
    'Among Us': ['strategy', 'survival'],
    'Rocket League': ['driving', 'action', 'sports'],
    'COD: Cold War': ['fps', 'shooter', 'action'],
    'Overwatch': ['fps', 'shooter', 'strategy', 'action'],
    'COD: Modern Warfare': ['fps', 'shooter', 'action'],
    'Star Wars Battlefront II': ['fps', 'shooter', 'action', 'adventure'],
    'Cyberpunk 2077': ['rpg', 'openWorld'],
    'NBA 2K': ['sports'],
    'Madden NFL': ['sports'],
    'Other': ['fps', 'action', 'shooter', 'adventure', 'arcade', 'simulation', 'mmo',
    'strategy', 'moba', 'driving', 'adventure', 'sports', 'survival', 'openWorld', 'rpg'],
    'None': ['none'],
  };

  Map<String, dynamic> videogameImages = {
    'Among Us': 'assets/images/amongUs.jpg',
    'Apex Legends': 'assets/images/apexLegends.jpg',
    'Star Wars Battlefront II': 'assets/images/battlefront2.jpg',
    'COD: Cold War': 'assets/images/coldWar.jpg',
    'COD: Modern Warfare': 'assets/images/modernWarfare.jpg',
    'CSGO': 'assets/images/CounterStrike.jpg',
    'Cyberpunk 2077': 'assets/images/cyberpunk2077.jpg',
    'Dota 2': 'assets/images/Dota2.jpg',
    'FIFA': 'assets/images/FIFA.jpg',
    'Fortnite': 'assets/images/Fortnite.jpg',
    'Grand Theft Auto V': 'assets/images/GTA.jpg',
    'League of Legends': 'assets/images/LOL.jpg',
    'Madden NFL': 'assets/images/Madden.jpg',
    'Minecraft': 'assets/images/Minecraft.jpg',
    'NBA 2K': 'assets/images/NBA.jpg',
    'Overwatch': 'assets/images/Overwatch.jpg',
    'Rainbow Six Siege': 'assets/images/Rainbows.jpg',
    'Rocket League': 'assets/images/RocketL.jpg',
    'Rust': 'assets/images/Rust.jpg',
    'VALORANT': 'assets/images/VALORANT.jpg',
    'COD: Warzone': 'assets/images/Warzone.jpg',
    'World of Warcraft': 'assets/images/WoW.jpg',
    'None': 'none',
    'Other': 'none'
  };
  

  uploadImage(BuildContext context) async {
    final user = Provider.of<CustomUser>(context, listen: false);
    if (theFile.path != null) {
      setState(() => isUploading = true);
      print(isUploading);
      DocumentReference docRef = FirebaseFirestore.instance.collection('posts').doc();
      String filePath = 'posts/${docRef.id}.jpg';
      _uploadTask = _storage.ref().child(filePath).putFile(File(theFile.path));
      _taskSnapshot = await _uploadTask;
      final String downloadUrl = await _taskSnapshot.ref.getDownloadURL();

      List theHashtags = [];
      List theSplittedList = theCaption.split(' ');
      for (int i = 0; i < theSplittedList.length; i++) {
        if (theSplittedList[i].startsWith('#')) {
          await checkIfHashtagExistsAndCreateHashtag(theSplittedList[i].toLowerCase()).then((val) {
            theHashtags.add(val);
          });
        }
      }

      Map<String, dynamic> theUploadMap = {
        'postedBy': user.uid,
        'postImg': downloadUrl,
        'id': docRef.id,
        'commentsEnabled': commentsEnabled,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeTS': DateTime.now(),
        'prediction': videogame,
        //'confidence': outputs[0]['confidence'],
        'postDims': [imageWidth, maxImageHeight >= imageHeight ? imageHeight : maxImageHeight],
        'caption': theCaption,
        'hashtags': theHashtags,
        'category': theCategories,
        'type': isImage == true ? 'image' : 'video',
        'likes': 0,
        'comments': 0
      };
      DatabaseService().uploadPost(theUploadMap, docRef);
      //if (mounted) {
        setState(() {
          isUploading = false;
          theFile = null;
          _captionController.text = '';
          theCaption = '';
        });
      //}
    }
  }

  checkIfHashtagExistsAndCreateHashtag(hashtagName) async {
    QuerySnapshot theHashtag = await FirebaseFirestore.instance
    .collection('hashtags').where('hashtag', isEqualTo: hashtagName).limit(1).get();
    //.doc(hashtagId).get();
    if (theHashtag.docs.isNotEmpty) {
      return theHashtag.docs[0].data()['hashtag'];
    } else if (theHashtag.docs.isEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('hashtags').doc();
      List<String> splitList = hashtagName.split(" ");
      List<String> indexList = [];
      for (int i = 0; i < splitList.length; i++) {
        for (int y = 1; y < splitList[i].length + 1; y++) {
          indexList.add(splitList[i].substring(0, y).toLowerCase());
        }
      }
      Map<String, dynamic> hashtagMap = {
        'id': docRef.id,
        'hashtag': hashtagName,
        'hashtagIndex': indexList,
        'posts': 1,
        'views': 1,
        //'posts': ,
        //'views': ,
      };
      await DatabaseService().createHashtag(hashtagMap, docRef);
      return hashtagName;
    }
    //DocumentSnapshot querySnapshot = await theQuery.get();
  }

  scrollToPage() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  askForPermission() async {
    final permitted = await PhotoManager.requestPermission();
    if (!permitted) return;
    getGalleryPictures();
  }

  getGalleryPictures() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
    final recentAlbum = albums.first;
    final albumAssets = await recentAlbum.getAssetListPaged(
      currentPageAsset,
      50,
    );
    for (int i = 0; i < albumAssets.length; i++) {
      assetWidgets[albumAssets[i].file] = FutureBuilder<Uint8List>(
        future: albumAssets[i].thumbData,
        builder: (_, snapshot) {
          final bytes = snapshot.data;
          return bytes != null 
          ? GestureDetector(
            onTap: () {
              selectFile(albumAssets[i].file);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: MemoryImage(bytes),
                  fit: BoxFit.cover
                )
              )
            ),
          )
          : Container(
            child: Text('loading...')
          );
        }
      );
    }
    setState(() {
      assets = albumAssets;
      currentPageAsset++;
    });
  }

  selectFile(Future<File> selectedFile) async {
    if (isLoading == true) {
      return ;
    }
    if (isLoading == false) {
      final theSelectedFile = await selectedFile;
      setState(() {
        isLoading = true;
        theFile = theSelectedFile;
      });
      await getFileType(theFile, context);
      //await getFileDims(theFile);
    }
  }

  getFileType(File theFile, BuildContext context) async {
    final mimeType = lookupMimeType(theFile.path);
    if (mimeType.startsWith('image')) {
      //setState(() {
        isImage = true;
        await getFileDims(theFile);
        await loadCNNImage(theFile, context);
      //});
    } else {
      isImage = false;
      print('video');
    }
  }

  getFileDims(File theFile) async  {
    var decodedImage = await decodeImageFromList(theFile.readAsBytesSync());
    setState(() {
      imageWidth = decodedImage.width.toDouble();
      imageHeight= decodedImage.height.toDouble();
      double maxDifference = imageWidth * 0.10;
      maxImageHeight = imageWidth + maxDifference;
      //isLoading = false;
    });
  }

  goToSettings() {
    _tabController.animateTo(2, duration: Duration(milliseconds: 300), curve: Curves.ease);
    Timer.periodic(
      Duration(milliseconds: 300), 
      (timer) {
        _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.ease);
        timer.cancel();
      }
    );
  }

  Map theHashtagsMap = {};
  String theWord = '';
  List theWords = [];

  void refresh(String theCaption) {
    setState(() {
      theCaption = theCaption;
      //theComment = value;
      theWords = theCaption.split(' ');
      if (theWords.length > 0) {
        if (theWords[theWords.length - 1].startsWith('#')) {
          theWord = theWords[theWords.length - 1];
        } else {
          theWord = '';
        }
      } else {
        theWord = '';
      }
      if (theWord.length == 0) {
        theHashtagsMap = {};
      }
      if (theWord.length > 0) {
        if (theWords[theWords.length - 1].startsWith('@')) {
        } else if (theWords[theWords.length - 1].startsWith('#')) {
          searchForHashtags();
        }
      }
    });
  }

  searchForHashtags() async {
    //String theNewWord = theWord.replaceAll('@', '');
    Query theQuery = FirebaseFirestore.instance.collection('hashtags')
    .where('hashtagIndex', arrayContains: theWord).limit(12);
    QuerySnapshot querySnapshot = await theQuery.get();
    setState(() {
      theHashtagsMap = {};
    });
    if (querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {  
          theHashtagsMap[querySnapshot.docs[i].data()['id']] = querySnapshot.docs[i].data();
        });
      }
    }
    setState(() {});
  }

  void refreshComments(bool newCommentsEnabled) {
    setState(() {
      commentsEnabled = newCommentsEnabled;
    });
    print(commentsEnabled);
  }

  void refreshVideogame(String newVideogame) {
    setState(() {
      videogame = newVideogame;
      theCategories = videogameCategories[newVideogame];
    });
    print(videogame);
    print(theCategories);
  }


  loadCNNModel() async {
    await Tflite.loadModel(
      model: "assets/agmodel.tflite",
      labels: "assets/AGLabels.txt",
      //useGpuDelegate: true
    );
  }


  loadCNNImage(File imageFile, BuildContext context) async {
    var modelOutputs = await Tflite.runModelOnImage(
      path: imageFile.path,
      imageMean: 0,
      imageStd: 255,
      numResults: 4,
      threshold: 0.0,
    );
    setState(() {
      //var predictions = modelOutputs.map((json) => Prediction.fromJson(json)).toList();
      isLoading = false;
      outputs = modelOutputs;
      videogame = outputs[0]['label'];
      theCategories = videogameCategories[videogame];
      //detectedGameNotification(context, outputs[0]['label']);
    });
    showPredictionNotification(context, videogameImages[outputs[0]['label']], outputs[0]['label']);
  }

  showPredictionNotification(BuildContext context, String theImgPath, String theLabel) {
    showOverlayNotification((context) {
      return PredictionOverlay(
        statusBar: widget.statusBar,
        image: theImgPath,
        label: theLabel,
        goToSettings: goToSettings
      );
    }, duration: Duration(seconds: 4));
  }

  void updatePadding(double newPadding) {
    paddingTopPorcentage = newPadding;
    print(paddingTopPorcentage);
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      _customScrollViewController.animateTo(
        _customScrollViewController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease
      );
    } 
    print("Focus: "+focusNode.hasFocus.toString());
  }

  @override
  void initState() {
    super.initState();
    //askForPermission();
    _captionController = RichTextController(
      patternMap: {
        RegExp(r"\B#[a-zA-Z0-9]+\b"):TextStyle(color:Colors.red),
      },
    );
    _tabController = TabController(length: 3, vsync: this);
    getGalleryPictures();
    _galleryScrollController.addListener(() {
      if (_galleryScrollController.position.pixels 
        / _galleryScrollController.position.maxScrollExtent > 0.33) {
        getGalleryPictures();
      }
    });
    loadCNNModel();
    focusNode.addListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(widget.statusBar + 56),
          child: Container(
            margin: EdgeInsets.only(top: widget.statusBar),
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      //color: Colors.red,
                      margin: EdgeInsets.only(left: widget.statusBar / 2),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[800],
                        size: 42
                      ),
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      'New Post',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w800,
                        fontSize: 22
                      )
                    )
                  ),
                ),
              ],
            )
          ),
        ),
        body: GestureDetector(
          onPanDown: (val) {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(    
            color: Colors.grey[50],
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                NestedScrollView(
                  controller: _customScrollViewController,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: AspectRatio(
                          aspectRatio: imageHeight == null || imageWidth == null 
                          ? 16/9
                          : maxImageHeight >= imageHeight
                          ? imageWidth / imageHeight
                          : imageWidth / maxImageHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: theFile != null ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[350],
                                image: DecorationImage(
                                  image: FileImage(theFile),
                                  fit: BoxFit.cover
                                ),
                              ) : BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[350],
                              )
                            )
                          )
                        ),
                      ),
                      // SliverPersistentHeader(
                      //   pinned: true,
                      //   delegate: SliverUploadTabBar(
                      //     tabController: _tabController,
                      //     updatePadding: updatePadding
                      //   )
                      // ),
                    ];
                  },
                  body: Stack(
                    children: [
                      
                      Container(
                        //padding: EdgeInsets.only(top: 45),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Container(
                              //color: Colors.red,
                              //height: 400,
                              child: GridView.builder(
                                padding: EdgeInsets.only(
                                  top: 52,
                                  left: 3,
                                  right: 3,
                                  bottom: 3
                                ),
                                key: new PageStorageKey('theGridView'),
                                controller: _galleryScrollController,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 12/9,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3
                                ),
                                //physics: ClampingScrollPhysics(),
                                //padding: EdgeInsets.all(3),
                                itemCount: assetWidgets.length,
                                itemBuilder: (_, index) {
                                  return assetWidgets.values.toList()[index];
                                }
                              )
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                top: 65,
                                bottom: 20,
                                left: 12,
                                right: 12
                                //vertical: 20, 
                                //horizontal: 12
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    child: CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 10),
                                      fadeOutDuration: Duration(milliseconds: 10),
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[350],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      imageUrl: widget.myInfo['profileImg'],
                                      fit: BoxFit.cover,
                                      cacheManager: CustomCacheManager.instance,
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[350],
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover
                                            )
                                          ),
                                        );
                                      }
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 6, top: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            child: Text(
                                              '${widget.myInfo['name']}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15.2,
                                                fontWeight: FontWeight.w600
                                              )
                                            )
                                          ),
                                          Container(
                                            child: TextField(
                                              focusNode: focusNode,
                                              keyboardType: TextInputType.text,
                                              controller: _captionController,
                                              maxLines: 5,
                                              minLines: 1,
                                              autocorrect: false,
                                              onChanged: (value) {
                                                setState(() {
                                                  theCaption = value;
                                                });
                                                refresh(theCaption);
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLength: 120,
                                              buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                                isDense: true,
                                                border: InputBorder.none,
                                                //counter: SizedBox.shrink(),
                                                //counterText: '',
                                                hintText: 'Add a description...',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 16,
                                                  //height: 2,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          )
                                        ],
                                      )
                                    ),
                                  )
                                ],
                              )
                            ),
                            Container(
                              color: Colors.grey[50],
                              padding: EdgeInsets.only(
                                top: 45,
                                bottom: 20,
                              ),
                              child: PageView(
                                key: new PageStorageKey('thePageView'),
                                physics: currentPage == 0 ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                                controller: _pageController,
                                onPageChanged: (page) {
                                  setState(() {
                                    currentPage = page;
                                  });
                                },
                                children: [
                                  PostSettings(
                                    commentsEnabled: commentsEnabled,
                                    refresh: refreshComments,
                                    videogameCategories: videogameCategories,
                                    videogameImages: videogameImages,
                                    theCategories: theCategories,
                                    videogame: videogame,
                                    videogameRefresh: refreshVideogame,
                                    imageFile: theFile,
                                    scrollToPage: scrollToPage,
                                  ),
                                  VideogameSelection(
                                    videogameCategories: videogameCategories,
                                    videogameImages: videogameImages,
                                    theCategories: theCategories,
                                    videogame: videogame,
                                    videogameRefresh: refreshVideogame,
                                    comesFromSettings: true,
                                    refreshSettings: refreshVideogame,
                                    imageFile: theFile,
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)
                          ),
                          color: Colors.grey[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: TabBar(
                            controller: _tabController,
                            labelPadding: EdgeInsets.symmetric(horizontal: 0),
                            indicator: MD2Indicator(
                              indicatorSize: MD2IndicatorSize.normal,
                              indicatorHeight: 6.0,
                              indicatorColor: Colors.grey[700],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Text(
                                'Photos',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(
                                'Description',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600
                                )
                              )
                            ],
                          )
                        ),
                      ),
                    ],
                  )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      if (theFile != null && isLoading == false && isUploading == false) {
                        uploadImage(context);
                      }
                    },
                    child: theFile != null
                    ? Container(
                      height: 50,
                      width: 200,
                      margin: EdgeInsets.only(
                        bottom: 34 // iphone home bar size
                      ),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(55),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[600].withOpacity(0.2),
                            spreadRadius: 4,
                            blurRadius: 12,
                            offset: Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(
                        child: isUploading == false ? Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.grey[850],
                            fontSize: 20,
                            fontWeight: FontWeight.w800
                          )
                        ) : CupertinoActivityIndicator(radius: 12),
                      )
                    )
                    : Container(),
                  )
                )
              ]
            )
          ),
        )
      )
    );
  }
}

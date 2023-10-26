import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class DatabaseService {
  final String uid;
  final String docId;
  DatabaseService({this.uid, this.docId});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('chatRooms');

  Future uploadUserInfo(userMap) async {
    print('the user map is $userMap');
    return await userCollection.doc(uid).set(userMap);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      //imageUrl: snapshot.data()['imageUrl'],
    );
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  getUserByUsername(String username) async {
    print('userByUsername printed');
    return await userCollection.where('userNameIndex', arrayContains: username).get();
  }

  getUserByUserEmail(String email) async {
    return userCollection
        .where(
          'email',
          isEqualTo: email,
        )
        .get();
  }

  Stream<DocumentSnapshot> getUserByUid() {
    return userCollection.doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getUserByUidFuture() async {
    return await userCollection.doc(uid).get();
  }

  //profileEdit
  editProfile(Map updateInfo) async {
    return await userCollection.doc(uid).update(updateInfo);
  }

  //posts
  uploadPost(postMap, docRef) async {
    return await docRef.set(postMap);
  }

  //likes
  likePost(likeMap) async {
    return await postsCollection.doc(docId).collection('likes').doc(uid).set(likeMap);
  }

  batchedLikePost(likeMap, updateMap) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference likePost = postsCollection.doc(docId).collection('likes').doc(uid);
    batch.set(likePost, likeMap);
    DocumentReference updateLikePostCount = postsCollection.doc(docId);
    batch.update(updateLikePostCount, updateMap);
    batch.commit().then((_) {});
  }

  batchedUnlikePost(updateMap) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference unlikePost = postsCollection.doc(docId).collection('likes').doc(uid);
    batch.delete(unlikePost);
    DocumentReference updateLikePostCount = postsCollection.doc(docId);
    batch.update(updateLikePostCount, updateMap);
    batch.commit().then((_) {});
  }



  unlikePost() async {
    return await postsCollection.doc(docId).collection('likes').doc(uid).delete();
  }

  incrementPostLikeCount(updateMap) async {
    return await postsCollection.doc(docId).update(updateMap);
  }

  //getLikes()

  Future<bool> hasLikedPost() async {
     try {
      var result = await postsCollection.doc(docId).collection('likes').doc(uid).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  //comments
  uploadComment(commentMap, docRef) async {
    return await docRef.set(commentMap);
  }

  batchedUploadComment(commentMap, docRef, postCommentCount) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference addComment = docRef;
    batch.set(addComment, commentMap);
    DocumentReference updateCommentPostCount = postsCollection.doc(docId);
    batch.update(updateCommentPostCount, postCommentCount);
    batch.commit().then((_) {});
  }

  batchedDeleteComment(commentId, postCommentCount) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference deleteComment = postsCollection.doc(docId).collection('comments').doc(commentId);
    batch.delete(deleteComment);
    DocumentReference updateCommentPostCount = postsCollection.doc(docId);
    batch.update(updateCommentPostCount, postCommentCount);
    batch.commit().then((_) {});
  }

  //likeComment
  likeComment(commentLikeMap, commentId) async {
    return await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('likes').doc(uid).set(commentLikeMap);
  }

  unlikeComment(commentId) async {
    return await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('likes').doc(uid).delete();
  }

  Future<bool> hasLikedComments(commentId) async {
     try {
      var result = await postsCollection.doc(docId).collection('comments')
      .doc(commentId).collection('likes').doc(uid).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  incrementCommentLikeCount(commentId, updateMap) async {
    return await postsCollection.doc(docId).collection('comments')
      .doc(commentId).update(updateMap);
  }

  //delete comments
  deleteComment(commentId) async {
    return await postsCollection.doc(docId).collection('comments')
    .doc(commentId).delete();
  }

  registerUserPreferences(registerUserMap) async {
    return await userCollection.doc(uid).collection('user_preferences').doc(uid).update(registerUserMap);
  }

  createUserPreferences(registerUserMap) async {
    return await userCollection.doc(uid).collection('user_preferences').doc(uid).set(registerUserMap);
  }

  //search

  //searchForUser() async {
  //  return await user
  //}

  //follow
  registerFollower(followerMap, userFollower) async {
    return await userCollection.doc(uid).collection('followers').doc(userFollower).set(followerMap);
  }

  registerFollowing(followingMap, userFollowing) async {
    return await userCollection.doc(uid).collection('following').doc(userFollowing).set(followingMap);
  }

  deleteFollower(userFollower) async {
    return await userCollection.doc(uid).collection('followers').doc(userFollower).delete();
  }

  deleteFollowing(userFollowing) async {
    return await userCollection.doc(uid).collection('following').doc(userFollowing).delete();
  }

  incrementFollowLikeCount(updateMap) async {
    return await userCollection.doc(docId).update(updateMap);
  }

  batchedUnfollow(userFollower, userFollowing, updateMap1, 
  updateMap2, myUid, otherUserUid) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference followRegis = userCollection.doc(otherUserUid).collection('followers').doc(userFollower);
    batch.delete(followRegis);
    DocumentReference followingRegis = userCollection.doc(myUid).collection('following').doc(userFollowing);
    batch.delete(followingRegis);
    DocumentReference updateCounter1 = userCollection.doc(otherUserUid);
    batch.update(updateCounter1, updateMap1);
    DocumentReference updateCounter2 = userCollection.doc(myUid);
    batch.update(updateCounter2, updateMap2);
    batch.commit().then((_) {});
  }

  batchedFollow(followerMap, userFollower, followingMap, 
  userFollowing, updateMap1, updateMap2, myUid, otherUserUid) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference followRegis = userCollection.doc(otherUserUid).collection('followers').doc(userFollower);
    batch.set(followRegis, followerMap);
    DocumentReference followingRegis = userCollection.doc(myUid).collection('following').doc(userFollowing);
    batch.set(followingRegis, followingMap);
    DocumentReference updateCounter1 = userCollection.doc(otherUserUid);
    batch.update(updateCounter1, updateMap1);
    DocumentReference updateCounter2 = userCollection.doc(myUid);
    batch.update(updateCounter2, updateMap2);
    batch.commit().then((_) {});
  }

  Future<bool> isFollowingUser(followingUser) async {
    try {
      var result = await userCollection.doc(uid).collection('following')
      .doc(followingUser).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  Stream isFollowingUser2(followingUser,) {
    return userCollection.doc(uid).collection('following')
    .doc(followingUser).snapshots();
  }

  getFollowingUsers() async {
    return await userCollection.doc(uid).collection('following').limit(500).get();
  }
  

  //for chat
  createChat(chatMap, docRef) async {
    return await docRef.set(chatMap);
  }

  updateChat(updatedChatMap, chatRoomId) async {
    return await chatCollection.doc(chatRoomId).update(updatedChatMap);
  }

  queryChat(List users) async {
    return await chatCollection.where('usersInChat', arrayContains: users).get();
  }

  sendMessage(messageMap, docRef) async {
    return await docRef.set(messageMap);
  }

  createGroupChat(chatMap, docRef) async {
    return await docRef.set(chatMap);
  }

  createChatIdDoc(chatMap, docRef) async {
    return await docRef.set(chatMap);
  }


  //for replies
  createReply(replyMap, docRef) async {
    return await docRef.set(replyMap);
  }

  createReplyBatch(postCommentCount, commentReplyCount, commentId, replyMap, docRef) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference createReply = docRef;
    batch.set(createReply, replyMap);
    DocumentReference updateCommentReplyCount = postsCollection.doc(docId)
      .collection('comments').doc(commentId);
    batch.update(updateCommentReplyCount, commentReplyCount);
    DocumentReference updateCommentPostCount = postsCollection.doc(docId);
    batch.update(updateCommentPostCount, postCommentCount);
    batch.commit().then((_) {});
  }

  deleteReplyBatch(postCommentCount, commentReplyCount, commentId, replyId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference deleteReply = FirebaseFirestore.instance.collection('posts')
      .doc(docId).collection('comments')
      .doc(commentId).collection('replies').doc(replyId);
    batch.delete(deleteReply);
    DocumentReference updateCommentReplyCount = postsCollection.doc(docId)
      .collection('comments').doc(commentId);
    batch.update(updateCommentReplyCount, commentReplyCount);
    DocumentReference updateCommentPostCount = postsCollection.doc(docId);
    batch.update(updateCommentPostCount, postCommentCount);
    batch.commit().then((_) {});
  }


  updateReplyCount(updatedMap, docRef) async {
    return await docRef.update(updatedMap);
  }

  likeReply(commentLikeMap, commentId, replyId) async {
    return await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('replies').doc(replyId).collection('likes').doc(uid).set(commentLikeMap);
  }

  unlikeReply(commentId, replyId) async {
    return await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('replies').doc(replyId).collection('likes').doc(uid).delete();
  }

  Future<bool> hasLikedReplys(commentId, replyId) async {
    try {
      var result = await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('replies').doc(replyId).collection('likes').doc(uid).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  incrementReplyLikeCount(commentId, updateMap, replyId) async {
    return await postsCollection.doc(docId).collection('comments').doc(commentId)
      .collection('replies').doc(replyId).update(updateMap);
  }

  //for hashtags
  createHashtag(hashtagMap, docRef) async {
    return await docRef.set(hashtagMap);
  }

  // for check if friends
  Future<bool> checkIfUsersAreFriends(myUserUid, otherUserUid) async {
    try {
      var result = await userCollection.doc(myUserUid).collection('friends')
        .doc(otherUserUid).get();
      return result.exists;
    } catch(err) {
      throw err;
    }
  }

}


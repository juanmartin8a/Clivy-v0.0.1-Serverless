import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const db = admin.firestore();

export const friends = functions.firestore
.document("users/{userId}/following/{userFollowing}").onCreate(
    async (snapshot) => {
        const followedUser = snapshot.data();
        //console.log(snapshot.);
        console.log(followedUser);
        const promises: Promise<any>[] = [];
        const isOtherUserFollowing = await db.collection("users")
         .doc(followedUser["following"]).collection('following').doc(followedUser["from"]);
        await isOtherUserFollowing.get().then((docSnapshot) => {
            if (docSnapshot.exists) {
                isOtherUserFollowing.onSnapshot( async (doc) => {
                    const createRelationship1 = db.collection("users")
                        .doc(followedUser["from"]).collection('friends')
                        .doc(followedUser["following"]).set({
                            'friendIs': followedUser["following"],
                            'me': followedUser["from"]
                        });
                    const createRelationship2 = db.collection("users")
                        .doc(followedUser["following"]).collection('friends')
                        .doc(followedUser["from"]).set({
                            'friendIs': followedUser["from"],
                            'me': followedUser["following"]
                        });
                    promises.push(createRelationship1, createRelationship2);
                });
            }
        });
        return await Promise.all(promises);
    }
    );

export const removeFriend = functions.firestore
    .document("users/{userId}/following/{userFollowing}").onDelete(
        async (snapshot) => {
            const unfollowedUser = snapshot.data();
            //console.log(snapshot.);
            console.log(unfollowedUser);
            const promises: Promise<any>[] = [];
            const isOtherUserFollowing = await db.collection("users")
            .doc(unfollowedUser["following"]).collection('following').doc(unfollowedUser["from"]);
            await isOtherUserFollowing.get().then((docSnapshot) => {
                if (docSnapshot.exists) {
                    isOtherUserFollowing.onSnapshot( async (doc) => {
                        const deleteRelationship1 = db.collection("users")
                            .doc(unfollowedUser["from"]).collection('friends')
                            .doc(unfollowedUser["following"]).delete();
                        const deleteRelationship2 = db.collection("users")
                            .doc(unfollowedUser["following"]).collection('friends')
                            .doc(unfollowedUser["from"]).delete();
                        promises.push(deleteRelationship1, deleteRelationship2);
                    });
                }
            });
            return await Promise.all(promises);
        }
    );
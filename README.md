# Clivy v0.0.1 (serverless)
Social media for gamers!

This is the first iteration of the Clivy app which functions without a server thanks to Firebase (bad idea). The final iteration of Clivy that uses a monolithic server can be found in [this repository](https://github.com/juanmartin8a/Clivy).


  - ## Why
    I thought that it would be cool to have a dedicated social media exclusively for gamers since it is a huge community.

  - ## Status
    No longer active as I realized that serverless sucks, firebase has many many many limitations.

## Platforms
- iOS
- Android

## Tech used
- **Frontend framework**: Flutter
- **Main database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **File storage**: Firebase Storage
- **Cloud functions**: Firebase using Typescript
- **Notifications**: Firebase Cloud Messaging

## Features
- ### Feeds
  Clivy has 2 different feeds:
  
    - **For you**: Shows recommended videogame clips (in this version of clivy I only used images for testing and simplicity).
  
    - **Following**: Shows the videogame clips (in this version of clivy I only used images for testing and simplicity) of the users you follow.
  
  The clips coming from each feed can be filtered by videogame. This means that you can choose to view clips from a specific videogame in the "For you" or "Following" feeds.
- ### Notifications
  You are notified when:
    - A user adds follows you
    - A user likes your videogame clip
    - A user comments on your videogame clip
    - A user replies to your comment
    - A user likes your comment
    - A user tags you in a comment, reply, or clip caption
- ### Likes and comments
  You can like and comment on any clips and other users can also like and comment on yours! Comments can also be liked and replied.
- ### Follow system
  A follow system is made to enable building relationships between users, it also helps with better videogame clip recommendations.
- ### Tagging system
  A tag system allows users to directly mention others by linking to their user profiles. This is done by using the "@" symbol followed by the username of the user being tagged, for example: "@juanmartin8a". When a user taps on this tag, the app navigates to the tagged user's profile.
- ## Clip
  The information that can be found on an uploaded clip includes:
    - Image
    - Caption
    - Date and time of creation
    - User that created the clip
    - Like count
    - Comment count
    - Comments
    - Views count
  Users can upload clips! This app makes use of [this videogame classification artificial neural network (ANN)](https://github.com/juanmartin8a/Videogame-Video-Classification). The app makes use of the image classification one not the full video classification.
- ### Profiles
  Each user has a profile which includes the following information:
  - Name
  - Gamer tag
  - Banner picture
  - Profile picture
  - Follower count
  - Following count
  - Uploaded videogame clips  
- ### User search
  A search engine for looking for people.

## Example Videos :)
The example videos include videos from when the app was in development

https://github.com/user-attachments/assets/1cc900ce-1bc4-42bc-8d7f-cd2861461947



https://github.com/user-attachments/assets/f022f291-b5cd-483f-9b4c-c73a539a4911



https://github.com/user-attachments/assets/491440bf-ed9b-4dc0-9487-918aebab23e5



https://github.com/user-attachments/assets/1f65ff53-6eaa-4def-907d-4d8737de7d1e



## Pictures
The pictures include pictures from when the app was in development
<div style="text-align: center;">
  <img src="https://github.com/user-attachments/assets/32aff16b-ce20-409b-bcbc-aaa9e2786598" alt="Screenshot 0" width="200" style="max-width: 100%; height: auto; display: inline-block; margin: 5px;" />
  <img src="https://github.com/user-attachments/assets/0f2bf21c-e245-40c7-a5df-e1ae5e1a8f7a" alt="Screenshot 1" width="200" style="max-width: 100%; height: auto; display: inline-block; margin: 5px;" />
  <img src="https://github.com/user-attachments/assets/cd54744e-5936-44d4-a04c-71597f73e595" alt="Screenshot 2" width="200" style="max-width: 100%; height: auto; display: inline-block; margin: 5px;" />
</div>

## Disclaimer
There are a few things to note about this project:
  - This was my first production-ready project!
  - This app uses images instead of clips (short videos). This decision was made to simplify development and testing.

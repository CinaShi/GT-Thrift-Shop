# GT Thrift Shop

The idea of project is to make a mobile application for pre-owned goods trading among Georgia Tech students. This idea came from our experience using Facebook GT thrift shop group page. We believe that a mobile application, with improvement and newly added features such as rating and comments system, instant message and direct photos uploads, will make it more convenient for GT students and faculties to sell or buy used goods. Additionally, integrating GT authentication into the app will make our app a much safer choice for GT students.

## Team Members

  * Jihai An [@alexan0218]
  * Mengyang Shi [@CinaShi]
  * Wenzhong Jin [@WenzhongJin]
  * Yang Yang [@yysama233]
  * Yichen Li [@yli923]

## Detailed Design

 >[Link to our detailed design doc](https://docs.google.com/document/d/12jZxifblpwG3lAC5Kqw02ObpOMUnJd0dU-_GKG7gAdg/edit?usp=sharing)
 
 ## Release Notes
  
 __1. New Features__
  * Users now can search the product they want by keywords and categories.
  * Chat function available.
  * Buyers now can rate and comment the seller after purchasing.
  * Users now can view a product's pictures in full-screen size.
  * The side bar on product page can now be expanded by swiping.
  
 __2. Bugs fixed__
  * Fixed a bug that makes the app crush after users cancel searching.
  * Fixed a bug that makes the swipe gesture fails.
  * User's rating is updated properly now.
  * Fixed minor UI bugs. The app now looks good on different screen sizes.
  
 __3. Existing problems & future functionalities.__
  * This app can only run on iOS devices whose system language is English(U.S.).
  * User will be able to update their profile and products in the future.
  * User will be able to use swipe gesture to browse images in full-screen mode.
  * User will be able to use third party payment methods(Venmo, Paypal, etc) to complete their transaction.

## Install Guide

### Pre-requisites and Download Instruction:

- For developers:

> This project requires Mac OS system, Xcode 8 and Swift 3 to run. Normally if you are using a Mac system already, simply downlaod the [latest version of Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) from App Store and open `GTThriftShop.xcworkspace` in `frontend` folder. 

- For future customers:

> After this app launches in App Store in the future, customers will be able to download it directly from App Store on iPhone. This app currently requires iPhone version of at least 10.0 and iPhone model no earlier than iPhone 6. 

### Dependent Libraries and Trouble-shooting(for developers):

> Normally to run this project there's no need to download any other dependent libraries since all dependent ones have been included. But if when running the app Xcode shoots troubles of any third-party libraries missing, try re-install CocoaPods by running following line in `frontend` folder from Terminal:

```sh
$ pod install
```
### Run Instruction(for developers):

> To run this project in Xcode, you can either use Xcode's built-in iPhone simulator or, if you have an Apple developer account already, connect your device to your Mac and test running the app on your device. If you are unfamiliar with how to use Xcode, here's [an awesome user guide from codewithchris.com](http://codewithchris.com/xcode-tutorial/).


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen.)

[@CinaShi]: <https://github.com/CinaShi>


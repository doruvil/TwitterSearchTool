Twitter Search Tool iOS
=================

This is a part of a functional iPhone app where the user can search for tweets on Twitter and see any particular tweet in a UIWebView while injecting it’s word count after the tweet.

Goal
Develop a functional iPhone app where the user can search for tweets on Twitter and see
any particular tweet in a UIWebView while injecting it’s word count after the tweet.
The search results should be shown in a UITableView and a UIWebView should be
presented every time the user selects a tweet from the results table. The word count of the
tweet should be shown when the UIWebView finishes loading by running some provided
Javascript function.

Expected deliverables

• Xcode project compatible with iOS 6+;

• Any extra document that may be needed to understand how the project is structured, any
special design decisions, etc.
Provided material

• .js file with the Javascript functions to be injected in the page
• function to get the tweet text;

• function to count the number of words in a piece of text;
• function to inject some text between the tweet and its timestamp.
• URL for any giving tweet
• [NSString stringWithFormat:@"https://twitter.com/%@/status/%@",
userHandle, tweetID];
Requirements
User interface
• The user should have a search bar available so that he can search the Twitter for tweets;
• The tweets should be displayed in a UITableView, each of them in its own custom cell;
• Each cell should display the user handle that sent the tweet and a preview of the text if
it’s too large;
• Touching a cell should display a UIWebView in some way with the tweet;
• The number of words in the tweet must be shown to the user as soon as possible when
this UIWebView is presented. This will appear just between the tweet and its timestamp.
Inner workings
You should use Twitter API v1.1 to do the search. In iOS 6+ you have Social framework for
this;
To parse the JSON response from the Twitter search API you should choose your
preferred way to do it;
The Javascript functions provided should be injected in the page and this is how the word
count must be calculated and inserted in the HTML.


Important notes:
This project has been developed by Vilceanu Dumitru (doruvil@yahoo.com)
	The tools starts with a main View Controller which has a search textfield, a search button, a table, but also a textfield in order to set new value for the search count results (the number of the results which are asked in the URL request).
	In order to work, you need to get your Consumer key and Consumer secret from https://dev.twitter.com/apps/new. These two values should be in the application info.plist file. as KEY: TWITTER_CONSUMER_KEY = "your_consumer_key" and TWITTER_CONSUMER_SECRET = "your_consumer_secret".
	Another additional, required setting is to add a Twitter account to your Settings.app (the main Settings application of the iPad).

Workflow: 
	The text you want to search needs to be UITextField, and then press SEARCH. An activity indicator will be shown on the screen, and user interface will be temporarily disabled. After getting the result from calling the URL, the data will be parsed and shown in the table. 
	Also, the number of the tweets got from the call can be changed using the textfield on the right, where you can set another value besides 20 (this is a default value). This count value will also be the number of the entries in the table.
	After getting the search results in the table you can press one cell and a UIWebView will be shown with the Tweet details: username of the user who posted that tweet, the text of the tweet, the number of words in tweet (using javascript injection) and also the date (according the the GMT time).
	Also a back button will be shown in the UIWebView in order to get back to the View Controller which contains the table and the search textfield.


References: 
https://twitter.com/search-home
Using this link each tweet can be searched anonymously.

https://dev.twitter.com/
Main link for twitter dev.

https://dev.twitter.com/docs/api/1.1
API 1.1 documentation link.

https://dev.twitter.com/docs/auth/oauth/faq
Documentation about Authentication.

https://dev.twitter.com/docs/ios
Link where details about integrating API Twitter into iOS can be found

https://dev.twitter.com/discussions
Link where discussion about latest API can be found.

https://dev.twitter.com/docs/ios/making-api-requests-slrequest
SLRequest main reference link

Other References:


http://stackoverflow.com/questions/1965218/twitter-oauth-with-mgtwitterengine
http://stackoverflow.com/questions/14334047/how-to-call-javascript-function-in-objective-c
http://stackoverflow.com/questions/6315317/how-to-reload-already-loaded-uiwebview-with-new-html-string

Projects as template from github:

https://github.com/seancook/TWReverseAuthExample
https://github.com/atebits/OAuthCore
https://github.com/stevenpsmith/ObjectiveCToJavascript
https://github.com/kharrison/CodeExamples/tree/master/TwitterSearch
https://github.com/bengottlieb/Twitter-OAuth-iPhone

https://github.com/meinside/iphonelib/wiki
https://github.com/meinside/iphonelib/wiki/OAuthProvider
http://zwekyethu.appspot.com/github.com/jaanus/PlainOAuth/commit/7e247fcfd81b5196301c22a1edb632a11979efb7
https://github.com/whomwah/tellybox/blob/master/TellyBox/MGTwitterEngine.m
https://github.com/kimptoc/MGTwitterEngine-1.0.8-OAuth/
https://github.com/bengottlieb/Twitter-OAuth-iPhone/blob/master/Twitter%2BOAuth/MGTwitterEngine/MGTwitterEngine.h
https://github.com/mattgemmell/MGTwitterEngine/wiki/Building-and-testing-MGTwitterEngine
https://github.com/mattgemmell/MGTwitterEngine/blob/master/MGTwitterEngineGlobalHeader.h
https://github.com/mattgemmell/MGTwitterEngine




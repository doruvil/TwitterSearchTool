//
//  WebViewController.h
//  DVDTwitterSearch
//  Copyright (c) 2013, Dumitru Vilceanu
//  All rights reserved.
#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
    NSDictionary *tweetDictionary;
}
@property (retain, nonatomic) NSDictionary *tweetDictionaryToUse;

+ (WebViewController *) sharedStore;  /*Singleton used for passing variables*/
@end

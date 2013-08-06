//
//  ViewController.h
//  DVDTwitterSearch
//  Copyright (c) 2013, Dumitru Vilceanu
//  All rights reserved.
#import <UIKit/UIKit.h>
#import "WebViewController.h"
@class WebViewController;

@interface ViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *searchTextfield;
@property (retain, nonatomic) IBOutlet UILabel *valueTweetCount;

@property (retain, nonatomic) IBOutlet UITextField *textfieldNewCountValue; 

@property (retain, nonatomic) IBOutlet UITableView *resultsTable;  /*table used for the search results*/
@property (retain, nonatomic) NSMutableArray *arrayOfTweetsFound; /*array of dictionaries, one dictionary for each tweet*/
@property (readwrite) int numberOfTweets;    /*The number of tweets which will be passed as value for key "count" in URL request*/
@end

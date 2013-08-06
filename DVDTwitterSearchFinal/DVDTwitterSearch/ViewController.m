//
//  ViewController.m
//  DVDTwitterSearch
//  Copyright (c) 2013, Dumitru Vilceanu
//  All rights reserved.

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "ViewController.h"
#import "WaitingState.h"

#define ERROR_TITLE_MSG @"Warning"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this aplication."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

@interface ViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *reverseAuthBtn;
@property (nonatomic, strong) UIButton *searchBtn;


@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *buffer;
@property (nonatomic,strong) NSMutableArray *results;
@end

@implementation ViewController
@synthesize arrayOfTweetsFound;
@synthesize searchTextfield;
@synthesize valueTweetCount;
@synthesize textfieldNewCountValue;
@synthesize resultsTable = _resultsTable;
#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
    }
    return self;
}

- (IBAction)searchAction:(id)sender {
    if([searchTextfield.text length]==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                        message:@"Insert something into the search textfield!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
        
    /*First we show a Activity Indicator and block the user interface*/
    [WaitingState presentActivityIndicatorAsModalFromController:self landscape:YES];
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            /*After getting the access, we format the URL to call*/
            self.accounts = [_accountStore accountsWithAccountType:twitterType];          
            [searchTextfield resignFirstResponder];
            
            /*String which will be searched will be got from the UITextField*/
            NSString *stringToSearch = searchTextfield.text;
            /*String is formated as URL(If has spaces it will be replaced with %20*/
            NSString *encodedstring = [stringToSearch stringByAddingPercentEscapesUsingEncoding:
                                    NSASCIIStringEncoding];
            /*q- string which will be searched; count- is the number of the results expected after calling the URL*/
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:encodedstring, @"q",[NSString stringWithFormat:@"%d",_numberOfTweets],@"count", nil];
            
            NSString *getUrl = @"https://api.twitter.com/1.1/search/tweets.json";
            NSString *finalURL = [NSString stringWithFormat:@"%@?q=%@&count=%@",getUrl,[params valueForKey:@"q"], [params valueForKey:@"count"]];
            /*Creating the TWRequest URL*/
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:finalURL] parameters:nil requestMethod:TWRequestMethodGET];
            [postRequest setAccount:[self.accounts lastObject]];
            NSMutableArray *tweetsArray = [[NSMutableArray alloc]init];
            
            [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                
                // Parse the responseData, which we asked to be in JSON format for this request, into an NSDictionary using NSJSONSerialization.
                
                NSError *jsonParsingError = nil;
                if (responseData)
                {
                    NSDictionary *gotTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
                    /*The dictionary "gotTweets" which have two keys: metadata and statuses, so further we will consider the content for key statuses*/
                    NSArray *allTheTweets = [gotTweets objectForKey:@"statuses"];
                    /*Parsing the array allTheTweets will result a better concludent array which will contain just the information that we need for the tweets*/
                    arrayOfTweetsFound = [self setValuesForTableUsingAllTweetsArray: allTheTweets];
                    /*Having a new set of data, the table will reload the values (delegate methods will be called)*/
                    [_resultsTable reloadData];                   
                }
                else
                {
                    NSLog(@"No result of search");
                }
            }];
        }
    };
    
    //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
    if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)])
    {
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    }
    else
    {
        [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
    }
    [searchTextfield resignFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTwitterAccounts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    if (!_apiManager) {
        _apiManager = [[TWAPIManager alloc] init];
    }
    _numberOfTweets = 20;
    [self showCurrentValueOfTweetCount];
    if (!arrayOfTweetsFound) {
        arrayOfTweetsFound = [[NSMutableArray alloc]init];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)dealloc
{
    [_resultsTable release];
    [textfieldNewCountValue release];
    [valueTweetCount release];
    [searchTextfield release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private
/**
 *  Checks for the current Twitter configuration on the device / simulator.
 *
 *  First, we check to make sure that we've got keys to work with inside Info.plist (see README)
 *
 *  Then we check to see if the device has accounts available via +[TWAPIManager isLocalTwitterAccountAvailable].
 *
 *  Next, we ask the user for permission to access his/her accounts.
 *
 *  Upon completion, the button to continue will be displayed, or the user will be presented with a status message.
 */
- (void)refreshTwitterAccounts
{
    
    if (![TWAPIManager hasAppKeys]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    _reverseAuthBtn.enabled = YES;
                    _searchBtn.enabled = YES;
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    TWALog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
    if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    }
    else {
        [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
    }
}


#pragma mark - Delegate methods for the table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayOfTweetsFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indexToString = @"";
    NSString *tweetToString = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
    }
    indexToString  = [NSString stringWithFormat:@"%d",indexPath.row + 1] ;
    if([arrayOfTweetsFound objectAtIndex:indexPath.row])
        if ([[arrayOfTweetsFound objectAtIndex:indexPath.row]objectForKey:@"text"]) {
            tweetToString = [[arrayOfTweetsFound objectAtIndex:indexPath.row]objectForKey:@"text"];
        }
    /*There will be a dictionary for every tweet which is got using [arrayOfTweetsFound objectAtIndex:indexPath.row] */
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@",indexToString,tweetToString];
    NSString *dateInNormalFormat = [[arrayOfTweetsFound objectAtIndex:indexPath.row]objectForKey:@"timestamp"];
    NSString *userWhoTweeted = [[arrayOfTweetsFound objectAtIndex:indexPath.row]objectForKey:@"screen_name"];
    
    NSString *day = [self getSubstringFromActualSring:dateInNormalFormat usingStartPoint:8 andTheLength:2];
    NSString *month = [self getSubstringFromActualSring:dateInNormalFormat usingStartPoint:4 andTheLength:3];
    NSString *year = [self getSubstringFromActualSring:dateInNormalFormat usingStartPoint:26 andTheLength:4];
    
    NSString *time = [self getSubstringFromActualSring:dateInNormalFormat usingStartPoint:11 andTheLength:8];
    NSString *detailTextForLabel = [NSString stringWithFormat:@"%@ at %@/%@/%@ %@",userWhoTweeted,day,month,year,time];
    
    cell.detailTextLabel.text = detailTextForLabel;
    return cell;
    
}
/*This method will show the UIWebview with full description of the tweet*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebViewController *myStore = [WebViewController sharedStore];
    myStore.tweetDictionaryToUse = [arrayOfTweetsFound objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //automated deselect the cell that has been selected
    [self performSegueWithIdentifier:@"segueWebView" sender:self];
}

/*In this method we check if the table has finished loading in order to stop the activity indicator*/
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [WaitingState stopTheActivityIndicatorFromController:self];
    }
}

#pragma mark - Methods used for parsing data
/*This method is used to get the substring from the actual string using x and y position to have a range for the substring*/
- (NSString *) getSubstringFromActualSring: (NSString *) theActualString usingStartPoint: (int) theBegining andTheLength: (int) theLength
{
    NSRange rangeToGetFromString = NSMakeRange(theBegining, theLength);
    @try {
        NSString *theStringToReturn = [theActualString substringWithRange:rangeToGetFromString];
        return theStringToReturn;
    }
    @catch (NSException *exception) {
        return @"";
    }
    
}

/*This method parses the results from the URL request and returns an array of dictionaries, one dictionary for each tweet*/
- (NSMutableArray *)setValuesForTableUsingAllTweetsArray: (NSArray *)allTweetsArray {
    NSMutableArray *arrayOfTweetsDetailed = [[NSMutableArray alloc]init];
    for (NSDictionary *tweet in allTweetsArray) {
        NSMutableDictionary *newDictForTweet = [[NSMutableDictionary alloc]init];
        [newDictForTweet setValue:[tweet valueForKey:@"text"] forKey:@"text"];
        [newDictForTweet setValue:[tweet valueForKey:@"created_at"] forKey:@"timestamp"];
        [newDictForTweet setValue:[[tweet valueForKey:@"user"] valueForKey:@"name"] forKey:@"name"];
        [newDictForTweet setValue:[[tweet valueForKey:@"user"] valueForKey:@"screen_name"] forKey:@"screen_name"];
        [arrayOfTweetsDetailed addObject:newDictForTweet];
        [newDictForTweet release];
    }
    return arrayOfTweetsDetailed;
}
/*This method sets new value for numberOfTweets, as number of results*/
- (IBAction)setNewValueForTweetCount:(id)sender
{
    _numberOfTweets = [textfieldNewCountValue.text intValue];
    [self showCurrentValueOfTweetCount];
}

/*This method is used to show in a label the actual value of numberOfTweets*/
- (void)showCurrentValueOfTweetCount
{
    [valueTweetCount setText:[NSString stringWithFormat:@"%d",_numberOfTweets]];
}

@end

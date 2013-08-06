//
//  WebViewController.m
//  DVDTwitterSearch
//  Copyright (c) 2013, Dumitru Vilceanu
//  All rights reserved.

#import "WebViewController.h"
static bool webviewLoaded = FALSE;
@interface WebViewController ()<UIWebViewDelegate>
@property (atomic, strong) IBOutlet UIWebView *webView;

@end

@implementation WebViewController
@synthesize tweetDictionaryToUse;
static WebViewController *sharedStore = nil;

+ (WebViewController *) sharedStore {
    @synchronized(self) {
        if(sharedStore == nil) {
            sharedStore = [[self alloc] init];
        }
    }return sharedStore;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webviewLoaded = FALSE;
	// Do any additional setup after loading the view, typically from a nib.
	
    WebViewController *myStore = [WebViewController sharedStore];
    tweetDictionary = myStore.tweetDictionaryToUse;
    
	// Make ourselves the delegate
	[self.webView setDelegate:self];
    
	// Get the path to the html file, this could have easily been loaded from a server as well
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	if ([htmlFile length]) {
        
		// Get the contents of the html file
		NSError *error = NULL;
		NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
		if ([html length]) {
            NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
			
			// Load the html into the web view
			[self.webView loadHTMLString:html baseURL:baseURL];
		} 
	}
}

// This delegate method is used to grab any links used to "talk back" to Objective-C code from the html/JavaScript
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
// In the event we see our URL scheme pass by, we deal with it, otherwise we let other URL schemes pass by
	// You may choose to handle other UIWebViewNavigationType values as your app requires
    if (inType == UIWebViewNavigationTypeOther || inType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *URL = [inRequest URL];
		NSString *scheme = [URL scheme];
		if ([scheme isEqualToString:@"print"]) {
			
			// This is the point where we are communicated with - the resourceSpecifier contains anything after the
			// print: in the URL. We can parse it as needed. In this case we simple NSLog it.
			NSLog(@"%@", [URL resourceSpecifier]);
			
			// Let the webView know we handled it
			return NO;
		}
        if ([scheme isEqualToString:@"dismiss"]) {
			
			// This is the point where we are communicated with - the resourceSpecifier contains anything after the
			// dismiss: dismiss the web view controller
            [self dismissViewControllerAnimated:YES completion:nil];
			// Let the webView know we handled it
			return NO;
		}
    }
	
	// Let the webView handle everything else
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This delegate method is called when a webView has finished loading
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webviewLoaded) {
        /*Creating the function to call: countWords with one parameter*/
        NSString *function = [[NSString alloc] initWithFormat: @"countWords('%@')", [tweetDictionary objectForKey:@"text"]];
        NSString *wordCount = [self.webView stringByEvaluatingJavaScriptFromString:function];
        /*Variable wordCount is the result of calling the function*/
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        if ([htmlFile length]) {
            
            // Get the contents of the html file
            NSError *error = NULL;
            NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
            if ([html length]) {
                
                // Define the string to inject into the html file - this can be anything you like including
                // JavaScript code, html, css, etc. - anything that the client can handle
                // Inject the string by replacing our placeholder. You can use anything you like as a placeholder
                // here including a comment such as <!-- put stuff here -->, etc. I happen to be setting a JavaScript
                // variable in this case but you could just as easily fill in the contents of a <div>, etc.
                
                NSString *twitterUsername = [tweetDictionary objectForKey:@"screen_name"];
                NSString *twitterTweet = [tweetDictionary objectForKey:@"text"];
                NSString *twitterTweetDate = [tweetDictionary objectForKey:@"timestamp"];
                
                html = [html stringByReplacingOccurrencesOfString:@"%twitterUsername%" withString:twitterUsername];
                html = [html stringByReplacingOccurrencesOfString:@"%twitterTweet%" withString:twitterTweet];
                html = [html stringByReplacingOccurrencesOfString:@"%wordCount%" withString:wordCount];
                html = [html stringByReplacingOccurrencesOfString:@"%twitterTweetDate%" withString:twitterTweetDate];
                // Get the base URL of the file in question, in case the page loads any other assets, etc.
                NSURL *baseURL = [NSURL fileURLWithPath:htmlFile];
                
                // Load the html into the web view (the html which contains also the values)
                [self.webView loadHTMLString:html baseURL:baseURL];
            } 
        } 
         webviewLoaded = TRUE;
    }
}
@end

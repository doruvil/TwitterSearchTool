
#import "WaitingState.h"

@implementation WaitingState

UIView * globalView;

+ (void)presentActivityIndicatorAsModalFromController:(UIViewController *)controller landscape:(bool)landscape
{
    controller.view.userInteractionEnabled = FALSE;
    
    CGRect rectForActivityIndicator;
    if(landscape)
    {
        rectForActivityIndicator = CGRectMake(controller.view.frame.size.height/2 - 100, controller.view.frame.size.width/2 - 100,200, 200);
    }
    else
    {
        rectForActivityIndicator = CGRectMake(controller.view.frame.size.width/2 - 100, controller.view.frame.size.height/2 - 100,200, 200);
    }
    
    
    UIActivityIndicatorView * activityIndicatorFade = [[UIActivityIndicatorView alloc] initWithFrame:rectForActivityIndicator];
    
    activityIndicatorFade.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicatorFade.alpha = 4.0;
    
    CGRect rectForGlobalView;
    if(landscape)
    {
        rectForGlobalView = CGRectMake(0, 0, controller.view.frame.size.height + 20, controller.view.frame.size.width);
    }
    else
    {
        rectForGlobalView = CGRectMake(0, 0, controller.view.frame.size.width, controller.view.frame.size.height + 20);
    }
    
    
    globalView = [[UIView alloc] initWithFrame:rectForGlobalView];
    globalView.backgroundColor = [UIColor blackColor];
    
    [globalView addSubview:activityIndicatorFade];
    [activityIndicatorFade startAnimating];
    [controller.view addSubview:globalView];
    
    globalView.alpha = 0.0f;
    [UIView beginAnimations:@"fadeInSecondView" context:NULL];
    [UIView setAnimationDuration:0.5];
    globalView.alpha = 0.5f;
    [UIView commitAnimations];
}

+ (void)stopTheActivityIndicatorFromController:(UIViewController *)controller
{
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ globalView.alpha = 0.0;
                     }
                     completion:^(BOOL fin) {
                         if (fin)
                         {[globalView removeFromSuperview];
                         }
                     }];
    controller.view.userInteractionEnabled = TRUE;
}

+ (void)presentActivityIndicatorAsModalFromControllerOnHalt:(NSMutableArray *)arrayWithObjects
{
    bool landscape;
    if([[arrayWithObjects objectAtIndex:1] isEqualToString:@"TRUE"])
    {
        landscape = TRUE;
    }
    else
    {
        landscape = FALSE;
    }
    [WaitingState presentActivityIndicatorAsModalFromController:[arrayWithObjects objectAtIndex:0] landscape:landscape];
    
}

+ (void)stopTheActivityIndicatorFromControllerForNSThreadDetach:(UIViewController *)controller
{
   // currentProgressBarFilling = 0.0;
    // UIWindow *w = [[[UIApplication sharedApplication] windows] objectAtIndex: 0];
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ globalView.alpha = 0.0;
                        // viewWithElementsToDisplayGlobal.alpha = 0.0;
                     }
                     completion:^(BOOL fin) {
                         if (fin)
                         {[globalView removeFromSuperview];
                            // [viewWithElementsToDisplayGlobal removeFromSuperview];
                             // call the sent delegate
                             
                             //                             else
                             //                             {
                             //                                 [StartUpClass returnMainController].view.userInteractionEnabled = TRUE;
                             //                             }
                             
                             // NSLog(@"load data 34r534v34rv");
                             
                            // globalView.userInteractionEnabled = TRUE;
                             
                         }
                     }];
    controller.view.userInteractionEnabled = TRUE;
    // w.userInteractionEnabled = TRUE;
}
@end

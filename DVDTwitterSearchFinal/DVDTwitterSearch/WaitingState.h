
#import <Foundation/Foundation.h>

@interface WaitingState : NSObject

+ (void)presentActivityIndicatorAsModalFromController:(UIViewController *)controller landscape:(bool)landscape;
+ (void)stopTheActivityIndicatorFromController:(UIViewController *)controller;
+ (void)presentActivityIndicatorAsModalFromControllerOnHalt:(NSMutableArray *)arrayWithObjects;
+ (void)stopTheActivityIndicatorFromControllerForNSThreadDetach:(UIViewController *)controller;

@end

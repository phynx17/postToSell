//
//  RecallAppDelegate.m
//  Recall
//
//  Created by Pandu Pradhana on 11/9/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import "RecallAppDelegate.h"
#import "LoginViewController.h"
#import "LoginTableController.h"
#import "LatestViewController.h"

#import "ParseOperation.h"
#import "PostItemRequest.h"
#import "PostItem.h"

@implementation RecallAppDelegate


@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize loginViewController;
@synthesize latestViewController;


@synthesize postItemRecords;
@synthesize queue;
@synthesize apiConnection;
@synthesize postItemListData;
@synthesize lastItemSellId;




/**
 * INI GAG BAKAL DI PANGGIL CUYYYY
 *
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    NSLog(@"Moneyetss");
    [_window addSubview:_tabBarController.view];
}
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.     
    //self.window.rootViewController = self.viewController;
    
    /*
        ==============
        A simple login 
        ============== 
     */
    //NSLog(@"entering didFinishLaunchingWithOptions()");
    self.window.rootViewController = self.tabBarController;
    [self.window addSubview:_tabBarController.view];
    
    /* 
        ==============
        A simple login 
        ==============
    LoginViewController *newloginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];    
    
    self.loginViewController = newloginViewController;
	[newloginViewController release];
    
    [self.window addSubview:loginViewController.view];    
    */
    
    /*
         ==================
         A login with table
         ==================
    LoginTableController *newloginViewController = [[LoginTableController alloc] initWithNibName:@"LoginTableController" bundle:nil];    
    
    self.loginViewController = newloginViewController;
	[newloginViewController release];
    
    [self.window addSubview:loginViewController.view];    
     */
    

    //
    // Don't DO THIS!! http://forums.macrumors.com/showthread.php?t=1233594
    //[loginViewController release];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark ParseOperationDelegate delegate methods

// -------------------------------------------------------------------------------
//	didFinishParsing:appList
// -------------------------------------------------------------------------------
- (void)didFinishParsing:(NSArray *)appList
{
    /**
     * Last ID always set at first index
     *
     */
    if (appList.count > 0) {
        PostItem *_lastPost = [appList objectAtIndex:0];
        if (_lastPost) {
            [self setLastItemSellId:_lastPost.streamId];            
        }
        _lastPost = nil;
    }
    
    [self performSelectorOnMainThread:@selector(handleLoadedApps:) 
                           withObject:appList 
                        waitUntilDone:NO];    
    self.queue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}


// -------------------------------------------------------------------------------
//	handleLoadedApps:notif
// -------------------------------------------------------------------------------
- (void)handleLoadedApps:(NSArray *)loadedApps
{
    [self.postItemRecords addObjectsFromArray:loadedApps];
    //NSIndexSet *start = [NSIndexSet indexSetWithIndex:0];
    //[self.postItemRecords insertObjects:loadedApps atIndexes:start];
    
    
    // tell our table view to reload its data, now that parsing has completed
    [latestViewController.tableLatestPost reloadData];

    [self performSelector:@selector(methodThatCallsScrollToRow) withObject:nil];

}
// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Latest Post"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


/**
 * Automatically scroll to hide the search box
 *
 */
- (void) methodThatCallsScrollToRow
{    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    //[NSIndexPath indexPathWithIndex:2];
    [latestViewController.tableLatestPost scrollToRowAtIndexPath:scrollIndexPath 
                                                atScrollPosition:(UITableViewScrollPositionTop) 
                                                        animated:TRUE];    
}




#pragma mark -
#pragma mark PostItemRequestDelegate delegate methods

- (void)request:(PostItemRequest *)request didFailWithError:(NSError *)error;
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Problem while posting"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)request:(PostItemRequest *)request didLoad:(id)result {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
														message:@"Post is sent to Pandoo.me"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
}



- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [latestViewController release];
    [super dealloc];
}

@end

//
//  RecallAppDelegate.h
//  Recall
//
//  Created by Pandu Pradhana on 11/9/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ParseOperation.h"
#import "PostItemRequest.h"


//@class RecallViewController;
@class LatestViewController;

@interface RecallAppDelegate : 
    NSObject <UIApplicationDelegate, 
                UITabBarControllerDelegate, 
                ParseOperationDelegate, PostItemRequestDelegate> {
                    
    UITabBarController *tabBarController;
    UIViewController *loginViewController;
    LatestViewController *latestViewController;

    /**
     * The post item stream list
     *
     */
    NSMutableArray          *postItemRecords;
    NSOperationQueue		*queue;
    NSURLConnection         *apiConnection;
    NSMutableData           *postItemListData;
    NSInteger               *lastItemSellId;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LatestViewController *latestViewController;
@property (nonatomic, retain) UIViewController *loginViewController;

@property (nonatomic, retain) NSMutableArray *postItemRecords;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSURLConnection *apiConnection;
@property (nonatomic, retain) NSMutableData *postItemListData;
@property (nonatomic, assign) NSInteger *lastItemSellId;


@end

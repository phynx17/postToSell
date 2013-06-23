//
//  LatestViewController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/11/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RecallAppDelegate.h"
#import "IconDownloader.h"
#import "EGORefreshTableHeaderView.h"


//@class RecallAppDelegate;

@interface LatestViewController : UIViewController
                        <UITableViewDelegate, 
                         UITableViewDataSource,
                         IconDownloaderDelegate, 
                         UIScrollViewDelegate,
                         EGORefreshTableHeaderDelegate, 
                         UIScrollViewDelegate> {
                             
    IBOutlet UIWindow *window;
    IBOutlet RecallAppDelegate *appDelegate;
    IBOutlet UITableView *tableLatestPost;
                             
                             
    EGORefreshTableHeaderView *_refreshHeaderView;
                             
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes 
    BOOL _reloading;                            

    @private 
        // for downloading the xml data from API
        NSURLConnection *apiURLConnection;
        // the set of IconDownloader objects for each app
        NSMutableDictionary *imageDownloadsInProgress;
                             
        NSOperationQueue *queueParser;
}


- (void)callTheAPI;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;



/**
 * The synthetized properties
 *
 */
@property (nonatomic, retain) RecallAppDelegate *appDelegate;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITableView *tableLatestPost;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress; 
@property (nonatomic, retain) NSOperationQueue *queueParser;
@property (nonatomic, retain) EGORefreshTableHeaderView *_refreshHeaderView;

@end

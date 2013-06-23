/*
    The icon downloader. Source is modified version of 
    Apple's LazyTableImages
  
    Created by Pandu Pradhana on 11/9/11.
    Copyright 2011 PhynxSoft. All rights reserved.    
 */

#import "ImageManipulator.h"

@class PostItem;
@class LatestViewController;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    PostItem *postItem;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) PostItem *postItem;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
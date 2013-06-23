/*
 The icon downloader. Source is modified version of 
 Apple's LazyTableImages
 
 Created by Pandu Pradhana on 11/9/11.
 Copyright 2011 PhynxSoft. All rights reserved.    
 */


#import "IconDownloader.h"
#import "PostItem.h"
#import "ImageManipulator.h"

#define kAppIconHeight 48


@implementation IconDownloader

@synthesize postItem;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
    [postItem release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:postItem.itemImageURL] delegate:self];
    
    NSLog(@"IconDownloader.startDownload: after connect URL : %@",postItem.itemName);    
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"IconDownloader.connectionDidFinishLoading %@",postItem.itemName);    
    
    
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    /**
     * Biar cakep dikit :p
     *
     */    
    image = [ImageManipulator 
                makeRoundCornerImage:image : 8 : 8];
    
    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.postItem.itemImage = UIGraphicsGetImageFromCurrentImageContext();
        //image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {
        self.postItem.itemImage = image;
    }
    
    self.activeDownload = nil;
    if (image) {
        [image release];
    }
    
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display

    //NSLog(@"(IconDownloader) Will call delegate %@",postItem.itemName);    

    [delegate appImageDidLoad:self.indexPathInTableView];

    //NSLog(@"(IconDownloader) After call delegate %@",postItem.itemName);    

}

@end


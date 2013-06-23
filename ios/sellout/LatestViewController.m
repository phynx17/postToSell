//
//  LatestViewController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/11/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import "LatestViewController.h"
#import "ParseOperation.h"
#import "PostItem.h"
#import "Constant.h"
#import "EGORefreshTableHeaderView.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>


// Each subview in the cell will be identified by a unique tag.
static NSUInteger const kItemNameLabelTag = 2;
static NSUInteger const kDescriptionLabelTag = 3;
static NSUInteger const kPriceTag = 4;
static NSUInteger const kItemImageTag = 5;


# pragma LatestViewController()

// forward declarations
@interface LatestViewController()
    @property (nonatomic, retain) NSURLConnection *apiURLConnection;
    - (void)handleError:(NSError *)error;
    - (void)startIconDownload:(PostItem *)postItem forIndexPath:(NSIndexPath *)indexPath;
    - (void)loadImagesForOnscreenRows;

@end



#pragma mark -
#pragma mark LatestViewController

@implementation LatestViewController

@synthesize window;
@synthesize appDelegate;
@synthesize tableLatestPost;
@synthesize apiURLConnection;
@synthesize imageDownloadsInProgress;
@synthesize queueParser;
@synthesize _refreshHeaderView;

/* --- End Sythesize part --- */



#pragma mark -
#pragma mark Class's constant

// customize the appearance of table view cells
//
static NSString *kPostItemCellID = @"PostItemCellID";   
static NSString *CellIdentifier = @"LazyTableCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [apiURLConnection release];
    [tableLatestPost release];
    [appDelegate release];
    [_refreshHeaderView release];
    [window release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
 - (void)viewDidLoad
 {
     //NSLog(@"Entering viewDidLoad");
     self.imageDownloadsInProgress = [NSMutableDictionary dictionary];

     [super viewDidLoad];
    
     /*
      postItemQueue = [NSOperationQueue new];
      
      
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(addPostItem:)
                                                  name:kAddPostItemsNotif
                                                object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(postItemError:)
                                                  name:kPostItemErrorNotif
                                                object:nil];
      */

     //self.postItemList = [NSMutableArray array];
     self.appDelegate.postItemRecords = [NSMutableArray array];
     
     // The table row height is not the standard value. Since all the rows have the same height,
     // it is more efficient to set this property on the table, rather than using the delegate
     // method -tableView:heightForRowAtIndexPath:
     //
     self.tableLatestPost.rowHeight = kCustomRowHeight;
     
     // KVO: listen for changes to our earthquake data source for table view updates
     //[self addObserver:self forKeyPath:@"postItemList" options:0 context:NULL];
     
     [self callTheAPI];
     
     
     
     /**
      * Create the reloading appreance
      *
      */
     EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
                                        initWithFrame:CGRectMake(0.0f, 0.0f - 
                                                    self.tableLatestPost.bounds.size.height, 
                                                    self.view.frame.size.width, 
                                                    self.tableLatestPost.bounds.size.height)];
     view.delegate = self;
     [self.tableLatestPost addSubview:view];
     _refreshHeaderView = view;
     [view release];

 }


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableLatestPost = nil;    
    //[self removeObserver:self forKeyPath:@"postItemList"];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (void)callTheAPI 
{
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not
    // be blocked - the application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked!
    // Also, avoid synchronous network access on any thread.
    //
    NSString *lastId = self.appDelegate.lastItemSellId ? 
                        [NSString stringWithFormat:@"&from_id=%d",self.appDelegate.lastItemSellId]
                        :
                        @"";
    
    NSString *theAPI = [NSString stringWithFormat:@"%@/stream?api_key=2c002a%@"
                            ,SERVER_URL_API
                            ,lastId];
    
    if (DEBUG) {
        NSLog(@"Calling URL: %@",theAPI);
    }
    
    //NSLog(@"Before request URL");
    //NSURLRequest
    NSMutableURLRequest *itemAPIURLRequest = 
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:theAPI]];
    [itemAPIURLRequest setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    self.apiURLConnection = [[[NSURLConnection alloc] initWithRequest:itemAPIURLRequest 
                                                             delegate:self] autorelease];
    
    //NSLog(@"After the URL intantiation");
    
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.apiURLConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}






#pragma mark -
#pragma mark KVO support
/*
- (void)insertPostItems:(NSArray *)postItems
{
    // this will allow us as an observer to notified (see observeValueForKeyPath)
    // so we can update our UITableView
    //
    [self willChangeValueForKey:@"postItemList"];
    [self.postItemList addObjectsFromArray:postItems];
    [self didChangeValueForKey:@"postItemList"];
}

// listen for changes to the earthquake list coming from our app delegate.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self.tableLatestPost reloadData];
}
*/


#pragma mark <UITableViewDelegate> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// The cell uses a custom layout, but otherwise has standard behavior for UITableViewCell.
// In these cases, it's preferable to modify the view hierarchy of the cell's content view, rather
// than subclassing. Instead, view "tags" are used to identify specific controls, such as labels,
// image views, etc.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Declare references to the subviews which will display the earthquake data.
    UILabel *itemLabel = nil;
    UILabel *descriptionLabel = nil;
    UILabel *priceLabel = nil;
    UIImageView *itemImage = nil;

    // add a placeholder cell while waiting on table data
    int netsign = 0;
    if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        netsign = 1;
    }
	//NSLog(@"--> %d, networkActivityIndicatorVisible: %d",nodeCount,netsign);
    
    
    //int nodeCount = [self.appDelegate.postItemRecords count];
    
    /**
     * ====================
     *
     *   The Loading Part
     * 
     * ====================
     */
	if (netsign == 1){
        if (indexPath.row == 0) {
            UITableViewCell *cell = 
                                [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
                cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.detailTextLabel.text = @"Loading…";
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }    
    
    
    
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPostItemCellID];
	if (cell == nil) {
        // No reusable cell was available, so we create a new cell and configure its subviews.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kPostItemCellID] autorelease];
        
        itemLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78, 3, 230, 20)] autorelease];
        itemLabel.tag = kItemNameLabelTag;
        itemLabel.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:itemLabel];
        
        descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78, 28, 230, 14)] autorelease];
        descriptionLabel.tag = kDescriptionLabelTag;
        descriptionLabel.font = [UIFont systemFontOfSize:11];
        [cell.contentView addSubview:descriptionLabel];

        priceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(78, 48, 230, 14)] autorelease];
        priceLabel.tag = kPriceTag;
        priceLabel.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:priceLabel];        
        
        /**
         * The image tend to be 48x48 
         *
         *
        itemImage = [[[UIImageView alloc] 
                      initWithImage:[UIImage imageNamed:@"Placeholder.png"]] autorelease];
         */
        //itemImage = [[UIImageView alloc] init];
        itemImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 48, 48)];
        itemImage.tag = kItemImageTag;
        itemImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:itemImage];
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews
        // using their tags.
        //
        itemLabel = (UILabel *)[cell.contentView viewWithTag:kItemNameLabelTag];
        descriptionLabel = (UILabel *)[cell.contentView viewWithTag:kDescriptionLabelTag];
        priceLabel = (UILabel *)[cell.contentView viewWithTag:kPriceTag];
        itemImage = (UIImageView *)[cell.contentView viewWithTag:kItemImageTag];
    }
    
    // Get the specific earthquake for this row.
	//PostItem *postItem = [postItemList objectAtIndex:indexPath.row];
    PostItem *postItem = [self.appDelegate.postItemRecords objectAtIndex:indexPath.row];
    
    /*
    NSLog([NSString stringWithFormat:@"PostItem Count: %d now: %d",
           postItemList.count, indexPath.row]);
    */
    
    // Set the relevant data for each subview in the cell.
    itemLabel.text = [NSString stringWithFormat:@"%@", postItem.itemName];
    descriptionLabel.text = [NSString stringWithFormat:@"%@", postItem.description];
    priceLabel.text = [NSString stringWithFormat:@"%@: %f", postItem.currency, postItem.priceOffer];    
    
    //dateLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:earthquake.date]];
   // magnitudeLabel.text = [NSString stringWithFormat:@"%.1f", earthquake.magnitude];
    //magnitudeImage.image = [self imageForMagnitude:earthquake.magnitude];
    
    //WORK THIS LATER
    // Leave cells empty if there's no data yet
    //if (nodeCount > 0)
	//{
        // Set up the cell...
        // Only load cached images; defer new downloads until scrolling ends
        if (!postItem.itemImage)
        {
            if (self.tableLatestPost.dragging == NO 
                && self.tableLatestPost.decelerating == NO)
            {
                if (DEBUG) NSLog(@"Start download Icon at index : %d", indexPath.row);
                [self startIconDownload:postItem forIndexPath:indexPath];
            } 
            // if a download is deferred or in progress, return a placeholder image
            
            //Already
            //cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];            
            itemImage.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            if (DEBUG) NSLog(@"Icon already downloaded at index : %d", indexPath.row);
            //cell.imageView.image = postItem.itemImage;
            //itemImage = (UIImageView *)[cell.contentView viewWithTag:kItemImageTag];            
            if (postItem.itemImage && itemImage.image) {
                itemImage.image = postItem.itemImage;
            }
        }
        
    //}    
    
    
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [postItemList count];
    int count = self.appDelegate.postItemRecords.count;
	
	// ff there's no data yet, return enough rows to fill the screen
    if (count == 0) {
        return kCustomRowCount;
    }
    return count;    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return @"";
}




#pragma mark -
#pragma mark <IconDownloaderDelegate> delegate methods

- (void)startIconDownload:(PostItem *)postItem forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (DEBUG) NSLog(@"Going to start download Icon: %@",iconDownloader);
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.postItem = postItem;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader 
                                     forKey:indexPath]; 
        if (DEBUG) {
            NSLog(@"The OBJ: %@",iconDownloader);                        
            NSLog(@"After set OBJ imageDownloadsInProgress row: %d section: %d",
                  indexPath.row, indexPath.section);
            
            IconDownloader *_iconDownloader = 
                    //[imageDownloadsInProgress objectForKey:indexPath];
                    [imageDownloadsInProgress objectForKey:indexPath];
            
            NSLog(@"Test get OBJ row: %d section: %d --> %@",
                  indexPath.row, indexPath.section, _iconDownloader);
            _iconDownloader = nil;
        }
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.appDelegate.postItemRecords count] > 0)
    {
        NSArray *visiblePaths = [self.tableLatestPost indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            PostItem *postItem = [self.appDelegate.postItemRecords 
                                    objectAtIndex:indexPath.row];
            
            // avoid the app icon download if the app already has an icon
            if (!postItem.itemImage)             {
                [self startIconDownload:postItem forIndexPath:indexPath];
            }
            postItem = nil;
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    NSLog(@"Start Image set: %d: section: %d",indexPath.row, indexPath.section);    
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    NSLog(@"IconDownloader: %@",iconDownloader); 
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableLatestPost 
                                 cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        //cell.imageView.image = iconDownloader.postItem.itemImage;

        UIImageView *itemImage = (UIImageView *)[cell.contentView viewWithTag:kItemImageTag];
        itemImage.image = iconDownloader.postItem.itemImage;
        
        cell = nil;
        
        
        //NSLog(@"cell.imageView.image: %@",cell.imageView.image); 
        NSLog(@"itemImage.image: %@",itemImage.image); 
    
        //repaint
        //[cell setNeedsDisplay];
        //[self.tableLatestPost reloadData];
        //[self.tableLatestPost setNeedsDisplay];
        [self.tableLatestPost performSelectorOnMainThread:@selector(reloadData) 
                               withObject:nil waitUntilDone:NO];
        
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /**
     * Do the Reloading view
     *
     */
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];    
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];    
    [self loadImagesForOnscreenRows];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}





#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    //NSLog(@"Receive response");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"text/xml"]) {
        //self.postItemData = [NSMutableData data];
        appDelegate.postItemListData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Just to print it out to console
    /*
    NSString *thdata = 
        [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog([NSString stringWithFormat:@"Receive data : %@",thdata]); 
    [thdata release];
     */
    //[postItemData appendData:data]; 
    [appDelegate.postItemListData appendData:data];
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.apiURLConnection = nil;
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"Receive connectionDidFinishLoading");
    
    self.apiURLConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    ParseOperation *parseOperation = [[ParseOperation alloc] 
                                      initWithData:[self.appDelegate postItemListData]
                                      delegate:[self appDelegate]];   
    
    // this will start the "ParseOperation"
    //[self.postItemQueue addOperation:parseOperation];
    
    //[self.appDelegate setQueue:[NSOperationQueue new]];
    [self.appDelegate setQueue:[[NSOperationQueue alloc] init]];
    [self.appDelegate.queue addOperation:parseOperation];
    
    //self.queueParser = [[NSOperationQueue alloc] init];
    //[self.queueParser addOperation:parseOperation];
    
    // once added to the NSOperationQueue it's retained, we don't need it anymore
    [parseOperation release];       
    // earthquakeData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    //self.postItemData = nil;
    self.appDelegate.postItemListData = nil;
    
    
    [self doneLoadingTableViewData];
    
}

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Cannot Fetch Data",
                       @"Error while fetching data from the API")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}






#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[self._refreshHeaderView 
        egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableLatestPost];
	
}




#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    [self callTheAPI];
    
	[self reloadTableViewDataSource];	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{	
	return [NSDate date]; // should return date data source was last changed
	
}




#pragma mark -
#pragma mark NSNotification callbacks


/* OLD VESION 
// Our NSNotification callback from the running NSOperation to add the earthquakes
//
- (void)addPostItem:(NSNotification *)notif {
    //NSLog(@"addPostItem");
    
    assert([NSThread isMainThread]);    
    [self addPostItemToList:[[notif userInfo] valueForKey:kPostItemResultsKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)postItemError:(NSNotification *)notif 
{
    assert([NSThread isMainThread]);    
    [self handleError:[[notif userInfo] valueForKey:kPostItemsMsgErrorKey]];
}
*/

// The NSOperation "ParseOperation" calls addPostItemToList: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.
// The batch size is set via the kSizeOfEarthquakeBatch constant.
//
/*
- (void)addPostItemToList:(NSArray *)postItem 
{
    PostItem *i = [postItem objectAtIndex:3];
    NSLog(@"addPostItemToList: %@",i.itemName);    
    [self insertPostItems:postItem];
}
 */


@end

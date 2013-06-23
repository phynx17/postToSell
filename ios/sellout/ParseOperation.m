//
//  ParseOperation.m
//  Recall
//
//  Created by Pandu Pradhana on 11/15/11.
//  Copyright 2011 Codejawa. All rights reserved.
//

#import "ParseOperation.h"
#import "PostItem.h"

/* OLD VERSION 
// NSNotification name for sending post item data back to the app delegate
NSString *kAddPostItemsNotif = @"AddPostItemsNotif";

// NSNotification userInfo key for obtaining the post item data
NSString *kPostItemResultsKey = @"PostItemResultsKey";

// NSNotification name for reporting errors
NSString *kPostItemErrorNotif = @"PostItemErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kPostItemsMsgErrorKey = @"PostItemsMsgErrorKey";
*/




#pragma mark -
#pragma mark Parser constants

// Limit the number of parsed post item to 30
//
static const const NSUInteger kMaximumNumberOfPostItemToParse = 30;

// When an PostItem object has been fully constructed, it must be passed to the main thread and
// the table view in RootViewController must be reloaded to display it. It is not efficient to do
// this for every Earthquake object - the overhead in communicating between the threads and reloading
// the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the
// constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
//
static NSUInteger const kSizeOfPostItemBatch = 10;

static NSString * const kURL_DEFAULT = @"http://null.ceode.me";



#pragma mark -
#pragma mark Element Names

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kItemElementName = @"ITEM";
static NSString * const kItemStreamId = @"ID";
static NSString * const kSellItemElementName = @"SELL_ITEM";
static NSString * const kItemIdElementName = @"ITEM_ID";
static NSString * const kUsernameElementName = @"USERNAME";
static NSString * const kUserfullnameElementName = @"USER_FULLNAME";
static NSString * const kCategoryElementName = @"CATEGORY";
static NSString * const kDatePostedElementName = @"DTPOSTED";
static NSString * const kItemNameElementName = @"ITEM_NAME";
static NSString * const kDescriptionElementName = @"DESCRIPTION";
static NSString * const kPriceOfferElementName = @"PRICE_OFFER";
static NSString * const kPriceAskMinElementName = @"PRICE_ASK_MIN";
static NSString * const kPriceAskMaxElementName = @"PRICE_ASK_MAX";
static NSString * const kCurrencyMinElementName = @"CURRENCY";
static NSString * const kLocationMaxElementName = @"LOCATION";
static NSString * const kLongitudeMaxElementName = @"LOC_LAN";
static NSString * const kLatitudeMaxElementName = @"LOC_LAT";
static NSString * const kImageLinkElementName = @"IMAGE_URL";
static NSString * const kDeliveryElementName = @"DELIVERY";







@interface ParseOperation () 
    /* OLD VERSION 
    @property (nonatomic, copy) NSData *postItemData;
    @property (nonatomic, retain) PostItem *currentPostItemObject;
    @property (nonatomic, retain) NSMutableArray *currentParseBatch;
    @property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
    */
    @property (nonatomic, assign) id <ParseOperationDelegate> delegate;
    @property (nonatomic, retain) NSData *dataToParse;
    @property (nonatomic, retain) NSMutableArray *workingArray;
    @property (nonatomic, retain) PostItem *workingEntry;
    @property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
    @property (nonatomic, retain) NSArray *elementsToParse;
    @property (nonatomic, assign) BOOL storingCharacterData;
    @property (nonatomic, assign) BOOL didAbortParsing;
@end


@implementation ParseOperation

//OLD VERSION 
//@synthesize postItemData, currentPostItemObject, currentParsedCharacterData, currentParseBatch;

@synthesize delegate;
@synthesize dataToParse;
@synthesize workingArray;
@synthesize workingEntry;
@synthesize currentParsedCharacterData;
@synthesize elementsToParse;
@synthesize storingCharacterData;
@synthesize didAbortParsing;


//OLD VERSION 
/*
- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {    
        postItemData = [parseData copy];  
        //postItemData = parseData;  
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    }
    return self;
}
*/


- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;      
        self.elementsToParse = 
                [NSArray arrayWithObjects:
                                kItemElementName, kItemStreamId, 
                                kSellItemElementName, kItemIdElementName, 
                                kUsernameElementName, kUserfullnameElementName,
                                kCategoryElementName, kDatePostedElementName,
                                kItemNameElementName,kDescriptionElementName,
                                kPriceOfferElementName,kPriceAskMinElementName,
                                kPriceAskMaxElementName, kCurrencyMinElementName,
                                kLocationMaxElementName,kLongitudeMaxElementName,
                                kLatitudeMaxElementName,kImageLinkElementName, 
                                kDeliveryElementName, nil];
    }
    return self;
}



/* OLD VERSION 
// the main function for this NSOperation, to start the parsing
- (void)main {
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    //
    //NSLog(@"Start NSOperation");
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.postItemData];
    [parser setDelegate:self];
    [parser parse];
    NSLog(@"End NSOperation");

    // depending on the total number of post item parsed, the last batch might not have been a
    // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
    // the array and, if necessary, send it to the main thread.
    //
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addPostItemsToList:)
                               withObject:self.currentParseBatch 
                            waitUntilDone:NO];
        //NSLog(@"Performing add to table");

    }
    
    self.currentParseBatch = nil;
    self.currentPostItemObject = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}
*/




// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.currentParsedCharacterData = nil;
    self.dataToParse = nil;
    
    [parser release];
    
	[pool release];
}







/* OLD VERSION 

//The selector of completing XML parsing task
- (void)addPostItemsToList:(NSArray *)postItems {    
    //assert([NSThread isMainThread]);
    //NSLog(@"start addPostItemsToList()");

    PostItem *i = [postItems objectAtIndex:0];
    NSLog(@"ParseOperation.addPostItemToList (1): %@",i.itemName);   
    i = nil;

    i = [postItems objectAtIndex:1];
    NSLog(@"ParseOperation.addPostItemToList (2): %@",i.itemName);   
    i = nil;
    
    
    //[i release];
    
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:kAddPostItemsNotif
                          object:self
                        userInfo:[NSDictionary dictionaryWithObject:postItems 
                                                      forKey:kPostItemResultsKey]]; 
    
    //NSLog(@"end addPostItemsToList()");

}


- (void)dealloc {
    [postItemData release];
    
    [currentPostItemObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    [dateFormatter release];
    
    [super dealloc];
}
 */

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [currentParsedCharacterData release];
    [workingArray release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

/*
- (void)parser:(NSXMLParser *)parser 
                   didStartElementOLDVERSION:(NSString *)elementName
                      namespaceURI:(NSString *)namespaceURI
                     qualifiedName:(NSString *)qName
                        attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfPostItemToParse, abort the parse.
    //
    if (parsedPostItemCounter >= kMaximumNumberOfPostItemToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        //
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kItemElementName]) {
        PostItem *item = [[PostItem alloc] init];
        self.currentPostItemObject = item;
        [item release];
    } else if (
               [elementName isEqualToString:kSellItemElementName] ||               
               [elementName isEqualToString:kItemIdElementName] ||                 
               [elementName isEqualToString:kUsernameElementName] ||
               [elementName isEqualToString:kUserfullnameElementName] ||
               [elementName isEqualToString:kItemNameElementName] 
               [elementName isEqualToString:kCategoryElementName] ||
               [elementName isEqualToString:kDatePostedElementName] ||
               [elementName isEqualToString:kDescriptionElementName] ||
               [elementName isEqualToString:kPriceOfferElementName] ||
               [elementName isEqualToString:kPriceAskMinElementName] ||
               [elementName isEqualToString:kPriceAskMaxElementName] ||
               [elementName isEqualToString:kCurrencyMinElementName] ||
               [elementName isEqualToString:kLocationMaxElementName] ||
               [elementName isEqualToString:kLongitudeMaxElementName] ||
               [elementName isEqualToString:kLatitudeMaxElementName] ||  
               [elementName isEqualToString:kImageLinkMaxElementName] || 
               [elementName isEqualToString:kDeliveryElementName]
               ) {
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        
        [currentParsedCharacterData setString:[NSString stringWithFormat:@" %d ",parsedPostItemCounter]];
    }
}
 */


- (void)parser:(NSXMLParser *)parser 
            didStartElement:(NSString *)elementName
               namespaceURI:(NSString *)namespaceURI
              qualifiedName:(NSString *)qName
                 attributes:(NSDictionary *)attributeDict {

    
    if (parsedPostItemCounter >= kMaximumNumberOfPostItemToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        //
        didAbortParsing = YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kItemElementName]) {
        PostItem *item = [[PostItem alloc] init];
        self.workingEntry = item;
        [item release];
        
    } 
    storingCharacterData = [elementsToParse containsObject:elementName];  
    //[workingPropertyString setString:[NSString stringWithFormat:@" %d ",parsedPostItemCounter]];
    
}


/* OLD VERSION 
//While finding the end tag 
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName { 
    
    if ([elementName isEqualToString:kItemElementName]) {
        //NSLog([NSString stringWithFormat:@"%@",self.currentPostItemObject.itemName]);
        [self.currentParseBatch addObject:self.currentPostItemObject];
        int _ci = self.currentParseBatch.count-1;        
        PostItem *i = [self.currentParseBatch objectAtIndex:_ci];
        NSLog(@"ParseOperation.didEndElement (%d): %@",_ci,i.itemName);
        i = nil;
        
        parsedPostItemCounter++;
        if ([self.currentParseBatch count] >= kMaximumNumberOfPostItemToParse) {
            NSLog(@"... masuk");
            
            PostItem *i = [self.currentParseBatch objectAtIndex:0];
            NSLog(@"ParseOperation.addPostItemToList (1): %@",i.itemName);   
            i = nil;
            [self performSelectorOnMainThread:@selector(addPostItemsToList:)
                                   withObject:self.currentParseBatch
                                waitUntilDone:NO];
            //[self addPostItemsToList:self.currentParseBatch];
            self.currentParseBatch = [NSMutableArray array];
        }
        self.currentPostItemObject = nil;
    } else if ([elementName isEqualToString:kItemNameElementName]) {
        
        self.currentPostItemObject.itemName = self.currentParsedCharacterData;
        
    } else if ([elementName isEqualToString:kUsernameElementName]) {
        
        self.currentPostItemObject.username = self.currentParsedCharacterData;
        
    } else if ([elementName isEqualToString:kUserfullnameElementName]) {
        
        self.currentPostItemObject.fullname = self.currentParsedCharacterData;        
        
    } else if ([elementName isEqualToString:kCategoryElementName]) {
        
        self.currentPostItemObject.category = self.currentParsedCharacterData;        
        
    } else if ([elementName isEqualToString:kDescriptionElementName]) {
        
        self.currentPostItemObject.description = self.currentParsedCharacterData;        
        
    } else if ([elementName isEqualToString:kLocationMaxElementName]) {
        
        self.currentPostItemObject.location = self.currentParsedCharacterData;        
        
    } else if ([elementName isEqualToString:kDeliveryElementName]) {
        
        self.currentPostItemObject.delivery = self.currentParsedCharacterData;        
        
    } 
    
    else if ([elementName isEqualToString:kLongitudeMaxElementName]) {
        
        self.currentPostItemObject.longitude = [self.currentParsedCharacterData doubleValue];
        
    } else if ([elementName isEqualToString:kLatitudeMaxElementName]) {
        
        self.currentPostItemObject.latitude = [self.currentParsedCharacterData doubleValue]; 
        
    } else if ([elementName isEqualToString:kPriceOfferElementName]) {
        
        self.currentPostItemObject.priceOffer = [self.currentParsedCharacterData doubleValue];        
        
    } else if ([elementName isEqualToString:kPriceAskMaxElementName]) {
        
        self.currentPostItemObject.priceAskMax = [self.currentParsedCharacterData doubleValue];        
        
    } else if ([elementName isEqualToString:kPriceAskMinElementName]) {
        
        self.currentPostItemObject.priceAskMin = [self.currentParsedCharacterData doubleValue];        
        
    } 
    
    else if ([elementName isEqualToString:kDatePostedElementName]) {
        self.currentPostItemObject.datePosted = [NSDate dateWithTimeIntervalSince1970:
                                                 [currentParsedCharacterData doubleValue]];
    }
    
    //NSLog([NSString stringWithFormat:@"--> %@ dan Item Name: %@",
    //       currentParsedCharacterData, self.currentPostItemObject.itemName]);
    
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}
 */




- (void)parser:(NSXMLParser *)parser 
                                 didEndElement:(NSString *)elementName
                                  namespaceURI:(NSString *)namespaceURI
                                 qualifiedName:(NSString *)qName { 
    
    if (self.workingEntry) 
    {
        if (storingCharacterData)
        {
            NSString *trimmedString = [currentParsedCharacterData stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];            
            [currentParsedCharacterData setString:@""];  // clear the string for next time
            
            if ([elementName isEqualToString:kItemNameElementName]) {
                
                self.workingEntry.itemName = trimmedString;
                
            } else if ([elementName isEqualToString:kItemStreamId]) {
                
                self.workingEntry.streamId = (NSInteger *)[trimmedString integerValue];
                
            } else if ([elementName isEqualToString:kItemIdElementName]) {
                
                self.workingEntry.itemId = (NSInteger *)[trimmedString integerValue];
                
            } else if ([elementName isEqualToString:kUsernameElementName]) {
                
                self.workingEntry.username = trimmedString;
                
            } else if ([elementName isEqualToString:kUserfullnameElementName]) {
                
                self.workingEntry.fullname = trimmedString;        
                
            } else if ([elementName isEqualToString:kCategoryElementName]) {
                
                self.workingEntry.category = trimmedString;        
                
            } else if ([elementName isEqualToString:kDescriptionElementName]) {
                
                self.workingEntry.description = trimmedString;        
                
            } else if ([elementName isEqualToString:kLocationMaxElementName]) {
                
                self.workingEntry.location = trimmedString;        
                
            } else if ([elementName isEqualToString:kDeliveryElementName]) {
                
                self.workingEntry.delivery = trimmedString;        
                
            } else if ([elementName isEqualToString:kCurrencyMinElementName]) {
                
                self.workingEntry.currency = trimmedString;        
                
            } 
            
            else if ([elementName isEqualToString:kLongitudeMaxElementName]) {
                
                self.workingEntry.longitude = [trimmedString doubleValue];
                
            } else if ([elementName isEqualToString:kLatitudeMaxElementName]) {
                
                self.workingEntry.latitude = [trimmedString doubleValue]; 
                
            } else if ([elementName isEqualToString:kPriceOfferElementName]) {
                
                self.workingEntry.priceOffer = [trimmedString doubleValue];        
                
            } else if ([elementName isEqualToString:kPriceAskMaxElementName]) {
                
                self.workingEntry.priceAskMax = [trimmedString doubleValue];        
                
            } else if ([elementName isEqualToString:kPriceAskMinElementName]) {
                
                self.workingEntry.priceAskMin = [trimmedString doubleValue];        
            
            } else if ([elementName isEqualToString:kImageLinkElementName]) {
                
                if (![trimmedString isEqualToString:kURL_DEFAULT]) {
                    self.workingEntry.itemImageURL = [NSURL URLWithString:trimmedString];        
                }
                
            } 
            
            else if ([elementName isEqualToString:kDatePostedElementName]) {
                self.workingEntry.datePosted = [NSDate dateWithTimeIntervalSince1970:
                                                         [currentParsedCharacterData doubleValue]];
            }
            

        }
        else if ([elementName isEqualToString:kItemElementName])
        {
            [self.workingArray addObject:self.workingEntry];  
            self.workingEntry = nil;
            parsedPostItemCounter++;
        }
            
    }
}







// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    /* OLD VERSION 
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
     */
    if (storingCharacterData)
    {
        [currentParsedCharacterData appendString:string];
    }    
}


// an error occurred while parsing the earthquake data,
// post the error as an NSNotification to our app delegate.
// 
- (void)handlePostItemError:(NSError *)parseError 
{
    /*
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:kPostItemErrorNotif
                      object:self
                    userInfo:[NSDictionary dictionaryWithObject:parseError
                                                forKey:kPostItemsMsgErrorKey]];
     */
}


// an error occurred while parsing the earthquake data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of earthquakes)
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    /* OLD VERSION 
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handlePostItemError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
     */
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [delegate parseErrorOccurred:parseError];
    }        
}

@end

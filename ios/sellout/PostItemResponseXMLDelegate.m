//
//  PostItemResponseXMLDelegate.m
//  Recall
//
//  Created by Pandu Pradhana on 11/26/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import "PostItemResponseXMLDelegate.h"
#import "PostItemRequest.h"


static NSString* kElementISell = @"ISELL";

@implementation PostItemResponseXMLDelegate

@synthesize currentParsedCharacterData;
@synthesize request;
@synthesize data;

#pragma mark -
#pragma mark NSXMLParser delegate methods


- (id) initWithParent:(PostItemRequest *)parent data:(NSData *) aData
{
    self = [super init];
    if (self) {
        [self setRequest:parent];
        [self setData:aData];
    }
    return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    
    if ([elementName isEqualToString:kElementISell]) {
        [self.request setPostedSuccess:TRUE];
        currentParsedCharacterData = [NSMutableString stringWithFormat:@""];
    } 
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName { 
    
    if([self.request postedSuccess]) {
        if ([elementName isEqualToString:@"ID"]) {
            self.request.postedId =  
                    [currentParsedCharacterData stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            currentParsedCharacterData = nil;
        }
    }
    
}


// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if ([self.request postedSuccess]) {
        [currentParsedCharacterData appendString:string];
    }    
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    //if (DEBUG) NSLog(@"Error: %@",[parseError description]);
    self.request.errorXmlParsing = parseError;
}


/**
 * The main part is here
 *
 */
- (id) do_parse 
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];    
    //if (DEBUG) NSLog(@"Start parsing...");
    [parser parse];
    //if (DEBUG) NSLog(@"End parsing...");
}



/**
 * Free internal structure
 */
- (void)dealloc {
    [currentParsedCharacterData release];
    [data release];
    [request release];
    [super dealloc];
}


@end

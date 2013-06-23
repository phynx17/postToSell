//
//  ParseOperation.h
//  Recall
//
//  Created by Pandu Pradhana on 11/15/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kAddPostItemsNotif;
extern NSString *kPostItemResultsKey;

extern NSString *kPostItemErrorNotif;
extern NSString *kPostItemsMsgErrorKey;

@class PostItem;


@protocol ParseOperationDelegate;


@interface ParseOperation : NSOperation<NSXMLParserDelegate> {
    
@private    
    id <ParseOperationDelegate> delegate;    
    /*
     OLD version 
    NSDateFormatter *dateFormatter;
    NSData *postItemData;
    PostItem *currentPostItemObject;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    */
    NSUInteger parsedPostItemCounter;

    
    NSData          *dataToParse;    
    NSMutableArray  *workingArray;
    PostItem        *workingEntry;
    NSMutableString  *currentParsedCharacterData;
    NSArray         *elementsToParse;
    BOOL            storingCharacterData;    
    BOOL            didAbortParsing;
}


- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate;

@end



@protocol ParseOperationDelegate
- (void)didFinishParsing:(NSArray *)appList;
- (void)parseErrorOccurred:(NSError *)error;
@end



//
//  PostItemResponseXMLDelegate.h
//  Recall
//
//  Created by Pandu Pradhana on 11/26/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostItemRequest.h"

@interface PostItemResponseXMLDelegate : NSObject<NSXMLParserDelegate> {
    NSMutableString  *currentParsedCharacterData;
    NSData *data;
    PostItemRequest *request;
}

@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) PostItemRequest *request;
@property (nonatomic, retain) NSData *data;

- (id) initWithParent:(PostItemRequest *)parent data:(NSData *) aData;
- (id) do_parse ;

@end

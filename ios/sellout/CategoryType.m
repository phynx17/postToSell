//
//  CategoryType.m
//  Recall
//
//  Created by Pandu Pradhana on 11/21/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import "CategoryType.h"

@implementation CategoryType

@synthesize categoryId;
@synthesize name;

- (id) initWithId:(int)aCategoryId name:(NSString *)aName {
    self = [super init]; 
    if (self) {
        self.categoryId = aCategoryId;
        self.name = aName;
    }
    return self;    
}

- (void)dealloc {
    //[categoryId release];
    [name release];
    [super dealloc];
}

@end

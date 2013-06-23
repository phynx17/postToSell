//
//  PostItem.m
//  Recall
//
//  Created by Pandu Pradhana on 11/15/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import "PostItem.h"

@implementation PostItem

@synthesize streamId;
@synthesize itemId;
@synthesize username;
@synthesize fullname;
@synthesize category;
@synthesize itemName;
@synthesize description;
@synthesize itemImageURL;
@synthesize datePosted;
@synthesize itemImage;

@synthesize currency;
@synthesize location;
@synthesize delivery;

@synthesize priceOffer;
@synthesize priceAskMin;
@synthesize priceAskMax;
@synthesize latitude;
@synthesize longitude;
@synthesize sold;



- (void)dealloc {
    [username release];
    [fullname release];
    [category release];
    [itemName release];
    [itemImageURL release];
    [itemImage release];
    [description release];
    [datePosted release];
    
    [currency release];
    [location release];
    [delivery release];

    [super dealloc];
}


@end

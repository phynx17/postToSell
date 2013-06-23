//
//  PostItem.h
//  Recall
//
//  Created by Pandu Pradhana on 11/15/11.
//  Copyright 2011 Codejawa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PostItem : NSObject {
@private
    //CGFloat magnitude;
    NSInteger *streamId;    
    NSInteger *itemId;
    NSString *username;
    NSString *fullname;
    NSString *category;
    NSString *itemName;
    NSString *description;
    NSDate *datePosted;
    NSURL *itemImageURL;    
    UIImage *itemImage;
    
    NSString *currency;
    NSString *location;
    NSString *delivery;    
    double priceOffer;    
    double priceAskMin;    
    double priceAskMax;    
    double latitude;
    double longitude;
    BOOL sold;   
}


@property (nonatomic, assign) NSInteger *itemId;
@property (nonatomic, assign) NSInteger *streamId;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *itemName;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSURL *itemImageURL;
@property (nonatomic, retain) UIImage *itemImage;

@property (nonatomic, retain) NSDate *datePosted;

@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *delivery;

@property (nonatomic, assign) double priceOffer;
@property (nonatomic, assign) double priceAskMin;
@property (nonatomic, assign) double priceAskMax;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) BOOL sold;


@end

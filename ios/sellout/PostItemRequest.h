//
//  PostItemRequest.h
//  Recall
//
//  Created by Pandu Pradhana on 11/25/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PostItemRequestDelegate;

@interface PostItemRequest : NSObject {
    
    id<PostItemRequestDelegate> delegate;
    NSURLConnection *apiURLConnection;
    NSMutableDictionary *params;
    NSMutableData *responseText;
    
    int requestType;
    BOOL postedSuccess;
    
@private    
    NSError *errorXmlParsing;
}

@property(nonatomic,assign) id<PostItemRequestDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *apiURLConnection;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSMutableData *responseText;
@property (nonatomic, retain) NSString *postedId;
@property (nonatomic, retain) NSError *errorXmlParsing;


@property (nonatomic, assign) int requestType;
@property (nonatomic, assign) BOOL postedSuccess;




+ (PostItemRequest*) getRequestWithParams:(NSMutableDictionary *) params
                                 delegate:(id<PostItemRequestDelegate>)delegate
                              requestType:(int) requestType;

- (BOOL) loading;
- (void) sendRequest;

@end


enum tApiSendRequest {
    PostItemRequest_Upload_Image = 1,
    PostItemRequest_Upload_Data = 2
};


////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate
 */
@protocol PostItemRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(PostItemRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(PostItemRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(PostItemRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(PostItemRequest *)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(PostItemRequest *)request didLoadRawResponse:(NSData *)data;

@end

//
//  PostItemRequest.m
//  Recall
//
//  The code is inspired by 
//    https://github.com/facebook/facebook-ios-sdk/blob/master/src/FBRequest.m#L109-165
//
//  Created by Pandu Pradhana on 11/25/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import "PostItemRequest.h"
#import "Constant.h"
#import "PostItemResponseXMLDelegate.h"



///////////////////////////////////////////////////////////////////////////////////////////////////
// Global Config

static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static const int kGeneralErrorCode = 10000;

static const NSTimeInterval kTimeoutInterval = 180.0;




// Forward declarations
@interface PostItemRequest()
- (NSString *)generateURL;
- (NSMutableData *)generatePostBody;
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data;
- (void)failWithError:(NSError *)error;
- (id)parseXmlResponse:(NSData *)data error:(NSError **)error;
- (void)handleResponseData:(NSData *)data;

//Debug purpose
- (void) printNSData:(NSData *)data;

@end



@implementation PostItemRequest


@synthesize apiURLConnection;
@synthesize params;
@synthesize responseText;
@synthesize delegate;
@synthesize requestType;
@synthesize postedId;
@synthesize postedSuccess;
@synthesize errorXmlParsing;


/**
 * Generate URL 
 */
- (NSString *)generateURL {
    return [NSString stringWithFormat:@"%@/postsellupload?api_key=2c002a",SERVER_URL_API];    

    if (requestType == PostItemRequest_Upload_Data) {
        return [NSString stringWithFormat:@"%@/postsell?api_key=2c002a",SERVER_URL_API];
    } else {
        return [NSString stringWithFormat:@"%@/upload_image?api_key=2c002a",SERVER_URL_API];
    }
}


/**
 * Body append for POST method
 */
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
    [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}


/**
 * Generate body for POST method
 */
- (NSMutableData *)generatePostBody {
    NSMutableData *body = [NSMutableData data];
    NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];
    
    for (id key in [params keyEnumerator]) {
        
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            
            //NSLog([NSString stringWithFormat:@"Masuk --> %@",key]);
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
            
        }
        
        [self utfAppendBody:body
                       data:[NSString
                             stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                             key]];
        [self utfAppendBody:body data:[params valueForKey:key]];        
        [self utfAppendBody:body data:endLine];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            if ([dataParam isKindOfClass:[UIImage class]]) {
                NSData* imageData = UIImagePNGRepresentation((UIImage*)dataParam);
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:
                                     @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key,@"photoupload.png"]];
                [self utfAppendBody:body
                               data:[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"]];
                [body appendData:imageData];
            } else {
                /**
                 * Is never go to this block :p
                 *
                 */
                NSAssert([dataParam isKindOfClass:[NSData class]],
                         @"dataParam must be a UIImage or NSData");
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:
                                     @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
                [self utfAppendBody:body
                               data:[NSString 
                                     stringWithString:@"Content-Type: content/unknown\r\n\r\n"]];
                [body appendData:(NSData*)dataParam];
            }
            [self utfAppendBody:body data:endLine];
            
        }
    }
    
    [self printNSData:body];
    
    return body;
}


/*
 * private helper function: call the delegate function when the request
 *                          fails with error
 */
- (void)failWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [delegate request:self didFailWithError:error];
    } else {
        if (DEBUG) {
            NSLog(@"ERROR while posting: --> %@",[error description]);    
        }
    }
}


/*
 * private helper function: handle the response data
 */
- (void)handleResponseData:(NSData *)data {

    
    if ([delegate respondsToSelector:
         @selector(request:didLoadRawResponse:)]) {
        [delegate request:self didLoadRawResponse:data];
    }
    
    if ([delegate respondsToSelector:@selector(request:didLoad:)] ||
        [delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            NSError* error = nil;
            id result = [self parseXmlResponse:data error:&error];
            //[self parseXmlResponse:data error:&error];
            if (error) {
                [self failWithError:error];
            } else if ([delegate respondsToSelector:@selector(request:didLoad:)]) {
                [delegate request:self didLoad:(result == nil ? data : result)];
            }
            //[delegate request:self didLoad:nil];
            //result = nil;
            
        }
    
}



#pragma mark -
#pragma mark NSURLConnection delegate methods

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {\
    responseText = [[NSMutableData alloc] init];    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([delegate respondsToSelector:
         @selector(request:didReceiveResponse:)]) {
        [delegate request:self didReceiveResponse:httpResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseText appendData:data];
    if (DEBUG) {
        [self printNSData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    
    if (DEBUG) {
        NSString *thdata = 
                [[NSString alloc] initWithData:responseText encoding:NSASCIIStringEncoding];
        NSLog(@"Data : %@",thdata); 
        [thdata release];     
    }
    
    [self handleResponseData:responseText];
    [responseText release];
    responseText = nil;
    [apiURLConnection release];    
    apiURLConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    [self failWithError:error];    
    [responseText release];
    responseText = nil;
    [apiURLConnection release];
    apiURLConnection = nil;
}




- (void) printNSData:(NSData *)data {
    /*
    NSString *thdata = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog([NSString stringWithFormat:@"Data : %@",thdata]); 
    [thdata release];   
     */
}


/**
 * parse the response data
 */
- (id)parseXmlResponse:(NSData *)data error:(NSError **)error {
    
    if (DEBUG) {
        [self printNSData:data];
    }

    postedId = nil;
    
    PostItemResponseXMLDelegate *parser = 
        [[PostItemResponseXMLDelegate alloc] initWithParent:self data:data];
    
    [parser do_parse];
    
    /*
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }    
    self.dataToParse = nil;
    self.workingArray = nil;
     */
    
    
    if(!postedId) {
        if (errorXmlParsing) {
            error = &errorXmlParsing;
        } else {
            /*
             
             From APPLE
             // Make underlying error.
             NSError *underlyingError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain
             code:errno userInfo:nil] autorelease];
             // Make and return custom domain error.
             NSArray *objArray = [NSArray arrayWithObjects:description, underlyingError, path, nil];
             NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
             NSUnderlyingErrorKey, NSFilePathErrorKey, nil];
             NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray
             forKeys:keyArray];
             
             *anError = [[[NSError alloc] initWithDomain:MyCustomErrorDomain
             code:errCode userInfo:eDict] autorelease];
            */
            

             *error = [[[NSError alloc] initWithDomain:@"XMLError"
                                                  code:100 userInfo:nil] autorelease];
        }
    }
    
    NSLog(@"Posted Id: %@",postedId);
    [parser release];

    return nil;
    
}



#pragma mark -
#pragma mark PUBLIC methods

//////////////////////////////////////////////////////////////////////////////////////////////////
// PUBLIC methods

+ (PostItemRequest*) getRequestWithParams:(NSMutableDictionary *) params
                                 delegate:(id<PostItemRequestDelegate>)delegate
                              requestType:(int) requestType{
    
    PostItemRequest* request = [[[PostItemRequest alloc] init] autorelease];
    request.delegate = delegate;
    request.params = params;
    request.requestType = requestType;
    request.apiURLConnection = nil;
    request.responseText = nil;
    request.postedSuccess = FALSE;
    
    return request;    
}


- (BOOL) loading {
    return !!apiURLConnection;
}


- (void) sendRequest {
    if ([delegate respondsToSelector:@selector(requestLoading:)]) {
        [delegate requestLoading:self];
    }    
    NSString* url = [self generateURL];
    
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:kTimeoutInterval];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    NSString* contentType = [NSString
                             stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[self generatePostBody]];
    [request setHTTPMethod:@"POST"];

    if (DEBUG) {
        NSLog(@"PostItemRequest.sendRequest...");
    }
    apiURLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}






/**
 * Free internal structure
 */
- (void)dealloc {
    NSLog(@"Dealloc...");
    [postedId release];
    if (apiURLConnection) {
        [apiURLConnection cancel];
        [apiURLConnection release];        
    }
    [errorXmlParsing release];    
    [responseText release];
    [params release];
    [super dealloc];
}



@end

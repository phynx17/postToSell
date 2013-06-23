//
//  CategoryType.h
//  Recall
//
//  Created by Pandu Pradhana on 11/21/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryType : NSObject {
    int categoryId;
    NSString *name;
}

@property (nonatomic, assign) int categoryId;
@property (nonatomic, retain) NSString *name;

- (id) initWithId:(int)categoryId name:(NSString*)name;

@end

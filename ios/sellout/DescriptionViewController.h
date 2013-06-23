//
//  DescriptionViewController.h
//  Recall
//
//  Created by Pandu Pradhana on 11/23/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostItemViewController.h"

@interface DescriptionViewController : UIViewController<UITextViewDelegate> {
    UITextView *textView;
    @private
        NSString *description;
        PostItemViewController *viewCaller;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) PostItemViewController *viewCaller;



@end

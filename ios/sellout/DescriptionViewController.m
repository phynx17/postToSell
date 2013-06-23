//
//  DescriptionViewController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/23/11.
//  Copyright (c) 2011 Codejawa. All rights reserved.
//

#import "DescriptionViewController.h"


@implementation DescriptionViewController

@synthesize description;
@synthesize viewCaller;
@synthesize textView;


- (id)initWithStyle:(UITableViewStyle)style
{
    //self = [super initWithStyle:style];
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.view.backgroundColor = 
    [UIColor colorWithPatternImage:
     [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"background1.png"]]];    
    
    self.navigationItem.title = @"Description";    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    textView.font = viewCaller.descriptionField.font;
    textView.delegate = self;
    [self.view addSubview:textView];
    
    [self.viewCaller setHidesBottomBarWhenPushed:FALSE];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark <UITextViewDelegate> Methods


- (void)textViewDidEndEditing:(UITextView *)aTextView 
{
    [self.viewCaller.descriptionField setText:textView.text];    
	[aTextView resignFirstResponder];
    
}



- (void)dealloc
{
    [textView release];    
    [viewCaller release];
    [super dealloc];
}


@end

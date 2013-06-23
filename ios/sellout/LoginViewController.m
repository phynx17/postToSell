//
//  LoginViewController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/13/11.
//  Copyright 2011 PhynxSoft. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController

@synthesize loginField=_loginField;
@synthesize passwordField=_passwordField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [loginField dealloc];
    [passwordField dealloc];
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
    [super viewDidLoad];
    NSLog(@"TESSS");
    //_loginField.delegate = self;
    //[_passwordField setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}


/* The implementation */

- (IBAction)cancel:(id)sender 
{
    
}
- (IBAction)login:(id)sender 
{
    NSLog(@"TESSS");
}


#pragma mark -
#pragma mark <UITextFieldDelegate> Methods


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"TESSS WOIII %@",[textField text]);
	[textField resignFirstResponder];
    /*
    if (textField == self.loginField) {
        [textField resignFirstResponder];
    }*/   
    return YES;
}




@end

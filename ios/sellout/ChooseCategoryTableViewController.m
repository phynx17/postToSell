//
//  ChooseCategoryTableViewController.m
//  Recall
//
//  Created by Pandu Pradhana on 11/21/11.
//  Copyright (c) 2011 PhynxSoft. All rights reserved.
//

#import "ChooseCategoryTableViewController.h"
#import "CategoryType.h"

//Defaut Cell Height is 44pixels
#define DEFAULT_CELL_HEIGHT 44



@interface ChooseCategoryTableViewController () 
    - (void) addCategory:(int)categoryId name:(NSString*)name;
@end

@implementation ChooseCategoryTableViewController

@synthesize listOfcategoryTypes;
@synthesize tableView;
@synthesize category;
@synthesize viewCaller;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self setNavigationController:[[UINavigationController alloc] init]];
        
        //self.tableView = [[UITableView alloc] init];
                
        //CGFloat height = (CGFloat) DEFAULT_CELL_HEIGHT*listOfcategoryTypes.count;
        //NSLog(@"%d",height);
        self.tableView =[[UITableView alloc]                          
                         
                         initWithFrame:CGRectMake(
                                                  0, 
                                                  0, 
                                                  320, 
                                                  400) 
                         
                         //initWithFrame: [[UIScreen mainScreen] applicationFrame]
                         style:UITableViewStyleGrouped];
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
        
        //CGRect frame = [[UIScreen mainScreen] applicationFrame];
        //NSLog([NSString stringWithFormat:@"%@",NSStringFromCGRect(frame)]);
        
        listOfcategoryTypes = [[NSMutableArray array] retain];
        
        /*
         * Set the list of category
         */
        [self addCategory:1 name:@"Antiques"];
        [self addCategory:2 name:@"Arts"];
        [self addCategory:3 name:@"Books"];
        [self addCategory:4 name:@"Baby and Kid Stuff"];
        [self addCategory:5 name:@"Business"];
        [self addCategory:6 name:@"Camera,Photography"];
        [self addCategory:7 name:@"Cars,Vehicle,Parts"];
        [self addCategory:8 name:@"Cell Phones"];
        [self addCategory:9 name:@"Collectibles"];
        [self addCategory:10 name:@"Computers"];
        [self addCategory:11 name:@"CDs and DVDs"];
        [self addCategory:12 name:@"Dolls "];
        [self addCategory:13 name:@"Electronics"];
        [self addCategory:14 name:@"Flora and Fauna"];
        [self addCategory:15 name:@"Fashion"];
        [self addCategory:16 name:@"Furniture"];
        [self addCategory:17 name:@"Gift Cards"];
        [self addCategory:18 name:@"Health and Beauty"];
        [self addCategory:19 name:@"Hardware,Tools"];
        [self addCategory:20 name:@"Jewelry,Watches"];
        [self addCategory:21 name:@"Musical Instruments"];
        [self addCategory:22 name:@"Pet Supplies"];
        [self addCategory:23 name:@"Services"];
        [self addCategory:24 name:@"Sports Equipment"];
        [self addCategory:25 name:@"Tickets"];
        [self addCategory:26 name:@"Toys and Hobbies"];
        [self addCategory:27 name:@"Travel"];
        [self addCategory:28 name:@"TV,Video, Audio"];
        [self addCategory:29 name:@"Video Games"];
        [self addCategory:30 name:@"Everything Else"];    
        
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
    //NSLog([NSString stringWithFormat:@"viewDidLoad:initChoose-> %@",self.view]);

    self.view.backgroundColor = 
    [UIColor colorWithPatternImage:
     [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"background1.png"]]];    
    tableView.backgroundColor = [UIColor clearColor];
        
    self.navigationItem.title = @"Category";

    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    [tableView reloadData];
    
    [self.view addSubview:[self tableView]];
    [tableView release];

    //This is a must!
    [self.viewCaller setHidesBottomBarWhenPushed:FALSE];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    //NSLog(@"ChooseCategory.dealloc()");
    [listOfcategoryTypes release];
    [viewCaller release];
    [category release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 
    [[self tableView] reloadData];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewCaller setHidesBottomBarWhenPushed:FALSE];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [listOfcategoryTypes count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //NSLog(@"going cellForRowAtIndexPath");        
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    CategoryType *type = [self.listOfcategoryTypes objectAtIndex:indexPath.row];
    if (type != nil) {
        cell.textLabel.text = type.name;
    }
    /*
    NSLog(@"going cellForRowAtIndexPath:2");            
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Antiques";
    } else {
        cell.textLabel.text = @"Everything Els";
    }
    
    NSLog(@"going cellForRowAtIndexPath:3");  
     */
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryType *type = [self.listOfcategoryTypes objectAtIndex:indexPath.row];
    if (type != nil) {
        viewCaller.category = type;
        viewCaller.categoryField.text = type.name;
    }    
    
    // Set the checkmark accessory for the selected row.
    [[self.tableView cellForRowAtIndexPath:indexPath] 
        setAccessoryType:UITableViewCellAccessoryCheckmark];    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissModalViewControllerAnimated:TRUE];		
}




#pragma mark - PRIVATES
- (void) addCategory:(int)categoryId 
                name:(NSString*)name {
    CategoryType *cat = [[CategoryType alloc] initWithId:categoryId name:name];
    [listOfcategoryTypes addObject:cat];
    [cat release];
}


@end

//
//  ContactAddViewController.m
//  CatchMe
//
//  Created by Brian Mo on 11/23/12.
//  Copyright (c) 2012 Same Level Software. All rights reserved.
//

#import "ContactAddViewController.h"
#import "ContactsListViewController.h"
#import "ContactEdit.h"

@interface ContactAddViewController ()

@end

@implementation ContactAddViewController

@synthesize nameField = _namefield;
@synthesize numberField = _numberField;
@synthesize emailField = _emailField;
@synthesize contactListView = _contactListView;

@synthesize emailOn = _emailOn;
@synthesize phoneOn = _phoneOn;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)doneButton:(id)sender {
    ContactEdit *newContact = [[ContactEdit alloc]initWithName:self.nameField.text number:self.numberField.text email:self.emailField.text];
    
    [self.contactListView.contacts addObject:newContact];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [self.contactListView.tableView reloadData];
    
}

@end

//
//  DetailViewController.m
//  projet_iphone
//
//  Created by Projet4a on 22/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import "DetailViewController.h"
#import "TaskViewController.h"
#import "Task.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
}

- (void)configureView {			
    [[self addTaskButton] setHidden:YES];
    
    _projectDescription.layer.borderWidth = 0.5f;
    _projectDescription.layer.borderColor = [[UIColor grayColor] CGColor];
    _projectDescription.layer.cornerRadius = 5.0f;
    
    self.projectTitle.delegate = self;
    self.projectDescription.delegate = self;
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectDescription.text = [[self.detailItem valueForKey:@"describe"] description];
        
        [[self addTaskButton] setHidden:NO];
        
        tasks = [[self.detailItem valueForKey:@"tasks"] allObjects];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tasks count];
}

-(NSInteger) numberOfTasksInList
{
    return [tasks count];
}

-(Task*) taskAtIndex: (NSInteger) index
{
    return [tasks objectAtIndex:index] ;
}

- (void) setIsNew:(int)newIsNew {
    isNew = newIsNew;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    Task * task = [self taskAtIndex: indexPath.row];
    
    [self configureCell:cell withTaskObject:task];
    
    return cell;
}

- (IBAction)saveButton:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *project = nil;
    
    if (isNew) {
        project = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Project"
                                    inManagedObjectContext:context];
    } else {
        project = self.detailItem;
    }
    
    [project setValue:[[self projectTitle] text] forKey:@"title"];
    [project setValue:[[self projectDescription] text] forKey:@"describe"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

- (IBAction)addTask:(id)sender {
    TaskViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskViewController"];
    [controller.navigationItem setTitle:@"Créer une tâche"];
    [controller setProject:self.detailItem];
    [controller setIsNew:YES];
    [controller setManagedObjectContext:[self managedObjectContext]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withTaskObject:(Task *)task {
    cell.textLabel.text = [[task valueForKey:@"title"] description];
    cell.detailTextLabel.text = [task valueForKey:@"title"];
    
    if ([[task valueForKey:@"checked"] boolValue]) {
        [cell setBackgroundColor: [UIColor greenColor]];
    } else {
        [cell setBackgroundColor: [UIColor whiteColor]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    tasks = [[self.detailItem valueForKey:@"tasks"] allObjects];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Project *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    if([[segue identifier] isEqualToString:@"TaskDetailIdentifier"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [tasks objectAtIndex:indexPath.row];
        TaskViewController *controller = (TaskViewController *)[segue destinationViewController];
        [controller setDetailItem:object];
        [controller setIsNew:NO];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}
@end

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
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    [[self addTaskButton] setHidden:YES];
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectDescription.text = [[self.detailItem valueForKey:@"describe"] description];
        
        [[self addTaskButton] setHidden:NO];
        
        tasks = [[self.detailItem valueForKey:@"tasks"] allObjects];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    Task * task = [self taskAtIndex: indexPath.row];
    
    [self configureCell:cell withTaskObject:task];
    
    return cell;
}

- (IBAction)saveButton:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *project = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Project"
                                       inManagedObjectContext:context];
    [project setValue:[[self projectTitle] text] forKey:@"title"];
    [project setValue:[[self projectDescription] text] forKey:@"describe"];
    /*[project setValue:[NSNumber numberWithInt:1] forKey:@"id"];
    NSManagedObject *failedBankDetails = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Task"
                                          inManagedObjectContext:context];
    [failedBankDetails setValue:[NSDate date] forKey:@"date_start"];
    [failedBankDetails setValue:[NSDate date] forKey:@"date_end"];
    [failedBankDetails setValue:[NSNumber numberWithInt:1] forKey:@"id"];
    [failedBankDetails setValue:@"details" forKey:@"title"];
    [failedBankDetails setValue:@"details" forKey:@"describe"];
    [failedBankDetails setValue:failedBankInfo forKey:@"project_id"];
    [project setValue:[NSSet setWithObject:failedBankDetails] forKey:@"tasks"];*/
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

- (IBAction)addTask:(id)sender {
    TaskViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskViewController"];
    [controller.navigationItem setTitle:@"Créer une tâche"];
    [controller setProject:self.detailItem];
    [controller setManagedObjectContext:[self managedObjectContext]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withTaskObject:(Task *)task {
    cell.textLabel.text = [[task valueForKey:@"title"] description];
    
    cell.detailTextLabel.text = [task valueForKey:@"title"];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
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
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}
@end

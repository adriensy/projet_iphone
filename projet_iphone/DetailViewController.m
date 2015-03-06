//
//  DetailViewController.m
//  projet_iphone
//
//  Created by Projet4a on 22/02/2015.
//  Copyright (c) 2015 Projet4a. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize fetchedResultsController = _fetchedResultsController;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"project_id == %@", self.detailItem];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date_start" ascending:YES];
    NSSortDescriptor *sortDescriptorChecked = [[NSSortDescriptor alloc] initWithKey:@"checked" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorChecked, sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)backButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)configureView {			
    [[self addTaskButton] setHidden:YES];
    [[self tableView] setHidden:YES];
    [[self titleTasksList] setHidden:YES];
    
    // Bouton valider arrondi
    CALayer *btnLayer = [[self saveButton] layer];
    [btnLayer setBorderWidth:0.5f];
    [btnLayer setBorderColor:[[UIColor blueColor] CGColor]];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    [[self saveButton] setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Titre de la page
    self.titleTasksList.topItem.title = @"Mes tâches";
    
    // Gestion bouton retour
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Retour" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _projectDescription.layer.borderWidth = 0.5f;
    _projectDescription.layer.borderColor = [[UIColor grayColor] CGColor];
    _projectDescription.layer.cornerRadius = 5.0f;
    
    self.projectTitle.delegate = self;
    self.projectDescription.delegate = self;
    
    if (self.detailItem) {
        self.navigationItem.title = @"Modifier mon projet";
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.projectDescription.text = [[self.detailItem valueForKey:@"describe"] description];
        
        [[self addTaskButton] setHidden:NO];
        [[self tableView] setHidden:NO];
        [[self titleTasksList] setHidden:NO];
    } else {
        self.navigationItem.title = @"Créer mon projet";
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
    
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) setIsNew:(int)newIsNew {
    isNew = newIsNew;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
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
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSString *) formatDate:(NSDate*)date withFormat:(NSString *) format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString * dateString = @"";
    
    [formatter setDateFormat:format];
    dateString = [formatter stringFromDate:date];
    
    return dateString;
}

- (IBAction)addTask:(id)sender {
    TaskViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskViewController"];
    [controller setProject:self.detailItem];
    [controller setIsNew:YES];
    [controller setManagedObjectContext:[self managedObjectContext]];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Task *task = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = task.title;
    
    if ([[task valueForKey:@"checked"] boolValue]) {
        [cell setBackgroundColor: [UIColor greenColor]];
        cell.detailTextLabel.text = [[NSString alloc]initWithFormat:@"Date de fin : %@", [self formatDate:task.date_end withFormat:@"dd-MM-yyyy"]];
    } else {
        [cell setBackgroundColor: [UIColor whiteColor]];
        cell.detailTextLabel.text = [[NSString alloc]initWithFormat:@"Date de début : %@", [self formatDate: task.date_start withFormat:@"dd-MM-yyyy"]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Project *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
    }
    if([[segue identifier] isEqualToString:@"TaskDetailIdentifier"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        TaskViewController *controller = (TaskViewController *)[segue destinationViewController];
        [controller setDetailItem:object];
        [controller setManagedObjectContext:self.managedObjectContext];
        [controller setIsNew:NO];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}













@end

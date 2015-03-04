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

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }
}

- (void)backButtonPressed
{
    // write your code to prepare popview
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
        
        tasks = [[self.detailItem valueForKey:@"tasks"] allObjects];
    } else {
        self.navigationItem.title = @"Créer mon prjet";
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"project_id == %@", self.detailItem.id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date_end" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
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

- (void)configureCell:(UITableViewCell *)cell withTaskObject:(Task *)task {
    cell.textLabel.text = [[task valueForKey:@"title"] description];
    
    if ([[task valueForKey:@"checked"] boolValue]) {
        [cell setBackgroundColor: [UIColor greenColor]];
        cell.detailTextLabel.text = [[NSString alloc]initWithFormat:@"Date de fin : %@", [self formatDate:[task valueForKey:@"date_end"] withFormat:@"dd-MM-yyyy"]];
    } else {
        [cell setBackgroundColor: [UIColor whiteColor]];
        cell.detailTextLabel.text = [[NSString alloc]initWithFormat:@"Date de début : %@", [self formatDate: [task valueForKey:@"date_start"] withFormat:@"dd-MM-yyyy"]];
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
    }
    if([[segue identifier] isEqualToString:@"TaskDetailIdentifier"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [tasks objectAtIndex:indexPath.row];
        TaskViewController *controller = (TaskViewController *)[segue destinationViewController];
        [controller setDetailItem:object];
        [controller setIsNew:NO];
    }
}
@end

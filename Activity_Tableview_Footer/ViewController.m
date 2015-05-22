//
//  ViewController.m
//  Activity_Tableview_Footer
//
//  Created by Vy Systems - iOS1 on 2/3/15.
//  Copyright (c) 2015 Vy Systems - iOS1. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UITableViewController+ENFooterActivityIndicatorView.h"
#import "ProductEntity.h"

@interface ViewController ()
{
    AppDelegate *appDelegate ;
    
   
}

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSInteger rowsCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //This block runs when the table view scrolled to the bottom
    __weak typeof(self) weakSelf = self; //Don't forget to make weak pointer to self
    [self setTableScrolledDownBlock:^void()
    {
        //Put here your data loading logic
        if (!weakSelf.isLoading)
            [weakSelf loadNextBatch];
    }];
    
    _rowsCount = 0;
    
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPressed:)];
    self.navigationItem.rightBarButtonItem = refreshBarButton;
    
    [self loadNextBatch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data loading logic
- (void)loadNextBatch
{
    _isLoading = YES;
    if (![self footerActivityIndicatorView])
    {
        [self addFooterActivityIndicatorWithHeight:80.f];//Add ENFooterActivityIndicatorView to tableView's footer
    }
    
    if (_rowsCount < 60)
    {
        [self performSelector:@selector(addNewData) withObject:nil afterDelay:3.3333];// I've made a little delay to imitate data loading
    }
    else
    {
        [self removeFooterActivityIndicator];
    }
}

#pragma mark - other functions
- (void)addNewData
{
    _rowsCount +=15;
    _isLoading = NO;
    [self addToCoreData];
    [self.tableView reloadData];
}

-(void)addToCoreData
{
    NSString *_fromid = [NSString stringWithFormat:@"%d" ,_rowsCount- 15];
     NSString *_toid = [NSString stringWithFormat:@"%d" ,_rowsCount-1];
    
    [self getCartProductDetails:_fromid : _toid];
    
     NSLog(@"number of coredata are %d", [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    
//    [self getCartProductDetails:@"16" : @"29"];
//    
//    NSLog(@"number of coredata are %d", [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    
    if ( [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] <= 1 )
    {
        for (int i = _rowsCount -15; i<_rowsCount; i++)
        {
            ProductEntity *_productdetails = [NSEntityDescription insertNewObjectForEntityForName:@"ProductEntity"       inManagedObjectContext:appDelegate.managedObjectContext];
            
            _productdetails.productid =[NSString stringWithFormat:@"%d",i];
            // _cartdetails.productname = [self genRandStringLength:8];
            
            _productdetails.productname = [NSString stringWithFormat:@"product%d",i];;
            
        
        }
        
        [appDelegate.managedObjectContext save:nil];  // write to database
      

        [self setupFetchedResultsController];
        
       NSLog(@"number of objects are %d", [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    }
    else
    {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductEntity" inManagedObjectContext:appDelegate. managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *info in fetchedObjects)
        {
            NSLog(@"Main Productid %@", [info valueForKey:@"productid"]);
           
            NSLog(@"Main ProductName  %@", [info valueForKey:@"productname"]);
        }
        
        [self setupFetchedResultsController];
        
        NSLog(@"number of objects are %d", [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    }

    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"rows count is %d",_rowsCount);
    return _rowsCount ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    //  NSLog(@"index path is %ld",(long)indexPath.row);
    NSIndexPath *path;
 path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];;
    
    ProductEntity  *_productdetails = [self.fetchedResultsController objectAtIndexPath:path];
    
    NSLog(@"product name is %@",_productdetails.productname);
    
    
//    cell.productname.text =  _cartdetails.productname;
//    cell.qty.text = _cartdetails.quantity;
//    cell.unitPrice.text = [NSString stringWithFormat:@"$ %@",_cartdetails.unitprice] ;
//    cell.totalPrice.text = [NSString stringWithFormat:@"$ %@",_cartdetails.totalprice] ;
    

    
//    [cell.textLabel setText:[NSString stringWithFormat:@"row #%li", (long)indexPath.row+1]];
    
    cell.detailTextLabel.text = _productdetails.productname;
    cell.textLabel.text = _productdetails.productid;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self longRunningTask];
}

-(void)longRunningTask
{
    [ENLoadingView showLoaderInView:self.navigationController.view
                        withMessage:@"authorization"
                               type:ENLoadingViewTypeModal
                          blurStyle:ENBlurStyleDark];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [ENLoadingView hideLoaderForView:self.navigationController.view];
//        
//    });
    
     dispatch_queue_t imageQueue ;
     imageQueue = dispatch_queue_create("com.company.app.imageQueue", NULL);
    dispatch_async(imageQueue, ^{
        
        [NSThread sleepForTimeInterval:4];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [ENLoadingView hideLoaderForView:self.navigationController.view];
        });
    });
}

/*
 #pragma mark - UIScrollView Delegate Methods
 //If you need to use this method in your view controller, call super
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
 [super scrollViewDidScroll:scrollView];
 
 // Your code here ..
 }
 */

#pragma mark - Event handlers
- (void)refreshPressed:(id)sender {
    //Clear loaded data
    _rowsCount = 0;
    [self.tableView reloadData];
    [self loadNextBatch];
}

#pragma mark  Get Values From CoreData
- (void)setupFetchedResultsController
{
    // 1 - Decide what Entity you want
    NSString *entityName = @"ProductEntity"; // Put your entity name here
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    //request.predicate = [NSPredicate predicateWithFormat:@"Role.name = Blah"];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"productid"                                     ascending:YES                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // 5 - Fetch it
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}


- (void)performFetch
{
    if (self.fetchedResultsController)
    {
        if (self.fetchedResultsController.fetchRequest.predicate)
        {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        }
        else
        {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    }
    else
    {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    //[self.tableView reloadData];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend)
    {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else
    {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}


#pragma mark - CoreData Functions
- (NSFetchedResultsController *)getCartProductDetails:(NSString *)_fromid : (NSString *)_toid
{
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 1 - Decide what Entity you want
    NSString *entityName = @"ProductEntity"; // Put your entity name here
    // NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
   request.predicate = [NSPredicate predicateWithFormat:@"(productid >= %@) AND (productid < %@)",_fromid,_toid];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"productid"                                     ascending:YES                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // 5 - Fetch it
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
    [self performFetch];
    
    // NSLog(@"Number of rows %lu",(unsigned long)[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    
    return self.fetchedResultsController;
}


@end

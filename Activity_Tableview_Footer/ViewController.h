//
//  ViewController.h
//  Activity_Tableview_Footer
//
//  Created by Vy Systems - iOS1 on 2/3/15.
//  Copyright (c) 2015 Vy Systems - iOS1. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <coredata/coredata.h>
#import "ENLoadingView.h"
@interface ViewController : UITableViewController

{
    
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL debug;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@end


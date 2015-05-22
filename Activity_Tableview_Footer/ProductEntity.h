//
//  ProductEntity.h
//  Activity_Tableview_Footer
//
//  Created by Vy Systems - iOS1 on 2/3/15.
//  Copyright (c) 2015 Vy Systems - iOS1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProductEntity : NSManagedObject

@property (nonatomic, retain) NSString * productid;
@property (nonatomic, retain) NSString * productname;

@end

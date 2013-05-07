//
//  DataAccessor.h
//  TheCount
//
//  Created by Ryan Maxwell on 11/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAccessor : NSObject 
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataAccessor *)sharedDataAccessor;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

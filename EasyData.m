//
//  EasyData.m
//  EasyData
//
//  Created by Benjamin Martin on 5/24/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import "EasyDataInitializer.h"

typedef enum {insert, retrieve} type;

@implementation EasyDataInitializer

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)insertObjectOfType:(id)className withValues:(NSDictionary*)values {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([className class]) inManagedObjectContext:context];

    // Get all keys in the dictionary
    // Call entity setValue forKey
//    for (id object in values key) {
//
//    }
}

- (id)retrieveObjectOfType:(id)className withAttribute:(id)attribute equalTo:(id)value {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([className class])];
    
    // Can I insert a string value into a predicate as I've done below?
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", attribute, value];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    return [[context executeFetchRequest:request error:&error] objectAtIndex:0];
}

- (id)updateObjectOfType:(id)className withAttribute:(id)attribute equalTo:(id)value withNewValues:(NSDictionary*)values {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([className class])];
    
    // Can I insert a string value into a predicate as I've done below?
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", attribute, value];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    id object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];

    // Get all keys in the dictionary and update the object's values with the key-value pairings.
    // Call entity setValue forKey
    //    for (id object in values key) {
    //
    //    }
    
    [self saveContext];
    return object;
}

- (id)deleteObjectOfType:(id)className withAttribute:(id)attribute equalTo:(id)value {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([className class])];
    
    // Can I insert a string value into a predicate as I've done below?
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", attribute, value];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    id object = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
    
    [context deleteObject:object];
    [self saveContext];
    
    return object;
}

- (void)deleteAllObjectsOfType:(id)className {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([className class])];
    
    NSError *error;
    for (id object in [context executeFetchRequest:request error:&error]) {
        [context deleteObject:object];
    }
    [self saveContext];
}

- (BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            return NO;
        }
    }
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - createFetchedResultsController

// Need the class name and key to sort the rc with
- (NSFetchedResultsController *)createFetchedResultsControllerForClass:(id)className sortedByKey:keyName withBatchSize:(NSUInteger)batchSize
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([className class])
                inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:batchSize];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyName
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context
                                          sectionNameKeyPath:@"title"
                                                   cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Error handling
	}
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods



@end
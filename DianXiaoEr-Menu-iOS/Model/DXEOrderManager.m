//
//  DXEOrderManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderManager.h"
#import "DXEDishItem.h"

@interface DXEOrderManager ()

@end

@implementation DXEOrderManager

+ (DXEOrderManager *)sharedInstance
{
    static DXEOrderManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
        
        sharedManager.totalCount = 0;
        sharedManager.cartList = [[NSMutableArray alloc] init];
        sharedManager.todoList = [[NSMutableArray alloc] init];
        sharedManager.doingList = [[NSMutableArray alloc] init];
        sharedManager.doneList = [[NSMutableArray alloc] init];
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - Proxy for KVO

- (NSMutableArray *)cart
{
    return [self mutableArrayValueForKey:@"cartList"];
}

- (NSMutableArray *)todo
{
    return [self mutableArrayValueForKey:@"todoList"];
}

- (NSMutableArray *)doing
{
    return [self mutableArrayValueForKey:@"doingList"];
}

- (NSMutableArray *)done
{
    return [self mutableArrayValueForKey:@"doneList"];
}

#pragma mark - KVC

- (void)insertObject:(DXEDishItem *)object inCartListAtIndex:(NSUInteger)index
{
    [object addObserver:self
             forKeyPath:NSStringFromSelector(@selector(count))
                options:NSKeyValueObservingOptionNew
                context:nil];
    object.inCart = YES;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] + [object.count integerValue]];
    [self.cartList insertObject:object atIndex:index];
}

- (void)removeObjectFromCartListAtIndex:(NSUInteger)index
{
    DXEDishItem *object = [self.cartList objectAtIndex:index];
    [object removeObserver:self
                forKeyPath:NSStringFromSelector(@selector(count))];
    object.inCart = NO;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] - [object.count integerValue]];
    object.count = [NSNumber numberWithInteger:0];
    [self.cartList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inTodoListAtIndex:(NSUInteger)index
{
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] + [object.count integerValue]];
    [self.todoList insertObject:object atIndex:index];
}

- (void)removeObjectFromTodoListAtIndex:(NSUInteger)index
{
    [self.todoList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inDoingListAtIndex:(NSUInteger)index
{
    [self.doingList insertObject:object atIndex:index];
}

- (void)removeObjectFromDoingListAtIndex:(NSUInteger)index
{
    [self.doingList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inDoneListAtIndex:(NSUInteger)index
{
    [self.doneList insertObject:object atIndex:index];
}

- (void)removeObjectFromDoneListAtIndex:(NSUInteger)index
{
    [self.doneList removeObjectAtIndex:index];
}

#pragma mark - Notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(count))])
    {
        int totalCount = 0;
        totalCount += [[self valueForKeyPath:@"cartList.@sum.count"] intValue];
        totalCount += [[self valueForKeyPath:@"todoList.@sum.count"] intValue];
        totalCount += [[self valueForKeyPath:@"doingList.@sum.count"] intValue];
        totalCount += [[self valueForKeyPath:@"doneList.@sum.count"] intValue];
        self.totalCount = [NSNumber numberWithInt:totalCount];
    }
}

@end
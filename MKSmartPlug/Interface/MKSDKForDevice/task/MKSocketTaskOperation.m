//
//  MKSocketTaskOperation.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSocketTaskOperation.h"
#import "MKSocketManager.h"
#import "MKSocketDataModel.h"

@interface MKSocketTaskOperation()

/**
 线程结束时候的回调
 */
@property (nonatomic, copy)communicationCompleteBlock completeBlock;

@property (nonatomic, assign)MKSocketTaskID taskID;

/**
 是否结束当前线程的标志
 */
@property (nonatomic, assign)BOOL complete;

/**
 只有添加了监听的operation才需要移除监听
 */
@property (nonatomic, assign)BOOL shouldRemoveObser;

@end

@implementation MKSocketTaskOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKSocketTaskOperation销毁");
    if (!self.shouldRemoveObser) {
        return;
    }
    [[MKSocketManager sharedInstance] removeObserver:self forKeyPath:@"dataList" context:nil];
}

/**
 初始化通信线程
 
 @param operationID 当前线程的任务ID
 @param completeBlock 数据通信完成回调
 @return operation
 */
- (instancetype)initOperationWithID:(MKSocketTaskID)operationID
                      completeBlock:(communicationCompleteBlock)completeBlock{
    if (self = [super init]) {
        _executing = NO;
        _finished = NO;
        _completeBlock = completeBlock;
        _taskID = operationID;
    }
    return self;
}

#pragma mark - super method
- (void)main{
    @try {
        @autoreleasepool{
            [self startListen];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    } @finally {
        
    }
}

- (void)start{
    if (self.isFinished || self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (self.isCancelled
        || object != [MKSocketManager sharedInstance]
        || ![keyPath isEqualToString:@"dataList"]
        || !_executing) {
        return;
    }
    NSArray *list = change[@"new"];
    if (!list || list.count != 1) {
        return;
    }
    MKSocketDataModel *model = list[0];
    if (!model
        || model.taskID != self.taskID
        || model.taskID == socketUnknowTask
        || !model.returnData) {
        return;
    }
    [self finishOperation];
    if (model.timeout) {
        //超时
        self.completeBlock([self getErrorWithMsg:@"Communication timeout"], self.taskID, nil);
        return;
    }
    if (self.completeBlock) {
        self.completeBlock(nil, self.taskID, model.returnData);
    }
}

#pragma mark - private method
- (void)startListen{
    if (self.isCancelled) {
        return;
    }
    [[MKSocketManager sharedInstance] addObserver:self forKeyPath:@"dataList" options:NSKeyValueObservingOptionNew context:nil];
    self.shouldRemoveObser = YES;
    do {
        [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
    }while (NO == _complete);
}

- (void)finishOperation{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    _complete = YES;
}

- (NSError *)getErrorWithMsg:(NSString *)msg{
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.operationError" code:-999 userInfo:@{@"errorInfo":msg}];
    return error;
}

#pragma mark - setter & getter
- (BOOL)isConcurrent{
    return YES;
}

- (BOOL)isFinished{
    return _finished;
}

- (BOOL)isExecuting{
    return _executing;
}

@end

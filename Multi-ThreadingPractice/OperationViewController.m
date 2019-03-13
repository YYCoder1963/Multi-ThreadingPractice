//
//  OperationViewController.m
//  Multi-ThreadingPractice
//
//  Created by lyy on 2019/3/11.
//  Copyright © 2019 lyy. All rights reserved.
//

#import "OperationViewController.h"
#import "CustomOperation.h"


@interface OperationViewController ()

@end

@implementation OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self operationQueuePriority];
}



#pragma mark -- OperationQueuePriority
// 对同一个队列中的操作，对准备就绪的操作，优先级高的先执行。依赖关系高于优先级
- (void)operationQueuePriority {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task) object:nil];
    [invocationOperation setQueuePriority:NSOperationQueuePriorityLow];
    
    CustomOperation *customOperation = [[CustomOperation alloc]init];
    [customOperation setQueuePriority:NSOperationQueuePriorityHigh];
    
    CustomOperation *customOperation1 = [[CustomOperation alloc]init];
    [customOperation1 setQueuePriority:NSOperationQueuePriorityHigh];
    
    CustomOperation *customOperation2 = [[CustomOperation alloc]init];
    [customOperation2 setQueuePriority:NSOperationQueuePriorityHigh];
    
    [queue addOperation:invocationOperation];
    [queue addOperation:customOperation];
    [queue addOperation:customOperation1];
    [queue addOperation:customOperation2];
    
}

#pragma mark -- OperationDependency
- (void)operationDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task) object:nil];
    
    CustomOperation *customOperation = [[CustomOperation alloc]init];
    
    [invocationOperation addDependency:customOperation];
    
    [queue addOperation:customOperation];
    [queue addOperation:invocationOperation];
}

#pragma mark -- NSOperationQueue

- (void)operationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 2; // 并发数，每个OperationQueue同一时间能够处理的操作数,具体开启几个线程由系统决定
    
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task) object:nil];
    [queue addOperation:invocationOperation];

    NSBlockOperation *blockOperation = [[NSBlockOperation alloc]init];
    [blockOperation addExecutionBlock:^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"\n NSBlockOperation:%@",[NSThread currentThread]);
    }];
    [queue addOperation:blockOperation];
    
    CustomOperation *customOperation = [[CustomOperation alloc]init];
    [queue addOperation:customOperation];
    
}

#pragma mark -- Only Operation Excute Task
- (void)onlyOperation {
    // 不使用NSOperationQueue，使用 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task) object:nil];
    [operation start];
    
    //不使用NSOperationQueue， NSBlockOperation对象封装的第一个操作会在主线程执行，当通过addExecutionBlock方法添加的操作数量大于1时，会开启新的线程执行这些操作
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc]init];
    [blockOperation addExecutionBlock:^{
        NSLog(@"\n NSBlockOperation-1:%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"\n NSBlockOperation-2:%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"\n NSBlockOperation-3:%@",[NSThread currentThread]);
    }];
    [blockOperation start];
    
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"\n blockOperation1:%@",[NSThread currentThread]);
    }];
    [blockOperation1 start];
    
    // 不使用NSOperationQueue，使用自定义的Operation执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程
    CustomOperation *customOperation = [[CustomOperation alloc]init];
    [customOperation start];
    
}

- (void)task {
    [NSThread sleepForTimeInterval:1];
    NSLog(@"\n NSInvocationOperation:%@",[NSThread currentThread]);
}

@end

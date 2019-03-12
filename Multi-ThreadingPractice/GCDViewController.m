//
//  GCDViewController.m
//  Multi-ThreadingPractice
//
//  Created by lyy on 2019/3/11.
//  Copyright © 2019 lyy. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dispatchSemaphore];
}

#pragma mark --- DispatchSemaphore

- (void)dispatchSemaphore {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_semaphore_t semophore = dispatch_semaphore_create(1);
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 100; i++) {
        dispatch_async(queue, ^{
            // 信号量大于1，dispatch_semaphore_wait函数返回，并将信号量减一，否则线程停止
            dispatch_semaphore_wait(semophore, DISPATCH_TIME_FOREVER);
        
            [array addObject:[NSNumber numberWithInt:i]];
            // 信号量加一
            dispatch_semaphore_signal(semophore);
            
        });
    }
    
    NSLog(@"%@",array);

}

#pragma mark --- DispatchSuspendAndResume

// dispatch_suspend函数挂起queue，挂起前添加到队列的block任务照常执行，挂起后加入的待dispatch_suspend函数恢复队列后f才会执行
- (void)dispatchSuspendAndResume {
    dispatch_queue_t queue = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue", NULL);
    dispatch_async(queue, ^{
        NSLog(@"1111");
        sleep(2);
    });
    
    dispatch_suspend(queue);
    
    dispatch_async(queue, ^{
        NSLog(@"2222");
        sleep(2);
    });
    
    dispatch_resume(queue);
    
    dispatch_async(queue, ^{
        NSLog(@"3333");
    });
    
}
#pragma mark --- DispatchApply

- (void)dispatchApply {
    NSArray *array = @[@"one",@"two",@"three",@"four",@"five"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(array.count, queue, ^(size_t index) {
        NSLog(@"\n%zu: %@",index,array[index]);
    });
}

#pragma mark --- DispatchBarrierAysc

- (void)dispatchBarrierAysc {
    dispatch_queue_t queue = dispatch_queue_create("XL.Multi-ThreadingPractice.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{ NSLog(@"read data1"); });
    dispatch_async(queue, ^{ NSLog(@"read data2"); });
    dispatch_async(queue, ^{ NSLog(@"read data3"); });

    dispatch_barrier_async(queue, ^{
        NSLog(@"write data");
    });
    
    dispatch_async(queue, ^{ NSLog(@"read data4"); });
    dispatch_async(queue, ^{ NSLog(@"read data5"); });
    dispatch_async(queue, ^{ NSLog(@"read data6"); });
    
}
#pragma mark --- Dispatch_Set_Target_Queue

- (void)dispatchSetQueuePriority {
    dispatch_queue_t serialQueue1 = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue1", NULL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue2", NULL);
    
    /*
    dispatch_async(serialQueue1, ^{
        NSLog(@"before--1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"before---2");
    });
    */
  
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_set_target_queue(serialQueue2, backgroundQueue);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"after---1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"after---2");
    });
    
}

// 在必须将不可并行执行的处理追加到多个serial dispatch queue中时，如果使用dispatch_set_target_queue函数将目标制定为某个serial dispatch queue，即可防止并行执行
- (void)dispatchSetQueueExcuteOrder {
    dispatch_queue_t serialQueue1 = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue1", NULL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue2", NULL);
    dispatch_queue_t serialQueue3 = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue3", NULL);
    
    dispatch_queue_t targetQueue = dispatch_queue_create("XL.Multi-ThreadingPractice.targetQueue", NULL);
    dispatch_set_target_queue(serialQueue1, targetQueue);
    dispatch_set_target_queue(serialQueue2, targetQueue);
    dispatch_set_target_queue(serialQueue1, targetQueue);
    /* 或者
    dispatch_set_target_queue(serialQueue1, serialQueue3);
    dispatch_set_target_queue(serialQueue2, serialQueue3);
    */
    dispatch_async(serialQueue1, ^{
        NSLog(@"after--1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"after---2");
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"after---3");
    });
    
}

#pragma mark --- DispatchQueue

- (void)gcdQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("XL.Multi-ThreadingPractice.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("XL.Multi-ThreadingPractice.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(serialQueue, ^{
        NSLog(@"\nasync_serialQueue:%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"\nasync_concurrentQueue%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    
    dispatch_async(mainQueue, ^{
        NSLog(@"\nasync_mainQueue:%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"\nsync_serialQueue:%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"\nsync_concurrentQueue:%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    /*
     // 同步函数串行队列添加任务会死锁
     dispatch_sync(mainQueue, ^{
     NSLog(@"\n%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
     });
     */
}

#pragma mark --- DispatchGroup

- (void)gcdGroup {
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task_1");
    });
    dispatch_group_leave(group);
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task_2");
    });
    dispatch_group_leave(group);
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task_3");
    });
    dispatch_group_leave(group);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"all done");
    });
}

@end

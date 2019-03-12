//
//  ThreadViewController.m
//  Multi-ThreadingPractice
//
//  Created by lyy on 2019/3/11.
//  Copyright © 2019 lyy. All rights reserved.
//

#import "ThreadViewController.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createThread];
}
#pragma mark --- NSThread

- (void)createThread {
    NSLog(@"%d",[[NSThread currentThread] isMainThread]);
    NSThread *thread1 = [[NSThread alloc]initWithBlock:^{
        NSLog(@"\n%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    }];
    [thread1 setName:@"thread1"];
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(test) object:nil];
    [thread2 setName:@"thread2"];
    [thread2 start];
    
    // 创建后自动启动线程
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"\n%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    }];
    // 创建后自动启动线程
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:nil];
    
}

- (void)test {
    NSLog(@"\n-----test------");
    [NSThread sleepForTimeInterval:1];
    [NSThread exit];
    NSLog(@"\n%@ --- %d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
}

@end

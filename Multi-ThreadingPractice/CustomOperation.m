//
//  CustomOperation.m
//  Multi-ThreadingPractice
//
//  Created by lyy on 2019/3/13.
//  Copyright © 2019 lyy. All rights reserved.
//

#import "CustomOperation.h"

@implementation CustomOperation

- (void)main {
    if (!self.isCancelled) {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"\n CustomOperation:%@",[NSThread currentThread]);
    }
}

@end

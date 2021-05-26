//
//  TestB.m
//  OC消息传递以及完整消息转发流程
//
//  Created by 颜仁浩 on 2021/5/26.
//

#import "TestB.h"

@implementation TestB

- (void)runAway {
    NSLog(@"1, 当前调用对象的类型是 ---->  %@", [self class]);
    NSLog(@"%s", __FUNCTION__);
}


- (void)goAway {
    NSLog(@"2、当前调用对象的类型是 ---->  %@", [self class]);
    NSLog(@"%s", __FUNCTION__);
}

@end

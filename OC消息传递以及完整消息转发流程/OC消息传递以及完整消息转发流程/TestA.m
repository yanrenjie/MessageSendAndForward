//
//  TestA.m
//  OC消息传递以及完整消息转发流程
//
//  Created by 颜仁浩 on 2021/5/26.
//

#import "TestA.h"
#import <objc/runtime.h>
#import "TestB.h"

@implementation TestA

- (void)eatAction {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"当前消息的接受者是%@", [self class]);
}

// 这里是当消息接受对象的类里的方法列表中并没找到对应的方法实现的时候，然后进行动态添加方法实现
#if 0
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"runAway"]) {
        return class_addMethod(self, sel, (IMP)addMethodInResolveTime, "v@:@");
    }
    return [super resolveInstanceMethod:sel];
}


void addMethodInResolveTime(id self, SEL _cmd) {
    NSLog(@"这是没有在对象所在的类以及其父类中找到对应的方法实现的时候，然后进行动态添加的方法实现，如果实现了，则直接调用，并不需要进行消息转发机制");
}
#endif

//这里是消息的快速转发，直接指定对应的类来处理对应的消息，比方说，这里TestA调用了runAway方法，但是TestA只有方法的声明，并没有方法的具体实现，这里就指定TestB类来处理，因为TestB中有相同方法名称的声明以及实现

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *methdoName = NSStringFromSelector(aSelector);

    TestB *b = [TestB new];
    if ([methdoName isEqualToString:@"runAway"]) {
        if ([b respondsToSelector:aSelector]) {
            return b;
        }
    }
    return  [super forwardingTargetForSelector:aSelector];
}

// 消息的标准转发，慢速转发
// 1、方法签名
// 2、消息转发，指定消息的接受者，可以是本类也可是其他类

// 方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"runAway"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

// 消息的转发
// 1、指定当前消息的接受者为TestB 类，但是处理消息的方法名与TestA中的名称相同

#if 0
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = [anInvocation selector];
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"runAway"]) {
        TestB *b = [TestB new];
        if ([b respondsToSelector:sel]) {
            [anInvocation invokeWithTarget:b];
            return;
        }
    }
    return [super forwardInvocation:anInvocation];
}
#endif


// 2、指定当前消息的接受者为TestB，但是处理的方法名称与TestA中的不一样
#if 0
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = [anInvocation selector];
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"runAway"]) {
        TestB *b = [TestB new];
        if ([b respondsToSelector:sel]) {
            [anInvocation setSelector:@selector(goAway)];
            [anInvocation invokeWithTarget:b];
            return;
        }
    }
    return [super forwardInvocation:anInvocation];
}
#endif


// 3、指定当前消息的接受者就是TestA本类，但是处理此消息更换为其他的方法
#if 1
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = [anInvocation selector];
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"runAway"]) {
        [anInvocation setSelector:@selector(eatAction)];
        [anInvocation invokeWithTarget:self];
        return;
    }
    return [super forwardInvocation:anInvocation];
}
#endif

@end

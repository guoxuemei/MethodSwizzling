//
//  NSObject+Swizzle.m
//  MethodSwizzling
//
//  Created by guoxmei on 2017/8/17.
//  Copyright © 2017年 huayang. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (void)swizzleSelector:(SEL)originSelector withSelector:(SEL)swizzledSelector {
    
    Class cls = [self class];
    
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    //添加 SEL:originSelector -> IMP(swizzledMethod),已存在则返回失败
    BOOL addSucceed = class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));//encoding:@12@0:4I8

    //针对数组为例,只有 -objectAtIndexedSubscript:方法执行到 if 语句了,其余的情况执行的是 else 语句🤔
    if (addSucceed) {
        //替换 SEL:swizzledSelector -> IMP(originMethod),完成交换操作
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        NSLog(@"%@ %@ 0",cls,NSStringFromSelector(originSelector));

    } else {
        //已存在,直接交换
        NSLog(@"%@ %@ 1",cls,NSStringFromSelector(originSelector));

        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

+ (void)swizzleClassSelector:(SEL)originSelector withClassSelector:(SEL)swizzledSelector {
    
    Class cls = object_getClass(self);
    
    Method originMethod = class_getClassMethod(cls, originSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    
    BOOL addSucceed = class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (addSucceed) {
        
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

@end

#pragma mark - NSArray 访问控制
@implementation NSArray (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        /*两种方式获取不可变数组的类
          objc_getClass("__NSArrayI") = NSClassFromString(@"__NSArrayI")
          不能使用 [self class],因为 NSArray 是个类簇,不是很懂
         */

        Class cls = objc_getClass("__NSArrayI");
        Class singCls = objc_getClass("__NSSingleObjectArrayI");
        [cls swizzleSelector:@selector(objectAtIndex:) withSelector:@selector(safe_objectAtIndex:)];
        
        //这里的objectAtIndex: 应该是safe_objectAtIndex:
        [singCls swizzleSelector:@selector(objectAtIndex:) withSelector:@selector(safe_singleObjectAtIndex:)];
        
        //iOS 11以前,下标方式,objectAtIndexedSubscript:调用无效后,会尝试调用objectAtIndex:
        //iOS 11以后,下标方式,objectAtIndexedSubscript:,如果不交换实现做容错处理,会崩溃;
        [cls swizzleSelector:@selector(objectAtIndexedSubscript:) withSelector:@selector(safe_objectAtIndexedSubscript:)];
        
        Class emptyCls = objc_getClass("__NSArray0");
        [emptyCls swizzleSelector:@selector(objectAtIndex:) withSelector:@selector(safe_emptyObjectAtIndex:)];
    });
}

- (id)safe_objectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        
        return [self safe_objectAtIndex:index];
    }
    NSLog(@"NSArray objectAtIndex: 失败");
    return nil;
}
- (id)safe_objectAtIndexedSubscript:(NSUInteger)index {
    
    id object = nil;
    @try {
        object = [self safe_objectAtIndexedSubscript:index];
    }
    @catch (NSException *exception) {
        NSLog(@"NSArray[] 失败");
    }
    @finally {
        return object;
    }
}
- (id)safe_singleObjectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        return [self safe_singleObjectAtIndex:index];
    }
    NSLog(@"NSSingleArray objectAtIndex: 失败");
    return nil;
}
//非可变的空数组
- (id)safe_emptyObjectAtIndex:(NSUInteger)index {
    
    id object = nil;
    @try {
        object = [self safe_emptyObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        NSLog(@"NSArray0 失败");
    }
    @finally {
        return object;
    }
}
@end

#pragma mark - NSMutableArray 访问控制
@implementation NSMutableArray (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("__NSArrayM");
        [cls swizzleSelector:@selector(objectAtIndex:) withSelector:@selector(safe_objectAtIndex:)];
        [cls swizzleSelector:@selector(objectAtIndexedSubscript:) withSelector:@selector(safe_objectAtIndexedSubscript:)];
        [cls swizzleSelector:@selector(addObject:) withSelector:@selector(safe_addObject:)];
        [cls swizzleSelector:@selector(removeObjectAtIndex:) withSelector:@selector(safe_removeObjectAtIndex:)];
        [cls swizzleSelector:@selector(replaceObjectAtIndex:withObject:) withSelector:@selector(safe_replaceObjectAtIndex:withObject:)];
        [cls swizzleSelector:@selector(insertObject:atIndex:) withSelector:@selector(safe_insertObject:atIndex:)];
    });
}

- (id)safe_objectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        return [self safe_objectAtIndex:index];
    }
    NSLog(@"NSMutableArray objectAtIndex: 失败");
    return nil;
}
- (id)safe_objectAtIndexedSubscript:(NSUInteger)index {
    
    id object = nil;
    @try {
        object = [self safe_objectAtIndexedSubscript:index];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableArray[] 失败");
    }
    @finally {
        return object;
    }
}
- (void)safe_addObject:(id)anObject {
    
    if (anObject) {
        [self safe_addObject:anObject];
    } else {
        NSLog(@"NSMutableArray addObject: 失败");
    }
}
- (void)safe_removeObjectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        [self safe_removeObjectAtIndex:index];
    } else {
        NSLog(@"NSMutableArray removeObjectAtIndex: 失败");
    }
}

- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    if (anObject && index < self.count) {
        [self safe_replaceObjectAtIndex:index withObject:anObject];
    } else {
        NSLog(@"NSMutableArray replaceObjectAtIndex:withObject: 失败");
    }
}
- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    
    //index: This value must not be greater than the count of elements in the array.
    if (anObject && index <= self.count) {
        
        [self safe_insertObject:anObject atIndex:index];
    } else {
        NSLog(@"NSMutableArray insertObject:atIndex: 失败");
    }
}
@end

#pragma mark - NSMutableDictionary 访问控制
@implementation NSMutableDictionary (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"__NSDictionaryM");
        [cls swizzleSelector:@selector(setObject:forKey:) withSelector:@selector(safe_setObject:forKey:)];
        [cls swizzleSelector:@selector(removeObjectForKey:) withSelector:@selector(safe_removeObjectForKey:)];
    });
}
- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (anObject && aKey) {
        [self safe_setObject:anObject forKey:aKey];
    } else {
        NSLog(@"NSMutableDictionary setObject:forKey: 失败");
    }
}
- (void)safe_removeObjectForKey:(id)aKey {
    
    if (aKey) {
        [self safe_removeObjectForKey:aKey];
    } else {
        NSLog(@"NSMutableDictionary removeObjectForKey: 失败");
    }
}

@end
#pragma mark - NSString 访问控制
@implementation NSString (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        Class cls = NSClassFromString(@"__NSCFString");
        [cls swizzleSelector:@selector(substringFromIndex:) withSelector:@selector(safe_substringFromIndex:)];
        [cls swizzleSelector:@selector(substringToIndex:) withSelector:@selector(safe_substringToIndex:)];
        [cls swizzleSelector:@selector(substringWithRange:) withSelector:@selector(safe_substringWithRange:)];
       
        [cls swizzleSelector:@selector(stringByAppendingString:) withSelector:@selector(safe_stringByAppendingString:)];
        
        [cls swizzleSelector:@selector(stringByReplacingCharactersInRange:withString:) withSelector:@selector(safe_stringByReplacingCharactersInRange:withString:)];
        [cls swizzleSelector:@selector(stringByReplacingOccurrencesOfString:withString:options:range:) withSelector:@selector(safe_stringByReplacingOccurrencesOfString:withString:options:range:)];

    });
}
- (NSString *)safe_substringFromIndex:(NSUInteger)from {
    
    NSString *subString = nil;
    @try {
        subString = [self safe_substringFromIndex:from];
    } @catch (NSException *exception) {
        NSLog(@"NSString substringFromIndex: 失败");
        subString = nil;
    } @finally {
        return subString;
    }
}
- (NSString *)safe_substringToIndex:(NSUInteger)to {
    
    NSString *subString = nil;
    @try {
        subString = [self safe_substringToIndex:to];
    } @catch (NSException *exception) {
        NSLog(@"NSString substringToIndex: 失败");
        subString = nil;
    } @finally {
        return subString;
    }
}
- (NSString *)safe_substringWithRange:(NSRange)range {
    
    NSString *subString = nil;
    @try {
        subString = [self safe_substringWithRange:range];
    } @catch (NSException *exception) {
        NSLog(@"NSString substringWithRange: 失败");
        subString = nil;
    } @finally {
        return subString;
    }
}
- (NSString *)safe_stringByAppendingString:(NSString *)aString {
    
    NSString *str = self;
    @try {
        str = [self safe_stringByAppendingString:aString];
    } @catch (NSException *exception) {
        NSLog(@"NSString stringByAppendingString: 失败");
    } @finally {
        return str;
    }
    
}

- (NSString *)safe_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = self;
    @try {
        newStr = [self safe_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        NSLog(@"NSString stringByReplacingOccurrencesOfString:withString:options:range: 失败");
    }
    @finally {
        return newStr;
    }
}

- (NSString *)safe_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    
    NSString *newStr = self;
    @try {
        newStr = [self safe_stringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        NSLog(@"NSString stringByReplacingCharactersInRange:withString: 失败");
    }
    @finally {
        return newStr;
    }
}

@end

#pragma mark - NSMutableString 访问控制
@implementation NSMutableString (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"__NSCFString");
        [cls swizzleSelector:@selector(replaceCharactersInRange:withString:)
                withSelector:@selector(safe_replaceCharactersInRange:withString:)];
        [cls swizzleSelector:@selector(insertString:atIndex:)
                withSelector:@selector(safe_insertString:atIndex:)];
        [cls swizzleSelector:@selector(deleteCharactersInRange:)
                withSelector:@selector(safe_deleteCharactersInRange:)];
    });
}

- (void)safe_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    
    @try {
        [self safe_replaceCharactersInRange:range withString:aString];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableString replaceCharactersInRange:withString: 失败");
    }
    @finally {
    }
}

- (void)safe_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    
    @try {
        [self safe_insertString:aString atIndex:loc];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableString insertString:atIndex: 失败");
    }
    @finally {
    }
}

- (void)safe_deleteCharactersInRange:(NSRange)range {
    
    @try {
        [self safe_deleteCharactersInRange:range];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableString deleteCharactersInRange: 失败");
    }
    @finally {
    }
}

@end

#pragma mark - NSAttributedString 访问控制
@implementation NSAttributedString (Swizzle)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"NSConcreteAttributedString");
        [cls swizzleSelector:@selector(initWithString:)
                withSelector:@selector(safe_initWithString:)];
        [cls swizzleSelector:@selector(initWithString:attributes:)
                withSelector:@selector(safe_initWithString:attributes:)];
    });
    
}

- (instancetype)safe_initWithString:(NSString *)str {
    
    id object = nil;
    @try {
        object = [self safe_initWithString:str];
    }
    @catch (NSException *exception) {
        NSLog(@"NSAttributedString initWithString: 失败");
    }
    @finally {
        return object;
    }
}

- (instancetype)safe_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self safe_initWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        NSLog(@"NSAttributedString initWithString:attributes: 失败");
    }
    @finally {
        return object;
    }
}

@end

#pragma mark - NSMutableAttributedString 访问控制
@implementation NSMutableAttributedString (Swizzle)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"NSConcreteMutableAttributedString");
        [cls swizzleSelector:@selector(initWithString:)
                withSelector:@selector(safe_initWithString:)];
        [cls swizzleSelector:@selector(initWithString:attributes:)
                withSelector:@selector(safe_initWithString:attributes:)];
        
        [cls swizzleSelector:@selector(setAttributes:range:) withSelector:@selector(safe_setAttributes:range:)];
        
        [cls swizzleSelector:@selector(addAttribute:value:range:) withSelector:@selector(safe_addAttribute:value:range:)];
        [cls swizzleSelector:@selector(addAttributes:range:) withSelector:@selector(safe_addAttributes:range:)];
        
        [cls swizzleSelector:@selector(removeAttribute:range:) withSelector:@selector(safe_removeAttribute:range:)];
    });
}

- (instancetype)safe_initWithString:(NSString *)str {
    id object = nil;
    @try {
        object = [self safe_initWithString:str];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString initWithString: 失败");
    }
    @finally {
        return object;
    }
}

- (instancetype)safe_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self safe_initWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString initWithString:attributes: 失败");
    }
    @finally {
        return object;
    }
}
- (void)safe_setAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    
    @try {
        [self safe_setAttributes:attrs range:range];
    } @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString setAttributes:range: 失败");
    } @finally {
    }
}
- (void)safe_addAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    
    @try {
        [self safe_addAttribute:name value:value range:range];
    } @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString addAttribute:value:range: 失败");
    } @finally {
    }
}
- (void)safe_addAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range {
    
    @try {
        [self safe_addAttributes:attrs range:range];
    } @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString addAttributes:range: 失败");
    } @finally {
    }
}
- (void)safe_removeAttribute:(NSString *)name range:(NSRange)range {
    
    @try {
        [self safe_removeAttribute:name range:range];
    } @catch (NSException *exception) {
        NSLog(@"NSMutableAttributedString removeAttribute:range: 失败");
    } @finally {
    }
}
@end

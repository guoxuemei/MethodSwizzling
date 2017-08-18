//
//  NSObject+Swizzle.h
//  MethodSwizzling
//
//  Created by guoxmei on 2017/8/17.
//  Copyright © 2017年 huayang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

/*!
 *  @brief runtime 交换两个 selector 的实现
 *
 *  @param originSelector   原来的方法
 *  @param swizzledSelector 要交换的方法
 */
+ (void)swizzleSelector:(SEL)originSelector withSelector:(SEL)swizzledSelector;

/*!
 *  @brief 交换两个类方法的实现
 *
 *  @param originSelector   原来的类方法
 *  @param swizzledSelector 要交换的类方法
 */
+ (void)swizzleClassSelector:(SEL)originSelector withClassSelector:(SEL)swizzledSelector;

@end

@interface NSArray (Swizzle)

@end

@interface NSMutableArray (Swizzle)

@end

@interface NSMutableDictionary (Swizzle)

@end

@interface NSString (Swizzle)

@end

@interface NSMutableString (Swizzle)

@end

@interface NSAttributedString (Swizzle)

@end

@interface NSMutableAttributedString (Swizzle)

@end

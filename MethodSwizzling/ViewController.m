//
//  ViewController.m
//  MethodSwizzling
//
//  Created by guoxmei on 2017/8/17.
//  Copyright © 2017年 huayang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)btnClicked:(id)sender {
    
    /**NSArray**********************************************************************/
//    //1. 测试多元素数组取值越界
//    NSArray *array1 = @[@"111",@"222"];
//    NSLog(@"1:%@",[array1 objectAtIndex:2]);
//    NSLog(@"2:%@",array1[2]);
    
//    //2. 测试单元素数组取值越界
//    NSArray *array2 = @[@"111"];
//    NSLog(@"3:%@",[array2 objectAtIndex:1]);
//    NSLog(@"4:%@",array2[1]);
//
     //空数组取值问题
    NSArray *emptyArray = [[NSArray alloc] init];
    NSLog(@"%@",emptyArray[0]);
//    
//    //3. 测试可变数组取值问题
//    NSMutableArray *mArray = [@[@"111",@"222"] mutableCopy];
//    NSLog(@"1:%@",mArray[2]);
//    NSString *s = nil;
//
//    //3.1 取出特定位置元素
//    NSLog(@"%@",[mArray objectAtIndex:3]);
//
//    //3.2 添加
//    [mArray addObject:s];
//
//    //3.3 移除特定位置元素
//    [mArray removeObjectAtIndex:3];
//
//    //3.4 替换特定位置元素
//    [mArray replaceObjectAtIndex:0 withObject:s];
//
//    //3.5 特定位置插入元素
//    [mArray insertObject:@"333" atIndex:3];

/**NSDictionary****************************************************************/
//    //字典读取时,key 为 nil 时不会报出异常
//    NSDictionary *dict = @{@"key1": @"111"};
//    NSString *s = nil;
//    NSLog(@"%@",dict[s]);

//4. 可变字典的操作
//    NSMutableDictionary *mDict = [@{@"key1": @"value1", @"key2": @"value2"} mutableCopy];
//
//    NSString *key = nil, *value = nil;
//
//    //4.1 设置值
//    [mDict setObject:value forKey:key];
//
//    //4.2 移除值
//    [mDict removeObjectForKey:key];

/**NSString****************************************************************/

//    NSString *str = @"abcdefg";
//    NSLog(@"%@",[str substringFromIndex:-7]);
//    NSLog(@"%@",[str substringToIndex:9]);
//    NSLog(@"%@",[str substringWithRange:NSMakeRange(0, 8)]);
//
//    NSString *a = nil;
//    NSString *b = @"ds";
//    NSLog(@"%@",[str stringByAppendingString:a]);
//    NSLog(@"%@",[str stringByAppendingFormat:b,a]);
//
//    NSLog(@"%@",[str stringByReplacingCharactersInRange:NSMakeRange(0, 15) withString:a]);

//    NSLog(@"%@",[str stringByReplacingOccurrencesOfString:@"ab" withString:@"A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 9)]);

//    NSMutableString *mStr = [@"abcdefg" mutableCopy];
//    NSLog(@"%@",[mStr substringFromIndex:9]); //处理同 NSString
//    [mStr replaceCharactersInRange:NSMakeRange(0, 5) withString:nil];
//    [mStr insertString:nil atIndex:9];
//    [mStr deleteCharactersInRange:NSMakeRange(0, 2)];
//    NSLog(@"%@",mStr);

/**NSAttributedString****************************************************************/
//    NSString *str = nil;
//    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:str attributes:nil];

//    NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:@"12345"];
//
//
//    [mAttStr setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(0, 3)];
//    [mAttStr setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} range:NSMakeRange(0, 8)];
//
//两个 add 方法,虽然range(0,8)出界,但是 有效部分的range会被执行, 即range(0,5),会被设置为 font 16
//set方法,就不会执行
//    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 3)];
//    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, 8)];

//    [mAttStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} range:NSMakeRange(0, 3)];
//    [mAttStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} range:NSMakeRange(0, 8)];

//remove方法性质和上面差不多,虽然 range(1,9)出界,但是有效部分的 range 会被执行,即 range(1,4),会将 font 属性移除
//    [mAttStr removeAttribute:NSFontAttributeName range:NSMakeRange(1, 9)];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  CYLMediator.m
//  CYLMediator
//
//  Created by GARY on 2017/4/12.
//  Copyright © 2017年 GARY. All rights reserved.
//

#import "CYLMediator.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation CYLMediator
#pragma mark - 单例
static id sharedMediator;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{
        sharedMediator = [super allocWithZone:zone];
    });
    return sharedMediator;
}
+ (instancetype)sharedMediator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMediator = [[self alloc] init];
    });
    return sharedMediator;
}
- (id)copyWithZone:(NSZone *)zone
{
    return sharedMediator;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    return sharedMediator;
}

#pragma mark - method

/**
带参数 跳转到目标控制器

 @param className 目标控制器的类名字符串
 @param param 参数 param1=11&param2=long&param3=0122
 @param handler 返回参数字典
 */
- (void)mediatorPresentViewContoller:(NSString*)className andParame:(NSString*)param completeHandler:(void(^)(NSDictionary*))handler
{
    
    Class ViewControllerClass = NSClassFromString(className);
    UIViewController *vc = [[ViewControllerClass alloc] init];
    NSMutableDictionary *params = [self setParam:param forViewController:vc];
    
    if (handler) {
        handler(params);
    }
}


- (void)mediatorPresentViewContoller:(NSString*)className withModelObject:(id)model completeHandler:(void(^)(NSDictionary*))handler
{
    Class viewControllerClass = NSClassFromString(className);
    UIViewController *vc = [[viewControllerClass alloc] init];
    NSMutableDictionary *dic = [self setModel:model forViewController:vc];
    
    if (handler) {
        handler(dic);
    }
}


- (void)mediatorPresentViewContoller:(NSString*)className withModelObject:(id)model andParam:(NSString *)param completeHandler:(void(^)(NSDictionary*))handler
{
    Class viewControllerClass = NSClassFromString(className);
    UIViewController *vc = [[viewControllerClass alloc] init];
    NSMutableDictionary *paramDic = [self setParam:param forViewController:vc];
    NSMutableDictionary *dic = [self setModel:model forViewController:vc];
    [dic addEntriesFromDictionary:paramDic];
    
    if (handler) {
        handler(dic);
    }
}

#pragma mark - private

- (NSMutableDictionary*)setModel:(id)model forViewController:(UIViewController*)vc
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([vc class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *propertyClass = [NSString stringWithUTF8String:property_getAttributes(property)];
        if ([propertyClass containsString:NSStringFromClass([model class])]) {
            [vc setValue:model forKeyPath:propertyName];
            [dic setObject:model forKey:propertyName];
        }
    }
    
    [dic setObject:vc forKey:ViewControllerKey];

    return dic;
}

- (NSMutableDictionary*)setParam:(NSString*)param forViewController:(UIViewController*)vc
{
    NSMutableDictionary *params = [self parseParams:param];
    
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([vc class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([params.allKeys containsObject:propertyName]) {
            [vc setValue:params[propertyName] forKeyPath:propertyName];
        }
    }
    [params setValue:vc forKey:ViewControllerKey];
    
    return params;

}


- (NSMutableDictionary*)parseParams:(NSString*)param
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *subStr in [param componentsSeparatedByString:@"&"]) {
        NSArray *arr = [subStr componentsSeparatedByString:@"="];
        [params setValue:arr[1] forKey:arr[0]];
    }
    
    return params;
}


- (NSDictionary*)modelToDict:(id)model
{
    //模型转字典
    NSMutableDictionary *ModelDic = [NSMutableDictionary dictionary];
    Class modelClass = [model class];
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(modelClass, &outCount);
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id propertyValue = [model valueForKey:propertyName];
        if (propertyValue) [ModelDic setValue:propertyValue forKey:propertyName];
    }
    
    return ModelDic;
}



@end

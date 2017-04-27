//
//  GPS.h
//
//  Created by mac on 15/9/15.
//  Copyright (c) 2015年 韩刚. All rights reserved.
//

/*
 iOS8之后 需要设置配置文件
 
 1.在info.plist中添加
	<key>NSLocationAlwaysUsageDescription</key>
	<string>是否允许此App使用您的地理位置？</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>是否允许此App使用您的地理位置？</string>
 2.调用时候要添加成员变量,局部变量会释放,将不能定位成功
 
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationCompletionBlock)(CGFloat longitude, CGFloat latitude);

@interface SXGps : NSObject
//-------------------------------定位
//开启定位
- (void)startLocation;
//停止定位
- (void)endLocation;
//判断定位是否成功
@property (nonatomic, strong) NSString *message;
//经度
@property (nonatomic, assign) CGFloat longitude;
//纬度
@property (nonatomic, assign) CGFloat latitude;
//调用BLOCK
@property (nonatomic, copy)   LocationCompletionBlock locationBlock;

//------------------------------火星偏移
//国内偏移,国外不变返回原值
+ (CLLocation *)transformToMarsGlobalLocation:(CLLocation *)location;

//-------------------------------坐标转换地址
typedef void (^AddressCompletionBlock)(NSArray *locationArr,NSError *error);
@property (nonatomic, strong) CLGeocoder *gecoder;
@property (nonatomic, copy) AddressCompletionBlock locationAddressBlock;

//传入经纬度,block中返回查询到的地址数组
- (void)searchLocation:(CLLocation*)location completeionBlock:(AddressCompletionBlock)completeion;

//----------------------------调用此方法可以直接获取地址
- (void)searchReturnAddress:(void (^)(NSString *totalAddress))addressBlock;

@end

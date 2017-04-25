# SXGpsHelper
Easy use GPS get address

## 1.import
if use Pod 
```
  #import <SXGps.h>
```
else
```
  #import "SXGps.h"
```
## 2.use
```
setting plist
	<key>NSLocationAlwaysUsageDescription</key>
	<string>App需要使用您的地理位置来提供服务</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>App需要使用您的地理位置来提供服务</string>
```

```
SXGps *_gpsHelper;
```
```
//use example
_gpsHelper = [[SXGps alloc] init];
[_gpsHelper startLocation];
[_gpsHelper searchReturnAddress:^(NSString *totalAddress) {
    NSLog(@"address->>%@", totalAddress);
    [_gpsHelper endLocation];
}];
...
```
## 3.interface
```
//-------------------------------定位
//开启定位
- (void)startLocation;
//停止定位
- (void)endLocation;
//定位不成功会返回message
@property (nonatomic, strong) NSString *message;
//经度
@property (nonatomic, assign) CGFloat longitude;
//纬度
@property (nonatomic, assign) CGFloat latitude;
//调用BLOCK
@property (nonatomic, copy)   LocationCompletionBlock locationBlock;


//------------------------------火星偏移
//国内偏移,国外不变返回原值
+ (CLLocation *)transformToMars:(CLLocation *)location;

//根据国内经纬返回全球经纬度
+ (double)transformLatWithX:(double)x y:(double)y;
+ (double)transformLonWithX:(double)x y:(double)y;


//-------------------------------坐标转换地址

typedef void (^AddressCompletionBlock)(NSArray *locationArr,NSError *error);
@property (nonatomic, strong) CLGeocoder *gecoder;
@property (nonatomic, copy) AddressCompletionBlock locationAddressBlock;

//传入经纬度,block中返回查询到的地址数组
- (void)searchLocation:(CLLocation*)location completeionBlock:(AddressCompletionBlock)completeion;

//----------------------------调用此方法可以直接获取地址
- (void)searchReturnAddress:(void (^)(NSString *totalAddress))addressBlock;

```

//
//  MKSocketManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备默认的ip地址
extern NSString *const defaultHostIpAddress;
//设备默认的端口号
extern NSInteger const defaultPort;

@class MKSocketDataModel;
@interface MKSocketManager : NSObject

@property (nonatomic, strong)NSMutableArray <MKSocketDataModel *>*dataList;

+ (MKSocketManager *)sharedInstance;

/**
 获取当前手机连接的wifi ssid,注意:目前公司设备的ssid前两位为mk(MK)

 @return wifi ssid
 */
+ (NSString *)currentWifiSSID;

/**
 连接plug设备
 
 @param host host ip address
 @param port port (0~65535)
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectDeviceWithHost:(NSString *)host
                         port:(NSInteger)port
              connectSucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
           connectFailedBlock:(void (^)(NSError *error))failedBlock;
/**
 读取设备信息
 
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readSmartPlugDeviceInformationWithSucBlock:(void (^)(id returnData))sucBlock
                                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

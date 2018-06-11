//
//  MKDeviceDataBaseManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceDataBaseManager.h"
#import "MKDeviceDataBaseAdopter.h"
#import "MKDeviceModel.h"

static char *const MKDeviceDataBaseOperationQueue = "MKDeviceDataBaseOperationQueue";

@implementation MKDeviceDataBaseManager

/**
 添加的设备入库
 
 @param deviceList 设备列表
 @param sucBlock 入库成功
 @param failedBlock 入库失败
 */
+ (void)insertDeviceList:(NSArray <MKDeviceModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock{
    if (!deviceList) {
        [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
        return;
    }
    if (deviceList.count == 0) {
        dispatch_main_async_safe(^{
            sucBlock();
        });
        return;
    }
    dispatch_queue_t queueInsert = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueInsert, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        
        BOOL resCreate = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceTable (device_mac text NOT NULL, local_name text NOT NULL,device_name text NOT NULL, device_icon text NOT NULL, device_specifications text NOT NULL, device_function text NOT NULL);"];
        if (!resCreate) {
            [db close];
            [MKDeviceDataBaseAdopter operationInsertFailedBlock:failedBlock];
            return;
        }
        for (MKDeviceModel *model in deviceList) {
            BOOL exist = NO;
            FMResultSet * result = [db executeQuery:@"select * from deviceTable where device_mac = ?",model.device_mac];
            while (result.next) {
                if ([model.device_mac isEqualToString:[result stringForColumn:@"device_mac"]]) {
                    exist = YES;
                }
            }
            if (exist) {
                //存在该设备，更新设备
                [db executeUpdate:@"UPDATE deviceTable SET device_name = ? ,local_name = ?,device_icon = ? , device_specifications = ? ,device_function = ? WHERE device_mac = ?",                          SafeStr(model.device_name),SafeStr(model.local_name),SafeStr(model.device_icon),SafeStr(model.device_specifications),SafeStr(model.device_function),SafeStr(model.device_mac)];
            }else{
                //不存在，插入设备
                [db executeUpdate:@"INSERT INTO deviceTable (device_mac, local_name, device_name, device_icon, device_specifications, device_function) VALUES (?, ?, ?, ?, ?, ?);",
                 model.device_mac,model.local_name,model.device_name,model.device_icon,model.device_specifications,model.device_function];
            }
            
        }
        if (sucBlock) {
            dispatch_main_async_safe(^{
                sucBlock();
            });
        }
        [db close];
    });
}

/**
 获取本地数据库存储的设备列表

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)getLocalDeviceListWithSucBlock:(void (^)(NSArray <MKDeviceModel *>*deviceList))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock{
    dispatch_queue_t queueInsert = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueInsert, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationGetDataFailedBlock:failedBlock];
            return;
        }
        NSMutableArray *dataList = [NSMutableArray array];
        FMResultSet * result = [db executeQuery:@"SELECT * FROM deviceTable"];
        while ([result next]) {
            MKDeviceModel *deviceModel = [[MKDeviceModel alloc] init];
            deviceModel.local_name = [result stringForColumn:@"local_name"];
            deviceModel.device_mac = [result stringForColumn:@"device_mac"];
            deviceModel.device_name = [result stringForColumn:@"device_name"];
            deviceModel.device_icon = [result stringForColumn:@"device_icon"];
            deviceModel.device_specifications = [result stringForColumn:@"device_specifications"];
            deviceModel.device_function = [result stringForColumn:@"device_function"];
            [dataList addObject:deviceModel];
        }
        [db close];
        if (sucBlock) {
            dispatch_main_async_safe(^{
                sucBlock(dataList);
            });
        }
    });
}

/**
 更新本地deviceModel，Key为mac地址
 
 @param deviceModel model
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)updateDevice:(MKDeviceModel *)deviceModel
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
            return;
        }
        BOOL resUpdate = [db executeUpdate:@"UPDATE deviceTable SET device_name = ? ,local_name = ?,device_icon = ? , device_specifications = ? ,device_function = ? WHERE device_mac = ?",                          SafeStr(deviceModel.device_name),SafeStr(deviceModel.local_name),SafeStr(deviceModel.device_icon),SafeStr(deviceModel.device_specifications),SafeStr(deviceModel.device_function),SafeStr(deviceModel.device_mac)];
        [db close];
        if (!resUpdate) {
            [MKDeviceDataBaseAdopter operationUpdateFailedBlock:failedBlock];
            return;
        }
        if (sucBlock) {
            dispatch_main_async_safe(^{
                sucBlock();
            });
        }
    });
}

/**
 删除指定mac地址的设备

 @param device_mac mac 地址
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)deleteDeviceWithMacAddress:(NSString *)device_mac
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock{
    if (!ValidStr(device_mac)) {
        [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
        return;
    }
    dispatch_queue_t queueUpdate = dispatch_queue_create(MKDeviceDataBaseOperationQueue,DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueUpdate, ^{
        FMDatabase* db = [FMDatabase databaseWithPath:deviceDBPath];
        if (![db open]) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        BOOL result = [db executeUpdate:@"DELETE FROM deviceTable WHERE device_mac = ?",device_mac];
        if (!result) {
            [MKDeviceDataBaseAdopter operationDeleteFailedBlock:failedBlock];
            return;
        }
        if (sucBlock) {
            dispatch_main_async_safe(^{
                sucBlock();
            });
        }
    });
}

@end

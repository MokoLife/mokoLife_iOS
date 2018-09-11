//
//  MKDeviceDataBaseManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceDataBaseManager.h"
#import "MKDeviceDataBaseAdopter.h"

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
        
        BOOL resCreate = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceTable (device_mode text NOT NULL,device_mac text NOT NULL,device_type text NOT NULL ,local_name text NOT NULL,device_name text NOT NULL, device_icon text NOT NULL, device_specifications text NOT NULL, device_function text NOT NULL,swich_way_nameDic text NOT NULL);"];
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
                NSString *swichListJsonString = @"";
                if (model.device_mode == MKDevice_swich && !ValidDict(model.swich_way_nameDic)) {
                    //默认插入三路面板状态
                    NSDictionary *jsonDic = @{
                                              @"switch_state_01":@"Switch1",
                                              @"switch_state_02":@"Switch2",
                                              @"switch_state_03":@"Switch3",
                                              };
                    swichListJsonString = [jsonDic jsonStringEncoded];
                }
                if (model.device_mode == MKDevice_swich && ValidDict(model.swich_way_nameDic)) {
                    swichListJsonString = [model.swich_way_nameDic jsonStringEncoded];
                }
                [db executeUpdate:@"UPDATE deviceTable SET device_mode = ?, device_type = ?, device_name = ? ,local_name = ?,device_icon = ? , device_specifications = ? ,device_function = ? ,swich_way_nameDic = ? WHERE device_mac = ?",[NSString stringWithFormat:@"%ld",(long)model.device_mode], SafeStr(model.device_type),                         SafeStr(model.device_name),SafeStr(model.local_name),SafeStr(model.device_icon),SafeStr(model.device_specifications),SafeStr(model.device_function),swichListJsonString,SafeStr(model.device_mac)];
            }else{
                //不存在，插入设备
                NSString *mode = [NSString stringWithFormat:@"%ld",(long)model.device_mode];
                NSString *swichListJsonString = @"";
                if (model.device_mode == MKDevice_swich && !ValidDict(model.swich_way_nameDic)) {
                    //默认插入三路面板状态
                    NSDictionary *jsonDic = @{
                                              @"switch_state_01":@"Switch1",
                                              @"switch_state_02":@"Switch2",
                                              @"switch_state_03":@"Switch3",
                                              };
                    swichListJsonString = [jsonDic jsonStringEncoded];
                }
                if (model.device_mode == MKDevice_swich && ValidDict(model.swich_way_nameDic)) {
                    swichListJsonString = [model.swich_way_nameDic jsonStringEncoded];
                }
                [db executeUpdate:@"INSERT INTO deviceTable (device_mode, device_mac, device_type, local_name, device_name, device_icon, device_specifications, device_function, swich_way_nameDic) VALUES (?,?,?,?,?,?,?,?,?);",mode
                 ,SafeStr(model.device_mac),SafeStr(model.device_type),SafeStr(model.local_name),SafeStr(model.device_name),SafeStr(model.device_icon),SafeStr(model.device_specifications),SafeStr(model.device_function),swichListJsonString];
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
            deviceModel.device_mode = [[result stringForColumn:@"device_mode"] integerValue];
            deviceModel.local_name = [result stringForColumn:@"local_name"];
            deviceModel.device_mac = [result stringForColumn:@"device_mac"];
            deviceModel.device_type = [result stringForColumn:@"device_type"];
            deviceModel.device_name = [result stringForColumn:@"device_name"];
            deviceModel.device_icon = [result stringForColumn:@"device_icon"];
            deviceModel.device_specifications = [result stringForColumn:@"device_specifications"];
            deviceModel.device_function = [result stringForColumn:@"device_function"];
            if (deviceModel.device_mode == MKDevice_swich) {
                NSString *nameDicString = [result stringForColumn:@"swich_way_nameDic"];
                deviceModel.swich_way_nameDic = [nameDicString jsonValueDecoded];
            }
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
        NSString *swichListJsonString = @"";
        if (deviceModel.device_mode == MKDevice_swich && !ValidDict(deviceModel.swich_way_nameDic)) {
            //默认插入三路面板状态
            NSDictionary *jsonDic = @{
                                      @"switch_state_01":@"Switch1",
                                      @"switch_state_02":@"Switch2",
                                      @"switch_state_03":@"Switch3",
                                      };
            swichListJsonString = [jsonDic jsonStringEncoded];
        }
        if (deviceModel.device_mode == MKDevice_swich && ValidDict(deviceModel.swich_way_nameDic)) {
            swichListJsonString = [deviceModel.swich_way_nameDic jsonStringEncoded];
        }
        BOOL resUpdate = [db executeUpdate:@"UPDATE deviceTable SET device_mode = ?, device_type = ?, device_name = ? ,local_name = ?,device_icon = ? , device_specifications = ? ,device_function = ? ,swich_way_nameDic = ? WHERE device_mac = ?",[NSString stringWithFormat:@"%ld",(long)deviceModel.device_mode], SafeStr(deviceModel.device_type),                         SafeStr(deviceModel.device_name),SafeStr(deviceModel.local_name),SafeStr(deviceModel.device_icon),SafeStr(deviceModel.device_specifications),SafeStr(deviceModel.device_function),swichListJsonString,SafeStr(deviceModel.device_mac)];
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

/**
 根据mac地址查询localName

 @param device_mac mac地址
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)selectLocalNameWithMacAddress:(NSString *)device_mac
                             sucBlock:(void (^)(NSString *localName))sucBlock
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
        FMResultSet * result = [db executeQuery:@"select * from deviceTable where device_mac = ?",device_mac];
        NSString *localName = @"";
        while ([result next]) {
            localName = [result stringForColumn:@"local_name"];
        }
        [db close];
        if (sucBlock) {
            dispatch_main_async_safe(^{
                sucBlock(localName);
            });
        }
    });
}

@end

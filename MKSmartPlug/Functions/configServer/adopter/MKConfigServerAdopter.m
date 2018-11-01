//
//  MKConfigServerAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerAdopter.h"
#import "MKConfigServerHostCell.h"
#import "MKConfigServerPortCell.h"
#import "MKConfigServerConnectModeCell.h"
#import "MKConfigServerQosCell.h"
#import "MKConfigServerNormalCell.h"
#import "MKConfigServerPickView.h"
#import "MKConfigServerCellProtocol.h"
#import "MKConfigServerModel.h"
#import "MKConfigServerController.h"
#import "twlt_uuid_util.h"

@implementation MKConfigServerAdopter

+ (UILabel *)configServerDefaultMsgLabel{
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    return msgLabel;
}

+ (CGFloat)defaultMsgLabelHeight{
    return MKFont(15.f).lineHeight;
}

+ (UITableViewCell *)configCellWithIndexPath:(NSIndexPath *)indexPath
                                       table:(UITableView *)tableView
                                 configModel:(MKConfigServerModel *)configModel
                                       isApp:(BOOL)isApp{
    if (indexPath.row == 0) {
        //host
        MKConfigServerHostCell *cell = [MKConfigServerHostCell initCellWithTableView:tableView];
        [cell setParams:configModel.host];
        return cell;
    }
    if (indexPath.row == 1) {
        //port
        MKConfigServerPortCell *cell = [MKConfigServerPortCell initCellWithTableView:tableView];
        NSDictionary *params = @{
                                 @"port":SafeStr(configModel.port),
                                 @"clean":@(configModel.cleanSession)
                                 };
        [cell setParams:params];
        return cell;
    }
    if (indexPath.row == 2) {
        //connect mode
        MKConfigServerConnectModeCell *cell = [MKConfigServerConnectModeCell initCellWithTableView:tableView];
        [cell setParams:@(configModel.connectMode)];
        return cell;
    }
    if (indexPath.row == 3) {
        //qos
        MKConfigServerQosCell *cell = [MKConfigServerQosCell initCellWithTableView:tableView];
        NSDictionary *dic = @{
                              @"qos":SafeStr(configModel.qos),
                              @"keepAlive":SafeStr(configModel.keepAlive),
                              };
        [cell setParams:dic];
        return cell;
    }
    if (isApp) {
        //app
        if (indexPath.row == 4) {
            //client id
            MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
            cell.msg = @"Client Id";
            NSString *clientId = SafeStr(configModel.clientId);
            if (!ValidStr(clientId)) {
                //如果没有有效值，则默认用手机uuid
                clientId = twlt_uuid_create();//设备唯一标识
            }
            [cell setParams:clientId];
            return cell;
        }
        if (indexPath.row == 5) {
            //Username
            MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
            cell.msg = @"Username";
            [cell setParams:SafeStr(configModel.userName)];
            return cell;
        }
        //Password
        MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
        cell.msg = @"Password";
        cell.secureTextEntry = YES;
        [cell setParams:SafeStr(configModel.password)];
        return cell;
    }
    //device
    if (indexPath.row == 4) {
        //Username
        MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
        cell.msg = @"Username";
        [cell setParams:SafeStr(configModel.userName)];
        return cell;
    }
    //Password
    MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
    cell.msg = @"Password";
    cell.secureTextEntry = YES;
    [cell setParams:SafeStr(configModel.password)];
    return cell;
}

/**
 所有带输入框的cell取消第一响应者
 */
+ (void)configCellResignFirstResponderWithTable:(UITableView *)tableView{
    for (NSInteger row = 0; row < [tableView numberOfRowsInSection:0]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        id <MKConfigServerCellProtocol>cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(hiddenKeyBoard)]) {
            [cell hiddenKeyBoard];
        }
    }
}


/**
 获取当前配置的服务器数据

 @param tableView tableView
 @param isApp 配置app的服务器信息还是设备的服务器信息
 @return model
 */
+ (MKConfigServerModel *)currentServerModelWithTable:(UITableView *)tableView isApp:(BOOL)isApp{
    MKConfigServerModel *serverModel = [[MKConfigServerModel alloc] init];
    
    //host
    NSIndexPath *hostPath = [NSIndexPath indexPathForRow:0 inSection:0];
    id <MKConfigServerCellProtocol>hostCell = [tableView cellForRowAtIndexPath:hostPath];
    NSDictionary *hostDic = [hostCell configServerCellValue];
    serverModel.host = hostDic[@"host"];
    
    //port
    NSIndexPath *portPath = [NSIndexPath indexPathForRow:1 inSection:0];
    id <MKConfigServerCellProtocol>portCell = [tableView cellForRowAtIndexPath:portPath];
    NSDictionary *portDic = [portCell configServerCellValue];
    if (ValidStr(portDic[@"port"])) {
        serverModel.port = [NSString stringWithFormat:@"%ld",(long)[portDic[@"port"] integerValue]];
    }
    serverModel.cleanSession = [portDic[@"cleanSession"] boolValue];
    
    //connect mode
    NSIndexPath *connectModePath = [NSIndexPath indexPathForRow:2 inSection:0];
    id <MKConfigServerCellProtocol>connectModeCell = [tableView cellForRowAtIndexPath:connectModePath];
    NSDictionary *connectModeDic = [connectModeCell configServerCellValue];
    serverModel.connectMode = [connectModeDic[@"connectMode"] integerValue];
    
    //qos
    NSIndexPath *qosPath = [NSIndexPath indexPathForRow:3 inSection:0];
    id <MKConfigServerCellProtocol>qosCell = [tableView cellForRowAtIndexPath:qosPath];
    NSDictionary *qosDic = [qosCell configServerCellValue];
    serverModel.qos = qosDic[@"qos"];
    if (ValidStr(qosDic[@"keepAlive"])) {
        serverModel.keepAlive = [NSString stringWithFormat:@"%ld",(long)[qosDic[@"keepAlive"] integerValue]];
    }
    
    if (isApp) {
        //app
        //client id
        NSIndexPath *clientIdPath = [NSIndexPath indexPathForRow:4 inSection:0];
        id <MKConfigServerCellProtocol>clientIdCell = [tableView cellForRowAtIndexPath:clientIdPath];
        NSDictionary *clientIdDic = [clientIdCell configServerCellValue];
        serverModel.clientId = clientIdDic[@"paramValue"];
        
        //userName
        NSIndexPath *userNamePath = [NSIndexPath indexPathForRow:5 inSection:0];
        id <MKConfigServerCellProtocol>userNameCell = [tableView cellForRowAtIndexPath:userNamePath];
        NSDictionary *userNameDic = [userNameCell configServerCellValue];
        serverModel.userName = userNameDic[@"paramValue"];
        
        //password
        NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:6 inSection:0];
        id <MKConfigServerCellProtocol>passwordCell = [tableView cellForRowAtIndexPath:passwordPath];
        NSDictionary *passwordDic = [passwordCell configServerCellValue];
        serverModel.password = passwordDic[@"paramValue"];
    }else{
        
        //userName
        NSIndexPath *userNamePath = [NSIndexPath indexPathForRow:4 inSection:0];
        id <MKConfigServerCellProtocol>userNameCell = [tableView cellForRowAtIndexPath:userNamePath];
        NSDictionary *userNameDic = [userNameCell configServerCellValue];
        serverModel.userName = userNameDic[@"paramValue"];
        
        //password
        NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:5 inSection:0];
        id <MKConfigServerCellProtocol>passwordCell = [tableView cellForRowAtIndexPath:passwordPath];
        NSDictionary *passwordDic = [passwordCell configServerCellValue];
        serverModel.password = passwordDic[@"paramValue"];
    }
    
    return serverModel;
}

/**
 右上角清除按钮点了之后，将所有cell上面的信息恢复成默认的
 */
+ (void)clearAllConfigCellValuesWithTable:(UITableView *)tableView{
    for (NSInteger row = 0; row < [tableView numberOfRowsInSection:0]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        id <MKConfigServerCellProtocol>cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(setToDefaultParameters)]) {
            [cell setToDefaultParameters];
        }
    }
}

/**
 Qos选择
 
 @param currentData 当前Qos值
 @param confirmBlock 选择之后的回调
 */
+ (void)showQosPickViewWithCurrentData:(NSString *)currentData
                          confirmBlock:(void (^)(NSString *data, NSInteger selectedRow))confirmBlock{
    NSArray *dataList = @[@"0",@"1",@"2"];
    MKConfigServerPickView *pickView = [[MKConfigServerPickView alloc] init];
    [pickView showConfigServerPickViewWithDataList:dataList currentData:currentData block:confirmBlock];
}

/**
 右上角clear按钮点击事件
 
 @param confirmAction 确认
 @param cancelAction 取消
 */
+ (void)clearAction:(void (^)(void))confirmAction cancelAction:(void (^)(void))cancelAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Clear All Parameters"
                                                                             message:@"Please confirm whether to clear all parameters"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       if (cancelAction) {
                                                           cancelAction();
                                                       }
                                                   }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        if (confirmAction) {
                                                            confirmAction();
                                                        }
                                                    }];
    
    [alertController addAction:cancel];
    [alertController addAction:confirm];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

/**
 各项参数是否正确

 @param serverModel 当前配置的服务器参数
 @param target MKConfigServerController
 @return YES:正确，NO:存在参数错误
 */
+ (BOOL)checkConfigServerParams:(MKConfigServerModel *)serverModel target:(MKConfigServerController *)target{
    if (![serverModel.host checkIsUrl] && ![serverModel.host isValidatIP]) {
        //host校验错误
        [target.view showCentralToast:@"Host error"];
        return NO;
    }
    if (!ValidStr(serverModel.port)) {
        [target.view showCentralToast:@"Port error"];
        return NO;
    }
    if ([serverModel.port integerValue] < 0 || [serverModel.port integerValue] > 65535) {
        //port错误
        [target.view showCentralToast:@"Port range : 0~65535"];
        return NO;
    }
    if (!ValidStr(serverModel.keepAlive)) {
        [target.view showCentralToast:@"Keep alive range : 60~120"];
        return NO;
    }
    if ([serverModel.keepAlive integerValue] < 60 || [serverModel.keepAlive integerValue] > 120) {
        [target.view showCentralToast:@"Keep alive range : 60~120"];
        return NO;
    }
    if (target.controllerType == MKConfigServerForApp) {
        //app，不能为空并且最大32个字符
        if (!ValidStr(serverModel.clientId) || serverModel.clientId.length > 32) {
            //client id错误
            [target.view showCentralToast:@"Client id error"];
            return NO;
        }
    }
    
    if (!ValidStr(serverModel.userName) || serverModel.userName.length > 32) {
        //user name错误
        [target.view showCentralToast:@"User name error"];
        return NO;
    }
    if (!ValidStr(serverModel.password) || serverModel.password.length > 32) {
        //passwrod错误
        [target.view showCentralToast:@"Password error"];
        return NO;
    }
    return YES;
}

+ (void)saveDataToLocal:(MKConfigServerModel *)serverModel target:(MKConfigServerController *)target{
    if (target.controllerType == MKConfigServerForApp) {
        [[MKMQTTServerDataManager sharedInstance] saveServerConfigDataToLocal:serverModel];
        [[MKMQTTServerDataManager sharedInstance] connectServer];
        if (![[MKSmartPlugConnectManager sharedInstance].configServerModel needParametersHasValue]) {
            //如果设置给plug的mqtt服务器信息没有，去设置
            MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
            vc.controllerType = MKConfigServerForSmartPlug;
            [target.navigationController pushViewController:vc animated:YES];
            return;
        }
        [target.navigationController popViewControllerAnimated:YES];
        return;
    }
    [[MKSmartPlugConnectManager sharedInstance] saveServerConfigDataToLocal:serverModel];
    if (![[MKMQTTServerDataManager sharedInstance].configServerModel needParametersHasValue]) {
        //如果app的mqtt服务器信息没有，则去设置
        MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
        vc.controllerType = MKConfigServerForApp;
        [target.navigationController pushViewController:vc animated:YES];
        return;
    }
    UIViewController *popController = nil;
    for (UIViewController *v in target.navigationController.viewControllers) {
        if ([v isKindOfClass:NSClassFromString(@"MKSettingsController")]) {
            popController = v;
            break;
        }
    }
    if (!popController) {
        //从主页面直接过来的
        [target.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [target.navigationController popViewControllerAnimated:YES];
}

@end

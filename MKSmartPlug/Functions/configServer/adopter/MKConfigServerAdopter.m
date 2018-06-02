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

@implementation MKConfigServerAdopter

+ (UILabel *)configServerDefaultMsgLabel{
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = HCKFont(15.f);
    return msgLabel;
}

+ (CGFloat)defaultMsgLabelHeight{
    return HCKFont(15.f).lineHeight;
}

+ (UITextField *)configServerTextField{
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = COLOR_WHITE_MACROS;
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = HCKFont(15.f);
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
    textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
    textField.layer.cornerRadius = 5.f;
    return textField;
}

+ (UITableViewCell *)configCellWithIndexPath:(NSIndexPath *)indexPath table:(UITableView *)tableView{
    if (indexPath.row == 0) {
        //host
        MKConfigServerHostCell *cell = [MKConfigServerHostCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.row == 1) {
        //port
        MKConfigServerPortCell *cell = [MKConfigServerPortCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.row == 2) {
        //connect mode
        MKConfigServerConnectModeCell *cell = [MKConfigServerConnectModeCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.row == 3) {
        //qos
        MKConfigServerQosCell *cell = [MKConfigServerQosCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.row == 4) {
        //client id
        MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        cell.msg = @"Client Id";
        return cell;
    }
    if (indexPath.row == 5) {
        //Username
        MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
        cell.indexPath = indexPath;
        cell.msg = @"Username";
        return cell;
    }
    //Password
    MKConfigServerNormalCell *cell = [MKConfigServerNormalCell initCellWithTableView:tableView];
    cell.indexPath = indexPath;
    cell.msg = @"Password";
    return cell;
}

/**
 所有带输入框的cell取消第一响应者
 */
+ (void)configCellResignFirstResponderWithTable:(UITableView *)tableView{
    for (NSInteger row = 0; row < 7; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        id <MKConfigServerCellProtocol>cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(resignFirstResponder)]) {
            [cell resignFirstResponder];
        }
    }
}

/**
 获取当前配置的服务器数据
 
 @return MKConfigServerModel
 */
+ (MKConfigServerModel *)currentServerModelWithTable:(UITableView *)tableView{
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
    serverModel.port = portDic[@"port"];
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
    serverModel.keepAlive = qosDic[@"keepAlive"];
    
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
    
    return serverModel;
}

/**
 右上角清除按钮点了之后，将所有cell上面的信息恢复成默认的
 */
+ (void)clearAllConfigCellValuesWithTable:(UITableView *)tableView{
    for (NSInteger row = 0; row < 7; row ++) {
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
+ (BOOL)checkConfigServerParams:(MKConfigServerModel *)serverModel target:(UIViewController *)target{
    if (![serverModel.host checkIsUrl] && ![serverModel.host isValidatIP]) {
        //host校验错误
        [target.view showCentralToast:@"Host error"];
        return NO;
    }
    if ([serverModel.port integerValue] < 0 || [serverModel.port integerValue] > 65535) {
        //port错误
        [target.view showCentralToast:@"Port effective range : 0~65535"];
        return NO;
    }
    if (![serverModel.clientId checkClientId]) {
        //client id错误
        [target.view showCentralToast:@"Client id error"];
        return NO;
    }
    if (![serverModel.userName checkUserName]) {
        //user name错误
        [target.view showCentralToast:@"User name error"];
        return NO;
    }
    if (![serverModel.password checkPassword]) {
        //passwrod错误
        [target.view showCentralToast:@"Password error"];
        return NO;
    }
    return YES;
}

@end

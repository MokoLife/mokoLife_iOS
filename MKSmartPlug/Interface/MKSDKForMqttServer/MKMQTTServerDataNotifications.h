
/*
 manager的状态发生改变通知
 */
static NSString *const MKMQTTServerManagerStateChangedNotification = @"MKMQTTServerManagerStateChangedNotification";

/*
 发送数据到服务器成功通知
 */
static NSString *const MKMQTTServerManagerSendDataSuccessNotification = @"MKMQTTServerManagerSendDataSuccessNotification";

/*
 接收到开关状态的通知
 */
static NSString *const MKMQTTServerReceivedSwitchStateNotification = @"MKMQTTServerReceivedSwitchStateNotification";

/*
 接收到倒计时的通知
 */
static NSString *const MKMQTTServerReceivedDelayTimeNotification = @"MKMQTTServerReceivedDelayTimeNotification";

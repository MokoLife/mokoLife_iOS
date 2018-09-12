
/*
 添加设备成功的时候设备列表页面需要重新读取设备
*/
static NSString *const MKNeedReadDataFromLocalNotification = @"MKNeedReadDataFromLocalNotification";

/*
 对于智能面板，当分路开关名字发生改变的时候，需要设备列表页面更新
 */
static NSString *const MKNeedUpdateSwichWayNameNotification = @"MKNeedUpdateSwichWayNameNotification";

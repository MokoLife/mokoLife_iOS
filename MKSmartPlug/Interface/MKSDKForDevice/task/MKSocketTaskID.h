
/*
 命令ID
 */
typedef NS_ENUM(NSInteger, MKSocketTaskID){
    socketUnknowTask = 0,                           //初始状态
    socketReadDeviceInformationTask = 1,            //读取设备信息
    socketConfigMQTTServerTask = 2,                 //配置mqtt服务器信息
    socketConfigWifiTask = 3,                       //配置plug要连接的wifi
};


/*
 命令ID
 */
typedef NS_ENUM(NSInteger, MKSocketTaskID){
    socketUnknowTask,                           //初始状态
    socketReadDeviceInformationTask,            //读取设备信息
    socketConfigMQTTServerTask,                 //配置mqtt服务器信息
    socketConfigWifiTask,                       //配置plug要连接的wifi
};

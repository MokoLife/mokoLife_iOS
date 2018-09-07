
/**
 设备类型

 - MKDevice_plug: 智能插座
 - MKDevice_swich: 智能面板
 */
typedef NS_ENUM(NSInteger, MKDeviceType) {
    MKDevice_plug,
    MKDevice_swich,
};

/**
 智能插座状态

 */
typedef NS_ENUM(NSInteger, MKSmartPlugState) {
    MKSmartPlugOffline,             //离线状态
    MKSmartPlugOn,                  //在线并且打开
    MKSmartPlugOff,           //在线并且关闭
};

typedef NS_ENUM(NSInteger, deviceModelTopicType) {
    deviceModelTopicDeviceType,             //设备发布数据的主题
    deviceModelTopicAppType,                //APP发布数据的主题
};


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

/**
 智能面板状态
 */
typedef NS_ENUM(NSInteger, MKSmartSwichState) {
    MKSmartSwichOffline,
    MKSmartSwichOnline,             //只有在线和离线两种状态
};

typedef NS_ENUM(NSInteger, deviceModelTopicType) {
    deviceModelTopicDeviceType,             //设备发布数据的主题
    deviceModelTopicAppType,                //APP发布数据的主题
};

@class MKDeviceModel;
/**
 设备在线状态发生改变
 */
@protocol MKDeviceModelDelegate <NSObject>

@optional
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel;

@end

@protocol MKDeviceModelProtocol <NSObject>

/**
 是否处于离线状态
 */
@property (nonatomic, assign, readonly)BOOL offline;

- (void)updatePropertyWithModel:(MKDeviceModel *)model;

/**
 设备列表页面的状态监控
 */
- (void)startStateMonitoringTimer;

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter;

/**
 取消定时器
 */
- (void)cancel;

@end

1、Support pod，pod ‘MKMqttServerSDK’, ‘~> 0.0.2’，pod ‘MKSocketSDK’, ‘~> 0.0.2’
2、Below the MKSDKForDevice folder is the SDK for configuring the smart plug, make sure that the mobile phone is currently connected to the plug hotspot,you can configure the smart plug by calling the interface below the MKSocketManager folder.
3、Below the MKSDKForMqttServer folder is the SDK for configuring the APP and mqttServer,the notification of the MKMQTTServerDataNotifications.h is the notification thrown by the SDK after receiving the relevant data,register the corresponding notification in the place where you need to accept the data, you can get the target data.

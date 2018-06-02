
@protocol MKConfigServerCellProtocol <NSObject>
/**
 获取当前cell显示的数值

 @return @{
    @"row":@(row),
    @"xx":@"xx"
    @"xx":@"xx"
 }
 */
- (NSDictionary *)configServerCellValue;

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters;

@optional

/**
 隐藏键盘
 */
- (void)resignFirstResponder;

@end

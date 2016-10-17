//
//  OCPullDownRefreshView.h
//  自定义下拉刷新控件
//
//  Created by Maple on 16/7/26.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCPullDownRefreshView : UIView

///下拉刷新执行的block
@property (nonatomic, copy) void (^refreshBlock)();

///结束刷新
- (void)endRefresh;

///开始刷新
- (void)beginRefresh;

@end

//
//  OCPullDownRefreshView.m
//  自定义下拉刷新控件
//
//  Created by Maple on 16/7/26.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "OCPullDownRefreshView.h"

typedef enum : NSUInteger {
  OCPullDownRefreshViewStatusNormal,  //下拉刷新
  OCPullDownRefreshViewStatusPulling, //释放刷新
  OCPullDownRefreshViewStatusRefresh, //正在刷新
} OCPullDownRefreshViewStatus;

@interface OCPullDownRefreshView ()
///记录父类
@property (nonatomic, strong) UIScrollView *mySuperview;
///记录当前状态
@property (nonatomic, assign) OCPullDownRefreshViewStatus currentStatus;
///箭头控件
@property (nonatomic, weak) UIImageView *arrwoImageView;
///加载控件
@property (nonatomic, weak) UIImageView *loadingImageView;
///信息文本
@property (nonatomic, weak) UILabel *infoLabel;
@end

@implementation OCPullDownRefreshView

///结束刷新
- (void)endRefresh {
  if (self.currentStatus == OCPullDownRefreshViewStatusRefresh) {
    
    [UIView animateWithDuration:0.25 animations:^{
      //隐藏
      UIEdgeInsets inset = self.mySuperview.contentInset;
      inset.top = 64;
      self.mySuperview.contentInset = inset;
    }];
    self.loadingImageView.hidden = YES;
    self.arrwoImageView.hidden = NO;
    [self.loadingImageView.layer removeAllAnimations];
    self.currentStatus = OCPullDownRefreshViewStatusNormal;
  }
}

///开始刷新
- (void)beginRefresh {
  self.currentStatus = OCPullDownRefreshViewStatusRefresh;
}

- (void)setCurrentStatus:(OCPullDownRefreshViewStatus)currentStatus {
  _currentStatus = currentStatus;

  if (currentStatus == OCPullDownRefreshViewStatusNormal) {
    self.infoLabel.text = @"下拉刷新";
    [UIView animateWithDuration:0.25 animations:^{
      self.arrwoImageView.transform = CGAffineTransformIdentity;
    }];
  }else if(currentStatus == OCPullDownRefreshViewStatusPulling) {
    self.infoLabel.text = @"释放刷新";
    [UIView animateWithDuration:0.25 animations:^{
      self.arrwoImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
  }else if(currentStatus == OCPullDownRefreshViewStatusRefresh) {
    self.loadingImageView.hidden = NO;
    self.arrwoImageView.hidden = YES;
    self.infoLabel.text = @"正在刷新...";
    [UIView animateWithDuration:0.25 animations:^{
      //停留
      UIEdgeInsets inset = self.mySuperview.contentInset;
      inset.top = 124;
      self.mySuperview.contentInset = inset;
    }];
    
    //动画
    CABasicAnimation *ba = [CABasicAnimation animation];
    ba.keyPath = @"transform.rotation";
    ba.toValue = @(M_PI * 2);
    ba.duration = 0.75;
    ba.repeatCount = MAXFLOAT;
    ba.removedOnCompletion = NO;
    [self.loadingImageView.layer addAnimation:ba forKey:nil];
    //执行回调
    if (self.refreshBlock) {
      self.refreshBlock();
    }
  }
}

- (instancetype)initWithFrame:(CGRect)frame {
  CGRect newFrame = CGRectMake(0, -60, [UIScreen mainScreen].bounds.size.width, 60);
  if (self = [super initWithFrame:newFrame]) {
    self.backgroundColor = [UIColor brownColor];
    self.currentStatus = OCPullDownRefreshViewStatusNormal;
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.loadingImageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.arrwoImageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.loadingImageView.hidden = YES;
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-30]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrwoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrwoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.arrwoImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:10]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.arrwoImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
  
}

///添加监听
- (void)willMoveToSuperview:(UIView *)newSuperview {
  if ([newSuperview isKindOfClass:[UIScrollView class]]) {
    self.mySuperview = (UIScrollView *)newSuperview;
    [self.mySuperview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
  }
}

- (void)dealloc {
  [self.mySuperview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
  //是否在拖拽中
  if (self.mySuperview.isDragging) {
    //下拉刷新： offy > -124
    if (self.currentStatus == OCPullDownRefreshViewStatusPulling && self.mySuperview.contentOffset.y > -124) {
      self.currentStatus = OCPullDownRefreshViewStatusNormal;
    }else if (self.currentStatus == OCPullDownRefreshViewStatusNormal && self.mySuperview.contentOffset.y < -124 ) {
      //释放刷新
      self.currentStatus = OCPullDownRefreshViewStatusPulling;
    }
  }else {
    //正在刷新
    if (self.currentStatus == OCPullDownRefreshViewStatusPulling && self.mySuperview.contentOffset.y < -124) {
      self.currentStatus = OCPullDownRefreshViewStatusRefresh;
    }
  }
}

#pragma mark 懒加载
- (UIImageView *)arrwoImageView {
  if (_arrwoImageView == nil) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_pull_refresh"]];
    [self addSubview:imageView];
    _arrwoImageView = imageView;
  }
  return _arrwoImageView;
}

- (UIImageView *)loadingImageView {
  if (_loadingImageView == nil) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_loading"]];
    [self addSubview:imageView];
    _loadingImageView = imageView;
  }
  return _loadingImageView;
}

- (UILabel *)infoLabel {
  if (_infoLabel == nil) {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"下拉刷新";
    label.font = [UIFont systemFontOfSize:15];
    _infoLabel = label;
    [self addSubview:label];
  }
  return _infoLabel;
}
                              
                              


@end

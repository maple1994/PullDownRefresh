//
//  ViewController.m
//  自定义下拉刷新控件
//
//  Created by Maple on 16/7/26.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "ViewController.h"
#import "OCPullDownRefreshView.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, weak) OCPullDownRefreshView *pullDownRefreshView;
@end

@implementation ViewController

static NSString *resuedID = @"resuedID";
static NSInteger COUNT = 0;
- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:resuedID];
  
  self.data = [self loadData];

  self.pullDownRefreshView.refreshBlock = ^ {
    NSArray *tempData = [self loadData];
    [self.data addObjectsFromArray:tempData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.pullDownRefreshView endRefresh];
      [self.tableView reloadData];
    });
  };
}

// 模型数据
- (NSMutableArray *)loadData {
  NSMutableArray *array = [NSMutableArray array];
  for (int i = 0; i < 5; i++) {
    NSString *name = [NSString stringWithFormat:@"maple%zd", COUNT];
    COUNT++;
    [array addObject:name];
  }
  return array;
}

#pragma mark tableview数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.data ? self.data.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuedID forIndexPath:indexPath];
  cell.textLabel.text = self.data[indexPath.row];
  return cell;
}

#pragma mark getter
- (OCPullDownRefreshView *)pullDownRefreshView {
  if(_pullDownRefreshView == nil) {
    OCPullDownRefreshView *pullDownRefreshView = [[OCPullDownRefreshView alloc] init];
    _pullDownRefreshView = pullDownRefreshView;
    [self.tableView addSubview:_pullDownRefreshView];
  }
  return _pullDownRefreshView;
}

@end

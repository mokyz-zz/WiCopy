//
//  ViewController.m
//  WiCopy
//
//  Created by 张志辉 on 2017/11/1.
//  Copyright © 2017年 Moky. All rights reserved.
//

#import "ViewController.h"

static NSString * kWiCopyBonjourType = @"_wicopy2._tcp.";
static NSString *reuseID = @"cell";
@interface ViewController () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSNetService *server;
@property (nonatomic, strong) NSNetServiceBrowser *browser;

/** 当前可连接的设备*/
@property (nonatomic, strong) NSMutableArray *services;
/** 已连接过的设备*/
@property (nonatomic, strong) NSArray *connectedEquipments;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseID];
    
    self.navigationItem.title = @"WiCopy";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    
    self.services = [NSMutableArray array];
    
    [self setupServer];
    
}

- (void)setupServer
{
    NSNetService *server = [[NSNetService alloc] initWithDomain:@"local." type:kWiCopyBonjourType name:[UIDevice currentDevice].name port:0];
    server.delegate = self;
    server.includesPeerToPeer = YES;
    [server setDelegate:self];
    [server publishWithOptions:NSNetServiceListenForConnections];
    self.server = server;
    // 发布
    [self start];
}

- (void)start
{
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.includesPeerToPeer = YES;
    [self.browser setDelegate:self];
    [self.browser searchForServicesOfType:kWiCopyBonjourType inDomain:@"local"];
}

- (void)stop
// See comment in header.
{
    [self.browser stop];
    self.browser = nil;
    
    [self.services removeAllObjects];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - NSNetServiceDelegate


#pragma mark - UITableDelegate & UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.services.count;
    } else {
        return 5;//self.connectedEquipments.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"可连接设备";
    } else {
        return @"连接过的设备";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    NSNetService *service = self.services[indexPath.row];
    cell.textLabel.text = service.name;
    return cell;
}

@end

//
//  FDSJChatController.m
//  chatTestDemo
//
//  Created by Linshi on 2018/4/19.
//  Copyright © 2018年 Linshi. All rights reserved.
//

#import "FDSJChatController.h"
#import "UUMessageFrame.h"
#import "UUInputFunctionView.h"
#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUChatCategory.h"
#import "HttpRequestManager.h"
#import "MJExtension.h"
#import "FDSJChatModel.h"
#import "chatTestDemo-swift.h"

@interface FDSJChatController ()<UUInputFunctionViewDelegate, UUMessageCellDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _keyboardHeight;
}
//聊天数据模型
//@property (strong, nonatomic) ChatModel *chatModel;
//聊天table
@property (strong, nonatomic) UITableView         *chatTableView;
//聊天工具条
@property (strong, nonatomic) UUInputFunctionView *inputFuncView;
//聊天数据数组
@property (strong, nonatomic) NSMutableArray      *chatArrays;
/*!
 @property 客户端socket
 @abstract 客户端socket
 */
@property (nonatomic, strong) SocketIOClient *clientSocket;
@end

@implementation FDSJChatController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustCollectionViewLayout) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self tableViewScrollToBottom];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //连接服务器
    [self.clientSocket connect];
    [self.clientSocket on:@"connection" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        NSLog(@"亲，服务器连接成功！");
    }];
    [self fdsj_setUpUI];
    [self fdsj_loadRequest];
    self.chatTableView.frame = CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40);
    self.inputFuncView.frame = CGRectMake(0, self.chatTableView.uu_bottom, self.view.uu_width, 40);
}


#pragma mark -- privite methods
- (void)fdsj_setUpUI {
    [self.view addSubview:self.chatTableView];
    [self.chatTableView registerClass:[UUMessageCell class] forCellReuseIdentifier:NSStringFromClass([UUMessageCell class])];
    [self.view addSubview:self.inputFuncView];
}
/**
 加载数据
 */
- (void)fdsj_loadRequest {
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"page", nil];
    [HttpRequestManager GET:@"http://192.168.31.163:3000/api/rooms/1/messages" parameters:dic success:^(id responseObject) {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        arr = [FDSJChatModel mj_objectArrayWithKeyValuesArray:responseObject[@"messages"]];
        for (FDSJChatModel *chatModel in arr) {
            UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
            [messageFrame setChatModel:chatModel];
            
            [self.chatArrays addObject:messageFrame];
        }
        [self.chatTableView reloadData];
        } failure:^(NSError *error) {
        
    }];
    [self.chatTableView reloadData];
}


#pragma mark - notification event
//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatArrays.count==0) { return; }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatArrays.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    _keyboardHeight = keyboardEndFrame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.chatTableView.uu_height = self.view.uu_height - _inputFuncView.uu_height;
    self.chatTableView.uu_height -= notification.name == UIKeyboardWillShowNotification ? _keyboardHeight:0;
    self.chatTableView.contentOffset = CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.uu_height);
    
    self.inputFuncView.uu_top = self.chatTableView.uu_bottom;
    
    [UIView commitAnimations];
}

- (void)adjustCollectionViewLayout
{
    [self.chatTableView reloadData];
}

/*!
@method  收到 text
@abstract 收到 text，数据处理
*/
- (void)receiveText {
    [self.clientSocket on:@"text" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        NSLog(@"%@", array);
//        NSString *data = array.firstObject;
        [self.chatTableView reloadData];
        }];
    
}


#pragma mark - tableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatArrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UUMessageCell class])];
    cell.delegate = self;
    [cell setMessageFrame:self.chatArrays[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return [self.chatArrays[indexPath.row] cellHeight];
}


#pragma mark - InputFunctionViewDelegate

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"content": message,
                          @"type": @"text"};
    NSDictionary *Dic = @{@"message": dic};
    [HttpRequestManager POST:@"http://192.168.31.163:3000/api/rooms/1/messages" parameters:Dic success:^(id responseObject) {
        [self.chatTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
#warning 测试
    //socket发送数据
    [self.clientSocket emit:@"" with:@[@"1"]];
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
//    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}


#pragma mark -- lazy load
- (UITableView *)chatTableView {
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40) style:UITableViewStylePlain];
        _chatTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
    }
    return _chatTableView;
}

- (UUInputFunctionView *)inputFuncView {
    if (!_inputFuncView) {
        _inputFuncView = [[UUInputFunctionView alloc] initWithFrame:CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40)];
        _inputFuncView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _inputFuncView.delegate = self;
    }
    return _inputFuncView;
}

- (NSMutableArray *)chatArrays {
    if (!_chatArrays) {
        _chatArrays = [[NSMutableArray alloc]init];
    }
    return _chatArrays;
}

/*!
 @method 懒加载
 @abstract 初始化客户端socket对象
 @result 客户端socket对象
 */
- (SocketIOClient *)clientSocket {
    if (!_clientSocket) {
        NSURL *url = [NSURL URLWithString:@"http://192.168.31.163:3000"];
        _clientSocket = [[SocketIOClient alloc]initWithSocketURL:url
                                                          config:@{@"log": @YES, @"forcePolling": @YES}];
        
    }
    return _clientSocket;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

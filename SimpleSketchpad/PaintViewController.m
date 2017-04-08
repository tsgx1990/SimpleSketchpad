//
//  PaintViewController.m
//  SimpleSketchpad
//
//  Created by guanglong on 2017/4/8.
//  Copyright © 2017年 bjhl. All rights reserved.
//

#import "PaintViewController.h"
#import "SKView.h"

@interface PaintViewController ()

@property (weak, nonatomic) IBOutlet SKView *paintView;

@end

@implementation PaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revokeBtnPressed:(UIButton*)sender
{
//    [self.paintView removeLastPath];
    [self.paintView removeLastPathAutomatically];
}

- (IBAction)revokeByPoint:(id)sender
{
//    [self.paintView removeByPoint];
    [self.paintView removeByPointAutomatically];
}

- (IBAction)removeAllBtnPressed:(id)sender
{
    [self.paintView removeAllPaths];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

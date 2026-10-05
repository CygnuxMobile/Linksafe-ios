//
//  BRPrintResultViewController.h
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BRWLANPrintOperation.h"
#import "BRBluetoothPrintOperation.h"

@protocol BRPrintResultViewControllerDelegate <NSObject>
- (void) showPrintResultForWLAN;
- (void) showPrintResultForBluetooth;
@end

@interface BRPrintResultViewController : UIViewController<BRWLANPrintOperationDelegate, BRBluetoothPrintOperationDelegate>
{
}
@property (nonatomic, weak)id<BRPrintResultViewControllerDelegate> delegate;
@property (nonatomic, strong)NSMutableArray *imagePathArray;

@property(nonatomic, strong) NSMutableDictionary *visitorDetails;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpscrollview;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *vadidateButton;
@property (weak, nonatomic) IBOutlet UILabel *lbInstruction;

@property (retain, nonatomic) NSString *navTitle;

@property (nonatomic) BOOL isReprint;

@end

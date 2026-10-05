//
//  MeetingWithVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "MeetingWithVC.h"
#import "SiteApproverScreenVC.h"
#import "TakePhotoVC.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"
#import "UITextField+Additions.h"
#import "UserDetailsVC.h"
#import "UserRegistrationVC.h"
#import "VisitorBehaviourVC.h"
#import "VisitorCustomQuestionVC.h"
#import "VisitorInductionVC.h"

@interface MeetingWithVC () <UITextFieldDelegate, UITableViewDelegate,
                             UITableViewDataSource> {
  NSDictionary *selectedContractor;
}

@property(nonatomic, strong) NSMutableArray *arrContacts;
@property(nonatomic, strong) NSMutableArray *arrTempAllContacts;
@property(weak, nonatomic) IBOutlet UITableView *siteListview;

@end

@implementation MeetingWithVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [FIRAnalytics logEventWithName:@"Meeting Screen"
                      parameters:@{@"onload" : @"13"}];
  [self getAllContacts];

  self.siteListview.hidden = YES;
  self.siteListview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  self.txtSearch.returnKeyType = UIReturnKeyDone;
  self.txtSearch.delegate = self;
  self.txtSearch.placeholder = @"Search name here...";
  [self.txtSearch addTarget:self
                     action:@selector(textFieldDidChangeValue:)
           forControlEvents:UIControlEventEditingChanged];

  //    self.siteListview.keyboardDismissMode =
  //    UIScrollViewKeyboardDismissModeOnDrag;

  _lbName.text = [_visitorDetails valueForKey:@"firstName"];
  _lbLastName.text = [_visitorDetails valueForKey:@"lastName"];

  [_btnContinue applyBlueShedow];

  //    if ([Common appDelegate].isIpad)
  //    {
  [_txtSearch applyGrayBorderTheme];
  //    }
  //    else
  //    {
  //        [_txtSearch applyFlatTheme];
  //    }

  [self.view sendSubviewToBack:_btnContinue];
  UIView *view5501 = [self.view viewWithTag:5501];
  UIView *view5502 = [self.view viewWithTag:5502];
  [Common ApplyUIViewTheme:view5501];
  [Common ApplyUIViewTheme:view5502];
  [view5501.layer setBorderWidth:1.0f];
  [view5502.layer setBorderWidth:1.0f];

  [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
  AppDelegate *app =
      (AppDelegate *)[[UIApplication sharedApplication] delegate];
  if (!app.isIpad) {
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                        self.view.frame.size.height - 64 > 550
                                            ? self.view.frame.size.height - 64
                                            : 550);
    self.tpscrollview.contentSize =
        CGSizeMake(self.view.frame.size.width, _contentView.frame.size.height);
  } else {
    self.contentView.frame =
        CGRectMake(0, 0, self.view.frame.size.width,
                   ((self.view.frame.size.height - 64) > 704
                        ? (self.view.frame.size.height - 64)
                        : 704));
    self.tpscrollview.contentSize =
        CGSizeMake(self.view.frame.size.width, _contentView.frame.size.height);
  }
  self.contentView.clipsToBounds = YES;
  [Common setBgImage:self.view useDefault:YES];
  [Common applyThemeColorToPowerdBy:self.view];

  if (self.isForPreregister) {
    [self onClickYourInformation:nil];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.navTitle; //@"VISITOR SIGN IN";
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(upadteTime)
                                               name:N_UpdateTime
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateBackground)
                                               name:N_UpdateBackgroundImages
                                             object:nil];

  [self upadteTime];
}

- (void)viewWillDisappear:(BOOL)animated {
  self.navigationItem.title = @"";
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:N_UpdateTime
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:N_UpdateBackgroundImages
                                                object:nil];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
}

- (void)updateBackground {
  [Common setBgImage:self.view useDefault:YES];
}

- (void)upadteTime {
  [Common updateTime:self.view];
}

- (IBAction)onSideMenuClick:(id)sender {
  [self.menuContainerViewController toggleRightSideMenuCompletion:^{
  }];
}

- (IBAction)onClickYourInformation:(id)sender {
  UserRegistrationVC *userUpdateVC = [[Common mainStoryboard]
      instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
  userUpdateVC.isUpdate = YES;
  userUpdateVC.visitorDetails = self.visitorDetails;
  userUpdateVC.navTitle = self.navTitle;
  userUpdateVC.didFinishwithVisitorDetail =
      ^(NSMutableDictionary *updaedVisitorDetails) {
        self.visitorDetails = updaedVisitorDetails;
      };
  [self.navigationController pushViewController:userUpdateVC animated:YES];
}

- (IBAction)onClickSignIn:(id)sender {
  NSMutableDictionary *newVisitorField =
      [[[Common SiteData] valueForKey:@"visitorFields"] mutableCopy];
  SiteConfig *config = [Common appDelegate].config;
  if (config.skinTemperature.isTemperatureMandatoryVisitor) {
    [newVisitorField setObject:@{
      @"behaviour" : @"Mandatory",
      @"labelText" : @"Skin Temperature"
    }
                        forKey:@"skinTemperature"];
  }
  NSMutableDictionary *visitorType =
      [[Common SiteData] valueForKey:KEY_VISITOR_TYPE_BEHAVE];

  if (newVisitorField != nil) {
    NSMutableArray *keys = [[newVisitorField allKeys] mutableCopy];
    for (int i = 0; i < [keys count]; i++) {
      NSDictionary *dynemicField = [newVisitorField valueForKey:keys[i]];
      if (dynemicField) {
        if ([[dynemicField valueForKey:@"behaviour"]
                isEqualToString:@"Mandatory"]) {
          //                    NSLog(@"VISITOR : %@",[NSString
          //                    stringWithFormat:@"%@",[_visitorDetails
          //                    valueForKey:keys[i]]]);
          if (![_visitorDetails valueForKey:keys[i]]) {
            [self onClickYourInformation:nil];
            [Common showAlert:@"Please enter mandatory fields.":@""];
            return;
          }
          NSString *value = [_visitorDetails valueForKey:keys[i]];
          if ([value isKindOfClass:[NSString class]] ||
              [value isKindOfClass:[NSMutableString class]]) {
            if ([value length] <= 0) {
              [self onClickYourInformation:nil];
              [Common showAlert:@"Please enter mandatory fields.":@""];
              return;
            }
          }
        } else if ([[dynemicField valueForKey:@"behaviour"]
                       isEqualToString:@"Hidden"]) {
          if ([_visitorDetails valueForKey:keys[i]]) {
            [_visitorDetails removeObjectForKey:keys[i]];
          }
        }
      }
    }
  }

  if (selectedContractor) {
    if ([selectedContractor valueForKey:KEY_CONTACT_ID]) {
      NSString *displayText = [selectedContractor valueForKey:@"name"];
      NSString *posString = [selectedContractor valueForKey:@"position"];
      displayText = [NSString
          stringWithFormat:@"%@%@", displayText,
                           (posString.length > 0
                                ? [NSString
                                      stringWithFormat:@" (%@)", posString]
                                : @"")];

      if ([displayText isEqualToString:self.txtSearch.text]) {
        if ([_visitorDetails valueForKey:KEY_FROM_SEARCH]) {
          [_visitorDetails removeObjectForKey:KEY_FROM_SEARCH];
        }
        [_visitorDetails
            setObject:[selectedContractor valueForKey:KEY_CONTACT_ID]
               forKey:KEY_CONTACT_ID];
        if ([_visitorDetails valueForKey:@"phone"]) {
            [_visitorDetails setObject:[_visitorDetails valueForKey:@"phone"]
                                forKey:KEY_MOBILE];
        }

        NSString *strMode = [visitorType valueForKey:@"mode"];
        if ([strMode isEqualToString:@"None"]) {
          [self callGetInductionConfig];
        } else {
          [self NewScreen:visitorType];
        }

        return;
      }
    }
  }
  [Common showAlert:@"Please select whom to meet":@""];
}

- (void)NewScreen:(NSMutableDictionary *)dictVisitorBehave {
  VisitorBehaviourVC *VisitorBehaviourVC = [[Common mainStoryboard]
      instantiateViewControllerWithIdentifier:@"VisitorBehaviourVC"];
  VisitorBehaviourVC.visitorDetails = self.visitorDetails;
  VisitorBehaviourVC.navTitle = self.navTitle;
  VisitorBehaviourVC.visitorBehave = dictVisitorBehave;
  [self.navigationController pushViewController:VisitorBehaviourVC
                                       animated:YES];
}

- (void)callGetInductionConfig {
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  NSMutableDictionary *parameteres = [[NSMutableDictionary alloc] init];
  if ([_visitorDetails objectForKey:@"phone"]) {
      [parameteres setObject:[_visitorDetails objectForKey:@"phone"]
                      forKey:@"phone"];
  }
  [parameteres setObject:arr forKey:KEY_VISITORTYPEID];

  [Common callAPI:parameteres
                    Request:API_GET_INDUCTION_CONFIG
               ShowProgress:YES
      WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@", [responseObject
                                                   objectForKey:KEY_SUCCESS]]
                boolValue]) {
          if ([[responseObject objectForKey:@"isInductionEnabled"] boolValue]) {
            [_visitorDetails
                setObject:[responseObject objectForKey:@"inductionHandle"]
                   forKey:@"inductionHandle"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [responseObject objectForKey:@"slides"];
            VisitorInductionVC *visitorInductionVC = [[Common mainStoryboard]
                instantiateViewControllerWithIdentifier:@"VisitorInductionVC"];
            visitorInductionVC.visitorDetails = self.visitorDetails;
            visitorInductionVC.arrSlides = arr;
            visitorInductionVC.navTitle = self.navTitle;
            visitorInductionVC.inductionHandle =
                [responseObject objectForKey:@"inductionHandle"];
            [self.navigationController pushViewController:visitorInductionVC
                                                 animated:YES];
          } else {
            if ([Common appDelegate]
                    .config.customQuestionScreen.visitor.isEnabled) {
              VisitorCustomQuestionVC *vc = [[Common constraintStoryboard]
                  instantiateViewControllerWithIdentifier:
                      @"VisitorCustomQuestionVC"];
              vc.visitorDetails = self.visitorDetails;
              vc.navTitle = self.navTitle;
              [self.navigationController pushViewController:vc animated:YES];
            } else if ([Common appDelegate]
                           .config.isPhotoRequiredSignInVisitor ||
                       [Common appDelegate].config.isSignatureRequiredVisitor) {
              TakePhotoVC *vc = [[Common mainStoryboard]
                  instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
              vc.visitorDetails = self.visitorDetails;
              vc.navTitle = self.navTitle;
              vc.isContractor = NO;
              [self.navigationController pushViewController:vc animated:YES];
            } else if ([Common appDelegate]
                           .config.signInApprovalScreen.visitor.isEnabled) {
              SiteApproverScreenVC *vc = [[Common constraintStoryboard]
                  instantiateViewControllerWithIdentifier:
                      @"SiteApproverScreenVC"];
              vc.visitorDetails = self.visitorDetails;
              vc.navTitle = self.navTitle;
              vc.isContractor = NO;
              [self.navigationController pushViewController:vc animated:YES];
            } else {
              [self onValideLogin];
            }
          }
        } else {
          NSString *errorMsg = [NSString
              stringWithFormat:@"%@",
                               [responseObject objectForKey:KEY_ERROR_MESSAGE]];
          [Common showAlert:errorMsg:@""];
        }
      }];
}

- (void)onValideLogin {
  if ([_visitorDetails valueForKey:@"phone"]) {
      [_visitorDetails setObject:[_visitorDetails valueForKey:@"phone"]
                          forKey:KEY_MOBILE];
  }
  [Common
       callVisitorSignInAPI:_visitorDetails
               ShowProgress:YES
      WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@", [responseObject
                                                   objectForKey:KEY_SUCCESS]]
                boolValue]) {
          NSLog(@"success");
          [self onPrint:[responseObject mutableCopy]];
        } else {
          UIAlertController *alert = [UIAlertController
              alertControllerWithTitle:@"Error"
                               message:[responseObject
                                           valueForKey:@"errorMessage"]
                        preferredStyle:UIAlertControllerStyleAlert];
          [alert
              addAction:[UIAlertAction
                            actionWithTitle:@"Ok"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *_Nonnull action) {
                                      [self.navigationController
                                          popToRootViewControllerAnimated:YES];
                                    }]];
          [self presentViewController:alert animated:YES completion:nil];
        }
      }];
}

- (void)onPrint:(NSMutableDictionary *)responceDic {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
  BRLMChannel *_ptp = [Common prepareForPtp];
  BRPrintResultViewController *printResultViewController =
      (BRPrintResultViewController *)[[Common mainStoryboard]
          instantiateViewControllerWithIdentifier:
              @"BRPrintResultViewController"];
  printResultViewController.visitorDetails = responceDic;
  [printResultViewController.visitorDetails setObject:@"0"
                                               forKey:kPrinterStatus];
  printResultViewController.navTitle = self.navTitle;
  if (_ptp) {

    //        if ([_ptp isPrinterReady])
    //        {
    [printResultViewController.visitorDetails setObject:@"1"
                                                 forKey:kPrinterStatus];
    //        }
    //        else
    //        {
    //            [printResultViewController.visitorDetails setObject:@"Printer
    //            is not ready!" forKey:kPrinterMessage];
    //        }
  } else {
    [printResultViewController.visitorDetails
        setObject:@"Please set printer properly!"
           forKey:kPrinterMessage];
  }
  [self.navigationController pushViewController:printResultViewController
                                       animated:YES];
}

#pragma mark - UITextField Delegate
- (IBAction)textFieldDidChangeValue:(UITextField *)textField {
  NSString *substring = [NSString stringWithString:textField.text];

  if (substring.length == 0) {
    self.arrContacts = self.arrTempAllContacts;
    [self.siteListview reloadData];
  } else {
    [self searchAutocompleteEntriesWithSubstring:substring];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  _siteListview.hidden = YES;
  [textField resignFirstResponder];
  return true;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [textField resignFirstResponder];
  _siteListview.hidden = YES;
  return true;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
  // Put anything that starts with this substring into the autoCompleteArray
  // The items in this array is what will show up in the table view
  NSMutableArray *elementArray = [[NSMutableArray alloc] init];
  for (int i = 0; i < self.arrTempAllContacts.count; i++) {
    NSDictionary *contact = [self.arrTempAllContacts objectAtIndex:i];
    NSString *curString =
        [[contact objectForKey:@"DisplayText"] lowercaseString];
    NSRange substringRangeLowerCase =
        [curString rangeOfString:[substring lowercaseString]];

    if (substringRangeLowerCase.length != 0) {
      [elementArray addObject:contact];
    }
  }
  self.arrContacts = elementArray;
  [self.siteListview reloadData];

  if (self.arrContacts.count > 0) {
    self.siteListview.hidden = NO;
  } else {
    self.siteListview.hidden = YES;
  }
}

- (void)setScrollForKeyBoard:(BOOL)isKBOpen {
  if ([Common appDelegate].isIpad) {
    if (isKBOpen) {
      _contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                      self.view.frame.size.height + 450);
      _tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,
                                             _contentView.frame.size.height);
      [_tpscrollview setContentOffset:CGPointMake(0, 450) animated:YES];
    } else {
      _contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                      self.view.frame.size.height);
      _tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,
                                             _contentView.frame.size.height);
    }
  } else {
    if (isKBOpen) {
      _contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                      self.view.frame.size.height + 550);
      _tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,
                                             _contentView.frame.size.height);
      [_tpscrollview
          setContentOffset:CGPointMake(
                               0, [self.view viewWithTag:5502].frame.origin.y)
                  animated:YES];
    } else {
      _contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                      self.view.frame.size.height > 550
                                          ? self.view.frame.size.height
                                          : 550);
      _tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,
                                             _contentView.frame.size.height);
    }
  }
  CGRect cfr = _bottomView.frame;
  cfr.origin.y = _contentView.frame.size.height - _bottomView.frame.size.height;
  _bottomView.frame = cfr;
  _bottomView.hidden = isKBOpen;
}
#pragma get all contractor
- (void)getAllContacts {
  NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
  [dicParameters setObject:@"Visitor" forKey:KEY_REGISTRATION_TYPE];
  [Common callAPI:dicParameters
                    Request:REQUEST_GET_CONTACTS
               ShowProgress:YES
      WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@", [responseObject
                                                   objectForKey:KEY_SUCCESS]]
                boolValue]) {
          NSArray *contactData = [responseObject valueForKey:@"contacts"];
          if ([contactData count] > 0) {
            NSString *selected =
                [self.visitorDetails objectForKey:KEY_CONTACT_ID];
            self.arrContacts = [[NSMutableArray alloc] init];
            for (int i = 0; i < contactData.count; i++) {
              NSMutableDictionary *contact =
                  [[contactData objectAtIndex:i] mutableCopy];
              [contact
                  setObject:
                      [NSString
                          stringWithFormat:
                              @"%@%@", [contact valueForKey:@"name"],
                              ([NSString
                                   stringWithFormat:
                                       @"%@", [contact valueForKey:@"position"]]
                                           .length > 0
                                   ? [NSString
                                         stringWithFormat:
                                             @" (%@)",
                                             [NSString
                                                 stringWithFormat:
                                                     @"%@",
                                                     [contact valueForKey:
                                                                  @"position"]]]
                                   : @"")]
                     forKey:@"DisplayText"];
              if (selected != nil) {
                if (selected == [contact valueForKey:KEY_CONTACT_ID]) {
                  selectedContractor = contact;
                  self.txtSearch.text = [NSString
                      stringWithFormat:@"%@",
                                       selectedContractor[@"DisplayText"]];
                }
              }
              [self.arrContacts addObject:contact];
            }
            self.arrTempAllContacts = [self.arrContacts copy];
            [self.siteListview reloadData];
          } else {
            [Common showAlert:@"Ooopss..":@"No contact found"];
          }
        } else {
          NSString *errorMsg = [NSString
              stringWithFormat:@"%@",
                               [responseObject objectForKey:KEY_ERROR_MESSAGE]];
          [Common showAlert:errorMsg:@""];
        }
      }];
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.arrContacts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"cellID";

  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }

  NSDictionary *contact = [self.arrContacts objectAtIndex:indexPath.row];

  UILabel *lbFirstName = (UILabel *)[cell.contentView viewWithTag:1001];
  [lbFirstName applyUITheme:kThemeGreyValue(0.0)];
  lbFirstName.font = kThemeRegularFonts([Common appDelegate].isIpad ? 24 : 16);

  NSString *lableText =
      [NSString stringWithFormat:@"%@", contact[@"DisplayText"]];

  if ([lbFirstName respondsToSelector:@selector(setAttributedText:)]) {
    NSDictionary *attribs = @{
      NSForegroundColorAttributeName : lbFirstName.textColor,
      NSFontAttributeName : lbFirstName.font
    };

    NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:lableText
                                               attributes:attribs];
    NSRange textRange = [[lableText lowercaseString]
        rangeOfString:[self.txtSearch.text lowercaseString]];
    [attributedText
        setAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]}
                range:textRange];
    lbFirstName.attributedText = attributedText;
  } else {
    lbFirstName.text = lableText;
  }

  cell.backgroundColor = [UIColor clearColor];
  UIView *bgColorView = [[UIView alloc] init];
  bgColorView.backgroundColor = kGetThemeColor;
  [cell setSelectedBackgroundView:bgColorView];
  //    if (cell.isSelected) {
  //        lbFirstName.textColor = kThemeGreyValue(255.0);
  //        lbFirstName.text = lableText;
  //    }
  return cell;
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
  [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  _siteListview.hidden = YES;
  selectedContractor = [self.arrContacts objectAtIndex:indexPath.row];
  self.txtSearch.text =
      [NSString stringWithFormat:@"%@", selectedContractor[@"DisplayText"]];
  [self.txtSearch resignFirstResponder];
  //    [tableView reloadData];
}

@end

//
//  UserRegistrationVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "UserRegistrationVC.h"
#import "AsyncImageView.h"
#import "MeetingWithVC.h"
#import "SiteApproverScreenVC.h"
#import "TakePhotoVC.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"
#import "UITextField+Additions.h"
#import "VisitorBehaviourVC.h"
#import "VisitorCustomQuestionVC.h"
#import "VisitorInductionVC.h"

@interface UserRegistrationVC () {
  NSMutableDictionary *valueOfVisitorField;
  NSMutableDictionary *tempDic;
  NSMutableArray *keys;
  BOOL _isTitleMandatory;
}

@end

@implementation UserRegistrationVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [FIRAnalytics logEventWithName:@"User Registration"
                      parameters:@{@"onload" : @"12"}];
  _lbWelcomeMessage.textColor = kGetHomeLabelColor;
  self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                      self.view.bounds.size.height);

  [_btnCancel applyGrayTheme];
  [_continueBtn applyBlueShedow];
  [Common setBgImage:self.view useDefault:YES];
  [Common applyThemeColorToPowerdBy:self.view];
  _btnTitle.layer.cornerRadius = 3.0;
  _btnTitle.layer.borderWidth = 1.0;
  _btnTitle.layer.borderColor = kThemeGreyValue(197.0).CGColor;
  _btnTitle.backgroundColor = kThemeGreyValue(249.0);

  NSMutableDictionary *newVisitorField =
      [[[Common SiteData] valueForKey:@"visitorFields"] mutableCopy];
  if (newVisitorField == nil) {
    newVisitorField = [[NSMutableDictionary alloc] init];
  }
  NSDictionary *titleData = [newVisitorField objectForKey:@"title"];
  if ([[titleData valueForKey:@"behaviour"] isEqualToString:@"Mandatory"]) {
    _isTitleMandatory = YES;
    [_btnTitle setTitle:@"  Mr" forState:UIControlStateNormal];
  } else {
    _isTitleMandatory = NO;
    [_btnTitle setTitle:@"  " forState:UIControlStateNormal];
  }

  if (_isUpdate) {
    [_continueBtn setTitle:@"UPDATE" forState:UIControlStateNormal];
    tempDic = [_visitorDetails mutableCopy];
    if ([_visitorDetails valueForKey:@"title"]) {
      _btnTitle.enabled = NO;
      [_btnTitle setTitle:[NSString stringWithFormat:@"  %@",
                                                     [_visitorDetails
                                                         valueForKey:@"title"]]
                 forState:UIControlStateNormal];
    }
  } else {
    _btnTitle.enabled = YES;
    if (_visitorDetails != nil) {
      tempDic = [_visitorDetails mutableCopy];
      if ([_visitorDetails valueForKey:@"title"]) {
        //                _btnTitle.enabled=NO;
        [_btnTitle
            setTitle:[NSString
                         stringWithFormat:@"  %@", [_visitorDetails
                                                       valueForKey:@"title"]]
            forState:UIControlStateNormal];
      }
      _visitorDetails = nil;
    }
  }
  _lbWelcomeMessage.hidden = !_notFoundUser;

  SiteConfig *config = [Common appDelegate].config;
  if (config.skinTemperature.isTemperatureMandatoryVisitor) {
    [newVisitorField setObject:@{
      @"behaviour" : @"Mandatory",
      @"labelText" : @"Skin Temperature"
    }
                        forKey:@"skinTemperature"];
  }

  valueOfVisitorField = [[NSMutableDictionary alloc] init];
  int noofcomponant = 0;
  int oneviewhight = [Common appDelegate].isIpad ? 100 : 70;

  NSArray *arrKeys = [[newVisitorField allKeys] mutableCopy];
  NSArray *want = [[NSArray alloc]
      initWithObjects:@"title", @"firstname", @"lastname", @"emailAddress",
                      @"organisation", @"vehicleRegistrationNumber", @"phone",
                      @"custom1", @"custom2", @"custom3", @"custom4",
                      @"custom5", @"skinTemperature", nil];
  int si = 0;
  keys = [[arrKeys sortedArrayUsingComparator:^NSComparisonResult(
                       NSString *firstString, NSString *secondString) {
    return
        [[firstString lowercaseString] compare:[secondString lowercaseString]];
  }] mutableCopy];

  for (int wi = 0; wi < [want count]; wi++) {
    for (int ki = 0; ki < [keys count]; ki++) {
      if ([[keys[ki] lowercaseString]
              isEqualToString:[want[wi] lowercaseString]]) {
        if (ki != si) {
          NSString *robj = [keys objectAtIndex:ki];
          [keys removeObjectAtIndex:ki];
          [keys insertObject:robj atIndex:si];
        }
        si++;
        break;
      }
    }
  }
  for (int ki = 0; ki < [keys count]; ki++) {
    BOOL needObjReplace = YES;
    for (int wi = 0; wi < [want count]; wi++) {
      if ([[keys[ki] lowercaseString]
              isEqualToString:[want[wi] lowercaseString]] ||
          [[keys objectAtIndex:ki] hasPrefix:@"custom"]) {
        needObjReplace = NO;
        break;
      }
    }
    if (needObjReplace) {
      NSString *robj = [keys objectAtIndex:ki];
      [keys removeObjectAtIndex:ki];
      [keys addObject:robj];
    }
  }

  for (int i = 0; i < [keys count]; i++) {
    NSString *key = keys[i];
    NSMutableDictionary *valueDic =
        [[newVisitorField objectForKey:key] mutableCopy];
    if ([[valueDic valueForKey:@"behaviour"] isEqualToString:@"Hidden"]) {
      continue;
    }
    //        if (![[valueDic valueForKey:@"behaviour"]
    //        isEqualToString:@"Mandatory"])
    //        {
    //            continue;
    //        }
    if ([key isEqualToString:@"title"]) {
      [valueOfVisitorField setObject:@{
        @"behaviour" : [valueDic valueForKey:@"behaviour"],
        @"labelText" : key,
        @"title" : [[NSString stringWithFormat:@"%@", _btnTitle.titleLabel.text]
            stringByReplacingOccurrencesOfString:@" "
                                      withString:@""]
      }
                              forKey:key];
      continue;
    }

    UILabel *titlelb;
    UITextField *tfValue;

    if ([Common appDelegate].isIpad) {
      int compLine = (noofcomponant + 1) / 3;
      int cwidth = (self.view.frame.size.width - 80) / 3;
      int xpos = 20 + (20 + cwidth) * ((noofcomponant + 1) % 3);
      if (noofcomponant < 2) {
        //                cwidth=cwidth*3/2-50;
        //                if (noofcomponant==0)
        //                {
        if ([keys containsObject:@"title"]) {
          NSMutableDictionary *valueDic =
              [[newVisitorField objectForKey:@"title"] mutableCopy];
          if ([[valueDic valueForKey:@"behaviour"] isEqualToString:@"Hidden"]) {
            _titleView.hidden = YES;
            cwidth = cwidth * 3 / 2 + 10;
            if (noofcomponant == 0) {
              xpos = 20;
            } else {
              xpos = 40 + cwidth;
            }
          } else {
            cwidth = cwidth * 3 / 2 - 50;
            if (noofcomponant == 0) {
              xpos = 140;
            } else {
              xpos = 160 + cwidth;
            }
          }
        } else {
          _titleView.hidden = YES;
          cwidth = cwidth * 3 / 2 + 10;
          if (noofcomponant == 0) {
            xpos = 20;
          } else {
            xpos = 40 + cwidth;
          }
        }
        //                    xpos=140;
        //                }
        //                else
        //                {
        //                    xpos=160+cwidth;
        //                }
      }

      titlelb = [[UILabel alloc]
          initWithFrame:CGRectMake(xpos, 50 + compLine * oneviewhight, cwidth,
                                   40)];
      tfValue = [[UITextField alloc]
          initWithFrame:CGRectMake(xpos, 90 + compLine * oneviewhight, cwidth,
                                   60)];
      [tfValue applyGrayBorderTheme];
    } else {
      if ([key containsString:@"firstName"]) {
        if ([keys containsObject:@"title"]) {
          NSMutableDictionary *valueDic =
              [[newVisitorField objectForKey:@"title"] mutableCopy];
          if ([[valueDic valueForKey:@"behaviour"] isEqualToString:@"Hidden"]) {
            _titleView.hidden = YES;
            titlelb = [[UILabel alloc]
                initWithFrame:CGRectMake(40, 58 + noofcomponant * oneviewhight,
                                         self.view.frame.size.width - 80, 30)];
            tfValue = [[UITextField alloc]
                initWithFrame:CGRectMake(40, 80 + noofcomponant * oneviewhight,
                                         self.view.frame.size.width - 80, 40)];
          } else {
            titlelb = [[UILabel alloc]
                initWithFrame:CGRectMake(120, 58 + noofcomponant * oneviewhight,
                                         self.view.frame.size.width - 160, 30)];
            tfValue = [[UITextField alloc]
                initWithFrame:CGRectMake(120, 80 + noofcomponant * oneviewhight,
                                         self.view.frame.size.width - 160, 40)];
          }
        } else {
          _titleView.hidden = YES;
          titlelb = [[UILabel alloc]
              initWithFrame:CGRectMake(40, 58 + noofcomponant * oneviewhight,
                                       self.view.frame.size.width - 80, 30)];
          tfValue = [[UITextField alloc]
              initWithFrame:CGRectMake(40, 80 + noofcomponant * oneviewhight,
                                       self.view.frame.size.width - 80, 40)];
        }
      } else {
        titlelb = [[UILabel alloc]
            initWithFrame:CGRectMake(40, 58 + noofcomponant * oneviewhight,
                                     self.view.frame.size.width - 80, 30)];
        tfValue = [[UITextField alloc]
            initWithFrame:CGRectMake(40, 80 + noofcomponant * oneviewhight,
                                     self.view.frame.size.width - 80, 40)];
      }
      [tfValue applyGrayBorderTheme];
    }
    tfValue.tag = 1110 + noofcomponant;
    if (tempDic != nil) {
      if ([tempDic valueForKey:key]) {
        //                if (_isUpdate && ([key
        //                isEqualToString:@"vehicleRegistrationNumber"] || [key
        //                isEqualToString:@"phone"] || [key
        //                hasPrefix:@"custom"]))
        //                {
        //                    tfValue.enabled=YES;
        //                }
        //                else
        //                {
        //                    tfValue.enabled=NO;
        //                }

        if (_isUpdate && ([key isEqualToString:@"firstName"] ||
                          [key isEqualToString:@"lastName"] ||
                          [key isEqualToString:@"title"] ||
                          [key hasPrefix:@"organisation"])) {
          tfValue.enabled = NO;
        } else {
          tfValue.enabled = YES;
        }

        //                if (!_isUpdate)
        //                {
        //                    tfValue.enabled=YES;
        //                }
        tfValue.text = [tempDic valueForKey:key];
        if ([key containsString:@"phone"]) {
          tfValue.text = [Common GetMaskedIfPhone:[tempDic valueForKey:key]
                                           forKay:@"phone"];
        }
      }
    }
    tfValue.delegate = self;
    //        if (!_isUpdate && [key isEqualToString:@"phone"])
    //        {
    //            tfValue.enabled=YES;
    //        }

    noofcomponant++;
    titlelb.text = [valueDic valueForKey:@"labelText"];
    tfValue.placeholder = [NSString
        stringWithFormat:@"Enter %@", [valueDic valueForKey:@"labelText"]];
    if ([key isEqualToString:@"emailAddress"]) {
      tfValue.tag = 999;
      tfValue.keyboardType = UIKeyboardTypeEmailAddress;
    }
    [titlelb applyUITheme:kThemeGreyValue(100.0)];

    //        if (![Common appDelegate].isIpad)
    //        {
    titlelb.textColor = kGetHomeLabelColor; //[UIColor whiteColor];
    //        }
    tfValue.textColor = [UIColor darkTextColor];

    if ([key containsString:@"phone"]) {
      [tfValue setKeyboardType:UIKeyboardTypePhonePad];
      tfValue.tag = 9998;
    }

    if ([key containsString:@"skinTemperature"]) {
      tfValue.tag = 9999;
      [tfValue setKeyboardType:UIKeyboardTypeDecimalPad];
    }

    tfValue.returnKeyType = UIReturnKeyDone;
    [valueDic setObject:[NSString stringWithFormat:@"%ld", (long)tfValue.tag]
                 forKey:@"tag"];
    [valueOfVisitorField setObject:valueDic forKey:key];
    [_contentView addSubview:titlelb];
    [_contentView addSubview:tfValue];
  }
  int needHight = 0;
  if ([Common appDelegate].isIpad) {
    needHight = 210 + (noofcomponant / 3 + 1) * oneviewhight;
    UIView *bgView = [self.view viewWithTag:5501];
    bgView.backgroundColor = [UIColor clearColor];
    //        [Common ApplyUIViewTheme:bgView];
    CGRect vrect = bgView.frame;
    vrect.size.width = self.view.frame.size.width - 20;
    vrect.size.height = needHight - 200;
    bgView.frame = vrect;
  } else {
    needHight = 220 + noofcomponant * oneviewhight;
  }

  int viewHight = self.view.frame.size.height - 64;
  self.contentView.frame =
      CGRectMake(0, 0, self.view.bounds.size.width,
                 needHight > viewHight ? needHight : viewHight);
  self.tpKeyBoard.contentSize =
      CGSizeMake(self.view.frame.size.width, _contentView.frame.size.height);

  if ([self.view viewWithTag:3311]) {
    CGRect btnContainerFrame = [self.view viewWithTag:3311].frame;
    btnContainerFrame.origin.y =
        _contentView.frame.size.height - btnContainerFrame.size.height;
    [self.view viewWithTag:3311].frame = btnContainerFrame;
  }

  for (id subView in _titleView.subviews) {
    if ([subView isKindOfClass:[UILabel class]]) {
      UILabel *lblTitle = (UILabel *)subView;
      lblTitle.textColor = kGetHomeLabelColor;
    }
  }
}

- (IBAction)onSideMenuClick:(id)sender {
  [self.menuContainerViewController toggleRightSideMenuCompletion:^{
  }];
}
- (void)viewWillAppear:(BOOL)animated {
  self.navigationItem.title = self.navTitle; //@"VISITOR SIGN IN";
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateBackground)
                                               name:N_UpdateBackgroundImages
                                             object:nil];
}
- (void)updateBackground {
  dispatch_async(dispatch_get_main_queue(), ^{
    [Common setBgImage:self.view useDefault:YES];
  });
}
- (void)viewWillDisappear:(BOOL)animated {
  self.navigationItem.title = @"";
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:N_UpdateBackgroundImages
                                                object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (_isUpdate) {
    if ([textField.text length] > 0) {
      [self registerUser];
    }
  }
  [textField resignFirstResponder];
  return true;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField.tag == 999) {
    // email address textfield
    return YES;
  }
  if (textField.tag == 9999) {
    // skin temperature textfield
    if (range.length > 0) {
      return YES;
    }
    NSCharacterSet *cs = [[NSCharacterSet
        characterSetWithCharactersInString:TEMPERATURE_ACCEPTABLE_CHARACTERS]
        invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]
        componentsJoinedByString:@""];
    if ([string isEqualToString:filtered]) {
      if (textField.text.length > 0) {
        NSArray *array = [textField.text componentsSeparatedByString:@"."];
        if (array.count > 1) {
          NSString *decimal = array[1];
          if (decimal.length >= 2) {
            return NO;
          }
        }
      }
      return YES;
    }
    return NO;
  } else if (textField.tag == 9998 && [textField.text hasPrefix:@"XXXX"]) {
    textField.text = @"";
  }
  NSCharacterSet *cs = [[NSCharacterSet
      characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];

  NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]
      componentsJoinedByString:@""];

  return [string isEqualToString:filtered];
}

- (IBAction)onClickTitle:(id)sender {

  [self.view endEditing:YES];
  if (_isTitleMandatory) {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:@"Title"
                      delegate:self
             cancelButtonTitle:[@"Cancel" uppercaseString]
        destructiveButtonTitle:nil
             otherButtonTitles:@"Mr", @"Mrs", @"Miss", @"Ms", @"Dr", @"Rev",
                               @"Rabbi", nil]; // Mr, Mrs, Miss, Ms, Dr, Rev
    [actionSheet showInView:self.view];
  } else {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"Title"
                                    delegate:self
                           cancelButtonTitle:[@"Cancel" uppercaseString]
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"", @"Mr", @"Mrs", @"Miss", @"Ms",
                                             @"Dr", @"Rev", @"Rabbi",
                                             nil]; // Mr, Mrs, Miss, Ms, Dr, Rev
    [actionSheet showInView:self.view];
  }
}
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([[actionSheet buttonTitleAtIndex:buttonIndex]
          isEqualToString:[@"Cancel" uppercaseString]]) {
    return;
  } else {
    [_btnTitle
        setTitle:[NSString stringWithFormat:@"  %@",
                                            [actionSheet
                                                buttonTitleAtIndex:buttonIndex]]
        forState:UIControlStateNormal];
  }
}

- (IBAction)onCancel:(id)sender {
  [self.view endEditing:YES];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onContinue:(id)sender {
  [self.view endEditing:YES];
  [self registerUser];
}
- (void)registerUser {
  NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
  //    for (NSString* key in valueOfVisitorField)
  for (NSString *key in keys) {
    NSDictionary *valueDic = [valueOfVisitorField objectForKey:key];
    if (valueDic) {
      if ([key isEqualToString:@"title"]) {
        if ([[valueDic valueForKey:@"behaviour"]
                isEqualToString:@"Mandatory"]) {
          if ([_btnTitle.titleLabel.text isEqualToString:@"  "]) {
            if (_isUpdate) {
              [Common
                  showAlert:
                   @"Oops!":[NSString stringWithFormat:
                                          @"%@ Visitor information is missing.",
                                          [valueDic valueForKey:@"labelText"]]];
            } else {
              [Common
                  showAlert:
                   @"Oops!":[NSString stringWithFormat:
                                          @"Please select %@",
                                          [valueDic valueForKey:@"labelText"]]];
            }
            return;
          }
        }
        [dicParameters
            setObject:[[NSString
                          stringWithFormat:@"%@", _btnTitle.titleLabel.text]
                          stringByReplacingOccurrencesOfString:@" "
                                                    withString:@""]
               forKey:key];
        continue;
      }

      UITextField *tfValue =
          [_contentView viewWithTag:[[valueDic valueForKey:@"tag"] intValue]];
      if ([[valueDic valueForKey:@"behaviour"] isEqualToString:@"Mandatory"]) {
        if ([tfValue.text length] <= 0) {
          if (_isUpdate) {
            [Common
                showAlert:
                 @"Oops!":[NSString stringWithFormat:
                                        @"%@ Visitor information is missing.",
                                        [valueDic valueForKey:@"labelText"]]];
          } else {
            [Common
                showAlert:
                 @"Oops!":[NSString
                              stringWithFormat:@"Please enter %@",
                                               [valueDic
                                                   valueForKey:@"labelText"]]];
          }

          return;
        } else {
          if ([key isEqualToString:@"phone"]) {
            if (![Common isNumberValid:tfValue.text] &&
                ![tfValue.text hasPrefix:@"XXXX"]) {
              [Common
                  showAlert:[NSString
                                stringWithFormat:@"Enter valid %@",
                                                 [valueDic
                                                     valueForKey:@"labelText"]
              ]:@"Phone number should be 6 to 14 digit"];
              return;
            }
          } else if ([key isEqualToString:@"emailAddress"]) {
            if (![Common validateEmailAddress:tfValue.text]) {
              [Common
                  showAlert:[NSString
                                stringWithFormat:@"Enter valid %@",
                                                 [valueDic
                                                     valueForKey:@"labelText"]
              ]:@""];
              return;
            }
          } else if ([key containsString:@"skinTemperature"]) {
            if (![Common validateSkinTemperature:tfValue.text]) {
              [Common
                  showAlert:[NSString
                                stringWithFormat:@"Enter valid %@",
                                                 [valueDic
                                                     valueForKey:@"labelText"]
              ]:@""];
              return;
            }
          }

          [dicParameters setObject:tfValue.text forKey:key];
          if ([key isEqualToString:@"phone"]) {
            if ([tfValue.text hasPrefix:@"XXXX"]) {
              [dicParameters setObject:[tempDic valueForKey:key] forKey:key];
            }
          }
        }
      } else {
        [dicParameters setObject:@"" forKey:key];
        if ([tfValue.text length] > 0) {
          [dicParameters setObject:tfValue.text forKey:key];
        }
      }
    }
  }

  for (NSString *key in [dicParameters allKeys]) {
    if ([[dicParameters objectForKey:key] isKindOfClass:[NSString class]]) {
      NSString *string = [dicParameters objectForKey:key];

      if ([string containsString:@"’"]) {
        string = [string stringByReplacingOccurrencesOfString:@"’"
                                                   withString:@"'"];
        [dicParameters setObject:string forKey:key];
      }
    }
  }
  if (![dicParameters valueForKey:KEY_CONTACT_ID]) {
    if ([tempDic valueForKey:KEY_CONTACT_ID]) {
      [dicParameters setObject:[tempDic valueForKey:KEY_CONTACT_ID]
                        forKey:KEY_CONTACT_ID];
    }
  }
  [self validateVisitor:dicParameters];
}

- (void)validateVisitor:(NSMutableDictionary *)parameters {

  [Common callAPI:parameters
                    Request:API_VALIDATE_VISITOR
               ShowProgress:YES
      WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@", [responseObject
                                                   objectForKey:KEY_SUCCESS]]
                boolValue]) {
          if ([[NSString stringWithFormat:@"%@", [responseObject
                                                     objectForKey:@"isValid"]]
                  boolValue]) {
            if (_isUpdate) {
              [self.navigationController popViewControllerAnimated:YES];
              _didFinishwithVisitorDetail(parameters);
            } else {
              [self moveToNextPage:parameters];
            }
          } else if ([[responseObject objectForKey:@"validationErrors"]
                         isKindOfClass:[NSArray class]] ||
                     [[responseObject objectForKey:@"validationErrors"]
                         isKindOfClass:[NSMutableArray class]]) {

            NSArray *array = [responseObject objectForKey:@"validationErrors"];
            if ([array count] > 0) {

              NSString *errorMsg = [array componentsJoinedByString:@"\n"];
              [Common showAlert:errorMsg:@""];
            }
          } else {

            NSString *errorMsg = [NSString
                stringWithFormat:@"%@", [responseObject
                                            objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg:@""];
          }
        }
      }];
}

- (void)moveToNextPage:(NSDictionary *)visitorDetails {
  if ([Common appDelegate].config.isContactSelectionEnabledVisitor) {
    [self goToDisplayInfo:visitorDetails];
  } else {
    NSMutableDictionary *visitorType =
        [[Common SiteData] valueForKey:KEY_VISITOR_TYPE_BEHAVE];
    NSString *strMode = [visitorType valueForKey:@"mode"];
    if ([strMode isEqualToString:@"None"]) {
      [self callGetInductionConfig:[visitorDetails mutableCopy]];
    } else {
      [self NewScreenWith:[visitorDetails mutableCopy]];
    }
  }
}

- (void)goToDisplayInfo:(NSDictionary *)visitorDetails {
  MeetingWithVC *vc = [[Common mainStoryboard]
      instantiateViewControllerWithIdentifier:@"MeetingWithVC"];
  vc.visitorDetails = [visitorDetails mutableCopy];
  vc.navTitle = self.navTitle;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)NewScreenWith:(NSMutableDictionary *)visitorDetails {
  NSMutableDictionary *visitorType =
      [[Common SiteData] valueForKey:KEY_VISITOR_TYPE_BEHAVE];
  VisitorBehaviourVC *VisitorBehaviourVC = [[Common mainStoryboard]
      instantiateViewControllerWithIdentifier:@"VisitorBehaviourVC"];
  VisitorBehaviourVC.visitorDetails = visitorDetails;
  VisitorBehaviourVC.navTitle = self.navTitle;
  VisitorBehaviourVC.visitorBehave = visitorType;
  [self.navigationController pushViewController:VisitorBehaviourVC
                                       animated:YES];
}

- (void)callGetInductionConfig:(NSMutableDictionary *)visitorDetails {
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  NSMutableDictionary *parameteres = [[NSMutableDictionary alloc] init];
  [parameteres setObject:[visitorDetails objectForKey:@"phone"]
                  forKey:@"phone"];
  [parameteres setObject:arr forKey:KEY_VISITORTYPEID];

  [Common callAPI:parameteres
                    Request:API_GET_INDUCTION_CONFIG
               ShowProgress:YES
      WithCompletionHandler:^(id responseObject) {
        if ([[NSString stringWithFormat:@"%@", [responseObject
                                                   objectForKey:KEY_SUCCESS]]
                boolValue]) {
          if ([[responseObject objectForKey:@"isInductionEnabled"] boolValue]) {
            [visitorDetails
                setObject:[responseObject objectForKey:@"inductionHandle"]
                   forKey:@"inductionHandle"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [responseObject objectForKey:@"slides"];
            VisitorInductionVC *visitorInductionVC = [[Common mainStoryboard]
                instantiateViewControllerWithIdentifier:@"VisitorInductionVC"];
            visitorInductionVC.visitorDetails = visitorDetails;
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
              vc.visitorDetails = visitorDetails;
              vc.navTitle = self.navTitle;
              [self.navigationController pushViewController:vc animated:YES];
            } else if ([Common appDelegate]
                           .config.isPhotoRequiredSignInVisitor ||
                       [Common appDelegate].config.isSignatureRequiredVisitor) {
              TakePhotoVC *vc = [[Common mainStoryboard]
                  instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
              vc.visitorDetails = visitorDetails;
              vc.navTitle = self.navTitle;
              vc.isContractor = NO;
              [self.navigationController pushViewController:vc animated:YES];
            } else if ([Common appDelegate]
                           .config.signInApprovalScreen.visitor.isEnabled) {
              SiteApproverScreenVC *vc = [[Common constraintStoryboard]
                  instantiateViewControllerWithIdentifier:
                      @"SiteApproverScreenVC"];
              vc.visitorDetails = visitorDetails;
              vc.navTitle = self.navTitle;
              vc.isContractor = NO;
              [self.navigationController pushViewController:vc animated:YES];
            } else {
              [self onValideLogin:visitorDetails];
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

- (void)onValideLogin:(NSMutableDictionary *)visitorDetails {
  [visitorDetails setObject:[visitorDetails valueForKey:@"phone"]
                     forKey:KEY_MOBILE];
  [Common
       callVisitorSignInAPI:visitorDetails
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

@end

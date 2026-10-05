//
//  VisitorInductionVC.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 10/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorInductionVC.h"
#import "UIButton+Additions.h"
#import "TakePhotoVC.h"
#import "VisitorCustomQuestionVC.h"
#import "SiteApproverScreenVC.h"

@interface VisitorInductionVC ()
{
    NSMutableArray *arrayOfInduction;
    int selectedIndex, totalTime;
    NSMutableDictionary *webViewLoad;
    BOOL isScrolledToBottom;
    NSTimer *timer;
}
@end

@implementation VisitorInductionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor Induction" parameters:@{@"onload": @"15"}];
    _lblNote.textAlignment = NSTextAlignmentLeft;
    _lblNote.textColor = kGetHomeLabelColor;
    _lblNote.text = @"NOTE: Please read all induction content by scrolling.";
    _lblNote.hidden = YES;
    arrayOfInduction=[[NSMutableArray alloc] init];
   // [self getRegisterUserDeail];
    [_continueBtn applyBlueShedow];
    [_continueBtn setTitle:@"CONTINUE" forState:UIControlStateNormal];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    selectedIndex=0;
    [Common setBgImage:self.view useDefault:YES];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common applyThemeColorToPowerdBy:self.view];
    webViewLoad=[[NSMutableDictionary alloc] init];
    
    _lblRemainingTime.textColor = kGetHomeLabelColor;
    
    currMinute = 0;
    currSeconds = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;//@"VISITOR INDUCTION";
    UIView *view1=[self.view viewWithTag:5501];
    UIView *view2=[self.view viewWithTag:3311];
    if (![Common appDelegate].isIpad)
    {
        view1.frame=CGRectMake(10, 10, self.view.frame.size.width-20,view2.frame.origin.y-10);
        _collectionInduction.frame=CGRectMake(0, 10, view1.frame.size.width,view1.frame.size.height-20);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    
//    _continueBtn.enabled = NO;
    isScrolledToBottom = NO;
    
    if (_arrSlides.count > 0) {
        NSDictionary *dict = [_arrSlides objectAtIndex:0];
        NSString *strTime = [NSString stringWithFormat:@"%@",[dict valueForKey:@"minimumReadingTime"]];
        
        totalTime = [strTime intValue];
        
        if(totalTime == 0){
            _lblRemainingTime.hidden = YES;
        }
        else{
            _lblRemainingTime.hidden = NO;
            [self readingTimer:totalTime];
        }
    }
    else {
        // No slides returned from API — show alert and go back
        _lblRemainingTime.hidden = YES;
        totalTime = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Induction Content"
                                                                           message:@"No induction slides are available at this time. Please try again later."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)readingTimer:(int)seconds{
    _lblRemainingTime.hidden = NO;
    currSeconds = seconds % 60;
    currMinute = seconds / 60;
    _lblRemainingTime.text = [NSString stringWithFormat:@"Required Reading Time: %02d:%02d",currMinute,currSeconds];
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired
{    
    if((currMinute>0 || currSeconds>=0) && currMinute>=0)
    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        }
        else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        
        if (currMinute == 00 && currSeconds == 00) {
            
            [timer invalidate];
            timer = nil;
            _lblRemainingTime.hidden = YES;
        }
    }
    else
    {
        [timer invalidate];
        timer = nil;
    }
    _lblRemainingTime.text = [NSString stringWithFormat:@"Required Reading Time: %02d:%02d",currMinute,currSeconds];
}


#pragma mark - Collection Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrSlides.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"HGPhoto";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = [_arrSlides objectAtIndex:indexPath.row];
    
//    UIWebView *webView = [cell.contentView viewWithTag:1001];
    WKWebView *webView = [cell.contentView viewWithTag:1001];
    NSString *htmlString = [dic valueForKey:@"html"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
//    NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"1indu" ofType:@"html"];
//    htmlString = [NSString stringWithContentsOfFile:stringPath encoding:NSUTF8StringEncoding error:nil];
//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
//    if ([htmlString containsString:@"<html>"])
//    {
//        htmlString=[NSString stringWithFormat:@"<html><body>%@</body></html>",htmlString];
//    }
    
    if ([Common appDelegate].isIpad)
    {
       webView.frame=CGRectMake(0,0,collectionView.frame.size.width,collectionView.frame.size.height-50);
    }
    else
    {
        webView.frame=CGRectMake(0,0,collectionView.frame.size.width,collectionView.frame.size.height-40);
    }
//    //test
//    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<img[^>]*>" withString:@"" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch range:NSMakeRange(0, [htmlString length])];
    [webView loadHTMLString:htmlString baseURL:nil];
    
//    _continueBtn.enabled = NO;
//    isScrolledToBottom = NO;
//    if (![webViewLoad valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] && indexPath.row>1)
//    {
        webView.navigationDelegate=self;
        webView.scrollView.delegate=self;
//    }
    
    BEMCheckBox *myCheckBox = [cell.contentView viewWithTag:1002];
    UILabel *checkLable = [cell.contentView viewWithTag:1003];
    
    if (checkLable==nil)
    {
        UILabel *checkLable;
        if ([Common appDelegate].isIpad)
        {
            checkLable = [[UILabel alloc] initWithFrame:CGRectMake(50,collectionView.frame.size.height-40,200,30)];
        }
        else {
            checkLable = [[UILabel alloc] initWithFrame:CGRectMake(50,collectionView.frame.size.height-31,200,30)];
        }
        checkLable.text=@"I Agree";
        checkLable.textColor=[UIColor darkGrayColor];
        checkLable.tag=1003;
        [cell.contentView addSubview:checkLable];
    }
    if (myCheckBox==nil)
    {
        BEMCheckBox *myCheckBox;
        if ([Common appDelegate].isIpad)
        {
            myCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(10,collectionView.frame.size.height-40,30,30)];
        }
        else
        {
            myCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(10,collectionView.frame.size.height-31,28,28)];
        }
        
        myCheckBox.boxType=BEMBoxTypeCircle;
        myCheckBox.onAnimationType=BEMAnimationTypeBounce;
        myCheckBox.offAnimationType=BEMAnimationTypeBounce;
        myCheckBox.onFillColor=kGetThemeColor;
        myCheckBox.onTintColor=[UIColor whiteColor];
        myCheckBox.onCheckColor=[UIColor whiteColor];
        myCheckBox.tag=1002;
        [cell.contentView addSubview:myCheckBox];
    }
    
    if ([dic valueForKey:@"isAgree"])
    {
        myCheckBox.on=[[dic valueForKey:@"isAgree"] boolValue];
    }
    else
    {
        myCheckBox.on=NO;
    }
    
    return cell;
    
}
/*
#pragma mark - UIWebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    webView.delegate=nil;
    if (webView.isLoading){
        [Common showProgress];
        [Common appDelegate].window.userInteractionEnabled = false;
        return;
    }
    [Common hideProgress];
    [Common appDelegate].window.userInteractionEnabled = true;
    
    CGRect visibleRect = (CGRect){.origin = self.collectionInduction.contentOffset, .size = self.collectionInduction.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.collectionInduction indexPathForItemAtPoint:visiblePoint];
    [webViewLoad setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)visibleIndexPath.row]];
    NSLog(@"%@", webViewLoad);
    if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
        isScrolledToBottom = NO;
        NSLog(@"NO");
    }
    else {
        isScrolledToBottom = YES;
        NSLog(@"YES");
    }
    
//    for (UICollectionViewCell *cell in [_collectionInduction visibleCells]){
//        NSIndexPath *indexPath = [_collectionInduction indexPathForCell:cell];
//        NSLog(@"===============>%@",indexPath);
//        [webViewLoad setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
//        NSLog(@"%@", webViewLoad);
//        if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
//            isScrolledToBottom = NO;
//            NSLog(@"NO");
//        }
//        else {
//            isScrolledToBottom = YES;
//            NSLog(@"YES");
//        }
//    }
    
//    UIView *aView = (UIView *)webView;
//    while(aView != nil)
//    {
//        if([aView isKindOfClass:[UICollectionViewCell class]])
//        {
//            NSLog(@"cell class");
//            UICollectionViewCell  *cell = (UICollectionViewCell *) aView;
//            NSIndexPath * indexPath = [self.collectionInduction indexPathForCell:cell];
//
//            if (![webViewLoad valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
//            {
//                NSLog(@"load done class");
//               // [webViewLoad setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
//                NSLog(@"Webview loding finished  %ld",(long)indexPath.row);
//                NSLog(@"%f >= %f",webView.scrollView.contentSize.height, webView.frame.size.height + 30);
//
//                if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
//                    isScrolledToBottom = NO;
//                    NSLog(@"NO");
//                }
//                else {
//                    isScrolledToBottom = YES;
//                    NSLog(@"YES");
//                }
//            }
//            else{
//                NSLog(@"error");
//                NSLog(@"%s",__FUNCTION__);
//            }
//            break;
//        }
//        aView = aView.superview;
//    }
}
*/
#pragma mark - WKNavigation Delegate
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [Common showProgress];
    [Common appDelegate].window.userInteractionEnabled = false;
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView.isLoading){
        [Common showProgress];
        [Common appDelegate].window.userInteractionEnabled = false;
        return;
    }
    [Common hideProgress];
    [Common appDelegate].window.userInteractionEnabled = true;
    
    CGRect visibleRect = (CGRect){.origin = self.collectionInduction.contentOffset, .size = self.collectionInduction.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.collectionInduction indexPathForItemAtPoint:visiblePoint];
    [webViewLoad setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)visibleIndexPath.row]];
    if(webView.scrollView.contentSize.height >= webView.frame.size.height) {
        isScrolledToBottom = NO;
    }
    else {
        isScrolledToBottom = YES;
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    for (UICollectionViewCell *cell in [_collectionInduction visibleCells])
    {
        WKWebView *webView = [cell.contentView viewWithTag:1001];
        if (scrollView == webView.scrollView)
        {
            CGFloat y = webView.scrollView.contentSize.height > webView.frame.size.height ? (webView.scrollView.contentSize.height - webView.frame.size.height) : 0;
            if (scrollView.contentOffset.y >= y)
            {
                NSLog(@"webview scroll bottom reached");
//                _continueBtn.enabled = YES;
                isScrolledToBottom = YES;
            }
            break;
        }
    }
}

#pragma mark - Continue button click
- (IBAction)onContinue:(id)sender {
    
    if(currSeconds == 0){
        for (UICollectionViewCell *cell in [_collectionInduction visibleCells])
        {
            NSIndexPath *indexPath = [_collectionInduction indexPathForCell:cell];
            if (![webViewLoad valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
            {
            }
            break;
        }
        
        UICollectionViewCell *cell=[_collectionInduction cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        
        BEMCheckBox *myCheckBox=[cell.contentView viewWithTag:1002];
        
        
        if (!isScrolledToBottom)
        {
            WKWebView *webView = [cell.contentView viewWithTag:1001];
            if (webView.isLoading){
                
            }else{
                if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
                    isScrolledToBottom = NO;
                    [Common showAlert:@"Alert" :@"Please read all induction content by scrolling down."];
                    return;
                }
                else {
                    isScrolledToBottom = YES;
                }
            }
        }
        
        if (myCheckBox.on)
        {
            selectedIndex++;
            if (selectedIndex>=[_arrSlides count])
            {
                selectedIndex--;
                [self onValideLogin];
            }
            else
            {
                isScrolledToBottom = NO;
                [_collectionInduction scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
                
                NSDictionary *dict = [_arrSlides objectAtIndex:selectedIndex];
                NSString *strTime = [NSString stringWithFormat:@"%@",[dict valueForKey:@"minimumReadingTime"]];
                
                totalTime = [strTime intValue];
                
                if(totalTime == 0) {
                    _lblRemainingTime.hidden = YES;
                }
                else{
                    _lblRemainingTime.hidden = NO;
                    [self readingTimer:totalTime];
                }
            }
        }
        else
        {
            [Common showAlert:@"Alert" :@"You are required to accept before proceeding"];
        }
    }
    else{
        NSString *str = [NSString stringWithFormat:@"The minimum reading time for this page is %d seconds",totalTime];
        [Common showAlert:@"Alert" :str];
    }
}

-(void)onValideLogin
{
    /*
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[_visitorDetails objectForKey:@"phone"] forKey:@"phone"];

    [Common callAPI:parameters Request:API_NOTIFY_INDUCTION_COMPLETED ShowProgress:NO WithCompletionHandler:^(id responseObject) {
        NSLog(@"Notify Induction Completed");
    }];
    */
    [_visitorDetails setObject:_inductionHandle forKey:@"inductionHandle"];
    if ([Common appDelegate].config.customQuestionScreen.visitor.isEnabled) {
        VisitorCustomQuestionVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"VisitorCustomQuestionVC"];
        vc.visitorDetails = _visitorDetails;
        vc.navTitle = self.navTitle;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    else if ([Common appDelegate].config.isPhotoRequiredSignInVisitor || [Common appDelegate].config.isSignatureRequiredVisitor)
    {
        TakePhotoVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
        vc.visitorDetails = _visitorDetails;
        vc.navTitle = self.navTitle;
        vc.isContractor = NO;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    else if ([Common appDelegate].config.signInApprovalScreen.visitor.isEnabled)
    {
        SiteApproverScreenVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
        vc.visitorDetails = self.visitorDetails;
        vc.navTitle = self.navTitle;
        vc.isContractor = NO;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    [_visitorDetails setObject:[_visitorDetails valueForKey:@"phone"] forKey:KEY_MOBILE];
    [Common callVisitorSignInAPI:_visitorDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSLog(@"success");
            [self onPrint:[responseObject mutableCopy]];
            
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[responseObject valueForKey:@"errorMessage"] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}
- (void)onPrint:(NSMutableDictionary *)responceDic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel	*_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=responceDic;
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];
    printResultViewController.navTitle = self.navTitle;
    if (_ptp)
    {
        
//        if ([_ptp isPrinterReady])
//        {
            [printResultViewController.visitorDetails setObject:@"1" forKey:kPrinterStatus];
//        }
//        else
//        {
//            [printResultViewController.visitorDetails setObject:@"Printer is not ready!" forKey:kPrinterMessage];
//        }
    }
    else
    {
        [printResultViewController.visitorDetails setObject:@"Please set printer properly!" forKey:kPrinterMessage];
    }
    [self.navigationController pushViewController:printResultViewController animated:YES];
}
@end

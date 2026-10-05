//
//  MessageBoardVC.m
//  LinkSafe
//
//  Created by uday on 4/11/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import "MessageBoardVC.h"
#import "UIButton+Additions.h"

@interface MessageBoardVC ()
{
    int selectedIndex;
    BOOL isScrolledToBottom;
}

@end

@implementation MessageBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Message Board" parameters:@{@"onload": @"39"}];
    // Do any additional setup after loading the view.
//    //test
//    NSString *html = @"<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style>body {font-family: Arial, Helvetica, sans-serif;font-size: 20px;}#myBtn {display: none;position: fixed;bottom: 20px;right: 30px;z-index: 99;font-size: 18px;border: none;outline: none;background-color: red;color: white;cursor: pointer;padding: 15px;border-radius: 4px;}#myBtn:hover {background-color: #555;}</style></head><body><button onclick=\"topFunction()\" id=\"myBtn\" title=\"Go to top\">Bottom</button><div style=background-color:black;color:white;padding:30px\">Scroll Down</div><div style=\"background-color:lightgrey;padding:30px 30px 2500px\">This example demonstrates how to create a \"scroll to bottom\" button that becomes visible when the user starts to scroll the page.</div><script>window.onload = function() {scrollFunction()};function scrollFunction() {document.getElementById(\"myBtn\").style.display = \"block\";}function topFunction() {window.scrollTo(0,document.body.scrollHeight);}</script></body></html>";
//    [_arrMessages addObject:html];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortedArray = [_arrMessages sortedArrayUsingDescriptors:@[sortDescriptor]];
    _arrMessages = [sortedArray mutableCopy];
    selectedIndex = 0;
    [_btnCancel applyGrayTheme];
    [_continueBtn applyBlueShedow];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isScrolledToBottom = NO;
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Common hideProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrMessages.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HGPhoto";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
//    UIWebView *webView = [cell.contentView viewWithTag:1001];
    WKWebView *webView = [cell.contentView viewWithTag:1001];
    webView.backgroundColor = [UIColor whiteColor];
    NSString *htmlString=[[_arrMessages objectAtIndex:indexPath.row] objectForKey:@"html"];
    
    if ([Common appDelegate].isIpad)
    {
        webView.frame=CGRectMake(0,0,collectionView.frame.size.width,collectionView.frame.size.height-50);
    }
    else
    {
        webView.frame=CGRectMake(0,0,collectionView.frame.size.width,collectionView.frame.size.height-40);
    }
    
    [webView loadHTMLString:htmlString baseURL:nil];
    webView.navigationDelegate=self;
    webView.scrollView.delegate=self;
    return cell;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    /*
    for (UICollectionViewCell *cell in [_collectionInduction visibleCells]) {
        NSIndexPath *indexPath = [_collectionInduction indexPathForCell:cell];
        NSLog(@"===============>%@",indexPath);
    }
    */
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

-(void)removeThisViewController
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)onCancel:(id)sender
{
    _didFinishAcknowledge([@{@"isFinished" : @"no"} mutableCopy]);
    [self removeThisViewController];
}

- (IBAction)onContinue:(id)sender
{
    UICollectionViewCell *cell=[_collectionInduction cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    
    if (!isScrolledToBottom)
    {
        WKWebView *webView = [cell.contentView viewWithTag:1001];
        if (webView.isLoading) {
            
            return;
            
        } else {
            if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
                isScrolledToBottom = NO;
                [Common showAlert:@"Alert" :@"Please read all content by scrolling down."];
                return;
            }
            else {
                isScrolledToBottom = YES;
            }
        }
    }
    
    
    selectedIndex++;
    if (selectedIndex>=[_arrMessages count])
    {
        selectedIndex--;
        _didFinishAcknowledge([@{@"isFinished" : @"yes"} mutableCopy]);
        [self removeThisViewController];
    }
    else
    {
        isScrolledToBottom = NO;
        [_collectionInduction scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

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
    
    if(webView.scrollView.contentSize.height >= webView.frame.size.height + 30) {
        isScrolledToBottom = NO;
    }
    else {
        isScrolledToBottom = YES;
    }
}

@end

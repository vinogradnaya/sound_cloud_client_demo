//
//  ViewController.m
//  TTChallenge
//
//  Created by keksiy on 05.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTSoundCloudManager.h"
#import "TTGradientBackgroundView.h"
#import "TTTrackTableViewCell.h"
#import "TTUser.h"
#import "TTTrack.h"
#import "TTDefines.h"
#import "TTCoreDataManager.h"
#import "TTUserSectionHeaderView.h"
#import "TTConstants.h"
#import "NSString+TTExtras.h"

static NSString *const kTTTrackCellIdentifier = @"trackCell";
static const CGFloat kTTTTTrackRowHeight = 120.f;
static const CGFloat kTTTotalExtraOffset = 45.f;

@interface TTMainViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet TTUserSectionHeaderView *sectionHeader;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sectionHeaderTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sectionHeaderHeightConstraint;
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) TTGradientBackgroundView *backgroundView;
@end

@implementation TTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];

    [self.dataManager addObserver:self];
    [self.dataManager fetchDataIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setting & Customising Views

- (void)setupView
{
    [self setupTableView];
    [self setupBackgroundView];
    [self setupSectionHeader];
    [self setupActivityIndicator];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TTTrackTableViewCell class]) bundle:nil] forCellReuseIdentifier:kTTTrackCellIdentifier];

    self.tableView.contentInset = UIEdgeInsetsMake(self.sectionHeaderTopConstraint.constant + self.sectionHeaderHeightConstraint.constant, 0, 0, 0);
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)setupSectionHeader
{
    self.sectionHeader.alpha = 0;
}

- (void)setupBackgroundView
{
    self.backgroundView = [TTGradientBackgroundView buildViewWithFrame:SCREEN_BOUNDS
                                                            scrollView:self.tableView];
    [self.view insertSubview:self.backgroundView belowSubview:self.tableView];
}

- (void)setupActivityIndicator
{
    [self.activityIndicator startAnimating];
}

- (void)removeActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

- (void)updateViewForUser:(TTUser *)user
{
    self.sectionHeader.user = user;

    __weak typeof(self) weakSelf = self;
    [self.backgroundView customizeForImageWithURL:user.avatarURL
                                       completion:^(UIColor *color, NSError *error) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (color) {
                                               strongSelf.view.backgroundColor = color;
                                               strongSelf.sectionHeader.backgroundColor.backgroundColor = color;
                                           }
                                           // hack to make tableview reload after the background is set
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [strongSelf showSectionHeader];
                                               [strongSelf reloadTableViewIfNeeded];
                                           });
                                       }];
}

- (void)reloadTableViewIfNeeded
{
    // we only need to reload tableview if we perform fetch for the first time, afterwards - we will have delegate do this for us
    if (self.fetchController.delegate == nil) {
        NSError *error = nil;
        if (![self.fetchController performFetch:&error]) {
            TTLog(@"error fetching tracks %@", error);
        } else {
            self.fetchController.delegate = self;
            [self removeActivityIndicator];
            [self.tableView reloadData];
        }
    }
}

- (void)showSectionHeader
{
    if (self.sectionHeader.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.sectionHeader.alpha = 1;
        }];
    }
}

#pragma mark - Observer

- (void)didFetchUser:(TTUser *)user error:(NSError *)error
{
    if (user != nil && error == nil) {
        [self updateViewForUser:user];
    } else {
        if (self.alertView == nil) {
            NSString *message = [NSString stringFromErrorCode:error.code];
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
            [self.alertView show];
        }
        TTLog(@"error fetching user = %@", error);
    }
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController.sections objectAtIndex:0];
     NSInteger number = [sectionInfo numberOfObjects];
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTTrackCellIdentifier forIndexPath:indexPath];
    TTTrack *track = [self.fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    cell.track = track;

    return cell;
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTTTTTrackRowHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;

    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, MAX(-(self.sectionHeaderTopConstraint.constant), -offset), 0);
    self.sectionHeader.layer.transform = transform;

    self.sectionHeader.backgroundColor.alpha = (offset < self.sectionHeaderTopConstraint.constant + kTTTotalExtraOffset) ? 0 : 1;
}

#pragma mark - FetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
}

#pragma mark - Properties

- (TTSoundCloudManager *)dataManager
{
    if (_dataManager != nil) {
        return _dataManager;
    }

    _dataManager = [TTSoundCloudManager sharedManager];
    return _dataManager;
}

- (NSFetchedResultsController *)fetchController
{
    if (_fetchController != nil) {
        return _fetchController;
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TTTrackEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.fetchLimit = 20;

    NSFetchedResultsController *fetchController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:[TTCoreDataManager sharedManager].managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchController = fetchController;
    return _fetchController;
}

@end

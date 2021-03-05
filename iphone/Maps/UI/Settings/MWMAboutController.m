#import "MWMAboutController.h"

#import <CoreApi/MWMFrameworkHelper.h>

#import "SwiftBridge.h"

@interface MWMAboutController () <SettingsTableViewSwitchCellDelegate>

@property(weak, nonatomic) IBOutlet UILabel * versionLabel;
@property(weak, nonatomic) IBOutlet UILabel * dataVersionLabel;

@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * websiteCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * facebookCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * twitterCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * osmCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * rateCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * adsCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewSwitchCell * crashlyticsCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * privacyPolicyCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * termsOfUseCell;
@property(weak, nonatomic) IBOutlet SettingsTableViewLinkCell * copyrightCell;

@property(nonatomic) IBOutlet UIView * headerView;

@end

@implementation MWMAboutController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = L(@"about_menu_title");

  [NSBundle.mainBundle loadNibNamed:@"MWMAboutControllerHeader" owner:self options:nil];
  self.tableView.tableHeaderView = self.headerView;

  AppInfo * appInfo = [AppInfo sharedInfo];
  NSString * version = appInfo.bundleVersion;
  if (appInfo.buildNumber)
    version = [NSString stringWithFormat:@"%@.%@", version, appInfo.buildNumber];
  self.versionLabel.text = [NSString stringWithFormat:L(@"version"), version];

  self.dataVersionLabel.text = [NSString stringWithFormat:L(@"data_version"), [MWMFrameworkHelper dataVersion]];

  [self.crashlyticsCell configWithDelegate:self title:L(@"opt_out_fabric") isOn:![MWMSettings crashReportingDisabled]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  SettingsTableViewLinkCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if (cell == self.websiteCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://omaps.app"]];
  }
  else if (cell == self.facebookCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://facebook.com/MapsWithMe"]];
  }
  else if (cell == self.twitterCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://twitter.com/OMaps"]];
  }
  else if (cell == self.osmCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://www.openstreetmap.org"]];
  }
  else if (cell == self.rateCell)
  {
    [UIApplication.sharedApplication rateApp];
  }
  else if (cell == self.privacyPolicyCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://omaps.app/terms"]];
  }
  else if (cell == self.termsOfUseCell)
  {
    [self openUrl:[NSURL URLWithString:@"https://omaps.app/privacy"]];
  }
  else if (cell == self.copyrightCell)
  {
    NSError * error;
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"copyright" ofType:@"html"];
    NSString * s = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString * text = [NSString stringWithFormat:@"%@\n%@", self.versionLabel.text, s];
    WebViewController * aboutViewController =
        [[WebViewController alloc] initWithHtml:text baseUrl:nil title:L(@"copyright")];
    aboutViewController.openInSafari = YES;
    [self.navigationController pushViewController:aboutViewController animated:YES];
  }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return section == 2 ? L(@"subtittle_opt_out") : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  return section == 2 ? L(@"opt_out_fabric_description") : nil;
}

#pragma mark - SettingsTableViewSwitchCellDelegate

- (void)switchCell:(SettingsTableViewSwitchCell *)cell didChangeValue:(BOOL)value
{
  if (cell == self.crashlyticsCell)
    [MWMSettings setCrashReportingDisabled:!value];
}

@end

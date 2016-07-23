#import <UIKit/UIKit.h>

@class BEBSettingsCell;

@protocol BEBSettingsCellDelegate <NSObject>

- (void)bebSettingsCell:(BEBSettingsCell *)cell didTurnOn:(BOOL)on atIndexPath:(NSIndexPath *)indexPath;

@end

@interface BEBSettingsCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<BEBSettingsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingsSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *facebookImageView;
@property (weak, nonatomic) IBOutlet UIImageView *twitterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *instagramImageView;
@property (weak, nonatomic) IBOutlet UIImageView *youtubuImageView;
@property (weak, nonatomic) IBOutlet UILabel *socialUsername;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

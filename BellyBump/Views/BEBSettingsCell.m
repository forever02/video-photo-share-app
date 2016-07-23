#import "BEBSettingsCell.h"

@interface BEBSettingsCell()

- (IBAction)changeSwitch:(id)sender;

@end

@implementation BEBSettingsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeSwitch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(bebSettingsCell:didTurnOn:atIndexPath:)]) {
        [self.delegate bebSettingsCell:self didTurnOn:[sender isOn] atIndexPath:self.indexPath];
    }
}

@end

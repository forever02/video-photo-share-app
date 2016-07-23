#import "BEBStoryDetailHeaderView.h"

@interface BEBStoryDetailHeaderView()

- (IBAction)editButtonDidTouch:(id)sender;

@end

@implementation BEBStoryDetailHeaderView

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.genderLabel.layer.cornerRadius = CGRectGetHeight(self.genderLabel.frame) / 2;
    self.genderLabel.clipsToBounds = YES;
    
    self.duedateLabel.layer.cornerRadius = CGRectGetHeight(self.duedateLabel.frame) / 2;
    self.duedateLabel.clipsToBounds = YES;
    
    self.storyNameLabel.layer.cornerRadius = CGRectGetHeight(self.storyNameLabel.frame) / 2;
    self.storyNameLabel.clipsToBounds = YES;
    
    self.storyNameTextField.layer.cornerRadius = CGRectGetHeight(self.storyNameTextField.frame) / 2;
    self.storyNameTextField.clipsToBounds = YES;
    
}

- (IBAction)editButtonDidTouch:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setObject:@"passed" forKey:@"tip12Name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tip12Passed" object:nil];

    [self.editButton setHidden:YES];
    [self.storyNameLabel setHidden:YES];
    [self.storyNameTextField setHidden:NO];
    [self.storyNameTextField becomeFirstResponder];
}

@end

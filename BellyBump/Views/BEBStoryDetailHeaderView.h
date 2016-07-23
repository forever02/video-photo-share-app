@interface BEBStoryDetailHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UITextField *storyNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *storyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (strong, nonatomic) IBOutlet UITextField *duedateLabelTextField;
@property (weak, nonatomic) IBOutlet UILabel *duedateLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *genderEditButton;
@property (strong, nonatomic) IBOutlet UIButton *duedateEditButton;

@end

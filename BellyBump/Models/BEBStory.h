
@interface BEBStory : NSObject

@property (nonatomic) NSInteger storyId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) BEBFrequencyType frequence;
@property (nonatomic, getter = isPregnancy) BOOL pregnancy; // pregnancy or new born.
@property (nonatomic) BEBStoryType storyType;
@property (nonatomic) CGPoint faceCenter;
@property (nonatomic) CGPoint bellyBumpCenter;

@property (nonatomic) NSInteger eyeLinePositionY;
@property (nonatomic) NSInteger bellyBumpLinePositionY;

@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic) BEBGenderType gender;

@property (nonatomic, strong) NSMutableArray *photos;

- (NSString *)timeForNextPhoto;
- (void)deleteImagesLocal;

@end

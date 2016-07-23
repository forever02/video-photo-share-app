
#import <Foundation/Foundation.h>

@protocol BEBTableViewDelegate <UITableViewDelegate>

@optional
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForHeaderInSection:(NSUInteger)section;
- (UIView *)viewForHeaderInSection:(NSUInteger)section;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BEBTableViewDelegate : NSObject<BEBTableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIViewController *viewController;

+ (instancetype)delegateForTableView:(UITableView *)tableView inViewController:(UIViewController *)controller;

@end

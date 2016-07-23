
#import <Foundation/Foundation.h>

@protocol BEBTableViewDataSource <UITableViewDataSource>

@optional
- (NSUInteger)numberOfSections;

@required
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)rowNumberOfSection:(NSInteger)section;

@end


@interface BEBTableViewDataSource : NSObject<BEBTableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIViewController *viewController;

+ (instancetype)dataSourceForTableView:(UITableView *)tableView inViewController:(UIViewController *)controller;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end



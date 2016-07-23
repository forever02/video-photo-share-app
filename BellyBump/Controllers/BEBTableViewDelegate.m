
#import "BEBTableViewDelegate.h"

@implementation BEBTableViewDelegate

+ (instancetype)delegateForTableView:(UITableView *)tableView inViewController:(UIViewController *)controller {
    
    BEBTableViewDelegate *delegate = [[self alloc] init];
    if (delegate) {
        delegate.tableView = tableView;
        delegate.viewController = controller;
        tableView.delegate = delegate;
    }
    
    return delegate;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return [self heightForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [self viewForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)heightForHeaderInSection:(NSUInteger)section {
    
    return 0.0f;
}

- (UIView *)viewForHeaderInSection:(NSUInteger)section {
    
    return nil;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

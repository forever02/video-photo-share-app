
#import "BEBTableViewDataSource.h"

@implementation BEBTableViewDataSource

+(instancetype)dataSourceForTableView:(UITableView *)tableView inViewController:(UIViewController *)controller {
    
    BEBTableViewDataSource *dataSource = [[self alloc] init];
    
    if (dataSource) {
        
        dataSource.tableView = tableView;
        dataSource.viewController = controller;
        tableView.dataSource = dataSource;
    }
    
    return dataSource;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self rowNumberOfSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self cellForRowAtIndexPath:indexPath];
}

#pragma mark - BEBTableViewDataSource

- (NSUInteger)numberOfSections {
    
    return 1;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (NSUInteger)rowNumberOfSection:(NSInteger)section {
    
    return 0;
}

#pragma mark - Public APIs
- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

@end

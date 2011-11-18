//
//  MBTiles.m
#import "MBTiles.h"
#import "FMDatabase.h"

@implementation MBTiles 

@synthesize callbackID;

-(void)getTile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options  
{
    self.callbackID = [arguments pop]; 
    NSArray *coords = [[arguments objectAtIndex:0] componentsSeparatedByString:@","];
    NSArray *bundledTileSets = [
        [NSBundle mainBundle]
        pathsForResourcesOfType:@"mbtiles" inDirectory:nil];
    
    NSAssert([bundledTileSets count] > 0, @"No bundled tile sets found in application");
    NSString *path = [[bundledTileSets sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
    NSURL *pathUrl = [NSURL URLWithString: path];
    PluginResult* pluginResult;
    
    // NSLog("%@", [pathUrl relativePath]);

    FMDatabase *db = [FMDatabase
        databaseWithPath:[pathUrl relativePath]];
    
    if (![db open]) {
        pluginResult = [PluginResult
            resultWithStatus:PGCommandStatus_ERROR
            messageAsString:@"database is not open."];
        [super writeJavascript: [pluginResult toErrorCallbackString:self.callbackID]];
        return nil;
    }
    
    FMResultSet *results = [db executeQuery:@"select tile_data \
                            from tiles where zoom_level = ? \
                            and tile_column = ? and tile_row = ?", 
                            [coords objectAtIndex:0], 
                            [coords objectAtIndex:1], 
                            [coords objectAtIndex:2]];
    if ([db hadError]) {
        NSString *errMessage = [NSString stringWithFormat:@"database error: %@", [db lastErrorMessage]];
        pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR messageAsString:errMessage];
        [super writeJavascript: [pluginResult toErrorCallbackString:self.callbackID]];
    } else {
        
        NSData *data = [results dataForColumn:@"tile_data"];
        NSString* jsString = [NSString stringWithUTF8String:[data bytes]];

        PluginResult* pluginResult = [PluginResult
        resultWithStatus:PGCommandStatus_OK messageAsString:
            [jsString
                  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        [super writeJavascript: [pluginResult toSuccessCallbackString:self.callbackID]];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"*** didReceiveMemoryWarning in %@", [self class]);
}

// #pragma mark -
/*

@implementation RMMBTilesTileSource

- (id)initWithTileSetURL:(NSURL *)tileSetURL
{
	if ( ! [super init])
		return nil;
	
	tileProjection = [[RMFractalTileProjection alloc]
        initFromProjection:[self projection] 
        tileSideLength:kMBTilesDefaultTileSize 
        maxZoom:kMBTilesDefaultMaxTileZoom 
        minZoom:kMBTilesDefaultMinTileZoom];
	
    db = [[FMDatabase databaseWithPath:[tileSetURL relativePath]] retain];
    
    if ( ! [db open])
        return nil;
    
	return self;
}

- (void)dealloc
{
	[tileProjection release];
    
    [db close];
    [db release];
    
	[super dealloc];
}

- (RMTileImage *)tileImage:(RMTile)tile
{
    NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
    
    NSInteger zoom = tile.zoom;
    NSInteger x    = tile.x;
    NSInteger y    = pow(2, zoom) - tile.y - 1;
    
    FMResultSet *results = [db executeQuery:@"select tile_data from tiles where zoom_level = ? and tile_column = ? and tile_row = ?", 
                            [NSNumber numberWithFloat:zoom], 
                            [NSNumber numberWithFloat:x], 
                            [NSNumber numberWithFloat:y]];
    
    if ([db hadError])
        return [RMTileImage dummyTile:tile];
    
    [results next];
    
    NSData *data = [results dataForColumn:@"tile_data"];
    
    RMTileImage *image;
    
    if (!data) {
        image = [RMTileImage dummyTile:tile];
    } else {
        image = [RMTileImage imageForTile:tile withData:data];
    }
    
    [results close];
    
    return image;
}


*/

@end
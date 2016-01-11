//
//  RCTFileUploader.h
//  RCTFileUploader
//
//  Created by Fabrice Armisen on 1/6/16.
//  Copyright © 2016 Fabrice Armisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"


static NSString *const METHOD_FIELD = @"method";

static NSString *const UPLOAD_URL_FIELD_NAME = @"uploadUrl";

@interface RCTFileUploader : NSObject<RCTBridgeModule>

@end

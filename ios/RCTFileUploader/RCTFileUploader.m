//
//  RCTFileUploader.m
//  RCTFileUploader
//
//  Created by Fabrice Armisen on 1/6/16.
//  Copyright © 2016 Fabrice Armisen. All rights reserved.
//  Copyright (c) 2015 Kamil Pękala. All rights reserved.
//

#import "RCTFileUploader.h"
#import "RCTLog.h"
#import "RCTUtils.h"

@implementation RCTFileUploader

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(upload:
(NSDictionary *) settings
    callback:
    (RCTResponseSenderBlock) callback) {
    NSString *uri = settings[@"uri"];
    if ([uri hasPrefix:@"file:"]) {
        [self uploadUri:settings callback:callback];
    }
    else if ([uri isAbsolutePath]) {
        [self uploadFile:settings callback:callback];
    }
    else {
        callback(@[RCTMakeError([NSString stringWithFormat:@"Can't handle %@", uri], nil, nil)]);
    }

}

- (void)uploadFile:(NSDictionary *)settings callback:(RCTResponseSenderBlock)callback {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:settings[@"uri"] options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        callback(@[RCTMakeError([error localizedDescription], nil, nil)]);
    } else {
        [self uploadData:data settings:settings callback:callback];
    }

}

- (void)uploadUri:(NSDictionary *)settings callback:(RCTResponseSenderBlock)callback {
    NSURL *url = [NSURL URLWithString:settings[@"uri"]];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        callback(@[RCTMakeError([error localizedDescription], nil, nil)]);
    } else {
        [self uploadData:data settings:settings callback:callback];
    }
}

//uri, // either an 'assets-library' url (for files from photo library) or an image dataURL
//uploadUrl,
//fileName,
//fieldName, // (default="file") the name of the field in the POST form data under which to store the file
//contentType,
//headers,
// method
//data: {
//    // whatever properties you wish to send in the request
//    // along with the uploaded file
//}



- (void)uploadData:(NSData *)data settings:(NSDictionary *)settings callback:(RCTResponseSenderBlock)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:settings[UPLOAD_URL_FIELD_NAME]]];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:settings[METHOD_FIELD] ?: @"POST"];

    NSString *boundary = [[NSUUID UUID] UUIDString];

    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    NSDictionary *extraData = settings[@"data"];
    for (NSString *field in [extraData allKeys]) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", field] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", extraData[field]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *contentType = settings[@"contentType"];
    NSString *filename = settings[@"fileName"] ?: [self filenameForContentType:contentType];
    NSString *fieldName = settings[@"fieldName"];


    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];

    NSString *postLength = [NSString stringWithFormat:@"%d", (int) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
        if (error) {
            callback(@[RCTMakeError([error localizedDescription], nil, nil)]);
        } else {
            NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
            NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *result = @{@"status" : @(statusCode), @"data" : responseBody};
            callback(@[[NSNull null], result]);
        }
    }
    ];

}

- (NSString *)filenameForContentType:(NSString *)contentType {
    NSArray *components = [contentType componentsSeparatedByString:@"/"];
    NSString *extension = [components count] == 2
        ? [NSString stringWithFormat:@".%@", components[1]]
        : @"";

    return [NSString stringWithFormat:@"%lf%@", [[NSDate date] timeIntervalSince1970], extension];
}

@end

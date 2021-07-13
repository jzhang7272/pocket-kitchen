//
//  NutrientApiManager.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/13/21.
//


#import "NutrientApiManager.h"

@implementation NutrientApiManager

- (id)init {
    self = [super init];

    self.session = [NSURLSession sharedSession];
    self.baseURL = @"https://api.nal.usda.gov/fdc/v1/foods/search";
//    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    return self;
}

- (void)fetchFoodItem: (NSString *)query :(int)page :(void(^)(NSArray *foodItems, NSError *error))completion {
//    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
//    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error != nil) {
//            NSLog(@"%@", [error localizedDescription]);
//
//            // The network request has completed, but failed.
//            // Invoke the completion block with an error.
//            // Think of invoking a block like calling a function with parameters
//            completion(nil, error);
//        }
//        else {
//            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//
//            NSArray *dictionaries = dataDictionary[@"results"];
//            NSArray *movies = [Movie moviesWithDictionaries:dictionaries];
//            completion(movies, nil);
//        }
//    }];
//    [task resume];
    // https://api.nal.usda.gov/fdc/v1/foods/search?api_key=DEMO_KEY&query=Cheddar%20Cheese
    
    NSURLComponents *components = [NSURLComponents componentsWithString:self.baseURL];
    NSURLQueryItem *apiKey = [NSURLQueryItem queryItemWithName:@"api_key" value:@"GLI01Ycppc8hpb8MJPDB8Zhar1JbMRzPGFKOlhh5"];
    NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"query" value:query];
//    NSURLQueryItem *dataType = [NSURLQueryItem queryItemWithName:@"dataType" value:@"Survey (FNDDS)"];
    NSURLQueryItem *pageSize = [NSURLQueryItem queryItemWithName:@"pageSize" value:[NSString stringWithFormat:@"%i", page]];
    components.queryItems = @[apiKey, queryItem, pageSize];
                                
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
//    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSLog(@"%@", httpResponse);
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
//            NSArray *dictionaries = dataDictionary[@"hits"];
            // NSArray *movies = [Movie moviesWithDictionaries:dictionaries];
        }
    }];
    [dataTask resume];
}


@end

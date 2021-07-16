//
//  NutrientApiManager.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/13/21.
//


#import "NutrientApiManager.h"

#import "FoodItem.h"

@implementation NutrientApiManager

- (id)init {
    self = [super init];

    self.session = [NSURLSession sharedSession];
    self.baseURL = @"https://api.nal.usda.gov/fdc/v1/foods/search";
//    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    return self;
}

- (void)fetchFoodItem: (NSString *)query :(int)page :(void(^)(NSArray *foodItems, NSError *error))completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.baseURL];
    NSURLQueryItem *apiKey = [NSURLQueryItem queryItemWithName:@"api_key" value:@"GLI01Ycppc8hpb8MJPDB8Zhar1JbMRzPGFKOlhh5"];
    NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"query" value:query];
//    NSURLQueryItem *dataType = [NSURLQueryItem queryItemWithName:@"dataType" value:@"Survey (FNDDS)"];
    NSURLQueryItem *pageSize = [NSURLQueryItem queryItemWithName:@"pageSize" value:[NSString stringWithFormat:@"%i", page]];
    components.queryItems = @[apiKey, queryItem, pageSize];
                                
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];

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

// Parser API - GET
- (void)fetchFood:(NSString *)item :(void(^)(NSDictionary *, NSString *, NSError *))completion{
    
    NSString *baseParseURL = @"https://api.edamam.com/api/food-database/v2/parser";
    NSURLComponents *components = [NSURLComponents componentsWithString:baseParseURL];
    NSURLQueryItem *appID = [NSURLQueryItem queryItemWithName:@"app_id" value:@"03df0f4f"];
    NSURLQueryItem *appKey = [NSURLQueryItem queryItemWithName:@"app_key" value:@"4322af03056e14eafae0bfebbcc340e8"];
    NSURLQueryItem *ingr = [NSURLQueryItem queryItemWithName:@"ingr" value:item];
    NSURLQueryItem *nutritionType = [NSURLQueryItem queryItemWithName:@"nutrition-type" value:@"cooking"];
    NSURLQueryItem *category = [NSURLQueryItem queryItemWithName:@"category" value:@"generic-foods"];
    components.queryItems = @[appID, appKey, ingr, nutritionType, category];
                                
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    NSMutableString *foodID = [NSMutableString stringWithString:@""];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completion(nil, nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            foodID.string = dataDictionary[@"parsed"][0][@"food"][@"foodId"];
            NSString *foodImage = dataDictionary[@"parsed"][0][@"food"][@"image"];
            [self fetchNutrients :foodID :@"http://www.edamam.com/ontologies/edamam.owl#Measure_unit" :^(NSDictionary *dictionary, NSError *error){
                if(error){
                    NSLog(@"%@", error.localizedDescription);
                }
                else{
                    [nutrients addEntriesFromDictionary:dictionary];
                    completion(nutrients, foodImage, nil);
                }
            }];
        }
    }];
    [dataTask resume];
}

// Nutrients API - POST
- (void) fetchNutrients:(NSString *)foodID :(NSString *)url :(void(^)(NSDictionary *, NSError *))completion{
    NSString *baseNutrientURL = @"https://api.edamam.com/api/food-database/v2/nutrients";
    NSURLComponents *nutrientComponents = [NSURLComponents componentsWithString:baseNutrientURL];
    NSURLQueryItem *appID = [NSURLQueryItem queryItemWithName:@"app_id" value:@"03df0f4f"];
    NSURLQueryItem *appKey = [NSURLQueryItem queryItemWithName:@"app_key" value:@"4322af03056e14eafae0bfebbcc340e8"];
    nutrientComponents.queryItems = @[appID, appKey];

    NSMutableURLRequest *requestNutrient = [NSMutableURLRequest requestWithURL:nutrientComponents.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

    // Create POST method
    [requestNutrient setHTTPMethod:@"POST"];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"ingredients\": [{\"quantity\": 1,\"measureURI\": \"%@\",\"foodId\": \"%@\"}]}", url, foodID];

    // Apply data to body
    [requestNutrient setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [requestNutrient setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    NSURLSession *nutrient_session = [NSURLSession sharedSession];
    NSURLSessionDataTask *nutrient_dataTask = [nutrient_session dataTaskWithRequest:requestNutrient completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completion(nil, error);
        }
        else {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            NSLog(@"%@", httpResponse);
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([dataDictionary[@"totalNutrients"] count] == 0){
                NSLog(@"1");
                [self fetchNutrients :foodID :@"http://www.edamam.com/ontologies/edamam.owl#Measure_serving" :^(NSDictionary *dictionary, NSError *error){
                    if(error){
                        NSLog(@"%@", error.localizedDescription);
                        completion(nil, error);
                    }
                    else{
                        [nutrients addEntriesFromDictionary:dictionary];
                        completion(nutrients, nil);
                    }
                }];
            }
            else{
                [nutrients addEntriesFromDictionary: [FoodItem initNutrients:dataDictionary[@"totalNutrients"]]];
                completion(nutrients, nil);
            }
        }
    }];
    [nutrient_dataTask resume];
}

@end

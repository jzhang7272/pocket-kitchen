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
    self.servingURL = @"http://www.edamam.com/ontologies/edamam.owl#Measure_serving";

    return self;
}

- (void)fetchInventoryNutrients:(NSString *)item :(NSString *)nutrientType :(void(^)(NSDictionary *, BOOL, NSString *, NSError *))completion{
    
    NSString *baseParseURL = @"https://api.edamam.com/api/food-database/v2/parser";
    NSURLComponents *components = [NSURLComponents componentsWithString:baseParseURL];
    NSURLQueryItem *appID = [NSURLQueryItem queryItemWithName:@"app_id" value:@"03df0f4f"];
    NSURLQueryItem *appKey = [NSURLQueryItem queryItemWithName:@"app_key" value:@"4322af03056e14eafae0bfebbcc340e8"];
    NSURLQueryItem *ingr = [NSURLQueryItem queryItemWithName:@"ingr" value:item];
    NSURLQueryItem *nutritionType = [NSURLQueryItem queryItemWithName:@"nutrition-type" value:@"cooking"];
    // NSURLQueryItem *category = [NSURLQueryItem queryItemWithName:@"category" value:@"generic-foods"];
    components.queryItems = @[appID, appKey, ingr, nutritionType];
                                
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    NSMutableString *foodID = [NSMutableString stringWithString:@""];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completion(nil, nil, nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            foodID.string = dataDictionary[@"hints"][0][@"food"][@"foodId"];
            NSString *foodImage = dataDictionary[@"hints"][0][@"food"][@"image"];
            NSString *alternateUnitURL = dataDictionary[@"hints"][0][@"measures"][0];
            
            [self fetchNutrientHelper :foodID :self.servingURL :alternateUnitURL :@"totalNutrients" :^(NSDictionary *dictionary, BOOL cup, double nil1, NSError *error){
                if(error){
                    NSLog(@"%@", error.localizedDescription);
                }
                else{
                    [nutrients addEntriesFromDictionary:dictionary];
                    completion(nutrients, cup, foodImage, nil);
                }
            }];
        }
    }];
    [dataTask resume];
}

- (void)fetchGroceryNutrients:(NSString *)foodItem :(void(^)(NSDictionary *, double nmbrServings, NSError *))completion{

    int quantity = (foodItem.integerValue > 0) ? foodItem.integerValue : 1;

    NSString *baseParseURL = @"https://api.edamam.com/api/food-database/v2/parser";
    NSURLComponents *components = [NSURLComponents componentsWithString:baseParseURL];
    NSURLQueryItem *appID = [NSURLQueryItem queryItemWithName:@"app_id" value:@"03df0f4f"];
    NSURLQueryItem *appKey = [NSURLQueryItem queryItemWithName:@"app_key" value:@"4322af03056e14eafae0bfebbcc340e8"];
    NSURLQueryItem *ingr = [NSURLQueryItem queryItemWithName:@"ingr" value:foodItem];
    NSURLQueryItem *nutritionType = [NSURLQueryItem queryItemWithName:@"nutrition-type" value:@"cooking"];
    components.queryItems = @[appID, appKey, ingr, nutritionType];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

    [request setHTTPMethod:@"GET"];

    
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    NSMutableString *foodID = [NSMutableString stringWithString:@""];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"hints"] count] == 0) {
            NSLog(@"%@", error);
            completion(nil, 0, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            foodID.string = dataDictionary[@"hints"][0][@"food"][@"foodId"];
            double totalWeight = quantity * [dataDictionary[@"hints"][0][@"measures"][0][@"weight"] doubleValue];
            NSString *alternateUnitURL = dataDictionary[@"hints"][0][@"measures"][0][@"uri"];
            [self fetchNutrientHelper :foodID :self.servingURL :alternateUnitURL :@"totalNutrients" :^(NSDictionary *dictionary, BOOL cup, double weightOneUnit, NSError *error){
                if(error){
                    NSLog(@"%@", error.localizedDescription);
                    completion(nil, 0, error);
                }
                else{
                    double nmbrServings = totalWeight / weightOneUnit;
                    [nutrients addEntriesFromDictionary:dictionary];
                    completion(nutrients, nmbrServings, nil);
                }
            }];
        }
    }];
    [dataTask resume];
}

// Nutrients API - POST
- (void) fetchNutrientHelper:(NSString *)foodID :(NSString *)unitURL :(NSString *)alternateUnitURL :(NSString *)nutrientType :(void(^)(NSDictionary *, BOOL, double, NSError *))completion{
    NSString *baseNutrientURL = @"https://api.edamam.com/api/food-database/v2/nutrients";
    NSURLComponents *nutrientComponents = [NSURLComponents componentsWithString:baseNutrientURL];
    NSURLQueryItem *appID = [NSURLQueryItem queryItemWithName:@"app_id" value:@"03df0f4f"];
    NSURLQueryItem *appKey = [NSURLQueryItem queryItemWithName:@"app_key" value:@"4322af03056e14eafae0bfebbcc340e8"];
    nutrientComponents.queryItems = @[appID, appKey];

    NSMutableURLRequest *requestNutrient = [NSMutableURLRequest requestWithURL:nutrientComponents.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

    // Create POST method
    [requestNutrient setHTTPMethod:@"POST"];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"ingredients\": [{\"quantity\": 1,\"measureURI\": \"%@\",\"foodId\": \"%@\"}]}", unitURL, foodID];

    // Apply data to body
    [requestNutrient setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [requestNutrient setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    NSURLSession *nutrient_session = [NSURLSession sharedSession];
    NSURLSessionDataTask *nutrient_dataTask = [nutrient_session dataTaskWithRequest:requestNutrient completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            completion(nil, nil, 0, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([dataDictionary[nutrientType] count] == 0){
                [self fetchNutrientHelper :foodID :alternateUnitURL :alternateUnitURL :nutrientType :^(NSDictionary *dictionary, BOOL nil1, double weight, NSError *error){
                    if(error){
                        NSLog(@"%@", error.localizedDescription);
                        completion(nil, nil, 0, error);
                    }
                    else{
                        completion(dictionary, true, weight, nil);
                    }
                }];
            }
            else{
                double weightOneUnit = [dataDictionary[@"totalWeight"] doubleValue];
                completion(dataDictionary[nutrientType], false, weightOneUnit, nil);
            }
        }
    }];
    [nutrient_dataTask resume];
}





@end

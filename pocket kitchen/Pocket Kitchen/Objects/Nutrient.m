//
//  RecommendedNutrients.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "Nutrient.h"
#import "FoodItem.h"
#import "NutrientApiManager.h"

@implementation Nutrient

- (instancetype)initNutrient:(double)quantity :(NSString *)unit :(NSString *)code :(NSString *)name{
    self = [super init];
    if (self){
        self.quantity = quantity;
        self.unit = unit;
        self.code = code;
        self.name = name;
    }
    return self;
}

+ (void) updateSource:(Nutrient *)nutrient :(NSString *)source{
    if (nutrient.source == nil){
        nutrient.source = [NSMutableArray new];
    }
    [nutrient.source addObject:source];
}

+ (void) checkNutrition{
    // Get recently bought items/items in inventory
    // For each new item, check for all nutrients if it is high/low in that nutrient
    // If it is, add to array - items in array should disappear after 3 weeks
}

+ (NSDictionary *)recommendedNutrientAmount:(int) days{
    NSMutableDictionary *recommendedAmount = [NSMutableDictionary new];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient :(900*days) :@"\u03BCg" :@"VITA_RAE" :@"Vitamin A"] forKey:@"VITA_RAE"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(90*days) :@"mg" :@"VITC" :@"Vitamin C"] forKey:@"VITC"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(1300*days) :@"mg" :@"CA" :@"Calcium"] forKey:@"CA"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(18*days) :@"mg" :@"FE" :@"Iron"] forKey:@"FE"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(20*days) :@"\u03BCg" :@"VITD" :@"Vitamin D"] forKey:@"VITD"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(15*days) :@"mg" :@"TOCPHA" :@"Vitamin E"] forKey:@"TOCPHA"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(120*days) :@"\u03BCg" :@"VITK1" :@"Vitamin K"] forKey:@"VITK1"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(1.2*days) :@"mg" :@"THIA" :@"Thiamin (B1)"] forKey:@"THIA"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(1.3*days) :@"mg" :@"RIBF" :@"Riboflavin (B2)"] forKey:@"RIBF"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(16*days) :@"mg" :@"NIA" :@"Niacin (B3)"] forKey:@"NIA"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(1.7*days) :@"mg" :@"VITB6A" :@"Vitamin B6"] forKey:@"VITB6A"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(400*days) :@"\u03BCg" :@"FOLDFE" :@"Folate"] forKey:@"FOLDFE"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(2.4*days) :@"\u03BCg" :@"VITB12" :@"Vitamin B12"] forKey:@"VITB12"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(1250*days) :@"mg" :@"P" :@"Phosphorus"] forKey:@"P"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(420*days) :@"mg" :@"MG" :@"Magnesium"] forKey:@"MG"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(4700*days) :@"mg" :@"K" :@"Potassium"] forKey:@"K"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(78*days) :@"g" :@"FAT" :@"Fat"] forKey:@"FAT"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(20*days) :@"g" :@"FASAT" :@"Saturated"] forKey:@"FASAT"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(300*days) :@"mg" :@"CHOLE" :@"Cholesterol"] forKey:@"CHOLE"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(275*days) :@"g" :@"CHOCDF" :@"Carbs"] forKey:@"CHOCDF"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(2300*days) :@"mg" :@"NA" :@"Sodium"] forKey:@"NA"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(28*days) :@"g" :@"FIBTG" :@"Fiber"] forKey:@"FIBTG"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(50*days) :@"g" :@"PROCNT" :@"Protein"] forKey:@"PROCNT"];
    [recommendedAmount setObject:[[Nutrient alloc] initNutrient:(50*days) :@"g" :@"SUGAR" :@"Sugars"] forKey:@"SUGARS"];
    return recommendedAmount;
}

// positive if nutrient missing
+ (NSDictionary*)nutrientDifference:(NSArray *)groceryItems :(NSMutableDictionary *)recommendedNutrients {
    dispatch_group_t group = dispatch_group_create();
    NSMutableDictionary *sumNutrients = [NSMutableDictionary new];
    NSMutableDictionary *diffNutrients = [NSMutableDictionary new];
    
    for (int i = 0; i < [groceryItems count]; i ++){
        dispatch_group_enter(group);
        FoodItem *groceryItem = [groceryItems objectAtIndex:i];
    
        NutrientApiManager *nutrientApi = [NutrientApiManager new];
        [nutrientApi fetchFoodID:groceryItem.name :@"http://www.edamam.com/ontologies/edamam.owl#Measure_serving" :@"totalNutrients" :^(NSDictionary *groceryNutrients, BOOL unitGram, NSString *foodImage, NSError *error) {
            if(error){
                NSLog(@"%@", error.localizedDescription);
            }
            else{
                for(id nutrient in recommendedNutrients){
                    NSDictionary *nutrientDetails = groceryNutrients[nutrient];
                    double quantity = [nutrientDetails[@"quantity"] doubleValue];
                    Nutrient *nutrientItem = [sumNutrients objectForKey:nutrient];
                    if (nutrientItem){
                        nutrientItem.quantity += quantity;
                        [sumNutrients setObject:nutrientItem forKey:nutrient];
                    }
                    else{
                        [sumNutrients setObject:[[Nutrient alloc] initNutrient:[nutrientDetails[@"quantity"] doubleValue] :nutrientDetails[@"unit"] :nutrient :nutrientDetails[@"label"]] forKey:nutrient];
                    }
                }
            }
            dispatch_group_leave(group);
        }];
    }
        
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    for(id nutrient in recommendedNutrients){
        Nutrient *sumNutrient = [sumNutrients objectForKey:nutrient];
        Nutrient *recommendedNutrient = [recommendedNutrients objectForKey:nutrient];
        double diff = recommendedNutrient.quantity - sumNutrient.quantity;
        [diffNutrients setObject:[NSNumber numberWithDouble:diff] forKey:nutrient];
    }
    return diffNutrients;
}

@end

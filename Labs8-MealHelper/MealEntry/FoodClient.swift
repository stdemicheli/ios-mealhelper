//
//  FoodClient.swift
//  Labs8-MealHelper
//
//  Created by De MicheliStefano on 15.11.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation

class FoodClient {
    
    static let shared = FoodClient()
    
    // TODO: to be deleted. just a hack for saving data
    var ingredients = [Ingredient]()
    var recipes = [
        Recipe(name: "Smørrebrød", calories: 123, servings: 1, ingredients: [], userId: 1, mealId: 1),
        Recipe(name: "Leverpostej", calories: 123, servings: 1, ingredients: [], userId: 1, mealId: 1),
        Recipe(name: "Fiskefrikadeller", calories: 123, servings: 1, ingredients: [], userId: 1, mealId: 1),
        Recipe(name: "Mørbradbøffer", calories: 123, servings: 1, ingredients: [], userId: 1, mealId: 1),
        Recipe(name: "Æbleflæsk", calories: 123, servings: 1, ingredients: [], userId: 1, mealId: 1)
    ]
    var meals = [Meal]()
    
    let usdaBaseUrl: URL = URL(string: "https://api.nal.usda.gov/ndb/search/")!
    let usdaAPIKey = "c24xU3JZJhbrgnquXUNlyAGXcysBibSmESbE3Nl6"
    let baseUrl: URL = URL(string: "https://labs8-meal-helper.herokuapp.com/")!
    var userId = Constants.User().id
    //var userId = String(UserDefaults().loggedInUserId())
    
    // MARK: - Meal Helper
    
    func fetchMeals(for user: User, completion: @escaping (Response<[Meal]>) -> ()) {
        var url = baseUrl
        url.appendPathComponent("users")
        url.appendPathComponent(userId) // TODO: Fetch user id from local store
        url.appendPathComponent("meals")
        
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                let meals = try JSONDecoder().decode([Meal].self, from: data)
                completion(Response.success(meals))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
        }.resume()
    }
    
    func fetchRecipes(for user: User, completion: @escaping (Response<[Recipe]>) -> ()) {
        var url = baseUrl
        url.appendPathComponent("recipe")
        url.appendPathComponent(userId) // TODO: Fetch user id from local store
        
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                completion(Response.success(recipes))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
        }.resume()
    }
    
    func fetchIngredients(for user: User, completion: @escaping (Response<[Ingredient]>) -> ()) {
        var url = baseUrl
        url.appendPathComponent("ingredients")
        url.appendPathComponent(userId) // TODO: Fetch user id from local store
        
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                let ingredient = try JSONDecoder().decode([Ingredient].self, from: data)
                completion(Response.success(ingredient))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
        }.resume()
    }
    
    func postMeal(with userCredentials: User, mealTime: String, experience: String?, date: String, completion: @escaping (Response<Int>) -> ()) {
        
        var url = baseUrl
        url.appendPathComponent("users")
        url.appendPathComponent(userId)
        url.appendPathComponent("meals")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let ingredientDetails = [
                "user_id": userId,
                "mealTime": mealTime,
                "experience": experience,
                "date": date
            ]
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let ingredientJson = try encoder.encode(ingredientDetails)
            urlRequest.httpBody = ingredientJson
        } catch {
            NSLog("Failed to encode ingredients: \(error)")
            completion(Response.error(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                // TODO: Handle response. Note: backend response objects change with each request. Backend should standardize success and failure responses.
                //let ingredientId = try JSONDecoder().decode(Int.self, from: data)
                completion(Response.success(1))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
        }.resume()
    }
    
    
    func postIngredient(with userCredentials: User, name: String, nutrientId: String?, completion: @escaping (Response<Int>) -> ()) {
        
        var url = baseUrl
        url.appendPathComponent("ingredients")
        url.appendPathComponent(userId)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let ingredientDetails = ["name": name, "nutrients_id": nutrientId]
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let ingredientJson = try encoder.encode(ingredientDetails)
            urlRequest.httpBody = ingredientJson
        } catch {
            NSLog("Failed to encode ingredients: \(error)")
            completion(Response.error(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                // TODO: Handle response. Note: backend response objects change with each request. Backend should standardize success and failure responses.
                //let ingredientId = try JSONDecoder().decode(Int.self, from: data)
                completion(Response.success(1))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
        }.resume()
    }
    
    // MARK: USDA
    
    func fetchUsdaIngredients(with searchTerm: String, completion: @escaping (Response<[Ingredient]>) -> ()) {
        var urlComponents = URLComponents(url: usdaBaseUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "sort", value: "n"),
            URLQueryItem(name: "max", value: "25"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "api_key", value: usdaAPIKey),
            URLQueryItem(name: "q", value: searchTerm)
        ]
        
        guard let requestURL = urlComponents.url else {
            NSLog("Problem constructing search URL for \(searchTerm)")
            completion(Response.error(NSError()))
            return
        }
        
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { (data, res, error) in
            
            if let error = error {
                NSLog("Error with urlReqeust: \(error)")
                completion(Response.error(error))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(Response.error(NSError()))
                return
            }
            
            do {
                let usdaIngredients = try JSONDecoder().decode(UsdaIngredients.self, from: data)
                let ingredients: [Ingredient] = self.convertToIngredient(usdaIngredients.list.item)
                completion(Response.success(ingredients))
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(Response.error(error))
                return
            }
            
            }.resume()
    }
    
    // MARK: - Private
    
    private func convertToIngredient(_ usdaIngredients: [UsdaIngredients.Item.UsdaIngredient]) -> [Ingredient] {
        return usdaIngredients.map { Ingredient(name: $0.name, nbdId: $0.ndbId) }
    }
    
}

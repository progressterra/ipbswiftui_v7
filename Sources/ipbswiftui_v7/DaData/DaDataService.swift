//
//  DaDataService.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.08.2023.
//

import Combine
import ipbswiftapi_v7
import Foundation

/// Provides services for accessing the DaData API for address suggestions and reverse geocoding.
///
/// The `DaDataService` struct offers methods to retrieve suggestions for addresses and to get addresses based on geographic coordinates. It utilizes `NetworkDispatcher` for network requests, ensuring proper request handling and error management.
///
/// ## Usage
///
/// Ensure that `IPBSettings.daDataBaseURL` and `IPBSettings.daDataAPIKey` are set correctly in your app's configuration.
///
/// ### Getting Suggestions for an Address
///
/// To get address suggestions, call `getSuggestions(for:)` with the address query:
///
/// ```swift
/// daDataService.getSuggestions(for: "address query")
/// ```
///
/// ### Getting Address by Geographic Coordinates
///
/// To find an address based on latitude and longitude, use `getAddressByGeo(latitude:longitude:)`:
///
/// ```swift
/// daDataService.getAddressByGeo(latitude: 55.7558, longitude: 37.6173)
/// ```
///
/// ## Responses
///
/// Both methods return a publisher that emits `Suggestions` on success or a `NetworkRequestError` on failure.
///
/// - `Suggestions`: A struct containing an array of `Suggestion`, each representing a possible match for the query.
/// - `Suggestion`: Represents a single address suggestion with a `value` property containing the suggested address as a string.
///
/// ## Example
///
/// ```swift
/// let daDataService = DaDataService()
/// daDataService.getSuggestions(for: "Kremlin")
///     .sink(receiveCompletion: { completion in
///         // Handle completion
///     }, receiveValue: { suggestions in
///         // Process suggestions
///     })
///     .store(in: &subscriptions)
/// ```
///
/// This service requires an active subscription to DaData and proper configuration of API keys and base URLs in `IPBSettings`.
public struct DaDataService {
    
    private let networkDispatcher: NetworkDispatcher
    
    public init(networkDispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.networkDispatcher = networkDispatcher
    }
    
    public func getSuggestions(for address: String) -> AnyPublisher<Suggestions, NetworkRequestError> {
        guard let url = URL(string: IPBSettings.daDataBaseURL + "/suggest/address") else {
            return Fail(error: NetworkRequestError.customError("Invalid URL")).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token \(IPBSettings.daDataAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body = ["query": address]
        if let httpBody = try? JSONEncoder().encode(body) {
            request.httpBody = httpBody
        }
        
        return networkDispatcher.dispatch(request: request)
    }
    
    public func getAddressByGeo(latitude: Double, longitude: Double) -> AnyPublisher<Suggestions, NetworkRequestError> {
        guard let url = URL(string: IPBSettings.daDataBaseURL + "/geolocate/address") else {
            return Fail(error: NetworkRequestError.customError("Invalid URL")).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token \(IPBSettings.daDataAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body = ["lat": latitude, "lon": longitude]
        if let httpBody = try? JSONEncoder().encode(body) {
            request.httpBody = httpBody
        }
        
        return networkDispatcher.dispatch(request: request)
    }
}

//
//  MainViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Combine
import Foundation
import ipbswiftapi_v7

/// A view model for managing the main interface of an application, handling the loading and presentation of product lists from various categories.
///
/// The `MainViewModel` orchestrates fetching product data from predefined product categories in ``IPBSettings`` like top sales, promotions, and new arrivals. It updates the UI based on the state of these operations, such as indicating loading progress, handling errors, and updating the UI when data is received.
///
public class MainViewModel: ObservableObject {
    
    /// Stores the results of product list fetches indexed by category ID.
    @Published public var productListResults: [String: [ProductViewDataModel]] = [:]
    
    /// Indicates whether the view model is currently performing a network request.
    @Published public var isLoading: Bool = false
    
    /// Stores the request ID of the last network call made, useful for animating data appearing.
    @Published public var xRequestID: String?
    
    @Published public var showErrorAlert: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var error: NetworkRequestError? {
        didSet {
            if let error {
                switch error {
                case let NetworkRequestError.badRequest(message),
                    let NetworkRequestError.customError(message),
                    let NetworkRequestError.serverError(message),
                    let NetworkRequestError.forbidden(message),
                    let NetworkRequestError.unknownError(message):
                    errorMessage = message
                    showErrorAlert = true
                default:
                    print("An unexpected error occurred - \(error)")
                }
            }
        }
    }
    
    private let productService: ProductService
    private var subscriptions: Set<AnyCancellable> = []
    
    public init(productService: ProductService = ProductService()) {
        self.productService = productService
    }
    
    /// Sets up the view model by initiating the product list fetch process.
    public func setUpView() {
        fetchProductList(for: IPBSettings.topSalesCategoryID)
        fetchProductList(for: IPBSettings.promoProductsCategoryID)
        fetchProductList(for: IPBSettings.newProductsCategoryID)
    }
    
    private func fetchProductList(for idCategory: String) {
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(
                    fieldName: "nomenclature.listCatalogCategory",
                    listValue: [idCategory],
                    comparison: .equalsStrong
                )
            ],
            sort: SortData(fieldName: "", variantSort: .asc),
            searchData: "",
            skip: 0,
            take: 10
        )
        
        productService.fetchProductList(for: idCategory, using: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                if result.result.status == .success {
                    self?.xRequestID = result.result.xRequestID
                    self?.productListResults[idCategory] = result.dataList
                }
            }
            .store(in: &subscriptions)
    }
}

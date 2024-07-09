//
//  CatalogViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Foundation
import Combine
import ipbswiftapi_v7

/// A view model responsible for managing and fetching catalog data and products.
///
/// ## Overview
/// The `CatalogViewModel` is typically used in conjunction with views that display catalog data, such as `CatalogView` or `CatalogProductListView`.
/// - Manages the fetching and displaying of catalog categories and products.
/// - Handles user interactions for navigating through different catalog categories.
/// - Keeps track of the product list for each catalog category.
/// - Manages loading states and error handling.
///
/// ## Features
/// - **Dynamic Data Loading**: Loads catalog data and products dynamically based on user interaction and navigation.
/// - **Error Handling**: Captures and handles errors during data fetching, providing error messages and managing error states.
/// - **State Management**: Manages various states including loading, error, and data presentation.
/// - **Navigation Management**: Handles the logic for managing the stack of navigated catalog items, allowing for backward navigation in a hierarchical catalog structure.
///
public class CatalogViewModel: ObservableObject {
    
    @Published public var catalogCategoryResult: ResultData<RFCatalogCategoryViewModel>?
    
    /// Stores product data for each catalog category, indexed by category ID.
    @Published public var productListResults: [String: [ProductViewDataModel]] = [:]
    
    @Published public var searchText: String = ""
    
    /// Maintains a navigation stack of catalog items to manage hierarchical navigation.
    @Published public var navigationStack: [CatalogItem] = []
    
    @Published public var rootCatalogItem: CatalogItem?
    
    @Published public var isLoading: Bool = false
    
    /// Stores the unique request ID from the last fetch, usable to animate data appearing.
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
    
    private var subscriptions = Set<AnyCancellable>()
    private let catalogService: CatalogService
    private let productService: ProductService
    
    public init(catalogService: CatalogService = CatalogService(), productService: ProductService = ProductService()) {
        self.catalogService = catalogService
        self.productService = productService
    }
    
    /// Fetches the root catalog categories and initializes the navigation stack.
    public func getCatalog() {
        guard rootCatalogItem == nil else { return }
        
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(fieldName: "", listValue: [], comparison: .equalsStrong)
            ],
            sort: nil,
            searchData: searchText,
            skip: 0,
            take: 30
        )
        
        catalogService.getCatalog(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                if let catalog = result.data {
                    self?.rootCatalogItem = catalog
                }
            }
            .store(in: &subscriptions)
    }
    
    /// Fetches category details for a specified category ID.
    public func getCatalogCategory(by categoryID: String) {
        isLoading = true
        
        catalogService.getCatalogCategory(by: categoryID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.catalogCategoryResult = result
            }
            .store(in: &subscriptions)
    }
    
    /// Fetches products for a specified catalog category ID.
    public func fetchProductList(for idCategory: String) {
        guard productListResults[idCategory] == nil else { return }
        
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
            searchData: searchText,
            skip: 0,
            take: 25
        )
        
        productService.fetchProductList(for: idCategory, using: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.xRequestID = result.result.xRequestID
                self?.productListResults[idCategory] = result.dataList
            }
            .store(in: &subscriptions)
    }
}

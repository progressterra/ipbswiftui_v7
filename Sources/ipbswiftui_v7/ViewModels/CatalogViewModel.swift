//
//  CatalogViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Foundation
import Combine
import ipbswiftapi_v7

public class CatalogViewModel: ObservableObject {
    
    @Published public var catalogCategoryResult: ResultData<RFCatalogCategoryViewModel>?
    @Published public var productListResults: [String: [ProductViewDataModel]] = [:]
    @Published public var navigationStack: [CatalogItem] = []
    @Published public var rootCatalogItem: CatalogItem?
    
    @Published public var isLoading: Bool = false
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
    
    public func getCatalog() {
        guard rootCatalogItem == nil else { return }
        
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(fieldName: "", listValue: [], comparison: .equalsStrong)
            ],
            sort: nil,
            searchData: nil,
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
    
    public func fetchProductList(for idCategory: String) {
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

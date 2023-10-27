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
    @Published public var currentCatalogItem: CatalogItem? {
        didSet {
            if currentCatalogItem == nil {
                getCatalog()
            }
        }
    }
    
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getCatalog()
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                if result.result.status == .success {
                    self?.currentCatalogItem = result.data
                }
            }
            .store(in: &subscriptions)
    }
    
    public func getCatalogCategory(by categoryID: String) {
        isLoading = true
        
        catalogService.getCatalogCategory(by: categoryID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getCatalogCategory(by: categoryID)
                        }
                    }
                case .finished:
                    break
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.fetchProductList(for: idCategory)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.xRequestID = result.result.xRequestID
                self?.productListResults[idCategory] = result.dataList
            }
            .store(in: &subscriptions)
    }
}

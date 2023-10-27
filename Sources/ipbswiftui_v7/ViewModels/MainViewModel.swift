//
//  MainViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Combine
import Foundation
import ipbswiftapi_v7

public class MainViewModel: ObservableObject {
    
    @Published public var productListResults: [String: [ProductViewDataModel]] = [:]
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
    
    private let productService: ProductService
    private var subscriptions = Set<AnyCancellable>()
    
    public init(productService: ProductService = ProductService()) {
        self.productService = productService
    }
    
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
                if result.result.status == .success {
                    self?.xRequestID = result.result.xRequestID
                    self?.productListResults[idCategory] = result.dataList
                }
            }
            .store(in: &subscriptions)
    }
}

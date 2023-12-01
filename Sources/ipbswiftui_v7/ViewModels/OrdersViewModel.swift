//
//  OrdersViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import Combine
import Foundation
import ipbswiftapi_v7

public class OrdersViewModel: ObservableObject {
    
    @Published public var orderList: ResultDataList<DHSaleHeadAsOrderViewModel>?
    @Published public var productDictionary: [String: ProductViewDataModel] = [:]
    
    @Published public var isLoading: Bool = false
    
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
    
    private let orderService: OrderService
    private let productService: ProductService
    private var subscriptions = Set<AnyCancellable>()
    
    public init(orderService: OrderService = OrderService(), productService: ProductService = ProductService()) {
        self.orderService = orderService
        self.productService = productService
    }
    
    public func getOrderList() {
        let filter = FilterAndSort(
            listFields: nil,
            sort: SortData(fieldName: "dateAdded", variantSort: .desc),
            searchData: nil,
            skip: 0,
            take: 100
        )
        isLoading = true
        
        orderService.getOrderList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.orderList = result
            }
            .store(in: &subscriptions)
    }
    
    public func fetchProductsInformation(for order: DHSaleHeadAsOrderViewModel) {
        guard let listDRSale = order.listDRSale else { return }
        
        Publishers.MergeMany(listDRSale.compactMap { saleItem -> AnyPublisher<ProductViewDataModel?, Never>? in
            return productService.getProductByID(idRFNomenclature: saleItem.idrfNomenclature)
                .map(\.data)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        })
        .collect()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] productsViewData in
            let filteredData = productsViewData.compactMap { $0 }
            let productDict = Dictionary(uniqueKeysWithValues: zip(listDRSale.map(\.idrfNomenclature), filteredData))
            self?.productDictionary = productDict
        }
        .store(in: &subscriptions)
    }
}

//
//  OrdersViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import Combine
import Foundation
import ipbswiftapi_v7

/// A view model for managing and fetching order data, including product details.
///
/// `OrdersViewModel` interacts with `OrderService` and `ProductService` to fetch and manage orders and their associated products. It provides functionality to load orders, display them, and retrieve detailed product information associated with each order.
///
/// ## Overview
/// - Fetches and manages a list of orders.
/// - Retrieves product details for items within each order.
/// - Handles loading states and error reporting.
///
/// ## Usage
///
/// The view model is injected as an environment object in the `OrdersView` view.
///
/// ```swift
/// OrdersView()
///     .environmentObject(OrdersViewModel())
/// ```
///
/// Or use it with your UI implementation.
public class OrdersViewModel: ObservableObject {
    
    /// Stores the list of orders fetched from the server.
    @Published public var orderList: ResultDataList<DHSaleHeadAsOrderViewModel>?
    /// Maps product IDs to their models for easier access in the UI.
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
    
    /// Fetches the list of all orders using `OrderService` with sorting by date added and assign them to orderList.
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
    
    /// Fetches detailed product information for each item in an order and updates the `productDictionary`.
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

//
//  CartViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import SwiftUI
import Combine
import ipbswiftapi_v7

/// Manages the cart and order process within the application.
///
/// `CartViewModel` provides a comprehensive interface for interacting with the cart, including adding or removing items, managing delivery information, applying bonuses, and handling payment options. It also integrates with the DaDataService for address suggestions and leverages Combine for reactive updates.
///
/// ## Features
/// - Tracks and updates cart items, including product details and quantities.
/// - Manages delivery address input with real-time suggestions from DaDataService.
/// - Allows for adding comments and custom delivery instructions.
/// - Supports applying available bonuses to the cart and managing payment options.
/// - Coordinates the checkout process across multiple stages, from payment to final confirmation.
///
/// ## Usage
/// Instantiate `CartViewModel` and use it as an environment object in SwiftUI views to access and manage cart data throughout the application flow. The ViewModel handles all interactions with the `CartService` and `ProductService` to fetch product details and cart information, and with `DaDataService` for address suggestions.
///
/// ## Example
/// ```swift
/// @StateObject private var cartViewModel = CartViewModel.shared
///
/// var body: some View {
///     CartView()
///         .environmentObject(cartViewModel)
/// }
/// ```
///
/// ## Observations
/// This ViewModel publishes changes to the cart, including updates to the number of items, the current checkout stage, and any errors or loading states. It ensures the UI remains responsive and up-to-date with the latest cart data and user interactions.

public final class CartViewModel: ObservableObject {
    
    public static let shared = CartViewModel()
    
    @Published public var cartResult: ResultData<DHSaleHeadAsOrderViewModel>? {
        didSet {
            cartItemsCount = cartResult?.data?.listDRSale?.reduce(0, { $0 + $1.quantity }) ?? 0
        }
    }
    @Published public var order: DHSaleHeadAsOrderViewModel?
    @Published public var productDictionary: [String: ProductViewDataModel] = [:]
    @Published public var cartItemsCount: Int = 0
    
    @Published public var paymentOption: PaymentFillView.PaymentOption = .internalPay
    
    public enum CheckoutStage: Int {
        case paymentProvider
        case delivery
        case payment
        case final
    }
    
    /// Current checkout stage. The `paymentProvider` case is a sign to display external payment provider.
    @Published public var checkoutStage: CheckoutStage = .delivery
    
    // Delivery properties
    @Published public var address: String = ""
    @Published public var suggestions: [Suggestion]?
    @Published public var comment: String = ""
    @Published public var isDeliveryButtonDisabled: Bool = true
    
    // Payment properties
    @Published public var availableBonuses: Double = 0
    @Published public var isBonusesApplied: Bool = false {
        didSet {
            if isBonusesApplied {
                addBonuses(availableBonuses)
            } else {
                deleteBonuses()
            }
        }
    }
    
    @Published public var isLoading = false
    
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
    
    private let cartService: CartService
    private let productService: ProductService
    private let daDataService: DaDataService
    
    private init(
        cartService: CartService = CartService(),
        productService: ProductService = ProductService(),
        daDataService: DaDataService = DaDataService()
    ) {
        self.cartService = cartService
        self.productService = productService
        self.daDataService = daDataService
        
        $address
            .map { $0.isEmpty }
            .assign(to: \.isDeliveryButtonDisabled, on: self)
            .store(in: &subscriptions)
        
        setupAddressSubscription()
    }
    
    public func getCart() {
        isLoading = true
        
        Just(())
            .delay(for: .seconds(.random(in: 0.2...0.5)), scheduler: DispatchQueue.main)
            .flatMap { [unowned self] _ in
                self.cartService.getCart()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func getProductByID(idRFNomenclature: String) {
        isLoading = true
        productService.getProductByID(idRFNomenclature: idRFNomenclature)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.productDictionary[idRFNomenclature] = result.data
            }
            .store(in: &subscriptions)
    }
    
    public func addCartItem(idrfNomenclature: String, count: Int) {
        isLoading = true
        cartService.addCartItem(idrfNomenclature: idrfNomenclature, count: count)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func deleteCartItem(idrfNomenclature: String, count: Int) {
        isLoading = true
        cartService.deleteCartItem(idrfNomenclature: idrfNomenclature, count: count)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func addAddress() {
        isLoading = true
        
        cartService.addAddressToCart(addressString: address, idAddress: UUID().uuidString)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func addComment() {
        guard !comment.isEmpty else { return }
        isLoading = true
        
        cartService.addCommentToCart(comment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func addBonuses(_ amount: Double) {
        isLoading = true
        
        cartService.addBonusesToCart(amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func deleteBonuses() {
        cartService.deleteBonusesFromCart()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.cartResult = result
            }
            .store(in: &subscriptions)
    }
    
    public func confirmCart() {
        isLoading = true
        cartService.confirmCart()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.order = result.data
            }
            .store(in: &subscriptions)
    }
}

// MARK: - DaData suggestions
extension CartViewModel {
    private func setupAddressSubscription() {
        isLoading = true
        
        $address
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [weak self] address -> AnyPublisher<Suggestions, NetworkRequestError> in
                return self?.daDataService.getSuggestions(for: address) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] newSuggestions in
                self?.suggestions = newSuggestions.suggestions
            }
            .store(in: &subscriptions)
    }
}

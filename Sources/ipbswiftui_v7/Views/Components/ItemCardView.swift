//
//  ItemCardView.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI

public struct ItemCardView: View {
    
    public struct Details {
        let name: String
        let brandName: String?
        let price: Double
        let originalPrice: Double?
        let sizeDescription: String?
        let colorAsHex: String?
        let imageURL: String
        let isAddToCartShowing: Bool
        let countMonthPayment: Int
        let amountPaymentInMonth: Double
        
        public init(name: String,
                    brandName: String? = nil,
                    price: Double,
                    originalPrice: Double? = nil,
                    sizeDescription: String? = nil,
                    colorAsHex: String? = nil,
                    imageURL: String,
                    isAddToCartShowing: Bool = false,
                    countMonthPayment: Int,
                    amountPaymentInMonth: Double) {
            self.name = name
            self.brandName = brandName
            self.price = price
            self.originalPrice = originalPrice
            self.sizeDescription = sizeDescription
            self.colorAsHex = colorAsHex
            self.imageURL = imageURL
            self.isAddToCartShowing = isAddToCartShowing
            self.countMonthPayment = countMonthPayment
            self.amountPaymentInMonth = amountPaymentInMonth
        }
    }
    
    public struct Actions {
        let onTapAction: () -> Void
        let addItemAction: () -> Void
        let removeItemAction: () -> Void
        let deleteAction: () -> Void
        
        public init(onTapAction: @escaping () -> Void,
                    addItemAction: @escaping () -> Void,
                    removeItemAction: @escaping () -> Void,
                    deleteAction: @escaping () -> Void = {}) {
            self.onTapAction = onTapAction
            self.addItemAction = addItemAction
            self.removeItemAction = removeItemAction
            self.deleteAction = deleteAction
        }
    }
    
    public enum Format {
        case normal
        case inCart
        case inOrder
    }
    
    let details: Details
    let format: Format
    @State var currentItemsAdded: Int
    let actions: Actions
    
    public init(details: Details,
                format: Format,
                currentItemsAdded: Int,
                actions: Actions) {
        self.details = details
        self.format = format
        self.currentItemsAdded = currentItemsAdded
        self.actions = actions
    }
    
    private let itemSize = UIScreen.main.bounds.size.width / 2.39
    
    public var body: some View {
        switch format {
        case .normal: normalItem
        case .inCart: inCartItem
        case .inOrder: inCartItem
        }
    }
}

extension ItemCardView {
    var normalItem: some View {
        VStack(alignment: .leading, spacing: 4) {
            image
            
            VStack(alignment: .leading, spacing: 4) {
                Text(details.name)
                    .font(Style.footnoteRegular)
                    .foregroundColor(Style.textPrimary)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 16,
                        maxHeight: 32,
                        alignment: .topLeading
                    )
                
                if let brandName = details.brandName {
                    Text(brandName)
                        .font(Style.footnoteRegular)
                        .foregroundColor(Style.textTertiary)
                }
                
                originalPrice
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(details.price.asCurrency())
                            .font(Style.subheadlineRegular)
                            .foregroundColor(Style.iconsPrimary2)
                        
                        if details.countMonthPayment != 0 && details.amountPaymentInMonth != 0 {
                            Text("Рассрочка:\n\(details.countMonthPayment) платежей\nпо \(details.amountPaymentInMonth.asCurrency())")
                                .font(Style.footnoteRegular)
                                .foregroundColor(Style.textTertiary)
                            
                        }
                    }
                    
                    Spacer()
                    
                    if details.isAddToCartShowing { button }
                }
            }
        }
        .frame(width: itemSize)
        .animation(.default, value: currentItemsAdded)
    }
    
    var inCartItem: some View {
        HStack(alignment: .top, spacing: 8) {
            image
            
            VStack(alignment: .leading, spacing: 4) {
                Text(details.name)
                    .font(Style.footnoteRegular)
                    .foregroundColor(Style.textPrimary)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 16,
                        maxHeight: 32,
                        alignment: .topLeading
                    )
                
                if let brandName = details.brandName {
                    Text(brandName)
                        .font(Style.footnoteRegular)
                        .foregroundColor(Style.textTertiary)
                }
                
                if let sizeDescription = details.sizeDescription {
                    Text("Размер: \(sizeDescription)")
                        .font(Style.footnoteRegular)
                        .foregroundColor(Style.textSecondary)
                }
                
                if let colorAsHex = details.colorAsHex {
                    HStack {
                        Text("Цвет: ")
                            .font(Style.footnoteRegular)
                            .foregroundColor(Style.textSecondary)
                            .padding(.trailing)
                        
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color(hex: colorAsHex))
                            .overlay {
                                Circle()
                                    .stroke()
                                    .foregroundColor(Style.secondary)
                            }
                    }
                }
                
                if details.countMonthPayment != 0 && details.amountPaymentInMonth != 0 {
                    Text("по \(details.amountPaymentInMonth.asCurrency())\n\(details.countMonthPayment) платежей")
                        .font(Style.subheadlineRegular)
                        .foregroundColor(Style.textPrimary2)
                        .frame(height: 36)
                    Text("(Рассрочка)")
                        .font(Style.subheadlineRegular)
                        .foregroundColor(Style.textTertiary)
                } else {
                    originalPrice
                    
                    Text(details.price.asCurrency())
                        .font(Style.subheadlineRegular)
                        .foregroundColor(Style.iconsPrimary2)
                }
                
                if format != .inOrder {
                    quantityPicker
                }
            }
            
            if format != .inOrder {
                VStack {
                    Button(action: actions.deleteAction) {
                        Image("trashCan", bundle: .module)
                            .foregroundColor(Style.iconsTertiary)
                    }
                    Spacer()
                }
            }
        }
        .animation(.default, value: currentItemsAdded)
    }
    
    var originalPrice: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let originalPrice = details.originalPrice {
                Text(originalPrice.asCurrency())
                    .font(Style.subheadlineRegular)
                    .foregroundColor(Style.textTertiary)
                    .strikethrough()
                Text("Цена для вас:")
                    .font(Style.footnoteRegular)
                    .foregroundColor(Style.textPrimary)
            }
        }
    }
    
    var image: some View {
        AsyncImageView(
            imageURL: details.imageURL,
            width: itemSize,
            height: itemSize,
            cornerRadius: 8
        )
        .onTapGesture(perform: actions.onTapAction)
    }
    
    var button: some View {
        ZStack {
            if currentItemsAdded == 0 {
                Button(action: increaseItemQuantity) {
                    Image("shoppingCart", bundle: .module)
                        .foregroundColor(Style.iconsPrimary)
                }
            } else {
                quantityPicker
            }
        }.frame(height: 28)
    }
    
    var quantityPicker: some View {
        HStack(spacing: 2) {
            Button(action: decreaseItemQuantity) {
                Image(systemName: "minus")
                    .font(.system(size: 10))
                    .frame(width: 24, height: 24)
                    .background(Style.iconsSecondary)
                    .clipShape(Circle())
            }
            
            Text(currentItemsAdded.formatted())
                .frame(width: 28, height: 28)
                .background(Style.iconsSecondary)
                .clipShape(Circle())
            
            Button(action: increaseItemQuantity) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .frame(width: 24, height: 24)
                    .background(Style.iconsSecondary)
                    .clipShape(Circle())
            }
        }
        .foregroundColor(Style.textPrimary)
        .font(Style.footnoteRegular)
    }
    
    private func decreaseItemQuantity() {
        if currentItemsAdded > 0 {
            currentItemsAdded -= 1
            actions.removeItemAction()
        } else {
            currentItemsAdded = 0
        }
    }
    
    private func increaseItemQuantity() {
        currentItemsAdded += 1
        actions.addItemAction()
    }
}



struct ItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        let details = ItemCardView.Details(name: "Chocolate skfnskdnf a fnaklf fsfdsfdsf afn", brandName: "Nike", price: 3000, originalPrice: 4000, sizeDescription: "Big", colorAsHex: "fafaa1", imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", isAddToCartShowing: true, countMonthPayment: 3, amountPaymentInMonth: 500)
        
        let actions = ItemCardView.Actions(
            onTapAction: { print("tapped") },
            addItemAction: { print("added") },
            removeItemAction: { print("removed") },
            deleteAction: { print("deleted") }
        )
        
        ScrollView {
            VStack(spacing: 20) {
                ItemCardView(
                    details: details,
                    format: .normal,
                    currentItemsAdded: 0,
                    actions: actions
                )
                
                ItemCardView(
                    details: details,
                    format: .inCart,
                    currentItemsAdded: 1,
                    actions: actions
                )
            }
            .padding()
            .background(Style.background.ignoresSafeArea())
        }
    }
}

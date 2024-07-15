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
        public let imageBannerURL: String?
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
                    amountPaymentInMonth: Double,
                    imageBannerURL: String? = "") {
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
            self.imageBannerURL = imageBannerURL
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
        case medicinalProduct
        case banner
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
        case .medicinalProduct: medicinalProduct
        case .banner: bannerItem
        }
    }
}

extension ItemCardView {
    
    var medicinalProduct: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack{
                Spacer()
                image
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack{
                    if let originalPrice = details.originalPrice {
                        Text("Кэшбэк \(originalPrice.clean) баллов")
                            .font(Style.captionBold)
                            .foregroundStyle(Style.surface)
                            .padding(7)
                            .lineLimit(1) // Ограничиваем текст одной строкой
                            .truncationMode(.tail) // Добавляем троеточие, если текст не помещается
                            .frame(alignment: .leading)
                    }
                        
                }.frame(width: itemSize*1.1, alignment: .leading)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFF53B8EB),
                                                                               Color(hex: 0xFF27D1AE)]), startPoint: .leading, endPoint: .trailing))
                
                
                Spacer().frame(height: 10)
                Text(details.name)
                    .font(Style.captionBold)
                    .foregroundStyle(Style.textPrimary)
                    .padding([.leading, .trailing], 7)
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .topLeading)
                    .lineLimit(3) // Ограничиваем текст одной строкой
                    .truncationMode(.tail) // Добавляем троеточие, если текст не помещается
                    
                
                
                if let brandName = details.brandName {
                    Text(brandName)
                        .font(Font.caption)
                        .foregroundStyle(Style.textPrimary)
                        .padding([.leading, .trailing], 7)
                        .lineLimit(1) // Ограничиваем текст одной строкой
                        .truncationMode(.tail) // Добавляем троеточие, если текст не помещается
                        .frame(alignment: .leading)
                }
                
                Spacer().frame(height: 10)
                
            }
        }
        .frame(width: itemSize * 1.1)
        .cornerRadius(12) // Радиус закругления углов
        .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Style.textTertiary, lineWidth: 1))
        .animation(.default, value: currentItemsAdded)
    }
    
    
    var bannerItem: some View {
        
            imageBanner
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Style.textTertiary, lineWidth: 1))
    }
    
    var normalItem: some View {
        VStack(alignment: .leading, spacing: 4) {
            image
            
            VStack(alignment: .leading, spacing: 4) {
                Text(details.name)
                    .font(Style.footnoteRegular)
                    .foregroundStyle(Style.textPrimary)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 16,
                        maxHeight: 40,
                        alignment: .topLeading
                    )
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                
                if let brandName = details.brandName {
                    Text(brandName)
                        .font(Style.footnoteRegular)
                        .foregroundStyle(Style.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                
                originalPrice
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(details.price.asCurrency())
                            .font(Style.subheadlineRegular)
                            .foregroundStyle(Style.iconsPrimary2)
                        
                        if details.countMonthPayment != 0 && details.amountPaymentInMonth != 0 {
                            Text("Рассрочка:\n\(details.countMonthPayment) платежей\nпо \(details.amountPaymentInMonth.asCurrency())")
                                .font(Style.footnoteRegular)
                                .foregroundStyle(Style.textTertiary)
                            
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
                    .foregroundStyle(Style.textPrimary)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 16,
                        maxHeight: 40,
                        alignment: .topLeading
                    )
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                if let brandName = details.brandName {
                    Text(brandName)
                        .font(Style.footnoteRegular)
                        .foregroundStyle(Style.textTertiary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                if let sizeDescription = details.sizeDescription {
                    Text("Размер: \(sizeDescription)")
                        .font(Style.footnoteRegular)
                        .foregroundStyle(Style.textSecondary)
                }
                
                if let colorAsHex = details.colorAsHex {
                    HStack {
                        Text("Цвет: ")
                            .font(Style.footnoteRegular)
                            .foregroundStyle(Style.textSecondary)
                            .padding(.trailing)
                        
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color(hex: colorAsHex))
                            .overlay {
                                Circle()
                                    .stroke()
                                    .foregroundStyle(Style.secondary)
                            }
                    }
                }
                
                if details.countMonthPayment != 0 && details.amountPaymentInMonth != 0 {
                    Text("по \(details.amountPaymentInMonth.asCurrency())\n\(details.countMonthPayment) платежей")
                        .font(Style.subheadlineRegular)
                        .foregroundStyle(Style.textPrimary2)
                        .frame(height: 38)
                        .lineLimit(2)
                    Text("(Рассрочка)")
                        .font(Style.subheadlineRegular)
                        .foregroundStyle(Style.textTertiary)
                } else {
                    originalPrice
                    
                    Text(details.price.asCurrency())
                        .font(Style.subheadlineRegular)
                        .foregroundStyle(Style.iconsPrimary2)
                }
                
                if format != .inOrder {
                    QuantityPicker(
                        currentQuantity: $currentItemsAdded,
                        decreaseAction: actions.removeItemAction,
                        increaseAction: actions.addItemAction
                    )
                }
            }
            
            if format != .inOrder {
                VStack {
                    Button(action: actions.deleteAction) {
                        Image("trashCan", bundle: .module)
                            .foregroundStyle(Style.iconsTertiary)
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
                    .foregroundStyle(Style.textTertiary)
                    .strikethrough()
                Text("Цена для вас:")
                    .font(Style.footnoteRegular)
                    .foregroundStyle(Style.textPrimary)
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
    
    var imageBanner: some View {
        AsyncImageBannerView(
            imageURL: details.imageBannerURL ?? "",
                    width: UIScreen.main.bounds.size.width,
                    height: itemSize,
                    cornerRadius: 8
                )
        
        .onTapGesture(perform: actions.onTapAction)
    }
    
    var button: some View {
        ZStack {
            if currentItemsAdded == 0 {
                Button(action: actions.addItemAction) {
                    Image("shoppingCart", bundle: .module)
                        .foregroundStyle(Style.iconsPrimary)
                }
            } else {
                QuantityPicker(
                    currentQuantity: $currentItemsAdded,
                    decreaseAction: actions.removeItemAction,
                    increaseAction: actions.addItemAction
                )
            }
        }.frame(height: 28)
    }
}



struct ItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        let details = ItemCardView.Details(name: "Chocolate skfnskdnf a fnaklf fsfdsfdsf afn", brandName: "Nike", price: 3000, originalPrice: 4000, sizeDescription: "Big", colorAsHex: "fafaa1", imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", isAddToCartShowing: true, countMonthPayment: 3, amountPaymentInMonth: 500)
        
        let detailsBanner = ItemCardView.Details(name: "Chocolate skfnskdnf a fnaklf fsfdsfdsf afn", brandName: "Nike", price: 3000, originalPrice: 4000, sizeDescription: "Big", colorAsHex: "fafaa1", imageURL: "https://ipb.website.yandexcloud.net/mediadata/08dc90ff-4ff9-4a44-8f91-4ffbf77bb8da_20240625220907524", isAddToCartShowing: true, countMonthPayment: 3, amountPaymentInMonth: 500,
                                                 imageBannerURL: "https://ipb.website.yandexcloud.net/mediadata/08dc90ff-4ff9-4a44-8f91-4ffbf77bb8da_20240625220907524")
    
        
        let actions = ItemCardView.Actions(
            onTapAction: { print("tapped") },
            addItemAction: { print("added") },
            removeItemAction: { print("removed") },
            deleteAction: { print("deleted") }
        )
        
        ScrollView {
            VStack(spacing: 20) {
                
                ItemCardView(
                    details: detailsBanner,
                    format: .banner,
                    currentItemsAdded: 0,
                    actions: actions
                )
                
                ItemCardView(
                    details: details,
                    format: .medicinalProduct,
                    currentItemsAdded: 0,
                    actions: actions
                )
                
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

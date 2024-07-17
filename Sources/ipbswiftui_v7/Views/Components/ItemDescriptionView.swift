//
//  ItemDescriptionView.swift
//  
//
//  Created by Artemy Volkov on 24.07.2023.
//

import SwiftUI

public struct ItemDescriptionView: View {
    enum Option: DisplayOptionProtocol {
        case description
        case parameters
        case delivery
        
        var rawValue: String {
            switch self {
            case .description: return "Описание"
            case .parameters: return "Параметры"
            case .delivery: return "Доставка"
            }
        }
    }
    
    public enum DeliveryOption {
        case box
        case express
        case onEmail
    }
    
    @Namespace private var animation
    @State private var option: Option = .description
    @State private var isDescriptionFolding: Bool = true
    @State private var isFavourite: Bool = false
    
    let descriptionTitle: String
    let description: String
    let favoriteAction: () -> ()
    let shareItem: String
    let parameters: [(String, String)]
    let deliveryOptions: [DeliveryOption]
    
    var idrfSpecification: String = ""
    var brandName: String = ""
    
    public init(
        descriptionTitle: String,
        description: String,
        favoriteAction: @escaping () -> (),
        shareItem: String,
        parameters: [(String, String)],
        deliveryOptions: [DeliveryOption] = [.box, .express, .onEmail],
        idrfSpecification: String,
        brandName: String
        
    ) {
        self.descriptionTitle = descriptionTitle
        self.description = description
        self.favoriteAction = favoriteAction
        self.shareItem = shareItem
        self.parameters = parameters
        self.deliveryOptions = deliveryOptions
        self.idrfSpecification = idrfSpecification
        self.brandName = brandName
    }
    
    public var body: some View {
        VStack {
            if idrfSpecification != Style.idrfSpecificatiuonForMedicialProduct {
                OptionPickerView(value: $option, options: [.description, .parameters, .delivery])
            }
            else
            {
                OptionPickerView(value: $option, options: [.description])
            }
            
            
            switch option {
            case .description:
                descriptionView
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .trailing),
                            removal: .push(from: .leading)
                        )
                        .combined(with: .opacity)
                    )
            case .parameters:
                parametersView
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .leading),
                            removal: .push(from: .trailing)
                        )
                        .combined(with: .opacity)
                    )
            case .delivery:
                deliveryView
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .leading),
                            removal: .push(from: .trailing)
                        )
                        .combined(with: .opacity)
                    )
            }
        }
        .animation(.default, value: option)
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(descriptionTitle)
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
                
                Spacer()
                
                
                
                HStack(spacing: 10) {
                    Button(action: {
                        favoriteAction()
                        isFavourite.toggle()
                    }) {
                        Image(isFavourite ? "favoriteIconFilled" : "favoriteIcon", bundle: .module)
                            .foregroundStyle(isFavourite
                                ? Style.primary
                                : LinearGradient(colors: [Style.iconsTertiary], startPoint: .center, endPoint: .center)
                            )
                    }
                    ShareLink(item: shareItem) {
                        Image("shareIcon", bundle: .module)
                    }
                }
                .foregroundStyle(Style.iconsTertiary)
            }
            
            if  brandName != "" {
                Spacer().frame(height: 7)
                Text(brandName)
                    .font(Font.caption)
                    .foregroundStyle(Style.textPrimary)
                    .lineLimit(1) // Ограничиваем текст одной строкой
                    .truncationMode(.tail) // Добавляем троеточие, если текст не помещается
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            Text(description)
                .padding(.top, 12)
                .font(Style.subheadlineRegular)
                .foregroundStyle(Style.textSecondary)
                .lineLimit(isDescriptionFolding ? 5 : nil)
            
            Button(isDescriptionFolding ? "Развернуть" : "Свернуть") {
                withAnimation { isDescriptionFolding.toggle() }
            }
            .font(Style.subheadlineRegular)
            .foregroundStyle(Style.onBackground)
            .padding(.top, 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Style.surface)
        .cornerRadius(12)
    }
    
    var parametersView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Параметры")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<parameters.count, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text(parameters[index].0)
                            .font(Style.subheadlineRegular)
                            .foregroundStyle(Style.textSecondary)
                            .frame(width: 108, alignment: .leading)
                        
                        Text(parameters[index].1)
                            .font(Style.subheadlineRegular)
                            .foregroundStyle(Style.textPrimary)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Style.surface)
        .cornerRadius(12)
    }
    
    var deliveryView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Доставка")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
                Spacer()
            }
            
            if deliveryOptions.contains(.box) {
                VStack(spacing: 0) {
                    Image("deliveryBoxIcon", bundle: .module)
                        .foregroundStyle( Style.primary)
                    Text("Доставка до постамата \n или пункта выдачи")
                        .multilineTextAlignment(.center)
                        .font(Style.body)
                        .foregroundStyle(Style.textPrimary)
                }
            }
            
            if deliveryOptions.contains(.express) {
                VStack(spacing: 0) {
                    Image("expressDeliveryIcon", bundle: .module)
                        .foregroundStyle( Style.primary)
                        
                    
                    Text("Курьерская доставка")
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                        .font(Style.body)
                        .foregroundStyle(Style.textPrimary)
                }
            }
            
            if deliveryOptions.contains(.onEmail) {
                VStack(spacing: 0) {
                    Image("email-mail-sent-icon", bundle: .module)
                        .foregroundStyle( Style.primary)
                        
                    
                    Text("Доствка на электронную почту")
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                        .font(Style.body)
                        .foregroundStyle(Style.textPrimary)
                }
            }
            
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Style.surface)
        .cornerRadius(12)
    }
}

struct ItemDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                ItemDescriptionView(
                    descriptionTitle: "Sneakers Rare Limited Edition Limited Edition",
                    description: "Air force культовая модель на все случаи жизни. Гарантируем что вы получите наилучшее оригинальное качество. Преимущества данной модели : натуральная кожа, оригинальная подошва, правильная форма, абсолютное соответствие всех материалов и дизайна с оригинальной моделью, правильная геометрия и колодка, очень удобные, размер соответствует оригиналу ,те кто носит кроссовки легко подберет свой размер. Таблицу размеров представим ниже. Уважаемые покупатели будьте уверены что вы платите за товар премиального качества и будете носить кроссовки долго и с комфортом.",
                    favoriteAction: {},
                    shareItem: "Share",
                    parameters: [
                        ("Цвет", "Красный"),
                        ("Цвет", "Белый"),
                        ("Размеры", "XXS / XS / S / M / L / XL / XXL / XXXL"),
                        ("Страна", "США")
                    ],
                    idrfSpecification: "",
                    brandName: "Производитель данной модели : натуральная кожа, оригинальная подошва, правильная форма,"
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

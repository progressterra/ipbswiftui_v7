//
//  OptionPickerView.swift
//  
//
//  Created by Artemy Volkov on 16.08.2023.
//

import SwiftUI

/// A customizable option picker view for SwiftUI that allows for selection among a set of options.
///
/// This view displays options provided as an array of enum values conforming to `DisplayOptionProtocol`. It allows for the visual selection of these options by tapping. The options are displayed horizontally, with the currently selected option highlighted.
///
/// ## Protocol
/// The options provided to this picker must conform to the `DisplayOptionProtocol`, which requires a `rawValue` of type `String`. This `rawValue` is used to display the options in the view.
///
/// ## Usage
///
/// To use `OptionPickerView`, define an enum conforming to `DisplayOptionProtocol` and initialize the view with a binding to a property of the enum type and an array of all possible options.
///
/// ```swift
/// enum Option: DisplayOptionProtocol {
///     case one, two, three, four
///
///     var rawValue: String {
///         switch self {
///         case .one:
///             return "One"
///         case .two:
///             return "Two"
///         case .three:
///             return "Three"
///         case .four:
///             return "Four"
///         }
///     }
/// }
///
/// struct ContentView: View {
///     @State private var selectedOption: Option = .one
///
///     var body: some View {
///         OptionPickerView(value: $selectedOption, options: Option.allCases)
///     }
/// }
/// ```
///
/// ## Recommendation
///
/// For optimal usability, especially on smaller screens, it is recommended to limit the number of options to four or fewer to ensure that option labels do not overlap or become too compressed.
///
/// ## Parameters
/// - `value`: A binding to the currently selected option of type `T`.
/// - `options`: An array of all possible options the user can choose from.
public struct OptionPickerView<T: DisplayOptionProtocol>: View {
    @Binding var value: T
    let options: [T]
    
    @Namespace private var animation
    
    public init(value: Binding<T>, options: [T]) {
        self._value = value
        self.options = options
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                ZStack {
                    if value == option {
                        Style.background
                            .cornerRadius(8)
                            .matchedGeometryEffect(id: "PickerBackground", in: animation)
                    }
                    Text(option.rawValue)
                        .padding(12)
                        .opacity(value == option ? 0 : 1)
                        .foregroundStyle(Style.textSecondary)
                        .overlay(
                            Text(option.rawValue)
                                .bold()
                                .opacity(value == option ? 1 : 0)
                                .foregroundStyle(Style.textPressed)
                        )
                        .frame(maxWidth: .infinity)
                        .onTapGesture { value = option }
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(Style.surface)
        .cornerRadius(12)
        .font(Style.subheadlineRegular)
        .animation(.easeInOut, value: value)
    }
}

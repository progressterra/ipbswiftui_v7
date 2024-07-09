//
//  ApplicationRequestView.swift
//
//
//  Created by Artemy Volkov on 13.03.2024.
//

import SwiftUI

/// A view for submitting application requests.
///
/// `ApplicationRequestView` is designed to capture user input for a new application request, including personal details and preferred communication channels. This view utilizes environment objects for application and profile view models to pre-populate fields and manage submission logic.
///
/// ## Overview
/// This view presents a form where users can enter their name, surname, phone number, email, and optionally, their Telegram contact or a custom communication channel. It validates the input to ensure essential details are provided before allowing the user to submit the application request.
///
/// Upon submission, the view displays a status message indicating whether the application was successfully created.
///
/// ## Usage
///
/// To use `ApplicationRequestView`, ensure you have `ApplicationViewModel` and `ProfileViewModel` instantiated and injected as environment objects into the SwiftUI environment. `idProduct` is required to associate the application request with a specific product.
///
/// ```swift
/// @StateObject private var applicationViewModel = ApplicationViewModel()
/// @StateObject private var profileViewModel = ProfileViewModel()
///
/// var body: some View {
///     ApplicationRequestView(idProduct: "123")
///         .environmentObject(applicationViewModel)
///         .environmentObject(profileViewModel)
/// }
/// ```
///
/// ## Environment Objects
/// - ``ApplicationViewModel``: Manages the application request logic submission.
/// - ``ProfileViewModel``: Supplies user profile information to pre-populate the form.
///
/// ## Parameters
/// - `idProduct`: A string identifier for the product related to the application request.
public struct ApplicationRequestView: View {
    
    let idProduct: String
    
    @EnvironmentObject var vm: ApplicationViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var displayedPhoneNumber = ""
    @State private var isCustomChannelOptionPresented = false
    @State private var applicationRequestStatus: String?
    @FocusState private var focusedField: Int?
    
    public init(idProduct: String) {
        self.idProduct = idProduct
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    CustomTextFieldView(text: $vm.message, prompt: "Комментарий", axis: .vertical)
                        .focused($focusedField, equals: 0)
                    
                    CustomTextFieldView(text: $vm.clientName, prompt: "Имя")
                        .focused($focusedField, equals: 1)
                        .onSubmit { focusedField = 2 }
                        .submitLabel(.next)

                    CustomTextFieldView(text: $vm.clientSurname, prompt: "Фамилия")
                        .focused($focusedField, equals: 2)
                        .onSubmit { focusedField = 3 }
                        .submitLabel(.next)
                    
                    CustomTextFieldView(text: $displayedPhoneNumber, prompt: "Номер телефона")
                        .modifier(PhoneNumberFormatterModifier(phoneNumber: $vm.phoneNumber, displayedPhoneNumber: $displayedPhoneNumber))
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: 3)
                    
                    CustomTextFieldView(text: $vm.email, prompt: "Email")
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: 4)
                        .onSubmit { focusedField = 5 }
                        .submitLabel(.next)
                    
                    CustomTextFieldView(text: $vm.idTelegram, prompt: "Telegram")
                        .focused($focusedField, equals: 5)
                        .onSubmit { focusedField = nil }
                        .submitLabel(.done)
                    
                    Button(action: { isCustomChannelOptionPresented.toggle() }) {
                        HStack(spacing: 6) {
                            Text("Указать свой способ связи")
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(isCustomChannelOptionPresented ? 90 : 0))
                        }
                        .font(Style.captionBold)
                        .foregroundStyle(Style.iconsTertiary)
                        .padding(8)
                    }
                    
                    if isCustomChannelOptionPresented {
                        CustomTextFieldView(text: $vm.nameOfChannel, prompt: "Название")
                            .focused($focusedField, equals: 0)
                            .onSubmit { focusedField = 1 }
                            .submitLabel(.next)
                        
                        if !vm.nameOfChannel.isEmpty {
                            CustomTextFieldView(text: $vm.idChannel, prompt: "Контакт " + vm.nameOfChannel)
                                .focused($focusedField, equals: 1)
                                .onSubmit { focusedField = nil }
                                .submitLabel(.done)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                CustomButtonView(
                    title: "Отправить",
                    isDisabled: .constant(vm.clientName.isEmpty || vm.phoneNumber.isEmpty || vm.idProduct.isEmpty),
                    action: vm.createApplication
                )
                .padding()
            }
            .onReceive(vm.$model.dropFirst()) { _ in
                applicationRequestStatus = "Заявка успешно сформирована.\nВ ближайшее время с Вами свяжется менеджер."
            }
            .overlay {
                StatusAlertView(status: $applicationRequestStatus) {
                    dismiss()
                }
            }
            .animation(.default, value: vm.nameOfChannel)
            .animation(.default, value: isCustomChannelOptionPresented)
            .background(Style.background)
            .onTapGesture(perform: hideKeyboard)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена", role: .cancel) { dismiss () }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: {
                        if let currentFocus = focusedField, currentFocus > 0 {
                            focusedField = currentFocus - 1
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField == 0)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: {
                        if let currentFocus = focusedField, currentFocus < 5 {
                            focusedField = currentFocus + 1
                        } else if focusedField == 5 {
                            focusedField = nil
                        }
                    }) {
                        Image(systemName: focusedField == 5 ? "keyboard.chevron.compact.down.fill" : "chevron.down")
                    }
                }
            }
            .onAppear {
                vm.idProduct = idProduct
                vm.clientName = profileVM.name
                vm.clientSurname = profileVM.surname
                vm.phoneNumber = profileVM.phoneNumber
                vm.email = profileVM.email
            }
        }
    }
}

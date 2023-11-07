//
//  ProfileDetailView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 22.08.2023.
//

import SwiftUI
import PhotosUI

public struct ProfileDetailView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    
    public enum Mode {
        case view
        case edit
        case register
        case birthdayAndSex
    }
    
    @Binding var mode: Mode
    let submitAction: () -> ()
    let skipAction: (() -> ())?
    
    @State private var displayingBirthday: String = ""
    @State private var displayingPhoneNumber: String = ""
    @State private var isDatePickerPresented: Bool = false
    @State private var isTypeSexPickerPresented: Bool = false
    @FocusState private var focusedField: Int?
    
    private let maleStr = "Мужской"
    private let femaleStr = "Женский"
    
    private var startDate: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }
    
    private let endDate = Date()
    
    private var isInEditMode: Bool {
        mode != .view
    }
    
    private var buttonTitle: String {
        switch mode {
        case .view: return "Изменить данные"
        case .edit: return "Готово"
        default: return "Далее"
        }
    }
    
    private var navigationTitle: String {
        switch mode {
        case .view: return "Профиль"
        case .edit: return "Изменить данные"
        case .register: return "Регистрация"
        case .birthdayAndSex: return "Личные данные"
        }
    }
    
    public init(mode: Binding<Mode>, submitAction: @escaping () -> (), skipAction: (() -> ())? = nil) {
        self._mode = mode
        self.submitAction = submitAction
        self.skipAction = skipAction
    }
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 8) {
                    if !isInEditMode {
                        PhotosPicker(selection: $vm.selectedPhoto, matching: .images, photoLibrary: .shared()) {
                            HStack(spacing: 0) {
                                if let profileImageURL = vm.profileImageURL {
                                    AsyncImageView(
                                        imageURL: profileImageURL,
                                        width: 80,
                                        height: 80,
                                        cornerRadius: 40
                                    )
                                    .padding(.trailing, 20)
                                } else {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .padding(.trailing, 20)
                                }
                                
                                HStack(spacing: 4) {
                                    Text("Сменить аватар")
                                    Image("pencilIcon", bundle: .module)
                                }
                                .foregroundColor(Style.textTertiary)
                                .font(Style.subheadlineBold)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .background(Style.surface)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    VStack(spacing: 12) {
                        if mode != .birthdayAndSex {
                            Group {
                                CustomTextFieldView(text: $vm.name, prompt: "Имя", backgroundColor: Style.background)
                                    .focused($focusedField, equals: 0)
                                    .onSubmit { focusedField = 1 }
                                    .submitLabel(.next)
                                CustomTextFieldView(text: $vm.surname, prompt: "Фамилия", backgroundColor: Style.background)
                                    .focused($focusedField, equals: 1)
                                    .onSubmit { focusedField = 2 }
                                    .submitLabel(.next)
                                CustomTextFieldView(text: $vm.patronymic, prompt: "Отчество", backgroundColor: Style.background)
                                    .focused($focusedField, equals: 2)
                                    .onSubmit {
                                        focusedField = nil
                                        isDatePickerPresented.toggle()
                                    }
                                    .submitLabel(.next)
                            }
                            .disabled(!isInEditMode)
                        }
                        
                        Button(action: {
                            if isInEditMode {
                                hideKeyboard()
                                isDatePickerPresented.toggle()
                            }
                        }) {
                            CustomTextFieldView(text: $displayingBirthday, prompt: "Дата рождения", backgroundColor: Style.background)
                                .onAppear {
                                    displayingBirthday = vm.birthday.format(as: "dd.MM.yyyy")
                                }
                                .animation(.default, value: displayingBirthday)
                                .onReceive(vm.$birthday) {
                                    displayingBirthday = $0.format(as: "dd.MM.yyyy")
                                }
                                .disabled(true)
                                .multilineTextAlignment(.leading)
                                .overlay(alignment: .trailing) {
                                    if isInEditMode {
                                        Image("calendarIcon", bundle: .module)
                                            .gradientColor(gradient:
                                                            isDatePickerPresented
                                                           ? Style.primary
                                                           : LinearGradient(colors: [Style.textDisabled], startPoint: .center, endPoint: .center)
                                            )
                                            .padding(.trailing, 8)
                                            .transition(.opacity)
                                    }
                                }
                                .overlay {
                                    if isDatePickerPresented {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Style.primary)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        
                        if isDatePickerPresented {
                            DatePicker("", selection: $vm.birthday, in: startDate...endDate, displayedComponents: .date)
                                .background(Style.background)
                                .datePickerStyle(.wheel)
                                .tint(Style.onBackground)
                                .cornerRadius(8)
                                .onChange(of: vm.birthday) { displayingBirthday = $0.format(as: "dd.MM.yyyy") }
                                .transition(.scale.combined(with: .push(from: .top)).combined(with: .opacity))
                        }
                        
                        ZStack(alignment: .top) {
                            if isTypeSexPickerPresented {
                                HStack {
                                    VStack(spacing: 12) {
                                        Text(maleStr)
                                            .onTapGesture {
                                                withAnimation {
                                                    vm.typeSex = .male
                                                    vm.typeSexStr = maleStr
                                                }
                                            }
                                        Text(femaleStr)
                                            .onTapGesture {
                                                withAnimation {
                                                    vm.typeSex = .female
                                                    vm.typeSexStr = femaleStr
                                                }
                                            }
                                        
                                    }
                                    .padding(.leading, 11)
                                    .padding(.top, 64)
                                    .padding(.bottom, 8)
                                    
                                    Spacer()
                                }
                                .background(Style.surface)
                                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 4)
                            }
                            
                            Button(action: {
                                if isInEditMode {
                                    isTypeSexPickerPresented.toggle()
                                }
                            }) {
                                CustomTextFieldView(
                                    text: $vm.typeSexStr,
                                    prompt: "Пол",
                                    backgroundColor: Style.background
                                )
                                .disabled(true)
                                .multilineTextAlignment(.leading)
                                .overlay(alignment: .trailing) {
                                    if isInEditMode {
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(Style.iconsTertiary)
                                            .rotationEffect(.degrees(isTypeSexPickerPresented ? 180 : 0))
                                            .padding(.trailing, 8)
                                    }
                                }
                                .overlay {
                                    if isTypeSexPickerPresented {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Style.primary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if !isInEditMode {
                            CustomTextFieldView(text: $displayingPhoneNumber, prompt: "Номер телефона", backgroundColor: Style.background)
                                .modifier(PhoneNumberFormatterModifier(phoneNumber: $vm.phoneNumber, displayedPhoneNumber: $displayingPhoneNumber))
                                .onChange(of: vm.phoneNumber) { displayingPhoneNumber = $0 }
                                .disabled(true)
                                .transition(.scale.combined(with: .push(from: .top)).combined(with: .opacity))
                        }
                        
                        // TODO: -                CustomTextFieldView(text: $vm.email, prompt: "E-mail", backgroundColor: Style.background)
                    }
                    .padding(12)
                    .background(Style.surface)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .animation(.default, value: isDatePickerPresented)
                    .animation(.default, value: isTypeSexPickerPresented)
                    .autocorrectionDisabled()
                }
            }
            .safeAreaPadding(value: 130)
            .refreshable { vm.setUpView() }
            .onAppear(perform: vm.setUpView)
            .onTapGesture(perform: hideKeyboard)
            .overlay(alignment: .bottom) {
                if focusedField == nil {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            CustomButtonView(
                                title: buttonTitle,
                                isDisabled: .constant(
                                    mode == .birthdayAndSex
                                    ? vm.typeSexStr.isEmpty || displayingBirthday.isEmpty
                                    : false
                                )
                            ) {
                                submitAction()
                                isDatePickerPresented = false
                                isTypeSexPickerPresented = false
                            }
                            
                            if let skipAction {
                                Button(action: skipAction) {
                                    Text("Пока пропустить")
                                        .foregroundColor(Style.textDisabled)
                                        .font(Style.body)
                                        .bold()
                                        .padding(.vertical, 15)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .safeAreaPadding(value: mode == .register || mode == .birthdayAndSex ? 0 : 65)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(Style.title)
                    .foregroundColor(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
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
                    if let currentFocus = focusedField, currentFocus < 2 {
                        focusedField = currentFocus + 1
                    } else if focusedField == 2 {
                        focusedField = nil
                    }
                }) {
                    Image(systemName: focusedField == 2 ? "keyboard.chevron.compact.down.fill" : "chevron.down")
                }
            }
        }
        .animation(.default, value: mode)
    }
}

struct ProfileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDetailView(mode: .constant(.birthdayAndSex), submitAction: {}, skipAction: {})
            .environmentObject(ProfileViewModel())
    }
}

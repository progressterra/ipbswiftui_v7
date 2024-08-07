//
//  WantThisDetailView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// Displays detailed view for a specific "Хочу это" request, allowing users to interact and modify request data if necessary.
///
/// This view provides detailed information about a particular product request, including the ability to chat about the request, update request details, and add or update an associated image. The view adapts based on the status of the request, allowing edits only if the request is pending review or requires additional images.
///
/// ## Functionality:
/// - **Editable Fields**: Users can edit the product request details if the request status allows.
/// - **Chat Integration**: Includes a button to initiate a chat related to the request using `MessengerViewModel`.
/// - **Image Handling**: Users can add or change an image associated with the request. If an image is present, it shows up with an option to remove it.
/// - **Status Updates**: Displays the current status of the request and updates it according to the changes made.
///
/// ## Usage:
/// This view is intended to be used when a user selects a specific request from a list of requests (`WantThisRequestsView`). Ensure that `WantThisViewModel` and `MessengerViewModel` are properly injected into the environment.
///
/// ```swift
/// WantThisDetailView(document: documentExample, fields: fieldsExample)
///     .environmentObject(WantThisViewModel())
///     .environmentObject(MessengerViewModel.shared)
/// ```
///
/// ## Important Components:
/// - **Chat Button**: Opens a compact chat view related to the request.
/// - **Completion Button**: Available only if the request can be edited; it allows users to finalize changes.
///
public struct WantThisDetailView: View {
    @EnvironmentObject var vm: WantThisViewModel
    @EnvironmentObject var supportServiceVM: MessengerViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: Field?
    @State private var isChatPresented: Bool = false
    
    var canEdit: Bool {
        document.statusDoc == .waitReview || document.statusDoc == .waitImage
    }
    
    enum Field {
        case itemURL
        case itemName
    }
    
    let document: RFCharacteristicValueViewModel
    let fields: [FieldData]
    
    public init(document: RFCharacteristicValueViewModel, fields: [FieldData]) {
        self.document = document
        self.fields = fields
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Запрос от " + document.dateAdded.convertDateFormat(to: "d MMMM"))
                            .font(Style.title)
                            .foregroundStyle(Style.textPrimary)
                        displayDocStatus(document.statusDoc ?? .notFill)
                            .font(Style.subheadlineBold)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        supportServiceVM.fetchOrCreateDialog(
                            for: .iwantit,
                            with: "Запрос от " + document.dateAdded.convertDateFormat(to: "d MMMM"),
                            reasonID: document.idUnique
                        )
                        isChatPresented = true
                    }) {
                        VStack(spacing: 2) {
                            Image("chatIcon", bundle: .module)
                                .foregroundStyle(Style.iconsTertiary)
                            Text("Чат по запросу")
                                .foregroundStyle(Style.textTertiary)
                                .font(Style.footnoteRegular)
                        }
                    }
                }
                
                if let fieldsData = vm.fieldsData {
                    CustomTextFieldView(text: $vm.itemName, prompt: fieldsData.first?.comment ?? "")
                        .focused($focusedField, equals: .itemName)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .itemURL }
                        .autocorrectionDisabled()
                    
                    CustomTextFieldView(text: $vm.itemURL, prompt: fieldsData.last?.comment ?? "")
                        .focused($focusedField, equals: .itemURL)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
                
                HStack(spacing: 12) {
                    Text("Добавить фото")
                        .foregroundStyle(Style.textPrimary)
                        .font(Style.body)
                    CameraButtonView(inputImage: $vm.itemImage)
                    Spacer()
                }
                
                HStack {
                    if let itemImage = vm.itemImage {
                        Image(uiImage: itemImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 157, height: 157)
                            .cornerRadius(8)
                            .overlay(alignment: .topTrailing) {
                                Button(action: { vm.itemImage = nil }) {
                                    Image("xmark", bundle: .module)
                                        .foregroundStyle(Style.error)
                                        .font(.title)
                                }
                                .padding(8)
                            }
                    } else if let itemImageURL = vm.itemImageURL {
                        AsyncImageView(
                            imageURL: itemImageURL,
                            width: 157,
                            height: 157,
                            cornerRadius: 8
                        )
                        .overlay(alignment: .topTrailing) {
                            Button(action: {
                                vm.itemImage = nil
                                vm.itemImageURL = nil
                            }) {
                                Image("xmark", bundle: .module)
                                    .foregroundStyle(Style.error)
                                    .font(.title)
                            }
                            .padding(8)
                        }
                    }
                    
                    Spacer().frame(height: 157)
                }
                .animation(.default, value: vm.itemImage)
                
                CompactChatView(isPresented: $isChatPresented)
            }
            .padding(.horizontal)
            .padding(.top)
            .disabled(!canEdit)
        }
        .safeAreaInset(edge: .bottom) {
            if canEdit {
                CustomButtonView(title: "Готово", isDisabled: $vm.isSubmitButtonDisabled) {
                    vm.editDocument()
                }
                .padding(8)
                .background(
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Style.surface)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .edgesIgnoringSafeArea(.bottom)
                )
                .padding(.horizontal, 8)
            }
        }
        .background(Style.background)
        .overlay { StatusAlertView(status: $vm.status) { dismiss() } }
        .onTapGesture { focusedField = nil }
        .onDisappear(perform: vm.eraseDocumentData)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: isChatPresented)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Запрос Хочу это")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
    }
    
    private func displayDocStatus(_ statusDoc: TypeStatusDoc) -> some View {
        switch statusDoc {
        case .confirmed:
            return Text("Запрос подтвержден")
                .foregroundStyle(Style.onBackground)
        case .waitReview, .waitImage:
            return Text("Ожидает подтверждения")
                .foregroundStyle(Style.textTertiary)
        case .rejected:
            return Text("Запрос отклонен")
                .foregroundStyle(Style.textPrimary2)
        case .notFill:
            return Text("Документ не заполнен")
                .foregroundStyle(Style.textPrimary2)
        }
    }
}

//
//  WantThisRequestsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 02.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// Displays a grid view of product requests ("Хочу это") submitted by user. Each grid item represents a product request, showing an image, name, and status.
///
/// This view fetches and displays a list of all product requests made by user from the `WantThisViewModel`. User can tap on any request to view detailed information about that request in `WantThisDetailView`. The view is capable of refreshing the list of requests and provides visual feedback on the status of each request, such as confirmed, pending review, or rejected.
///
/// ## Usage:
/// Ensure that `WantThisViewModel` is properly injected into the environment before using this view.
///
/// ```swift
/// WantThisRequestsView()
///     .environmentObject(WantThisViewModel())
/// ```
///
/// ## Navigation:
/// - Navigates to `WantThisDetailView` when a request is tapped to show more detailed information about the request.
///
public struct WantThisRequestsView: View {
    @EnvironmentObject var vm: WantThisViewModel
    
    @State private var isWantThisDetailPresented: Bool = false
    @State private var currentFields: [FieldData] = []
    @State private var currentDocument: RFCharacteristicValueViewModel?
    
    let size = UIScreen.main.bounds.width / 2.39
    
    public init() {}
    
    
    func getValueData(forName name: String, from fieldDataList: [FieldData]) -> String {
        for fieldData in fieldDataList {
            if fieldData.name == name {
                return fieldData.valueData ?? ""
            }
        }
        return ""
    }
    
    public var body: some View {
        ScrollView {
            if let documentList = vm.documentList?.dataList {
                //LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(documentList, id: \.idUnique) { document in
                        if let fieldsData = document.viewData?.data(using: .utf8),
                           let fields = try? JSONDecoder().decode([FieldData].self, from: (fieldsData)) {
                            VStack(alignment: .leading, spacing: 4) {
                                ZStack {
                                    
                                    Image("cashCheck", bundle: .module)
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: size, height: size)
                                                                                .cornerRadius(8)
//                                    if let imageURL = document.listImages?.sorted(by: { $0.dateAdded > $1.dateAdded }).first?.urlData {
//                                        AsyncImageView(
//                                            imageURL: imageURL,
//                                            width: size,
//                                            height: size,
//                                            cornerRadius: 8
//                                        )
//                                    } else {
//                                        Image(systemName: "photo")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: size, height: size)
//                                            .cornerRadius(8)
//                                    }
                                }
                                
                                Text(getValueData(forName: "date_doc", from: fields))
                                    .font(Style.footnoteRegular)
                                    .foregroundStyle(Style.textPrimary)
                                
                                
                                Text(getValueData(forName: "sum_doc", from: fields))
                                    .font(Style.footnoteRegular)
                                    .foregroundStyle(Style.textPrimary)
                                
                                
//                                if let name = fields.first?.valueData {
//                                    Text(name)
//                                        .font(Style.footnoteRegular)
//                                        .foregroundStyle(Style.textPrimary)
//                                }
                                if let statusDoc = document.statusDoc {
                                    displayDocStatus(statusDoc)
                                        .font(Style.footnoteBold)
                                }
                                Spacer()
                            }
                            //.frame(width: size)
                            .onTapGesture {
                                isWantThisDetailPresented = true
                                currentDocument = document
                                currentFields = fields
                                vm.currentDocumentID = document.idUnique
                                vm.itemName = fields.first?.valueData ?? ""
                                vm.itemURL = fields.last?.valueData ?? ""
                                if let imageURL = document.listImages?.sorted(by: { $0.dateAdded > $1.dateAdded }).first?.urlData {
                                    vm.itemImageURL = imageURL
                                }
                            }
                        }
                    }
                //}
                .padding(.horizontal)
                .padding(.top)
            } else {
                ProgressView()
            }
        }
        .animation(.default, value: vm.documentList?.result.xRequestID)
        .frame(maxWidth: .infinity)
        .background(Style.background)
        .onAppear { vm.fetchDocumentList() }
        .refreshable { vm.fetchDocumentList() }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Запросы Хочу это")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .navigationDestination(isPresented: $isWantThisDetailPresented) {
            if let currentDocument {
                WantThisDetailView(document: currentDocument, fields: currentFields)
                    .toolbarRole(.editor)
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

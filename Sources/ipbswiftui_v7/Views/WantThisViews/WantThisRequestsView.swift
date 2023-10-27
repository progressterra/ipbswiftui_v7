//
//  WantThisRequestsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 02.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct WantThisRequestsView: View {
    @EnvironmentObject var vm: WantThisViewModel
    
    @State private var isWantThisDetailPresented: Bool = false
    @State private var currentFields: [FieldData] = []
    @State private var currentDocument: RFCharacteristicValueViewModel?
    
    let size = UIScreen.main.bounds.width / 2.39
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            if let documentList = vm.documentList?.dataList {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(documentList, id: \.idUnique) { document in
                        if let fieldsData = document.viewData?.data(using: .utf8),
                           let fields = try? JSONDecoder().decode([FieldData].self, from: (fieldsData)) {
                            VStack(alignment: .leading, spacing: 4) {
                                AsyncImageView(
                                    imageURL: document.listImages?.sorted(by: { $0.dateAdded > $1.dateAdded }).first?.urlData ?? "",
                                    width: size,
                                    height: size,
                                    cornerRadius: 8
                                )
                                
                                if let name = fields.first?.valueData {
                                    Text(name)
                                        .font(Style.footnoteRegular)
                                        .foregroundColor(Style.textPrimary)
                                }
                                if let statusDoc = document.statusDoc {
                                    displayDocStatus(statusDoc)
                                        .font(Style.footnoteBold)
                                }
                                Spacer()
                            }
                            .frame(width: size)
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
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                ProgressView()
            }
        }
        .animation(.default, value: vm.documentList?.result.xRequestID)
        .safeAreaPadding()
        .background(Style.background)
        .onAppear { vm.fetchDocumentList() }
        .refreshable { vm.fetchDocumentList() }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Запросы Хочу это")
                    .foregroundColor(Style.textPrimary)
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
                .foregroundColor(Style.onBackground)
        case .waitReview:
            return Text("Ожидает подтверждения")
                .foregroundColor(Style.textTertiary)
        case .rejected:
            return Text("Запрос отклонен")
                .foregroundColor(Style.textPrimary2)
        case .notFill:
            return Text("Документ не заполнен")
                .foregroundColor(Style.textPrimary2)
        case .waitImage:
            return Text("Ожидает изображение")
                .foregroundColor(Style.textPrimary2)
        }
    }
}

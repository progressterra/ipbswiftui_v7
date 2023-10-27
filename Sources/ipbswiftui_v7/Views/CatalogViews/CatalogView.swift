//
//  CatalogView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct CatalogView: View {
    @EnvironmentObject var vm: CatalogViewModel
    
    @State private var isProductListPresented: Bool = false
    @State private var isEnclosingCatalogPresented: Bool = false
    
    let columns = [GridItem(), GridItem(), GridItem()]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                TextField("Поиск", text: .constant(""))
                    .padding()
                    .frame(height: 36)
                    .cornerRadius(40)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke()
                    }
                    .overlay(alignment: .trailing) {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing)
                    }
                    .padding(20)
                
               if let catalogItems = vm.currentCatalogItem?.listChildItems, !catalogItems.isEmpty {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(catalogItems, id: \.itemCategory.idUnique) { item in
                            CategoryCardView(
                                imageURL: item.itemCategory.imageData?.urlData ?? "",
                                name: item.itemCategory.name ?? ""
                            ) {
                                if let hasChildren = item.listChildItems?.isEmpty, !hasChildren {
                                    isEnclosingCatalogPresented = true
                                } else {
                                    vm.fetchProductList(for: item.itemCategory.idUnique)
                                    vm.currentCatalogItem = item
                                    isProductListPresented = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .safeAreaPadding()
            .background(Style.background)
            .refreshable { vm.getCatalog() }
            .onAppear(perform: vm.getCatalog)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .navigationDestination(isPresented: $isProductListPresented) {
                CatalogProductListView()
                    .toolbarRole(.editor)
                    .onDisappear(perform: vm.getCatalog)
                
            }
            .navigationDestination(isPresented: $isEnclosingCatalogPresented) {
                CatalogView().toolbarRole(.editor)
            }
        }
    }
}



struct Previews_CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
            .environmentObject(CatalogViewModel())
    }
}


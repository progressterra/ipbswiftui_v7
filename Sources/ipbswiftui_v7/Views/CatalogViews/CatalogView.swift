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
    
    let catalogItem: CatalogItem?
    
    private let columns = [GridItem(), GridItem(), GridItem()]
    
    public init(catalogItem: CatalogItem? = nil) {
        self.catalogItem = catalogItem
    }
    
    public var body: some View {
        NavigationStack(path: $vm.navigationStack) {
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
                
                if let catalogItems = catalogItem?.listChildItems {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(catalogItems, id: \.itemCategory.idUnique) { item in
                            CategoryCardView(
                                imageURL: item.itemCategory.imageData?.urlData ?? "",
                                name: item.itemCategory.name ?? ""
                            ) {
                                vm.navigationStack.append(item)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else if let rootCatalogItems = vm.rootCatalogItem?.listChildItems {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(rootCatalogItems, id: \.itemCategory.idUnique) { item in
                            CategoryCardView(
                                imageURL: item.itemCategory.imageData?.urlData ?? "",
                                name: item.itemCategory.name ?? ""
                            ) {
                                vm.navigationStack.append(item)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Style.background)
            .refreshable { vm.getCatalog() }
            .onAppear(perform: vm.getCatalog)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .navigationDestination(for: CatalogItem.self) { item in
                if let hasChildren = item.listChildItems?.isEmpty, !hasChildren {
                    CatalogView(catalogItem: item)
                        .toolbarRole(.editor)
                } else {
                    CatalogProductListView(catalogItem: item)
                        .toolbarRole(.editor)
                }
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

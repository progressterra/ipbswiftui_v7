//
//  CatalogView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// A view that presents a catalog of items using a grid layout.
///
/// This SwiftUI view is designed to display categories and products from a catalog dynamically loaded through a view model. It supports navigation through different levels of the catalog hierarchy, from root items to child categories and individual products.
///
/// ## Usage
///
/// `CatalogView` should be instantiated with an optional `CatalogItem`, which represents a specific point in the catalog hierarchy. If no item is provided, the view starts at the root of the catalog hierarchy.
///
/// ```swift
/// CatalogView(catalogItem: someCatalogItem)
///     .environmentObject(CatalogViewModel())
/// ```
///
/// ## Environment Objects
/// - `CatalogViewModel`: Handles fetching the catalog data and managing navigation state.
public struct CatalogView: View {
    
    @EnvironmentObject var vm: CatalogViewModel
    
    let catalogItem: CatalogItem?
    
    
    private let columns = Array(repeating: GridItem(), count: Style.countCatalogCategoryInRow)
    
    public init(catalogItem: CatalogItem? = nil) {
        self.catalogItem = catalogItem
    }
    
    public var body: some View {
        NavigationStack(path: $vm.navigationStack) {
            ScrollView {
                TextField("Поиск", text: $vm.searchText)
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
                    .onSubmit {
                        vm.getCatalog()
                    }
                    .submitLabel(.search)
                
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
                
                if catalogItem != nil
                {
                    CatalogProductListView(catalogItem: catalogItem!)
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

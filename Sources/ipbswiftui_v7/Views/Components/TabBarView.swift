//
//  TabBarView.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI

/// A protocol that represents a tab bar item.
public protocol TabBarItem: Hashable {
    var imageName: String { get }
    var title: String { get }
    /// Define if item should be offset by Y axe
    var isSpecial: Bool { get }
    var badgeCount: Int? { get }
}

/// `TabBarViewModel` is a class responsible for managing the state of a custom tab bar.
/// It keeps track of unique identifiers (UUIDs) associated with each tab,
/// which can be used to refresh individual tabs when necessary.
public class TabBarViewModel<Tab: TabBarItem>: ObservableObject {
    @Published public var refreshUUIDs: [Tab: UUID] = [:]
    
    public init(tabs: [Tab]) {
        tabs.forEach { refreshUUIDs[$0] = UUID() }
    }
    
    func refreshTab(_ tab: Tab) {
        refreshUUIDs[tab] = UUID()
    }
}

/// A View that represents the main layout for a tab-based view.
public struct TabBarView<Tab: TabBarItem, Content: View>: View {
    @Binding var selection: Tab
    let badgeRefreshFlag: Int?
    let content: Content
    @State private var tabs: [Tab] = []
    
    @EnvironmentObject var viewModel: TabBarViewModel<Tab>
    
    /// Initializes a new tab bar view.
    public init(selection: Binding<Tab>, badgeRefreshFlag: Int? = nil, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.badgeRefreshFlag = badgeRefreshFlag
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    Style.surface
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height < 800 ? 65 : 95)
                    TabBarItemsView(selector: $selection, tabs: tabs, badgeCount: badgeRefreshFlag)
                        .frame(height: 85)
                        .padding(.bottom, UIScreen.main.bounds.height < 800 ? 0 : 30)
                }
                .shadow(color: Style.textSecondary.opacity(0.1), radius: 5, y: -5)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onPreferenceChange(TabBarPreferenceKey.self) { tabs = $0 }
    }
}

/// A View that lays out the individual tabs in a tab bar.
struct TabBarItemsView<Tab: TabBarItem>: View {
    @Binding var selector: Tab
    let tabs: [Tab]
    let badgeCount: Int?
    
    @EnvironmentObject var viewModel: TabBarViewModel<Tab>
    
    var body: some View {
        HStack(alignment: .bottom) {
            ForEach(tabs, id: \.self) { tab in
                Spacer()
                IndividualTabView(tab: tab, isSelected: tab == selector, badgeCount: badgeCount)
                    .onTapGesture {
                        selector = tab
                        HapticUtility.impact(style: .light)
                    }
                    .simultaneousGesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                viewModel.refreshTab(tab)
                                HapticUtility.impact(style: .heavy)
                            }
                    )
                Spacer()
            }
        }
    }
}

/// A View that represents a single tab in a tab bar.
struct IndividualTabView<Tab: TabBarItem>: View {
    let tab: Tab
    let isSelected: Bool
    let badgeCount: Int?
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Image(tab.imageName)
                        .gradientColor(gradient: Style.primary)
                } else {
                    Image(tab.imageName)
                        .foregroundColor(Style.iconsPrimary)
                }
            }
            .overlay(alignment: .topTrailing) {
                if let count = tab.badgeCount, count > 0 {
                    Text("\(count)")
                        .font(Style.captionBold)
                        .foregroundColor(Style.surface)
                        .minimumScaleFactor(0.9)
                        .frame(width: 13, height: 13)
                        .padding(1)
                        .background(
                            isSelected
                            ? LinearGradient(colors: [Style.secondary], startPoint: .center, endPoint: .center)
                            : Style.primary
                        )
                        .clipShape(Circle())
                        .offset(x: 3)
                        .transition(.opacity)
                        .animation(.default, value: count)
                }
            }
            .padding(6)
            .background(tab.isSpecial ? Style.surface : .clear)
            .clipShape(Circle())
            .padding(tab.isSpecial ? 3 : 0)
            .overlay {
                ZStack {
                    if tab.isSpecial {
                        if isSelected {
                            Circle()
                                .stroke(lineWidth: 3)
                                .gradientColor(gradient: Style.primary)
                        } else {
                            Circle()
                                .stroke(lineWidth: 3)
                                .foregroundColor(Style.surface)
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(tab.isSpecial ? 0.1 : 0), radius: 2, y: -1)
            .shadow(color: .black.opacity(tab.isSpecial ? 0.1 : 0), radius: 2, y: 1)
            
            ZStack {
                if isSelected {
                    Text(tab.title)
                        .gradientColor(gradient: Style.primary)
                } else {
                    Text(tab.title)
                        .foregroundColor(Style.iconsPrimary)
                }
            }
            .frame(width: 60, height: 16)
            .font(Style.footnoteBold)
        }
        .animation(.linear(duration: 0.25), value: isSelected)
    }
}

/// A protocol that enables sharing of tabs data between views.
protocol TabBarPreferenceKeyProtocol {
    associatedtype Tab: TabBarItem
}

/// A struct that defines preference key for tab bar.
struct TabBarPreferenceKey<Tab: TabBarItem>: PreferenceKey, TabBarPreferenceKeyProtocol {
    static var defaultValue: [Tab] { [] }
    static func reduce(value: inout [Tab], nextValue: () -> [Tab]) {
        value.append(contentsOf: nextValue())
    }
}

/// A modifier that controls the visibility of a tab's associated view.
struct TabViewVisibilityModifier<Tab: TabBarItem>: ViewModifier {
    let tab: Tab
    @Binding var selection: Tab
    
    func body(content: Content) -> some View {
        content
            .preference(key: TabBarPreferenceKey<Tab>.self, value: [tab])
            .opacity(selection == tab ? 1 : 0)
    }
}

public extension View {
    /// A modifier to associate a tab with a view.
    func tabBarItem<Tab: TabBarItem>(tab: Tab, selection: Binding<Tab>) -> some View {
        modifier(TabViewVisibilityModifier(tab: tab, selection: selection))
    }
}

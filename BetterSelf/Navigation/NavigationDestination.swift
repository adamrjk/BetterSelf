//
//  NavigationDestination.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/11/2025.
//

import SwiftUI

public protocol NavigationDestination: Hashable, Equatable, Identifiable, View {
   // that's it
}

extension NavigationDestination {
    public nonisolated var id: Int {
        self.hashValue
    }
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    @MainActor public func asAnyView() -> AnyView {
        AnyView(self)
    }
}


extension View {
    public func navigationDestination<D: NavigationDestination>(_ destinations: D.Type) -> some View {
        self.navigationDestination(for: D.self) { destination in
            destination
        }
    }
}

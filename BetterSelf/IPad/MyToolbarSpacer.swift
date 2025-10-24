////
////  MyToolbarSpacer.swift
////  BetterSelf
////
////  Created by Adam Damou on 24/10/2025.
////
//
//import SwiftUI
//
//struct MyToolbarSpacer: View {
//    var body: some View {
//        if #available(iOS 26, *) {
//            ToolbarItem(placement: .topBarLeading){
//                ToolbarSpacer(.fixed, placement: .topBarTrailing)
//            }
//        }
//        else{
//            ToolbarItem(placement: .topBarTrailing){
//                Spacer()
//                    .frame(width: 50)
//            }
//
//        }
//    }
//}
//
//#Preview {
//    MyToolbarSpacer()
//}

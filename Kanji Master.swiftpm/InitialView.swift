//
//  InitialView.swift
//  Test 1
//
//  Created by Stefano on 16/04/23.
//

import SwiftUI

@available(iOS 16.0, *)
struct InitialView: View {
    @State private var showInfo = false
    @State private var path: [Bool] = []
    @Binding var hasGameStarted: Bool
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geo in
            NavigationStack(path: $path) {
                ZStack {
                    Image("background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .opacity(0.15)
                        .zIndex(0)
                    
                    VStack {
                        VStack {
                            MainTitleView(colorScheme: colorScheme)
                                .padding(.top)
                                .frame(width: 490, height: 88, alignment: .center)
                            Spacer()
                        }.frame(height: geo.size.height / 3)
                        Text("Welcome!")
                            .font(.system(size: 50))
                        Button(action: {
                            hasGameStarted.toggle()
                        }, label: {
                            Label("Start!", systemImage: "play.fill")
                                .font(.system(size: 40))
                        }).buttonStyle(.borderedProminent)
                            .padding(.all)
                        
                        Button(action: {path.append(true)}, label: {
                            Label("About", systemImage: "info.circle")
                                .font(.system(size: 40))
                        }).buttonStyle(.bordered)
                            .padding(.all)
                        
                        
                    }.frame(height: geo.size.height)
                    .zIndex(1)
                    
                }.navigationDestination(for: Bool.self) { val in
                    if(val) { AboutView(geoup: geo) }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView_Previews2()
    }
}

@available(iOS 16.0, *)
struct InitialView_Previews2: View {
    @State private var hasGameStarted = false
    var body: some View {
        InitialView(hasGameStarted: $hasGameStarted)
    }
}

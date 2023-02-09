//
//  ContentView.swift
//  Interview-LiFE
//
//  Created by Dmitry Kadyrov on 09/02/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var item = 0
    @State private var showRentalList = false
    
    var body: some View {
        GeometryReader { viewReader in
            VStack (spacing: 0) {
                VStack {
                    Text("Interview task")
                        .font(.largeTitle)
                        .fontWeight(.light)
                    Text("Collection view layout")
                        .font(.footnote)
                        .fontWeight(.ultraLight)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1).ignoresSafeArea())

                GeometryReader{ proxy in
                    let size = proxy.size
                    CollectionView(uiViewSize: size,
                                   topInset: viewReader.safeAreaInsets.top,
                                   bottomInset: viewReader.safeAreaInsets.bottom,
                                   viewHeight: viewReader.size.height,
                                   item: $item,
                                   showRentalList: $showRentalList)
                }
                .ignoresSafeArea()
            }
            .onChange(of: item) { newValue in
                self.item = newValue
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

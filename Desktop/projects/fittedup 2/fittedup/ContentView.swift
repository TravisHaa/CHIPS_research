//
//  ContentView.swift
//  fittedup
//
//  Created by Travis Ha on 2/14/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            
            Home()
                .tabItem(){
                    Image(systemName: "house.fill")
                    Text("Home")
                        .foregroundColor(.black)
                    
                }
            
            
            Sell()
                .tabItem(){
                    Image(systemName: "banknote")
                    Text("Sell")
                }
            Closet()
                .tabItem(){
                    Image(systemName: "suitcase")
                    Text("Closet")
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

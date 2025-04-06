//
//  Home.swift
//  fittedup
//
//  Created by Travis Ha on 2/15/24.
//

import SwiftUI
struct Home: View{
    
    
    @State private var animateGradient: Bool = false
    
    private let startColor: Color = .blue
    private let endColor: Color = .green
    @State private var selectedItem: ClothingItem?
    @State private var clothingItems: [ClothingItem] = [
        ClothingItem(image: "windbreaker", title: "North Face Windbreaker", color: .black, colorname: "Black", dateAdded: "2023-11-15", brand: "North Face", type: "WindBreaker"),
        ClothingItem(image: "hmjeans", title: "H&M faded black jeans", color: .black, colorname: "Black", dateAdded: "22023-11-15", brand: "H&M", type: "Jeans"),
        ClothingItem(image: "stussy", title: "Stussy 8-Ball Fleece Jacket", color: .white, colorname: "White", dateAdded: "2023-11-15", brand: "Stussy", type: "Jacket")
    ]
    
    let newItem: [ClothingItem] = [
        ClothingItem(image: "carhartt", title: "Carhartt Vintage Workwear Jacket", color: .gray, colorname: "Gray", dateAdded: "2023-11-15", brand: "Carhartt", type: "Jacket"),
        ClothingItem(image: "lacoste", title: "Lacoste Cardigan", color: .green, colorname: "Green", dateAdded: "2023-11-15", brand: "Lacoste", type: "Cardigan"),
        ClothingItem(image: "a", title: "Balenci Adidas Track Pants", color: .black, colorname: "Black", dateAdded: "2023-11-15", brand: "Adidas/Balenciaga", type: "Pants")
    ]
    
    var body: some View {
        NavigationView{
            ZStack{
                
                LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .hueRotation(.degrees(animateGradient ? 45 : 0))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                        Text("Welcome to Fitted Up")
                            .fontWeight(.heavy)
                            .font(.system(size: 30))
                            .padding(.leading)
                            .frame(height:100)
                            .foregroundColor(.white)
                        Text("Suggested Items:")
                        .foregroundColor(.white)
                    
                    NavigationView {
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: [GridItem(.fixed(200))], spacing: 10) {
                                ForEach(clothingItems) { item in
                                    Button(action: {
                                        selectedItem = item
                                    }) {
                                       Spacer()
                                        VStack{
                                            Image(item.image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)     .cornerRadius(10)
                                            Text(item.title)
                                                .fontWeight(.heavy)
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                            }
                        }
                        .cornerRadius(30)
                        .sheet(item: $selectedItem) { item in
                            ClothingDetailsView(item: item) {
                                // Closure to remove the selected item from the array
                                clothingItems.removeAll { $0.id == item.id }
                                selectedItem = nil // Deselect the item after removal
                            }
                        }
                        .cornerRadius(10)
                        
                    }
                    .frame( maxWidth: .infinity)
                    .frame(height: 150)
                    .cornerRadius(10)
                    Spacer()
                        
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .background {
                }
                
            }
        }
        
        
    }
}


struct Home_preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

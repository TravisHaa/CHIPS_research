import SwiftUI

struct ClothingItem: Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var color: Color
    var colorname: String
    var dateAdded: String
    var brand: String
    var type: String
    
}



struct Closet: View {
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
    @State private var newItemIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(clothingItems) { item in
                        Button(action: {
                            selectedItem = item
                        }) {
                            VStack{
                                Image(item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                Text(item.title)
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Closet")
            .sheet(item: $selectedItem) { item in
                ClothingDetailsView(item: item) {
                    // Closure to remove the selected item from the array
                    clothingItems.removeAll { $0.id == item.id }
                    selectedItem = nil // Deselect the item after removal
                }
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                // Add clothing item from the array and move to the next item
                if newItemIndex < newItem.count {
                    clothingItems.append(newItem[newItemIndex])
                    newItemIndex += 1
                }
            }) {
                Image(systemName: "plus")
            }
            )
        }
    }
}


struct ClothingDetailsView: View {
    let item: ClothingItem
    let onRemove: () -> Void // Closure to handle removal action
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text( "\(item.title)")
                .fontWeight(.heavy)
            
            Text("Color: \(item.colorname)")
                .fontWeight(.heavy)
            Text("Date Added: \(item.dateAdded)")
            
            Text("Brand: \(item.brand)")
            
            Text("Type: \(item.type)")
            
            Spacer()
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400, height: 400)
                .cornerRadius(10)
            Spacer()
            Button(action: {
                // Call the closure to remove the clothing item
                onRemove()
            }) {
                VStack{
                    Text("Remove")
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                }
                
            }
        }
        .padding()
    }
}


struct Closet_Previews: PreviewProvider {
    static var previews: some View {
        Closet()
    }
}

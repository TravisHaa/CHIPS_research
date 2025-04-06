import SwiftUI

@main // Define the entry point for the app
struct YourAppNameApp: App { // Use a name that reflects your app's name
    var body: some Scene {
        WindowGroup {
            splashscreen() // Set the splash screen as the root view
        }
    }
}

struct splashscreen: View {
    @State private var isActive = false
    @State private var animateGradient: Bool = false
    
    private let startColor: Color = .blue.opacity(20)
    private let endColor: Color = .green.opacity(20)
    
    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                ZStack{
                    LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    
                        .hueRotation(.degrees(animateGradient ? 45 : 0))
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                                animateGradient.toggle()
                            }
                        }
                    
                    VStack{
                        Spacer()
                        Spacer()
                        Image("logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .mask(
                                RoundedRectangle(cornerRadius: 20) // Adjust the cornerRadius to control the softness of edges
                                
                            )
                            .shadow(radius: 5)
                        Text("Fitted Up")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(80.0)
                        Spacer()
                        
                            .onAppear {
                                // Simulate a delay to mimic loading
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.isActive = true
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}

struct splashpreview: PreviewProvider {
    static var previews: some View {
        Group {
            splashscreen()
                .previewDevice("iPhone 11")
        }
    }
}

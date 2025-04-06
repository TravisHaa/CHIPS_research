import SwiftUI
import Combine

// MARK: - API Client

class GPTAPIClient {
    static let shared = GPTAPIClient()
    private init() {}
    
    func loadAPIKey() -> String? {
        //retrieves path of config.plist
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           //read content and convert to dict
           let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dictionary["API_KEY"] as? String //attempts to return api key from dict
        }
        return nil
    }


    private lazy var apiKey: String? = loadAPIKey()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    //converts images into base64 strings using a publisher
    func analyzeImages(_ images: [UIImage]) -> AnyPublisher<String, Error> {
        //converts to jpeg with compression .5, then to base64 string, compact map filters images that failed conversion
        let encodedImages = images.compactMap { image in
            image.jpegData(compressionQuality: 0.5)?.base64EncodedString()
        }
        
        let prompt = "You are an assistant for an e-commerce clothing platform where people sell their clothes online and other people buy it, similar to the app, Depop. Use the 1st image of the clothing to identify the taxonomy type, color, and the decade of fashion it is from. With the second image which is the tag on the item, identify the brand and fabric type. Create a small description of the clothing, similar to a Depop post, like this: Air Jordan 1 'Black Toe' shoes, featuring red, black, and white leather with suede accents. Y2K/retro streetwear. Identify the exact item it is in this description if possible."
        //defining request dict
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(encodedImages[0])"]] as [String : Any],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(encodedImages[1])"]]
                    ]
                ] as [String : Any]
            ],
            "max_tokens": 300
        ]
        //making request to api
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(String(describing: apiKey))", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //turns request body into JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        //creates a pbulisher to perform network request and processes the data recieved from the publisherana
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GPTResponse.self, decoder: JSONDecoder())
        //$0: Represents the current element in the sequence (the decoded GPTResponse object).
            .map { $0.choices.first?.message.content ?? "No response" }
            .eraseToAnyPublisher()
    }
}
//used to convert json to string
struct GPTResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

// MARK: - Sell View
private var cancellables = Set<AnyCancellable>()
struct Sell: View {
    @State private var selectedImages: [UIImage?] = [nil, nil]
    @State private var isShowingImagePicker = [false, false]
    @State private var gptResponse: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        ForEach(0..<2) { index in
                            VStack{
                                if let image = selectedImages[index] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .frame(width: 200, height: 200)
                                        .cornerRadius(10)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .padding()
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: {
                                    isShowingImagePicker[index] = true
                                }) {
                                    if index == 0 {
                                        Text("Insert image of clothing item front")
                                            .frame(width: 150, height: 45)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    else{
                                        Text("Insert image of tag")
                                            .frame(width: 150, height: 45)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if !gptResponse.isEmpty {
                        Text("Clothing Description:")
                            .font(.headline)
                            .padding(.top)
                        Text(gptResponse)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: processImages) {
                        Text("Analyze Clothing")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedImages.contains(nil) || isLoading)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Automated Resell")
            .sheet(isPresented: $isShowingImagePicker[0]) {
                ImagePicker(image: $selectedImages[0])
            }
            .sheet(isPresented: $isShowingImagePicker[1]) {
                ImagePicker(image: $selectedImages[1])
            }
        }
    }
    
    func processImages() {
        guard let image1 = selectedImages[0], let image2 = selectedImages[1] else { return }
        
        isLoading = true
        errorMessage = nil
        gptResponse = ""
        
        GPTAPIClient.shared.analyzeImages([image1, image2])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }, receiveValue: { response in
                gptResponse = response
            })
            .store(in:  &cancellables)
    }
    
    
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct Sell_Previews: PreviewProvider {
    static var previews: some View {
        Sell()
    }
}

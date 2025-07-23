import SwiftUI
import WebKit

struct EventMapView: View {
    @Environment(\.presentationMode) var presentationMode
    private let mapURL = URL(string: "https://forestfest.ie/sitemap-2025/")!
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text("Event Map")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    UIApplication.shared.open(mapURL)
                }) {
                    Image(systemName: "safari")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            
            // WebView for the map
            WebView(url: mapURL)
                .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color(red: 0.13, green: 0.05, blue: 0.3))
        .navigationBarHidden(true)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

#Preview {
    EventMapView()
} 
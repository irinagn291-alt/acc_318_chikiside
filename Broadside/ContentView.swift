import SwiftUI
import UIKit

/// Host role. The SwiftUI scene only seats the UIKit carousel. The spread is the product.
struct ContentView: View {
    var body: some View {
        SpreadHost()
            .ignoresSafeArea()
    }
}

struct SpreadHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SpreadBoot {
        SpreadBoot()
    }

    func updateUIViewController(_ uiViewController: SpreadBoot, context: Context) {}
}

/// Boot role. Seeds the simulator, then seats SpreadRoot.
final class SpreadBoot: UIViewController {
    private var store: BroadsideStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        let store = BroadsideStore(defaults: .standard)
        self.store = store
        Task { @MainActor in
            await store.applyDemoSeedIfNeeded()
            let root = SpreadRoot(store: store, pool: StockShelf.load())
            addChild(root)
            root.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(root.view)
            NSLayoutConstraint.activate([
                root.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                root.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                root.view.topAnchor.constraint(equalTo: view.topAnchor),
                root.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            root.didMove(toParent: self)
        }
    }
}

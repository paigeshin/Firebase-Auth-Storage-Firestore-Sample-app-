### Podfile

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FungiFinder' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FungiFinder

# add the Firebase pod for Google Analytics
pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'

# Optionally, include the Swift extensions if you're using Swift.
pod 'FirebaseFirestoreSwift'

# add pods for any other desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.2'
    end
  end
end
```

### RegisterViewModel

```swift
import Foundation
import Firebase

class RegisterViewModel: ObservableObject {

    var email: String = ""
    var password: String = ""

    func register(completion: @escaping() -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
        }
    }

}
```

### LoginViewModel

```swift
import Foundation
import Firebase

class LoginViewModel: ObservableObject {

    var email: String = ""
    var password: String = ""

    func login(completion: @escaping() -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
        }
    }

}
```

### FungiListViewModel

```swift
import Foundation
import Firebase
import FirebaseFirestoreSwift

enum LoadingState {
    case idle
    case loading
    case success
    case failure
}

class FungiListViewModel: ObservableObject {

    let storage = Storage.storage()
    let db = Firestore.firestore()

    @Published var fungi: [FungiViewModel] = []
    @Published var loadingState: LoadingState = .idle

    func getAllFungiForUser() {

        DispatchQueue.main.async {
            self.loadingState = .loading
        }

        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        db.collection("fungi")
            .whereField("userId", isEqualTo: currentUser.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.loadingState = .failure
                    }
                } else {
                    if let snapshot = snapshot {
                        let fungi: [FungiViewModel] = snapshot.documents.compactMap { doc in
                            var fungi = try? doc.data(as: Fungi.self)
                            fungi?.id = doc.documentID
                            if let fungi = fungi {
                                return FungiViewModel(fungi: fungi)
                            }
                            return nil
                        }

                        DispatchQueue.main.async {
                            self.fungi = fungi
                            self.loadingState = .success
                        }

                    }
                }
            }

    }

    func save(name: String, url: URL, completion: (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        do {
            _ = try db.collection("fungi")
                .addDocument(from: Fungi(name: name, url: url.absoluteString, userId: currentUser.uid))
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

    func uploadPhoto(data: Data, completion: @escaping(URL?) -> Void) {

        let imageName = UUID().uuidString
        let storageRef = storage.reference()
        let photoRef = storageRef.child("images/\(imageName).png")

        photoRef.putData(data, metadata: nil) { metadata, error in
            photoRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    completion(url)
                }
            }
        }

    }

}
```

### FungiViewModel

```swift
struct FungiViewModel {
    let fungi: Fungi

    var fungiId: String {
        fungi.id ?? ""
    }

    var name: String {
        fungi.name
    }

    var photoUrl: String {
        fungi.url
    }
}
```

### File + Firestore

```swift
private func saveFungi() {

        DispatchQueue.main.async {
            fungiListVM.loadingState = .loading
        }

        if let originalImage = originalImage {
            if let resizedImage = originalImage.resized(width: 1024) {
                if let data = resizedImage.pngData() {
                    fungiListVM.uploadPhoto(data: data) { url in
                        if let url = url {
                            fungiListVM.save(name: name, url: url) { error in
                                if let error = error {
                                    fungiListVM.loadingState = .failure
                                    print(error.localizedDescription)
                                } else {
                                    DispatchQueue.main.async {
                                        fungiListVM.loadingState = .success
                                    }
                                    fungiListVM.getAllFungiForUser()
                                }
                                image = nil
                            }
                        }
                    }
                }
            }
        }

    }
```

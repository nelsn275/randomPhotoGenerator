//
//  ViewController.swift
//  RandomPhotoGenerator
//
//  Created by Nicholas Nelson on 5/25/24.
//

import UIKit

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        // Create the space where our image will be
        let imageView = UIImageView()
        // Describe where the image will go in relation to the phone screen
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let button: UIButton = {
        // Create the space where our button will be
        let button = UIButton()
        // Describe where the button will go in relation to the phone screen
        button.backgroundColor = .white
        // button color and what it will say
        button.setTitle("Random Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    // Random background colors to choose from when button is pressed
    let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemGreen,
        .systemYellow,
        .systemPurple,
        .systemOrange,
        .systemRed,
        .systemGray
    ]
    
    override func viewDidLoad() {
        // What happens when the app is opened
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        // Add the actual image location
        view.addSubview(imageView)
        // Describe how big the image will be
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        // Make sure the image is centered
        imageView.center = view.center
        
        // Add the button to our screen
        view.addSubview(button)
        // Add the photo to the screen as well
        getRandomPhoto()
        // When the button is tapped, run the didTapButton function
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        // Call the getRandomPhoto function
        getRandomPhoto()
        
        // Change the background color when the button is clicked as well
        view.backgroundColor = colors.randomElement()
    }
    
    override func viewDidLayoutSubviews() {
        // Call function after safe area has been set
        super.viewDidLayoutSubviews()
        
        button.frame = CGRect(x: 30,
                              y: view.frame.size.height-150-view.safeAreaInsets.bottom,
                              width: view.frame.size.width-60,
                              height: 60)
    }

    // Function to fetch a random cat photo and update the imageView
    func getRandomPhoto() {
        let urlString = "https://api.thecatapi.com/v1/images/search"
        guard let url = URL(string: urlString) else { return }

        // Use the URL to reach out to the api
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Parse the response into JSON
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let firstResult = json.first,
                   let catUrlString = firstResult["url"] as? String,
                   let catUrl = URL(string: catUrlString) {
                    
                    // Get the cat image data
                    URLSession.shared.dataTask(with: catUrl) { catData, catResponse, catError in
                        if let catError = catError {
                            print("Error fetching cat image data: \(catError)")
                            return
                        }

                        guard let catData = catData else {
                            print("No cat image data received")
                            return
                        }
                        // Error handling
                        if let catImage = UIImage(data: catData) {
                            DispatchQueue.main.async {
                                self.imageView.image = catImage
                            }
                        } else {
                            print("Failed to create image from data")
                        }
                    }.resume()
                } else {
                    print("Failed to parse JSON or find cat URL")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}

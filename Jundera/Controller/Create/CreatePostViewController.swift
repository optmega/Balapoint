//
//  CameraViewController.swift
//  Balapoint
//
//  Created by David S on 11/15/17.
//  Copyright © 2017 David S. All rights reserved.

//  For Creating a new post. TODO: Change this VC file name. 

import UIKit
import AVFoundation

class CreatePostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var photo: UIImageView! // Image
    @IBOutlet weak var captionTextView: UITextView! // Body
    @IBOutlet weak var postTitle: UITextField! // Title
    @IBOutlet weak var header: UITextField! // Header
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var hashtag: UITextField! //Hashtag Testing
    
    var selectedImage: UIImage?
    var videoUrl: URL? //Wont need
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.text = "●"
        captionTextView.textColor = UIColor.lightGray
        settingsBarButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
        let aTabArray: [UITabBarItem] = (self.tabBarController?.tabBar.items)!
        for item in aTabArray {
            item.image = item.image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            item.imageInsets = UIEdgeInsetsMake(7, 0, -7, 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captionTextView.delegate = self
    }
    
    ///Navigation Bar
    func settingsBarButton() {
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "Dark.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(deletePostInfo), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x:0.0,y:0.0, width:25,height: 25.0)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        let publishButton: UIButton = UIButton(type: UIButtonType.custom)
        publishButton.addTarget(self, action: #selector(shareButton_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        publishButton.setTitle("Publish", for: UIControlState.normal)
        publishButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        let rightBarButton = UIBarButtonItem(customView: publishButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        self.navigationItem.title = "Create"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Futura", size: 18)!]
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if captionTextView.textColor == UIColor.lightGray {
            captionTextView.text = nil
            captionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if captionTextView.text.isEmpty {
            captionTextView.text = "Body"
            captionTextView.textColor = UIColor.lightGray
        }
    }
    
    // Deletes post info
    @objc func deletePostInfo() {
        print("Delete post button pressed on nav bar")
        presentAlertWithTitle(title: "Are you sure?", message: "Select yes to clear post.", options: "Yes", "Cancel") {
            (option) in
            switch(option) {
            case 0:
                print("Clear Post")
                self.clean()
                break
            case 1:
                print("Cancelled")
            default:
                break
            }
        }
    }

    //Adds a bullet point to each new line
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if (text == "\n") {
            if range.location == textView.text.count {
                let updatedText: String = textView.text!.appendingFormat("\n \u{2022} ")
                textView.text = updatedText
            }
            else {
                let beginning: UITextPosition = textView.beginningOfDocument
                let start: UITextPosition = captionTextView.position(from: beginning, offset: range.location)!
                let end: UITextPosition = textView.position(from: start, offset: range.length)!
                let textRange: UITextRange = captionTextView.textRange(from: start, to: end)!
            
                captionTextView.replace(textRange, withText: "\n \u{2022} ")
            
                let cursor: NSRange = NSMakeRange(range.location, 0)
                    //NSMakeRange(range.location + "\n \u{2022} ", 0)
                textView.selectedRange = cursor
            }
            return false
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        if (captionTextView.text?.isEmpty)! {
            print("Body is empty")
        } else {
            
        }
        if (postTitle.text?.isEmpty)! || (captionTextView.text?.isEmpty)! {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 2
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: postTitle.center.x - 10, y: postTitle.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: postTitle.center.x + 10, y: postTitle.center.y))
            postTitle.layer.add(animation, forKey: "position")
        } else {
            presentAlertWithTitle(title: "Ready to Publish? You will not be able to edit your post after you publish.", message: "", options: "YES", "Cancel") {
                (option) in
                switch(option) {
                case 0:
                   self.loading.startAnimating()
                   var profileImg = self.selectedImage
                    if profileImg == nil {
                        profileImg = UIImage(named: "placeholder-photo")
                    }
                    let imageData = UIImageJPEGRepresentation(profileImg!, 0.1)
                    let ratio = profileImg!.size.width / profileImg!.size.height
                        
                   HelperService.uploadDataToServer(data: imageData!, videoUrl: self.videoUrl, ratio: ratio, caption: self.header.text!, title: self.postTitle.text!, body: self.captionTextView.text!, date: Date().timeIntervalSince1970, hashtag: self.hashtag.text!, onSuccess: {
                        self.loading.stopAnimating()
                            print("Successfully sent info to database!")
                            self.clean()
                            self.tabBarController?.selectedIndex = 0
                        })
                    break
                default:
                    break
                }
            }
        }
    }
    
    /// This will delete the information if you press the X button 
    func clean() {
        self.header.text = ""
        self.postTitle.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
        self.captionTextView.text = ""
        self.hashtag.text = ""
    }
    
}

// Extension for camera
extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        print(info)
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumnailImage
                photo.image = thumnailImage
                self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
            dismiss(animated: true, completion: { 
            print("Image should appear in post")
            })
        }
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(7, 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}


//
//  SettingTableViewController.swift
//  Balapoint
//
//  Created by David S on 11/15/17.
//  Copyright © 2017 David S. All rights reserved.

//  View Controller will allow user to edit their profile. 

import UIKit

protocol SettingTableViewControllerDelegate {
    func updateUserInfor()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var delegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit"
        usernnameTextField.delegate = self
        emailTextField.delegate = self
        goalTextField.delegate = self
        websiteTextField.delegate = self
        profileImageView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        profileImageView.layer.borderWidth = 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 8
        fetchCurrentUser()
        setBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false //Testing for Profile Editing
    }
    
    func fetchCurrentUser() {
        Api.Userr.observeCurrentUser { (userr) in
            self.usernnameTextField.text = userr.username
            self.emailTextField.text = userr.email
            self.goalTextField.text = userr.bio
            self.websiteTextField.text = userr.website
            if let profileUrl = URL(string: userr.profileImageUrl!) {
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    
    @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
        loading.startAnimating()
        if let profileImg = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
          
            AuthService.updateUserInfor(username: usernnameTextField.text!, email: emailTextField.text!,
                                        bio:goalTextField.text!, website: websiteTextField.text!, imageData: imageData, onSuccess: {
                self.delegate?.updateUserInfor()
                self.loading.stopAnimating()
                self.presentAlertWithTitle(title: "Success", message: "Your profile has been updated.", options: "Ok") {
                                                (option) in
                                                switch(option) {
                                                case 0:
                                                    print("Clear Post")
                                                default:
                                                    break
                                                }
                                            }
                print("Success on updating user info!)")
            }, onError: { (errorMessage) in
                print("Error: \(String(describing: errorMessage))")
            })
        }
    }

    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            print("ERROR: \(String(describing: errorMessage))")
        }
    }
    
    @IBAction func changeProfileBtn_TouchUpInside(_ sender: Any) {
        print("Profile image selected")
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image"]
        present(pickerController, animated: true, completion: nil)
    }

}

extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.resignFirstResponder()
        return true
    }
}












































//
//  FoodViewController.swift
//  Jundera
//
//  Created by David S on 11/29/18.
//  Copyright © 2018 David S. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FoodViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var foodTableView: UITableView!
    
    var post = Post()
    var postIds: [String: Any]?
    var postSnapshots = [DataSnapshot]()
    var loadingPostCount = 0
    
    
    var posts = [Post]()
    var users = [Userr]()
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        loadUserPosts()
        foodTableView.isHidden = false
        activityIndicatorView.isHidden = true
        if posts.count == 0 {
            activityIndicatorView.stopAnimating()
        }
    }
    
    // Setup View
    private func setupView() {
        setupTableView()
        setupActivityIndicatorView()
    }
    
    // Setup TableView
    private func setupTableView() {
        foodTableView.isHidden = false
        if #available(iOS 10.0, *) {
            foodTableView.refreshControl = refreshControl
        } else {
            foodTableView.addSubview(refreshControl)
        }
        
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        foodTableView.estimatedRowHeight = 521
        foodTableView.rowHeight = UITableViewAutomaticDimension
        foodTableView.dataSource = self
        foodTableView.allowsSelection = true
    }
    
    // Refreshes data
    @objc private func refreshData(_ sender: Any) {
        
    }
    
    // Activity Indicator Setup
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
    
    private func updateView() {
        let hasPosts = posts.count > 0
        foodTableView.isHidden = !hasPosts
        
        if hasPosts {
            foodTableView.reloadData()
        }
        self.activityIndicatorView.stopAnimating()
    }
    
    func loadUserPosts() {
        Api.HashTag.observeFood { (post) in
            guard let postUid = post.uid else { return }
            //print("The post uid is: \(postUid)")
            self.fetchUser(uid: postUid, completed: {
                self.posts.append(post)
                self.foodTableView.reloadData()
                //                self.posts.sort(by: {(p1, p2) -> Bool in
                //                    return p1.date?.compare(p2.date!) == .orderedDescending
                //                })
                //self.updateView()
                //self.refreshControl.endRefreshing()
                //self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
    // Fetches User
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        Api.Userr.observeUser(withId: uid, completion: {
            user in
            self.users.append(user)
            completed()
        })
    }
    
    // Save posts
    func didSavePost(post: Post) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("saved").child(uid)
        guard let postId = post.id else { return }
        
        let values = [postId: post.uid]
        
        if post.isSaved == true {
            ref.updateChildValues(values as [AnyHashable : Any]) { (err, ref) in
                if let err = err {
                    print("Failed to put save post data in db:", err)
                    return
                }
                print("Successfully put save post in db")
            }
        } else {
            ref.child(post.id!).removeValue {_,_ in
                print("Post is unsaved from HomeVC")
            }
        }
    }
    
    func didUnsavePost(post: Post) {
        print("This function is unused")
    }
    
    // Will segue go to DetailVC is title of post is selected.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailPost_Segue" {
            print("Segue to Detail from HOME VC")
            let detailVC = segue.destination as! DetailViewController
            let postID = sender  as! String
            detailVC.postId = postID
        }
        // Go to Profile View Controller
        if segue.identifier == "Home_ProfileSegue" {
            print("Segue to profile from HomeVC")
            let profileVC = segue.destination as! ProfileUserViewController
            let userID = sender  as! String
            profileVC.userId = userID
        }
    }
    
}

extension FoodViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TopicDetailTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.post = posts[indexPath.row]
        cell.userTest = users[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

// MARK: Segue Actions
extension FoodViewController: DetailTopicDelegate {
    
    func goToDetailPostVC(postId: String) {
        performSegue(withIdentifier: "DetailPost_Segue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
}

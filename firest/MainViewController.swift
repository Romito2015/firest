//
//  MainViewController.swift
//  firest
//
//  Created by Roma Chopovenko on 11/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logoutAction(_ sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        do {
            try Auth.auth().signOut()
            if window!.rootViewController is ViewController {
                self.dismiss(animated: true, completion: { })
            } else {
                window!.rootViewController = AppDelegate.getVC(withId: "loginVC")
            }
        } catch let error {
            print("Logout Catched error: \(error.localizedDescription)")
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

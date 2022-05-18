//
//  MainViewController.swift
//  wasssup
//
//  Created by Lawrence Gimenez on 02/05/2017.
//  Copyright © 2017 Law Gimenez. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: Keys.isLoggedIn) {
            // If user is logged in, go directly to chat page
            performSegue(withIdentifier: "goToChat", sender: nil)
        } else {
            // If user is logged out, open login / sign up page
            performSegue(withIdentifier: "goToLogin", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

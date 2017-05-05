//
//  ViewController.swift
//  LMVrDemo
//
//  Created by wzkj on 2017/4/27.
//  Copyright © 2017年 dzeep. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view:LMDrawView = LMDrawView(frame: self.view.frame)
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


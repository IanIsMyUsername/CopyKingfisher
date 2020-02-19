//
//  ViewController.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/1/31.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let arrayOne = [1,2,3,4,5]
        let dictionary = [1:"hehe1",2:"hehe2"]
        for i in arrayOne where dictionary[i] != nil {
            print(i)
        }
    }


}


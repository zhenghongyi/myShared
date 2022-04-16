//
//  DetailController.swift
//  YIThemeDemo
//
//  Created by zhenghongyi on 2022/4/16.
//

import UIKit

class DetailController: UIViewController {
    
    deinit {
        print("detail deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func update(_ sender: Any) {
        var dic = YIThemeCenter.shared.theme
        dic[AlertTextColor] = UIColor.orange
        YIThemeCenter.shared.theme = dic
        YIThemeCenter.shared.update()
    }
}

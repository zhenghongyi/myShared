//
//  MainController.swift
//  YIThemeDemo
//
//  Created by zhenghongyi on 2022/4/16.
//

import UIKit

class MainController: UIViewController {

    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
subTitleLabel.t_textColorKey = SubTextColor
subTitleLabel.t_fontKey = SubTextFont
    }

    @IBAction func showDetail(_ sender: Any) {
        navigationController?.pushViewController(DetailController(), animated: true)
    }
}

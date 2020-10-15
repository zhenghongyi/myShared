//
//  ViewController.swift
//  YIHFWebView
//
//  Created by zhenghongyi on 2020/10/15.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {

    let hfWebView = YIHFWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(hfWebView)
        hfWebView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let headerView = UIView()
        headerView.backgroundColor = .yellow
        let footerView = UIView()
        footerView.backgroundColor = .green
        let webView = WKWebView()

        if let path = Bundle.main.path(forResource: "1", ofType: "html"),
           let html = try? String(contentsOfFile: path) {
            webView.loadHTMLString(html, baseURL: nil)
        }

        hfWebView.config(head: headerView, web: webView, foot: footerView)

        // 用于获取数据后的展示，或者高度展开收缩
        hfWebView.footHeight = 100
        hfWebView.headHeight = 100
    }

}


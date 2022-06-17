//
//  GifView.swift
//  MailUI
//
//  Created by lunkr on 2022/5/19.
//

import UIKit
import WebKit

class GifView: WKWebView {
    convenience init(bodyColor:(r:Int, g:Int, b:Int)) {
        self.init(frame: .zero)
        self.preLoad(bodyColor: bodyColor)
    }
    
    private func preLoad(bodyColor:(r:Int, g:Int, b:Int)) {
        isUserInteractionEnabled = false
        let html = """
            <html>
                <body style="background-color:rgba(0,0,0,1);">
                </body>
            </html>
        """
        loadHTMLString(html, baseURL: URL(fileURLWithPath: ""))
    }
    
    func load(gifFilePath:String) {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: gifFilePath)) {
            load(gifData: data)
        }
    }
    
    func load(gifData:Data) {
        let gifBase64Str = gifData.base64EncodedString()
        let html = """
            <html>
                <body style="background-color:rgba(0,0,0,1);">
                    <div style="height: 100%;display: flex;align-items: center;justify-content: center;">
                        <img src="data:image/gif;base64,\(gifBase64Str)"/>
                    </div>
                </body>
            </html>
        """
        loadHTMLString(html, baseURL: URL(fileURLWithPath: ""))
    }
}

/*
The MIT License (MIT)

Copyright (c) 2016 HJC hjcapple@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import UIKit

class TestView4 : TestView
{
    private var _views = [UIView]()
    private let _group = AutoLayoutKitConstraintGroup()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        
        let redView    = self.addColorSubView(UIColor.redColor())
        let blueView   = self.addColorSubView(UIColor.blueColor())
        let greenView = self.addColorSubView(UIColor.greenColor())
        
        _views.append(redView)
        _views.append(blueView)
        _views.append(greenView)
        
        replaceConstraints()
        
        let label = UILabel()
        label.text = "Tap Me"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(40)
        self.addSubview(label)
        self.tk_constraint { make in
            make.center(label)
        }
    }
    
    private func replaceConstraints()
    {
        self.tk_constraint(replace: _group) { make in
            let edge : CGFloat = 20
            make.insetEdges(edge: edge)
            
            make.width(_views[0], _views[1]) == make.w * 0.5 - edge * 0.5
            make.width(_views[2]) == make.w
            
            make.height(_views) == make.h * 0.5 - edge * 0.5
            
            make.xLeft(_views[0])
            make.yTop(_views[0])
            
            make.xRight(_views[1])
            make.yTop(_views[1])
            
            make.xCenter(_views[2])
            make.yBottom(_views[2])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let lastView = _views[2]
        _views[2] = _views[1]
        _views[1] = _views[0]
        _views[0] = lastView
        
        replaceConstraints()
        UIView.animateWithDuration(0.5) {
            self.layoutIfNeeded()
        }
    }
}



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

public extension AutoLayoutKitView
{
    var tk_centerX : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .centerX)
    }
    
    var tk_centerY : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .centerY)
    }
    
    var tk_right : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .right)
    }
    
    var tk_left : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .left)
    }
    
    var tk_top : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .top)
    }
    
    var tk_bottom : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(self, .bottom)
    }
}


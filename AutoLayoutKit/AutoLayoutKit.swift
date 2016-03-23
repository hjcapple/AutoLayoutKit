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

#if os(iOS)
    import UIKit
    public typealias AutoLayoutKitView = UIView
#else
    import AppKit
    public typealias AutoLayoutKitView = NSView
#endif


public extension AutoLayoutKitView
{
    func tk_constraint(@noescape callback:(AutoLayoutKitMaker -> Void)) -> AutoLayoutKitConstraintGroup
    {
        return tk_constraint(replace: AutoLayoutKitConstraintGroup(), callback: callback)
    }
    
    func tk_constraint(replace group: AutoLayoutKitConstraintGroup,
        @noescape callback:(AutoLayoutKitMaker -> Void)) -> AutoLayoutKitConstraintGroup
    {
        group.uninstall()
        let make = AutoLayoutKitMaker(view: self, group: group)
        callback(make)
        return group
    }
}

///////////////////////////////////////////////////////////////////////
public struct AutoLayoutKitConstraint
{
    let view: AutoLayoutKitView
    let constraint: NSLayoutConstraint
    
    init(view: AutoLayoutKitView, constraint: NSLayoutConstraint) {
        self.view = view
        self.constraint = constraint
    }
}

public class AutoLayoutKitConstraintGroup
{
    private var _constraints = [AutoLayoutKitConstraint]()
    
    private func addConstraints(constraint: AutoLayoutKitConstraint)
    {
        _constraints.append(constraint)
    }
    
    public func uninstall()
    {
        for c in _constraints
        {
            c.view.removeConstraint(c.constraint)
        }
        _constraints.removeAll()
    }
    
    public init()
    {
    }
}

public class AutoLayoutKitMaker
{
    public struct EdgeInsets
    {
        public var top: CGFloat
        public var left: CGFloat
        public var bottom: CGFloat
        public var right: CGFloat
        
        public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
        {
            self.top = top
            self.left = left
            self.bottom = bottom
            self.right = right
        }
    }
    
    private var _refview  : AutoLayoutKitView
    private var _edges = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var _group :AutoLayoutKitConstraintGroup
    
    var divider : AutoLayoutKitDivider {
        return AutoLayoutKitDivider()
    }
    
    var wall : AutoLayoutKitDivider {
        return self.divider
    }
    
    var w : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(_refview, .Width, -_edges.left - _edges.right)
    }
    
    var h : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(_refview, .Height, -_edges.top - _edges.bottom)
    }
    
    private init(view: AutoLayoutKitView, group: AutoLayoutKitConstraintGroup)
    {
        _refview = view
        _group = group
    }
    
    public func install(constraint: AutoLayoutKitConstraint?)
    {
        guard let constraint = constraint else { return }
        if let leftView = constraint.constraint.firstItem as? AutoLayoutKitView
        {
            leftView.translatesAutoresizingMaskIntoConstraints = false
        }
        constraint.view.addConstraint(constraint.constraint)
        _group.addConstraints(constraint)
    }
}

// MARK: -
// MARK: edges
extension AutoLayoutKitMaker
{
    public func resetEdges(edges: EdgeInsets)
    {
        _edges = edges
    }
    
    public func insetEdges(top top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> EdgeInsets
    {
        let edges = _edges
        _edges.left += left
        _edges.top += top
        _edges.right += right
        _edges.bottom += bottom
        return edges
    }
    
    public func insetEdges(edge edge: CGFloat) -> EdgeInsets
    {
        return insetEdges(top: edge, left: edge, bottom: edge, right: edge)
    }
}

// MARK: -
// MARK: xPlace
extension AutoLayoutKitMaker
{
    func xPlace(items: [AutoLayoutKitEdgeItem])
    {
        var lastEdge : AutoLayoutKitAttribute? = AutoLayoutKitAttribute(_refview, .Left, _edges.left)
        for item in items
        {
            if let view = item.autoLayoutKit_view
            {
                if let lastEdge = lastEdge
                {
                    install(AutoLayoutKitAttribute(view, .Left) == lastEdge)
                }
                lastEdge = AutoLayoutKitAttribute(view, .Right)
            }
            else
            {
                lastEdge = auto_layout_kit.updateEdge(lastEdge, value: item.autoLayoutKit_value)
            }
        }
        
        if let lastEdge = lastEdge where lastEdge.view !== _refview
        {
            install(lastEdge == AutoLayoutKitAttribute(_refview, .Right, -_edges.right))
        }
    }
    
    public func xPlace(items: AutoLayoutKitEdgeItem...)
    {
        return xPlace(items)
    }
}


// MARK: -
// MARK: yPlace
extension AutoLayoutKitMaker
{
    func yPlace(items: [AutoLayoutKitEdgeItem])
    {
        var lastEdge : AutoLayoutKitAttribute? = AutoLayoutKitAttribute(_refview, .Top, _edges.top)
        for item in items
        {
            if let view = item.autoLayoutKit_view
            {
                if let lastEdge = lastEdge
                {
                    install(AutoLayoutKitAttribute(view, .Top) == lastEdge)
                }
                lastEdge = AutoLayoutKitAttribute(view, .Bottom)
            }
            else
            {
                lastEdge = auto_layout_kit.updateEdge(lastEdge, value: item.autoLayoutKit_value)
            }
        }
        
        if let lastEdge = lastEdge where lastEdge.view !== _refview
        {
            install(lastEdge == AutoLayoutKitAttribute(_refview, .Bottom, _edges.bottom))
        }
    }
    
    public func yPlace(items: AutoLayoutKitEdgeItem...)
    {
        return yPlace(items)
    }
}

// MARK: -
// MARK: size
extension AutoLayoutKitMaker
{
    public struct SizeGroup
    {
        private let _views : [AutoLayoutKitView]
        private let _make : AutoLayoutKitMaker
        
        private init(views: [AutoLayoutKitView], make: AutoLayoutKitMaker)
        {
            _views = views
            _make = make
        }
        
        private func setValue(width: AutoLayoutKitAttributeItem, height: AutoLayoutKitAttributeItem)
        {
            for view in _views
            {
                _make.install(AutoLayoutKitAttribute(view, .Width) == width.autolayoutKit_attribute)
                _make.install(AutoLayoutKitAttribute(view, .Height) == height.autolayoutKit_attribute)
            }
        }
    }
    
    public func size(views: [AutoLayoutKitView]) -> SizeGroup
    {
        return SizeGroup(views: views, make: self)
    }
    
    public func size(views: AutoLayoutKitView...) -> SizeGroup
    {
        return size(views)
    }
}

public func == (group: AutoLayoutKitMaker.SizeGroup, size: CGSize)
{
    group.setValue(size.width, height: size.height)
}

public func == (group: AutoLayoutKitMaker.SizeGroup, size: (AutoLayoutKitAttributeItem, AutoLayoutKitAttributeItem))
{
    group.setValue(size.0, height: size.1)
}

// MARK: -
// MARK: width
extension AutoLayoutKitMaker
{
    public struct WidthGroup
    {
        private let _views : [AutoLayoutKitView]
        private let _make : AutoLayoutKitMaker
        
        private init(views: [AutoLayoutKitView], make: AutoLayoutKitMaker)
        {
            _views = views
            _make = make
        }
        
        private func setValue(value: AutoLayoutKitAttributeItem)
        {
            for view in _views
            {
                _make.install(AutoLayoutKitAttribute(view, .Width) == value.autolayoutKit_attribute)
            }
        }
        
        private func setValues(values: [AutoLayoutKitAttributeItem])
        {
            let count = min(_views.count, values.count)
            for i in 0 ..< count
            {
                _make.install(AutoLayoutKitAttribute(_views[i], .Width) == values[i].autolayoutKit_attribute)
            }
        }
    }
    
    public func width(views: [AutoLayoutKitView]) -> WidthGroup
    {
        return WidthGroup(views: views, make: self)
    }
    
    public func width(views: AutoLayoutKitView...) -> WidthGroup
    {
        return width(views)
    }
}

public func == (group: AutoLayoutKitMaker.WidthGroup, value: AutoLayoutKitAttributeItem)
{
    group.setValue(value)
}

public func == (group: AutoLayoutKitMaker.WidthGroup, values: [AutoLayoutKitAttributeItem])
{
    group.setValues(values)
}

// MARK: -
// MARK: width
extension AutoLayoutKitMaker
{
    public struct HeightGroup
    {
        private let _views : [AutoLayoutKitView]
        private let _make : AutoLayoutKitMaker
        
        private init(views: [AutoLayoutKitView], make: AutoLayoutKitMaker)
        {
            _views = views
            _make = make
        }
        
        private func setValue(value: AutoLayoutKitAttributeItem)
        {
            for view in _views
            {
                _make.install(AutoLayoutKitAttribute(view, .Height) == value.autolayoutKit_attribute)
            }
        }
        
        private func setValues(values: [AutoLayoutKitAttributeItem])
        {
            let count = min(_views.count, values.count)
            for i in 0 ..< count
            {
                _make.install(AutoLayoutKitAttribute(_views[i], .Height) == values[i].autolayoutKit_attribute)
            }
        }
    }
    
    public func height(views: [AutoLayoutKitView]) -> HeightGroup
    {
        return HeightGroup(views: views, make: self)
    }
    
    public func height(views: AutoLayoutKitView...) -> HeightGroup
    {
        return height(views)
    }
}

public func == (group: AutoLayoutKitMaker.HeightGroup, value: AutoLayoutKitAttributeItem)
{
    group.setValue(value)
}

public func == (group: AutoLayoutKitMaker.HeightGroup, values: [AutoLayoutKitAttributeItem])
{
    group.setValues(values)
}


// MARK: -
// MARK: xLeft
extension AutoLayoutKitMaker
{
    public func xLeft(views : [AutoLayoutKitView])
    {
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .Left) == AutoLayoutKitAttribute(_refview, .Left, _edges.left))
        }
    }
    
    public func xLeft(views : AutoLayoutKitView...)
    {
        xLeft(views)
    }
}

// MARK: -
// MARK: xRight
extension AutoLayoutKitMaker
{
    public func xRight(views : [AutoLayoutKitView])
    {
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .Right) == AutoLayoutKitAttribute(_refview, .Right, -_edges.right))
        }
    }
    
    public func xRight(views : AutoLayoutKitView...)
    {
        xRight(views)
    }
}


// MARK: -
// MARK: yTop
extension AutoLayoutKitMaker
{
    public func yTop(views : [AutoLayoutKitView])
    {
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .Top) == AutoLayoutKitAttribute(_refview, .Top, _edges.top))
        }
    }
    
    public func yTop(views : AutoLayoutKitView...)
    {
        yTop(views)
    }
}

// MARK: -
// MARK: yBottom
extension AutoLayoutKitMaker
{
    public func yBottom(views : [AutoLayoutKitView])
    {
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .Bottom) == AutoLayoutKitAttribute(_refview, .Bottom, -_edges.bottom))
        }
    }
    
    public func yBottom(views : AutoLayoutKitView...)
    {
        yBottom(views)
    }
}


// MARK: -
// MARK: xCenter
extension AutoLayoutKitMaker
{
    public func xCenter(views : [AutoLayoutKitView])
    {
        let offset = (_edges.left - _edges.right) * 0.5
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .CenterX) == AutoLayoutKitAttribute(_refview, .CenterX, -offset))
        }
    }
    
    public func xCenter(views : AutoLayoutKitView...)
    {
        xCenter(views)
    }
}

// MARK: -
// MARK: yCenter
extension AutoLayoutKitMaker
{
    public func yCenter(views: [AutoLayoutKitView])
    {
        let offset = (_edges.top - _edges.bottom) * 0.5
        for view in views
        {
            install(AutoLayoutKitAttribute(view, .CenterY) == AutoLayoutKitAttribute(_refview, .CenterY, -offset))
        }
    }
    
    public func yCenter(views: AutoLayoutKitView...)
    {
        yCenter(views)
    }
}


// MARK: -
// MARK: center
extension AutoLayoutKitMaker
{
    public func center(views: [AutoLayoutKitView])
    {
        self.xCenter(views)
        self.yCenter(views)
    }
    
    public func center(views: AutoLayoutKitView...)
    {
        center(views)
    }
}

// MARK: -
// MARK: xEqual
extension AutoLayoutKitMaker
{
    public func xEqual(views: [AutoLayoutKitView])
    {
        self.xLeft(views)
        self.xRight(views)
    }
    
    public func xEqual(views: AutoLayoutKitView...)
    {
        xEqual(views)
    }
}

// MARK: -
// MARK: yEqual
extension AutoLayoutKitMaker
{
    public func yEqual(views: [AutoLayoutKitView])
    {
        self.yTop(views)
        self.yBottom(views)
    }
    
    public func yEqual(views: AutoLayoutKitView...)
    {
        yEqual(views)
    }
}

// MARK: -
// MARK: equal
extension AutoLayoutKitMaker
{
    public func equal(views: [AutoLayoutKitView])
    {
        xEqual(views)
        yEqual(views)
    }
    
    public func equal(views: AutoLayoutKitView...)
    {
        equal(views)
    }
}

// MARK: -
// MARK: ref
extension AutoLayoutKitMaker
{
    public func ref(view: AutoLayoutKitView) -> AutoLayoutKitMaker
    {
        return AutoLayoutKitMaker(view: view, group: _group)
    }
}

////////////////////////////////////////////////////////
public struct AutoLayoutKitAttribute : AutoLayoutKitAttributeItem
{
    private var attribute: NSLayoutAttribute
    private var view: AutoLayoutKitView?
    private var constant: CGFloat = 0.0
    private var multiplier: CGFloat = 1.0
    
    public var autolayoutKit_attribute : AutoLayoutKitAttribute {
        return self
    }
    
    public init(_ view: AutoLayoutKitView?, _ attribute: NSLayoutAttribute, _ constant: CGFloat = 0.0)
    {
        self.attribute = attribute
        self.view = view
        self.constant = constant
    }
}

public func * (attribute: AutoLayoutKitAttribute, scale: CGFloat) -> AutoLayoutKitAttribute
{
    var result = attribute
    result.constant *= scale
    result.multiplier *= scale
    return result
}

public func / (attribute: AutoLayoutKitAttribute, scale: CGFloat) -> AutoLayoutKitAttribute
{
    var result = attribute
    result.constant /= scale
    result.multiplier /= scale
    return result
}

public func + (attribute: AutoLayoutKitAttribute, value: CGFloat) -> AutoLayoutKitAttribute
{
    var result = attribute
    result.constant += value
    return result
}

public func - (attribute: AutoLayoutKitAttribute, value: CGFloat) -> AutoLayoutKitAttribute
{
    var result = attribute
    result.constant -= value
    return result
}

public func == (left: AutoLayoutKitAttribute, right: AutoLayoutKitAttribute) -> AutoLayoutKitConstraint?
{
    return auto_layout_kit.makeConstraint(left, right: right, relatedBy: .Equal)
}

public func >= (left: AutoLayoutKitAttribute, right: AutoLayoutKitAttribute) -> AutoLayoutKitConstraint?
{
    return auto_layout_kit.makeConstraint(left, right: right, relatedBy: .GreaterThanOrEqual)
}

public func <= (left: AutoLayoutKitAttribute, right: AutoLayoutKitAttribute) -> AutoLayoutKitConstraint?
{
    return auto_layout_kit.makeConstraint(left, right: right, relatedBy: .LessThanOrEqual)
}

//////////////////////////////////////////

public protocol AutoLayoutKitEdgeItem
{
    var autoLayoutKit_view  : AutoLayoutKitView?  { get }
    var autoLayoutKit_value : CGFloat? { get }
}

public protocol AutoLayoutKitAttributeItem
{
    var autolayoutKit_attribute : AutoLayoutKitAttribute  { get }
}

// MARK: -
// MARK: CGFloat
extension CGFloat : AutoLayoutKitEdgeItem, AutoLayoutKitAttributeItem
{
    public var autoLayoutKit_view  : AutoLayoutKitView? {
        return nil
    }
    
    public var autoLayoutKit_value : CGFloat? {
        return self
    }
    
    public var autolayoutKit_attribute : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(nil, .NotAnAttribute, self)
    }
}

// MARK: -
// MARK: Int
extension Int : AutoLayoutKitEdgeItem, AutoLayoutKitAttributeItem
{
    public var autoLayoutKit_view  : AutoLayoutKitView? {
        return nil
    }
    
    public var autoLayoutKit_value : CGFloat? {
        return CGFloat(self)
    }
    
    public var autolayoutKit_attribute : AutoLayoutKitAttribute {
        return AutoLayoutKitAttribute(nil, .NotAnAttribute, CGFloat(self))
    }
}

// MARK: -
// MARK: View
extension AutoLayoutKitView : AutoLayoutKitEdgeItem
{
    public var autoLayoutKit_view  : AutoLayoutKitView? {
        return self
    }
    
    public var autoLayoutKit_value : CGFloat? {
        return nil
    }
}

// MARK: -
// MARK: AutoLayoutKitDivider
public struct AutoLayoutKitDivider : AutoLayoutKitEdgeItem
{
    public var autoLayoutKit_view  : AutoLayoutKitView? {
        return nil
    }
    
    public var autoLayoutKit_value : CGFloat? {
        return nil
    }
}

////////////////////////////////////////////////////////////
private struct auto_layout_kit
{
    static private func updateEdge(edge: AutoLayoutKitAttribute?, value: CGFloat?) -> AutoLayoutKitAttribute?
    {
        guard var edge = edge else { return nil }
        guard let value = value else { return nil }
        edge.constant += value
        return edge
    }
    
    static private func closestCommonAncestor(a: AutoLayoutKitView, b: AutoLayoutKitView) -> AutoLayoutKitView? {
        let (aSuper, bSuper) = (a.superview, b.superview)
        
        if a === b { return a }
        
        if a === bSuper { return a }
        
        if b === aSuper { return b }
        
        if aSuper === bSuper { return aSuper }
        
        let ancestorsOfA = Set(ancestors(a))
        
        for ancestor in ancestors(b) {
            if ancestorsOfA.contains(ancestor) {
                return ancestor
            }
        }
        return .None
    }
    
    static private func ancestors(v: AutoLayoutKitView) -> AnySequence<AutoLayoutKitView> {
        return AnySequence { () -> AnyGenerator<AutoLayoutKitView> in
            var view: AutoLayoutKitView? = v
            return AnyGenerator {
                let current = view
                view = view?.superview
                return current
            }
        }
    }
    
    static private func makeConstraint(
        left: AutoLayoutKitAttribute,
        right: AutoLayoutKitAttribute,
        relatedBy: NSLayoutRelation) -> AutoLayoutKitConstraint?
    {
        // left.multiplier * left + left.constant == right.multiplier * right + right.constant
        // => left = (right.multiplier * right) / left.multiplier + (right.constant - left.constant) / left.multiplier
        guard let leftView = left.view else { return nil }
        
        let constraint = NSLayoutConstraint(
            item: leftView,
            attribute: left.attribute,
            relatedBy: relatedBy,
            toItem: right.view,
            attribute: right.attribute,
            multiplier: right.multiplier / left.multiplier,
            constant: (right.constant - left.constant) / left.multiplier)
        
        var view : AutoLayoutKitView!
        if let rightView = right.view
        {
            view = auto_layout_kit.closestCommonAncestor(leftView, b: rightView)
        }
        else
        {
            view = leftView
        }
        
        return AutoLayoutKitConstraint(view: view, constraint: constraint)
    }
}


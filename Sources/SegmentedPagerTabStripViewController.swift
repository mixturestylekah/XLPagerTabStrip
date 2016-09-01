//  SegmentedPagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public struct SegmentedPagerTabStripSettings {
    
    public struct Style {
        public var segmentedControlColor: UIColor?
    }
    
    public var style = Style()
}


open class SegmentedPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripDelegate {
    
    open func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, didMoveToIndex: Int, viewController: UIViewController?) {
    }
    
    @IBOutlet lazy public var segmentedControl: UISegmentedControl! = UISegmentedControl()
    
    public var settings = SegmentedPagerTabStripSettings()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        pagerBehaviour = PagerTabStripBehaviour.common(skipIntermediateViewControllers: true)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pagerBehaviour = PagerTabStripBehaviour.common(skipIntermediateViewControllers: true)
        delegate = self
        datasource = self
    }
    
    private(set) var shouldUpdateSegmentedControl = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if segmentedControl.superview == nil {
            navigationItem.titleView = segmentedControl
        }
        segmentedControl.tintColor = settings.style.segmentedControlColor ?? segmentedControl.tintColor
        segmentedControl.addTarget(self, action: #selector(SegmentedPagerTabStripViewController.segmentedControlChanged(_:)), for: .valueChanged)
        reloadSegmentedControl()
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        if isViewLoaded {
            reloadSegmentedControl()
        }
    }
    
    func reloadSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, item) in viewControllers.enumerated(){
            let child = item as! IndicatorInfoProvider
            if let image = child.indicatorInfo(for: self).image {
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            }
            else {
                segmentedControl.insertSegment(withTitle: child.indicatorInfo(for: self).title, at: index, animated: false)
            }
        }
        segmentedControl.selectedSegmentIndex = currentIndex
    }
    
    func segmentedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        pagerTabStripViewController(self, updateIndicatorFrom: currentIndex, to: index)
        shouldUpdateSegmentedControl = false
        moveToViewController(at: index)
    }
    
    // MARK: - PagerTabStripDelegate
    
    public func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFrom fromIndex: Int, to toIndex: Int) {
        if shouldUpdateSegmentedControl {
            segmentedControl.selectedSegmentIndex = toIndex
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        shouldUpdateSegmentedControl = true
    }
}

//
//  DZMSegmentedControl.swift
//  DZMSegmentedControl
//
//  Created by 邓泽淼 on 2018/5/8.
//  Copyright © 2018年 邓泽淼. All rights reserved.
//

import UIKit

@objc protocol DZMSegmentedControlDelegate:NSObjectProtocol {
    
    /// 手动点击Item
    @objc optional func segmentedControl(segmentedControl:DZMSegmentedControl, clickIndex index:NSInteger)
}

private let DZMSCDuration:Double = 0.2

class DZMSegmentedControl: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    /// 代理
    weak var delegate:DZMSegmentedControlDelegate?
    
    /// 默认Item字体属性
    var itemAttributes:[NSAttributedStringKey:Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
    
    /// 选中Item字体属性
    var itemSelectAttributes:[NSAttributedStringKey:Any]?
    
    /// 每个Item四周间距
    var itemInset:UIEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
    
    /// 滚动条高度
    var sliderHeight:CGFloat = 3 {
        
        didSet{
            
            if sliderView != nil {
                
                let tempFrame = sliderView.frame
                
                sliderView.frame = CGRect(x: tempFrame.origin.x, y: frame.size.height - sliderHeight, width: tempFrame.size.width, height: sliderHeight)
            }
        }
    }
    
    /// 滚动条
    private(set) var sliderView:UIView!
    
    /// 数据源
    private var titles:[String] = []
    
    /// 滚动控件
    private var collectionView:UICollectionView!
    
    /// layout
    private var layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    /// 记录选中的IndexPath
    private var selectIndexPath:IndexPath!
    
    /// 记录选中的Item
    private weak var selectItem:DZMSegmentedControlItem!
    
    /// 所有的Item大小
    private var itemSizes:[CGSize] = []
    
    /// 所有的Item文字大小
    private var itemTitleSizes:[CGSize] = []
    
    /// 所有的Item使用的滚动条大小
    private var itemSliderRects:[CGRect] = []
    
    /// 相关联滚动控件
    private weak var registerScrollView:UIScrollView!
    
    /// 是点击滚动
    private var isClickSelect:Bool = true
    
    // MARK: 构造
    
    private init() { super.init(frame: CGRect.zero) }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addSubviews()
    }
    
    private func addSubviews() {
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DZMSegmentedControlItem.classForCoder(), forCellWithReuseIdentifier: "DZMSCI")
        addSubview(collectionView)
        
        sliderView = UIView()
        sliderView.backgroundColor = UIColor.red
        sliderView.frame = CGRect(x: 0, y: frame.size.height - sliderHeight, width: 0, height: sliderHeight)
        collectionView.addSubview(sliderView)
    }
    
    /// 刷新数据源
    func reload(_ titles:[String], _ selectIndex:NSInteger = 0, _ animated:Bool = false) {
        
        isClickSelect = true
        
        self.titles = titles
        
        setSelectIndexPath(nil)
        
        setSelectSliderView(nil)
        
        collectionView.reloadData()
        
        if !titles.isEmpty {
        
            reloadItemSizes()
            
            let indexPath = IndexPath.init(item: selectIndex, section: 0)
            
            setSelectIndexPath(indexPath)
            
            setSelectSliderView(indexPath, animated)
            
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
            
            delegate?.segmentedControl?(segmentedControl: self, clickIndex: indexPath.item)
        }
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DZMSCI", for: indexPath) as! DZMSegmentedControlItem
        
        cell.itemInset = itemInset
        
        cell.itemAttributedText = NSAttributedString.init(string: titles[indexPath.item], attributes: itemAttributes)
        
        if itemSelectAttributes != nil {
            
            cell.itemSelectAttributedText = NSAttributedString.init(string: titles[indexPath.item], attributes: itemSelectAttributes!)
            
        }else{
            
            cell.itemSelectAttributedText = nil
        }
        
        cell.isSelect = (selectIndexPath == indexPath)
        
        if cell.isSelect { selectItem = cell }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        isClickSelect = true
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        setSelectIndexPath(indexPath)
        
        setSelectSliderView(indexPath, true)
        
        delegate?.segmentedControl?(segmentedControl: self, clickIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return itemSizes[indexPath.item]
    }
    
    /// 重新计算所有Item大小
    private func reloadItemSizes() {
        
        if !titles.isEmpty {
            
            let sliderH:CGFloat = sliderHeight
            let sliderY:CGFloat = frame.size.height - sliderH
            var lastItemX:CGFloat = 0
            
            for title in titles {
                
                let string = NSAttributedString.init(string: title, attributes: itemAttributes)
                
                let itemTitleSize = string.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height - itemInset.top - itemInset.bottom), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil).size
                
                let itemSize = CGSize(width: itemTitleSize.width + itemInset.left + itemInset.right, height: frame.size.height)
                
                itemSliderRects.append(CGRect(x: lastItemX + itemInset.left, y: sliderY, width: itemTitleSize.width, height: sliderH))
                
                itemTitleSizes.append(itemTitleSize)
                
                itemSizes.append(itemSize)
                
                lastItemX += itemSize.width
            }
            
        }else{
            
            itemSizes.removeAll()
            
            itemTitleSizes.removeAll()
            
            itemSliderRects.removeAll()
        }
    }
    
    /// 设置滚动条到选中位置
    private func setSelectSliderView(_ indexPath:IndexPath?, _ animated:Bool = false) {
        
        if indexPath != nil {
            
            let rect = itemSliderRects[indexPath!.item]
            
            if animated {
                
                UIView.animate(withDuration: DZMSCDuration) { [weak self] () in
                    
                    self?.sliderView.frame = rect
                }
                
            }else{
                
                sliderView.frame = rect
            }
            
        }else{
            
            sliderView.frame = CGRect.zero
        }
    }
    
    /// 记录选中Item
    private func setSelectIndexPath(_ indexPath:IndexPath?) {
        
        if selectIndexPath != indexPath {
            
            selectIndexPath = indexPath
            
            if indexPath != nil {
                
                selectItem?.isSelect = false
                
                selectItem = collectionView.cellForItem(at: indexPath!) as? DZMSegmentedControlItem
                
                selectItem?.isSelect = true
                
            }else{
                
                selectItem = nil
            }
        }
    }
    
    // MARK: 扩展监听
    
    /// 注册关联滚动控件
    func register(_ scrollView: UIScrollView) {
        
        if registerScrollView != scrollView {
            
            if registerScrollView != nil {
                
                registerScrollView?.panGestureRecognizer.removeTarget(self, action: #selector(touchPan(_:)))
                
                registerScrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            }
            
            registerScrollView = scrollView
            
            registerScrollView.panGestureRecognizer.addTarget(self, action: #selector(touchPan(_:)))
            
            registerScrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    /// 开始拖拽
    @objc private func touchPan(_ pan:UIPanGestureRecognizer) {
        
        if pan.state == .began { isClickSelect = false }
    }
    
    /// KVO监听回调
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if !isClickSelect { monitor(registerScrollView) }
    }
    
    /// 监控关联滚动控件
    private func monitor(_ scrollView: UIScrollView) {
        
        if !titles.isEmpty && selectIndexPath?.item != nil {
            
            let page:CGFloat = scrollView.contentOffset.x / scrollView.frame.width
            
            let currentRect = itemSliderRects[selectIndexPath.item]
            
            let nextIndex:NSInteger = selectIndexPath.item + 1
            
            let lastIndex:NSInteger = selectIndexPath.item - 1
            
            if page > CGFloat(selectIndexPath.item) { // 下一个
                
                if nextIndex < titles.count {
                    
                    let nextRect = itemSliderRects[nextIndex]
                    
                    let spaceScale:CGFloat = page - CGFloat(selectIndexPath.item)
                    
                    if spaceScale <= 0.5 {
                        
                        let nextSpaceW:CGFloat = nextRect.maxX - currentRect.maxX
                        
                        let spaceW:CGFloat = nextSpaceW * min((spaceScale * 2.0), 1.0)
                        
                        sliderView.frame = CGRect(x: currentRect.origin.x, y: currentRect.origin.y, width: currentRect.width + spaceW, height: currentRect.size.height)
                        
                    }else{
                        
                        let totalW:CGFloat = nextRect.maxX - currentRect.minX
                        
                        let nextSpaceW:CGFloat = nextRect.minX - currentRect.minX
                        
                        let spaceW:CGFloat = nextSpaceW * min(((spaceScale - 0.5) * 2.0), 1.0)
                        
                        sliderView.frame = CGRect(x: currentRect.minX + spaceW, y: nextRect.origin.y, width: totalW - spaceW, height: nextRect.size.height)
                    }
                    
                    if page >= CGFloat(nextIndex) {
                        
                        let indexPath = IndexPath(item: nextIndex, section: 0)
                        
                        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                        
                        setSelectIndexPath(indexPath)
                    }
                }
                
            }else{ // 上一个
                
                if lastIndex >= 0 {
                    
                    let lastRect = itemSliderRects[lastIndex]
                    
                    let spaceScale:CGFloat = CGFloat(selectIndexPath.item) - page
                    
                    if spaceScale <= 0.5 {
                        
                        let lastSpaceW:CGFloat = currentRect.minX - lastRect.minX
                        
                        let spaceW:CGFloat = lastSpaceW * min((spaceScale * 2.0), 1.0)
                        
                        sliderView.frame = CGRect(x: currentRect.origin.x - spaceW, y: currentRect.origin.y, width: currentRect.width + spaceW, height: currentRect.size.height)
                    
                    }else{
                        
                        let totalW:CGFloat = currentRect.maxX - lastRect.minX
                        
                        let lastSpaceW:CGFloat = currentRect.maxX - lastRect.maxX
                        
                        let spaceW:CGFloat = lastSpaceW * min(((spaceScale - 0.5) * 2.0), 1.0)
                        
                        sliderView.frame = CGRect(x: lastRect.origin.x, y: lastRect.origin.y, width: totalW - spaceW, height: lastRect.size.height)
                    }
                    
                    if page <= CGFloat(lastIndex) {
                        
                        let indexPath = IndexPath(item: lastIndex, section: 0)
                        
                        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                        
                        setSelectIndexPath(indexPath)
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        registerScrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        
        registerScrollView?.panGestureRecognizer.removeTarget(self, action: #selector(touchPan(_:)))
    }
}

class DZMSegmentedControlItem:UICollectionViewCell {
    
    var itemAttributedText:NSAttributedString?
    
    var itemSelectAttributedText:NSAttributedString?
    
    var isSelect:Bool = false {

        didSet{
            
            if isSelect && itemSelectAttributedText != nil {
                
                label?.attributedText = itemSelectAttributedText
                
            }else{
                
                label?.attributedText = itemAttributedText
            }
        }
    }
    
    var itemInset:UIEdgeInsets = UIEdgeInsets.zero {
        
        didSet{ setNeedsLayout() }
    }
    
    private(set) var label:UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addSubviews()
    }
    
    private func addSubviews() {
        
        label = UILabel()
        
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        label.frame = CGRect(x: itemInset.left, y: itemInset.top, width: frame.size.width - itemInset.left - itemInset.right, height: frame.size.height - itemInset.top - itemInset.bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

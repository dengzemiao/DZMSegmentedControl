//
//  ViewController.swift
//  DZMSegmentedControl
//
//  Created by 邓泽淼 on 2018/5/8.
//  Copyright © 2018年 邓泽淼. All rights reserved.
//

/// RGB
func RGB(_ r:CGFloat,g:CGFloat,b:CGFloat) -> UIColor {
    
    return RGBA(r, g: g, b: b, a: 1.0)
}

/// RGBA
func RGBA(_ r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat) -> UIColor {
    
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,DZMSegmentedControlDelegate {

    let titles = ["新闻","推荐","热点asjdlasjdljaskld","新时代","美女","历史","情感","GIF","搞笑漫画"]
    
    var segmentedControl:DZMSegmentedControl!
    
    var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        /*
         
         1.创建DZMSegmentedControl
         2.(可选) 注册关联滚动控件 segmentedControl.register(collectionView)
         
         */
        
        segmentedControl = DZMSegmentedControl(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: 44))
        segmentedControl.itemAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor:UIColor.black]
        segmentedControl.itemSelectAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15),NSAttributedStringKey.foregroundColor:UIColor.red]
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.yellow
        view.addSubview(segmentedControl)
        
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height - segmentedControl.frame.maxY)
        collectionView = UICollectionView.init(frame: CGRect(x: 0, y: segmentedControl.frame.maxY, width: view.bounds.width, height: view.bounds.height - segmentedControl.frame.maxY), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "TempID")
        view.addSubview(collectionView)
        
        segmentedControl.register(collectionView)
        segmentedControl.reload(titles)
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TempID", for: indexPath)
        
        cell.backgroundColor = RGB(CGFloat(100 + indexPath.item * 15), g: CGFloat(80 + indexPath.item * 18), b: CGFloat(60 + indexPath.item * 8))
        
        return cell
    }
    
    // MARK: DZMSegmentedControlDelegate
    func segmentedControl(segmentedControl: DZMSegmentedControl, clickIndex index: NSInteger) {
        
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
}


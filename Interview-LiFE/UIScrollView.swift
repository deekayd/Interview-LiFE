//
//  UIScrollView.swift
//  Interview-LiFE
//
//  Created by Dmitry Kadyrov on 09/02/2023.
//

import SwiftUI
import UIKit

struct CollectionView: UIViewRepresentable {
    
    let scrollViewInsetY: CGFloat = 100
    let itemCount = 10
    var collectionLoaded: Bool = false
    var uiViewSize: CGSize
    
    var topInset: CGFloat
    var bottomInset: CGFloat
    var viewHeight: CGFloat
    
    var scrollTop: Bool = false
    var scrollPower: Double = 0.0
    
    @Binding var item: Int
    @Binding var showRentalList: Bool
    
    let collectioView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.register(CustomCell.self, forCellWithReuseIdentifier: "myCell")
        return view
    }()
    
    func makeUIView(context: Context) -> UICollectionView {
        collectioView.dataSource = context.coordinator
        collectioView.delegate = context.coordinator
        return collectioView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        // nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, uiViewSize: uiViewSize,
                    uiCollectionView: collectioView,
                    itemCount: itemCount,
                    topInset: topInset,
                    bottomInset: bottomInset,
                    viewHeight: viewHeight,
                    item: $item,
                    showRentalList: $showRentalList,
                    scrollTop: scrollTop,
                    scrollPower: scrollPower)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        var parent: CollectionView
        var uiViewSize: CGSize
        var uiCollectionView: UICollectionView
        var itemCount: Int
        
        var topInset: CGFloat
        var bottomInset: CGFloat
        var viewHeight: CGFloat
        
        var scrollTop: Bool
        var scrollPower: Double
        
        @Binding var item: Int
        @Binding var showRentalList: Bool
        
        var currentIndex = 0
        var previousIndex = 0
        
        init(_ collectionView: CollectionView, uiViewSize: CGSize, uiCollectionView: UICollectionView, itemCount: Int, topInset: CGFloat, bottomInset: CGFloat, viewHeight: CGFloat, item: Binding<Int>, showRentalList: Binding<Bool>, scrollTop: Bool, scrollPower: Double) {
            self.parent = collectionView
            self.uiViewSize = uiViewSize
            self.uiCollectionView = uiCollectionView
            self.itemCount = itemCount
            self.topInset = topInset
            self.bottomInset = bottomInset
            self.viewHeight = viewHeight
            self._item = item
            self._showRentalList = showRentalList
            self.scrollTop = scrollTop
            self.scrollPower = scrollPower
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            print(collectionView.frame.height)
            let topInset = collectionView.frame.width / 2
            let bottomInset = collectionView.frame.width / 2 + self.viewHeight - uiViewSize.height + self.topInset - 18
            collectionView.contentInset.top = topInset
            collectionView.contentInset.bottom = bottomInset
            collectionView.backgroundColor = .white
            let frame: CGSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2)
            return frame
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return itemCount
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? CustomCell else { return UICollectionViewCell() }
            if !parent.collectionLoaded, indexPath.row == 0 {
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                cell.carImage.alpha = 1
                parent.collectionLoaded = true
            } else {
                cell.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                cell.carImage.alpha = 0.5
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            showRentalList.toggle()
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            scrollView.decelerationRate = .normal
            
            parent.scrollPower = velocity.y
            
            let velocity = velocity.y
            var scrollConst: CGFloat
            if velocity > 3 {
                scrollConst = 2
            } else if velocity > 1.2 {
                scrollConst = 1
            } else if velocity < -3 {
                scrollConst = -2
            } else if velocity < -1.2 {
                scrollConst = -1
            } else {
                scrollConst = 0
            }
            
            guard velocity != 0 else { return }
            
            let itemHeight = scrollView.contentSize.height / CGFloat(parent.itemCount)
            let contentInset = uiViewSize.width / 2
            let contentOffset = scrollView.contentOffset.y + contentInset
            let index = contentOffset / itemHeight
            let roundedIndex = velocity > 0 ? index.rounded(.up) : index.rounded(.down)
            
            let offset = (itemHeight * (roundedIndex + scrollConst)) - contentInset
            let itemOffset: CGPoint = CGPoint(x: 0, y: offset)

            targetContentOffset.pointee = itemOffset
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            scrollView.decelerationRate = .normal
            if !decelerate {
                let itemHeight = scrollView.contentSize.height / CGFloat(parent.itemCount)
                let contentInset = uiViewSize.width / 2
                let contentOffset = scrollView.contentOffset.y + contentInset
                let index = contentOffset / itemHeight
                let indexRounded = index.rounded()
                if indexRounded < 0 {
                    let offset = 0 - contentInset
                    let itemOffset: CGPoint = CGPoint(x: 0, y: offset)
                    scrollView.setContentOffset(itemOffset, animated: true)
                } else {
                    let offset = itemHeight * indexRounded - contentInset
                    let itemOffset: CGPoint = CGPoint(x: 0, y: offset)
                    scrollView.setContentOffset(itemOffset, animated: true)
                }
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.contentSize.height > 0 else { return }
            let itemHeight = scrollView.contentSize.height / CGFloat(parent.itemCount)
            let contentInset = uiViewSize.width / 2
            let contentOffset = scrollView.contentOffset.y + contentInset

            let index = (contentOffset / itemHeight).rounded()
            self.parent.item = Int(index)
    
            guard let cell = parent.collectioView.cellForItem(at: IndexPath(item: Int(index), section: 0)) as? CustomCell else { return }
            let scrollPosition = contentOffset + itemHeight - (itemHeight * index)
            let scale = scrollPosition / itemHeight
            
            currentIndex = Int(index)
            if previousIndex != currentIndex {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                currentIndex = Int(index)
                previousIndex = currentIndex
            }
            
            if scale >= 1.25 {
                cell.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                cell.carImage.alpha = 0.5
            } else if scale <= 0.75 {
                cell.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                cell.carImage.alpha = 0.5
            } else if scale > 1 {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) {
                    cell.transform = CGAffineTransform(scaleX: 1+(1-scale), y: 1+(1-scale))
                    cell.carImage.alpha = 1+(1-scale)
                }
            } else {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) {
                    cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                    cell.carImage.alpha = scale
                }
            }
        }
    }
}

class CustomCell: UICollectionViewCell {
    
    fileprivate let carImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "bmw")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    fileprivate let carName: UILabel = {
        let label = UILabel()
        label.text = "BMW M2 Blue edition"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black.withAlphaComponent(0.85)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(carName)
        carName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        
        contentView.addSubview(carImage)
        carImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        carImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        carImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        carImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

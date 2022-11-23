//
//  TabNavigationMenu.swift
//  Pitaza170
//
//  Created by Глеб Фандеев on 20.11.2022.
//

import UIKit

class TabNavigationMenu: UIView {
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [TabItem], frame: CGRect) {
        self.init(frame: frame)
        for idx in 0 ..< menuItems.count {
            let itemWidth = self.frame.width / CGFloat(menuItems.count)
            let leadingAnchor = itemWidth * CGFloat(idx)
            
            let itemView = self.createTabItem(item: menuItems[idx])
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.clipsToBounds = true
            itemView.tag = idx
            
            self.addSubview(itemView)
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalTo: self.heightAnchor),
                itemView.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: leadingAnchor
                ),
                itemView.topAnchor.constraint(equalTo: self.topAnchor),
            ])
        }
        backgroundColor = .myPurple
        subviews.forEach { view in
            view.backgroundColor = .myPurple
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.activateTab(tab: 2) // activate the first tab
    }
    
    // Create a custom nav menu item
    func createTabItem(item: TabItem) -> UIView {
        let tabBarItem = UIView(frame: CGRect.zero)
        let itemTitleLabel = UILabel(frame: CGRect.zero)
        let itemIconView = UIImageView(frame: CGRect.zero)
        itemTitleLabel.text = item.displayTitle
        itemTitleLabel.textAlignment = .center
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.clipsToBounds = true
        
        itemIconView.image = item.icon.withRenderingMode(.automatic)
        itemIconView.translatesAutoresizingMaskIntoConstraints = false
        itemIconView.clipsToBounds = true
        tabBarItem.layer.backgroundColor = UIColor.white.cgColor
        tabBarItem.addSubview(itemIconView)
        tabBarItem.addSubview(itemTitleLabel)
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            itemIconView.heightAnchor.constraint(equalToConstant: 25),
            itemIconView.widthAnchor.constraint(equalToConstant: 25),
            itemIconView.centerXAnchor.constraint(equalTo: tabBarItem.centerXAnchor),
            itemIconView.topAnchor.constraint(equalTo: tabBarItem.topAnchor, constant: 2),
            itemIconView.leadingAnchor.constraint(
                equalTo: tabBarItem.leadingAnchor,
                constant: 35
            ),
            itemTitleLabel.heightAnchor.constraint(equalToConstant: 13),
            itemTitleLabel.widthAnchor.constraint(equalTo: tabBarItem.widthAnchor),
            itemTitleLabel.topAnchor.constraint(
                equalTo: itemIconView.bottomAnchor,
                constant: 4
            )
        ])
        tabBarItem.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.handleTap)
            )
        )
        return tabBarItem
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        self.switchTab(from: self.activeItem, to: sender.view!.tag)
    }
    
    func switchTab(from: Int, to: Int) {
        self.deactivateTab(tab: from)
        self.activateTab(tab: to)
    }
    
    func activateTab(tab: Int) {
        let tabToActivate = self.subviews[tab]
        let borderWidth = tabToActivate.frame.size.width - 20
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.green.cgColor
        borderLayer.name = "active border"
        borderLayer.frame = CGRect(x: 10, y: 0, width: borderWidth, height: 2)
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.8, delay: 0.0,
                options: [.curveEaseIn, .allowUserInteraction],
                animations: {
                    tabToActivate.layer.addSublayer(borderLayer)
                    tabToActivate.setNeedsLayout()
                    tabToActivate.layoutIfNeeded()
                })
            self.itemTapped?(tab)
        }
        self.activeItem = tab
    }
    
    func deactivateTab(tab: Int) {
        let inactiveTab = self.subviews[tab]
        let layersToRemove = inactiveTab.layer.sublayers!.filter {
            $0.name == "active border"
        }
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.4, delay: 0.0,
                options: [.curveEaseIn, .allowUserInteraction],
                animations: {
                    layersToRemove.forEach { $0.removeFromSuperlayer() }
                    inactiveTab.setNeedsLayout()
                    inactiveTab.layoutIfNeeded()
                })
        }
    }
}

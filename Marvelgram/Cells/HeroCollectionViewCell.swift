//
//  HeroCollectionViewCell.swift
//  Marvelgram
//
//  Created by iMac on 22.04.2021.
//

import UIKit

class HeroCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HeroCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    public func configure(with thumbnail: Tnumbnail) {
        
        let imagePath = thumbnail.path + "." + thumbnail.extension
        let urlPath = URL(string: imagePath)!
        
        imageView.sd_setImage(with: urlPath)
    }
}

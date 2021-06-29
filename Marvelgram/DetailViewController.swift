//
//  DetailViewController.swift
//  Marvelgram
//
//  Created by iMac on 23.04.2021.
//

import UIKit
import SDWebImage
import SnapKit

class DetailViewController: UIViewController {
    
    private var  hero: Hero!
    private var exploreHeroes = [Hero]()
    private var heroes = [Hero]()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.layer.masksToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var exploreMoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore more"
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private var collectionView: UICollectionView?
    
    init(hero: Hero, heroes: [Hero]) {
        
        self.hero = hero
        self.heroes = heroes
        self.exploreHeroes = Array(heroes.filter{$0.name != hero.name}
                                    .shuffled()
                                    .prefix(10))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)

        scrollView.addSubview(imageView)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(exploreMoreLabel)

        
        configureCollectionView()
        scrollView.addSubview(collectionView!)
        
        configureAttributes()
    }
    
    //MARK: - Configure
    func configureAttributes() {
        
        let thumbnail = hero.thumbnail
        let imagePath = thumbnail.path + "." + thumbnail.extension
        let urlPath = URL(string: imagePath)!
        
        imageView.sd_setImage(with: urlPath)
        imageView.contentMode = .scaleToFill
        
        descriptionLabel.text = hero.description
        
        title = hero.name
    }
    
    func configureCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 10)
        let size = (view.frame.width / 3) - 5
        layout.itemSize = CGSize(width: size, height: size)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.backgroundColor = .systemBackground
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView?.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: HeroCollectionViewCell.identifier)
    }
    
 
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let sizeWithoutImage = view.height - view.width - view.safeAreaInsets.bottom
        
        //scroll view:-----------------------------------------------------------
        scrollView.snp.makeConstraints { (maker) in
            maker.leading.trailing.width.height.equalToSuperview()
        }
        
        //imageView:-----------------------------------------------------------
        imageView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(scrollView.snp.centerX)
            maker.top.equalTo(scrollView.snp.top)
            maker.width.height.equalTo(view.width)
        }
        
        //descriptionLabel:-----------------------------------------------------------
        descriptionLabel.snp.makeConstraints { (maker) in
            maker.leading.equalTo(scrollView.snp.leading).offset(20)
            maker.top.equalTo(imageView.snp.bottom).offset(10)
            maker.width.equalTo(scrollView.snp.width).offset(-40)
        }
        
        //exploreMoreLabel:-----------------------------------------------------------
        exploreMoreLabel.snp.makeConstraints { (maker) in
            maker.leading.equalTo(scrollView.snp.leading).offset(20)
            maker.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            maker.width.equalTo(scrollView.snp.width).offset(-40)
            maker.height.equalTo(40)
        }
        
        //collectionView:-------------------------------------------------------------
        collectionView!.snp.makeConstraints { (maker) in
            maker.leading.equalTo(scrollView.snp.leading).offset(20)
            maker.top.equalTo(exploreMoreLabel.snp.bottom).offset(5)
            maker.width.equalTo(scrollView.snp.width)
            maker.height.equalTo(sizeWithoutImage / 2.0 - 20)
            maker.bottom.equalTo(scrollView.snp.bottom)
        }
    }
    
    
    private func getExploreHeroes(from heroes: [Hero], without hero: Hero) -> [Hero] {
        
        return Array(heroes.filter{$0.name != hero.name}
                        .shuffled()
                        .prefix(10))
    }
    
}

//MARK: - UICollectionViewDelegate
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exploreHeroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCollectionViewCell.identifier,
                                                      for: indexPath) as! HeroCollectionViewCell
        let exploreHero = exploreHeroes[indexPath.row]
        cell.configure(with: exploreHero.thumbnail)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedHero = exploreHeroes[indexPath.row]
        
        self.hero = selectedHero
        self.exploreHeroes = getExploreHeroes(from: heroes, without: selectedHero)
        
        configureAttributes()
        
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        collectionView.reloadData()
        
    }
    
}

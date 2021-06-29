//
//  ViewController.swift
//  Marvelgram
//
//  Created by iMac on 22.04.2021.
//

import UIKit
import SDWebImage
import Speech
import SnapKit

class MarvelViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var myBackgroundColor: UIColor? = nil
    
    var oppacityCount = 0
    
    let speechVC = SpeechViewController()
    
    private let searchController: UISearchController = {
        let search = UISearchController()
        search.searchBar.placeholder = "Search"
        search.searchBar.backgroundColor = nil
        search.searchBar.showsCancelButton = false
        search.view = nil
        search.searchBar.isHidden = true
        
        let micImage = UIImage(systemName: "mic")
        search.searchBar.setImage(micImage, for: .bookmark, state: .normal)
        search.searchBar.showsBookmarkButton = true

        return search
    }()
    
    lazy var stopRecordImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor?.withAlphaComponent(0)
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.image = UIImage(systemName: "square.circle")
        imageView.tintColor = .label
        imageView.isHidden = true
        imageView.layer.zPosition = 2
        imageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapStopRecord))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
        
        return imageView
    }()

    private var collectionView: UICollectionView?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        spinner.layer.zPosition = 1
        return spinner
    }()
    
    var heroes = [Hero]()
    var nativeHeroes = [Hero]()
    
    
    //MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .label
    
        view.addSubview(stopRecordImageView)
        spinner.startAnimating()
        view.addSubview(spinner)

        configureSearchBar()
        configureCollectionView()
        configureLeftBarButton()
        
        speechVC.requestAuthorization {(isAuthorized) in

            if !isAuthorized {

                print("Not Authorized!")
            }
        }
        
        getHeroes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let yForCV = view.safeAreaInsets.top
        
        collectionView?.snp.makeConstraints({ (maker) in
            maker.leading.equalToSuperview()
            maker.top.equalTo(view.snp_topMargin)
            maker.width.equalToSuperview()
            maker.height.equalTo(view.height - yForCV)
        })
        
        stopRecordImageView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(100)
            maker.center.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(100)
            maker.center.equalToSuperview()
        }
    }
    
    //MARK: - Configure from viewDidLoad
    func configureSearchBar() {
        
        navigationController?.navigationBar.backgroundColor = nil
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    func configureLeftBarButton() {
        
        let leftBarButton = UIBarButtonItem(title: "MARVEL", style: .done, target: self, action: nil)
        leftBarButton.tintColor = .label
        
        leftBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "MarkerFelt-Wide", size: 26)!],
            for: .normal)
        
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func configureCollectionView() {
        
        //обычный стиль картинок - 3 в ряд
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 1
//        layout.minimumInteritemSpacing = 1
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 1)
//        let size = (view.frame.width / 3) - 2
//        layout.itemSize = CGSize(width: size, height: size)
        
        //мозаичный стиль
        let mosaicLayout = MosaicLayout()
        
        collectionView?.layer.zPosition = -1
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: mosaicLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
   
        collectionView?.backgroundColor = .systemBackground
        
        collectionView?.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: HeroCollectionViewCell.identifier)
        
        
        guard let collectionView = collectionView else { return }
        
        view.addSubview(collectionView)
    }
    
    
    @objc func didTapStopRecord() {
  
        speechVC.stopRecording()
        
        stopRecordImageView.isHidden = true
        let micImage = UIImage(systemName: "mic")
        searchController.searchBar.setImage(micImage, for: .bookmark, state: .normal)

        findHeroes(with: searchController.searchBar.text!)
        collectionView?.isUserInteractionEnabled = true
    }
    
    //MARK: - Get heroes from server
    func getHeroes() {
        
        let queue = DispatchQueue.global(qos: .utility)
       
        queue.async { 
            getMarvelHeroes { [weak self] (heroes) in
                self?.heroes = heroes
                self?.nativeHeroes = heroes
                
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.searchController.searchBar.isHidden = false
                    self?.collectionView?.reloadData()
                }
            }
        }
        
    }
}


    //MARK: - UICollectionViewDelegate
extension MarvelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCollectionViewCell.identifier,
                                                      for: indexPath) as! HeroCollectionViewCell
        
        cell.contentView.alpha = 1
        let hero = heroes[indexPath.row]
        cell.configure(with: hero.thumbnail)
        
        if oppacityCount != 0 && indexPath.row >= oppacityCount {
            cell.contentView.alpha = 0.3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let hero = heroes[indexPath.row]
        
        let detailcVC = DetailViewController(hero: hero, heroes: heroes)
        
        navigationController?.pushViewController(detailcVC, animated: true)
    }
}

    //MARK: - UISearchBarDelegate
extension MarvelViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        if !stopRecordImageView.isHidden {
//            searchController.resignFirstResponder()
//        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        findHeroes(with: searchText)
    }
    
    func findHeroes(with name: String) {
        
        heroes = nativeHeroes
        
        let findedHeroes = heroes.filter{ $0.name.contains(name)}
        oppacityCount = findedHeroes.count
 
        heroes.removeAll{$0.name.contains(name)}

        heroes.insert(contentsOf: findedHeroes, at: 0)
        
        collectionView?.reloadData()
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        

        if stopRecordImageView.isHidden {
            
            searchBar.resignFirstResponder()
            searchBar.text = ""
            
            searchController.resignFirstResponder()
            
            stopRecordImageView.isHidden = false
            
            let micImage = UIImage(systemName: "mic.fill")
            searchBar.setImage(micImage, for: .bookmark, state: .normal)
            
            collectionView?.isUserInteractionEnabled = false
            
            view.backgroundColor?.withAlphaComponent(0.3)
            
            speechVC.startRecording { (speechedText) in
                searchBar.text = ""
                searchBar.text = speechedText
            }
            
        } else {
            return
        }

    }
}


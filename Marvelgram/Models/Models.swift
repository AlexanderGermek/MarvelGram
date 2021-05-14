//
//  Models.swift
//  Marvelgram
//
//  Created by iMac on 22.04.2021.
//

import Foundation

struct Hero: Decodable {
    let id: Int
    let name: String
    let description: String
    let modified: String
    let thumbnail: Tnumbnail
}

struct Tnumbnail: Decodable {
    let path: String
    let `extension`: String
}


let marvelAPI = "https://static.upstarts.work/tests/marvelgram/klsZdDg50j2.json"


func getMarvelHeroes(completion: @escaping (_ heroes: [Hero]) -> ()) {
    
    let url = URL(string: marvelAPI)!
    let session = URLSession.shared
    
    session.dataTask(with: url) { (data, response, error) in
        
        if error != nil {
            print("error=\(error!)")
            return
        }
        
        let decoder = JSONDecoder()
        if let data = data, let heroesData = try? decoder.decode([Hero].self, from: data) {
            completion(heroesData)
        }
    }.resume()
}

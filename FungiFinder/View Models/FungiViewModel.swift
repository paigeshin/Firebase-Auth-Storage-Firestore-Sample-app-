//
//  FungiViewModel.swift
//  FungiFinder
//
//  Created by paige on 2022/01/22.
//

struct FungiViewModel {
    let fungi: Fungi
    
    var fungiId: String {
        fungi.id ?? ""
    }
    
    var name: String {
        fungi.name
    }
    
    var photoUrl: String {
        fungi.url
    }
}

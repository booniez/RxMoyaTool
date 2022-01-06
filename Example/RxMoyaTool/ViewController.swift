//
//  ViewController.swift
//  RxMoyaTool
//
//  Created by kled on 01/05/2022.
//  Copyright (c) 2022 kled. All rights reserved.
//

import UIKit
import RxSwift
import RxMoyaTool

class ViewController: UIViewController {
    

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        struct LatestNewsModel: Codable {
            let date: String?
            let stories: [DetailModel]?
            let top_stories: [DetailModel]?
            struct DetailModel: Codable {
                let image_hue: String?
                let title: String?
                let url: String?
                let hint: String?
            }
        }
        
        exampleAPIProvider.request(.latestNews).mapToModel(LatestNewsModel.self, keyPath: "")
            .subscribe(onNext: { result in
                    print(result.date ?? "")
                    print(result.stories?.first?.title ?? "")
                    print(result.stories?.first?.hint ?? "")
                }, onError: { error in
                    if let error = error as? MTMoyaError {
                        print(error.errorMessage)
                    }
                }).disposed(by: disposeBag)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


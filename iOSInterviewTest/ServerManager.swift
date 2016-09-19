//
//  ServerManager.swift
//  iOSInterviewTest
//
//  Created by Yoav Schwartz on 16/09/16.
//  Copyright © 2016 Donkey Republic. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class ServerManager {

    static let sharedInstance = ServerManager()

    func getRepositoriesWithSearchText(text: String) -> Observable<[GithubRepository]> {
        return Observable<[GithubRepository]>.create { (observer) -> Disposable in
            let request =   Alamofire.request(.GET, "https://api.github.com/search/repositories", parameters: ["q": text]).validate().responseJSON { response in
                if let value = response.result.value,
                    let items = value["items"] as? [[String: AnyObject]] {
                    let repos: [GithubRepository] = items.map { GithubRepository(json: $0) }
                    observer.onNext(repos)
                    observer.onCompleted()
                }else if let error = response.result.error {
                    observer.onError(error)
                }
            }
             print(request.debugDescription)
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
}


struct GithubRepository {
    let name: String
    let URLString: String

    init(json: [String: AnyObject]) {
        self.name = json["full_name"] as! String
        self.URLString = json["html_url"] as! String
    }
}

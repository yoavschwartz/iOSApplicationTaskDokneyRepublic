//
//  ViewController.swift
//  iOSInterviewTest
//
//  Created by Yoav Schwartz on 16/09/16.
//  Copyright © 2016 Donkey Republic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UITableViewController {

    @IBOutlet var searchBar: UISearchBar!

    let disposBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        searchBar.rx_text.asObservable()
            .distinctUntilChanged()
            .throttle(0.25, scheduler: MainScheduler.instance)
            .flatMapLatest { text -> Observable<[GithubRepository]> in
                guard !text.isEmpty else { return Observable.just([]) }
                return ServerManager.sharedInstance
                    .getRepositoriesWithSearchText(text).retry(2)
                .catchErrorJustReturn([])
        }.asDriver(onErrorJustReturn: []).drive(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (_, repo: GithubRepository, cell: UITableViewCell) in
            cell.textLabel?.text = repo.name
            cell.detailTextLabel?.text = repo.URLString
        }.addDisposableTo(disposBag)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


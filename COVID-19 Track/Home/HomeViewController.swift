//
//  HomeViewController.swift
//  COVID-19 Track
//
//  Created by George Tsifrikas on 8/3/20.
//  Copyright © 2020 George Tsifrikas. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet weak var enableServiceSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var debugLabel: UITextView!
    
    var viewModel = HomeViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.configure(switchValue: enableServiceSwitch.rx.value.asObservable())
        
        viewModel.readyLabelValue.drive(statusLabel.rx.text).disposed(by: disposeBag)
        viewModel.debug.drive(debugLabel.rx.text).disposed(by: disposeBag)
        viewModel.activityIsSpinning.map(!).drive(activityIndicator.rx.isHidden).disposed(by: disposeBag)
        viewModel.switchValue.drive(enableServiceSwitch.rx.value).disposed(by: disposeBag)
    }
    
}

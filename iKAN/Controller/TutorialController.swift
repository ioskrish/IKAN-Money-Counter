//
//  TutorialController.swift
//  iKAN
//
//  Created by Krishna Panchal on 26/11/23.
//

import UIKit

class TutorialController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var tutorialTV: UITextView!
    @IBOutlet weak var takeMeBtn: UIButton!

    // MARK: Properties

    var delegate: SettingsPresenter?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeMeBtn.layer.cornerRadius = 7

//        if CommandLine.arguments.contains("--iKAN") {
//            // We are in testing mode, make arrangements if needed
//            UIView.setAnimationsEnabled(false)
//        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tutorialTV.flashScrollIndicators()

    }

    // MARK: Helpers

    @IBAction func doneBtnTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.presentSettings()
        }
    }

}

//
//  GlobalSkipPopUpVC.swift
//  SmartExchange
//
//  Created by Sameer Khan on 04/08/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit

class GlobalSkipPopUpVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnRetry: UIButton!
    
    var userConsent : ((_ ind : Int) -> Void)?
    
    var strTitle = ""
    var strMessage = ""
    
    var strBtnYesTitle = ""
    var strBtnNoTitle = ""
    var strBtnRetryTitle = ""
    
    var isShowThirdBtn = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTitle.text = self.strTitle
        self.lblMessage.text = self.strMessage
        
        self.btnYes.setTitle(self.strBtnYesTitle, for: .normal)
        self.btnNo.setTitle(self.strBtnNoTitle, for: .normal)
        self.btnRetry.setTitle(self.strBtnRetryTitle, for: .normal)

        self.btnRetry.isHidden = !self.isShowThirdBtn
        
        self.btnYes.tag = 1
        self.btnNo.tag = 2
        self.btnRetry.tag = 3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    //MARK: IBAction
    @IBAction func yesButtonClicked(sender: UIButton) {
        
        //guard let userAction = self.userConsent else { return }
        //userAction(sender.tag)
        //self.dismiss(animated: false, completion: nil)

        self.dismiss(animated: false) {
            guard let userAction = self.userConsent else { return }
            userAction(sender.tag)
        }
        
    }
    
    @IBAction func noButtonClicked(sender: UIButton) {
        
        self.dismiss(animated: false) {
            guard let userAction = self.userConsent else { return }
            userAction(sender.tag)
        }
        
    }
    
    
    @IBAction func retryButtonClicked(sender: UIButton) {
        
        self.dismiss(animated: false) {
            guard let userAction = self.userConsent else { return }
            userAction(sender.tag)
        }
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

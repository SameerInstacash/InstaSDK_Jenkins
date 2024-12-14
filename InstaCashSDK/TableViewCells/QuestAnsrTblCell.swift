//
//  QuestAnsrTblCell.swift
//  SmartExchange
//
//  Created by Sameer Khan on 19/12/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit

class QuestAnsrTblCell: UITableViewCell {
    
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var lblSeperator: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

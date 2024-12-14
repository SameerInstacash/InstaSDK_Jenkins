//
//  TestResultCell.swift
//  IC Warehouse
//
//  Created by Sameer Khan on 19/09/23.
//

import UIKit

class TestResultCell: UITableViewCell {
    
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var lblTestRetry: UILabel!
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

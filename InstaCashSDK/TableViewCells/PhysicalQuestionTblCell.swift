//
//  PhysicalQuestionTblCell.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 01/03/25.
//

import UIKit

class PhysicalQuestionTblCell: UITableViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var collectionViewQuestionAnswer: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionViewQuestionAnswer.register(UINib.init(nibName: "PhysicalQuestionCollectionVWCell", bundle: nil), forCellWithReuseIdentifier: "PhysicalQuestionCollectionVWCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

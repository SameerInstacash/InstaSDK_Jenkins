//
//  PhysicalQuestionCollectionVWCell.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 01/03/25.
//

import UIKit

class PhysicalQuestionCollectionVWCell: UICollectionViewCell {
    
    @IBOutlet weak var circleImgVW: UIImageView!
    @IBOutlet weak var lblAnswer: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleImgVW.layer.cornerRadius = circleImgVW.bounds.width/2
        
    }

}

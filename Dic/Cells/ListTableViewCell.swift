//
//  ListTableViewCell.swift
//  Dic
//
//  Created by Alper Ban on 30.05.2023.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var partOfSpeechLabel: UILabel!
    @IBOutlet weak var definitionsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        definitionsLabel.text = nil
                exampleLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}

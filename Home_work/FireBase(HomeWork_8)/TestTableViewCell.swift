//
//  TestTableViewCell.swift
//  FireBase(HomeWork_8)
//
//  Created by Сергей Чумовских  on 19.10.2021.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    static let reusedIdentifire = "TestTableViewCell"
    
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        numberLabel.text = nil
    }
    
    func configure(testModel: FireBaseTestModel) {
        nameLabel.text = testModel.name
        numberLabel.text = "\(testModel.number)"
    }
    
    
}

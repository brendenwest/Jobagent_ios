//
//  DatePickerCell.swift
//  jobagent
//
//  Created by Brenden West on 7/7/17.
//
//

import UIKit

protocol DatePickerCellDelegate: class {
    func dateChangedForField(field: ModelFieldType, toDate date: Date)
}

class DatePickerCell: UITableViewCell {
    // outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // data
    var field: ModelFieldType!
    weak var delegate: DatePickerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithField(field: ModelFieldType, currentDate: Date?) {
        self.field = field
        self.datePicker.date = currentDate ?? Date()
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        self.delegate?.dateChangedForField(field: field, toDate: datePicker.date)
    }
}

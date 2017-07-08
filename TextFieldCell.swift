//
//  TextFieldCell.swift
//  jobagent
//
//  Created by Brenden West on 7/6/17.
//
//

protocol TextFieldTableViewCellDelegate: class {
    func fieldDidBeginEditing(field: ModelFieldType)
    func field(field: ModelFieldType, changedValueTo value: String)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    // outlets
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueTextfield: UITextField!
    
    // data
    var field: ModelFieldType!
    weak var delegate: TextFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fieldValueTextfield.delegate = self
    }
    
    func configureWithField(field: ModelFieldType, andValue value: String?) {
        self.field = field
        self.fieldNameLabel.text = field.localized 
        self.fieldValueTextfield.text = value ?? ""
        
        if field.isEditable {
            self.fieldValueTextfield.isUserInteractionEnabled = true
            self.selectionStyle = .none
            self.fieldValueTextfield.returnKeyType = UIReturnKeyType.done;
            if field == .phone {
                self.fieldValueTextfield.keyboardType = UIKeyboardType.phonePad
            } else if field == .email {
                self.fieldValueTextfield.keyboardType = UIKeyboardType.emailAddress
            }
            
        } else {
            self.fieldValueTextfield.isUserInteractionEnabled = false
            if field.hasDisclosure {
                self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            self.selectionStyle = .default
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.fieldDidBeginEditing(field: field)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.delegate?.field(field: field, changedValueTo: textField.text!)
    }
}

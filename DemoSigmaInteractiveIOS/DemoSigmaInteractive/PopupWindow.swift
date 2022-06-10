//
//  PopupWindow.swift
//  DemoSigmaInteractive
//
//  Created by Pham Hai on 09/06/2022.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

class ListFieldType {
    enum ListType: String {
        case boolean
        case number
        case string
    }
    enum ListBoolean: String {
        case yes = "true"
        case no = "false"
    }
    enum ListChannel: String {
        case vtv1, vtv2, vtv3, vtv4
    }
}

class PopUpWindow: UIViewController {
    private let popUpWindowView = PopUpWindowView()
    var callback: (ListFieldType.ListType) -> Void
    init(title: String, text: String, buttontext: String, buttonTextCancel: String, callback: @escaping (ListFieldType.ListType) -> Void, selectedType: ListFieldType.ListType) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        popUpWindowView.selectedType = selectedType
        popUpWindowView.listSelectType.selectedSegmentIndex = selectedType == .string ? 0 : selectedType == .boolean ? 1 : 2;
        popUpWindowView.popupTitle.text = title
        popUpWindowView.popupButton.setTitle(buttontext, for: .normal)
        popUpWindowView.popupButton.addTarget(self, action: #selector(onOk), for: .touchUpInside)
        popUpWindowView.popupButtonCancel.setTitle(buttonTextCancel, for: .normal)
        popUpWindowView.popupButtonCancel.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view = popUpWindowView
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func onOk(){
        dismissView()
        self.callback(popUpWindowView.selectedType)
    }
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }

}

private class PopUpWindowView: UIView {
    
    let popupView = UIView(frame: CGRect.zero)
    let popupTitle = UILabel(frame: CGRect.zero)
    let popupText = UIView(frame: CGRect.zero)
    let popupButton = UIButton(frame: CGRect.zero)
    let popupButtonCancel = UIButton(frame: CGRect.zero)
    let listFieldType = UIPickerView(frame: CGRect.zero)
    var pickerData: [String] = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
    let listSelectType = UISegmentedControl(frame: CGRect(x: 0, y: 11, width: 260, height: 50))
    let BorderWidth: CGFloat = 2.0
    var selectedType = ListFieldType.ListType.string
    
    init() {
        super.init(frame: CGRect.zero)
        // Semi-transparent background
        listSelectType.insertSegment(withTitle: ListFieldType.ListType.string.rawValue, at: 0, animated: true)
        listSelectType.insertSegment(withTitle: ListFieldType.ListType.boolean.rawValue, at: 1, animated: true)
        listSelectType.insertSegment(withTitle: ListFieldType.ListType.number.rawValue, at: 2, animated: true)
        listSelectType.layer.borderWidth = 1;
        listSelectType.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        listSelectType.isUserInteractionEnabled = true
        listSelectType.selectedSegmentIndex = selectedType == .string ? 0 : selectedType == .boolean ? 1 : 2;
        listSelectType.selectedSegmentTintColor = UIColor.green
        listSelectType.addTarget(self, action: #selector(onTapSegment(_:)), for: .valueChanged)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Popup Background
        popupView.backgroundColor = UIColor(hexString:"#FFFFFF")
        popupView.layer.borderWidth = BorderWidth
        popupView.layer.masksToBounds = true
        popupView.layer.borderColor = UIColor.white.cgColor
        
        // Popup Title
        popupTitle.textColor = UIColor.black
        popupTitle.backgroundColor = UIColor(hexString: "#DDDDDD")
        popupTitle.layer.masksToBounds = true
        popupTitle.adjustsFontSizeToFitWidth = true
        popupTitle.clipsToBounds = true
        popupTitle.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
        popupTitle.numberOfLines = 1
        popupTitle.textAlignment = .center
        
        // Popup Text
        popupText.backgroundColor = UIColor.white
        //select type
        popupText.addSubview(listSelectType)
        
        // Popup Button
        popupButton.setTitleColor(UIColor.white, for: .normal)
        popupButton.titleLabel?.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
        popupButton.backgroundColor = UIColor(hexString: "#0000FF")
        
        popupButtonCancel.setTitleColor(UIColor.white, for: .normal)
        popupButtonCancel.titleLabel?.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
        popupButtonCancel.backgroundColor = UIColor(hexString: "#FF0000")
        
        popupView.addSubview(popupTitle)
//        popupView.addSubview(popupText)
        popupView.addSubview(popupText)
        popupView.addSubview(popupButton)
//        popupView.addSubview(popupButtonCancel)
        
        // Add the popupView(box) in the PopUpWindowView (semi-transparent background)
        addSubview(popupView)
        
        
        // PopupView constraints
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.widthAnchor.constraint(equalToConstant: 293),
            popupView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            popupView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
        
        // PopupTitle constraints
        popupTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupTitle.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: BorderWidth),
            popupTitle.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -BorderWidth),
            popupTitle.topAnchor.constraint(equalTo: popupView.topAnchor, constant: BorderWidth),
            popupTitle.heightAnchor.constraint(equalToConstant: 55)
            ])
        
        
        // PopupText constraints
        popupText.isUserInteractionEnabled = true
        popupText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupText.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            popupText.topAnchor.constraint(equalTo: popupTitle.bottomAnchor, constant: 8),
            popupText.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 15),
            popupText.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -15),
            popupText.bottomAnchor.constraint(equalTo: popupButton.topAnchor, constant: -8)
            ])

        
        // PopupButton constraints
        popupButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupButton.heightAnchor.constraint(equalToConstant: 44),
            popupButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: BorderWidth),
            popupButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -BorderWidth),
            popupButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -BorderWidth)
            ])
        
        
//        popupButtonCancel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            popupButtonCancel.heightAnchor.constraint(equalToConstant: 44),
//            popupButtonCancel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: BorderWidth),
//            popupButtonCancel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -BorderWidth),
//            popupButtonCancel.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -BorderWidth)
//            ])
        
    }
    @objc func onTapSegment(_ sender: UISegmentedControl) {
        print("onTapSegment", sender.selectedSegmentIndex)
            switch sender.selectedSegmentIndex {
            case 0:
                print("Segment 0 is selected")
                selectedType = ListFieldType.ListType.string
            case 1:
                print("Segment 1 is selected")
                selectedType = ListFieldType.ListType.boolean
            case 2:
                print("Segment 2 is selected")
                selectedType = ListFieldType.ListType.number
            default:
                break
            }
        }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

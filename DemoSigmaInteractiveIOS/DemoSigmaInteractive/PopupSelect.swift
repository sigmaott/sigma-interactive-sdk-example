//
//  PopupSelect.swift
//  DemoSigmaInteractive
//
//  Created by Pham Hai on 10/06/2022.
//

import Foundation
import UIKit


class PopUpWindowSelect: UIViewController {
    private let popUpWindowView = PopUpWindowSelectView()
    var callback: (ListFieldType.ListChannel) -> Void
    init(title: String, text: String, buttontext: String, buttonTextCancel: String, callback: @escaping (ListFieldType.ListChannel) -> Void, selectedChannel: ListFieldType.ListChannel) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        print("selectedChannel=>", selectedChannel)
        popUpWindowView.selectedChannel = selectedChannel
        popUpWindowView.listChannel.selectRow(selectedChannel == .vtv1 ? 0 : selectedChannel == .vtv2 ? 1 : selectedChannel == .vtv3 ? 2 : 3, inComponent: 0, animated: true);
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
        print("selectedChannel=>", popUpWindowView.listChannel.selectedRow(inComponent: 0))
        dismissView()
        let selectedIndex = popUpWindowView.listChannel.selectedRow(inComponent: 0)
        switch(selectedIndex) {
            case 0:
                self.callback(ListFieldType.ListChannel.vtv1)
                break;
            case 1:
                self.callback(ListFieldType.ListChannel.vtv2)
                break;
            case 2:
                self.callback(ListFieldType.ListChannel.vtv3)
                break;
            case 3:
                self.callback(ListFieldType.ListChannel.vtv4)
                break;
            default: break;
        }
    }
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }

}

private class PopUpWindowSelectView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    let popupView = UIView(frame: CGRect.zero)
    let popupTitle = UILabel(frame: CGRect.zero)
    let popupText = UIView(frame: CGRect.zero)
    let popupButton = UIButton(frame: CGRect.zero)
    let popupButtonCancel = UIButton(frame: CGRect.zero)
    let listChannel = UIPickerView(frame: CGRect(x: 0, y: 0, width: 260, height: 200))
    var pickerData: [String] = [
        ListFieldType.ListChannel.vtv1.rawValue,
        ListFieldType.ListChannel.vtv2.rawValue,
        ListFieldType.ListChannel.vtv3.rawValue,
        ListFieldType.ListChannel.vtv4.rawValue,
    ]
    let BorderWidth: CGFloat = 2.0
    var selectedChannel = ListFieldType.ListChannel.vtv1
    
    init() {
        super.init(frame: CGRect.zero)
        listChannel.delegate = self
        listChannel.dataSource = self
        listChannel.selectRow(selectedChannel == .vtv1 ? 0 : selectedChannel == .vtv2 ? 1 : selectedChannel == .vtv3 ? 2 : 3, inComponent: 0, animated: false)
        // Semi-transparent background
        
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
        popupText.addSubview(listChannel)
        
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
            popupText.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = pickerData[row]
        return row
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    @objc func onTapSegment(_ sender: UISegmentedControl) {
        print("onTapSegment", sender.selectedSegmentIndex)
            switch sender.selectedSegmentIndex {
            case 0:
                print("Segment 0 is selected")
                selectedChannel = ListFieldType.ListChannel.vtv1
            case 1:
                print("Segment 1 is selected")
                selectedChannel = ListFieldType.ListChannel.vtv2
            case 2:
                print("Segment 2 is selected")
                selectedChannel = ListFieldType.ListChannel.vtv3
            case 3:
                print("Segment 3 is selected")
                selectedChannel = ListFieldType.ListChannel.vtv4
            default:
                break
            }
        }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

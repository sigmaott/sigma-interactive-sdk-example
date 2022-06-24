//
//  ViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 30/03/2022.
//

import UIKit
import CryptoKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView =  false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

let baseUrlChannel = "https://dev-livestream.gviet.vn/manifest/"

let dataChannel:[String: String] = [
    ListFieldType.ListChannel.vtv1.rawValue: baseUrlChannel + "VTV1-PACKAGE/master.m3u8",
    ListFieldType.ListChannel.vtv2.rawValue: baseUrlChannel + "VTV2-PACKAGE/master.m3u8",
    ListFieldType.ListChannel.vtv3.rawValue: baseUrlChannel + "VTV3-PACKAGE/master.m3u8",
    ListFieldType.ListChannel.vtv4.rawValue: baseUrlChannel + "VTV4/master.m3u8"]

let dataChannelId:[String: String] = [
    ListFieldType.ListChannel.vtv1.rawValue: "c9c2ebfb-2887-4de6-aec4-0a30aa848915",
    ListFieldType.ListChannel.vtv2.rawValue: "32a55ed3-4ee1-42f8-819a-407b54a39923",
    ListFieldType.ListChannel.vtv3.rawValue: "60346597-8ed9-48de-bd4d-8546d0070c7c",
    ListFieldType.ListChannel.vtv4.rawValue: "22e1fdb6-8d10-4193-8411-562c7104aa2b"]

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtInteractiveLink: UITextView!
    @IBOutlet weak var txtVideoUrl: UITextView!
    @IBOutlet weak var btnOpenInteractive: UIButton!
    @IBOutlet weak var btnOpenWithOldConfig: UIButton!
    @IBOutlet weak var txtError: UILabel!
    @IBOutlet weak var txtUid: UITextView!
    @IBOutlet weak var viewUserData: UIView!
    @IBOutlet weak var btnAddFieldUserData: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var listUserType: UISegmentedControl!
    @IBOutlet weak var btnGetChannel: UIButton!
    
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    var typeField = ListFieldType.ListType.string
    var channel = ListFieldType.ListChannel.vtv1
    let txtBorderColor: CGColor = UIColor.gray.cgColor;
    let txtBorderRadius: CGFloat = 5.0, txtBorderWidth:CGFloat = 1.0;
    let fieldKeyId = "key-"
    let fieldValueId = "value-"
    let fieldUserValueContainer = "user-"
    var userDataValue: [[String: Any]] = []
    let heightOfBtnDeleteField = 40.0
    let widthOfBtnDeleteField = 100.0
    let heightOfInPutField = 50.0
    let heightOfLabelField = 50.0
    let heightOfPaddingOfBottomField = 10.0
    let paddingInput = 5.0
    var heightOfFieldUserValue = 150.0
    
    override func viewDidLoad() {
        heightOfFieldUserValue = heightOfLabelField + heightOfInPutField + heightOfBtnDeleteField + heightOfPaddingOfBottomField;
        txtInteractiveLink.layer.borderWidth = txtBorderWidth;
        txtInteractiveLink.layer.borderColor = txtBorderColor;
        txtInteractiveLink.layer.cornerRadius = txtBorderRadius;
        txtVideoUrl.layer.borderWidth = txtBorderWidth;
        txtVideoUrl.layer.borderColor = txtBorderColor;
        txtVideoUrl.layer.cornerRadius = txtBorderRadius;
        txtVideoUrl.text = dataChannel[channel.rawValue]
        txtUid.layer.borderWidth = txtBorderWidth;
        txtUid.layer.borderColor = txtBorderColor;
        txtUid.layer.cornerRadius = txtBorderRadius;
        txtUid.textContainerInset = UIEdgeInsets(top: 15, left: 4, bottom: 8, right: 4);
        let tokenCache = getTokenCache()
        let idCache = getIdCache()
        let roleCache = getRoleCache()
        if(tokenCache.count > 0 && idCache.count > 0 && roleCache.count > 0) {
            txtUid.text = idCache
//            btnOpenWithOldConfig.isEnabled = true;
//            btnOpenWithOldConfig.isHidden = false;
            listUserType.selectedSegmentIndex = getIndexUserRole(roleCache)
        } else {
//            btnOpenWithOldConfig.isEnabled = false;
//            btnOpenWithOldConfig.isHidden = true;
        }
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard));

       //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
       //tap.cancelsTouchesInView = false

       view.addGestureRecognizer(tap)
        scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.view.bounds.height + 100);
    }
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        // safe area values are now available to use
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       AppUtility.lockOrientation(.portrait)
       
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       AppUtility.lockOrientation(.all)
   }
    func getTokenCache() -> String {
        let defaults = UserDefaults.standard
        if let tokenCache = defaults.string(forKey: DefaultsKeysUser.token) {
            print("dataSession=>2", tokenCache)
            return tokenCache
        }
        return ""
    }
    func getRoleCache() -> String {
        let defaults = UserDefaults.standard
        if let roleCache = defaults.string(forKey: DefaultsKeysUser.userRole) {
            print("roleCache=>2", roleCache)
            return roleCache
        }
        return ""
    }
    func getIdCache() -> String {
        let defaults = UserDefaults.standard
        if let idCache = defaults.string(forKey: DefaultsKeysUser.userId) {
            print("idCache=>2", idCache)
            return idCache
        }
        return ""
    }
    func getUserDataCache() -> [String: Any] {
        let defaults = UserDefaults.standard
        if let userDataCache = defaults.dictionary(forKey: DefaultsKeysUser.userData) {
            print("userDataCache=>2", userDataCache)
            return userDataCache
        }
        return [:]
    }
    @IBAction func openInteractiveWithOldConfig(_ sender: Any) {
        print("open interactive=>", txtUid.isAccessibilityElement);
        for itemFieldUser in userDataValue {
            print("itemFieldUser=>", itemFieldUser)
        }
        let uidCache = getIdCache()
        let roleCache = getRoleCache()
        let userDataCache = getUserDataCache()
        let token = getTokenCache()
        let interactiveLink = txtInteractiveLink.text!, videoUrl = txtVideoUrl.text!;
        let isEmptyInteractive = interactiveLink.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || (!interactiveLink.hasPrefix("http://") && !interactiveLink.hasPrefix("https://"));
        let isEmptyVideoUrl = videoUrl.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || (!videoUrl.hasPrefix("http://") && !videoUrl.hasPrefix("https://"));
        if(isEmptyInteractive || isEmptyVideoUrl) {
            txtError.text = "Lỗi nhập " + (isEmptyInteractive ? "link interactive" : "link video");
        } else {
            txtError.text = "";
            self.view.endEditing(true);
            let story = UIStoryboard(name: "Main", bundle: nil);
            let controller = story.instantiateViewController(withIdentifier: "demoPlayer") as! PlayerViewController;
//            let ViewController = ViewController(nibName: "PlayerViewController", bundle: nil);
            controller.interactiveLink = interactiveLink;
            controller.videoUrl = videoUrl;
            controller.bottomSafeArea = bottomSafeArea;
            controller.topSafeArea = topSafeArea
            controller.tokenApp = token
            controller.userRole = roleCache
            controller.uid = uidCache
            controller.userData = userDataCache
            controller.channelId = dataChannelId[channel.rawValue]!
            self.navigationController?.pushViewController(controller, animated: true);
//            self.present(controller, animated: true, completion: nil);
        }
    }
    @IBAction func openInteractive(_ sender: UIButton) {
        print("open interactive=>", txtUid.isAccessibilityElement);
        for itemFieldUser in userDataValue {
            print("itemFieldUser=>", itemFieldUser)
        }
        let token = getToken()
        let interactiveLink = txtInteractiveLink.text!, videoUrl = txtVideoUrl.text!;
        let isEmptyInteractive = interactiveLink.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || (!interactiveLink.hasPrefix("http://") && !interactiveLink.hasPrefix("https://"));
        let isEmptyVideoUrl = videoUrl.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 || (!videoUrl.hasPrefix("http://") && !videoUrl.hasPrefix("https://"));
        if(isEmptyInteractive || isEmptyVideoUrl) {
            txtError.text = "Lỗi nhập " + (isEmptyInteractive ? "link interactive" : "link video");
        } else {
            txtError.text = "";
            self.view.endEditing(true);
            let story = UIStoryboard(name: "Main", bundle: nil);
            let controller = story.instantiateViewController(withIdentifier: "demoPlayer") as! PlayerViewController;
//            let ViewController = ViewController(nibName: "PlayerViewController", bundle: nil);
            controller.interactiveLink = interactiveLink;
            controller.videoUrl = videoUrl;
            controller.bottomSafeArea = bottomSafeArea;
            controller.topSafeArea = topSafeArea
            controller.tokenApp = token
            controller.userRole = getUserRole()
            controller.uid = getUid()
            controller.userData = getUserData()
            controller.channelId = dataChannelId[channel.rawValue]!
            self.navigationController?.pushViewController(controller, animated: true);
//            self.present(controller, animated: true, completion: nil);
        }
    }
    func getUserRole() -> String {
        let selectedRoleIndex = listUserType.selectedSegmentIndex
        var userRole = "admin"
        switch(selectedRoleIndex) {
            case 0:
                break;
            case 1:
                userRole = "user"
                break;
            case 2:
                userRole = "guest"
                break;
            default: break
        }
        return userRole
    }
    func getIndexUserRole(_ role: String) -> Int {
        let selectedRoleIndex = listUserType.selectedSegmentIndex
        var indexRole = 0
        switch(role) {
            case "admin":
              indexRole = 0
              break;
            case "user":
              indexRole = 1
              break;
            case "guest":
              indexRole = 2
              break;
            default: break
        }
        return indexRole
    }
    func getUid() -> String {
        return txtUid.text!;
    }
    func getUserData() -> [String: Any] {
        var formatUserData:[String: Any] = [:]
        for itemFieldUser in userDataValue {
            let keyData: String = itemFieldUser["key"] as! String ?? ""
            let valueData: Any = itemFieldUser["value"]
            let typeData: String = itemFieldUser["type"] as! String ?? ""
            if(keyData.count > 0 && typeData.count > 0) {
                switch(typeData) {
                case ListFieldType.ListType.boolean.rawValue:
                    formatUserData[keyData] = valueData
                    break;
                case ListFieldType.ListType.number.rawValue:
                    formatUserData[keyData] = (valueData as! NSString).integerValue
                    break;
                default:
                    formatUserData[keyData] = valueData
                    break;
                }
            }
        }
        return formatUserData
    }
    func getToken() -> String {
        var dataGetToken:[String: Any] = [:]
        dataGetToken["id"] = getUid()
        dataGetToken["role"] = getUserRole()
        dataGetToken["appId"] = "default-app"
        if(getUserRole() == "guest") {
            let defaults = UserDefaults.standard
            defaults.set("", forKey: DefaultsKeysUser.token)
        }
        return getUserRole() == "guest" ? "" : GenerateToken(getUid(), getUserData(), getUserRole()).genTokenFromApi()
    }
    @objc func deleteUserValueField(_ sender: UIButton?) {
        print("delete=>", sender?.tag)
        var subviewDelete:UIView
        var indexRemove = 0
        var isRemove = false
        for subview in self.viewUserData.subviews {
            print("subviewTag=>", subview.tag)
            if(subview.tag == sender?.tag) {
                isRemove = true
                subviewDelete = subview
                subview.removeFromSuperview()
                self.viewUserData.frame = CGRect(x: self.viewUserData.frame.origin.x, y: self.viewUserData.frame.origin.y, width: self.viewUserData.frame.width, height: max(50, self.viewUserData.frame.height - heightOfFieldUserValue))
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height - heightOfFieldUserValue)
                
                btnAddFieldUserData.frame = CGRect(x: btnAddFieldUserData.frame.origin.x, y: self.viewUserData.frame.origin.y + self.viewUserData.frame.height + 10, width: btnAddFieldUserData.bounds.width, height: btnAddFieldUserData.bounds.height)
            } else if(subview.tag > sender!.tag) {
                subview.frame = CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y - heightOfFieldUserValue, width: subview.frame.width, height: subview.frame.height)
            }
            if(!isRemove) {
                indexRemove += 1
            }
        }
        print("indexRemove=>", indexRemove)
        userDataValue.remove(at: indexRemove)
    }
    func getViewFieldUser(positionY y: Double) -> UIView {
        let keyTag = Date().millisecondsSince1970
        let btnDelete:UIButton = UIButton(frame: CGRect(x: (self.viewUserData.frame.width / 2.0) - (widthOfBtnDeleteField/2), y: heightOfLabelField + heightOfInPutField + heightOfPaddingOfBottomField, width: widthOfBtnDeleteField, height: heightOfBtnDeleteField))
        btnDelete.isAccessibilityElement = true
        btnDelete.backgroundColor = UIColor.red
        btnDelete.setTitle("Remove", for: .normal)
        btnDelete.setTitleColor(UIColor.white, for: .normal)
        btnDelete.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        btnDelete.layer.cornerRadius = 5
        
        let allSubviews = viewUserData.subviews.count;
        btnDelete.accessibilityIdentifier = "btnDelete-" + String(allSubviews)
        btnDelete.tag = Int(keyTag)
        btnDelete.addTarget(self, action: #selector(deleteUserValueField), for: UIButton.Event.touchUpInside)
        let fieldUserView: UIView = UIView(frame: CGRect(x: 0, y: y, width: self.viewUserData.frame.width, height: Double(heightOfFieldUserValue)));
        //for key view
        let fieldUserKeyView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Double(self.viewUserData.frame.width/2), height: Double(heightOfInPutField + heightOfLabelField)));
        let labelKey: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewUserData.frame.width/2.0, height: heightOfLabelField));
        labelKey.text = "Key";
        let uiTextViewKey: UITextView = UITextView(frame: CGRect(x: 0, y: heightOfInPutField, width: self.viewUserData.frame.width/2.0 - paddingInput, height: heightOfInPutField));
        uiTextViewKey.layer.borderWidth = txtBorderWidth;
        uiTextViewKey.layer.borderColor = txtBorderColor;
        uiTextViewKey.layer.cornerRadius = txtBorderRadius;
        uiTextViewKey.isAccessibilityElement = true
        uiTextViewKey.delegate = self
        uiTextViewKey.accessibilityIdentifier = fieldKeyId + String(keyTag)
        fieldUserKeyView.addSubview(labelKey);
        fieldUserKeyView.addSubview(uiTextViewKey);
        fieldUserView.addSubview(fieldUserKeyView)
        //for value view
        let fieldUserValueView: UIView = UIView(frame: CGRect(x: Double(self.viewUserData.frame.width / 2), y: 0, width: Double( self.viewUserData.frame.width/2), height: Double(heightOfLabelField + heightOfInPutField)));
        let labelValue: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewUserData.frame.width/2.0, height: heightOfLabelField));
        labelValue.text = "Value";
        fieldUserValueView.addSubview(labelValue);
        switch(typeField) {
            case .number, .string:
                //for value view
            let uiTextViewValue: UITextView = UITextView(frame: CGRect(x: 0, y: heightOfInPutField, width: self.viewUserData.frame.width/2.0, height: heightOfInPutField));
                uiTextViewValue.layer.borderWidth = txtBorderWidth;
                uiTextViewValue.layer.borderColor = txtBorderColor;
                uiTextViewValue.layer.cornerRadius = txtBorderRadius;
                uiTextViewValue.isAccessibilityElement = true
                uiTextViewValue.accessibilityIdentifier = fieldValueId + String(keyTag)
                uiTextViewValue.delegate = self
                fieldUserValueView.addSubview(uiTextViewValue);
                fieldUserView.addSubview(fieldUserValueView)
                userDataValue.append(["key": "", "value": "", "type": typeField.rawValue, "tag": String(keyTag)])
                break;
            case .boolean:
            let listSelectBoolean: UISegmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: heightOfInPutField, width: self.viewUserData.frame.width/2.0, height: heightOfInPutField));
                listSelectBoolean.insertSegment(withTitle: ListFieldType.ListBoolean.yes.rawValue, at: 0, animated: true)
                listSelectBoolean.insertSegment(withTitle: ListFieldType.ListBoolean.no.rawValue, at: 1, animated: true)
                listSelectBoolean.layer.borderWidth = 1;
                listSelectBoolean.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                listSelectBoolean.isUserInteractionEnabled = true
                listSelectBoolean.selectedSegmentIndex = 0
                listSelectBoolean.selectedSegmentTintColor = UIColor.green
                listSelectBoolean.isAccessibilityElement = true
                listSelectBoolean.accessibilityIdentifier = fieldValueId + String(keyTag)
                listSelectBoolean.addTarget(self, action: #selector(onTapSegment(_:)), for: .valueChanged)
                listSelectBoolean.tag = Int(keyTag)
                print("fieldValueId=>", listSelectBoolean.accessibilityIdentifier)
                fieldUserValueView.addSubview(listSelectBoolean);
                fieldUserView.addSubview(fieldUserValueView)
                userDataValue.append(["key": "", "value": true, "type": typeField.rawValue, "tag": String(keyTag)])
                break;
            default: break
        }
        fieldUserView.addSubview(btnDelete)
        fieldUserView.isAccessibilityElement = true
        fieldUserView.accessibilityIdentifier = fieldUserValueContainer + String(keyTag)
        fieldUserView.tag = Int(keyTag)
        return fieldUserView;
    }
    @objc func onTapSegment(_ sender: UISegmentedControl) {
        print("onTapSegment", sender.selectedSegmentIndex)
        let arrKey = sender.accessibilityIdentifier!.components(separatedBy: "-")
        print("arrKey", arrKey)
        if arrKey.count == 2 {
            let index: String = arrKey[1]
            let keySet: String = arrKey[0]
            var indexNumber = 0
            var isIndexChange = false
            for itemUserField in userDataValue {
                if(itemUserField["tag"] as! String == index) {
                    isIndexChange = true
                }
                if(!isIndexChange) {
                    indexNumber += 1
                }
            }
            print("indexNumber=>", indexNumber)
            userDataValue[indexNumber][keySet] = sender.selectedSegmentIndex == 0
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange=>", textView.accessibilityIdentifier!, textView.text)
        let arrKey = textView.accessibilityIdentifier!.components(separatedBy: "-")
        print("arrKey", arrKey)
        if arrKey.count == 2 {
            let index: String = arrKey[1]
            let keySet: String = arrKey[0]
            var indexNumber = 0
            var isIndexChange = false
            for itemUserField in userDataValue {
                if(itemUserField["tag"] as! String == index) {
                    isIndexChange = true
                }
                if(!isIndexChange) {
                    indexNumber += 1
                }
            }
            print("indexNumber=>", indexNumber)
            userDataValue[indexNumber][keySet] = textView.text!
        }
    }
    func setTypeField(fieldType type: ListFieldType.ListType) {
        typeField = type
        print("typeField=>", typeField);
        let allSubviews = viewUserData.subviews.count;
        print("allSubviews=>", allSubviews);
        switch(type) {
            case .number, .string, .boolean:
                self.viewUserData.addSubview(getViewFieldUser(positionY: Double(allSubviews) * (heightOfFieldUserValue)));
                self.viewUserData.frame = CGRect(x: self.viewUserData.frame.origin.x, y: self.viewUserData.frame.origin.y, width: self.viewUserData.frame.width, height: self.viewUserData.frame.height + (allSubviews > 0 ? heightOfFieldUserValue : heightOfFieldUserValue - 50))
                btnAddFieldUserData.frame = CGRect(x: btnAddFieldUserData.frame.origin.x, y: self.viewUserData.frame.origin.y + self.viewUserData.frame.height + 10, width: btnAddFieldUserData.bounds.width, height: btnAddFieldUserData.bounds.height)
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + heightOfFieldUserValue)
                break;
            default: break
        }
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    func setChannel(channel id: ListFieldType.ListChannel) {
        print("setChannel=>", id)
        channel = id
        switch(id) {
            case .vtv1, .vtv2, .vtv3, .vtv4:
                txtVideoUrl.text = dataChannel[id.rawValue]
                break;
            default: break
        }
    }
    @IBAction func onAddUserDataField(_ sender: Any) {
        var popUpWindow: PopUpWindow!
        popUpWindow = PopUpWindow(title: "Select field type", text: "Please select field type", buttontext: "OK", buttonTextCancel: "Cancel", callback: setTypeField, selectedType: typeField)
        self.present(popUpWindow, animated: true, completion: nil)
        
    }
    @IBAction func onGetChannel(_ sender: Any) {
        print("onGetChannel")
        var popUpWindow: PopUpWindowSelect!
        popUpWindow = PopUpWindowSelect(title: "Select Channel", text: "Please select channel", buttontext: "OK", buttonTextCancel: "Cancel", callback: setChannel, selectedChannel: channel)
        self.present(popUpWindow, animated: true, completion: nil)
    }
}

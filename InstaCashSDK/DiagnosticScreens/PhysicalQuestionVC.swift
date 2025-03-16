//
//  PhysicalQuestionVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 01/03/25.
//

import UIKit

class PhysicalQuestionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    var questAnswerDict : ((_ dict:[String:Any]) -> Void)?
    
    @IBOutlet weak var physicalQuestTblVW: UITableView!
    @IBOutlet weak var questionProgressVW: UIProgressView!
    @IBOutlet weak var lblQuestionCount: UILabel!
    
    //var arrQuestion = ["does your device ON", "does your device OFF", "does your device Broken"]
    //var arrAnswer = ["Yes", "No", "May be", "No Idea"]
    //var responseObject = [String:Any]()
    //var arrSelectedIndex = [Int]()
    
    var arrQuestionForQuestion = [PhysicalQuestionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomNavigationBar()
        
        //Register tableview cell
        self.physicalQuestTblVW.register(UINib(nibName: "PhysicalQuestionTblCell", bundle: nil), forCellReuseIdentifier: "PhysicalQuestionTblCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadQuestionAnswerFromString()
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func loadQuestionAnswerFromString() {
        
        let response = """
{
    "status": true,
    "timeStamp": "2025-03-01 12:41:40",
    "question": [
        {
            "id": "1",
            "question": "Screen Condition",
            "key": "Screen",
            "type": "radio",
            "options": [
                {
                    "id": "1",
                    "option": "Flawless",
                    "optionValue": "Flawless"
                },
                {
                    "id": "2",
                    "option": "2-3 Minor Scratches",
                    "optionValue": "2-3 Minor Scratches"
                }
            ]
        },

        {
            "id": "2",
            "question": "Body Condition",
            "key": "Body",
            "type": "radio",
            "options": [
                {
                    "id": "1",
                    "option": "Flawless",
                    "optionValue": "Flawless"
                },
                {
                    "id": "2",
                    "option": "Heavy Dented",
                    "optionValue": "Heavy Dented"
                }
            ]
        },

                        {        
            "id": "3",     
            "key": "accessories",   
                            "question" : "Select the available accessories",
                            "type" : "checkbox",
                            "options" : [
                                        {                        
                        "id" : "c51398349", 
                    "option": "Flawless",                   
                        "optionValue":"Earphone"
                    },
                                        {                        
                        "id" : "c51398350",    
                    "option": "Flawless",               
                        "optionValue":"Box with same IMEI"
                    },
                                        {                        
                        "id" : "c51398351",     
                    "option": "Flawless",                
                        "optionValue":"Original Charger"
                    }
                ]                
            },

                        {
                            "id": "4",     
                            "key": "functional",
                            "question" : "Select the functional issues of your device",
                "type" : "checkbox",     
                            "options": [
                                        {                        
                        "id" : "c51398352", 
                    "option": "Flawless",                       
                        "optionValue":"Front Or Back Camera - Not working or faulty"
                    },
                                        {                        
                        "id" : "c51398353",      
                    "option": "Flawless",                
                        "optionValue":"Volume Button not working"
                    },
                                        {                        
                        "id" : "c51398354",      
                    "option": "Flawless",                  
                        "optionValue":"Power/Home Button Faulty Hard or Not Working"
                    },
                                        {                        
                        "id" : "c51398355", 
                    "option": "Flawless",                    
                        "optionValue":"Wifi Or Bluetooth Or GPS Not Working"
                    },
                                        {                        
                        "id" : "c51398356",    
                    "option": "Flawless",                  
                        "optionValue":"Charging Defect unable to charge the phone"
                    },
                                        {                        
                        "id" : "c51398357",   
                    "option": "Flawless",                   
                        "optionValue":"Battery Faulty or Very Low Battery Back up"
                    },
                                        {                        
                        "id" : "c51398358",   
                    "option": "Flawless",                    
                        "optionValue":"Speakers not working faulty Or cracked sound"
                    },
                                        {                        
                        "id" : "c51398359",     
                    "option": "Flawless",                 
                        "optionValue":"Microphone Not Working"
                    },
                                        {                        
                        "id" : "c51398360",  
                    "option": "Flawless",                     
                        "optionValue":"GSM (Call Function) is not-working normally"
                    },
                                        {                        
                        "id" : "c51398361", 
                    "option": "Flawless",                      
                        "optionValue" : "Earphone Jack is damaged or not-working"
                    },
                                        {                        
                        "id" : "c51398362",       
                    "option": "Flawless",                
                        "optionValue" : "Fingerprint Sensor not-working"
                    }
                ]                          
            }


    ]
}
"""
        
        
        let respDict = convertToDictionary(text: response)
        print("respDict", respDict ?? [:])
        
        let arrData = respDict?["question"] as? NSArray ?? []
        
        for index in 0..<arrData.count {
            let dict = arrData[index] as? [String:Any] ?? [:]
            
            let modelQuestion = PhysicalQuestionModel()
            var arrQuestionValue = [PhysicalQuestionValuesModel]()
            
            modelQuestion.strQuestionId = dict["id"] as? String ?? ""
            modelQuestion.strQuestionName = dict["question"] as? String ?? ""
            modelQuestion.strQuestionKey = dict["key"] as? String ?? ""
            modelQuestion.strQuestionType = dict["type"] as? String ?? ""
            
            // put questionvalue here
            var  arrQuestionValues = NSArray()
            arrQuestionValues = dict["options"] as? NSArray ?? []
            
            if arrQuestionValues.count > 0 {
                for obj in 0..<arrQuestionValues.count {
                    
                    let dictValue = arrQuestionValues[obj] as? NSDictionary ?? [:]
                    let modelQuestionVal = PhysicalQuestionValuesModel()
                    modelQuestionVal.strAnswerID = dictValue["id"] as? String ?? ""
                    modelQuestionVal.strAnswerOption = dictValue["option"] as? String ?? ""
                    modelQuestionVal.strAnswerOptionValue = dictValue["optionValue"] as? String ?? ""
                    modelQuestionVal.isSelected = false
                    arrQuestionValue.insert(modelQuestionVal, at: obj)
                }
                
            }
            
            modelQuestion.arrQuestionOptions = arrQuestionValue
            self.arrQuestionForQuestion.append(modelQuestion)
            
        }
        
        
        
        if self.arrQuestionForQuestion.count > 0 {
            
            for i in 0..<self.arrQuestionForQuestion.count {
                
                if self.arrQuestionForQuestion[i].strQuestionType == "checkbox" {
                    
                    let modelQuestionAddValueFromOurSide = PhysicalQuestionValuesModel()
                    
                    if self.arrQuestionForQuestion[i].arrQuestionOptions.count == 1 {
                        
                        modelQuestionAddValueFromOurSide.strAnswerOptionValue = "Not Applicable"
                        modelQuestionAddValueFromOurSide.isSelected = false
                        self.arrQuestionForQuestion[i].arrQuestionOptions.append(modelQuestionAddValueFromOurSide)
                        
                    }
                    else if self.arrQuestionForQuestion[i].arrQuestionOptions.count > 1 {
                        
                        modelQuestionAddValueFromOurSide.strAnswerOptionValue = "None Of These"
                        modelQuestionAddValueFromOurSide.isSelected = false
                        self.arrQuestionForQuestion[i].arrQuestionOptions.append(modelQuestionAddValueFromOurSide)
                        
                    }
                    else{
                        
                    }
                }
            }
            
            
            let progress = Float(1)/Float(self.arrQuestionForQuestion.count)
            self.questionProgressVW.progress = Float(progress)
            self.lblQuestionCount.text = "1/" + "\(self.arrQuestionForQuestion.count)"
            self.physicalQuestTblVW.reloadData()
            
        }
        
        
    }
    
    func setCustomNavigationBar() {
        
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalUtility().AppThemeColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.title = "Physical Questions"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: UItableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.arrQuestion.count
        
        return self.arrQuestionForQuestion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tblCell = tableView.dequeueReusableCell(withIdentifier: "PhysicalQuestionTblCell", for: indexPath) as! PhysicalQuestionTblCell
        
        tblCell.collectionViewQuestionAnswer.delegate = self
        tblCell.collectionViewQuestionAnswer.dataSource = self
        tblCell.collectionViewQuestionAnswer.tag = indexPath.row
        tblCell.collectionViewQuestionAnswer.reloadData()
        
        tblCell.lblQuestion.text = self.arrQuestionForQuestion[indexPath.row].strQuestionName
        
        return tblCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return CGFloat((self.arrAnswer.count + 1) * 60)
        
        if (arrQuestionForQuestion[indexPath.row].arrQuestionOptions.count <= 2 )
        {
            return 180
        }
        else
        {
            return CGFloat(70 + (arrQuestionForQuestion[indexPath.row].arrQuestionOptions.count * 60))
        }
        
    }
    
    //MARK: collectionview delegates methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.arrAnswer.count
        
        return arrQuestionForQuestion[collectionView.tag].arrQuestionOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhysicalQuestionCollectionVWCell", for: indexPath as IndexPath) as! PhysicalQuestionCollectionVWCell
        
        //collCell.lblAnswer.text = self.arrAnswer[indexPath.item]
        
        collCell.lblAnswer.text = (arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.item].strAnswerOptionValue)
        
        if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.item].isSelected == true {
            collCell.circleImgVW.backgroundColor = AppThemeColor
        }
        else{
            collCell.circleImgVW.backgroundColor = .lightGray
        }
        
        return collCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        if (arrQuestionForQuestion[collectionView.tag].strQuestionType == "checkbox") &&  (arrQuestionForQuestion[collectionView.tag].arrQuestionOptions.count > 2 ) {
            
            if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.row].isSelected == true {
                
                arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.row].isSelected = false
                //arrQuestionForQuestion[collectionView.tag].strAnswerName = ""
                
            }
            else{
                
                if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.row].strAnswerOptionValue == "None Of These" {
                    
                    for k in 0..<arrQuestionForQuestion[collectionView.tag].arrQuestionOptions.count {
                        arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[k].isSelected = false
                    }
                    
                    arrQuestionForQuestion[collectionView.tag].strAnswerName = "None Of These"
                    
                }
                else{
                    
                    for k in 0..<arrQuestionForQuestion[collectionView.tag].arrQuestionOptions.count {
                        
                        if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[k].strAnswerOptionValue == "None Of These" {
                            
                            if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[k].isSelected == true {
                                
                                arrQuestionForQuestion[collectionView.tag].strAnswerName = ""
                                
                            }
                            arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[k].isSelected = false
                            
                        }
                    }
                    
                    //arrQuestionForQuestion[collectionView.tag].strAnswerName =                  arrQuestionForQuestion[collectionView.tag].strAnswerName + "," + arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.row].strAnswerOptionValue
                }
                
                arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[indexPath.item].isSelected = true
                
            }
                        
            
            let arrOpt = self.arrQuestionForQuestion[collectionView.tag].arrQuestionOptions
            var strAns = ""
            for ans in arrOpt {
                if ans.isSelected {
                    
                    if strAns == "" {
                        strAns += ans.strAnswerOptionValue
                    }
                    else {
                        strAns += "," + ans.strAnswerOptionValue
                    }
                    
                }
            }
            
            arrQuestionForQuestion[collectionView.tag].strAnswerName = strAns
            print("selected answers are : ", arrQuestionForQuestion[collectionView.tag].strAnswerName)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                var selQuestionCount = 0
                for selectedQuestion in self.arrQuestionForQuestion {
                    for innerQuestion in selectedQuestion.arrQuestionOptions {
                        if innerQuestion.isSelected {
                            selQuestionCount += 1
                                                                                    
                            let progress = Float(selQuestionCount)/Float(self.arrQuestionForQuestion.count)
                            
                            self.questionProgressVW.progress = Float(progress)
                            self.lblQuestionCount.text = "\(selQuestionCount)" + "/" + "\(self.arrQuestionForQuestion.count)"
                            
                            break
                        }
                    }
                }
                
                collectionView.reloadData()
            }
            
                        
            /*
            if collectionView.tag == self.arrQuestionForQuestion.count - 1 {
                
                var selJsonDict = [String:String]()
                
                for item in self.arrQuestionForQuestion {
                    selJsonDict[item.strQuestionName] = item.strAnswerName
                }
                
                if let dict = questAnswerDict {
                    dict(selJsonDict)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            */
            
        }
        else {
            
            //MARK: For Radio button condition & Select Condition
            
            for index in 0..<arrQuestionForQuestion[collectionView.tag].arrQuestionOptions.count {
                
                if index == indexPath.item {
                    
                    if arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[index].isSelected == true {
                        
                        arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[index].isSelected = false
                        arrQuestionForQuestion[collectionView.tag].strAnswerName = ""
                                                
                    }
                    else{
                        
                        arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[index].isSelected = true
                        arrQuestionForQuestion[collectionView.tag].strAnswerName = arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[index].strAnswerOptionValue
                                                
                    }
                    
                }else {
                    
                    arrQuestionForQuestion[collectionView.tag].arrQuestionOptions[index].isSelected = false
                    //arrQuestionForQuestion[collectionView.tag].strAnswerName = ""
                                        
                }
                
            }
            
            
            if arrQuestionForQuestion.count == collectionView.tag + 1 || arrQuestionForQuestion.count == collectionView.tag + 2
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    var selQuestionCount = 0
                    for selectedQuestion in self.arrQuestionForQuestion {
                        for innerQuestion in selectedQuestion.arrQuestionOptions {
                            if innerQuestion.isSelected {
                                selQuestionCount += 1
                                                                
                                let progress = Float(selQuestionCount)/Float(self.arrQuestionForQuestion.count)
                                
                                self.questionProgressVW.progress = Float(progress)
                                self.lblQuestionCount.text = "\(selQuestionCount)" + "/" + "\(self.arrQuestionForQuestion.count)"
                                
                                break
                            }
                        }
                    }
                    
                    collectionView.reloadData()
                }
                
            }
            else{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    var selQuestionCount = 0
                    for selectedQuestion in self.arrQuestionForQuestion {
                        for innerQuestion in selectedQuestion.arrQuestionOptions {
                            if innerQuestion.isSelected {
                                selQuestionCount += 1
                                
                                let progress = Float(selQuestionCount)/Float(self.arrQuestionForQuestion.count)
                                
                                self.questionProgressVW.progress = Float(progress)
                                self.lblQuestionCount.text = "\(selQuestionCount)" + "/" + "\(self.arrQuestionForQuestion.count)"
                                
                                break
                            }
                        }
                    }
                                        
                    collectionView.reloadData()
                }
                
            }
            
            if arrQuestionForQuestion.count != collectionView.tag + 1 {
                let indexPath = NSIndexPath(row: collectionView.tag + 1, section: 0)
                self.physicalQuestTblVW.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
                   
            /*
            if collectionView.tag == self.arrQuestionForQuestion.count - 1 {
                
                var selJsonDict = [String:Any]()
                
                for item in self.arrQuestionForQuestion {
                    selJsonDict[item.strQuestionName] = item.strAnswerName
                }
                
                if let dict = questAnswerDict {
                    dict(selJsonDict)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            */
            
            
        }
        
        
    }
    
    // MARK: IBActions
    @IBAction func physicalQuestionsResultSubmitButtonPressed(_ sender: UIButton) {
        var selJsonDict = [String:Any]()
        
        for item in self.arrQuestionForQuestion {
            selJsonDict[item.strQuestionName] = item.strAnswerName
        }
        
        if let dict = questAnswerDict {
            dict(selJsonDict)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


class PhysicalQuestionModel: NSObject {
    
    var strQuestionId = ""
    var strQuestionName = ""
    var strQuestionKey = ""
    var strQuestionType = ""
    var arrQuestionOptions = [PhysicalQuestionValuesModel]()
    
    var strAnswerName = ""
}

class PhysicalQuestionValuesModel: NSObject {
    
    var strAnswerID = ""
    var strAnswerOption = ""
    var strAnswerOptionValue = ""
    var isSelected = false
    
}

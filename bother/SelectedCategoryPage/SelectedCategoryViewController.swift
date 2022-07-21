//
//  SelectedCategoryViewController.swift
//  bother
//
//  Created by Eyüp Mert on 15.07.2022.
//

import UIKit
import FirebaseAuth
import FCAlertView

class SelectedCategoryViewController: UIViewController {
    
    
    // TODO: Can be anything without violence, sex, terrorism, etc.
    // TODO: When create user, go to correct page with correct info.
    // TODO: Here we can animate agreed and disagreed labels after selection, for better ui.
    // TODO: Also this stands by with the reason, people will be effected other's answers.
    
    // MARK: - Variables
    var selectedMainCategory : Int = 0
    var isDailyBotherFinished = false
    var botherObjectArray = [Bother]()
    var answeredBothersArray = [Bother]()
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: - Actions
    @IBAction func actionDismiss(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func btnResetDailyBother(_ sender: Any) {
        
        DispatchQueue.main.async {
                self.openWriteYourStoryPage()
        }
        if Auth.auth().currentUser == nil {
            openSignUpViewController(selectedMainCategory: selectedMainCategory)
        } else {
            openWriteYourStoryPage()
        }
        
    }
 
 
    // MARK: - Statements
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSuccessView), name: NSNotification.Name(rawValue: "newUserCreated"), object: nil)
        
        getBothersFromDB()
    }
    
    // MARK: - Functions
    
    
    func getBothersFromDB() {
        
        for index in botherArray {
            let newBother = Bother(botherText: index, botherAnswer: nil)
            botherObjectArray.append(newBother)
            print("BotherOBjArr: \(botherObjectArray)")
            
        }
        self.tableView.reloadData()
        
    }
    
    @objc func showSuccessView(){
        DispatchQueue.main.async {
            let alert = FCAlertView()
            let homeImage = UIImage(systemName: "house", withConfiguration: nil)
            DispatchQueue.main.async {
                alert.showAlert(inView: self,
                                withTitle: "Done",
                                withSubtitle: "Spend some time. You'll see there's a lot of people around you, bothered with something.",
                                withCustomImage: homeImage,
                                withDoneButtonTitle: "Done",
                                andButtons: ["Done"]) // Set your button titles here
                alert.dismissOnOutsideTouch = true
                alert.colorScheme = .red // Replace "Blue" with your preferred color from the image above
                alert.titleColor = .purple
                alert.subTitleColor = .orange
                alert.cornerRadius = 4
             }
        }
    }
}


// MARK: - Extensions
extension SelectedCategoryViewController: UITableViewDelegate, ActionYesOrNoDelegate {
    
    func actionYesOrNoClicked(answer: Int) {

    }
    
    func actionYesOrNoClicked(cell: SelectedCategoryTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell){
            if botherArray.count > 0 {
              //  botherArray.remove(at: indexPath.row - 1)
                if let dailyBotherLimit = BotherUser.shared.getSessionBotherLimit() {
                    BotherUser.shared.setSessionBotherLimit(sessionBotherLimit: dailyBotherLimit - 1)
                }
            } else {
                isDailyBotherFinished = true
            }
        }
    }
}


extension SelectedCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if botherArray.count > 0 {
            return botherArray.count + 1
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if botherArray.count != 0 {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyLimitAchievedTableViewCellID", for: indexPath) as! DailyLimitAchievedTableViewCell
            if Auth.auth().currentUser == nil {
                cell.headerAchievedLmt.text = "Sign up and become limitless user."
            } else {
                cell.headerAchievedLmt.text = "Write your own, share, relieve..."
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedCategoryTableViewCellID", for: indexPath) as! SelectedCategoryTableViewCell
            cell.actionYesOrNoDelegate = self

            prepareButtonCall(cell, indexPath)
            cell.updateCell(botherObject: botherObjectArray[indexPath.row - 1])

            return cell
        }
    }
    
    @objc func btnNoHandler(sender:UIButton) {
        
        let selectedIndexpath = sender.tag
            botherObjectArray[selectedIndexpath - 1].botherAnswer = false
            answeredBothersArray.append(botherObjectArray[selectedIndexpath - 1])
            self.tableView.reloadData()
        // TODO: Write new array to the database
        print("AnsweredBothersArray: \(answeredBothersArray)")
        }
    
    @objc func btnMeTooHandler(sender:UIButton) {
            let selectedIndexpath = sender.tag
            botherObjectArray[selectedIndexpath - 1].botherAnswer = true
            answeredBothersArray.append(botherObjectArray[selectedIndexpath - 1])
            self.tableView.reloadData()
        print("AnsweredBothersArray: \(answeredBothersArray)")
        // TODO: Write new array to the database
        }
    
    fileprivate func prepareButtonCall(_ cell: SelectedCategoryTableViewCell, _ indexPath: IndexPath) {
        cell.btnNo.tag = indexPath.row
        cell.btnNo.addTarget(self,action:#selector(btnNoHandler(sender:)), for: .touchUpInside)
        cell.btnMeToo.tag = indexPath.row
        cell.btnMeToo.addTarget(self,action:#selector(btnMeTooHandler(sender:)), for: .touchUpInside)
    }
    
}

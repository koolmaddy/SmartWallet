//
//  ViewController.swift
//  sw
//
//  Created by Madhusudan Srivastava on 4/24/18.
//  Copyright © 2018 Madhusudan Srivastava. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ccChaseFreedom: UIImageView!
    @IBOutlet weak var ccCitiBestBuy: UIImageView!
    @IBOutlet weak var ccBoACashRewards: UIImageView!
    @IBOutlet weak var ccBarclaycardApple: UIImageView!
    @IBOutlet weak var payTouch: UIImageView!
    @IBOutlet weak var prefCBLabel: UILabel!
    @IBOutlet weak var otherCBLabel: UILabel!
    
    var ccList = [UIImageView]()
    var ccYPositions: [CGFloat] = [643.0, 619.0, 596.0, 571.0]
    
    let todoEndpoint : String = "http://17.236.36.56:8080/MockService_war_exploded/getCBInfo?storeName=AppleStore"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        // initialise the CC array
        initCC()
        
        // reset the CC positions in the GUI
        reset()
        
        //highlightCard(cardID:3, message:"Test")
    }
    
    func initCC() {
        // init cc array
        ccList = [ccChaseFreedom, ccCitiBestBuy, ccBoACashRewards,ccBarclaycardApple]
        
        // call Wallet service to get cashbackinfo
        getCashBackInfo(){
            (result: [[String: Any]]) in
            //print(result)
            
            // Attach to main thread for GUI changes
            DispatchQueue.main.async {
                let cashbackText = result[0]["value"] as? NSNumber
                let pointsText = result[1]["value"] as? NSNumber
                
                // highlight selected card in GUI
                self.highlightCard(cardID:(result[0]["walletCardId"] as! Int), message:"\(cashbackText ?? 0)", altMessage:"\(pointsText ?? 0)")
            }
        }
    }
    
    func reset() {
        // iterate through cards, ordering them and displaying
        var count: Int = ccList.count - 1
        for cc in ccList {
            cc.frame = CGRect(x: 22.0, y: ccYPositions[count], width: cc.frame.size.width, height: cc.frame.size.height)
            self.view.bringSubview(toFront: cc)
            count = count - 1
        }
    }
    
    func sortRemainingCards(excludedCardID: Int) {
        // create tmp array without selected card
        var cardArray = ccList
        cardArray.remove(at: excludedCardID)

        // iterate through remaining cards, ordering them and displaying
        var count: Int = cardArray.count - 1
        for cc in cardArray {
            cc.frame = CGRect(x: 22.0, y: ccYPositions[count], width: cc.frame.size.width, height: cc.frame.size.height)
            self.view.bringSubview(toFront: cc)
            count = count - 1
        }
    }
    
    func highlightCard(cardID: Int, message: String, altMessage: String) {
        UIView.animate(withDuration: 1.2, animations: {
            self.ccList[cardID].frame = CGRect(x: 22 , y:32, width: 330, height : 207)
        }) { (finished) in
            self.payTouch.isHidden = false
            
            self.prefCBLabel.text = "You'll earn: " + message + "% cashback"
            self.prefCBLabel.isHidden = false
            
            self.otherCBLabel.text = "(" + altMessage + "x points available)"
            self.otherCBLabel.isHidden = false
        }
        
        // Order remaining CCs
        sortRemainingCards(excludedCardID: cardID)
    }
    
    func getCashBackInfo(completion: @escaping (_ result:[[String:Any]]) -> Void){
        var cashbackInfo: [[String: Any]] = []
        
        // create wallet service URL
        guard let url = URL(string: todoEndpoint) else {
            print("Invalid URL Format")
            return
        }
        
        // make call to wallet service
        URLSession.shared.dataTask(with:url, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                cashbackInfo = json["cashbackInfo"] as? [[String: Any]] ?? []
                completion(cashbackInfo)
                
                //print(cashbackInfo)
            
                //self.highlightCard(cardID:(cashbackInfo[0]["walletCardId"] as! Int), message:"test")
                
                //print((cashbackInfo[0]["walletCardId"] as! Int))
                
                //let cashbackText = cashbackInfo[0]["value"] as? NSNumber
                //print("Test: " + "\(cashbackText ?? 0)")
                //self.prefCBLabel.text = "Test: " + "\(cashbackText ?? 0)"
                
                // print preferred credit card
                
                
                // loop through available credit cards
                //for currCard in cashbackInfo {
                    //print(currCard["value"])
                    //print(currCard["walletCardId"])
                    
                    
                //}
                
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }

}


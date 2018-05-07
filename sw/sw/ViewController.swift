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
    @IBOutlet weak var card1Label: UILabel!
    @IBOutlet weak var card3Label: UILabel!
    @IBOutlet weak var card4Label: UILabel!
    @IBOutlet weak var card2Label: UILabel!
    @IBOutlet weak var storeLabel: UILabel!
    
    var currCardID : Int!
    var cashbackInfo: [[String: Any]]!
    
    var ccList = [UIImageView]()
    var cardLabelList = [UILabel]()
    var ccYPositions: [CGFloat] = [643.0, 619.0, 596.0, 571.0]
    
    //let todoEndpoint : String = "http://17.236.36.56:8080/MockService_war_exploded/getCBInfo?storeName=AppleStore"
    let todoEndpoint : String = "http://17.236.36.56:8080/MockService_war_exploded/getCBInfo?storeName=BestBuy"
    
    let storeEndpoint : String = "http://17.168.60.23:8090/v2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //findStore()
        // initialise the CC array
        initCC()
        
        // reset the CC positions in the GUI
        reset()
    }
    
//    func findStore(){
//        var cashbackInfo: [[String: Any]] = []
//        
//        // create wallet service URL
//        //guard let url = URL(string: appleEndpoint) else {
//        guard let url = URL(string: todoEndpoint) else {
//            print("Invalid URL Format")
//            return
//        }
//        
//        // make call to wallet service
//        URLSession.shared.dataTask(with:url, completionHandler: {(data, response, error) in
//            guard let data = data, error == nil else { return }
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
//                cashbackInfo = json["cashbackInfo"] as? [[String: Any]] ?? []
//                completion(cashbackInfo)
//                
//            } catch let error as NSError {
//                print(error)
//            }
//        }).resume()
//    }
    
    func initCC() {
        // init cc array
        ccList = [ccChaseFreedom, ccCitiBestBuy, ccBoACashRewards,ccBarclaycardApple]
        ccList[0].tag = 0
        ccList[1].tag = 1
        ccList[2].tag = 2
        ccList[3].tag = 3
        
        //self.storeLabel.text = "Apple store detected"
        self.storeLabel.text = "BestBuy store detected"
        
        cardLabelList = [card1Label, card2Label, card3Label, card4Label]
        
        // call Wallet service to get cashbackinfo
        getCashBackInfo(){
            (result: [[String: Any]]) in
            //print(result)
            
            // Attach to main thread for GUI changes
            DispatchQueue.main.async {
                
                print(result)
                self.cashbackInfo = result
                
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
        
        // hide labels and paytouch icon
        self.payTouch.isHidden = true
        self.prefCBLabel.isHidden = true
        self.otherCBLabel.isHidden = true
        
        self.card1Label.isHidden = true
        self.card2Label.isHidden = true
        self.card3Label.isHidden = true
        self.card4Label.isHidden = true
        self.storeLabel.isHidden = true
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
    
    func showAllCards() {
        
        self.payTouch.isHidden = true
        self.prefCBLabel.isHidden = true
        self.otherCBLabel.isHidden = true
        self.storeLabel.isHidden = true
        
        UIView.animate(withDuration: 1, animations: {
                    self.ccList[self.currCardID].frame = CGRect(x: 22 , y:571, width: 330, height : 207)
                }) { (finished) in
                    
                var yCord = 32
                var count = 0
                for card in self.ccList {
                     UIView.animate(withDuration: 0.7, animations: {
                        card.frame = CGRect(x: 22 , y:yCord, width: 330, height : 207)
                     })
                        yCord = yCord + 100
                        self.view.bringSubview(toFront: card)
                    
                        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cardSelected(gesture:)))
                        card.isUserInteractionEnabled = true
                        card.addGestureRecognizer(tapGestureRecognizer)
                    
                        var loopIt = 0
                        for ccInfo in self.cashbackInfo {
                            if ((ccInfo["walletCardId"] as? Int) == count) {
                                //print(count)
                                //print(ccInfo["walletCardId"] as? Int)
                                //let cardID = ccInfo["walletCardId"] as? Int
                                let cashbackText = self.cashbackInfo[loopIt]["value"] as? NSNumber
                                self.cardLabelList[count].text = "\(cashbackText ?? 0)%"
                                break
                            }
                            loopIt = loopIt + 1
                        }
                        count = count + 1
                    }
                    
                    // show labels with rewar values
                    self.card1Label.isHidden = false
                    self.card1Label.layer.zPosition = 1
                    self.card2Label.isHidden = false
                    self.card2Label.layer.zPosition = 1
                    self.card3Label.isHidden = false
                    self.card3Label.layer.zPosition = 1
                    self.card4Label.isHidden = false
                    self.card4Label.layer.zPosition = 1
                    
                
        }
    }
    
    @objc func cardSelected (gesture : UITapGestureRecognizer){
        let v = gesture.view!
        let tag = v.tag
        //print(tag)
        
        var cashbackText: NSNumber!
        var pointsText = self.cashbackInfo[1]["value"] as? NSNumber
        
        var count = 0
        for card in self.cashbackInfo {
            if ((card["walletCardId"] as? Int) == tag) {
                if (count != 0){
                    pointsText = self.cashbackInfo[0]["value"] as? NSNumber
                }
                cashbackText = card["value"] as? NSNumber
                
                break;
            }
            count = count + 1
        }
        
        // hide labels
        self.card1Label.isHidden = true
        self.card2Label.isHidden = true
        self.card3Label.isHidden = true
        self.card4Label.isHidden = true
       
        // animate all cards to bottom of screen
        moveDownAllCards()
        
        // show newly selected card
        highlightCard(cardID: tag, message: "\(cashbackText ?? 0)", altMessage: "\(pointsText ?? 0)")
    }
    
    func moveDownAllCards() {
        var count = 0
        for card in self.ccList {
            UIView.animate(withDuration: 0.7, animations: {
                card.frame = CGRect(x: 22 , y:self.ccYPositions[count], width: 330, height : 207)
            })
            self.view.bringSubview(toFront: card)
            
            count = count + 1
        }
    }
    
    func highlightCard(cardID: Int, message: String, altMessage: String) {
        UIView.animate(withDuration: 1.2, animations: {
            self.ccList[cardID].frame = CGRect(x: 22 , y:32, width: 330, height : 207)
        }) { (finished) in
            self.payTouch.isHidden = false
            
            self.prefCBLabel.text = "You'll earn: " + message + "% cashback"
            self.prefCBLabel.isHidden = false
            
            self.otherCBLabel.text = "(" + altMessage + "% cashback available)"
            self.otherCBLabel.isHidden = false
            
            //self.storeLabel.text = "Apple store detected"
            //self.storeLabel.text = "BestBuy store detected"
            self.storeLabel.isHidden = false
            
            // make preferred card animatable
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGestureRecognizer:)))
            self.ccList[cardID].isUserInteractionEnabled = true
            self.currCardID = cardID
            self.ccList[cardID].addGestureRecognizer(tapGestureRecognizer)
        }
        
        // Order remaining CCs
        sortRemainingCards(excludedCardID: cardID)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.showAllCards()
    }
    
    func getCashBackInfo(completion: @escaping (_ result:[[String:Any]]) -> Void){
        var cashbackInfo: [[String: Any]] = []
        
        // create wallet service URL
        //guard let url = URL(string: appleEndpoint) else {
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
                
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }

}


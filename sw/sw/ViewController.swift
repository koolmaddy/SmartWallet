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
    
    var ccList = [UIImageView]()
    var ccYPositions: [CGFloat] = [643.0, 619.0, 596.0, 571.0]
    
    let todoEndpoint : String = "http://localhost:8080/MockService_war_exploded/helloworld"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        // initialise the CC array
        initCC()
        
        // reset the CC positions in the GUI
        reset()
        
        highlightCard(cardID:3, message:"Test")
        
        getCashBackInfo()
    }
    
    func initCC() {
        ccList = [ccChaseFreedom, ccCitiBestBuy, ccBoACashRewards,ccBarclaycardApple]
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
    
    func highlightCard(cardID: Int, message: String) {
        UIView.animate(withDuration: 1.2, animations: {
            self.ccList[cardID].frame = CGRect(x: 22 , y:32, width: 330, height : 207)
        }) { (finished) in
            // TODO
        }
        
        sortRemainingCards(excludedCardID: cardID)
    }
    
    func getCashBackInfo(){
    
        guard let url = URL(string: todoEndpoint) else {
            print("Invalid URL Format")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on cashback service")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                print (todo)
                
                guard let todoTitle = todo["walletCardId"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
                /*var dictonary:NSDictionary?

                dictonary =  try JSONSerialization.jsonObject(with: responseData, options: []) as? [String:AnyObject] as! NSDictionary
                
                if let myDictionary = dictonary
                {
                    print(" test: \(myDictionary["walletCardId"]!)")
                }*/
               
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
    }

}


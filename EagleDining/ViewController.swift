//
//  ViewController.swift
//  EagleDining
//
//  Created by Jack Antico on 11/20/18.
//  Copyright © 2018 Jack Antico. All rights reserved.

import UIKit
import SwiftSoup
import Firebase
import Mixpanel

struct defaultsKeys {
    static let agoraUsername = "invalidUsername"
    static let agoraPassword = "invalidPassword"
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        writeDiningDollars()
        initalizeMixPanel()
    }
    
    func writeDiningDollars() {
        let uid = Auth.auth().currentUser?.uid
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        if (uid != nil) {
            ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let agoraUsername = value?["agoraUsername"] as? String ?? ""
                let agoraPassword = value?["agoraPassword"] as? String ?? ""
                
                let url1 = URL(string: "https://us-central1-bc-dining-menus.cloudfunctions.net/getResidentialMealPlan?username=\(agoraUsername)&password=\(agoraPassword)&userID=\(uid!)")!
                let task1 = URLSession.shared.dataTask(with: url1) {(data, response, error) in
                    guard let data = data else { return }
                    //print("residentialMealPlanBalance is:")
                    let residentialMealPlanBalance = String(data: data, encoding: .utf8)!
                    //print(residentialMealPlanBalance)
                    ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
                        ref.child("users/\(uid!)/diningDollars/residentialMealPlan").setValue(["residentialMealPlan": residentialMealPlanBalance])
                        //print("Database update 1 went through")
                    }) { (error) in
                        print("ERROR (SignUpViewController):" + error.localizedDescription)
                    }
                }
                task1.resume()
                
                let url2 = URL(string: "https://us-central1-bc-dining-menus.cloudfunctions.net/getResidentialDiningBucks?username=\(agoraUsername)&password=\(agoraPassword)&userID=\(uid!)")!
                let task2 = URLSession.shared.dataTask(with: url2) {(data, response, error) in
                    guard let data = data else { return }
                    //print("residentialDiningBucks is:")
                    let residentialDiningBucksBalance = String(data: data, encoding: .utf8)!
                    //print(residentialDiningBucksBalance)
                    ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
                        ref.child("users/\(uid!)/diningDollars/residentialDiningBucks").setValue(["residentialDiningBucks": residentialDiningBucksBalance])
                        //print("Database update 2 went through")
                    }) { (error) in
                        print("ERROR (SignUpViewController):" + error.localizedDescription)
                    }
                }
                task2.resume()
                
                let url3 = URL(string: "https://us-central1-bc-dining-menus.cloudfunctions.net/getStudentEagleBucks?username=\(agoraUsername)&password=\(agoraPassword)&userID=\(uid!)")!
                let task3 = URLSession.shared.dataTask(with: url3) {(data, response, error) in
                    guard let data = data else { return }
                    //print("studentEagleBucksBalance is:")
                    let studentEagleBucksBalance = String(data: data, encoding: .utf8)!
                    print(studentEagleBucksBalance)
                    ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
                        ref.child("users/\(uid!)/diningDollars/studentEagleBucks").setValue(["studentEagleBucks": studentEagleBucksBalance])
                        //print("Database update 3 went through")
                    }) { (error) in
                        print("ERROR (SignUpViewController):" + error.localizedDescription)
                    }
                }
                task3.resume()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    //Tracks user sessions in Firebase Database, not implemented yet
    func startRecordingSession() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "invalid_uuid"
        ref.child("users/\(uuid)").observeSingleEvent(of: .value, with: { (snapshot) in
            ref.child("users/\(uuid)/userData/sessions").setValue(["visitedHomeScreen": 1])
        }) { (error) in
            print("ERROR (ViewController):" + error.localizedDescription)
        }
    }
    
    @IBAction func diningDollarPressed(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "segueFromHomeToDiningDollars", sender: self)
        } else {
            performSegue(withIdentifier: "segueFromHomeToLogin", sender: self)
        }
        Analytics.logEvent("dining_dollars_pressed", parameters: nil)
    }
    
    @IBAction func macPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "mac_pressed")
    }
    
    @IBAction func lowerPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "lower_pressed")
    }
    
    @IBAction func newtonPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "newton_pressed")
    }
    
    @IBAction func eaglesNestPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "eagles_nest_pressed")
    }
    
    @IBAction func addiesPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "addies_pressed")
    }
    
    
    @IBAction func hillsidePressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "hillside_pressed")
    }
    
    @IBAction func chocolateBarPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "chocolate_bar_pressed")
    }
    
    @IBAction func theRatPressed(_ sender: UIButton) {
        Mixpanel.mainInstance().track(event: "the_rat_pressed")
    }
    
    func initalizeMixPanel() {
        Mixpanel.initialize(token: "458435c0bad6b37789903ee5c9471e1e")
    }
    
}

//extension StringProtocol where Index == String.Index {
//    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
//        return range(of: string, options: options)?.lowerBound
//    }
//    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
//        return range(of: string, options: options)?.upperBound
//    }
//    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
//        var result: [Index] = []
//        var start = startIndex
//        while start < endIndex,
//            let range = self[start..<endIndex].range(of: string, options: options) {
//                result.append(range.lowerBound)
//                start = range.lowerBound < range.upperBound ? range.upperBound :
//                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//        }
//        return result
//    }
//    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
//        var result: [Range<Index>] = []
//        var start = startIndex
//        while start < endIndex,
//            let range = self[start..<endIndex].range(of: string, options: options) {
//                result.append(range)
//                start = range.lowerBound < range.upperBound ? range.upperBound :
//                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//        }
//        return result
//    }
//}

//
//  LowerViewController.swift
//
//
//  Created by Jack Antico on 2/3/19.
//

import UIKit
import SwiftSoup

class AddiesViewController: UIViewController {
    
    
    @IBOutlet weak var mealTime: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var defaultsData = UserDefaults.standard
    var addiesMenuItems = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let url = NSURL(string: "http://foodpro.bc.edu/foodpro/shortmenu.asp?sName=BC+DINING&locationNum=21%28a%29&locationName=The+Loft+%40+Addies&naFlag=1")
        if url != nil {
            let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!
                    do {
                        let html: String = urlContent! as String
                        let els: Elements = try SwiftSoup.parse(html).getElementsByClass("shortmenurecipes")
                        for link: Element in els.array() {
                            let linkText: String = try link.text()
                            self.addiesMenuItems.append(linkText)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } catch Exception.Error(let type, let message) {
                        print(message)
                    } catch {
                        print("error")
                    }
                }
            })
            task.resume()
            
        }
    }
    
    
    
    @IBAction func mealTimeChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    
    func formatBreakfast(allItems: [String]) -> [String] {
        var leftBreakfast = false
        var breakfastItems = [String()]
        for item in allItems {
            if item == "The Nosh Bagel" {
                leftBreakfast = true
            }
            if !leftBreakfast {
                breakfastItems.append(item)
            }
        }
        breakfastItems.removeSubrange(0...1)
        breakfastItems.append("")
        return breakfastItems
    }
    
    func formatDinner(allItems: [String]) -> [String] {
        var hitDinner = false
        var leftDinner = false
        var dinnerItems = [String()]
        for item in allItems {
            if item == "Black Beans And Rice" {
                break
            }
            if hitDinner == true {
                dinnerItems.append(item)
            }
            if item == "Double Meatball Obsession" { //note this works 5/7 times
                hitDinner = true
            }
        }
        dinnerItems.remove(at: 0)
        return dinnerItems
    }
    
    func formatLateNight(allItems: [String]) -> [String] {
        var hitLateNight = false
        var lateNightItems = [String()]
        for item in allItems {
            if item == "Additional Chicken Breast" {
                hitLateNight = true
            }
            if hitLateNight {
                lateNightItems.append(item)
            }
        }
        lateNightItems.remove(at: 0)
        return lateNightItems
    }
    
}

extension AddiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var mealItems = [String()]
        switch mealTime.selectedSegmentIndex {
        case 0:
            mealItems = formatBreakfast(allItems: addiesMenuItems)
        case 1:
            mealItems = formatDinner(allItems: addiesMenuItems)
        case 2:
            mealItems = formatLateNight(allItems: addiesMenuItems)
        default:
            mealItems = formatDinner(allItems: addiesMenuItems)
        }
        return mealItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mealItems = [String()]
        switch mealTime.selectedSegmentIndex {
        case 0:
            mealItems = formatBreakfast(allItems: addiesMenuItems)
        case 1:
            mealItems = formatDinner(allItems: addiesMenuItems)
        case 2:
            mealItems = formatLateNight(allItems: addiesMenuItems)
        default:
            mealItems = formatDinner(allItems: addiesMenuItems)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = mealItems[indexPath.row]
        cell.backgroundColor = UIColor.init(red: 148.0/256.0, green: 23.0/256.0, blue: 81.0/256.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.init(red: 255.0/256.0, green: 251.0/256.0, blue: 0.0/256.0, alpha: 1.0)
        return cell
    }
    
}


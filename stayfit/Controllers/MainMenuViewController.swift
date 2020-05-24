//
//  MainMenuTableViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class MainMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileEditLabel: UIBarButtonItem!
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var displayCalendarCurrentMonth: UILabel!
    @IBOutlet weak var cpmInfoLabel: UILabel!
    @IBOutlet weak var targetInfoLabel: UILabel!
    @IBOutlet weak var caloriesForTarget: UILabel!
    @IBOutlet weak var fatsLabel: UILabel!
    @IBOutlet weak var proteinsLabel: UILabel!
    @IBOutlet weak var carbohydratesLabel: UILabel!
    
    @IBOutlet weak var cpmLeftLabel: UILabel!
    @IBOutlet weak var caloriesLeftLabel: UILabel!
    @IBOutlet weak var fatsLeftLabel: UILabel!
    @IBOutlet weak var proteinLeftLabel: UILabel!
    @IBOutlet weak var carbohydratesLeftLabel: UILabel!
    @IBOutlet weak var targetLeftLabel: UILabel!
    
    @IBOutlet weak var calendarViewHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var measurementsView: UITableView!
    
    @IBOutlet weak var showMeasureButton: UIButton!
    
    let realm = try! Realm()
    var dataSource = DataSource()
    var myArray = Array<DataMark>()
    var currentMonth = String()
    private let spacing:CGFloat = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCalendar() //need to reset few functions because when used navigation back -> OK but custom segue -> calendar crash
        getStartPosition()
        currentYearIsLeapYear()
        myArray = dataSource.profileTargetDay()
        
        navigationItem.hidesBackButton = true
        calendarView.delegate = self
        calendarView.dataSource = self
        measurementsView.delegate = self
        measurementsView.dataSource = self
        
        currentMonth = dataSource.months[month]
        displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        calendarView.collectionViewLayout = layout
        
        reloadVisibleData()
    }
    
    func reloadVisibleData() {
        cpmInfoLabel.text = String(format: "%.0f", dataSource.CPM.rounded()) + " Kcal" 
        targetInfoLabel.text = String("\(dataSource.passedTime) \(NSLocalizedString("Dni", comment: ""))")
        caloriesForTarget.text = String(format: "%.0f", dataSource.caloriesNeededForTarget.rounded()) + " Kcal"
        fatsLabel.text = String("\(dataSource.macroElements.fats) Kcal")
        proteinsLabel.text = String("\(dataSource.macroElements.proteins) Kcal")
        carbohydratesLabel.text = String("\(dataSource.macroElements.carbohydrates) Kcal")
        measurementsView.reloadData()
    }
    
    @IBAction func showMeasureButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.measurementsView.isHidden = !self.measurementsView.isHidden
            if self.measurementsView.isHidden {
                self.measurementsView.alpha = 0.0
            } else {
                self.measurementsView.alpha = 1.0
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
        reloadVisibleData() //reload labels if you came from measurement VC and create new measure data to compute
        measurementsView.isHidden = true
        measurementsView.alpha = 0.0
    }
    
    //MARK: - Calendar setup
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch dataSource.direction {
        case 0: return dataSource.numberInMonths[month] + dataSource.numberOfEmptySpace
        case 1...: return dataSource.numberInMonths[month] + dataSource.numberOfNextEmptySpace
        case -1: return dataSource.numberInMonths[month] + dataSource.numberOfPreviousEmpySpace
        default: fatalError("unknown direction to setup for the number of rows in calendar")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCalendarCell", for: indexPath) as! CalendarViewCell
        
        cell.backgroundColor = .clear
        cell.dateLabel.textColor = .label
        
        if cell.isHidden {
            cell.isHidden = false
        }
        
        switch dataSource.direction {
        case 0: cell.dateLabel.text = "\(indexPath.row + 1 - dataSource.numberOfEmptySpace)"
        case 1: cell.dateLabel.text = "\(indexPath.row + 1 - dataSource.numberOfNextEmptySpace)"
        case -1: cell.dateLabel.text = "\(indexPath.row + 1 - dataSource.numberOfPreviousEmpySpace)"
        default: fatalError("unknown direction to setup for labels of rows in calendar")
        }
        
        if let securedText = cell.dateLabel.text {
            if Int(securedText)! < 1 {
                cell.isHidden = true
            }
        }
            switch indexPath.row {
            case 5,6,12,13,19,20,26,27,33,34: cell.dateLabel.textColor = UIColor.gray
            default: break
            }
        
        for item in myArray {
            if year == item.year && month + 1 == item.month && cell.dateLabel.text == String(item.day) {
                    cell.backgroundColor = UIColor(named: "SecondaryColor")
            }
        }
    
        //select the current day of time and space :)
        if currentMonth == dataSource.months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && indexPath.row + 1 - dataSource.numberOfEmptySpace == day {
            cell.backgroundColor = UIColor(named: "PrimaryColor")
        }
        return cell
    }
    
    func setupWeek() {
        if dataSource.numberOfEmptySpace == 0 {
            dataSource.numberOfEmptySpace = 7
        }
    }
    
    func resetCalendar() {
            month = calendar.component(.month, from: date) - 1
            year = calendar.component(.year, from: date)
            currentMonth = dataSource.months[month]
            displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
    }
    
    func getStartPosition() {
        if dataSource.direction == 0 {
            dataSource.numberOfEmptySpace = week
            setupWeek()
            var dayCounter = day
            while dayCounter > 0 {
                dataSource.numberOfEmptySpace -= 1
                dayCounter -= 1
                setupWeek()
            }
                if dataSource.numberOfEmptySpace == 7 {
                    dataSource.numberOfEmptySpace = 0
                }
                dataSource.emptySpaceBuffor = dataSource.numberOfEmptySpace
        } else if dataSource.direction == 1 {
            dataSource.numberOfNextEmptySpace = (dataSource.emptySpaceBuffor + dataSource.numberInMonths[month])%7
            dataSource.emptySpaceBuffor = dataSource.numberOfNextEmptySpace
        } else if dataSource.direction == -1 {
            dataSource.numberOfPreviousEmpySpace = (7 - (dataSource.numberInMonths[month] - dataSource.emptySpaceBuffor)%7)
            if dataSource.numberOfPreviousEmpySpace == 7 {
                dataSource.numberOfPreviousEmpySpace = 0
            }
            dataSource.emptySpaceBuffor = dataSource.numberOfPreviousEmpySpace
        } else {
            fatalError("theres is no direction for calendar")
        }
    }
    
    //MARK: - Calendar movements
    
    @IBAction func nextCalendarMonth(_ sender: UIButton) {
            updatingDate(direction: 1)
    }
    
    @IBAction func previusCalendarMonth(_ sender: UIButton) {
        updatingDate(direction: -1)
    }
    
    func updatingDate(direction: Int) {
        if direction == 1 {
            if currentMonth == "Grudzień" || currentMonth == "December" {
                month = 0
                year += 1
            }
            dataSource.direction = 1
            currentYearIsLeapYear()
            getStartPosition()
            if currentMonth != "Grudzień" || currentMonth != "December" {
                month += 1
            }
            currentMonth = dataSource.months[month]
            displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        } else if direction == -1 {
            if currentMonth == "Styczeń" || currentMonth == "January"{
                month = 11
                year -= 1
            }
            if currentMonth != "Styczeń" || currentMonth != "January"{
                month -= 1
            }
            dataSource.direction = -1
            currentYearIsLeapYear()
            getStartPosition()
            currentMonth = dataSource.months[month]
            displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        } else {
            fatalError("No direction to update Date")
        }
    }
    
    //MARK: - check for leap year
    func currentYearIsLeapYear() {
        let isLeapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
        if isLeapYear {
            dataSource.numberInMonths[1] = 29
        } else {
            dataSource.numberInMonths[1] = 28
        }
    }
}

// MARK: - frame setup for calendar (always 7 columns coresponding to 7 days in a week) for different device orientation

extension MainMenuViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfItemsPerRow:CGFloat = 7
        let spacingBetweenCells:CGFloat = 20
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.calendarView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width / 2)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = calendarView.collectionViewLayout.collectionViewContentSize.height //everytime phone perspective is rotated - reload layout and make height responsive to the content (without this code the view below will cover calendarview)
        calendarViewHeightCons.constant = height
        calendarView.collectionViewLayout.invalidateLayout()
    }
    
//MARK: - tableview setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            return loadProfileData.measureArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            let arrayOfMeasures = loadProfileData.measureArray 
            let sortedMeasures = arrayOfMeasures.sorted(byKeyPath: "date", ascending: false)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            cell.textLabel!.text = "\(NSLocalizedString("Pomiar", comment: "")) \(dateFormatter.string(from: sortedMeasures[indexPath.row].date)) \(NSLocalizedString("wynosił", comment: "")) \(sortedMeasures[indexPath.row].newestMass) KG"
            return cell
        } else {
            cell.textLabel!.text = ""
            return cell
        }
    }
    
    
}


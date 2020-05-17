//
//  MainMenuTableViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class MainMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profileEditLabel: UIBarButtonItem!
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var displayCalendarCurrentMonth: UILabel!
    @IBOutlet weak var cpmInfoLabel: UILabel!
    @IBOutlet weak var targetInfoLabel: UILabel!
    @IBOutlet weak var calendarContentView: UIView!
    
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
        calendarView.backgroundColor = .systemGray6
        
        currentMonth = dataSource.months[month]
        displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        calendarView.collectionViewLayout = layout
        
        cpmInfoLabel.text = String("\(dataSource.CPM) Kcal")
        targetInfoLabel.text = String("\(dataSource.predictionTime) Dni")
    }
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
        
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
        cell.dateLabel.textColor = .black
        
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
                    cell.backgroundColor = UIColor.lightGray
            }
        }
    
        //select the current day of time and space :)
        if currentMonth == dataSource.months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && indexPath.row + 1 - dataSource.numberOfEmptySpace == day {
            cell.backgroundColor = UIColor.green
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
            if currentMonth == "Grudzień" {
                month = 0
                year += 1
            }
            dataSource.direction = 1
            currentYearIsLeapYear()
            getStartPosition()
            if currentMonth != "Grudzień" {
                month += 1
            }
            currentMonth = dataSource.months[month]
            displayCalendarCurrentMonth.text = "\(currentMonth) \(year)"
            calendarView.reloadData()
        } else if direction == -1 {
            if currentMonth == "Styczeń" {
                month = 11
                year -= 1
            }
            if currentMonth != "Styczeń" {
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
        calendarView.collectionViewLayout.invalidateLayout()
    }
}


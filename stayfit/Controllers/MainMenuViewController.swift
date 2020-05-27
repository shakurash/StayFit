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
    
    @IBOutlet weak var calendarLeftButton: UIButton!
    @IBOutlet weak var calendarRightButton: UIButton!
    @IBOutlet weak var displayCalendarCurrentMonth: UILabel!
    @IBOutlet weak var calendarView: UICollectionView!
    
    @IBOutlet weak var pnLabel: UILabel!
    @IBOutlet weak var wtLabel: UILabel!
    @IBOutlet weak var srLabel: UILabel!
    @IBOutlet weak var czLabel: UILabel!
    @IBOutlet weak var ptLabel: UILabel!
    @IBOutlet weak var sbLabel: UILabel!
    @IBOutlet weak var ndLabel: UILabel!
    
    @IBOutlet weak var cpmStack: UIStackView!
    @IBOutlet weak var kcalStack: UIStackView!
    @IBOutlet weak var fatsStack: UIStackView!
    @IBOutlet weak var carboStack: UIStackView!
    @IBOutlet weak var proteinStack: UIStackView!
    @IBOutlet weak var targetStack: UIStackView!
    
    @IBOutlet weak var measurementsView: UITableView!
    @IBOutlet weak var showMeasureButton: UIButton!
    
    @IBOutlet weak var profileEditLabel: UIBarButtonItem!

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
        if let arrayIsNotNil = dataSource.profileTargetDay() {
            myArray = arrayIsNotNil
        }
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
        fatsLabel.text = String("\(dataSource.macroElements.fats) Kcal")
        proteinsLabel.text = String("\(dataSource.macroElements.proteins) Kcal")
        carbohydratesLabel.text = String("\(dataSource.macroElements.carbohydrates) Kcal")
        let targetIsAchieved = dataSource.caloriesNeededForTarget.rounded()
        if targetIsAchieved == 0 {
            caloriesForTarget.text = NSLocalizedString("Udało się!", comment: "")
        } else {
            caloriesForTarget.text = String(format: "%.0f", targetIsAchieved) + " Kcal"
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        view.setupbackground(imageViewName: "Background")
        
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            loadProfileData.lightMode ? (overrideUserInterfaceStyle = .light) : (overrideUserInterfaceStyle = .dark)
        }
        reloadVisibleData() //reload labels if you came from measurement VC and create new measure data to compute
        measurementsView.isHidden = true
        measurementsView.alpha = 0.0
        
    //MARK: - animation preparation
        calendarLeftButton.alpha = 0.0
        calendarRightButton.alpha = 0.0
        displayCalendarCurrentMonth.alpha = 0.0
        pnLabel.alpha = 0.0
        pnLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        wtLabel.alpha = 0.0
        wtLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        srLabel.alpha = 0.0
        srLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        czLabel.alpha = 0.0
        czLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        ptLabel.alpha = 0.0
        ptLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        sbLabel.alpha = 0.0
        sbLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        ndLabel.alpha = 0.0
        ndLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        calendarView.alpha = 0.0
        
        cpmStack.alpha = 0.0
        kcalStack.alpha = 0.0
        fatsStack.alpha = 0.0
        carboStack.alpha = 0.0
        proteinStack.alpha = 0.0
        targetStack.alpha = 0.0
        showMeasureButton.alpha = 0.0
        showMeasureButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }
    
    //MARK: - run the animation
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1){
            self.calendarLeftButton.alpha = 1.0
               }
        UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.displayCalendarCurrentMonth.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.pnLabel.alpha = 1.0
            self.pnLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.1, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.calendarRightButton.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.wtLabel.alpha = 1.0
            self.wtLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.srLabel.alpha = 1.0
            self.srLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.czLabel.alpha = 1.0
            self.czLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 1.0, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.calendarView.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.ptLabel.alpha = 1.0
            self.ptLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.1, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.cpmStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.sbLabel.alpha = 1.0
            self.sbLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.1, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                   self.kcalStack.alpha = 1.0
               })
        UIView.animate(withDuration: 0.5, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.ndLabel.alpha = 1.0
            self.ndLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        UIView.animate(withDuration: 0.1, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                   self.fatsStack.alpha = 1.0
               })
        UIView.animate(withDuration: 0.1, delay: 0.8, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                   self.carboStack.alpha = 1.0
               })
        UIView.animate(withDuration: 0.1, delay: 0.9, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                   self.proteinStack.alpha = 1.0
               })
        UIView.animate(withDuration: 0.1, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.targetStack.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 1.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.showMeasureButton.alpha = 1.0
            self.showMeasureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
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
                cell.backgroundColor = UIColor(named: "CalendarCells")
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
            cell.accessibilityIdentifier = dateFormatter.string(from: sortedMeasures[indexPath.row].date)
            return cell
        } else {
            cell.textLabel!.text = ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Usuń", comment: "")) { (action, view, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath)
            let dataToRemove = cell?.accessibilityIdentifier
            self.containData(data: dataToRemove)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        tableView.reloadData()
        
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func containData(data: String?) {
        if let securedData = data {
            if let loadProfileData = realm.objects(ProfileModel.self).first {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                let arrayOfDates = loadProfileData.measureArray
                for date in arrayOfDates {
                    let stringDate = dateFormatter.string(from: date.date)
                    if securedData == stringDate {
                        do {
                        try realm.write{
                            realm.delete(date)
                            }
                        } catch {
                                print(error)
                            }
                    }
                }
            }
        }
    }
}


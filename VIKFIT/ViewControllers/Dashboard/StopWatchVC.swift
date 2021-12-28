//
//  StopWatchVC.swift
//  VIKFIT
//


import UIKit
import AudioToolbox

class StopWatchVC: UIViewController {
    
    @IBOutlet weak var lblCurrentRound: UILabel!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var lblMins: UILabel!
    @IBOutlet weak var btnRecoveryTime: UIButton!
    @IBOutlet weak var btnPause: DesignableButton!
    @IBOutlet weak var btnPlay: DesignableButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var watchPicker: UIPickerView!
    
    var picker = UIPickerView()
    var toolBar = UIToolbar()
    var isPausePressed = false
    var totalRoundTimeInSec = 0
    var totalRestTimeInSec = 0
    
    var noOfRound = 1
    
    var roundSecTime = 0
    var roundMinTime = 1
    
    var restTimeInSec = 0
    var restTimeInMin = 0
    
    var counter = 0
    var isRound = false
    var selectedRound = 1
    var counterSecs = 0
    var counterMins = 1
    var counterMiliSec = 0
    var isRest = false
    var timer = Timer()
    var isPlaying = false
    var arrTimeSlotInSec = [5, 10, 20, 30, 40, 50, 60, 90, 120, 150, 180, 240, 300]
    
    var arrTimeSlot = ["5" + " " + "sec".localized, "10" + " " + "sec".localized, "20" + " " + "sec".localized, "30" + " " + "sec".localized, "40" + " " + "sec".localized, "50" + " " + "sec".localized, "1" + " " + "min".localized, "1" + " " + "min".localized + " 30" + " " + "sec".localized, "2" + " " + "min".localized, "2" + " " + "min".localized + " 30" + " " + "sec".localized, "3" + " " + "min".localized, "4" + " " + "min".localized, "5" + " " + "min".localized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        lblSeconds.isHidden = true
        self.watchPicker.delegate = self
        self.watchPicker.dataSource = self
        watchPicker.setValue(UIColor.white, forKey: "magnifierLineColor")
        self.navigationController?.isNavigationBarHidden = true
        lblSeconds.text = "00"
        lblMins.text = "00’00’"
        lblCurrentRound.text = "Round".localized
        self.watchPicker.selectRow(59, inComponent: 0, animated: true)
        self.watchPicker.selectRow(58, inComponent: 1, animated: true)
        self.watchPicker.selectRow(59, inComponent: 2, animated: true)
        PickerViewConnection()
        totalRestTimeInSec = arrTimeSlotInSec[3]
        btnRecoveryTime.setTitle(arrTimeSlot[3], for: .normal)
        restTimeInSec = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).2
        restTimeInMin = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).1
        totalRoundTimeInSec = (roundMinTime * 60) + roundSecTime
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        isPlaying = false
    }
    
    //Mark: Action For Exercise pause Button
    @IBAction func btnExPause(_ sender: UIButton) {
        guard noOfRound > 0, (roundSecTime > 0) || (roundMinTime > 0) else {
            return
        }
        AudioServicesPlaySystemSound(1016)
        sender.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        btnPlay.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.43)
        sender.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        timer.invalidate()
        isPlaying = false
        if isPausePressed {
            sender.isEnabled = false
            resetOnStop()
        } else {isPausePressed = true}
        
        //        lblSeconds.isHidden = true
    }
    @IBAction func actionSelectRestTime(_ sender: UIButton) {
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
        
    }
    //Mark: Action For Exercise play Button
    @IBAction func actionButtonExPlay(_ sender: UIButton) {
        if(isPlaying) {
            return
        }
        isPausePressed = false
        guard noOfRound > 0, (roundSecTime > 0) || (roundMinTime > 0) else {
            Common.showAlertMessage(message: "Please check stopwatch settings.".localized, alertType: .warning)
            return
        }
        btnPause.isEnabled = true
        //        lblSeconds.isHidden = false
        AudioServicesPlaySystemSound(1016)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        sender.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        btnPause.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.43)
        btnPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        if !isRound {
            lblCurrentRound.text = "Round".localized + " 1"
            //selectedRound = 1
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isPlaying = true
    }
    
    @IBAction func actionResetCounter(_ sender: UIButton) {
        lblCurrentRound.text = "Round".localized
        lblSeconds.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        lblMins.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        noOfRound = 1
        totalRoundTimeInSec = 0
        totalRestTimeInSec = 0
        roundSecTime = 0
        roundMinTime = 0
        restTimeInSec = 0
        restTimeInMin = 0
        counter = 0
        isRound = false
        selectedRound = 1
        counterSecs = 0
        counterMins = 0
        counterMiliSec = 0
        isRest = false
        timer.invalidate()
        isPlaying = false
        watchPicker.selectRow(59, inComponent: 0, animated: true)
        watchPicker.selectRow(59, inComponent: 1, animated: true)
        watchPicker.selectRow(59, inComponent: 2, animated: true)
        totalRestTimeInSec = arrTimeSlotInSec[0]
        btnRecoveryTime.setTitle(arrTimeSlot[0], for: .normal)
        restTimeInSec = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).2
        restTimeInMin = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).1
        totalRoundTimeInSec = (roundMinTime * 60) + roundSecTime
        collectionView.reloadData()
        resetWatch()
        //        lblSeconds.isHidden = true
        lblSeconds.text = "00"
        lblMins.text = "00’00’"
        resetOnStop()
    }
    
    fileprivate func workOfStopWatch(isRest: Bool) {
        
        if counterMiliSec == 0 {
            if counterSecs == 0 {
                if counterMins == 0 {
                    counterMins = isRest ? restTimeInMin : roundMinTime
                } else {
                    counterMins = counterMins - 1
                }
                
                if isRest {
                    if restTimeInMin > 0 {
                        counterSecs = 59
                    } else {
                        counterSecs = restTimeInSec
                    }
                } else {
                    if roundMinTime > 0 { counterSecs = 59 } else {
                        
                        counterSecs = roundSecTime
                    }
                }
            } else {
                counterSecs = counterSecs - 1
            }
            
            lblMins.text = "\(String(format: "%02d", counterMins))’\(String(format: "%02d", counterSecs))’"
            counterMiliSec = 99
            counter = counter + 1
        } else {
            counterMiliSec = counterMiliSec - 1
        }
        lblSeconds.text = String(format: "%02d", counterMiliSec)
    }
    
    fileprivate func resetWatch() {
        AudioServicesPlaySystemSound(1016)
        counterMiliSec = 00
        if isRest {
            if selectedRound == noOfRound {
                timer.invalidate()
                isPlaying = false
                lblSeconds.text = "00"
                lblMins.text = "00’00’"
                resetOnStop()
                return
            }
            counterSecs = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).2
            counterMins = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).1
            lblSeconds.textColor = .systemBlue
            lblMins.textColor = .systemBlue
            lblSeconds.text = String(format: "%02d", counterMiliSec)
            lblMins.text = "\(String(format: "%02d", counterMins))’\(String(format: "%02d", counterSecs))’"
        } else {
            counterSecs = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).2
            counterMins = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).1
            
            lblSeconds.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            lblMins.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            lblSeconds.text = String(format: "%02d", counterMiliSec)
            lblMins.text = "\(String(format: "%02d", counterMins))’\(String(format: "%02d", counterSecs))’"
        }
    }
    
    @objc func updateTimer() {
        if counter > totalRoundTimeInSec {
            if (counter - (totalRoundTimeInSec + 1)) > (totalRestTimeInSec) {
                counter = 0
                isRest = false
                resetWatch()
                selectedRound = selectedRound + 1
                if selectedRound > noOfRound {
                    timer.invalidate()
                    isPlaying = false
                    resetOnStop()
                } else {
                    lblCurrentRound.text = "Round".localized + " \(selectedRound)"
                    collectionView.reloadData()
                }
                return
            } else {
                if isRest {
                    workOfStopWatch(isRest: true)
                } else {
                    isRest = true
                    resetWatch()
                }
            }
        } else {
            if !isRound {
                isRound = true
                collectionView.reloadData()
            }
            workOfStopWatch(isRest: false)
        }
    }
    
    //MARK:- Need to update according to minute
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

//}
extension StopWatchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noOfRound
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressCollectionCell", for: indexPath) as! ProgressCollectionCell
        if isRound {
            cell.progressBar.progress = indexPath.row <= selectedRound - 1 ? 1 : 0
        } else {
            cell.progressBar.progress = 0
        }
        return cell
    }
}
extension StopWatchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width / CGFloat(noOfRound) - 4), height: collectionView.height)
    }
}


//MARK:- Weight Picker DataSource Methods
extension StopWatchVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == picker {
            return 1
        } else {
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker {
            return arrTimeSlot.count
        } else {
            return 60
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == watchPicker {
            if component == 0 {
                return NSAttributedString(string: "\(60 - row)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            } else {
                return NSAttributedString(string: "\(59 - row)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
            
        } else {
            return NSAttributedString(string: arrTimeSlot[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
}
//MARK:- Weight Picker Delegates Methods
extension StopWatchVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == watchPicker {
            switch component {
            case 0:
                if !(noOfRound == (60 - row)) {
                    noOfRound = 60 - row
                    collectionView.reloadData()
                }
                break
            case 1:
                roundMinTime = 59 - row
                break
            default:
                roundSecTime = 59 - row
            }
            totalRoundTimeInSec = (roundMinTime * 60) + roundSecTime
            counterSecs = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).2
            counterMins = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).1
            if isPlaying {
                btnPause.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
                btnPlay.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.43)
                timer.invalidate()
                isPlaying = false
            }
            resetOnStop()
        }
    }
    
    func resetOnStop() {
        noOfRound = 60 - watchPicker.selectedRow(inComponent: 0)
        roundMinTime = 59 - watchPicker.selectedRow(inComponent: 1)
        roundSecTime = 59 - watchPicker.selectedRow(inComponent: 2)
        totalRoundTimeInSec = (roundMinTime * 60) + roundSecTime
        counterSecs = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).2
        counterMins = secondsToHoursMinutesSeconds(seconds: totalRoundTimeInSec).1
        btnPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        selectedRound = 1
        isRound = false
        isRest = false
        counterMiliSec = 00
        lblCurrentRound.text = "Round".localized
        lblSeconds.text = "00"
        lblMins.text = "00’00’"
        let dataIndex: Int = picker.selectedRow(inComponent: 0)
        btnPlay.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        btnPause.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.43)
        timer.invalidate()
        isPlaying = false
        totalRestTimeInSec = arrTimeSlotInSec[dataIndex]
        btnRecoveryTime.setTitle(arrTimeSlot[dataIndex], for: .normal)
        restTimeInSec = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).2
        restTimeInMin = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).1
        lblSeconds.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        lblMins.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
        counter = 0
        lblSeconds.text = String(format: "%02d", counterMiliSec)
        lblMins.text = "\(String(format: "%02d", counterMins))’\(String(format: "%02d", counterSecs))’"
        collectionView.reloadData()
    }
}

extension StopWatchVC {
    //MARK:-Picker View Setup
    func PickerViewConnection() {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1764705882, blue: 0.2039215686, alpha: 1)
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonTapped))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onCancelButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancel, flexibleSpace, done], animated: false)
    }
    
    //MARK:- The Function For the Picker Done button
    @objc func onDoneButtonTapped() {
        let dataIndex: Int = picker.selectedRow(inComponent: 0)
        if isPlaying {
            btnPause.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
            btnPlay.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.43)
            timer.invalidate()
            isPlaying = false
        }
        totalRestTimeInSec = arrTimeSlotInSec[dataIndex]
        btnRecoveryTime.setTitle(arrTimeSlot[dataIndex], for: .normal)
        restTimeInSec = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).2
        restTimeInMin = secondsToHoursMinutesSeconds(seconds: totalRestTimeInSec).1
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        
        resetOnStop()
    }
    
    //MARK:- The Function For the Picker Cancel button
    @objc func onCancelButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
}

class ProgressCollectionCell: UICollectionViewCell {
    @IBOutlet weak var progressBar: UIProgressView!
}

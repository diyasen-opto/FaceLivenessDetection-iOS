import UIKit
import AVFoundation
import CoreData

class SettingsViewController: UIViewController{
    
    static let CAMERA_LENS_DEFAULT = 1
    static let LIVENESS_THRESHOLD_DEFAULT = Float(0.7)
    
    @IBOutlet weak var cameraLensSwitch: UISwitch!
    @IBOutlet weak var livenessThresholdLbl: UILabel!

    @IBOutlet weak var cameraLensLbl: UILabel!
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: ViewController.CORE_DATA_NAME)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let defaults = UserDefaults.standard
        let cameraLens = defaults.integer(forKey: "camera_lens")

        if(cameraLens == 0) {
            cameraLensSwitch.isOn = false
            cameraLensLbl.text = "Back"
        } else {
            cameraLensSwitch.isOn = true
            cameraLensLbl.text = "Front"
        }
        
        let livenessThreshold = defaults.float(forKey: "liveness_threshold")
        livenessThresholdLbl.text = String(livenessThreshold)
    }
    
    static func setDefaultSettings() {
        let defaults = UserDefaults.standard
        let defaultChanged = defaults.bool(forKey: "default_changed")
        if(defaultChanged == false) {
            defaults.set(true, forKey: "default_changed")
            
            defaults.set(SettingsViewController.CAMERA_LENS_DEFAULT, forKey: "camera_lens")
            defaults.set(SettingsViewController.LIVENESS_THRESHOLD_DEFAULT, forKey: "liveness_threshold")
            
        }
    }
        
    @IBAction func done_clicked(_ sender: Any) {
        if let vc = self.presentingViewController as? ViewController {
            self.dismiss(animated: true, completion: {
//                vc.personView.reloadData()
            })
        }
    }
    
    @IBAction func cameraLens_switch(_ sender: Any) {
        let defaults = UserDefaults.standard
        if(cameraLensSwitch.isOn) {
            defaults.set(1, forKey: "camera_lens")
            cameraLensLbl.text = "Front"
        } else {
            defaults.set(0, forKey: "camera_lens")
            cameraLensLbl.text = "Back"
        }
    }
    
    func threshold_clicked(mode: Int) {
        var title = "Liveness threshold"
        
        let alertController = UIAlertController(title: title, message: "Please input a number between 0 and 1.", preferredStyle: .alert)

        let minimum = Float(0)
        let maximum = Float(1)
        alertController.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            
            let defaults = UserDefaults.standard
            
            if(mode == 0) {
                textField.text = String(defaults.float(forKey: "liveness_threshold"))
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let submitAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            var hasError = false
            var errorStr = ""
            let defaults = UserDefaults.standard
            
            if let numberString = alertController.textFields?.first?.text, let number = Float(numberString) {
                if(number < Float(minimum) || number > Float(maximum)) {
                    hasError = true
                    errorStr = "Invalid value"
                } else {
                    if(mode == 0) {
                        self.livenessThresholdLbl.text = String(number)
                        defaults.set(number, forKey: "liveness_threshold")
                    }
                }
            } else {
                hasError = true
                errorStr = "Invalid value"
            }
            
            if(hasError) {
                let errorNotification = UIAlertController(title: "Error", message: errorStr, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorNotification.addAction(okAction)
                self.present(errorNotification, animated: true, completion: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    errorNotification.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func livenessThreshold_clicked(_ sender: Any) {
        threshold_clicked(mode: 0)
    }
    
    
    @IBAction func restore_settings_clicked(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "default_changed")
        
        SettingsViewController.setDefaultSettings()
        showToast(message: "The default settings has been restored.")
        self.viewDidLoad()
    }
}


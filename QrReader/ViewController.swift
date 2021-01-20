//
//  ViewController.swift
//  QrReader
//
//  Created by jrangel on 14/01/21.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showQrReader(_ sender: Any) {
        //let vc = QrReaderViewController() //change this to your class name
        if self.storyboard != nil {
            //if let qrReaderViewController = storyboardValue.instantiateViewController(withIdentifier: "QrReaderViewController") as? QrReaderViewController {
            let qrReaderViewController = QrReaderViewController()
            //navigationController?.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(qrReaderViewController, animated: true)
            //self.present(vc, animated: true, completion: nil)
            //}
        }
        
    }
}

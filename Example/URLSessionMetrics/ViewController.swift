//
//  ViewController.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import UIKit
import URLSessionMetrics

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Send Request", style: .plain, target: self, action: #selector(ViewController.sendRequestButtonPressed(sender:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh Metrics", style: .plain, target: self, action: #selector(ViewController.refreshMetricsPressed(sender:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @objc func sendRequestButtonPressed(sender: UIBarButtonItem) {
        if let request = RequestBuilder.build(method: .GET, baseURL: "https://www.google.com").request {
            RequestManager.send(request: request) { data, response, error in
                guard let data = data else {
                    NSLog("Error \(error?.localizedDescription ?? "")")
                    return
                }

                print("Raw Response - \(data.count)")
                print("Response Object - \(String(describing: response))")
                self.refreshMetricsPressed(sender: UIBarButtonItem())
            }
        } else {
            print("failed to create request")
        }
    }

    @objc func refreshMetricsPressed(sender: UIBarButtonItem) {
        label.text = DefaultMetricsManager.shared.metrics.reduce("") { (t, metric) in
            return (t) + metric.details + "\n"
        }
    }

    @IBAction func showDebugControllerPressed(_ sender: UIButton) {
        let controller = RequestMetricsCollectionViewController.requestMetricsCollectionView()
        self.present(controller, animated: true, completion: nil)
    }

}



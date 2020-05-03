//
//  ViewController.swift
//  BackgroundTransfer
//
//  Created by Manish Kumar on 2019-12-11.
//  Copyright © 2019 Manish Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionTaskDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadFile()
    }

    func downloadFile() {
        print("Going to execute: ", #function)
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationUrl = documentsUrl.appendingPathComponent("sampleFile")

        // The files available are: 1MB   10MB   100MB   1GB   10GB   50GB   100GB   1000GB
        if let downloadUrl = URL(string: "http://speedtest.tele2.net/10MB.zip") {
            let downloadTask = URLSession.shared.dataTask(with: downloadUrl) { (data, response, err) in
                try! data?.write(to: destinationUrl)
                if err == nil {
                    print("File downloaded successfully")
                    self.uploadFile(taskID: "BackgroundUpload")
                }
            }

            downloadTask.resume()
        }
    }

    func uploadFile(taskID: String) {
        print("Going to execute: ", #function)
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationUrl = documentsUrl.appendingPathComponent("sampleFile")

        let uploadURL = URL(string: "http://speedtest.tele2.net/upload.php")
        var request = URLRequest(url: uploadURL!)
        request.httpMethod = "POST"
        let config = URLSessionConfiguration.background(withIdentifier: taskID)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let uploadTask = session.uploadTask(with: request, fromFile: destinationUrl)
        uploadTask.resume()
    }

    // This function will be called in both foreground and background transfer
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Going to execute: ", #function)
        if error == nil {
            print("Upload was successful")
        } else {
            print(error.debugDescription)
        }
    }

    /// This function will be called only if the app goes into background during the upload process. This is the last function called.
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("Going to execute: ", #function)

        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler else { return }

            appDelegate.backgroundSessionCompletionHandler = nil
            completionHandler()
            print("*** Background uploading is complete ***")
        }
    }
}



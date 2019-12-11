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
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    let destinationUrl = documentsUrl.appendingPathComponent("sampleFile")
    
     // if let url = URL(string: "https://speed.hetzner.de/100MB.bin") {
    if let downloadUrl = URL(string: "http://speedtest.tele2.net/10MB.zip") {
      let downloadTask = URLSession.shared.dataTask(with: downloadUrl) { (data, response, err) in
        try! data?.write(to: destinationUrl!)
        if err == nil {
          print("File downloaded successfully")
          self.uploadFile()
        }
      }
      
      downloadTask.resume()
      
    }
  }
  
  func uploadFile() {
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    let destinationUrl = documentsUrl.appendingPathComponent("sampleFile")
    
    let uploadURL = URL(string: "http://speedtest.tele2.net/upload.php")
    var request = URLRequest(url: uploadURL!)
    request.httpMethod = "POST"
    let config = URLSessionConfiguration.background(withIdentifier: "backgroundMeinBhejo")
    let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    let uploadTask = session.uploadTask(with: request, fromFile: destinationUrl!)
    uploadTask.resume()
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    print(#function)
    if error == nil {
      print(task.taskIdentifier)
      print("Upload was successful")
    } else {
      print(error.debugDescription)
    }
  }
  
  /// This function will be called only if the app goes into background during the upload process. This is the last function called.
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    print(#function)
    DispatchQueue.main.async {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler else { return }
      
      appDelegate.backgroundSessionCompletionHandler = nil
      completionHandler()
    }

  }
  
}



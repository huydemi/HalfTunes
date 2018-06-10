//
//  SearchVC+URLSessionDelegates.swift
//  HalfTunes
//
//  Created by Dang Quoc Huy on 6/10/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation

extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("Finished downloading to \(location).")
  }
}

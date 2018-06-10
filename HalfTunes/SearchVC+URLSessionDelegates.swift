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
    // extract the original request URL from the task
    // look up the corresponding Download in your active downloads
    // remove it from that dictionary
    guard let sourceURL = downloadTask.originalRequest?.url else { return }
    let download = downloadService.activeDownloads[sourceURL]
    downloadService.activeDownloads[sourceURL] = nil
    // generates a permanent local file path to save to
    let destinationURL = localFilePath(for: sourceURL)
    print(destinationURL)
    // move the downloaded file from its temporary file location to the desired destination file path
    // first clearing out any item at that location before you start the copy task
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationURL)
    do {
      try fileManager.copyItem(at: location, to: destinationURL)
      download?.track.downloaded = true
      // play track right away
      if let track = download?.track {
        playDownload(track)
      }
    } catch let error {
      print("Could not copy file to disk: \(error.localizedDescription)")
    }
    // use the download track’s index property to reload the corresponding cell
    if let index = download?.track.index {
      DispatchQueue.main.async {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
      }
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    // extract the URL of the provided downloadTask
    // use it to find the matching Download in dictionary of active downloads
    guard let url = downloadTask.originalRequest?.url,
      let download = downloadService.activeDownloads[url]  else { return }
    // calculate the progress
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    // generates a human-readable string showing the total download file size
    let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
    // find the cell responsible for displaying the Track
    // update its progress view and progress label
    DispatchQueue.main.async {
      if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index,
                                                                 section: 0)) as? TrackCell {
        trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
      }
    }
  }
}

//
//  SessionDelegate.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/28.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

// Represents the delegate object of downloader session. It also behave like a task manager for downloading.
class SessionDelegate: NSObject {
    
    typealias SessionChallengeFunc = (
        URLSession,
        URLAuthenticationChallenge,
        (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
    
    typealias SessionTaskChallengeFunc = (
        URLSession,
        URLSessionTask,
        URLAuthenticationChallenge,
        (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
    
    private var tasks: [URL: SessionDataTask] = [:]
    private let lock = NSLock()
    
    let onValidStatusCode = Delegate<Int,Bool>()
    let onDownloadingFinished = Delegate<(URL, Result<URLResponse, KingfisherError>), Void>()
    let onDidDownloadData = Delegate<SessionDataTask, Data?>()
    
    let onReceiveSessionChallenge = Delegate<SessionChallengeFunc, Void>()
    let onReceiveSessionTaskChallenge = Delegate<SessionChallengeFunc, Void>()
    
    func add(
        _ dataTask: URLSessionDataTask,
        url: URL,
        callback: SessionDataTask.TaskCallback) -> DownloadTask
    {
        lock.lock()
        defer { lock.unlock() }
        
        // Create a new task if necessary.
        let task = SessionDataTask(task: dataTask)
        task.onCallbackCancelled.delegate(on: self) {
            [unowned task] (self, value) in
            let (token, callback) = value
            
            let error = KingfisherError.requestError(reason: .taskCancelled(task: task, token: token))
            task.onTaskDone.call((.failure(error), [callback]))
            // No other callbacks waiting, we can clear the task now.
            if !task.containsCallbacks {
                let dataTask = task.task
                self.remove(dataTask)
            }
        }
        let token = task.addCallback(callback)
        tasks[url] = task
        return DownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func append(
        _ task: SessionDataTask,
        url: URL,
        callback: SessionDataTask.TaskCallback) -> DownloadTask
    {
        let token = task.addCallback(callback)
        return DownloadTask(sessionTask: task, cancelToken: token)
        
    }
    
    private func remove(_ task: URLSessionTask) {
        guard let url = task.originalRequest?.url else {
            return
        }
        lock.lock()
        defer {lock.unlock()}
        tasks[url] = nil
    }
    
    private func task(for task: URLSessionTask) -> SessionDataTask? {

        guard let url = task.originalRequest?.url else {
            return nil
        }
        
        lock.lock()
        defer {lock.unlock()}
        guard let sessionTask = tasks[url] else {
            return nil
        }
        guard sessionTask.task.taskIdentifier == task.taskIdentifier else {
            return nil
        }
        return sessionTask
    }
    
    func task(for url: URL) -> SessionDataTask? {
        lock.lock()
        defer { lock.unlock() }
        return tasks[url]
    }
    
    func cancelAll() {
        lock.lock()
        let taskValues = tasks.values
        lock.unlock()
        for task in taskValues {
            task.forceCancel()
        }
    }
    
    func cancel(url: URL) {
        lock.lock()
        let task = tasks[url]
        lock.unlock()
        task?.forceCancel()
    }
}

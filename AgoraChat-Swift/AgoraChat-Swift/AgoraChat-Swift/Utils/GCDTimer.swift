//
//  GCDTimer.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation


public protocol GCDTimer {
    func resume()
    func suspend()
    func cancel()
}

public class GCDTimerMaker {
    
    static func exec(_ task: (() -> ())?, interval: Int, repeats: Bool = true, async: Bool = true) -> GCDTimer? {
        
        guard let _ = task else {
            return nil
        }
        
        return TimerMaker(task,
                          deadline: .now(),
                          repeating: repeats ? .seconds(interval):.never,
                          async: async)
        
    }
}

private class TimerMaker: GCDTimer {
    
    enum TimerState {
        case running
        case stoped
    }
    
    private var state = TimerState.stoped
    
    private var timer: DispatchSourceTimer?
    
    convenience init(_ exce: (() -> ())?, deadline: DispatchTime, repeating interval: DispatchTimeInterval = .never, leeway: DispatchTimeInterval = .seconds(0), async: Bool = true) {
        self.init()

        let queue = async ? DispatchQueue.global():DispatchQueue.main
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: deadline,
                        repeating: interval,
                        leeway: leeway)
        
        timer?.setEventHandler(handler: {
            exce?()
        })
    }
    
    
    func resume() {
        guard state != .running else { return }
        state = .running
        timer?.resume()
    }
    
    func suspend() {
        guard state != .stoped else { return }
        state = .stoped
        timer?.suspend()
    }
    
    func cancel() {
        state = .stoped
        timer?.cancel()
    }
    
    
}


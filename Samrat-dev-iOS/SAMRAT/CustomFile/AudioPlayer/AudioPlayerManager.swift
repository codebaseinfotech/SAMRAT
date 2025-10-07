//
//  AudioPlayerManager.swift
//  ela
//
//  Created by Bastien Falcou on 4/14/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import AVFoundation

let audioPercentageUserInfoKey = "percentage"
let audioTotalDurationUserInfoKey = "duration"
protocol AudioPlayerWaveFormDelegate {
    func audioDidUpdate(totalTime:TimeInterval , currentTime:TimeInterval)
}

final class AudioPlayerManager: NSObject {
	
    private var delegate:AudioPlayerWaveFormDelegate?
    
	var isRunning: Bool {
		guard let audioPlayer = self.audioPlayer, audioPlayer.isPlaying else {
			return false
		}
		return true
	}

    init(_ delegate:AudioPlayerWaveFormDelegate) {
        self.delegate = delegate
    }
    
	private var audioPlayer: AVAudioPlayer?
	private var audioMeteringLevelTimer: Timer?

	// MARK: - Reinit and play from the beginning
    func loadAudio(at url: URL ,audioVisualizationTimeInterval timeInterval: TimeInterval = 0.05) throws ->TimeInterval {
        try self.audioPlayer = AVAudioPlayer(contentsOf: url)
        self.audioPlayer?.prepareToPlay()
        self.setupPlayer(with: timeInterval)
        return self.audioPlayer!.duration
        
    }
    
	func play(_ data: Data, with audioVisualizationTimeInterval: TimeInterval = 0.05) throws -> TimeInterval {
		try self.audioPlayer = AVAudioPlayer(data: data)
		
		print("Started to play sound")

		return self.audioPlayer!.duration
	}
    
    func setTime(_ timeInterVal:TimeInterval) throws {
        self.audioPlayer?.currentTime = timeInterVal // play(atTime: timeInterVal)
    }
    
	private func setupPlayer(with audioVisualizationTimeInterval: TimeInterval) {
		if let player = self.audioPlayer {
			player.delegate = self
			self.audioMeteringLevelTimer = Timer.scheduledTimer(timeInterval: audioVisualizationTimeInterval, target: self,
				selector: #selector(AudioPlayerManager.timerDidUpdateMeter), userInfo: nil, repeats: true)
		}
	}

	// MARK: - Resume and pause current if exists

	func resume() throws -> TimeInterval {
		if self.audioPlayer?.play() == false {
			print("Audio Player did fail to resume for internal reason")
			throw AudioErrorType.internalError
		}

		print("Resumed sound")
        if self.audioPlayer == nil {
            throw AudioErrorType.notCurrentlyPlaying
        }
        
		return self.audioPlayer!.duration - self.audioPlayer!.currentTime
	}

	func pause() throws {
		if !self.isRunning {
			print("Audio Player did fail to start: there is nothing currently playing")
			throw AudioErrorType.notCurrentlyPlaying
		}

		self.audioPlayer?.pause()
		print("Paused current playing sound")
	}

	func stop() throws {
		if !self.isRunning {
			print("Audio Player did fail to stop: there is nothing currently playing")
			throw AudioErrorType.notCurrentlyPlaying
		}
		
		self.audioPlayer?.stop()
		print("Audio player stopped")
	}
	
	// MARK: - Private

	@objc private func timerDidUpdateMeter() {
		if self.isRunning {
			self.audioPlayer!.updateMeters()
            guard let currentTime = self.audioPlayer?.currentTime else {return}
//            let averagePower = self.audioPlayer!.averagePower(forChannel: 0)
//            let percentage: Float = pow(10, (0.05 * averagePower))
            guard let totalTime = self.audioPlayer?.duration else {return}
            if let delegate = self.delegate {
                delegate.audioDidUpdate(totalTime: totalTime, currentTime: currentTime)
            }
//            NotificationCenter.default.post(name: NSNotification.Name.audioPlayerManagerMeteringLevelDidUpdateNotification, object: self, userInfo: [audioPercentageUserInfoKey: time,audioTotalDurationUserInfoKey:totalTime])
		}
	}
}

extension AudioPlayerManager: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		NotificationCenter.default.post(name: .audioPlayerManagerMeteringLevelDidFinishNotification, object: self)
	}
}

extension Notification.Name {
	static let audioPlayerManagerMeteringLevelDidUpdateNotification = Notification.Name("AudioPlayerManagerMeteringLevelDidUpdateNotification")
	static let audioPlayerManagerMeteringLevelDidFinishNotification = Notification.Name("AudioPlayerManagerMeteringLevelDidFinishNotification")
}

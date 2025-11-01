//
//  AnalyticsService.swift
//  BetterSelf
//
//  Created by Adam Damou on 01/11/2025.
//

import Foundation
import FirebaseAnalytics

struct AnalyticsService {
  static let anonKey = "anon_id"
  static let consentPropertyKey = "consented"

  // MARK: - Anonymous ID

  static func getAnonID() -> String {
    if let id = UserDefaults.standard.string(forKey: anonKey) { return id }
    let id = UUID().uuidString
    UserDefaults.standard.set(id, forKey: anonKey)
    return id
  }

  // MARK: - Configure / Defaults

  /// Configure analytics defaults and consent state. Keeps collection enabled by default for anonymous analytics.
  /// - Parameter consentedToIdentifiableTracking: Whether the user consented to setting a user ID and identifiable tracking.
  static func configure(consentedToIdentifiableTracking: Bool) {
    // Default event parameters (sent with every event)
    var defaults: [String: NSObject] = [
      "anon_id": getAnonID() as NSString,
      "app_version": (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") as NSString
    ]

    // Optionally include build number if available
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      defaults["app_build"] = build as NSString
    }

    Analytics.setDefaultEventParameters(defaults)

    // Reflect consent status as a user property (string values only)
    Analytics.setUserProperty(consentedToIdentifiableTracking ? "true" : "false", forName: consentPropertyKey)

    // Apply identifiable user state
    if consentedToIdentifiableTracking == false {
      // Ensure no userId is set
      Analytics.setUserID(nil)
    }
  }

  // MARK: - Logging

  static func log(_ name: String, params: [String: Any]? = nil) {
    Analytics.logEvent(name, parameters: params)
  }

  static func setUser(_ userId: String?, consented: Bool) {
    // Only set if user consented to identifiable tracking
    if consented {
      Analytics.setUserID(userId)
    } else {
      Analytics.setUserID(nil)
    }
  }

  /// Update consent and handle full opt-out if needed.
  /// - Parameters:
  ///   - consented: If true, identifiable tracking (user ID) is allowed. If false, user ID cleared.
  ///   - userId: Optional user identifier to set when consented.
  static func updateConsent(consented: Bool, userId: String? = nil) {
    Analytics.setUserProperty(consented ? "true" : "false", forName: consentPropertyKey)
    if consented {
      if let userId {
        Analytics.setUserID(userId)
      }
      setAnalyticsCollectionEnabled(true)
    } else {
      // Clear user id and optionally perform a full reset
      Analytics.setUserID(nil)
      // Keep anonymous analytics enabled by default; callers can fully opt-out using setAnalyticsCollectionEnabled(false)
    }
  }

  // MARK: - Collection control

  /// Enable/disable analytics collection entirely (for full opt-out). Consider calling `resetOnOptOut()` when disabling.
  static func setAnalyticsCollectionEnabled(_ enabled: Bool) {
    Analytics.setAnalyticsCollectionEnabled(enabled)
  }

  /// Reset analytics data (rotates app instance ID and clears user properties). Use when user fully opts out.
  static func resetOnOptOut() {
    Analytics.setUserID(nil)
    Analytics.resetAnalyticsData()
  }

  // MARK: - Screen tracking

  static func logScreenView(screenName: String, screenClass: String? = nil) {
    var params: [String: Any] = [
      AnalyticsParameterScreenName: screenName
    ]
    if let screenClass { params[AnalyticsParameterScreenClass] = screenClass }
    Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
  }

  // MARK: - User properties

  static func setUserProperty(_ value: String?, forName name: String) {
    Analytics.setUserProperty(value, forName: name)
  }

  // MARK: - Canonical events

  enum EventName {
    static let appOpened = "app_opened"
    static let reminderCreated = "reminder_created"
    static let reminderDeleted = "reminder_deleted"
    static let folderCreated = "folder_created"
    static let shareTapped = "share_tapped"
    static let reminderMoved = "reminder_moved"
    static let reminderPinned = "reminder_pinned"
    static let reminderUnpinned = "reminder_unpinned"
    static let folderDeleted = "folder_deleted"
    static let linkOpened = "link_opened"
    static let reminderEdited = "reminder_edited"
    static let buttonTapped = "button_tapped"
  }
}

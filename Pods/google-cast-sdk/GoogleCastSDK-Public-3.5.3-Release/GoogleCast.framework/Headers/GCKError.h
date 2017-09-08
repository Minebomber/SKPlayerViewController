// Copyright 2013 Google Inc.

#import <GoogleCast/GCKDefines.h>

#import <Foundation/Foundation.h>

#ifdef USE_CAST_DYNAMIC_FRAMEWORK
#define GCKErrorClass NSClassFromString(@"GCKError")
#endif

/** @file GCKError.h
 * Framework errors.
 */

GCK_ASSUME_NONNULL_BEGIN

/**
 * @enum GCKErrorCode
 * Framework error codes.
 */
typedef NS_ENUM(NSInteger, GCKErrorCode) {
  /**
   * Error Code indicating no error.
   */
  GCKErrorCodeNoError = 0,

  /**
   * Error code indicating a network I/O error.
   */
  GCKErrorCodeNetworkError = 1,

  /**
   * Error code indicating that an operation has timed out.
   */
  GCKErrorCodeTimeout = 2,

  /**
   * Error code indicating an authentication error.
   */
  GCKErrorCodeDeviceAuthenticationFailure = 3,

  /**
   * Error code indicating that an invalid request was made.
   */
  GCKErrorCodeInvalidRequest = 4,

  /**
   * Error code indicating that an in-progress request has been cancelled, most likely because
   * another action has preempted it.
   */
  GCKErrorCodeCancelled = 5,

  /**
   * Error code indicating that a request has been replaced by another request of the same type.
   */
  GCKErrorCodeReplaced = 6,

  /**
   * Error code indicating that the request was disallowed and could not be completed.
   */
  GCKErrorCodeNotAllowed = 7,

  /**
   * Error code indicating that a request could not be made because the same type of request is
   * still in process.
   */
  GCKErrorCodeDuplicateRequest = 8,

  /**
   * Error code indicating that the request is not allowed in the current state.
   */
  GCKErrorCodeInvalidState = 9,

  /**
   * Error code indicating that data could not be sent because the send buffer is full.
   */
  GCKErrorCodeSendBufferFull = 10,

  /**
   * Error indicating that the request could not be sent because the message exceeds the maximum
   * allowed message size.
   */
  GCKErrorCodeMessageTooBig = 11,

  /**
   * Error indicating that a channel operation could not be completed because the channel is not
   * currently connected.
   */
  GCKErrorCodeChannelNotConnected = 12,

  /**
   * Error indicating that the user is not authorized to use a Cast device.
   */
  GCKErrorCodeDeviceAuthorizationFailure = 13,

  /**
   * Error indicating that a device request could not be completed because there is no connection
   * currently established to the device.
   */
  GCKErrorCodeDeviceNotConnected = 14,

  /**
   * Error indicating that there is a mismatch between the protocol versions being used on the
   * sender and the receiver for a given namespace implementation.
   */
  GCKErrorCodeProtocolVersionMismatch = 15,

  /**
   * Error indicating that the maximum number of users is already connected to the receiver.
   */
  GCKErrorCodeMaxUsersConnected = 16,

  /**
   * Error indicating that the network is not reachable.
   */
  GCKErrorCodeNetworkNotReachable = 17,

  /**
   * Error code indicating that a requested application could not be found.
   */
  GCKErrorCodeApplicationNotFound = 20,

  /**
   * Error code indicating that a requested application is not currently running.
   */
  GCKErrorCodeApplicationNotRunning = 21,

  /**
   * Error code indicating that the application session ID was not valid.
   */
  GCKErrorCodeInvalidApplicationSessionID = 22,

  /**
   * Error code indicating that a media load failed on the receiver side.
   */
  GCKErrorCodeMediaLoadFailed = 30,

  /**
   * Error code indicating that a media media command failed because of the media player state.
   */
  GCKErrorCodeInvalidMediaPlayerState = 31,

  /**
   * Error indicating that no media session is currently available.
   */
  GCKErrorCodeNoMediaSession = 32,

  /**
   * Error code indicating that device authentication failed due to error received.
   */
  GCKErrorCodeAuthenticationErrorReceived = 40,

  /**
   * Error code indicating that device authentication failed because a malformed client certificate
   * is received.
   */
  GCKErrorCodeMalformedClientCertificate = 41,

  /**
   * Error code indicating that device authentication failed because certificate received from
   * Chromecast is not expected format.
   */
  GCKErrorCodeNotX509Certificate = 42,

  /**
   * Error code indicating that device authentication failed because the device certificate is not
   * trusted.
   */
  GCKErrorCodeDeviceCertificateNotTrusted = 43,

  /**
   * Error code indicating that device authentication failed because the SSL certificate is not
   * trusted.
   */
  GCKErrorCodeSSLCertificateNotTrusted = 44,

  /**
   * Error code indicating that device authentication failed because the response from device is
   * malformed.
   */
  GCKErrorCodeMalformedAuthenticationResponse = 45,

  /**
   * Error code indicating that device authentication failed because the device capability shows
   * unsupported.
   */
  GCKErrorCodeDeviceCapabilityNotSupported = 46,

  /**
   * Error code indicating that device authentication failed because CRL from device is invalid.
   */
  GCKErrorCodeCRLInvalid = 47,

  /**
   * Error code indicating that device authentication failed because device certificate is revoked
   * by CRL.
   */
  GCKErrorCodeCRLCheckFailed = 48,

  /**
   * Error code indicating that the application moved to the background.
   */
  GCKErrorCodeAppDidEnterBackground = 91,

  /**
   * Error code indicating that the connection to the receiver was closed.
   */
  GCKErrorCodeDisconnected = 92,

  /**
   * Error code indicating that the feature or action is unsupported either on this iOS device or
   * the receiver.
   */
  GCKErrorCodeUnsupportedFeature = 93,

  /**
   * Error code indicating that an unknown, unexpected error has occurred.
   */
  GCKErrorCodeUnknown = 99,
};

/**
 * The key for the customData JSON object associated with the error in the userInfo dictionary.
 */
GCK_EXTERN NSString *const kGCKErrorCustomDataKey;

/**
 * The error domain for GCKErrorCode.
 */
GCK_EXTERN NSString *const kGCKErrorDomain;

/**
 * A subclass of <a href="https://goo.gl/WJbrdL"><b>NSError</b></a> for framework errors.
 */
GCK_EXPORT
@interface GCKError : NSError

/** Constructs a GCKError with the given error code. */
+ (GCKError *)errorWithCode:(GCKErrorCode)code;

/** Constructs a GCKError with the given error code and optional custom data. */
+ (GCKError *)errorWithCode:(GCKErrorCode)code customData:(id GCK_NULLABLE_TYPE)customData;

/** Returns the human-readable description for a given error code. */
+ (NSString *)enumDescriptionForCode:(GCKErrorCode)code;

@end

GCK_ASSUME_NONNULL_END

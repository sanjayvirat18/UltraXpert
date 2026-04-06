import Foundation
import LocalAuthentication

final class SecurityManager {
    static let shared = SecurityManager()
    private init() {}

    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock UltraXpert with FaceID / TouchID"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authenticationError?.localizedDescription ?? "Authentication failed")
                    }
                }
            }
        } else {
            completion(false, error?.localizedDescription ?? "Biometrics not available")
        }
    }

    func biometricsType() -> String {
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "None"
        @unknown default: return "Biometrics"
        }
    }
}

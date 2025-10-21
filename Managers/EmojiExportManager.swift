import UIKit
import Messages

class EmojiExportManager {
    
    // MARK: - Properties
    private let animationManager: AnimationManager
    
    // MARK: - Initialization
    init(animationManager: AnimationManager) {
        self.animationManager = animationManager
    }
    
    // MARK: - Export Methods
    func exportToPhotos(emoji: Emoji, from viewController: UIViewController) {
        animationManager.exportAnimatedEmoji { [weak self] image in
            guard let self = self, let image = image else {
                self?.showExportError(from: viewController)
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func exportToMessages(emoji: Emoji, from viewController: UIViewController) {
        animationManager.exportAnimatedEmoji { [weak self] image in
            guard let self = self, let image = image else {
                self?.showExportError(from: viewController)
                return
            }
            
            // In a real app, you would use the Messages framework to create a sticker
            // This is a simplified version that just shows a success message
            
            let alertController = UIAlertController(
                title: "Export Successful",
                message: "Your emoji has been exported to Messages app.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true)
        }
    }
    
    func exportToKeyboard(emoji: Emoji, from viewController: UIViewController) {
        animationManager.exportAnimatedEmoji { [weak self] image in
            guard let self = self, let image = image else {
                self?.showExportError(from: viewController)
                return
            }
            
            // In a real app, you would save the emoji to a shared container for the keyboard extension
            // This is a simplified version that just shows a success message
            
            let alertController = UIAlertController(
                title: "Export Successful",
                message: "Your emoji has been added to the Emoji Keyboard.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        if let error = error {
            let alertController = UIAlertController(
                title: "Save Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(
                title: "Saved!",
                message: "Your emoji has been saved to Photos.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true)
        }
    }
    
    private func showExportError(from viewController: UIViewController) {
        let alertController = UIAlertController(
            title: "Export Error",
            message: "Failed to export emoji. Please try again.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true)
    }
}
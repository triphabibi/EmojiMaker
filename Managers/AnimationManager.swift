import UIKit

class AnimationManager {
    
    // MARK: - Properties
    private weak var canvasView: UIView?
    private var emoji: Emoji?
    private var isAnimating = false
    private var animationTimer: Timer?
    
    // MARK: - Initialization
    init(canvasView: UIView) {
        self.canvasView = canvasView
    }
    
    // MARK: - Public Methods
    func setEmoji(_ emoji: Emoji) {
        self.emoji = emoji
    }
    
    func startAnimation() {
        guard let emoji = emoji, emoji.isAnimated, !isAnimating else { return }
        
        isAnimating = true
        
        // Create animation timer
        animationTimer = Timer.scheduledTimer(
            timeInterval: 0.05,
            target: self,
            selector: #selector(animationTick),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopAnimation() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Reset elements to original positions
        resetElements()
    }
    
    func isCurrentlyAnimating() -> Bool {
        return isAnimating
    }
    
    // MARK: - Animation Methods
    @objc private func animationTick() {
        guard let emoji = emoji, let canvasView = canvasView else { return }
        
        // Animate each element
        for (index, _) in emoji.elements.enumerated() {
            guard let elementView = canvasView.viewWithTag(emoji.elements[index].id.hashValue) else { continue }
            
            // Apply animation based on element index
            let animationType = index % 4
            
            switch animationType {
            case 0:
                // Bounce animation
                applyBounceAnimation(to: elementView)
            case 1:
                // Rotate animation
                applyRotateAnimation(to: elementView)
            case 2:
                // Pulse animation
                applyPulseAnimation(to: elementView)
            case 3:
                // Shake animation
                applyShakeAnimation(to: elementView)
            default:
                break
            }
        }
    }
    
    private func applyBounceAnimation(to view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            view.transform = view.transform.translatedBy(x: 0, y: -10)
        })
    }
    
    private func applyRotateAnimation(to view: UIView) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveLinear, .repeat], animations: {
            view.transform = view.transform.rotated(by: .pi / 8)
        })
    }
    
    private func applyPulseAnimation(to view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            view.transform = view.transform.scaledBy(x: 1.1, y: 1.1)
        })
    }
    
    private func applyShakeAnimation(to view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-5.0, 5.0, -5.0, 5.0, -2.5, 2.5, -1.0, 1.0, 0.0]
        animation.repeatCount = .greatestFiniteMagnitude
        view.layer.add(animation, forKey: "shake")
    }
    
    private func resetElements() {
        guard let emoji = emoji, let canvasView = canvasView else { return }
        
        // Remove all animations
        for element in emoji.elements {
            guard let elementView = canvasView.viewWithTag(element.id.hashValue) else { continue }
            
            elementView.layer.removeAllAnimations()
            
            // Reset transform
            var transform = CGAffineTransform.identity
            transform = transform.scaledBy(x: element.scale * (element.isFlipped ? -1 : 1), y: element.scale)
            transform = transform.rotated(by: element.rotation)
            
            UIView.animate(withDuration: 0.2) {
                elementView.transform = transform
                elementView.center = element.position
            }
        }
    }
    
    // MARK: - Export Methods
    func exportAnimatedEmoji(completion: @escaping (UIImage?) -> Void) {
        guard let emoji = emoji, let canvasView = canvasView else {
            completion(nil)
            return
        }
        
        // If not animated, just export a static image
        if !emoji.isAnimated {
            let image = renderToImage()
            completion(image)
            return
        }
        
        // For animated emoji, we would need to create a GIF
        // This is a simplified version that just returns the first frame
        let image = renderToImage()
        completion(image)
        
        // In a real implementation, you would:
        // 1. Capture multiple frames of the animation
        // 2. Convert them to a GIF
        // 3. Return the GIF data
    }
    
    private func renderToImage() -> UIImage? {
        guard let canvasView = canvasView else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        canvasView.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
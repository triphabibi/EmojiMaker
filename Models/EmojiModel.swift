import UIKit

struct EmojiElement: Codable {
    var id: UUID
    var imageData: Data?
    var text: String?
    var font: String?
    var fontSize: CGFloat
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    var zPosition: Int
    var isFlipped: Bool
    
    init(id: UUID = UUID(), imageData: Data? = nil, text: String? = nil, font: String? = "Helvetica", 
         fontSize: CGFloat = 40, position: CGPoint = .zero, scale: CGFloat = 1.0, 
         rotation: CGFloat = 0, zPosition: Int = 0, isFlipped: Bool = false) {
        self.id = id
        self.imageData = imageData
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.zPosition = zPosition
        self.isFlipped = isFlipped
    }
}

class Emoji: Codable {
    var id: UUID
    var name: String
    var elements: [EmojiElement]
    var isAnimated: Bool
    var animationDuration: TimeInterval
    var createdDate: Date
    
    init(id: UUID = UUID(), name: String = "New Emoji", elements: [EmojiElement] = [], 
         isAnimated: Bool = false, animationDuration: TimeInterval = 1.0, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.elements = elements
        self.isAnimated = isAnimated
        self.animationDuration = animationDuration
        self.createdDate = createdDate
    }
    
    func addElement(_ element: EmojiElement) {
        elements.append(element)
    }
    
    func removeElement(withID id: UUID) {
        elements.removeAll { $0.id == id }
    }
    
    func moveElementToFront(withID id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        let maxZ = elements.map { $0.zPosition }.max() ?? 0
        var element = elements[index]
        element.zPosition = maxZ + 1
        elements[index] = element
    }
    
    func moveElementToBack(withID id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        let minZ = elements.map { $0.zPosition }.min() ?? 0
        var element = elements[index]
        element.zPosition = minZ - 1
        elements[index] = element
    }
}

// Extension to make CGPoint codable
extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(CGFloat.self)
        let y = try container.decode(CGFloat.self)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }
}
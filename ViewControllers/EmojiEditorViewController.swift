import UIKit

class EmojiEditorViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: EmojiEditorDelegate?
    var emoji: Emoji?
    
    private var selectedElement: EmojiElement?
    private var initialElementPosition: CGPoint = .zero
    private var initialPanPosition: CGPoint = .zero
    private var initialPinchScale: CGFloat = 1.0
    private var initialRotation: CGFloat = 0.0
    
    // MARK: - UI Components
    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Text", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let animateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Animate", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let fontKeyboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fonts", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        
        if emoji == nil {
            emoji = Emoji()
        }
        
        renderEmoji()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Emoji Editor"
        view.backgroundColor = .systemBackground
        
        // Add navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        
        // Add canvas view
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.heightAnchor.constraint(equalTo: canvasView.widthAnchor)
        ])
        
        // Add toolbar view
        view.addSubview(toolbarView)
        NSLayoutConstraint.activate([
            toolbarView.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 20),
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Add toolbar buttons
        toolbarView.addSubview(addTextButton)
        toolbarView.addSubview(addImageButton)
        toolbarView.addSubview(animateButton)
        toolbarView.addSubview(fontKeyboardButton)
        toolbarView.addSubview(saveButton)
        
        let buttonWidth = (view.bounds.width - 40) / 5
        
        NSLayoutConstraint.activate([
            addTextButton.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            addTextButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 10),
            addTextButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            addImageButton.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            addImageButton.leadingAnchor.constraint(equalTo: addTextButton.trailingAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            animateButton.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            animateButton.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor),
            animateButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            fontKeyboardButton.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            fontKeyboardButton.leadingAnchor.constraint(equalTo: animateButton.trailingAnchor),
            fontKeyboardButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            saveButton.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: fontKeyboardButton.trailingAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        
        // Add button targets
        addTextButton.addTarget(self, action: #selector(addTextButtonTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        animateButton.addTarget(self, action: #selector(animateButtonTapped), for: .touchUpInside)
        fontKeyboardButton.addTarget(self, action: #selector(fontKeyboardButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        canvasView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        canvasView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        canvasView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        canvasView.addGestureRecognizer(rotationGesture)
    }
    
    // MARK: - Emoji Rendering
    private func renderEmoji() {
        // Clear canvas
        for subview in canvasView.subviews {
            subview.removeFromSuperview()
        }
        
        // Render each element
        guard let emoji = emoji else { return }
        
        // Sort elements by z-position
        let sortedElements = emoji.elements.sorted { $0.zPosition < $1.zPosition }
        
        for element in sortedElements {
            if let imageData = element.imageData, let image = UIImage(data: imageData) {
                let imageView = UIImageView(image: image)
                configureElementView(imageView, with: element)
            } else if let text = element.text, let font = element.font {
                let label = UILabel()
                label.text = text
                label.font = UIFont(name: font, size: element.fontSize) ?? UIFont.systemFont(ofSize: element.fontSize)
                label.textAlignment = .center
                configureElementView(label, with: element)
            }
        }
    }
    
    private func configureElementView(_ view: UIView, with element: EmojiElement) {
        view.tag = element.id.hashValue
        view.isUserInteractionEnabled = true
        
        // Set position
        view.center = element.position
        
        // Set transform
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: element.scale * (element.isFlipped ? -1 : 1), y: element.scale)
        transform = transform.rotated(by: element.rotation)
        view.transform = transform
        
        // Add to canvas
        canvasView.addSubview(view)
        
        // Add border if selected
        if let selectedElement = selectedElement, selectedElement.id == element.id {
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        
        // Check if tapped on an element
        for subview in canvasView.subviews.reversed() {
            if subview.frame.contains(location) {
                // Find the element by tag
                if let element = emoji?.elements.first(where: { $0.id.hashValue == subview.tag }) {
                    selectElement(element)
                    return
                }
            }
        }
        
        // If tapped on empty space, deselect
        deselectElement()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let selectedElement = selectedElement,
              let index = emoji?.elements.firstIndex(where: { $0.id == selectedElement.id }) else { return }
        
        switch gesture.state {
        case .began:
            initialElementPosition = selectedElement.position
            initialPanPosition = gesture.location(in: canvasView)
        case .changed:
            let translation = gesture.translation(in: canvasView)
            let newPosition = CGPoint(
                x: initialElementPosition.x + translation.x,
                y: initialElementPosition.y + translation.y
            )
            
            // Update element position
            emoji?.elements[index].position = newPosition
            renderEmoji()
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedElement = selectedElement,
              let index = emoji?.elements.firstIndex(where: { $0.id == selectedElement.id }) else { return }
        
        switch gesture.state {
        case .began:
            initialPinchScale = selectedElement.scale
        case .changed:
            // Update element scale
            let newScale = initialPinchScale * gesture.scale
            emoji?.elements[index].scale = newScale
            renderEmoji()
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedElement = selectedElement,
              let index = emoji?.elements.firstIndex(where: { $0.id == selectedElement.id }) else { return }
        
        switch gesture.state {
        case .began:
            initialRotation = selectedElement.rotation
        case .changed:
            // Update element rotation
            let newRotation = initialRotation + gesture.rotation
            emoji?.elements[index].rotation = newRotation
            renderEmoji()
        default:
            break
        }
    }
    
    // MARK: - Element Selection
    private func selectElement(_ element: EmojiElement) {
        selectedElement = element
        renderEmoji()
    }
    
    private func deselectElement() {
        selectedElement = nil
        renderEmoji()
    }
    
    // MARK: - Button Actions
    @objc private func addTextButtonTapped() {
        let alertController = UIAlertController(title: "Add Text", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter text"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self, let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            
            let centerPoint = CGPoint(x: self.canvasView.bounds.width / 2, y: self.canvasView.bounds.height / 2)
            let element = EmojiElement(text: text, position: centerPoint)
            
            self.emoji?.addElement(element)
            self.renderEmoji()
            self.selectElement(element)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func addImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc private func animateButtonTapped() {
        // Toggle animation state
        emoji?.isAnimated = !(emoji?.isAnimated ?? false)
        
        // Update button title
        if emoji?.isAnimated == true {
            animateButton.setTitle("Stop Animation", for: .normal)
            // Start animation preview
            startAnimationPreview()
        } else {
            animateButton.setTitle("Animate", for: .normal)
            // Stop animation preview
            stopAnimationPreview()
        }
    }
    
    @objc private func fontKeyboardButtonTapped() {
        // Show font keyboard
        let fontVC = FontKeyboardViewController()
        fontVC.delegate = self
        let navController = UINavigationController(rootViewController: fontVC)
        present(navController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Save emoji
        delegate?.didSaveEmoji(emoji!)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Animation
    private func startAnimationPreview() {
        // Implement animation preview
    }
    
    private func stopAnimationPreview() {
        // Stop animation preview
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EmojiEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.pngData() else {
            picker.dismiss(animated: true)
            return
        }
        
        let centerPoint = CGPoint(x: canvasView.bounds.width / 2, y: canvasView.bounds.height / 2)
        let element = EmojiElement(imageData: imageData, position: centerPoint)
        
        emoji?.addElement(element)
        renderEmoji()
        selectElement(element)
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - FontKeyboardDelegate
extension EmojiEditorViewController: FontKeyboardDelegate {
    func didSelectFont(_ fontName: String) {
        guard let selectedElement = selectedElement,
              let index = emoji?.elements.firstIndex(where: { $0.id == selectedElement.id }),
              selectedElement.text != nil else { return }
        
        emoji?.elements[index].font = fontName
        renderEmoji()
    }
}

// MARK: - FontKeyboardDelegate Protocol
protocol FontKeyboardDelegate: AnyObject {
    func didSelectFont(_ fontName: String)
}

// MARK: - FontKeyboardViewController
class FontKeyboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var delegate: FontKeyboardDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FontCell.self, forCellWithReuseIdentifier: "FontCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let fonts = [
        "Helvetica", "Arial", "Verdana", "Avenir", "Futura",
        "Times New Roman", "Georgia", "Palatino", "Baskerville",
        "Courier", "Courier New", "Menlo", "Monaco"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Select Font"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCell", for: indexPath) as! FontCell
        cell.configure(with: fonts[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fontName = fonts[indexPath.item]
        delegate?.didSelectFont(fontName)
        dismiss(animated: true)
    }
}

// MARK: - FontCell
class FontCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 8
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with fontName: String) {
        label.text = "Aa"
        label.font = UIFont(name: fontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
    }
}
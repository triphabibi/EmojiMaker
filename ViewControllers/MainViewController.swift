import UIKit

class MainViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create New Emoji", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var emojis: [Emoji] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedEmojis()
    }
    
    private func setupUI() {
        title = "Emoji Maker"
        view.backgroundColor = .systemBackground
        
        // Add collection view
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Add create button
        view.addSubview(createButton)
        NSLayoutConstraint.activate([
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 200),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        createButton.addTarget(self, action: #selector(createNewEmoji), for: .touchUpInside)
    }
    
    private func loadSavedEmojis() {
        // In a real app, load from UserDefaults or Core Data
        // For now, create some sample emojis
        let emoji1 = Emoji(name: "Happy Face")
        let emoji2 = Emoji(name: "Cool Emoji")
        let emoji3 = Emoji(name: "Party Time")
        
        emojis = [emoji1, emoji2, emoji3]
        collectionView.reloadData()
    }
    
    @objc private func createNewEmoji() {
        let editorVC = EmojiEditorViewController()
        editorVC.delegate = self
        let navController = UINavigationController(rootViewController: editorVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(with: emojis[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let editorVC = EmojiEditorViewController()
        editorVC.emoji = emojis[indexPath.item]
        editorVC.delegate = self
        let navController = UINavigationController(rootViewController: editorVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: width)
    }
}

// MARK: - EmojiEditorDelegate
extension MainViewController: EmojiEditorDelegate {
    func didSaveEmoji(_ emoji: Emoji) {
        if let index = emojis.firstIndex(where: { $0.id == emoji.id }) {
            emojis[index] = emoji
        } else {
            emojis.append(emoji)
        }
        collectionView.reloadData()
    }
}

// MARK: - EmojiCell
class EmojiCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
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
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with emoji: Emoji) {
        nameLabel.text = emoji.name
        
        // In a real app, render the emoji to an image
        // For now, just show a placeholder
        imageView.backgroundColor = .systemGray5
        
        // If we had a rendered image:
        // imageView.image = renderEmojiToImage(emoji)
    }
}

// MARK: - EmojiEditorDelegate
protocol EmojiEditorDelegate: AnyObject {
    func didSaveEmoji(_ emoji: Emoji)
}
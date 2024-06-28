import UIKit

class KeyboardViewController: UIInputViewController {

    var buttonStackView: UIStackView!
    var tokenSlider: UISlider!
    var tokenLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var shouldReplaceEntireText = false
    var isFirstChunk = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground

        // Token Slider
        tokenSlider = UISlider()
        tokenSlider.minimumValue = 1
        tokenSlider.maximumValue = 500
        tokenSlider.value = 100
        tokenSlider.addTarget(self, action: #selector(tokenSliderChanged), for: .valueChanged)
        
        // Token Label
        tokenLabel = UILabel()
        tokenLabel.text = "Tokens: 100"
        tokenLabel.textAlignment = .center
        
        // Buttons
        let buttonTitles = ["Prompt+Clipboard", "Prompt Only", "Extend Text"]
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: [#selector(promptPlusClipboardTapped), #selector(promptOnlyTapped), #selector(extendTextTapped)][index], for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        // Activity Indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true

        // Add subviews
        [tokenSlider, tokenLabel, buttonStackView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        // Layout constraints
        NSLayoutConstraint.activate([
            tokenSlider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tokenSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tokenSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tokenLabel.topAnchor.constraint(equalTo: tokenSlider.bottomAnchor, constant: 8),
            tokenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonStackView.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    @objc func tokenSliderChanged() {
        let tokens = Int(tokenSlider.value)
        tokenLabel.text = "Tokens: \(tokens)"
    }

    @objc func promptPlusClipboardTapped() {
        shouldReplaceEntireText = true
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) : \"\(getHighlightedText())\" | \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: getHighlightedText(), inputFieldText: getInputFieldText())
    }
    
    @objc func promptOnlyTapped() {
        shouldReplaceEntireText = true
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: "", inputFieldText: getInputFieldText())
    }
    
    @objc func extendTextTapped() {
        shouldReplaceEntireText = false
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getInputFieldText())\" | \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: "", inputFieldText: getInputFieldText())
    }

    func getInputFieldText() -> String {
        guard let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy else { return "" }
        return textDocumentProxy.documentContextBeforeInput ?? ""
    }
    
    func getHighlightedText() -> String {
        return UIPasteboard.general.string ?? ""
    }

    func sendAPIRequest(instruction: String, highlightedText: String, inputFieldText: String) {
        let apiURL = "https://OPENAI-COMPATIBLE-API-URL:PORT/v1/completions/v1/completions"
        print("Sending API Request to OpenAI format endpoint")
        
        let combinedPrompt = "\(instruction) \(highlightedText) \(inputFieldText)"
        
        let parameters: [String: Any] = [
            "prompt": combinedPrompt,
            "max_tokens": Int(tokenSlider.value),
            "temperature": 0.7,
            "top_p": 0.9,
            "n": 1,
            "stream": true,
            "stop": "#"
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.startLoading()
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    func handleStreamingResponse(text: String) {
        if isFirstChunk {
            if shouldReplaceEntireText {
                // Remove all existing text
                while (textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput?.isEmpty == false {
                    (textDocumentProxy as? UITextDocumentProxy)?.deleteBackward()
                }
                // Move cursor to the beginning
                (textDocumentProxy as? UITextDocumentProxy)?.adjustTextPosition(byCharacterOffset: 0)
            } else {
                // Remove only "Loading..." text
                for _ in 0..<10 {
                    (textDocumentProxy as? UITextDocumentProxy)?.deleteBackward()
                }
            }
            isFirstChunk = false
        }
        
        // Update text input without removing newlines
        updateTextInput(with: text)
    }

    func updateTextInput(with text: String) {
        guard let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy else { return }
        textDocumentProxy.insertText(text)
    }

    func startLoading() {
        activityIndicator.startAnimating()
        isFirstChunk = true
        updateTextInput(with: " Processing ...")
    }

    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}

extension KeyboardViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let decoder = JSONDecoder()
        let lines = data.split(separator: UInt8(ascii: "\n"))
        
        for line in lines {
            if line.starts(with: Data("data: ".utf8)) {
                let jsonData = line.dropFirst(6)
                if let event = try? decoder.decode(StreamCompletionResponse.self, from: jsonData) {
                    if let text = event.choices.first?.text {
                        DispatchQueue.main.async { [weak self] in
                            self?.handleStreamingResponse(text: text)
                        }
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoading()
        }
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct StreamCompletionResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let text: String
    }
}

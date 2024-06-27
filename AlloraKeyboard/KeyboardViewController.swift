import UIKit

class KeyboardViewController: UIInputViewController {

    let customKeyboardView = UIInputView(frame: .zero, inputViewStyle: .keyboard)
    var activityIndicator: UIActivityIndicatorView!
    var shouldReplaceEntireText = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomKeyboard()
        setupActivityIndicator()
    }

    func setupCustomKeyboard() {
        customKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customKeyboardView)
        
        NSLayoutConstraint.activate([
            customKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            customKeyboardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupButtons()
    }

    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: customKeyboardView.bottomAnchor, constant: 8)
        ])
    }

    func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        customKeyboardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: customKeyboardView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: customKeyboardView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: customKeyboardView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: customKeyboardView.trailingAnchor),
        ])

        let buttonTitles = ["Send Both", "Send Text", "Clipboard...", "Text..."]
        let buttonSelectors: [Selector] = [#selector(executeButtonTapped), #selector(textOnlyButtonTapped), #selector(continueClipboardButtonTapped), #selector(continueTextButtonTapped)]

        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: buttonSelectors[index], for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    @objc func executeButtonTapped() {
        shouldReplaceEntireText = true
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) : \"\(getHighlightedText())\" | \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: getHighlightedText(), inputFieldText: getInputFieldText())
    }
    
    @objc func textOnlyButtonTapped() {
        shouldReplaceEntireText = true
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: "", inputFieldText: getInputFieldText())
    }
    
    @objc func continueClipboardButtonTapped() {
        shouldReplaceEntireText = false
        let instruction = "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getHighlightedText())\" | \n### Response:"
        sendAPIRequest(instruction: instruction, highlightedText: getHighlightedText(), inputFieldText: "")
    }
    
    @objc func continueTextButtonTapped() {
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
        let apiURL = "https://OPENAI-COMPATIBLE-API-URL:PORT/v1/completions"
        print("Sending API Request to OpenAI format endpoint")
        
        let combinedPrompt = "\(instruction) \(highlightedText) \(inputFieldText)"
        
        let parameters: [String: Any] = [
            "prompt": combinedPrompt,
            "max_tokens": 100,
            "temperature": 0.7,
            "top_p": 0.9,
            "n": 1,
            "stream": false,
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

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                self?.stopLoading()
            }

            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            if let responseText = self?.parseAPIResponse(responseData: data) {
                DispatchQueue.main.async {
                    self?.updateTextInput(with: responseText)
                }
            }
        }

        task.resume()
    }
    
    func parseAPIResponse(responseData: Data) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               !choices.isEmpty,
               let firstChoice = choices.first,
               let text = firstChoice["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Error parsing API response: \(error.localizedDescription)")
        }
        
        return ""
    }

    func updateTextInput(with text: String) {
        guard let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy else { return }
        
        if shouldReplaceEntireText {
            // Delete all existing text
            while textDocumentProxy.documentContextBeforeInput?.isEmpty == false {
                textDocumentProxy.deleteBackward()
            }
            // Insert new text without quotes
            textDocumentProxy.insertText(text)
        } else {
            // For continue operations, just append the text
            textDocumentProxy.insertText(text)
        }
    }

    func startLoading() {
        activityIndicator.startAnimating()
        updateTextInput(with: "Loading...")
    }

    func stopLoading() {
        activityIndicator.stopAnimating()
        // Remove "Loading..." text
        for _ in 0..<10 {
            (textDocumentProxy as? UITextDocumentProxy)?.deleteBackward()
        }
    }
}

import UIKit

class KeyboardViewController: UIInputViewController {

    let customKeyboardView = UIInputView(frame: .zero, inputViewStyle: .keyboard)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomKeyboard()
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
        handleTextExtractionAndAPIRequest(instruction: "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) : \"\(getHighlightedText())\" | \n### Response:")
    }
    
    @objc func textOnlyButtonTapped() {
        handleTextExtractionAndAPIRequest(instruction: "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) \n### Response:")
    }
    
    @objc func continueClipboardButtonTapped() {
        handleTextExtractionAndAPIRequest(instruction: "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getHighlightedText())\" | \n### Response:")
    }
    
    @objc func continueTextButtonTapped() {
        handleTextExtractionAndAPIRequest(instruction: "Below is an instruction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getInputFieldText())\" | \n### Response:")
    }

    func handleTextExtractionAndAPIRequest(instruction: String) {
        let highlightedText = getHighlightedText()
        let inputFieldText = getInputFieldText()
        sendAPIRequest(instruction: instruction, highlightedText: highlightedText, inputFieldText: inputFieldText)
    }
    
    func getInputFieldText() -> String {
        guard let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy else { return "" }
        return textDocumentProxy.documentContextBeforeInput ?? ""
    }
    
    func getHighlightedText() -> String {
        return UIPasteboard.general.string ?? ""
    }

    func sendAPIRequest(instruction: String, highlightedText: String, inputFieldText: String) {
        // Assuming your server is set up to mimic OpenAI's API structure
        let apiURL = "TEXT_GENERATION_HOSTNAME:PORT_NUMBER/v1/completions" // Update the engine if necessary
        print("Sending API Request to OpenAI format endpoint")
        
        // Combine your custom instruction with the highlighted and input text
        let combinedPrompt = "\(instruction) \(highlightedText) \(inputFieldText)"
        
        // OpenAI compatible parameters
        let parameters: [String: Any] = [
            "prompt": combinedPrompt,
            "max_tokens": 100,
            "temperature": 0.7,
            "top_p": 0.9,
            "n": 1, // Number of completions to generate
            "stream": false, //
            "stop": "#" //
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            let parsedResponse = self?.parseAPIResponse(responseData: data) ?? ""

            DispatchQueue.main.async {
                self?.printAPIResponse(response: parsedResponse)
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

    func printAPIResponse(response: String) {
        guard let textDocumentProxy = self.textDocumentProxy as? UITextDocumentProxy else { return }
        
        if let inputFieldText = textDocumentProxy.documentContextBeforeInput {
            for _ in inputFieldText {
                textDocumentProxy.deleteBackward()
            }
        }
        
        textDocumentProxy.insertText(response)
    }
}

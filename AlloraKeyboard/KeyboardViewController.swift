import UIKit

class KeyboardViewController: UIInputViewController {
    let customKeyboardView = UIInputView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomKeyboard()
    }
    
    func setupCustomKeyboard() {
        customKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        inputView?.addSubview(customKeyboardView)
        NSLayoutConstraint.activate([
            customKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            customKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let executeButton = UIButton(type: .system)
        executeButton.setTitle("Send Both", for: .normal)
        executeButton.addTarget(self, action: #selector(executeButtonTapped), for: .touchUpInside)
        customKeyboardView.addSubview(executeButton)
        executeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            executeButton.leadingAnchor.constraint(equalTo: customKeyboardView.leadingAnchor),
            executeButton.topAnchor.constraint(equalTo: customKeyboardView.topAnchor),
            executeButton.widthAnchor.constraint(equalTo: customKeyboardView.widthAnchor, multiplier: 0.25),
            executeButton.heightAnchor.constraint(equalTo: customKeyboardView.heightAnchor, multiplier: 0.5)
        ])
        
        let textOnlyButton = UIButton(type: .system)
        textOnlyButton.setTitle("Send Text", for: .normal)
        textOnlyButton.addTarget(self, action: #selector(textOnlyButtonTapped), for: .touchUpInside)
        customKeyboardView.addSubview(textOnlyButton)
        textOnlyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textOnlyButton.leadingAnchor.constraint(equalTo: executeButton.trailingAnchor),
            textOnlyButton.topAnchor.constraint(equalTo: customKeyboardView.topAnchor),
            textOnlyButton.widthAnchor.constraint(equalTo: customKeyboardView.widthAnchor, multiplier: 0.25),
            textOnlyButton.heightAnchor.constraint(equalTo: customKeyboardView.heightAnchor, multiplier: 0.5)
        ])
        
        let continueClipboardButton = UIButton(type: .system)
        continueClipboardButton.setTitle("Continue Clipboard", for: .normal)
        continueClipboardButton.addTarget(self, action: #selector(continueClipboardButtonTapped), for: .touchUpInside)
        customKeyboardView.addSubview(continueClipboardButton)
        continueClipboardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueClipboardButton.leadingAnchor.constraint(equalTo: textOnlyButton.trailingAnchor),
            continueClipboardButton.topAnchor.constraint(equalTo: customKeyboardView.topAnchor),
            continueClipboardButton.widthAnchor.constraint(equalTo: customKeyboardView.widthAnchor, multiplier: 0.25),
            continueClipboardButton.heightAnchor.constraint(equalTo: customKeyboardView.heightAnchor, multiplier: 0.5)
        ])
        
        let continueTextButton = UIButton(type: .system)
        continueTextButton.setTitle("Continue Text", for: .normal)
        continueTextButton.addTarget(self, action: #selector(continueTextButtonTapped), for: .touchUpInside)
        customKeyboardView.addSubview(continueTextButton)
        continueTextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueTextButton.leadingAnchor.constraint(equalTo: continueClipboardButton.trailingAnchor),
            continueTextButton.topAnchor.constraint(equalTo: customKeyboardView.topAnchor),
            continueTextButton.widthAnchor.constraint(equalTo: customKeyboardView.widthAnchor, multiplier: 0.25),
            continueTextButton.heightAnchor.constraint(equalTo: customKeyboardView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    
    @objc func executeButtonTapped() {
        // Call the function to handle the extraction and API request
        handleTextExtractionAndAPIRequest(instruction: "Below is an instrction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) : \"\(getHighlightedText())\" | \n### Response:")
    }
    
    @objc func textOnlyButtonTapped() {
        // Call the function to handle the extraction and API request
        handleTextExtractionAndAPIRequest(instruction: "Below is an instrction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n \(getInputFieldText()) \n### Response:")
    }
    
    @objc func continueClipboardButtonTapped() {
        // Call the function to handle the extraction and API request
        handleTextExtractionAndAPIRequest(instruction: "Below is an instrction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getHighlightedText())\" | \n### Response:")
    }
    
    @objc func continueTextButtonTapped() {
        // Call the function to handle the extraction and API request
        handleTextExtractionAndAPIRequest(instruction: "Below is an instrction that describes a task. Write a response that appropriately completes the request. \n### Instruction:\n Continue this text: \"\(getInputFieldText())\" | \n### Response:")
    }
    
    func handleTextExtractionAndAPIRequest(instruction: String) {
        // Get the clipboard copied text (highlightedText)
        let clipboard = UIPasteboard.general
        let highlightedText = clipboard.string ?? ""
        
        // Get the current input text field value (inputFieldText)
        let inputFieldText = getInputFieldText()
        
        // Call the function to send a REST API request with the extracted text
        sendAPIRequest(instruction: instruction, highlightedText: highlightedText, inputFieldText: inputFieldText)
    }
    
    func getInputFieldText() -> String {
        guard let textDocumentProxy = textDocumentProxy as? UITextDocumentProxy else { return "" }
        return textDocumentProxy.documentContextBeforeInput ?? ""
    }
    
    func getHighlightedText() -> String {
        let clipboard = UIPasteboard.general
        return clipboard.string ?? ""
    }
    
    func printAPIResponse(response: String) {
        guard let textDocumentProxy = textDocumentProxy as? UITextDocumentProxy else { return }
        
        // Delete text b from the input field
        if let inputFieldText = textDocumentProxy.documentContextBeforeInput {
            for _ in inputFieldText {
                textDocumentProxy.deleteBackward()
            }
        }
        
        // Overwrite text b with the response (text d)
        textDocumentProxy.insertText(response)
    }
    
    func sendAPIRequest(instruction: String, highlightedText: String, inputFieldText: String) {
        
        // Combine text a, text b, and text c into a formatted REST API request
        let apiURL = "http://API_URL:API_PORT/run/textgen"
        print("Sending API Request")
        let parameters: [String: Any] = [
            "data": [
                [
                    instruction,
                    [
                        "max_new_tokens": 100,
                        "do_sample": true,
                        "temperature": 0.7,
                        "top_p": 0.9,
                        "typical_p": 1,
                        "repetition_penalty": 1.05,
                        "encoder_repetition_penalty": 1.0,
                        "top_k": 0,
                        "min_length": 0,
                        "no_repeat_ngram_size": 0,
                        "num_beams": 1,
                        "penalty_alpha": 0,
                        "length_penalty": -1,
                        "early_stopping": false,
                        "seed": -1,
                        "add_bos_token": false,
                        "truncation_length": 2048,
                        "custom_stopping_strings": ["### Instruction:"],
                        "ban_eos_token": false,
                    ]
                ]
            ]
        ]
        
        
        // Make Request
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error creating request body: \(error)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error making API request: \(error)")
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
               let dataArray = json["data"] as? [String] {
                if dataArray.count > 0 {
                    let rawResponse = dataArray[0]
                    guard let range = rawResponse.range(of: "### Response:") else {
                        return rawResponse
                    }
                    let parsedResponse = String(rawResponse[range.upperBound...])
                    return parsedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } catch {
            print("Error parsing API response: \(error)")
        }
        
        return ""
    }
    
}

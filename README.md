# **Custom iOS Keyboard Extension**

# 💬 **ALLORA** 💬

Conversational filler, in italian: *'Well, then..'*  

## 💡 Description 💡

This repo provides the starting point for a custom iOS keyboard extension for Xcode, which provides a series of buttons for sending different combinations of input text and clipboard content to an LLM via REST API. 

This is currently configured to send a request to a locally hosted LLM using oobabooga’s text-generation-webui ([https://github.com/oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui)). It could easily be altered to work with any other LLM of your choice.

The API is expected to process the user input and return a response, which will be displayed in the input field. See below for examples of how to provide input from the iOS Keyboard.

This was originally built to serve the purpose of providing summarizations, quick replies, or in-text/chat LLM responses that can be generated anywhere on iOS where the native keyboard is displayed. It can be used to generate replies to messages, emails, to write a tweet, or transform text in just about any way you see fit.

## ⭐ Features ⭐

* Custom keyboard layout with four buttons:
    1. Send Both
    2. Send Text
    3. Continue Clipboard
    4. Continue Text
* Extracts the input field text and clipboard content.
* Sends extracted text to a REST API for processing.
* Displays the API response in the input field.

## 🔧 Installation 🔧

1. Clone this repository:

    ```
    git clone https://github.com/nicksavarese/allora-ios.git
    ```

2. Open the project in Xcode.
3. Change the API URL in the `sendAPIRequest` function to match your API endpoint.
4. Update the Development Team and Bundle Identifier for each target to match your Apple Developer account details:

_You will need to replace “API_URL” and “API_PORT” with your API URL and PORT details to the KeyboardViewController.swift file on line 130._

_Before building, be sure to add your Apple Developer details so you can sign the app properly._

5. Build and run the project on a simulator or a connected device.

## ⚡ Usage ⚡

1. Open any app that supports text input.
2. Long press the globe icon on the default keyboard and select the custom keyboard (AlLoRa) from the list. _Note: you may need to provide “Full Access” to the keyboard by going to Settings>General>Keyboards>AlLoRa, and then be sure that Full Access is enabled._
3. Use the buttons to send text to the API as seen in the examples below.
4. The API response will be displayed in the input field, and replaces input field text.

## 📚 Examples 📚
### Send Both:

#### Sends the input field text along with the highlighted (clipboard) text.

For example, if the input field text is:
    
    Write a nice and detailed reply with the solution
    
and the clipboard text is: 
    
    “Can u pls help?? my Apple watch has two faces smiling and frowning at me on it and now it won’t ring anymore????”
    
the API will receive both phrases and respond accordingly.
    
### Send Text: 

#### Sends the input field text only. For example, if the input field text is 
    Write a quote by Marcus Aurelius
the API will receive this phrase alone.

### Continue Clipboard:

#### Sends the highlighted (clipboard) text, asking the API to continue it. 

For example, if the clipboard text is 

    Let me not to the marriage of true minds…
    
the API will receive this phrase with a request to continue it.

### Continue Text: 

#### Sends the input field text, asking the API to continue it. For example, if the input field text is 

    Here is the plot of the show, ‘Westworld':

The API will receive this phrase with a request to continue it.



# 🖌 Customization

To customize the keyboard layout or the API request, modify the `KeyboardViewController` class in the Xcode project.


## 📝 Note

Remember to update the Development Team and Bundle Identifier for each target to match your Apple Developer account details. This ensures the project is signed properly for deployment.


## 📃 License

This project is licensed under the Apache License, Version 2.0. See the LICENSE file for more details.


## ⚠ Lil' Disclaimer / Not Legal Advice ⚠️

#### This repository is provided "as is" without warranty of any kind, either expressed or implied, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose. 

In no event will the author, copyright holder, or any other party who may modify and/or redistribute the software be liable to you for damages, including any general, special, incidental, or consequential damages arising out of the use or inability to use the software (including, but not limited to, loss of data or data being rendered inaccurate or losses sustained by you or third parties or a failure of the software to operate with any other software), even if such holder or other party has been advised of the possibility of such damages.

This project and its documentation are not legal advice, and you should not rely on them as such. If you need legal advice or guidance, consult with an attorney or other appropriate professional. The content provided here is for and research purposes only and is intended to help you better understand the functionality of the software. It is your responsibility to ensure that your use of this software complies with any applicable laws and regulations.

This repository does not include any language models or API endpoints for processing text. It is your responsibility to provide your own language model or REST API to work with this custom iOS keyboard extension. The author, copyright holder, or any other party who may modify and/or redistribute the software is not responsible for providing, maintaining, or supporting any language models or APIs. By using this software, you acknowledge and agree that you are responsible for obtaining and setting up your own language model or REST API to work with this custom iOS keyboard extension.

#### Please ensure that your use of any language models or REST APIs complies with their respective terms of service, licenses, and any applicable laws and regulations.

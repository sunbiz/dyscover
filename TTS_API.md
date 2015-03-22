These are the API's of TTS module

# Introduction #

These are the functions of different processes working in the background of the TTS module to execute & satisfy the user requirements.

**API's**
  * **getText()**:- Retrieve/Recognize the user entered text & generate a request to the database.

  * **recognizeType()**:- This function will recognize whether the entered text is number,character,special character,a word or a sentence.

  * **retrieveSound()**:- Retrieves the appropriate pronounciation of the word or character in the response to the user request from the database.

  * **retrieveImage()**:- Retrives the appropriate objects image for some of the words like Fruits,Vehicles etc. for better introduction of the child to the word from the database.

  * **retrieveSynonymous()**:- Retrieves the synonymous of the word if any in the table.

  * **Play()**:- By this function the result of the retrieveSound() method will be available to the actual user in terms of sound .

  * **Stop()**:- By this function the TTS player will be stopped.

  * **Pause()**:- By this function the TTS player will be paused for some time.

  * **Clear()**:- By this function the text field will be cleared.

  * **displayImage()**:- By this function the image that is retrieved from the database in the retrieveImage() method is displayed on the screen.

  * **recognizeSpace()**:- This function will recognize the space between two words of the sentense.Only one space is allowed in between two words,more spaces will be considered as the end of the statement & system will not read the words following that spaces.

  * **recognizeDot()**:- This function will recognize the "Dot" character in the sentense that will be either acting as a special character in the sentense like in the e-mail address piyubharati@gmail.com or as a full stop to indicate the end of the statement.

  * **recognizeEnd()**:- This function will recognize the end of the statement either by full stop or by more than one space in two words.
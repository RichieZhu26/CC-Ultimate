# Camera Calculator

This app is developed to solve handwritten mathamatica formulas. To use this app, the user will first choose a photo (from camera or photo library) that contains the first handwritten number, then select one calculation type (plus, minus, multiply or divide), and then choose another photo that contains the second handwritten number. Now the app will recognize the two numbers and perform the selected calculation and return the result on the screen.

This app applies the text detection module from Apple's Vision Framework to mark the location of the CGRect that contains the handwritten number in the photo,divide that number into individual digits and generate a list of images of the digits. Then, these images will be fed into a series of preprocessing filters (resizing and color adjustment) to be more alike to the training data of the image classification model. Then, these images will be recognized by an official pre-trained model for Apple's Core ML - "MNISTClassifier".

(The performance of number recognition in this app will be optimal when the number is long (> about 3 or 4). This is mainly the result of the text detection module.)

I'm currently looking for applicable datasets of calculation marks, and in the future I will train my own machine learning model to recognize digits and calculation marks together.
<br><br>
# Screenshots
<br><img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/firstview.jpeg" width="400">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/library.jpeg" width="400">
<br><br><img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/firstphoto.jpeg" width="400">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/method.jpeg" width="400">
<br><br><img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/secondphoto.jpeg" width="400">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://github.com/RichieZhu26/Camera-Calculator/blob/master/screenshot/result.jpeg" width="400">

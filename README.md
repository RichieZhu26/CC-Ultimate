# CC-Ultimate

CC-Ultimate is a camera calculator app developed by using text detection and image classification. To use this app, the user will first choose a photo (from camera or photo library) containing a handwritten number, then select one calculation type (plus, minus, multiply or divide), and then choose another also containing a handwritten number. The app will recognize the two numbers and perform the selected calculation to return the result.

This app applies the text detection module from Apple's Vision Framework to seperate handwritten texts from the photo and generate individual image for each character. At this point, these images are ready to be preprocessed to best fit the image classification model. So then the photos will go through several size and color filters to become of dark background and white writing. The last step is to predict what these images represent from the built-in model in Apple's Core ML, which is trained from the famous MNIST dataset.


from flask import Flask, request, jsonify
import werkzeug

from keras.preprocessing.image import load_img
from keras.preprocessing.image import img_to_array
from keras.applications.xception import preprocess_input
from keras.applications.xception import decode_predictions
from keras.applications.xception import Xception

app = Flask(__name__)
model = Xception(include_top=True,
    weights="imagenet",
    input_tensor=None,
    input_shape=None,
    pooling=None,
    classes=1000,
    classifier_activation="softmax",)

output  = {}
top10food = [['ice_cream', 'with 207 calories'],
 ['bell_pepper', 'with 31 calories'],
 ['cheeseburger', 'with 303 calories' ],
 ['broccoli', 'with 45 calories'],
 ['banana', 'with 89 calories'],
 ['pizza', 'with 266 calories'],
 ['orange', 'with 47 calories'],
 ['espresso', 'with 9 calories']]


foodList = ['ice_cream',
 'ice_lolly',
 'French_loaf',
 'bagel',
 'pretzel',
 'cheeseburger',
 'hotdog_290_calories',
 'mashed_potato',
 'head_cabbage',
 'broccoli',
 'cauliflower',
 'zucchini',
 'spaghetti_squash',
 'acorn_squash',
 'butternut_squash',
 'cucumber',
 'artichoke',
 'bell_pepper',
 'cardoon',
 'mushroom',
 'Granny_Smith',
 'strawberry',
 'orange',
 'lemon',
 'fig',
 'pineapple',
 'banana',
 'jackfruit',
 'custard_apple',
 'pomegranate',
 'hay',
 'carbonara',
 'chocolate_sauce',
 'dough',
 'meat_loaf',
 'pizza',
 'potpie',
 'red_wine',
 'espresso']

global alert

@app.route('/upload', methods=["POST"])
def upload():
        global result
        if(request.method == "POST"):
                imagefile = request.files['image']
                filename = werkzeug.utils.secure_filename(imagefile.filename)
                image_path = "./image/" + imagefile.filename
                imagefile.save(image_path)
                img = load_img(image_path, target_size=(299,299))
                img = img_to_array(img)
                img = img.reshape(1, img.shape[0], img.shape[1], img.shape[2])
                img = preprocess_input(img)
                yhat = model.predict(img)
                title = decode_predictions(yhat)
				
				for id in range(len(title[0])):
                        print(title[0][id])

                title =title[0][0]
                for i in range(len(foodList)):
                        if(foodList[i] == title[1]):
                            alert = 1
                            break
                        else:
                            alert = 0

                for i in range(len(top10food)):
                        if(top10food[i][0] == title[1]):
                            calories = top10food[i][1]
                            break
                        else:
                            calories = ''
							
				if alert == 1:
                        output  = '%s (%.2f%%) %s' % (title[1], title[2]*100, calories)
                        alert = 0
                else:
                        output = 'not a food!'

                print(output)
                output = output

                return jsonify({
                        "message": output #will use this for the flutter app
                        })
@app.route('/predict', methods=["GET"])
def predict():
        return output
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5000)
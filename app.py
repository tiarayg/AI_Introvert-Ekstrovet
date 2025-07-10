from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np

app = Flask(__name__)
CORS(app)

model = joblib.load('stacking_model.pkl')
encoder = joblib.load('label_encoder.pkl')

@app.route('/api/predict', methods=['POST'])
def predict():
    data = request.json['input']
    input_array = np.array([data])
    pred_encoded = model.predict(input_array)
    pred_label = encoder.inverse_transform(pred_encoded)[0]
    return jsonify({'label': pred_label})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

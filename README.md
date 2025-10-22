# hand-gesture-recognition-using-mediapipe

This repository demonstrates real-time hand pose estimation using MediaPipe (Python) and performs simple gesture recognition using lightweight models (MLP/LSTM). It includes sample inference code, pre-trained TFLite models, and the notebooks/data used to train them.

![demo-gif](https://user-images.githubusercontent.com/37477845/102222442-c452cd00-3f26-11eb-93ec-c387c98231be.gif)

---

## What this repo contains

* Example inference application (`app.py`) that runs a webcam demo and lets you collect training data.
* Pre-trained TFLite models for:

  * Hand sign classification (keypoint-based)
  * Finger gesture recognition (point-history based)
* Training data and Jupyter notebooks to re-train both models
* Utility for calculating FPS

---

## Requirements

Tested with the following (install with pip):

* mediapipe >= 0.8.4
* opencv-python >= 4.6
* tensorflow >= 2.9.0
* protobuf >= 3.9.2, < 3.20
* scikit-learn >= 1.0.2 (optional — for confusion matrices during training)
* matplotlib >= 3.5.1 (optional — for visualization during training)

---

## Quick demo

Run the webcam demo:

```bash
python app.py
```

Docker (if you want to run inside a container and forward your webcam/X11):

```bash
docker build -t hand_gesture .

xhost +local: && \
docker run --rm -it \
  --device /dev/video0:/dev/video0 \
  -v `pwd`:/home/user/workdir \
  -v /tmp/.X11-unix/:/tmp/.X11-unix:rw \
  -e DISPLAY=$DISPLAY \
  hand_gesture:latest

python app.py
```

### `app.py` options

* `--device` : camera device index (default: `0`)
* `--width` : capture width (default: `960`)
* `--height` : capture height (default: `540`)
* `--use_static_image_mode` : whether to enable MediaPipe static_image_mode (optional)
* `--min_detection_confidence` : detection confidence threshold (default: `0.5`)
* `--min_tracking_confidence` : tracking confidence threshold (default: `0.5`)

---

## Repository layout

```
│  app.py
│  keypoint_classification.ipynb
│  point_history_classification.ipynb
│
├─model
│  ├─keypoint_classifier
│  │  │  keypoint.csv
│  │  │  keypoint_classifier.hdf5
│  │  │  keypoint_classifier.py
│  │  │  keypoint_classifier.tflite
│  │  └─ keypoint_classifier_label.csv
│  │
│  └─point_history_classifier
│      │  point_history.csv
│      │  point_history_classifier.hdf5
│      │  point_history_classifier.py
│      │  point_history_classifier.tflite
│      └─ point_history_classifier_label.csv
│
└─utils
    └─cvfpscalc.py
```

### Files of note

* `app.py` — demo app for inference and data collection (press keys to toggle logging modes and save samples).
* `keypoint_classification.ipynb` — notebook to train the keypoint-based hand sign classifier.
* `point_history_classification.ipynb` — notebook to train the finger gesture (point-history) classifier.
* `model/...` — folders containing data, labels and trained models for each classifier.
* `utils/cvfpscalc.py` — simple FPS utility.

---

## Data collection & training

Both classifiers support collecting new samples directly from the demo and re-training using the provided notebooks.

### Hand sign (keypoint) data collection

* Start the demo and press `k` to enter keypoint logging mode.
* Press `0`–`9` to append the current normalized keypoint vector to `model/keypoint_classifier/keypoint.csv` with the pressed number used as the class ID.
* The saved keypoint vectors are preprocessed (normalized/scaled) before being written to CSV. The demo includes a few example classes by default (e.g., open hand, fist, pointing).

To train:

* Open `keypoint_classification.ipynb` and run from top to bottom. If you change the number of classes, update `NUM_CLASSES` and the label CSV file accordingly.

### Finger gesture (point-history) data collection

* Start the demo and press `h` to enter point-history logging mode.
* Press `0`–`9` to append the fingertip coordinate history to `model/point_history_classifier/point_history.csv` using the pressed number as the class ID.

To train:

* Open `point_history_classification.ipynb` and run from top to bottom. If you change class count, update `NUM_CLASSES` and the label CSV accordingly.

Model architectures used in the notebooks are intentionally simple (MLP for keypoint classification; MLP/LSTM options for point-history classification) so they can run and convert to TFLite easily.

---

## Practical applications

This project can be used as a foundation for:

* Hands-free control of drones or robots via gestures
* Sign language alphabet classification (with further data and model improvements)
* Gesture-based UI controls for interactive installations

See the `Application example` section in the original repo for external projects that built on similar ideas.

---

## References & resources

* MediaPipe: [https://mediapipe.dev/](https://mediapipe.dev/)
* This repository uses MediaPipe's Python APIs for hand landmark detection.

---

## License

This project is distributed under the Apache License 2.0. See the `LICENSE` file for details.

---

## Author

This README has been adapted for use by **`https://github.com/ketan13089`**. Replace the placeholder with your GitHub ID and update links where needed.

---

If you want any further edits (shorter intro, different license note, or to add a `CONTRIBUTING.md`), tell me what to change and I'll update it.

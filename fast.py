from fastapi import FastAPI, WebSocket, File, UploadFile, Request
import io
from fastapi.middleware.cors import CORSMiddleware
import json
import asyncio
import uvicorn
import threading
import cv2 as cv
import numpy as np
import base64
from typing import Dict, Any

# Import your existing script as a module
import app as gesture_recognizer

app = FastAPI()


# # Add this endpoint to receive frames from mobile clients
# @app.post("/process-frame")
# async def process_frame(request: Request):
#     # Get the raw content from the request
#     content = await request.body()
    
#     # Convert bytes to numpy array
#     nparr = np.frombuffer(content, np.uint8)
    
#     # Decode the image
#     image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
#     if image is None:
#         return {"error": "Invalid image data"}
    
#     # Process the image with your gesture recognition function
#     result = process_single_frame(image)
    
#     return result

# # Function to process a single frame
# def process_single_frame(image):
#     # Your gesture recognition logic here
#     # This is a simplified version of the run_recognition function
    
#     # Process the image
#     image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
    
#     # Run the model
#     mp_hands = gesture_recognizer.mp.solutions.hands
#     hands = mp_hands.Hands(
#         static_image_mode=True,
#         max_num_hands=1,
#         min_detection_confidence=0.7,
#         min_tracking_confidence=0.5,
#     )
    
#     results = hands.process(image)
    
#     # Rest of your processing logic...
#     # Return the detection results
    
#     # Example return:
#     return {
#         "hand_sign": "detected_sign",
#         "finger_gesture": "detected_gesture",
#         "hand_position": [[x, y] for x, y in landmark_list] if 'landmark_list' in locals() else []
#     }

# Add CORS middleware to allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Store for latest gesture data
latest_data = {
    "hand_sign": "",
    "finger_gesture": "",
    "hand_position": [],
    "fps": 0,
    "handedness": ""
}

# Image frame (for optional streaming)
latest_frame = None

# Flag to control the gesture recognition thread
running = False
recognition_thread = None

# Function to run the hand gesture recognition in a separate thread
def run_recognition():
    global latest_data, latest_frame, running
    
    # Setup
    args = gesture_recognizer.get_args()
    cap_device = args.device
    cap_width = args.width
    cap_height = args.height
    use_static_image_mode = args.use_static_image_mode
    min_detection_confidence = args.min_detection_confidence
    min_tracking_confidence = args.min_tracking_confidence
    use_brect = True
    
    # Camera
    cap = cv.VideoCapture(cap_device)
    cap.set(cv.CAP_PROP_FRAME_WIDTH, cap_width)
    cap.set(cv.CAP_PROP_FRAME_HEIGHT, cap_height)
    
    # Model loading
    mp_hands = gesture_recognizer.mp.solutions.hands
    hands = mp_hands.Hands(
        static_image_mode=use_static_image_mode,
        max_num_hands=1,
        min_detection_confidence=min_detection_confidence,
        min_tracking_confidence=min_tracking_confidence,
    )
    
    keypoint_classifier = gesture_recognizer.KeyPointClassifier()
    point_history_classifier = gesture_recognizer.PointHistoryClassifier()
    
    # Labels
    with open('model/keypoint_classifier/keypoint_classifier_label.csv',
            encoding='utf-8-sig') as f:
        keypoint_classifier_labels = gesture_recognizer.csv.reader(f)
        keypoint_classifier_labels = [
            row[0] for row in keypoint_classifier_labels
        ]
    with open(
            'model/point_history_classifier/point_history_classifier_label.csv',
            encoding='utf-8-sig') as f:
        point_history_classifier_labels = gesture_recognizer.csv.reader(f)
        point_history_classifier_labels = [
            row[0] for row in point_history_classifier_labels
        ]
    
    # FPS calculation
    cvFpsCalc = gesture_recognizer.CvFpsCalc(buffer_len=10)
    
    # Coordinate history
    history_length = 16
    point_history = gesture_recognizer.deque(maxlen=history_length)
    
    # Finger gesture history
    finger_gesture_history = gesture_recognizer.deque(maxlen=history_length)
    
    # Mode
    mode = 0
    
    while running:
        fps = cvFpsCalc.get()
        
        # Camera capture
        ret, image = cap.read()
        if not ret:
            continue
        image = cv.flip(image, 1)
        debug_image = gesture_recognizer.copy.deepcopy(image)
        
        # Detection implementation
        image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = hands.process(image)
        image.flags.writeable = True
        
        # Process results
        if results.multi_hand_landmarks is not None:
            for hand_landmarks, handedness in zip(results.multi_hand_landmarks,
                                                results.multi_handedness):
                # Bounding box calculation
                brect = gesture_recognizer.calc_bounding_rect(debug_image, hand_landmarks)
                
                # Landmark calculation
                landmark_list = gesture_recognizer.calc_landmark_list(debug_image, hand_landmarks)
                
                # Conversion to relative coordinates / normalized coordinates
                pre_processed_landmark_list = gesture_recognizer.pre_process_landmark(landmark_list)
                pre_processed_point_history_list = gesture_recognizer.pre_process_point_history(
                    debug_image, point_history)
                
                # Hand sign classification
                hand_sign_id = keypoint_classifier(pre_processed_landmark_list)
                if hand_sign_id == 2:  # Pointing gesture
                    point_history.append(landmark_list[8])
                else:
                    point_history.append([0, 0])
                
                # Finger gesture classification
                finger_gesture_id = 0
                point_history_len = len(pre_processed_point_history_list)
                if point_history_len == (history_length * 2):
                    finger_gesture_id = point_history_classifier(
                        pre_processed_point_history_list)
                
                # Calculate the most frequent gesture ID in the latest detection
                finger_gesture_history.append(finger_gesture_id)
                most_common_fg_id = gesture_recognizer.Counter(
                    finger_gesture_history).most_common()
                
                # Update the latest data for the API
                latest_data = {
                    "hand_sign": keypoint_classifier_labels[hand_sign_id],
                    "finger_gesture": point_history_classifier_labels[most_common_fg_id[0][0]] if most_common_fg_id else "",
                    "hand_position": landmark_list,
                    "fps": fps,
                    "handedness": handedness.classification[0].label
                }
                
                # Draw graphics for debugging
                debug_image = gesture_recognizer.draw_bounding_rect(use_brect, debug_image, brect)
                debug_image = gesture_recognizer.draw_landmarks(debug_image, landmark_list)
                debug_image = gesture_recognizer.draw_info_text(
                    debug_image,
                    brect,
                    handedness,
                    keypoint_classifier_labels[hand_sign_id],
                    point_history_classifier_labels[most_common_fg_id[0][0]] if most_common_fg_id else "",
                )
        else:
            point_history.append([0, 0])
            latest_data["hand_sign"] = ""
            latest_data["finger_gesture"] = ""
            latest_data["hand_position"] = []
            latest_data["handedness"] = ""
        
        debug_image = gesture_recognizer.draw_point_history(debug_image, point_history)
        debug_image = gesture_recognizer.draw_info(debug_image, fps, mode, -1)
        
        # Store the latest frame for optional video streaming
        latest_frame = debug_image
        
        # Display the image for debugging (optional, can be commented out)
        cv.imshow('Hand Gesture Recognition', debug_image)
        key = cv.waitKey(1)
        if key == 27:  # ESC key
            break
    
    # Release resources
    cap.release()
    cv.destroyAllWindows()


@app.get("/")
async def root():
    return {"message": "Hand Gesture Recognition API"}

@app.get("/status")
async def status():
    global running
    return {"status": "running" if running else "stopped"}

@app.get("/start")
async def start_recognition():
    global running, recognition_thread
    if not running:
        running = True
        recognition_thread = threading.Thread(target=run_recognition)
        recognition_thread.daemon = True
        recognition_thread.start()
        return {"status": "started"}
    return {"status": "already running"}

@app.get("/stop")
async def stop_recognition():
    global running
    if running:
        running = False
        return {"status": "stopping"}
    return {"status": "already stopped"}

@app.get("/data")
async def get_data():
    return latest_data

@app.get("/frame")
async def get_frame():
    if latest_frame is not None:
        # Convert the image to JPEG
        ret, jpeg = cv.imencode('.jpg', latest_frame, [cv.IMWRITE_JPEG_QUALITY, 70])
        # Convert to base64 for easy transfer
        frame_bytes = jpeg.tobytes()
        encoded = base64.b64encode(frame_bytes)
        return {"frame": encoded.decode('utf-8')}
    return {"frame": None}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        # Send data continuously via WebSocket
        while True:
            # Send the latest gesture data to the client
            await websocket.send_text(json.dumps(latest_data))
            await asyncio.sleep(0.05)  # Send at ~20fps
    except Exception as e:
        print(f"WebSocket error: {e}")
    finally:
        await websocket.close()




if __name__ == "__main__":
    uvicorn.run("fast:app", host="0.0.0.0", port=8000, reload=True)
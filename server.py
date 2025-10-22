from fastapi import FastAPI, UploadFile, File, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import mediapipe as mp
import uvicorn
from model import KeyPointClassifier
import csv
import io
from typing import Dict
import uuid

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize MediaPipe Hands
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=True,
    max_num_hands=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.5,
)

# Load keypoint classifier
keypoint_classifier = KeyPointClassifier()

# Load labels
with open('model/keypoint_classifier/keypoint_classifier_label.csv', encoding='utf-8-sig') as f:
    keypoint_classifier_labels = [row[0] for row in csv.reader(f)]


# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}

    async def connect(self, room_id: str, user_id: str, websocket: WebSocket):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        self.active_connections[room_id][user_id] = websocket
        print(f"User {user_id} connected to room {room_id}")

    def disconnect(self, room_id: str, user_id: str):
        if room_id in self.active_connections and user_id in self.active_connections[room_id]:
            del self.active_connections[room_id][user_id]
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]
        print(f"User {user_id} disconnected from room {room_id}")

    async def send_personal_message(self, message: str, room_id: str, user_id: str):
        if room_id in self.active_connections and user_id in self.active_connections[room_id]:
            await self.active_connections[room_id][user_id].send_text(message)

    async def broadcast(self, message: str, room_id: str, sender_id: str):
        if room_id in self.active_connections:
            for user_id, websocket in self.active_connections[room_id].items():
                if user_id != sender_id:
                    try:
                        await websocket.send_text(message)
                        print(f"Sent to {user_id}: {message}")  # Debug log
                    except Exception as e:
                        print(f"Error sending to {user_id}: {e}")
                        self.disconnect(room_id, user_id)


manager = ConnectionManager()


# New endpoints for video calling
@app.get("/create-room")
async def create_room():
    """Endpoint to create a new video call room"""
    room_id = str(uuid.uuid4())
    return {"room_id": room_id}


@app.get("/validate-room/{room_id}")
async def validate_room(room_id: str):
    """Endpoint to validate if a room exists"""
    # In this simple implementation, all room IDs are considered valid
    # You could add actual validation logic here if needed
    return {"valid": True, "room_id": room_id}


@app.websocket("/ws/{room_id}/{user_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, user_id: str):
    """WebSocket endpoint for real-time communication"""
    await manager.connect(room_id, user_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            if data == 'ping':
                # Respond to ping to keep connection alive
                await websocket.send_text('pong')
            else:
                await manager.broadcast(data, room_id, user_id)
    except WebSocketDisconnect:
        manager.disconnect(room_id, user_id)
        await manager.broadcast(f"User {user_id} left the call", room_id, user_id)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(room_id, user_id)

# Existing hand sign detection endpoint
@app.post("/detect-hand-sign")
async def detect_hand_sign(file: UploadFile = File(...)):
    try:
        # Read image file
        contents = await file.read()
        if len(contents) == 0:
            return {"detected": False, "sign": "Empty image"}
        nparr = np.frombuffer(contents, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if image is None:
            return {"detected": False, "sign": "Invalid image"}

        # Convert to RGB
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False

        # Process with MediaPipe
        results = hands.process(image)
        image.flags.writeable = True

        if not results.multi_hand_landmarks:
            return {"detected": False, "sign": "No hand detected"}

        # Get the first hand detected
        hand_landmarks = results.multi_hand_landmarks[0]

        # Calculate landmark list
        landmark_list = calc_landmark_list(image, hand_landmarks)

        # Pre-process landmarks
        pre_processed_landmark_list = pre_process_landmark(landmark_list)

        # Classify hand sign
        hand_sign_id = keypoint_classifier(pre_processed_landmark_list)
        hand_sign = keypoint_classifier_labels[hand_sign_id]

        return {"detected": True, "sign": hand_sign}

    except Exception as e:
        return {"detected": False, "sign": f"Error: {str(e)}"}


def calc_landmark_list(image, landmarks):
    image_width, image_height = image.shape[1], image.shape[0]
    landmark_point = []
    for _, landmark in enumerate(landmarks.landmark):
        landmark_x = min(int(landmark.x * image_width), image_width - 1)
        landmark_y = min(int(landmark.y * image_height), image_height - 1)
        landmark_point.append([landmark_x, landmark_y])
    return landmark_point


def pre_process_landmark(landmark_list):
    temp_landmark_list = landmark_list.copy()

    # Convert to relative coordinates
    base_x, base_y = 0, 0
    for index, landmark_point in enumerate(temp_landmark_list):
        if index == 0:
            base_x, base_y = landmark_point[0], landmark_point[1]
        temp_landmark_list[index][0] = temp_landmark_list[index][0] - base_x
        temp_landmark_list[index][1] = temp_landmark_list[index][1] - base_y

    # Convert to a one-dimensional list
    temp_landmark_list = sum(temp_landmark_list, [])

    # Normalization
    max_value = max(list(map(abs, temp_landmark_list)))
    if max_value != 0:
        temp_landmark_list = [n / max_value for n in temp_landmark_list]

    return temp_landmark_list


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
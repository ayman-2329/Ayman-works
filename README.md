<p align="center">
  <img src="https://img.shields.io/badge/Mohammed%20Ayman-Embedded%20AI%20%C2%B7%20Computer%20Vision%20%C2%B7%20Automation-1f6feb?style=for-the-badge&logo=github&logoColor=white" alt="Mohammed Ayman" />
</p>

<h1 align="center">Mohammed Ayman</h1>

<p align="center">
  <b>Embedded AI &amp; Computer Vision · Workflow Automation Intern</b><br/>
  B.E. Computer Science Engineering · S.A. Engineering College · 2024–2028
</p>

<p align="center">
  <a href="mailto:mayman2229@gmail.com"><img src="https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white" /></a>
  <a href="https://www.linkedin.com/in/mohammed-ayman-22a97a23a"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" /></a>
  <a href="https://github.com/ayman-2329"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
</p>

---

## About Me

I build systems where **sensors, AI models, and real alerts** meet — hardware that senses
something, a model that decides what it means, and a dashboard or a phone that tells a human
in time to act.

That pattern runs through most of my work: an ESP32 that detects which direction someone
crossed a perimeter and computes their speed from a 10 cm sensor gap; a YOLOv8 pipeline
watching camera feeds for rising water and firing SMS to responders; a desk assistant that
listens on an I2S mic, transcribes with Whisper, and answers through a speaker.

Currently in my third year of B.E. Computer Science Engineering, working as a **Workflow
Automation Intern** building Power Automate flows over SharePoint and Microsoft 365.

I judge a project by one question: can someone else clone it and run it? Everything below is
built to that standard.

---

## Tech Stack

**AI / ML**
<p>
  <img src="https://img.shields.io/badge/Python-3670A0?style=flat-square&logo=python&logoColor=ffdd54"/>
  <img src="https://img.shields.io/badge/YOLOv8-00FFFF?style=flat-square&logo=yolo&logoColor=black"/>
  <img src="https://img.shields.io/badge/OpenCV-5C3EE8?style=flat-square&logo=opencv&logoColor=white"/>
  <img src="https://img.shields.io/badge/TensorFlow-FF6F00?style=flat-square&logo=tensorflow&logoColor=white"/>
  <img src="https://img.shields.io/badge/scikit--learn-F7931E?style=flat-square&logo=scikitlearn&logoColor=white"/>
  <img src="https://img.shields.io/badge/Whisper-412991?style=flat-square&logo=openai&logoColor=white"/>
</p>

**Embedded & Hardware**
<p>
  <img src="https://img.shields.io/badge/ESP32-E7352C?style=flat-square&logo=espressif&logoColor=white"/>
  <img src="https://img.shields.io/badge/Arduino-00979D?style=flat-square&logo=arduino&logoColor=white"/>
  <img src="https://img.shields.io/badge/C++-00599C?style=flat-square&logo=cplusplus&logoColor=white"/>
  <img src="https://img.shields.io/badge/I2S%20Audio-555555?style=flat-square"/>
  <img src="https://img.shields.io/badge/Serial%20Protocols-555555?style=flat-square"/>
</p>

**Backend & Apps**
<p>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flask-000000?style=flat-square&logo=flask&logoColor=white"/>
  <img src="https://img.shields.io/badge/WebSockets-010101?style=flat-square&logo=socketdotio&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white"/>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black"/>
</p>

**Automation & Cloud**
<p>
  <img src="https://img.shields.io/badge/Power%20Automate-0066FF?style=flat-square&logo=microsoft&logoColor=white"/>
  <img src="https://img.shields.io/badge/SharePoint-0078D4?style=flat-square&logo=microsoftsharepoint&logoColor=white"/>
  <img src="https://img.shields.io/badge/Microsoft%20365-D83B01?style=flat-square&logo=microsoftoffice&logoColor=white"/>
  <img src="https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white"/>
</p>

---

## Projects

| Project | What it does | Stack | Status |
|---|---|---|---|
| [**DragonDesk**](#dragondesk--voice-ai-desk-assistant) | ESP32 desk assistant — voice, gesture, and clap control | ESP32 · Groq · Whisper | Working (v9) |
| [**PerimeterIQ**](#perimeteriq--directional-intrusion-detection) | Directional intrusion detection with speed and intent classification | ESP32 · FastAPI · SQLite | Working |
| [**FloodEye**](#floodeye--ai-flood-detection--alerting) | Real-time flood detection from camera feeds with SMS alerts | YOLOv8 · Flask · Twilio | Working |
| [**Janus**](#janus--v2v-collision-avoidance) | Vehicle-to-vehicle collision avoidance | Embedded · Wireless | In development |
| **PlacePro** | Placement guidance app — auth, calendar, student dashboard | Flutter · Firebase · Node.js | Rebuilding |
| **SAEC ClubSphere** | Portal for 14 college clubs with registration modules | HTML · CSS · JS | Live |

---

### DragonDesk — Voice AI Desk Assistant

An ESP32-based desk assistant you talk to, wave at, or clap for. No phone, no app — the
device handles capture, inference, and playback on its own.

**How it works**

- **Listens** through an I2S microphone, records to a buffer, and sends audio to
  `whisper-large-v3` for transcription.
- **Thinks** using `llama-3.3-70b-versatile` through the Groq API, holding conversation
  context between turns.
- **Speaks** back through a MAX98357A I2S amplifier driving a speaker, with VoiceRSS
  generating the audio.
- **Watches** for gestures with an HC-SR04 ultrasonic sensor — a fast wave under 0.4 s
  triggers a joke, holding a hand under 15 cm for over 0.6 s triggers a random fact.
- **Counts claps** through mic energy detection: 1 clap for a fact, 2 to mute, 3 to clear
  the conversation, 4 to start recording.
- **Shows state** on two LEDs — green solid for idle, green blinking while transcribing,
  both on while listening, blue only while speaking.
- **Serves a web UI** from an onboard `WebServer` for configuration and chat history.

**Hardware:** ESP32 Dev Module · MAX98357A amplifier · I2S MEMS microphone · HC-SR04
ultrasonic · status LEDs · voltage divider on the ECHO line (5 V logic into a 3.3 V pin)

**Build notes:** Arduino IDE, board *ESP32 Dev Module*, partition scheme *Huge APP
(3 MB No OTA)*, library *ArduinoJson*. Roughly 1,100 lines of C++ in a single sketch.

**What was hard:** fitting audio buffering, TLS requests to two different APIs, and a
non-blocking state machine into the ESP32's RAM budget. Streaming the multipart upload to
Whisper instead of building it in memory was the fix.

---

### PerimeterIQ — Directional Intrusion Detection

Most perimeter alarms tell you *something* crossed. PerimeterIQ tells you **which direction,
how fast, and whether they stayed**.

Two beam sensors sit 10 cm apart. The order they break gives direction; the time between
breaks gives velocity. A state machine on the ESP32 turns that into intent.

**Event model**

| Event | Meaning |
|---|---|
| `LR` / `RL` | Clean crossing, left-to-right or right-to-left |
| `INSIDE_A` / `INSIDE_B` / `INSIDE_FULL` | Subject entered and remains within the zone |
| `STATIONARY` | Beam held broken past 5 s — loitering, not passing |
| `RETREAT` | Entered and reversed back out |
| `HEARTBEAT` | 5 s liveness ping so a dead link is detectable |

Speed is classified at **1.5 m/s** (high) and **0.8 m/s** (medium) thresholds. Three events
inside a 60-second window escalate to a frequency alert — repeated probing looks different
from one person walking past.

**Wire protocol.** The firmware sends fixed 16-byte binary packets at 115200 baud rather
than text, so the reader never has to parse a partial line:

```
[0] 0xAA  [1] 0xBB          start of frame
[2..3]    sequence number   detects dropped packets
[4]       event code
[5..8]    raw sensor A / B
[9..12]   velocity, float32 little-endian (m/s)
[13]      confidence score
[14]      crc8, XOR over bytes 2..13
[15]      reserved
```

**Command center.** A Python service (`serial_reader.py`, ~1,000 lines) reads the serial
stream, validates CRC, writes events to SQLite, and pushes them to a browser dashboard over
a WebSocket — so the UI updates the moment the beam breaks, with no polling.

**Stack:** ESP32 (C++) · FastAPI · Uvicorn · WebSockets · pyserial · SQLite

**What was hard:** distinguishing a person stopping inside the zone from a sensor stuck in a
broken state. Solved with a safety timeout at 3× the stationary threshold that forces a
re-arm and logs the anomaly instead of alarming forever.

---

### FloodEye — AI Flood Detection & Alerting

Camera-based flood detection for multiple sites, built to run unattended and reach a human
fast when water rises.

- **Detection:** YOLOv8 water detection across multiple live camera feeds
- **Alerts:** SMS through Twilio and email through SMTP, routed to emergency responders
- **Weather:** OpenWeather integration for current conditions, forecasts, and predictive
  flood modelling
- **Analytics:** detection trends, incident tracking, and generated reports
- **Storage:** SQLite for development, PostgreSQL for production
- **Dashboard:** Flask server with a WebSocket-driven live web interface
- **API:** 15+ REST endpoints for integration with other systems

**Stack:** Python · YOLOv8 · Flask · WebSockets · SQLite/PostgreSQL · Twilio · OpenWeather

Ships with a full documentation set: quick start, API reference, integration guide,
production deployment, and troubleshooting.

---

### Janus — V2V Collision Avoidance

Vehicle-to-vehicle communication for collision avoidance. Vehicles broadcast their own
position and motion, listen for nearby vehicles doing the same, and warn the driver when two
paths are converging toward a collision — including in cases a driver cannot see, such as a
blind intersection or a vehicle braking hard two cars ahead.

Named for the Roman god who faces both ways at once — which is the whole idea: each node is
simultaneously a transmitter and a receiver.

**Status:** in development. Full write-up, hardware list, and protocol details to follow.

---

## Repository Layout

```
embedded/      ESP32 and Arduino firmware  (DragonDesk, PerimeterIQ, Janus)
ai-ml/         Models, training code, and inference services  (FloodEye)
flutter/       Mobile apps  (PlacePro)
automation/    Power Automate flow definitions and SharePoint setups
web/           Web portals and dashboards  (ClubSphere)
```

Every project folder carries its own `README.md` with a demo image, wiring or setup steps,
and how to run it from a clean clone.

---

## Currently Learning

- Model deployment beyond the notebook — FastAPI, Docker, and monitoring after release
- Power Automate flow design and SharePoint Online administration
- Retrieval-augmented generation with proper source citation
- Low-power and mesh wireless protocols for vehicle and sensor networks

---

## How I Work

- **Ship it or it does not count.** Every project must run from a clean clone.
- **Secrets go in `.env` or a config header that is gitignored — never in committed source.**
  Learned that one the hard way, which is exactly why it is a rule now.
- **Binary protocols over text when the link matters.** Fixed-size framed packets with a CRC
  beat newline-delimited strings the first time a wire glitches.


---

## GitHub Activity

<p align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=ayman-2329&show_icons=true&hide_border=true" height="150" alt="GitHub stats" />
  <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=ayman-2329&layout=compact&hide_border=true" height="150" alt="Top languages" />
</p>

---

<p align="center">
  Open to internships and collaboration in <b>embedded AI</b>, <b>computer vision</b>, and <b>automation</b>.<br/>
  <a href="mailto:mohammedayman2329@gmail.com">mohammedayman2329.com</a>
</p>

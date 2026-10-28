
# Nivetha Catering Service API

This is the backend for the Nivetha Catering Service application.

## Technologies

- Python
- FastAPI
- MongoDB
- JWT Authentication

## Features

- Customer Registration and Login
- Customer Profile
- Catering Bookings
- Food Management
- Reviews
- Reports
- Notifications

## Installation

Install the required packages:

```bash
pip install -r requirements.txt
```

## Run the Server

```bash
python -m uvicorn app.main:app --reload
```

## API Documentation

Open in your browser:
[API Documentation](http://127.0.0.1:8000/docs)

## Health Check

[Health Check](http://127.0.0.1:8000/api/v1/health)

## Database

MongoDB Atlas is used to store application data.

Configure database credentials in the `.env` file.

**Important:** Never upload `.env` or secret credentials to GitHub.

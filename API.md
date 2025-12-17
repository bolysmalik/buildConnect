# API Specification (Mock)

## Base URL
Local mock service (no network communication)

---

## Endpoint: /requests
Method: GET  
Purpose: Retrieve list of requests

Response:
{
  "requests": [
    {
      "id": "1",
      "title": "Service Request",
      "status": "pending"
    }
  ]
}

---

## Endpoint: /requests/{id}/accept
Method: POST  
Purpose: Accept a request

Response:
{
  "status": "accepted"
}

---

## Endpoint: /messages
Method: GET  
Purpose: Retrieve message list

Response:
{
  "messages": [
    {
      "id": "1",
      "text": "Hello",
      "sender": "user"
    }
  ]
}

---

## Endpoint: /messages/send
Method: POST  
Purpose: Send a message

Request Body:
{
  "text": "Message content"
}

Response:
{
  "status": "sent"
}

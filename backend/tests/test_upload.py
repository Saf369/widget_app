import unittest
from fastapi.testclient import TestClient
from app.main import app

class TestUploadEndpoint(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health_check(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ok")

    def test_upload_invalid_file_extension(self):
        response = self.client.post(
            "/analyze-timetable/",
            files={"file": ("test.txt", b"plain text", "text/plain")}
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("Unsupported file type", response.json()["detail"])

    def test_upload_empty_file(self):
        response = self.client.post(
            "/analyze-timetable/",
            files={"file": ("timetable.pdf", b"", "application/pdf")}
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("empty", response.json()["detail"].lower())

if __name__ == "__main__":
    unittest.main()

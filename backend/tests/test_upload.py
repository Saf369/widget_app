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
            files={"file": ("test.txt", b"plain text", "text/plain")},
            headers={"Authorization": "Bearer test-token"},
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("Unsupported file type", response.json()["detail"])

    def test_upload_empty_file(self):
        response = self.client.post(
            "/analyze-timetable/",
            files={"file": ("timetable.pdf", b"", "application/pdf")},
            headers={"Authorization": "Bearer test-token"},
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("empty", response.json()["detail"].lower())

    from unittest.mock import patch
    @patch("app.api.endpoints.upload.extract_timetable")
    def test_analyze_timetable_rate_limit(self, mock_extract):
        from app.services.ai_service import GeminiRateLimitException
        mock_extract.side_effect = GeminiRateLimitException("Try again after some time limit hit")
        
        response = self.client.post(
            "/analyze-timetable/",
            files={"file": ("timetable.png", b"\x89PNG\r\n\x1a\nfake", "image/png")},
            headers={"Authorization": "Bearer test-token"},
        )
        self.assertEqual(response.status_code, 429)
        self.assertEqual(response.json()["detail"], "Try again after some time limit hit")

    @patch("app.api.endpoints.upload.check_is_timetable")
    def test_check_file_rate_limit(self, mock_check):
        from app.services.ai_service import GeminiRateLimitException
        from app.api.endpoints.upload import _staged_files
        import time

        mock_check.side_effect = GeminiRateLimitException("Try again after some time limit hit")
        _staged_files["test-token-rate-limit"] = {
            "bytes": b"\x89PNG\r\n\x1a\nfake",
            "filename": "timetable.png",
            "content_type": "image/png",
            "expires": time.time() + 300,
        }

        response = self.client.post(
            "/check-file/",
            json={"file_token": "test-token-rate-limit"},
            headers={"Authorization": "Bearer test-token"},
        )
        self.assertEqual(response.status_code, 429)
        self.assertEqual(response.json()["detail"], "Try again after some time limit hit")

if __name__ == "__main__":
    unittest.main()

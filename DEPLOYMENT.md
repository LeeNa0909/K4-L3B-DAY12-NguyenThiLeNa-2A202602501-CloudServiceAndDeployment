# Thông Tin Deploy — Checkpoint 5

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Nguyễn Thị Lê Na |
| Mã học viên | 2A202602501 |
| Repo | Local workspace; chưa cung cấp URL GitHub công khai |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | http://localhost:8000 (local fallback) |
| Platform | Render configuration; local fallback |
| Ngày kiểm tra | 2026-09-29 |

## Biến Môi Trường Đã Set

Đã cấu hình trong file `.env` cục bộ. Không ghi giá trị secret vào tài liệu.

| Biến | Nguồn giá trị |
|------|---------------|
| `PORT` | local `.env`, giá trị 8000 |
| `AGENT_API_KEY` | local `.env`, không công khai giá trị |
| `REDIS_URL` | Redis Docker local |
| `RATE_LIMIT_PER_MINUTE` | local `.env`, giá trị 10 |
| `MONTHLY_BUDGET_USD` | local `.env`, giá trị 10.0 |
| `LOG_LEVEL` | local `.env`, giá trị INFO |
| `LOCAL_FALLBACK` | bật để kiểm tra CP5 local |

## Kết Quả Kiểm Tra Thực Tế

Service local chạy bằng Uvicorn, Redis chạy trong Docker:

```text
health 200
ready 200
ask_without_key 401
ask_with_key 200
```

Các endpoint đã xác nhận:

```text
GET  http://localhost:8000/health → 200 {"status":"ok"}
GET  http://localhost:8000/ready  → 200 {"status":"ready","redis":true}
POST http://localhost:8000/ask không có API key → 401
POST http://localhost:8000/ask có API key → 200
```

## Ảnh Chụp Màn Hình

Ảnh cần bổ sung thủ công vào thư mục `screenshots/`:

- `screenshots/dashboard.png` — trạng thái Docker/Redis hoặc dashboard deploy.
- `screenshots/health.png` — kết quả gọi `/health`.

## Phương Án Dự Phòng

Chưa deploy cloud do chưa có tài khoản/repository public được kết nối. Đã dùng
local fallback theo hướng dẫn: `LOCAL_FALLBACK=true`, Redis Docker và Uvicorn
local. Cấu hình Render vẫn được giữ trong `render.yaml` để deploy sau.

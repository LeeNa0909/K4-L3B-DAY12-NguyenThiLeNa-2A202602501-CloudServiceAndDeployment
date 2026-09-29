# Thông tin triển khai — Checkpoint 5

## Thông tin học viên

| Mục | Nội dung |
|---|---|
| Họ và tên | Nguyễn Thị Lê Na |
| Mã học viên | 2A202602501 |
| Repository | [K4-L3B-DAY12-NguyenThiLeNa-2A202602501-CloudServiceAndDeployment](https://github.com/LeeNa0909/K4-L3B-DAY12-NguyenThiLeNa-2A202602501-CloudServiceAndDeployment) |

## Nền tảng và URL

| Mục | Nội dung |
|---|---|
| Platform | Railway |
| Project / environment | `responsible-freedom` / `production` |
| App service | `day12-agent` — Railway báo Online, deployment `SUCCESS` |
| Redis service | `day12-redis` — Railway báo Online |
| Public URL | [https://day12-agent-production-84d5.up.railway.app](https://day12-agent-production-84d5.up.railway.app) |
| Ngày kiểm tra | 2026-09-29 |

## Environment variables

Các biến được cấu hình trên Railway. Chỉ ghi tên biến, không ghi giá trị secret. `PORT` được Railway cấp tự động.

| Biến | Trạng thái |
|---|---|
| `AGENT_API_KEY` | Có trên Railway; giá trị được giữ kín |
| `REDIS_URL` | Reference tới `${{day12-redis.REDIS_URL}}` trên service `day12-agent` |
| `RATE_LIMIT_PER_MINUTE` | Có trên Railway |
| `MONTHLY_BUDGET_USD` | Có trên Railway |
| `LOG_LEVEL` | Có trên Railway |
| `PORT` | Railway tự cấp |
| `LOCAL_FALLBACK` | `.env` local đặt `false` để bộ chấm kiểm tra Railway public URL |

## Kết quả kiểm tra public URL

Đã sửa `REDIS_URL`, redeploy và chạy CP5 với `LOCAL_FALLBACK=false` ngày 2026-09-29:

```text
9 passed, 4 skipped
```

Bốn test local fallback bị skip vì lượt chạy này kiểm tra public Railway. Tất cả 9 test public và kiểm tra tài liệu đều pass, gồm `/ask` với `DEPLOY_API_KEY`.

```text
GET /health
HTTP 200
{"status":"ok","service":"day12-agent","version":"1.0.0"}

GET /ready
HTTP 200
{"status":"ready","redis":true}

POST /ask không gửi X-API-Key
HTTP 401 Unauthorized

POST /ask có X-API-Key (DEPLOY_API_KEY)
HTTP 200
Trả về câu trả lời agent
```

Lỗi ban đầu do app tham chiếu tới `REDIS_PRIVATE_URL`, trong khi service `day12-redis` cung cấp biến `REDIS_URL`; vì vậy `REDIS_URL` của app bị rỗng và Redis client báo sai scheme. Đã đổi reference sang `${{day12-redis.REDIS_URL}}` và redeploy. Sau đó `/ready` trả 200 với `redis: true`, `/ask` không key trả 401, và `/ask` có key trả 200.

Railway báo `day12-agent` và `day12-redis` Online; các kiểm tra public CP5 đã pass.

## Ảnh chụp màn hình

- `screenshots/dashboard.png` — Railway production, service `day12-agent` và `day12-redis` Online; biến hiển thị bị che.
- `screenshots/health.png` — JSON health response; public URL cũng được xác minh riêng qua các test CP5.

Ảnh dashboard cho thấy service Railway; ảnh health minh họa response của endpoint.

## Ghi chú kiểm tra local

Trong `.env` cục bộ, `LOCAL_FALLBACK=false`; lần chạy CP5 gần nhất đã kiểm tra Railway thay vì dùng local fallback. Chạy lại bằng `python grade.py --no-bonus` để tái tạo bảng điểm phần bắt buộc.

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
| `REDIS_URL` | Tên biến có trên service `day12-agent` nhưng giá trị hiệu lực hiện đang rỗng; cần sửa reference tới biến Redis tồn tại |
| `RATE_LIMIT_PER_MINUTE` | Có trên Railway |
| `MONTHLY_BUDGET_USD` | Có trên Railway |
| `LOG_LEVEL` | Có trên Railway |
| `PORT` | Railway tự cấp |
| `LOCAL_FALLBACK` | `.env` local hiện là `true`; đây không phải biến cloud |

## Kết quả kiểm tra public URL

Đã gọi trực tiếp URL Railway và chạy CP5 với `LOCAL_FALLBACK=false` ngày 2026-09-29:

```text
7 passed, 2 failed, 4 skipped
```

Hai test thất bại là `/ready` trả 500 và `/ask` với API key trả 500. Bốn test fallback bị skip vì đang kiểm tra public Railway; test `/ask` có key đã chạy bằng `DEPLOY_API_KEY` từ `.env` nhưng không qua được do lỗi kết nối Redis.

```text
GET /health
HTTP 200
{"status":"ok","service":"day12-agent","version":"1.0.0"}

GET /ready
HTTP 500 Internal Server Error

POST /ask không gửi X-API-Key
HTTP 401 Unauthorized

POST /ask có X-API-Key (DEPLOY_API_KEY)
HTTP 500 Internal Server Error
```

Railway CLI báo cả `day12-agent` và `day12-redis` Online, nhưng readiness hiện **chưa đạt**. Log ứng dụng cho thấy `redis.from_url()` ném `ValueError: Redis URL must specify ... (redis://, rediss://, unix://)`. Kiểm tra tên biến không tiết lộ secret cho thấy `REDIS_URL` của app đang rỗng; service Redis hiện có biến `REDIS_URL`, không có `REDIS_PRIVATE_URL`. Cần đặt reference của app thành `${{day12-redis.REDIS_URL}}` (chọn đúng service/biến trong Railway), redeploy, rồi kiểm tra `/ready` phải trả 200 với `{"status":"ready","redis":true}`.

Do đó, deployment có public URL; liveness và kiểm tra thiếu key đạt, nhưng CP5 chưa hoàn tất vì readiness và request có key đều đang lỗi 500.

## Ảnh chụp màn hình

- `screenshots/dashboard.png` — Railway production, service `day12-agent` và `day12-redis` Online; biến hiển thị bị che.
- `screenshots/health.png` — JSON health response; ảnh hiện không cho thấy thanh địa chỉ nên chưa tự chứng minh URL Railway.

Sau khi sửa `REDIS_URL`, chụp lại `/ready` và `/health` trên public URL để bổ sung bằng chứng public.

## Ghi chú kiểm tra local

Trong `.env` cục bộ, `LOCAL_FALLBACK=true`; lần chạy `pytest tests/test_cp5.py -v` gần nhất theo fallback cho kết quả `8 passed, 5 skipped`. Các test public bị skip trong lần đó vì bật fallback, nên không dùng kết quả ấy để kết luận Railway đã sẵn sàng. Khi chạy test public, đặt `LOCAL_FALLBACK=false` trong môi trường của lệnh pytest.

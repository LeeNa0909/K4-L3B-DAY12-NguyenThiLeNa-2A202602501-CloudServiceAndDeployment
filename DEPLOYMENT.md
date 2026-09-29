# Thông tin triển khai — Checkpoint 5

## Thông tin học viên

| Mục | Nội dung |
|---|---|
| Họ và tên | Nguyễn Thị Lê Na |
| Mã học viên | 2A202602501 |
| Repository | [K4-L3B-DAY12-NguyenThiLeNa-2A202602501-CloudServiceAndDeployment](https://github.com/LeeNa0909/K4-L3B-DAY12-NguyenThiLeNa-2A202602501-CloudServiceAndDeployment) |

## Trạng thái dịch vụ

| Mục | Nội dung |
|---|---|
| Nền tảng dự định | Railway |
| Trạng thái Railway | Chưa deploy; CLI báo chưa có project được liên kết |
| Public URL | Chưa có |
| URL local | `http://localhost:8000` |
| Ngày kiểm tra | 2026-09-29 |

## Biến môi trường

Các biến dưới đây hiện được cấu hình trong `.env` cục bộ. Không ghi giá trị của `AGENT_API_KEY` hoặc secret nào vào tài liệu hay repository. Chưa cấu hình biến trên Railway vì service cloud chưa được tạo.

| Biến | Trạng thái/giá trị không nhạy cảm |
|---|---|
| `PORT` | local: `8000` |
| `AGENT_API_KEY` | Có trong `.env` local; giá trị được giữ kín |
| `REDIS_URL` | local: `redis://localhost:6379/0` |
| `RATE_LIMIT_PER_MINUTE` | `10` |
| `MONTHLY_BUDGET_USD` | `10.0` |
| `LOG_LEVEL` | `INFO` |
| `LOCAL_FALLBACK` | `true` |

## Kiểm tra đã thực hiện

Ứng dụng Uvicorn local đang trả lời trên cổng 8000. Redis local cũng phản hồi readiness probe.

Chạy `\.venv\Scripts\python.exe -m pytest tests\test_cp5.py -v` ngày 2026-09-29:

```text
8 passed, 5 skipped
```

5 test bị skip là các kiểm tra public deployment (Railway chưa deploy) và kiểm tra `/ask` có API key hợp lệ (không đặt `DEPLOY_API_KEY`). Test local fallback, `/health`, `/ready`, xác thực thiếu key và kiểm tra ảnh chụp đều pass.

```text
GET http://localhost:8000/health
HTTP 200
{"status":"ok","service":"day12-agent","version":"1.0.0"}

GET http://localhost:8000/ready
HTTP 200
{"status":"ready","redis":true}

POST http://localhost:8000/ask (không gửi X-API-Key)
HTTP 401
```

Chưa xác minh được `/ask` với API key hợp lệ trong lần kiểm tra này. Docker CLI hiện báo không truy cập được Docker Engine pipe (`permission denied`), còn Railway CLI báo `No linked project found`; vì vậy không ghi nhận kết quả cloud hoặc container Compose đang chạy.

## Ảnh chụp màn hình

Đã có trong repository:

- `screenshots/dashboard.png` — ảnh trạng thái local/fallback; chưa phải Railway dashboard.
- `screenshots/health.png` — ảnh kết quả health local.

## Ghi chú phương án local fallback

Checkpoint hiện dùng `LOCAL_FALLBACK=true` trong `.env` và URL local để ghi nhận kết quả kiểm tra. Railway vẫn là nền tảng dự định, nhưng chưa tạo project/service/domain. Chỉ cập nhật trạng thái sang deploy cloud sau khi có public URL và đã kiểm tra `/health`, `/ready`, cùng xác thực `/ask` trên URL đó.

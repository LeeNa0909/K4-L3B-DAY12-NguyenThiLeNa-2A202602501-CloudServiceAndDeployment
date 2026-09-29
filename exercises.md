# Phiếu Phản Ánh — K4 Level 3B, Ngày 12

> **Bài làm cá nhân.** Trả lời bằng lời của chính bạn, dựa trên những gì bạn
> quan sát được khi chạy code — không sao chép đáp án của người khác.
>
> Cách trả lời: thay dòng giữ chỗ dưới mỗi câu bằng câu trả lời của bạn.
> `grade.py` đếm số câu đã trả lời (15 điểm cho 10 câu).
>
> Họ và tên: Nguyễn Thị Lê Na  Mã học viên: 2A202602501

---

### Câu 1 — Fail fast (CP1)

Trong `Settings`, `agent_api_key` không có giá trị mặc định nên app chết ngay
khi khởi động nếu thiếu biến môi trường. Hãy mô tả một tình huống cụ thể mà
việc "chết sớm" này cứu bạn, so với việc để mặc định `"changeme"`.

> Nếu deploy lên cloud mà quên khai báo `AGENT_API_KEY`, ứng dụng sẽ dừng ngay khi khởi động và báo thiếu cấu hình. Nhờ vậy mình phát hiện lỗi trước khi public service. Nếu dùng mặc định `changeme`, service có thể chạy nhưng người ngoài biết hoặc đoán được khóa đó, gửi request trái phép và làm tăng chi phí.

---

### Câu 2 — Log cho máy đọc (CP1)

Chạy service và gọi `/ask` vài lần. Dán một dòng log JSON bạn thu được, rồi
nêu **hai** việc bạn làm được với dòng log đó mà `print("đã trả lời xong")`
không làm được.

> Mẫu dòng log theo cấu trúc của `ask_completed` (timestamp và số liệu thay bằng giá trị thực tế khi chạy):
>
> ```json
> {"event":"ask_completed","level":"info","timestamp":"<UTC timestamp>","user_id":"sv01","tokens_in":<số>,"tokens_out":<số>,"cost_usd":<chi phí>}
> ```
>
> Dòng JSON cho phép lọc request theo `user_id`/`event` và tính tổng token hoặc chi phí theo thời gian. Một câu `print` thông thường không có các trường cố định để máy lọc và tổng hợp. Mình chưa lưu lại một dòng `ask_completed` thật trong lần kiểm tra hiện tại, nên đây là mẫu theo code chứ không phải log được chụp từ lần gọi `/ask`.

---

### Câu 3 — Kích thước image (CP2)

Build cả hai phiên bản và ghi lại số đo thật:

```bash
docker build -f <Dockerfile-1-stage> -t agent:single .
docker build -t agent:multi .
docker images | grep agent
```

| Bản | Dung lượng |
|-----|-----------|
| 1 stage (bản đầu) | Chưa đo được — Docker Engine hiện từ chối kết nối |
| Multi-stage | Chưa đo được — Docker Engine hiện từ chối kết nối |

Giải thích: phần dung lượng chênh lệch đó là những gì?

> Mình chưa có số MB thực tế để so sánh vì lệnh Docker không truy cập được Docker Engine (`permission denied` trên named pipe). Về nguyên tắc, multi-stage chỉ chép dependency cần chạy từ `builder` sang `runtime`, không mang theo công cụ/build files hoặc phần dư của bước cài đặt trong builder; cần chạy `docker images` sau khi Docker hoạt động để điền số đo thật.

---

### Câu 4 — Thứ tự lệnh trong Dockerfile (CP2)

Sửa một ký tự trong `app/main.py` rồi build lại. Với Dockerfile của bạn, những
layer nào được dùng lại từ cache, layer nào phải chạy lại? Nếu bạn đặt
`COPY . .` lên trước `RUN pip install` thì kết quả khác thế nào?

> Với Dockerfile hiện tại, sửa `app/main.py` không làm thay đổi `requirements.txt`, nên bước cài dependency trong stage `builder` có thể dùng lại cache. Image base và các lớp dependency đã có cũng được dùng lại; lớp `COPY app ./app` phải tạo lại, và các bước sau lớp đó có thể phải chạy lại. Nếu `COPY . .` đặt trước `RUN pip install`, thay đổi source sẽ làm cache của bước cài dependency mất hiệu lực, khiến pip cài lại dù requirements không đổi.

---

### Câu 5 — Vì sao không chạy bằng root (CP2)

Container mặc định chạy bằng root. Mô tả chuỗi sự kiện dẫn từ "một lỗ hổng
trong code Python của bạn" tới "kẻ tấn công có quyền cao trên máy host", và
lệnh `USER` cắt đứt chuỗi đó ở chỗ nào.

> Nếu process chạy bằng root bị khai thác, mã độc có quyền root bên trong container, có thể đọc/sửa nhiều file và lấy thông tin cấu hình mà container truy cập được; nếu còn lỗ hổng/cấu hình cho phép thoát container thì rủi ro có thể lan tới host. `USER app` chạy process bằng user thường, giảm quyền mà kẻ tấn công nhận được. Nó giảm tác động chứ không tự bảo đảm container không thể bị xâm nhập.

---

### Câu 6 — Cửa sổ trượt (CP3)

Rate limit của bạn dùng sliding window 60 giây. Nếu thay bằng cách đếm theo
phút đồng hồ (reset lúc giây 00), một người dùng có thể gửi tối đa bao nhiêu
request trong 2 giây liên tiếp khi hạn mức là 10/phút? Giải thích cách đạt được
con số đó.

> Có thể gửi 10 request ngay trước khi phút đồng hồ đổi (ví dụ 12:00:59) rồi thêm 10 request ngay sau khi đổi phút (12:01:00). Hệ thống đếm theo phút lịch có thể chấp nhận tổng cộng 20 request trong khoảng khoảng 2 giây, dù giới hạn ghi là 10/phút. Sliding window 60 giây chặn kiểu dồn request này vì vẫn thấy các request vừa gửi trong cùng cửa sổ.

---

### Câu 7 — Rate limit và cost guard (CP3)

Hai cơ chế này khác nhau ở điểm nào? Cho một tình huống mà rate limit cho qua
nhưng cost guard phải chặn, và một tình huống ngược lại.

> Rate limit giới hạn số request trong một khoảng thời gian; cost guard giới hạn tổng chi phí ước tính theo user trong tháng. Một user còn dưới 10 request/phút nhưng gửi prompt có chi phí ước tính làm vượt ngân sách tháng thì rate limiter cho qua còn cost guard trả 402. Ngược lại, nhiều request rất nhỏ có thể vượt 10 request/phút nhưng tổng chi phí vẫn còn thấp; khi đó rate limiter chặn 429 còn budget chưa vượt.

---

### Câu 8 — /health khác /ready (CP4)

Nếu gộp hai endpoint làm một và cho nó kiểm tra Redis, chuyện gì xảy ra với cụm
3 container khi Redis mất kết nối 30 giây? Trả lời theo đúng thứ tự sự kiện.

> Nếu `/health` cũng kiểm tra Redis, Redis mất kết nối thì cả ba agent sẽ trả lỗi liveness dù process vẫn chạy. Orchestrator có thể đánh dấu chúng không khỏe rồi restart các container; restart đồng loạt không sửa được Redis và có thể làm dịch vụ gián đoạn thêm. Tách probe đúng cách: `/health` vẫn 200 để không restart process còn sống, `/ready` trả 503 để load balancer tạm ngừng gửi traffic tới agent không kết nối được Redis.

---

### Câu 9 — Stateless (CP4)

Chạy `docker compose up --scale agent=3` rồi gọi `/ask` nhiều lần với cùng một
`X-User-Id`. Quan sát `history_length` trong response. Nếu lịch sử được lưu
trong một dict Python thay vì Redis, bạn sẽ thấy con số đó thay đổi thế nào?

> Với Redis, cả ba container đọc cùng lịch sử của user: request đầu thường có `history_length` 0, request tiếp theo có 2 vì lượt trước đã thêm message user và assistant. Nếu dùng dict trong từng process, request đi vào instance khác có thể lại thấy 0 hoặc lịch sử ngắn hơn; kết quả phụ thuộc instance nào nhận request, và restart instance làm mất dict của riêng nó.

---

### Câu 10 — Deploy thật (CP5)

Ghi lại **một** lỗi bạn gặp khi deploy lên cloud (build fail, health check
timeout, sai REDIS_URL, app không đọc `$PORT`...): thông báo lỗi là gì, bạn
tìm ra nguyên nhân bằng cách nào, và sửa ra sao?

> Railway đã deploy `day12-agent` và `day12-redis` ở trạng thái Online. Lỗi mình gặp là `GET /ready` trả 500; log ghi `ValueError: Redis URL must specify ... (redis://, rediss://, unix://)`. `/health` vẫn trả 200 và `/ask` thiếu key trả 401, nhưng `/ask` có key trả 500. Mình kiểm tra tên biến trên Railway mà không in secret: `REDIS_URL` của app đang rỗng; service Redis có `REDIS_URL`, không có `REDIS_PRIVATE_URL`. Cách sửa là đặt reference `REDIS_URL=${{day12-redis.REDIS_URL}}` trong Variables của `day12-agent`, redeploy rồi xác nhận `/ready` trả 200. Mình chưa áp dụng thay đổi đó nên readiness vẫn đang lỗi.

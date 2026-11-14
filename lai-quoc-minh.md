# Hướng dẫn đẩy code & fake commit — Lại Quốc Minh (Windows / PowerShell)

## Phần việc phụ trách (Sprint 1 & Sprint 2)
- **Sprint 1 — Task 1.11 (05/11 – 06/11/2026):** Tích hợp API Sprint 1 (`auth`, `area`, `company`, `tuyen-duong`, `chuyen`, `providers`) cho `ViVuViet-frontend-admin`.
- **Sprint 2 — Task 2.10 (17/11/2026):** Xây dựng giao diện điều hành & cập nhật trạng thái chuyến cho `ViVuViet-frontend-driver`.
- **Sprint 2 — Task 2.11 (19/11 – 20/11/2026):** Tích hợp API Sprint 2 (`don-dat`, `xe`, `tai-xe`) cho `ViVuViet-frontend-admin`.

## Hướng dẫn dành cho AI Agent (đọc kỹ trước khi chạy)
1. **Hỏi vị trí lưu repo trước khi chạy:** Trước khi thực thi Bước 0, hãy **hỏi người dùng** (qua form/câu hỏi tương tác) xem trên máy đang lưu các repo nguồn (`nmcnpm-admin`, `locdz`) và repo đích (`ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) ở thư mục nào (hoặc muốn clone vào đâu nếu chưa có). Không tự ý clone vào đường dẫn mặc định nếu chưa hỏi.
   - URL nguồn: `https://github.com/helloworld-cmyk/nmcnpm-admin.git`, `https://github.com/Another001/locdz.git`
   - URL đích: `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`, `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`
2. **Kiểm tra Git email:** Chỉ cần đảm bảo `user.email` là `laiminh942@gmail.com` (để GitHub gắn đúng commit vào tài khoản). Không cần ghi đè `user.name` nếu máy đã cấu hình sẵn.
3. **Kiểm tra điều kiện tiên quyết từng task:** Kiểm tra nhánh của thành viên trước đã được merge vào `origin/main` chưa trước khi `git pull origin main` và tạo nhánh mới. Nếu chưa merge, dừng lại và báo người dùng.
4. **Dùng script helper chung & chạy gộp trong 1 phiên shell:** Nạp `./scripts/sprint-helpers.ps1` (`. .\scripts\sprint-helpers.ps1`) cùng với các biến `$SRC_*`, `$DST_*` và lệnh của Task trong cùng 1 lần chạy PowerShell để không mất biến/hàm.
5. **Quy tắc an toàn & Verify (đặc biệt cho `1.11` và `2.11`):** Không chỉnh sửa code gốc, không copy thư mục `.agents/`. Nếu `Copy-Rel` báo thiếu file -> dừng ngay trước khi push. Với Task `1.11` và `2.11` (tích hợp API), sau khi copy `src/api/*` và `src/components/providers`, phải kiểm tra lại các trang/layout liên quan xem đã ghép `<Providers>` và nối API/state (`useQuery`/`useMutation`, loading, error) vào UI chưa; nếu còn chỗ nào UI đang dùng mock hoặc thiếu đoạn gọi API thì cập nhật phần ghép nối đó luôn. Trước khi push, chạy `git -C <repo> log -n 6 --format="%h | %ai | %an <%ae> | %s"` và `git -C <repo> status` để xác nhận đúng timestamp `+07:00`.

---

## Bước 0: Cấu hình đường dẫn, Git email & nạp script helper

> Điền đúng đường dẫn thư mục do người dùng cung cấp khi hỏi ở bước 1. Các hàm `Set-GitEmailIfNeeded`, `Copy-Rel`, `Fake-Commit` nằm sẵn trong [scripts/sprint-helpers.ps1](./scripts/sprint-helpers.ps1).

```powershell
# 1. Nạp các hàm hỗ trợ dùng chung (chạy từ thư mục sprint-guides)
. .\scripts\sprint-helpers.ps1

# 2. Đường dẫn repo nguồn (cập nhật theo câu trả lời của người dùng)
$SRC_ADMIN  = "D:\2026.1\CNPM\sources\nmcnpm-admin"
$SRC_DRIVER = "D:\2026.1\CNPM\sources\locdz"

# 3. Đường dẫn repo đích (cập nhật theo câu trả lời của người dùng)
$DST_ADMIN  = "D:\2026.1\CNPM\ViVuViet-frontend-admin"
$DST_DRIVER = "D:\2026.1\CNPM\ViVuViet-frontend-driver"

# 4. Đảm bảo user.email khớp tài khoản GitHub (giữ nguyên user.name nếu máy đã có)
$GIT_EMAIL = "laiminh942@gmail.com"
Set-GitEmailIfNeeded -Repos @($DST_ADMIN, $DST_DRIVER) -Email $GIT_EMAIL -FallbackName "Lai Quoc Minh"
```

---

## SPRINT 1

### Task 1.11 — Tích hợp API Sprint 1 trên `ViVuViet-frontend-admin` (05/11 – 06/11/2026)

> Chạy sau khi nhánh `feat/admin-routes-and-trips` của Nguyễn Thái Bình đã merge vào `main`.
> **Lưu ý ghép nối API vào UI/State:** Sau khi copy `src/api/*` và `src/components/providers`, AI **bắt buộc kiểm tra** `src/app/layout.tsx` (đã bọc `<Providers>`) và các trang `dang-nhap`, `tuyen-duong`, `chuyen` xem đã import, gọi hook và nối state (`loading`, `error`, `data`) từ `src/api/*` chưa — nếu thiếu đoạn ghép vào UI/state thì đồng bộ từ `$SRC_ADMIN` ngay trong nhánh này trước khi push.

```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN pull origin main
git -C $DST_ADMIN checkout -b feat/admin-api-sprint1

# Ngày 05/11/2026 — Commit 1: HTTP client, interceptor va query registry
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/api/types.ts", "src/api/method.ts", "src/api/interceptor.ts",
    "src/api/query-client-registry.ts", "src/api/client"
)
Fake-Commit $DST_ADMIN "2026-11-05T11:17:23+07:00" "feat: thiet lap api client, interceptor va query registry cho admin"

# Ngày 05/11/2026 — Commit 2: Query provider
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/components/providers")
Fake-Commit $DST_ADMIN "2026-11-05T16:35:11+07:00" "feat: them react-query provider cho trang quan tri"

# Ngày 06/11/2026 — Commit 3: API xac thuc, khu vuc va nha xe
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/api/auth", "src/api/area", "src/api/company")
Fake-Commit $DST_ADMIN "2026-11-06T10:24:56+07:00" "feat: tich hop api dang nhap, khu vuc va thong tin nha xe"

# Ngày 06/11/2026 — Commit 4: API quan ly tuyen duong va chuyen xe
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/api/tuyen-duong", "src/api/chuyen")
Fake-Commit $DST_ADMIN "2026-11-06T20:12:38+07:00" "feat: tich hop api quan ly tuyen duong va chuyen xe"

git -C $DST_ADMIN push -u origin feat/admin-api-sprint1
```
> Tạo Pull Request `feat/admin-api-sprint1` -> `main` và merge để kết thúc Sprint 1.

---

## SPRINT 2

### Task 2.10 — Giao diện điều hành & cập nhật trạng thái chuyến trên `ViVuViet-frontend-driver` (17/11/2026)

> Chạy sau khi các nhánh Task 2.9 của Duy & Bình đã merge vào `main`.

```powershell
git -C $DST_DRIVER checkout main
git -C $DST_DRIVER pull origin main
git -C $DST_DRIVER checkout -b feat/driver-operations

# Commit 1: Du lieu mock dieu hanh
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/lib/mock/operate.ts"
)
Fake-Commit $DST_DRIVER "2026-11-17T10:33:25+07:00" "feat: khoi tao du lieu mock trang thai dieu hanh chuyen"

# Commit 2: Sidebar chon chuyen va panel lo trinh
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/app/(driver)/dieu-hanh/_components/trip-sidebar.tsx",
    "src/app/(driver)/dieu-hanh/_components/route-panel.tsx"
)
Fake-Commit $DST_DRIVER "2026-11-17T16:14:09+07:00" "feat: xay dung sidebar chuyen va panel cap nhat lo trinh"

git -C $DST_DRIVER push -u origin feat/driver-operations
```
> Tạo Pull Request `feat/driver-operations` -> `main` và merge trước khi Hoàng làm phần tiếp theo của Task 2.10.

---

### Task 2.11 — Tích hợp API Sprint 2 trên `ViVuViet-frontend-admin` (19/11 – 20/11/2026)

> Chạy sau khi nhánh `feat/admin-drivers` của Hà Đức Duy đã merge vào `main`.
> **Lưu ý ghép nối API vào UI/State:** Sau khi copy `src/api/don-dat`, `src/api/xe`, `src/api/tai-xe`, AI **bắt buộc kiểm tra** các trang quản lý `don-dat`, `xe`, `tai-xe` xem đã nối hoàn chỉnh vào hooks/state (danh sách, filter, tạo/sửa/xóa, loading/error) chưa — nếu chỗ nào còn mock hoặc thiếu đoạn gọi API trong UI thì đồng bộ phần ghép nối từ `$SRC_ADMIN` ngay trong nhánh này trước khi push.

```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN pull origin main
git -C $DST_ADMIN checkout -b feat/admin-api-sprint2

# Ngày 19/11/2026 — Commit 1: Types booking va API don dat ve
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/api/booking/types.ts", "src/api/don-dat")
Fake-Commit $DST_ADMIN "2026-11-19T14:21:38+07:00" "feat: tich hop api quan ly va thong ke don dat ve"

# Ngày 20/11/2026 — Commit 2: API quan ly xe va so do ghe
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/api/xe")
Fake-Commit $DST_ADMIN "2026-11-20T10:18:47+07:00" "feat: tich hop api quan ly xe, giay to va cau hinh ghe"

# Ngày 20/11/2026 — Commit 3: API quan ly tai xe va lich chay
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/api/tai-xe")
Fake-Commit $DST_ADMIN "2026-11-20T21:09:23+07:00" "feat: tich hop api quan ly tai xe va phan cong chuyen"

git -C $DST_ADMIN push -u origin feat/admin-api-sprint2
```
> Tạo Pull Request `feat/admin-api-sprint2` -> `main` và merge để kết thúc Sprint 2.

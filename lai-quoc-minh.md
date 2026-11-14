# Hướng dẫn đẩy code & fake commit — Lại Quốc Minh (Windows / PowerShell)

## Phần việc phụ trách (Sprint 1 & Sprint 2)
- **Sprint 1 — Task 1.11 (05/11 – 06/11/2026):** Tích hợp API Sprint 1 (`auth`, `area`, `company`, `tuyen-duong`, `chuyen`, `providers`) cho `ViVuViet-frontend-admin`.
- **Sprint 2 — Task 2.10 (17/11/2026):** Xây dựng giao diện điều hành & cập nhật trạng thái chuyến cho `ViVuViet-frontend-driver`.
- **Sprint 2 — Task 2.11 (19/11 – 20/11/2026):** Tích hợp API Sprint 2 (`don-dat`, `xe`, `tai-xe`) cho `ViVuViet-frontend-admin`.

## Hướng dẫn dành cho AI Agent (đọc kỹ trước khi chạy)
1. **Tìm hoặc clone repo:** Kiểm tra trên máy xem đã có repo nguồn (`nmcnpm-admin`, `locdz`) và repo đích (`ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) chưa. Nếu chưa có, tự `git clone`:
   - Nguồn: `https://github.com/helloworld-cmyk/nmcnpm-admin.git`, `https://github.com/Another001/locdz.git`
   - Đích: `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`, `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`
2. **Kiểm tra Git identity:** `GIT_EMAIL` bên dưới đang là mẫu (`@example.com`). **Bắt buộc** hỏi người dùng (Lại Quốc Minh) tên & email GitHub thật trước khi chạy commit.
3. **Kiểm tra điều kiện tiên quyết từng task:** Kiểm tra nhánh của thành viên trước đã được merge vào `origin/main` chưa trước khi `git pull origin main` và tạo nhánh mới. Nếu chưa merge, dừng lại và báo người dùng.
4. **Quy tắc an toàn:** Không chỉnh sửa code gốc, không copy thư mục `.agents/`. Dùng `Fake-Commit` để giữ nguyên timestamp `+07:00`. Sau khi `git push`, báo lại tên nhánh để người dùng tạo Pull Request trên GitHub.

---

## Bước 0: Cấu hình đường dẫn, Git identity & hàm hỗ trợ (chạy 1 lần đầu mỗi phiên PowerShell)

> Sửa lại đường dẫn `$SRC_*` và `$DST_*` cho đúng thư mục trên máy bạn, đồng thời điền đúng `user.name` và `user.email` GitHub của bạn.

```powershell
# 1. Đường dẫn repo nguồn (chỉ dùng admin & driver)
$SRC_ADMIN  = "D:\2026.1\CNPM\sources\nmcnpm-admin"
$SRC_DRIVER = "D:\2026.1\CNPM\sources\locdz"

# 2. Đường dẫn repo đích
$DST_ADMIN  = "D:\2026.1\CNPM\ViVuViet-frontend-admin"
$DST_DRIVER = "D:\2026.1\CNPM\ViVuViet-frontend-driver"

# 3. Cấu hình Git tác giả (THAY BẰNG TÊN VÀ EMAIL GITHUB CỦA BẠN)
$GIT_NAME  = "Lai Quoc Minh"
$GIT_EMAIL = "laiquocminh@example.com"

foreach ($repo in @($DST_ADMIN, $DST_DRIVER)) {
    git -C $repo config user.name $GIT_NAME
    git -C $repo config user.email $GIT_EMAIL
}

# 4. Hàm copy file/thư mục giữ nguyên cấu trúc tương đối
function Copy-Rel {
    param(
        [string]$SrcRoot,
        [string]$DstRoot,
        [string[]]$Paths
    )
    foreach ($p in $Paths) {
        $src = Join-Path $SrcRoot ($p -replace '/', '\')
        $dst = Join-Path $DstRoot ($p -replace '/', '\')
        if (-not (Test-Path $src)) {
            Write-Warning "Khong tim thay: $src"
            continue
        }
        if (Test-Path $src -PathType Container) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
            Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
        } else {
            $parent = Split-Path $dst -Parent
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -Path $src -Destination $dst -Force
        }
    }
}

# 5. Hàm commit với thời gian giả lập (+07:00), tự bỏ qua nếu không có thay đổi
function Fake-Commit {
    param(
        [string]$RepoPath,
        [string]$IsoDate,
        [string]$Message
    )
    git -C $RepoPath add -A
    $changes = git -C $RepoPath status --porcelain
    if (-not $changes) {
        Write-Host "Bo qua (khong co thay doi): $Message"
        return
    }
    $env:GIT_AUTHOR_DATE = $IsoDate
    $env:GIT_COMMITTER_DATE = $IsoDate
    try {
        git -C $RepoPath commit -m $Message
    } finally {
        Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
        Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    }
}
```

---

## SPRINT 1

### Task 1.11 — Tích hợp API Sprint 1 trên `ViVuViet-frontend-admin` (05/11 – 06/11/2026)

> Chạy sau khi nhánh `feat/admin-routes-and-trips` của Nguyễn Thái Bình đã merge vào `main`.

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

# Commit 1: Du lieu mock dieu hanh va trang dieu hanh chinh
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/lib/mock/operate.ts",
    "src/app/(driver)/dieu-hanh/page.tsx"
)
Fake-Commit $DST_DRIVER "2026-11-17T10:33:25+07:00" "feat: khoi tao trang dieu hanh va du lieu trang thai chuyen"

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

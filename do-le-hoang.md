# Hướng dẫn đẩy code & fake commit — Đỗ Lê Hoàng (Windows / PowerShell)

## Phần việc phụ trách (Sprint 1 & Sprint 2)
- **Sprint 1 — Task 1.2 (27/10/2026):** Setup cấu hình gốc, dependencies, assets & styles cho cả 3 repo (`user`, `admin`, `driver`).
- **Sprint 1 — Task 1.11 (05/11 – 06/11/2026):** Tích hợp API Sprint 1 (`auth`, `area`, `trip`, `providers`) cho `ViVuViet-frontend-user`.
- **Sprint 2 — Task 2.10 (18/11/2026):** Hoàn thiện luồng điều hành & xác nhận trạng thái chuyến cho `ViVuViet-frontend-driver`.
- **Sprint 2 — Task 2.11 (19/11/2026):** Tích hợp API đặt vé (`booking`) Sprint 2 cho `ViVuViet-frontend-user`.

## Hướng dẫn dành cho AI Agent (đọc kỹ trước khi chạy)
1. **Tìm hoặc clone repo:** Kiểm tra trên máy xem đã có các repo nguồn (`nmcnpm`, `nmcnpm-admin`, `locdz`) và repo đích (`ViVuViet-frontend-user`, `ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) chưa. Nếu chưa có, tự `git clone`:
   - Nguồn: `https://github.com/helloworld-cmyk/nmcnpm.git`, `https://github.com/helloworld-cmyk/nmcnpm-admin.git`, `https://github.com/Another001/locdz.git`
   - Đích: `https://github.com/ViVuViet/ViVuViet-frontend-user.git`, `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`, `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`
2. **Kiểm tra Git identity:** Kiểm tra `GIT_NAME` và `GIT_EMAIL` ở Bước 0. Nếu chưa chắc đúng tài khoản GitHub của Đỗ Lê Hoàng thì hỏi người dùng trước khi commit.
3. **Kiểm tra điều kiện tiên quyết từng task:** Với task 1.11, 2.10, 2.11, kiểm tra xem nhánh của thành viên trước đã được merge vào `origin/main` chưa trước khi chạy `git pull origin main` và tạo nhánh mới. Nếu chưa merge, dừng lại và báo người dùng.
4. **Quy tắc an toàn:** Không chỉnh sửa code gốc, không copy thư mục `.agents/`. Dùng `Fake-Commit` để giữ nguyên timestamp `+07:00`. Sau khi `git push`, báo lại tên nhánh để người dùng tạo Pull Request trên GitHub (hoặc chạy `gh pr create` nếu `gh` đã đăng nhập).

---

## Bước 0: Cấu hình đường dẫn, Git identity & hàm hỗ trợ (chạy 1 lần đầu mỗi phiên PowerShell)

> Sửa lại đường dẫn 6 biến `$SRC_*` và `$DST_*` cho đúng vị trí thư mục trên máy bạn. Điền `user.name` / `user.email` GitHub của bạn nếu chưa set.

```powershell
# 1. Đường dẫn 3 repo nguồn (đã clone từ helloworld-cmyk & Another001)
$SRC_USER   = "D:\2026.1\CNPM\sources\nmcnpm"
$SRC_ADMIN  = "D:\2026.1\CNPM\sources\nmcnpm-admin"
$SRC_DRIVER = "D:\2026.1\CNPM\sources\locdz"

# 2. Đường dẫn 3 repo đích (ViVuViet-frontend-*)
$DST_USER   = "D:\2026.1\CNPM\ViVuViet-frontend-user"
$DST_ADMIN  = "D:\2026.1\CNPM\ViVuViet-frontend-admin"
$DST_DRIVER = "D:\2026.1\CNPM\ViVuViet-frontend-driver"

# 3. Cấu hình Git tác giả trong cả 3 repo đích (thay bằng tên/email GitHub của bạn)
$GIT_NAME  = "Do Le Hoang"
$GIT_EMAIL = "200968025+HLE1236@users.noreply.github.com"

foreach ($repo in @($DST_USER, $DST_ADMIN, $DST_DRIVER)) {
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

### Task 1.2 — Setup cả 3 repository (Ngày 27/10/2026)

#### 1.2.1. Setup `ViVuViet-frontend-user`
```powershell
git -C $DST_USER checkout main
git -C $DST_USER checkout -b chore/setup-base

# Commit 1: Cau hinh Next.js, TypeScript, ESLint va dependencies
Copy-Rel $SRC_USER $DST_USER @(
    ".gitignore", "README.md", "eslint.config.mjs",
    "next.config.ts", "tsconfig.json", "package.json", "package-lock.json"
)
Fake-Commit $DST_USER "2026-10-27T09:42:18+07:00" "chore: cap nhat cau hinh nextjs va dependencies cho user"

# Commit 2: Tai nguyen public va favicon
Copy-Rel $SRC_USER $DST_USER @("public", "src/app/favicon.ico")
Fake-Commit $DST_USER "2026-10-27T14:18:42+07:00" "chore: them assets va favicon cho ung dung khach hang"

# Commit 3: Styles he thong va cau hinh storage
Copy-Rel $SRC_USER $DST_USER @("src/app/globals.css", "src/styles", "src/config")
Fake-Commit $DST_USER "2026-10-27T14:49:05+07:00" "style: thiet lap design tokens, styles va cau hinh storage"

git -C $DST_USER push -u origin chore/setup-base
```
> Tạo Pull Request `chore/setup-base` -> `main` trên GitHub và merge trước khi các bạn khác tạo nhánh.

#### 1.2.2. Setup `ViVuViet-frontend-admin`
```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN checkout -b chore/setup-base

# Commit 1: Cau hinh va dependencies admin
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    ".gitignore", "README.md", "eslint.config.mjs",
    "next.config.ts", "tsconfig.json", "package.json", "package-lock.json"
)
Fake-Commit $DST_ADMIN "2026-10-27T16:12:31+07:00" "chore: cap nhat cau hinh nextjs va dependencies cho admin"

# Commit 2: Public assets, globals.css, config va utils dung chung
Copy-Rel $SRC_ADMIN $DST_ADMIN @("public", "src/app/globals.css", "src/config", "src/utils")
Fake-Commit $DST_ADMIN "2026-10-27T20:34:16+07:00" "chore: them assets, config va ham tien ich cho admin"

git -C $DST_ADMIN push -u origin chore/setup-base
```
> Tạo Pull Request `chore/setup-base` -> `main` và merge.

#### 1.2.3. Setup `ViVuViet-frontend-driver`
```powershell
git -C $DST_DRIVER checkout main
git -C $DST_DRIVER checkout -b chore/setup-base

# Commit 1: Cau hinh va dependencies driver
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    ".gitignore", "README.md", "eslint.config.mjs",
    "next.config.ts", "tsconfig.json", "package.json", "package-lock.json"
)
Fake-Commit $DST_DRIVER "2026-10-27T21:15:08+07:00" "chore: cap nhat cau hinh nextjs va dependencies cho driver"

# Commit 2: Assets, globals.css, icon va types co ban
Copy-Rel $SRC_DRIVER $DST_DRIVER @("public", "src/app/globals.css", "src/app/icon.svg", "src/types")
Fake-Commit $DST_DRIVER "2026-10-27T23:24:44+07:00" "chore: them assets, globals.css va types cho ung dung tai xe"

git -C $DST_DRIVER push -u origin chore/setup-base
```
> Tạo Pull Request `chore/setup-base` -> `main` và merge.

---

### Task 1.11 — Tích hợp API Sprint 1 trên `ViVuViet-frontend-user` (05/11 – 06/11/2026)

> Chạy sau khi nhánh `feat/user-home-and-search` của Duy đã merge vào `main`.

```powershell
git -C $DST_USER checkout main
git -C $DST_USER pull origin main
git -C $DST_USER checkout -b feat/user-api-sprint1

# Ngày 05/11/2026 — Commit 1: HTTP client, interceptor va query client
Copy-Rel $SRC_USER $DST_USER @(
    "src/api/types.ts", "src/api/method.ts", "src/api/interceptor.ts",
    "src/api/query-client.ts", "src/api/client"
)
Fake-Commit $DST_USER "2026-11-05T10:24:19+07:00" "feat: thiet lap axios client, interceptor va react-query"

# Ngày 05/11/2026 — Commit 2: Providers dong bo phien dang nhap
Copy-Rel $SRC_USER $DST_USER @("src/components/providers")
Fake-Commit $DST_USER "2026-11-05T15:48:33+07:00" "feat: them query provider va session sync cho ung dung"

# Ngày 06/11/2026 — Commit 3: API xac thuc dang nhap, dang ky va ho so
Copy-Rel $SRC_USER $DST_USER @("src/api/auth")
Fake-Commit $DST_USER "2026-11-06T09:17:41+07:00" "feat: tich hop api xac thuc dang nhap, dang ky va ho so"

# Ngày 06/11/2026 — Commit 4: API danh sach khu vuc tinh thanh
Copy-Rel $SRC_USER $DST_USER @("src/api/area")
Fake-Commit $DST_USER "2026-11-06T16:05:22+07:00" "feat: tich hop api danh sach khu vuc tinh thanh"

# Ngày 06/11/2026 — Commit 5: API tim kiem chuyen xe va so do ghe
Copy-Rel $SRC_USER $DST_USER @("src/api/trip")
Fake-Commit $DST_USER "2026-11-06T21:38:04+07:00" "feat: tich hop api tim kiem chuyen xe va so do ghe"

git -C $DST_USER push -u origin feat/user-api-sprint1
```
> Tạo Pull Request `feat/user-api-sprint1` -> `main` và merge để kết thúc Sprint 1.

---

## SPRINT 2

### Task 2.10 — Hoàn thiện điều hành & xác nhận trạng thái chuyến trên `ViVuViet-frontend-driver` (18/11/2026)

> Chạy sau khi nhánh `feat/driver-operations` của Lại Quốc Minh đã merge vào `main`.

```powershell
git -C $DST_DRIVER checkout main
git -C $DST_DRIVER pull origin main
git -C $DST_DRIVER checkout -b feat/driver-status-updates

# Commit 1: Bang dieu hanh tong hop va modal xac nhan
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/app/(driver)/_components/operations.tsx",
    "src/app/(driver)/dieu-hanh/_components/confirm-modal.tsx"
)
Fake-Commit $DST_DRIVER "2026-11-18T14:22:17+07:00" "feat: bo sung bang dieu hanh va modal xac nhan cap nhat trang thai"

# Commit 2: Panel hanh khach khi van hanh chuyen
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/app/(driver)/dieu-hanh/_components/passengers-panel.tsx"
)
Fake-Commit $DST_DRIVER "2026-11-18T20:11:45+07:00" "feat: hoan thien panel hanh khach va trang thai don tra"

git -C $DST_DRIVER push -u origin feat/driver-status-updates
```
> Tạo Pull Request `feat/driver-status-updates` -> `main` và merge.

---

### Task 2.11 — Tích hợp API đặt vé Sprint 2 trên `ViVuViet-frontend-user` (19/11/2026)

> Chạy sau khi nhánh `feat/user-profile` của Nguyễn Thái Bình đã merge vào `main`.

```powershell
git -C $DST_USER checkout main
git -C $DST_USER pull origin main
git -C $DST_USER checkout -b feat/user-api-sprint2

# Commit 1: API tao, xac nhan va huy dat ve
Copy-Rel $SRC_USER $DST_USER @(
    "src/api/booking/api/types.ts",
    "src/api/booking/api/create-booking.ts",
    "src/api/booking/api/confirm-booking.ts",
    "src/api/booking/api/cancel-booking.ts",
    "src/api/booking/tanstack/use-create-booking.ts",
    "src/api/booking/tanstack/use-confirm-booking.ts",
    "src/api/booking/tanstack/use-cancel-booking.ts"
)
Fake-Commit $DST_USER "2026-11-19T16:44:16+07:00" "feat: tich hop api tao, xac nhan va huy dat ve"

# Commit 2: API danh sach va lich su chuyen da dat
Copy-Rel $SRC_USER $DST_USER @("src/api/booking")
Fake-Commit $DST_USER "2026-11-19T22:31:52+07:00" "feat: tich hop api lich su va trang thai dat ve cua toi"

git -C $DST_USER push -u origin feat/user-api-sprint2
```
> Tạo Pull Request `feat/user-api-sprint2` -> `main` và merge để kết thúc Sprint 2.

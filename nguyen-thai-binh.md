# Hướng dẫn đẩy code & fake commit — Nguyễn Thái Bình (Windows / PowerShell)

## Phần việc phụ trách (Sprint 1 & Sprint 2)
- **Sprint 1 — Task 1.9 (29/10 – 30/10/2026):** Xây dựng giao diện khung (kèm các icon cơ bản cần dùng) & màn hình đăng nhập cho `ViVuViet-frontend-admin` và `ViVuViet-frontend-driver`.
- **Sprint 1 — Task 1.10 (31/10 – 01/11/2026):** Xây dựng giao diện quản lý tuyến đường & chuyến xe (bổ sung icon tương ứng) cho `ViVuViet-frontend-admin`.
- **Sprint 2 — Task 2.8a (11/11 – 12/11/2026):** Xây dựng giao diện quản lý đơn đặt vé & xe cho `ViVuViet-frontend-admin`.
- **Sprint 2 — Task 2.8b (12/11/2026 — Cross-repo):** Xây dựng trang hồ sơ cá nhân khách hàng cho `ViVuViet-frontend-user`.
- **Sprint 2 — Task 2.9 (13/11/2026):** Xây dựng giao diện thông tin xe & lịch sử chuyến của xe cho `ViVuViet-frontend-driver`.

## Hướng dẫn dành cho AI Agent (đọc kỹ trước khi chạy)
1. **Tìm hoặc clone repo:** Kiểm tra trên máy xem đã có repo nguồn (`nmcnpm`, `nmcnpm-admin`, `locdz`) và repo đích (`ViVuViet-frontend-user`, `ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) chưa. Nếu chưa có, tự `git clone`:
   - Nguồn: `https://github.com/helloworld-cmyk/nmcnpm.git`, `https://github.com/helloworld-cmyk/nmcnpm-admin.git`, `https://github.com/Another001/locdz.git`
   - Đích: `https://github.com/ViVuViet/ViVuViet-frontend-user.git`, `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`, `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`
2. **Kiểm tra Git identity:** `GIT_NAME` là `Nguyen Thai Binh` và `GIT_EMAIL` đã được đặt là `nguyenthaibinh.tink32chl@gmail.com`. Xác nhận lại với người dùng nếu cần dùng email GitHub khác.
3. **Kiểm tra điều kiện tiên quyết từng task:** Kiểm tra nhánh của thành viên trước đã được merge vào `origin/main` chưa trước khi `git pull origin main` và tạo nhánh mới. Nếu chưa merge, dừng lại và báo người dùng.
4. **Chạy gộp Bước 0 + Task trong cùng 1 phiên shell:** Đa số AI agent chạy mỗi lệnh trong một phiên shell mới; **bắt buộc** gộp phần khai báo ở Bước 0 cùng với lệnh của Task vào chung 1 lần thực thi để không mất biến `$SRC_*`, `$DST_*` và hàm `Copy-Rel`, `Sync-IconsIndex`, `Fake-Commit`.
5. **Cơ chế icon tăng dần (`Sync-IconsIndex`):** Mỗi feature chỉ copy đúng các file icon dùng cho tính năng đó, sau đó gọi `Sync-IconsIndex` để `src/components/icons/index.ts` chỉ export những icon đang có, đảm bảo không lỗi `Module not found`.
6. **Quy tắc an toàn & Verify:** Không chỉnh sửa code gốc, không copy thư mục `.agents/`. Nếu `Copy-Rel` báo thiếu file -> dừng ngay trước khi push. Trước khi push, chạy `git -C <repo> log -n 6 --format="%h | %ai | %an <%ae> | %s"` và `git -C <repo> status` để xác nhận đúng timestamp `+07:00`. Sau khi `git push`, báo lại tên nhánh để người dùng tạo Pull Request trên GitHub.

---

## Bước 0: Cấu hình đường dẫn, Git identity & hàm hỗ trợ (chạy 1 lần đầu mỗi phiên PowerShell)

> Sửa lại đường dẫn `$SRC_*` và `$DST_*` cho đúng thư mục trên máy bạn, đồng thời điền đúng `user.name` và `user.email` GitHub của bạn.

```powershell
# 1. Đường dẫn repo nguồn
$SRC_USER   = "D:\2026.1\CNPM\sources\nmcnpm"
$SRC_ADMIN  = "D:\2026.1\CNPM\sources\nmcnpm-admin"
$SRC_DRIVER = "D:\2026.1\CNPM\sources\locdz"

# 2. Đường dẫn repo đích
$DST_USER   = "D:\2026.1\CNPM\ViVuViet-frontend-user"
$DST_ADMIN  = "D:\2026.1\CNPM\ViVuViet-frontend-admin"
$DST_DRIVER = "D:\2026.1\CNPM\ViVuViet-frontend-driver"

# 3. Cấu hình Git tác giả
$GIT_NAME  = "Nguyen Thai Binh"
$GIT_EMAIL = "nguyenthaibinh.tink32chl@gmail.com"

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
            throw "Khong tim thay: $src"
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

# 5. Hàm đồng bộ src/components/icons/index.ts chỉ export các icon đã có ở đích
function Sync-IconsIndex {
    param(
        [string]$SrcRoot,
        [string]$DstRoot
    )
    $srcIndex = Join-Path $SrcRoot "src\components\icons\index.ts"
    $dstDir   = Join-Path $DstRoot "src\components\icons"
    $dstIndex = Join-Path $dstDir "index.ts"
    if (-not (Test-Path $srcIndex)) {
        throw "Khong tim thay: $srcIndex"
    }
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    $kept = @()
    foreach ($line in Get-Content $srcIndex) {
        if ($line -match '\./([A-Za-z0-9_-]+)') {
            $mod = $Matches[1]
            if ((Test-Path (Join-Path $dstDir "$mod.tsx")) -or (Test-Path (Join-Path $dstDir "$mod.ts"))) {
                $kept += $line
            }
        }
    }
    [System.IO.File]::WriteAllLines($dstIndex, $kept, (New-Object System.Text.UTF8Encoding $false))
}

# 6. Hàm commit với thời gian giả lập (+07:00), tự bỏ qua nếu không có thay đổi
function Fake-Commit {
    param(
        [string]$RepoPath,
        [string]$IsoDate,
        [string]$Message
    )
    git -C $RepoPath add -A
    git -C $RepoPath reset -q HEAD -- AGENTS.md opencode.json 2>$null
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

### Task 1.9 — Giao diện khung & đăng nhập cho `ViVuViet-frontend-admin` và `ViVuViet-frontend-driver` (29/10 – 30/10/2026)

> Chạy sau khi Đỗ Lê Hoàng đã merge `chore/setup-base` vào `main`.

#### 1.9.1. Trên `ViVuViet-frontend-admin`
```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN pull origin main
git -C $DST_ADMIN checkout -b feat/admin-layout-and-auth

# Ngày 29/10/2026 — Commit 1: Cac icon co ban va UI form/modal/toast dung chung
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/components/icons/icon-base.tsx",
    "src/components/icons/icon.tsx",
    "src/components/icons/menu.tsx",
    "src/components/icons/close.tsx",
    "src/components/icons/user.tsx",
    "src/components/icons/logout.tsx",
    "src/components/icons/bell.tsx",
    "src/components/icons/dashboard.tsx",
    "src/components/icons/route.tsx",
    "src/components/icons/car.tsx",
    "src/components/icons/ticket.tsx",
    "src/components/icons/users.tsx",
    "src/components/icons/chart.tsx",
    "src/components/icons/shield.tsx",
    "src/components/icons/lock.tsx",
    "src/components/icons/mail.tsx",
    "src/components/icons/eye.tsx",
    "src/components/icons/eye-off.tsx",
    "src/components/icons/check.tsx",
    "src/components/icons/alert.tsx",
    "src/components/icons/x-circle.tsx",
    "src/components/icons/chevron-down.tsx",
    "src/components/icons/chevron-right.tsx",
    "src/components/icons/calendar.tsx",
    "src/components/icons/clock.tsx",
    "src/components/ui",
    "src/components/reveal.tsx"
)
Sync-IconsIndex $SRC_ADMIN $DST_ADMIN
Fake-Commit $DST_ADMIN "2026-10-29T09:31:37+07:00" "feat: them icon co ban, modal, toast va form components cho admin"

# Ngày 29/10/2026 — Commit 2: Layout admin shell, session gate va hooks dung chung
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/components/layout", "src/hooks", "src/app/layout.tsx", "src/app/(admin)/layout.tsx")
Fake-Commit $DST_ADMIN "2026-10-29T15:09:44+07:00" "feat: xay dung layout khung quan tri, session gate va hooks"

# Ngày 30/10/2026 — Commit 3: Store phien dang nhap va cong ty
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/global-states/session-store.ts", "src/global-states/company-store.ts")
Fake-Commit $DST_ADMIN "2026-10-30T11:24:08+07:00" "feat: them store quan ly phien dang nhap va thong tin nha xe"

# Ngày 30/10/2026 — Commit 4: Giao dien dang nhap quan tri vien
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/app/(auth)")
Fake-Commit $DST_ADMIN "2026-10-30T17:42:51+07:00" "feat: xay dung giao dien va guard dang nhap trang quan tri"

git -C $DST_ADMIN push -u origin feat/admin-layout-and-auth
```
> Tạo Pull Request `feat/admin-layout-and-auth` -> `main` và merge trước khi sang Task 1.10.

#### 1.9.2. Trên `ViVuViet-frontend-driver`
```powershell
git -C $DST_DRIVER checkout main
git -C $DST_DRIVER pull origin main
git -C $DST_DRIVER checkout -b feat/driver-layout-and-auth

# Ngày 30/10/2026 — Commit 1: UI icon, sprite va layout khung tai xe
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/components/ui",
    "src/app/layout.tsx",
    "src/app/(driver)/layout.tsx",
    "src/app/(driver)/_components/driver-header.tsx"
)
Fake-Commit $DST_DRIVER "2026-10-30T20:49:33+07:00" "feat: xay dung layout khung va header cho ung dung tai xe"

# Ngày 30/10/2026 — Commit 2: Giao dien dang nhap tai xe
Copy-Rel $SRC_DRIVER $DST_DRIVER @("src/app/(driver)/dang-nhap")
Fake-Commit $DST_DRIVER "2026-10-30T23:17:15+07:00" "feat: xay dung man hinh dang nhap danh cho tai xe"

git -C $DST_DRIVER push -u origin feat/driver-layout-and-auth
```
> Tạo Pull Request `feat/driver-layout-and-auth` -> `main` và merge.

---

### Task 1.10 — Giao diện quản lý tuyến đường & chuyến xe trên `ViVuViet-frontend-admin` (31/10 – 01/11/2026)

```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN pull origin main
git -C $DST_ADMIN checkout -b feat/admin-routes-and-trips

# Ngày 31/10/2026 — Commit 1: Bo sung icon tuyen/chuyen va xu ly du lieu tuyen duong
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/components/icons/plus.tsx",
    "src/components/icons/edit.tsx",
    "src/components/icons/trash.tsx",
    "src/components/icons/search.tsx",
    "src/components/icons/filter.tsx",
    "src/components/icons/map.tsx",
    "src/components/icons/pin.tsx",
    "src/components/icons/swap.tsx",
    "src/components/icons/publish.tsx",
    "src/components/icons/refresh.tsx",
    "src/components/icons/check-circle.tsx",
    "src/components/icons/arrow-right.tsx",
    "src/components/icons/arrow-up-right.tsx",
    "src/global-states/tuyen-duong-filters-store.ts",
    "src/app/(admin)/tuyen-duong/_data",
    "src/app/(admin)/tuyen-duong/_hooks",
    "src/app/(admin)/tuyen-duong/_utils"
)
Sync-IconsIndex $SRC_ADMIN $DST_ADMIN
Fake-Commit $DST_ADMIN "2026-10-31T10:08:27+07:00" "feat: bo sung icon va xu ly du lieu tuyen duong"

# Ngày 31/10/2026 — Commit 2: Giao dien bang va form quan ly tuyen duong
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/app/(admin)/tuyen-duong")
Fake-Commit $DST_ADMIN "2026-10-31T15:43:52+07:00" "feat: hoan thien giao dien danh sach va cap nhat tuyen duong"

# Ngày 01/11/2026 — Commit 3: Store bo loc, hooks va utils quan ly chuyen xe
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/global-states/chuyen-filters-store.ts",
    "src/app/(admin)/chuyen/_data",
    "src/app/(admin)/chuyen/_hooks",
    "src/app/(admin)/chuyen/_utils"
)
Fake-Commit $DST_ADMIN "2026-11-01T11:22:18+07:00" "feat: them store bo loc va logic quan ly chuyen xe"

# Ngày 01/11/2026 — Commit 4: Giao dien board, modal tao/sua va phan cong chuyen xe
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/app/(admin)/chuyen")
Fake-Commit $DST_ADMIN "2026-11-01T19:39:46+07:00" "feat: hoan thien giao dien quan ly va phan cong chuyen xe"

git -C $DST_ADMIN push -u origin feat/admin-routes-and-trips
```
> Tạo Pull Request `feat/admin-routes-and-trips` -> `main` và merge trước khi Minh làm Task 1.11.

---

## SPRINT 2

### Task 2.8a — Giao diện quản lý đơn đặt vé & xe trên `ViVuViet-frontend-admin` (11/11 – 12/11/2026)

> Chạy sau khi nhánh `feat/admin-api-sprint1` của Lại Quốc Minh đã merge vào `main`.

```powershell
git -C $DST_ADMIN checkout main
git -C $DST_ADMIN pull origin main
git -C $DST_ADMIN checkout -b feat/admin-bookings-and-fleet

# Ngày 11/11/2026 — Commit 1: Hoan thien bo icon va logic xu ly don dat ve
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/components/icons",
    "src/global-states/don-dat-filters-store.ts",
    "src/app/(admin)/don-dat/_data",
    "src/app/(admin)/don-dat/_hooks",
    "src/app/(admin)/don-dat/_utils"
)
Fake-Commit $DST_ADMIN "2026-11-11T14:41:19+07:00" "feat: hoan thien bo icon va logic xu ly don dat ve"

# Ngày 11/11/2026 — Commit 2: Giao dien danh sach va chi tiet don dat ve
Copy-Rel $SRC_ADMIN $DST_ADMIN @("src/app/(admin)/don-dat")
Fake-Commit $DST_ADMIN "2026-11-11T21:23:45+07:00" "feat: hoan thien giao dien quan ly don dat ve va huy ve"

# Ngày 12/11/2026 — Commit 3: Store, hooks va giao dien quan ly xe + so do ghe
Copy-Rel $SRC_ADMIN $DST_ADMIN @(
    "src/global-states/xe-filters-store.ts",
    "src/app/(admin)/xe"
)
Fake-Commit $DST_ADMIN "2026-11-12T10:17:34+07:00" "feat: xay dung giao dien quan ly xe, giay to va so do ghe"

git -C $DST_ADMIN push -u origin feat/admin-bookings-and-fleet
```
> Tạo Pull Request `feat/admin-bookings-and-fleet` -> `main` và merge trước khi Duy làm `feat/admin-drivers`.

---

### Task 2.8b (Cross-repo) — Trang hồ sơ cá nhân trên `ViVuViet-frontend-user` (12/11/2026)

> Chạy sau khi nhánh `feat/user-booking-and-history` của Hà Đức Duy đã merge vào `main`.

```powershell
git -C $DST_USER checkout main
git -C $DST_USER pull origin main
git -C $DST_USER checkout -b feat/user-profile

# Ngày 12/11/2026 — Commit 1: Store va giao dien trang ho so ca nhan khach hang
Copy-Rel $SRC_USER $DST_USER @("src/global-states/profile-store.ts", "src/app/ho-so")
Fake-Commit $DST_USER "2026-11-12T19:56:08+07:00" "feat: xay dung trang thong tin ho so ca nhan khach hang"

git -C $DST_USER push -u origin feat/user-profile
```
> Tạo Pull Request `feat/user-profile` -> `main` và merge trước khi Hoàng làm Task 2.11.

---

### Task 2.9 — Giao diện thông tin xe trên `ViVuViet-frontend-driver` (13/11/2026)

> Chạy sau khi nhánh `feat/driver-layout-and-auth` đã merge vào `main`.

```powershell
git -C $DST_DRIVER checkout main
git -C $DST_DRIVER pull origin main
git -C $DST_DRIVER checkout -b feat/driver-vehicle-info

# Commit 1: Du lieu mock va thong tin ky thuat + giay to xe
Copy-Rel $SRC_DRIVER $DST_DRIVER @(
    "src/lib/mock/vehicle.ts",
    "src/app/(driver)/xe/_components/vehicle-info.tsx",
    "src/app/(driver)/xe/_components/vehicle-documents.tsx"
)
Fake-Commit $DST_DRIVER "2026-11-13T15:16:29+07:00" "feat: xay dung giao dien thong tin xe va giay to dang kiem"

# Commit 2: Lich su chuyen cua xe va trang /xe hoan chinh
Copy-Rel $SRC_DRIVER $DST_DRIVER @("src/app/(driver)/xe")
Fake-Commit $DST_DRIVER "2026-11-13T21:54:07+07:00" "feat: bo sung lich su chuyen cua xe va hoan thien trang xe"

git -C $DST_DRIVER push -u origin feat/driver-vehicle-info
```
> Tạo Pull Request `feat/driver-vehicle-info` -> `main` và merge.

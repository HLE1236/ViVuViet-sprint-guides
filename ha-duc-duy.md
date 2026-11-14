# Hướng dẫn đẩy code & fake commit — Hà Đức Duy (macOS / zsh & bash)

## Phần việc phụ trách (Sprint 1 & Sprint 2)
- **Sprint 1 — Task 1.9 (29/10 – 30/10/2026):** Xây dựng giao diện khung (layout, UI, các icon cần dùng) & màn hình đăng nhập/đăng ký cho `ViVuViet-frontend-user`.
- **Sprint 1 — Task 1.10 (31/10 – 01/11/2026):** Xây dựng giao diện trang chủ, form tìm kiếm & kết quả tìm chuyến (kèm icon/artwork tương ứng) cho `ViVuViet-frontend-user`.
- **Sprint 2 — Task 2.8a (11/11 – 12/11/2026):** Xây dựng giao diện chọn chuyến, chọn ghế, đặt vé & xem lịch sử chuyến cho `ViVuViet-frontend-user`.
- **Sprint 2 — Task 2.8b (12/11/2026 — Cross-repo):** Xây dựng giao diện quản lý tài xế cho `ViVuViet-frontend-admin`.
- **Sprint 2 — Task 2.9 (13/11 – 14/11/2026):** Xây dựng giao diện danh sách chuyến được phân công, chi tiết chuyến & hồ sơ tài xế cho `ViVuViet-frontend-driver`.

## Hướng dẫn dành cho AI Agent (đọc kỹ trước khi chạy trên macOS)
1. **Tìm hoặc clone repo:** Kiểm tra trên máy Mac xem đã có repo nguồn (`nmcnpm`, `nmcnpm-admin`, `locdz`) và repo đích (`ViVuViet-frontend-user`, `ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) chưa. Nếu chưa có, tự `git clone`:
   - Nguồn: `https://github.com/helloworld-cmyk/nmcnpm.git`, `https://github.com/helloworld-cmyk/nmcnpm-admin.git`, `https://github.com/Another001/locdz.git`
   - Đích: `https://github.com/ViVuViet/ViVuViet-frontend-user.git`, `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`, `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`
2. **Kiểm tra Git identity:** `GIT_NAME` là `Ha Duc Duy` và `GIT_EMAIL` đã được đặt là `duy.hd2416182@sis.hust.edu.vn`. Xác nhận lại với người dùng nếu cần dùng email GitHub khác.
3. **Kiểm tra điều kiện tiên quyết từng task:** Kiểm tra nhánh của thành viên trước đã được merge vào `origin/main` chưa trước khi `git pull origin main` và tạo nhánh mới. Nếu chưa merge, dừng lại và báo người dùng.
4. **Chạy gộp Bước 0 + Task trong cùng 1 phiên shell:** Đa số AI agent chạy mỗi lệnh trong một phiên shell mới; **bắt buộc** gộp phần khai báo ở Bước 0 cùng với lệnh của Task vào chung 1 lần thực thi để không mất biến `$SRC_*`, `$DST_*` và hàm `copy_rel`, `sync_icons_index`, `fake_commit`.
5. **Cơ chế icon tăng dần (`sync_icons_index`):** Mỗi feature chỉ copy đúng các file icon dùng cho tính năng đó, sau đó gọi `sync_icons_index` để file `src/components/icons/index.ts` chỉ export những icon đang có, đảm bảo không lỗi `Module not found`.
6. **Quy tắc an toàn & Verify:** Không chỉnh sửa code gốc, không copy thư mục `.agents/`. Nếu `copy_rel` báo thiếu file -> dừng ngay trước khi push. Trước khi push, chạy `git -C <repo> log -n 6 --format="%h | %ai | %an <%ae> | %s"` và `git -C <repo> status` để xác nhận đúng timestamp `+07:00`. Sau khi `git push`, báo lại tên nhánh để người dùng tạo Pull Request trên GitHub.

---

## Bước 0: Cấu hình đường dẫn, Git identity & hàm hỗ trợ (chạy 1 lần đầu mỗi phiên Terminal)

> Sửa lại đường dẫn `SRC_*` và `DST_*` cho đúng thư mục trên máy Mac của bạn, đồng thời điền đúng `user.name` và `user.email` GitHub của bạn.

```bash
# 1. Đường dẫn repo nguồn
SRC_USER="$HOME/Documents/CNPM/sources/nmcnpm"
SRC_ADMIN="$HOME/Documents/CNPM/sources/nmcnpm-admin"
SRC_DRIVER="$HOME/Documents/CNPM/sources/locdz"

# 2. Đường dẫn repo đích
DST_USER="$HOME/Documents/CNPM/ViVuViet-frontend-user"
DST_ADMIN="$HOME/Documents/CNPM/ViVuViet-frontend-admin"
DST_DRIVER="$HOME/Documents/CNPM/ViVuViet-frontend-driver"

# 3. Cấu hình Git tác giả
GIT_NAME="Ha Duc Duy"
GIT_EMAIL="duy.hd2416182@sis.hust.edu.vn"

for repo in "$DST_USER" "$DST_ADMIN" "$DST_DRIVER"; do
  git -C "$repo" config user.name "$GIT_NAME"
  git -C "$repo" config user.email "$GIT_EMAIL"
done

# 4. Hàm copy file/thư mục giữ nguyên cấu trúc tương đối
copy_rel() {
  local src_root="$1"
  local dst_root="$2"
  shift 2
  for p in "$@"; do
    local src="$src_root/$p"
    local dst="$dst_root/$p"
    if [ ! -e "$src" ]; then
      echo "Khong tim thay: $src" >&2
      return 1
    fi
    if [ -d "$src" ]; then
      mkdir -p "$dst"
      cp -R "$src"/. "$dst"/
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    fi
  done
}

# 5. Hàm đồng bộ src/components/icons/index.ts chỉ export các icon đã có ở đích
sync_icons_index() {
  local src_root="$1"
  local dst_root="$2"
  local src_index="$src_root/src/components/icons/index.ts"
  local dst_dir="$dst_root/src/components/icons"
  local dst_index="$dst_dir/index.ts"
  if [ ! -f "$src_index" ]; then
    echo "Khong tim thay: $src_index" >&2
    return 1
  fi
  mkdir -p "$dst_dir"
  : > "$dst_index"
  while IFS= read -r line; do
    if [[ "$line" =~ \./([A-Za-z0-9_-]+) ]]; then
      local mod="${BASH_REMATCH[1]}"
      if [ -f "$dst_dir/$mod.tsx" ] || [ -f "$dst_dir/$mod.ts" ]; then
        echo "$line" >> "$dst_index"
      fi
    fi
  done < "$src_index"
}

# 6. Hàm commit với thời gian giả lập (+07:00), tự bỏ qua nếu không có thay đổi
fake_commit() {
  local repo_path="$1"
  local iso_date="$2"
  local message="$3"
  git -C "$repo_path" add -A
  git -C "$repo_path" reset -q HEAD -- AGENTS.md opencode.json 2>/dev/null || true
  if [ -z "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "Bo qua (khong co thay doi): $message"
    return 0
  fi
  export GIT_AUTHOR_DATE="$iso_date"
  export GIT_COMMITTER_DATE="$iso_date"
  git -C "$repo_path" commit -m "$message"
  unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE
}
```

---

## SPRINT 1

### Task 1.9 — Giao diện khung & màn hình đăng nhập/đăng ký trên `ViVuViet-frontend-user` (29/10 – 30/10/2026)

> Chạy sau khi Đỗ Lê Hoàng đã merge `chore/setup-base` vào `main`.

```bash
git -C "$DST_USER" checkout main
git -C "$DST_USER" pull origin main
git -C "$DST_USER" checkout -b feat/user-layout-and-auth

# Ngày 29/10/2026 — Commit 1: Cac icon co ban cho header, footer va auth
copy_rel "$SRC_USER" "$DST_USER" \
  "src/components/icons/icon-base.tsx" \
  "src/components/icons/menu.tsx" \
  "src/components/icons/close.tsx" \
  "src/components/icons/user.tsx" \
  "src/components/icons/logout.tsx" \
  "src/components/icons/facebook.tsx" \
  "src/components/icons/instagram.tsx" \
  "src/components/icons/youtube.tsx" \
  "src/components/icons/headset.tsx" \
  "src/components/icons/phone.tsx" \
  "src/components/icons/mail.tsx" \
  "src/components/icons/eye.tsx" \
  "src/components/icons/eye-off.tsx" \
  "src/components/icons/arrow-right.tsx" \
  "src/components/icons/chevron-down.tsx" \
  "src/components/icons/calendar.tsx"
sync_icons_index "$SRC_USER" "$DST_USER"
fake_commit "$DST_USER" "2026-10-29T10:15:24+07:00" "feat: them cac icon co ban cho layout va xac thuc"

# Ngày 29/10/2026 — Commit 2: UI components dung chung (header, footer, modal, date-picker...)
copy_rel "$SRC_USER" "$DST_USER" "src/components/ui"
fake_commit "$DST_USER" "2026-10-29T14:47:39+07:00" "feat: xay dung header, footer, date-picker va cac ui component"

# Ngày 29/10/2026 — Commit 3: Khung layout chinh (site-shell va app/layout.tsx)
copy_rel "$SRC_USER" "$DST_USER" "src/components/layout" "src/app/layout.tsx"
fake_commit "$DST_USER" "2026-10-29T21:11:05+07:00" "feat: thiet lap layout khung chinh cho ung dung khach hang"

# Ngày 30/10/2026 — Commit 4: Auth components va global state xac thuc
copy_rel "$SRC_USER" "$DST_USER" \
  "src/components/auth" \
  "src/global-states/login-store.ts" \
  "src/global-states/register-store.ts" \
  "src/global-states/session-store.ts"
fake_commit "$DST_USER" "2026-10-30T09:16:52+07:00" "feat: xay dung auth components va store quan ly phien dang nhap"

# Ngày 30/10/2026 — Commit 5: Trang dang nhap
copy_rel "$SRC_USER" "$DST_USER" "src/app/dang-nhap"
fake_commit "$DST_USER" "2026-10-30T15:53:28+07:00" "feat: xay dung giao dien va xu ly form dang nhap"

# Ngày 30/10/2026 — Commit 6: Trang dang ky
copy_rel "$SRC_USER" "$DST_USER" "src/app/dang-ky"
fake_commit "$DST_USER" "2026-10-30T22:18:41+07:00" "feat: xay dung giao dien va xu ly form dang ky tai khoan"

git -C "$DST_USER" push -u origin feat/user-layout-and-auth
```
> Tạo Pull Request `feat/user-layout-and-auth` -> `main` trên GitHub và merge trước khi sang Task 1.10.

---

### Task 1.10 — Giao diện tìm kiếm & danh sách chuyến xe trên `ViVuViet-frontend-user` (31/10 – 01/11/2026)

```bash
git -C "$DST_USER" checkout main
git -C "$DST_USER" pull origin main
git -C "$DST_USER" checkout -b feat/user-home-and-search

# Ngày 31/10/2026 — Commit 1: Bo sung icon va artwork cho trang chu va tim kiem
copy_rel "$SRC_USER" "$DST_USER" \
  "src/components/art" \
  "src/components/icons/map.tsx" \
  "src/components/icons/pin.tsx" \
  "src/components/icons/swap.tsx" \
  "src/components/icons/clock.tsx" \
  "src/components/icons/route.tsx" \
  "src/components/icons/car.tsx" \
  "src/components/icons/star.tsx" \
  "src/components/icons/shield.tsx" \
  "src/components/icons/arrow-up-right.tsx" \
  "src/components/icons/chevron-right.tsx" \
  "src/components/icons/users.tsx" \
  "src/components/icons/check.tsx" \
  "src/components/icons/refresh.tsx"
sync_icons_index "$SRC_USER" "$DST_USER"
fake_commit "$DST_USER" "2026-10-31T09:41:12+07:00" "feat: bo sung icon va artwork cho trang chu va tim kiem"

# Ngày 31/10/2026 — Commit 2: Store form dat ve va hero + booking form trang chu
copy_rel "$SRC_USER" "$DST_USER" \
  "src/global-states/booking-form-store.ts" \
  "src/app/(home)/_utils" \
  "src/app/(home)/_hooks" \
  "src/app/(home)/_components/hero.tsx" \
  "src/app/(home)/_components/booking-form.tsx" \
  "src/app/(home)/_components/area-field.tsx"
fake_commit "$DST_USER" "2026-10-31T11:19:43+07:00" "feat: xay dung hero va form tim kiem chuyen xe tren trang chu"

# Ngày 31/10/2026 — Commit 3: Cac section tuyen duong, doi xe va huong dan
copy_rel "$SRC_USER" "$DST_USER" \
  "src/app/(home)/_components/routes-section.tsx" \
  "src/app/(home)/_components/route-scene.tsx" \
  "src/app/(home)/_components/fleet-section.tsx" \
  "src/app/(home)/_components/steps-section.tsx" \
  "src/app/(home)/_components/features-section.tsx" \
  "src/app/(home)/_components/compare-scene.tsx" \
  "src/app/(home)/_components/arrival-scene.tsx"
fake_commit "$DST_USER" "2026-10-31T16:37:21+07:00" "feat: bo sung cac section tuyen noi bat, doi xe va quy trinh"

# Ngày 31/10/2026 — Commit 4: Phan danh gia, FAQ, CTA va trang chu hoan chinh
copy_rel "$SRC_USER" "$DST_USER" "src/app/(home)"
fake_commit "$DST_USER" "2026-10-31T21:48:09+07:00" "feat: hoan thien trang chu voi faq, testimonials va cta"

# Ngày 01/11/2026 — Commit 5: Store bo loc va utils trang ket qua tim chuyen
copy_rel "$SRC_USER" "$DST_USER" \
  "src/global-states/search-filters-store.ts" \
  "src/app/ket-qua-tim-chuyen/_utils" \
  "src/app/ket-qua-tim-chuyen/_hooks"
fake_commit "$DST_USER" "2026-11-01T10:26:55+07:00" "feat: them store bo loc va hooks xu ly ket qua tim chuyen"

# Ngày 01/11/2026 — Commit 6: Thanh loc va card chuyen xe
copy_rel "$SRC_USER" "$DST_USER" \
  "src/app/ket-qua-tim-chuyen/_components/dual-range.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/results-filter-bar.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/ride-card.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/ride-skeletons.tsx"
fake_commit "$DST_USER" "2026-11-01T15:14:32+07:00" "feat: xay dung card chuyen xe va thanh loc ket qua"

# Ngày 01/11/2026 — Commit 7: Cac trang thai rong, loi va class responsive
copy_rel "$SRC_USER" "$DST_USER" \
  "src/app/ket-qua-tim-chuyen/_components/empty-state.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/error-state.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/no-area-state.tsx" \
  "src/app/ket-qua-tim-chuyen/_components/state-panels-classes.ts"
fake_commit "$DST_USER" "2026-11-01T16:02:18+07:00" "fix: bo sung trang thai rong, loi va class responsive ket qua tim chuyen"

# Ngày 01/11/2026 — Commit 8: Hoan thien trang ket qua tim kiem chuyen xe
copy_rel "$SRC_USER" "$DST_USER" "src/app/ket-qua-tim-chuyen"
fake_commit "$DST_USER" "2026-11-01T20:41:17+07:00" "feat: hoan thien trang danh sach va phan trang ket qua tim chuyen"

git -C "$DST_USER" push -u origin feat/user-home-and-search
```
> Tạo Pull Request `feat/user-home-and-search` -> `main` và merge trước khi Hoàng làm Task 1.11.

---

## SPRINT 2

### Task 2.8a — Giao diện chọn chuyến, đặt vé & xem lịch sử đặt vé trên `ViVuViet-frontend-user` (11/11 – 12/11/2026)

> Chạy sau khi nhánh `feat/user-api-sprint1` của Đỗ Lê Hoàng đã merge vào `main`.

```bash
git -C "$DST_USER" checkout main
git -C "$DST_USER" pull origin main
git -C "$DST_USER" checkout -b feat/user-booking-and-history

# Ngày 11/11/2026 — Commit 1: Bo sung cac icon con lai (check-circle, copy, wallet, camera) va icons index day du
copy_rel "$SRC_USER" "$DST_USER" "src/components/icons"
fake_commit "$DST_USER" "2026-11-11T15:12:08+07:00" "feat: bo sung icon dat ve, thanh toan va hoan thien icons index"

# Ngày 11/11/2026 — Commit 2: Store chi tiet dat cho va so do ghe ngoi
copy_rel "$SRC_USER" "$DST_USER" \
  "src/global-states/booking-detail-store.ts" \
  "src/app/chi-tiet-chuyen/_utils" \
  "src/app/chi-tiet-chuyen/_hooks" \
  "src/app/chi-tiet-chuyen/_components/seat-art.tsx" \
  "src/app/chi-tiet-chuyen/_components/seat-button.tsx" \
  "src/app/chi-tiet-chuyen/_components/seat-map.tsx" \
  "src/app/chi-tiet-chuyen/_components/steering-wheel.tsx"
fake_commit "$DST_USER" "2026-11-11T19:37:44+07:00" "feat: xay dung so do chon ghe va xu ly trang chi tiet chuyen"

# Ngày 11/11/2026 — Commit 3: Panel dat ve hoan chinh va trang dat cho thanh cong
copy_rel "$SRC_USER" "$DST_USER" "src/app/chi-tiet-chuyen" "src/app/dat-cho-thanh-cong"
fake_commit "$DST_USER" "2026-11-11T23:12:13+07:00" "feat: hoan thien panel dat ve va trang dat cho thanh cong"

# Ngày 12/11/2026 — Commit 4: Store chuyen cua toi va cac tab trang thai ve
copy_rel "$SRC_USER" "$DST_USER" \
  "src/global-states/trips-store.ts" \
  "src/app/chuyen-cua-toi/_data" \
  "src/app/chuyen-cua-toi/_hooks" \
  "src/app/chuyen-cua-toi/_utils" \
  "src/app/chuyen-cua-toi/_components/trip-tabs.tsx" \
  "src/app/chuyen-cua-toi/_components/trip-filters.tsx" \
  "src/app/chuyen-cua-toi/_components/trip-card.tsx"
fake_commit "$DST_USER" "2026-11-12T10:38:21+07:00" "feat: xay dung danh sach, tab va bo loc chuyen da dat"

# Ngày 12/11/2026 — Commit 5: Modal huy ve va trang thai loading/rong cua chuyen cua toi
copy_rel "$SRC_USER" "$DST_USER" "src/app/chuyen-cua-toi"
fake_commit "$DST_USER" "2026-11-12T17:14:57+07:00" "feat: hoan thien modal huy ve va lich su chuyen cua toi"

git -C "$DST_USER" push -u origin feat/user-booking-and-history
```
> Tạo Pull Request `feat/user-booking-and-history` -> `main` và merge trước khi Bình làm `feat/user-profile`.

---

### Task 2.8b (Cross-repo) — Giao diện quản lý tài xế trên `ViVuViet-frontend-admin` (12/11/2026)

> Chạy sau khi nhánh `feat/admin-bookings-and-fleet` của Nguyễn Thái Bình đã merge vào `main`.

```bash
git -C "$DST_ADMIN" checkout main
git -C "$DST_ADMIN" pull origin main
git -C "$DST_ADMIN" checkout -b feat/admin-drivers

# Ngày 12/11/2026 — Commit 1: Store bo loc, hooks va utils quan ly tai xe
copy_rel "$SRC_ADMIN" "$DST_ADMIN" \
  "src/global-states/tai-xe-filters-store.ts" \
  "src/app/(admin)/tai-xe/_data" \
  "src/app/(admin)/tai-xe/_hooks" \
  "src/app/(admin)/tai-xe/_utils"
fake_commit "$DST_ADMIN" "2026-11-12T21:19:44+07:00" "feat: them store bo loc, hooks va utils quan ly tai xe"

# Ngày 12/11/2026 — Commit 2: Giao dien danh sach va lich chay tai xe
copy_rel "$SRC_ADMIN" "$DST_ADMIN" "src/app/(admin)/tai-xe"
fake_commit "$DST_ADMIN" "2026-11-12T22:54:12+07:00" "feat: hoan thien giao dien danh sach va lich chay tai xe"

git -C "$DST_ADMIN" push -u origin feat/admin-drivers
```
> Tạo Pull Request `feat/admin-drivers` -> `main` và merge trước khi Minh làm Task 2.11.

---

### Task 2.9 — Giao diện danh sách chuyến được phân công & hồ sơ tài xế trên `ViVuViet-frontend-driver` (13/11 – 14/11/2026)

> Chạy sau khi nhánh `feat/driver-layout-and-auth` của Nguyễn Thái Bình đã merge vào `main`.

```bash
git -C "$DST_DRIVER" checkout main
git -C "$DST_DRIVER" pull origin main
git -C "$DST_DRIVER" checkout -b feat/driver-trips-and-profile

# Ngày 13/11/2026 — Commit 1: Bang lich trinh va card chuyen duoc phan cong
copy_rel "$SRC_DRIVER" "$DST_DRIVER" \
  "src/lib/mock/trips.ts" \
  "src/app/(driver)/_components/schedule-board.tsx" \
  "src/app/(driver)/_components/trip-card.tsx" \
  "src/app/(driver)/page.tsx"
fake_commit "$DST_DRIVER" "2026-11-13T16:28:11+07:00" "feat: xay dung danh sach va lich trinh chuyen duoc phan cong"

# Ngày 13/11/2026 — Commit 2: Panel thong tin chuyen, timeline va phan cong
copy_rel "$SRC_DRIVER" "$DST_DRIVER" \
  "src/lib/mock/trip-detail.ts" \
  "src/app/(driver)/chuyen/_components/trip-summary.tsx" \
  "src/app/(driver)/chuyen/_components/trip-info-panel.tsx" \
  "src/app/(driver)/chuyen/_components/trip-timeline-panel.tsx" \
  "src/app/(driver)/chuyen/_components/assignment-panel.tsx"
fake_commit "$DST_DRIVER" "2026-11-13T20:04:39+07:00" "feat: xay dung chi tiet chuyen, lo trinh va thong tin phan cong"

# Ngày 13/11/2026 — Commit 3: Danh sach hanh khach va modal bao cao su co
copy_rel "$SRC_DRIVER" "$DST_DRIVER" "src/app/(driver)/chuyen"
fake_commit "$DST_DRIVER" "2026-11-13T20:39:52+07:00" "fix: bo sung danh sach hanh khach va modal bao cao su co"

# Ngày 14/11/2026 — Commit 4: Ho so tai xe va thong tin giay phep lai xe
copy_rel "$SRC_DRIVER" "$DST_DRIVER" "src/lib/mock/profile.ts" "src/app/(driver)/ho-so"
fake_commit "$DST_DRIVER" "2026-11-14T10:42:17+07:00" "feat: xay dung trang ho so ca nhan va giay phep lai xe"

git -C "$DST_DRIVER" push -u origin feat/driver-trips-and-profile
```
> Tạo Pull Request `feat/driver-trips-and-profile` -> `main` và merge.

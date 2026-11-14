# Hướng dẫn đẩy code & fake commit Sprint 1 – 2 (Vi Vu Việt - Frontend)

> **Hướng dẫn dùng AI Coding Agent (Prompt chuẩn copy-paste):** Xem [PROMPT_GUIDE.md](./PROMPT_GUIDE.md)

Thư mục này chứa hướng dẫn chi tiết từng câu lệnh cho **4 thành viên phụ trách Frontend/Setup/Integration** trong Sprint 1 (`27/10/2026 – 09/11/2026`) và Sprint 2 (`10/11/2026 – 23/11/2026`).

## Danh sách file hướng dẫn theo từng người
- **Đỗ Lê Hoàng** (Windows / PowerShell): [do-le-hoang.md](./do-le-hoang.md)
- **Lại Quốc Minh** (Windows / PowerShell): [lai-quoc-minh.md](./lai-quoc-minh.md)
- **Hà Đức Duy** (macOS / zsh-bash): [ha-duc-duy.md](./ha-duc-duy.md)
- **Nguyễn Thái Bình** (Windows / PowerShell): [nguyen-thai-binh.md](./nguyen-thai-binh.md)

## Danh sách Repository (Nguồn & Đích)
- **Repo nguồn (chỉ để copy code sang, không push ngược lại):**
  - `nmcnpm`: `https://github.com/helloworld-cmyk/nmcnpm.git` -> đẩy sang `ViVuViet-frontend-user`
  - `nmcnpm-admin`: `https://github.com/helloworld-cmyk/nmcnpm-admin.git` -> đẩy sang `ViVuViet-frontend-admin`
  - `locdz`: `https://github.com/Another001/locdz.git` -> đẩy sang `ViVuViet-frontend-driver`
- **Repo đích (nơi tạo nhánh & push):**
  - `ViVuViet-frontend-user`: `https://github.com/ViVuViet/ViVuViet-frontend-user.git`
  - `ViVuViet-frontend-admin`: `https://github.com/ViVuViet/ViVuViet-frontend-admin.git`
  - `ViVuViet-frontend-driver`: `https://github.com/ViVuViet/ViVuViet-frontend-driver.git`

## Quy ước chung
1. **Không copy `.agents/`:** Bỏ qua hoàn toàn thư mục `.agents/` ở repo nguồn.
2. **Quy trình nhánh & PR:**
   - Mỗi task tạo 1 nhánh riêng từ `main` (`chore/...` hoặc `feat/...`).
   - Commit tiếng Việt **không dấu**, chia nhỏ theo từng nhóm component/module.
   - Đẩy nhánh lên GitHub (`git push -u origin <branch>`) rồi tạo Pull Request vào `main` (hoặc merge vào `main` theo đúng thứ tự bên dưới để tránh conflict).
3. **Thứ tự merge vào `main` khuyến nghị:**
   - **Sprint 1:**
     1. `1.2` Setup (`Đỗ Lê Hoàng` — cả 3 repo) -> merge trước tiên
     2. `1.9` Layout & Auth (`Hà Đức Duy` trên `user`; `Nguyễn Thái Bình` trên `admin`, `driver`)
     3. `1.10` Trang chủ, tìm kiếm, tuyến đường, chuyến (`Hà Đức Duy` trên `user`; `Nguyễn Thái Bình` trên `admin`)
     4. `1.11` Tích hợp API Sprint 1 (`Đỗ Lê Hoàng` trên `user`; `Lại Quốc Minh` trên `admin`)
   - **Sprint 2:**
     5. `2.8a` Đặt vé, lịch sử, đơn đặt, xe (`Hà Đức Duy` trên `user`; `Nguyễn Thái Bình` trên `admin`)
     6. `2.8b` Hồ sơ khách hàng & Quản lý tài xế (`Nguyễn Thái Bình` trên `user`; `Hà Đức Duy` trên `admin` — chạy sau `2.8a`)
     7. `2.9` Chuyến tài xế, hồ sơ & xe tài xế (`Hà Đức Duy` & `Nguyễn Thái Bình` trên `driver`)
     8. `2.10` Điều hành & cập nhật trạng thái chuyến (`Lại Quốc Minh` & `Đỗ Lê Hoàng` trên `driver`)
     9. `2.11` Tích hợp API Sprint 2 (`Đỗ Lê Hoàng` trên `user`; `Lại Quốc Minh` trên `admin`)
4. **Phạm vi Sprint 3+ & các phần chưa migrate ở Sprint 1–2:**
   - `ViVuViet-frontend-admin`: Các module `tong-quan`, `doanh-thu`, `khach-hang` được giữ lại cho Sprint 3+.
   - `ViVuViet-frontend-driver`: Sprint 1–2 dùng dữ liệu `src/lib/mock/*`; phần tích hợp `src/api/*` cho tài xế thực hiện ở Sprint 3+.
   - **Kiểm tra file app-level:** Ở cuối Sprint 2, rà soát lại các repo nguồn xem có `src/middleware.ts` (hoặc `src/proxy.ts`), `src/app/not-found.tsx`, `src/app/error.tsx` cần bổ sung không.
5. **Quy tắc Build / Quality Gate (UI trước – API sau):**
   - Trong Sprint 1 & 2, các nhánh UI (`1.9`, `1.10`, `2.8a`, `2.8b`) được merge trước khi tầng `src/api/*` và `src/components/providers` được đẩy ở `1.11` / `2.11`.
   - Do đó, **chỉ chạy `npm install && npm run lint && npx tsc --noEmit && npm run build` làm cổng kiểm tra bắt buộc (Quality Gate)** tại các mốc hoàn chỉnh: **sau Task `1.11`** (kết thúc Sprint 1) và **sau Task `2.11`** (kết thúc Sprint 2), cũng như sau **Task `2.10`** trên `driver`. Ở các PR UI trung gian, tuyệt đối không tự ý sửa code nếu thiếu `@/api/*` hoặc `@/components/providers`.

## Cấu hình chạy tích hợp 3 Frontend (`.env.local` & Ports)
Khi chạy thử đồng thời cả 3 ứng dụng trên máy local:
- `ViVuViet-frontend-user`: `npm run dev` -> `http://localhost:3000`
- `ViVuViet-frontend-admin`: `npm run dev -- -p 3001` -> `http://localhost:3001`
- `ViVuViet-frontend-driver`: `npm run dev -- -p 3002` -> `http://localhost:3002`

Tạo file `.env.local` ở từng repo đích (không commit lên Git) với biến trỏ về Backend API, ví dụ:
```env
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

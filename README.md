# Hướng dẫn đẩy code & fake commit Sprint 1 – 2 (Vi Vu Việt - Frontend)

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
4. **Phạm vi Admin (`ViVuViet-frontend-admin`):**
   - Các module `tong-quan`, `doanh-thu`, `khach-hang` không nằm trong Sprint 1–2 nên được giữ lại cho Sprint 3+.

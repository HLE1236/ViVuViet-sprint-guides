# Hướng dẫn Prompt chuẩn cho AI Coding Agent (Sprint 1 – 2)

Tài liệu này giúp cả team dùng AI Coding Agent (OpenCode, Claude Code, Cursor, Antigravity...) để **tự động thực thi** các file hướng dẫn trong `sprint-guides/` một cách chính xác, đúng thứ tự merge, đúng timestamp `+07:00` và **không làm hỏng code hoặc commit nhầm**.

---

## 1. Quy trình làm việc chuẩn với AI Agent (Agent Loop)

Mỗi khi giao 1 task cho AI Agent, hãy để Agent chạy theo đúng vòng lặp 5 bước:

1. **Đọc Context & Scope Lock:** Đọc [README.md](../README.md) và đúng file `.md` của bạn (`do-le-hoang.md`, `ha-duc-duy.md`, `lai-quoc-minh.md`, `nguyen-thai-binh.md`). Không đụng vào task của người khác.
2. **Pre-flight Check (Kiểm tra điều kiện tiên quyết):**
   - Kiểm tra repo nguồn (`sources/...`) và repo đích (`ViVuViet-frontend-...`) đã tồn tại chưa; nếu chưa thì clone đúng đường dẫn.
   - Kiểm tra Git identity (`user.name`, `user.email`) — **tuyệt đối không commit nếu email còn là `@example.com`**.
   - Kiểm tra nhánh của người làm trước đã được merge vào `origin/main` chưa (`git fetch origin` + kiểm tra `git log origin/main`).
3. **Implement (Thực thi trong 1 script/session):**
   - Gộp **Bước 0** (khai báo biến + hàm `Copy-Rel`/`Fake-Commit`) và **Task** vào **cùng 1 lần chạy shell** (hoặc file script tạm rồi xóa) để không bị mất biến/hàm giữa các lệnh của Agent.
   - Nếu có cảnh báo `Khong tim thay: ...` -> **DỪNG NGAY** trước khi push, báo lại để kiểm tra.
4. **Verify (Tự kiểm tra):**
   - Kiểm tra `git status` (working tree sạch), `git log -n 10 --format="%h | %ai | %an <%ae> | %s"` (đúng ngày giờ `+07:00`, đúng tác giả, đúng commit message không dấu).
   - Nếu task là điểm kết thúc feature/sprint hoặc đã đủ dependencies: chạy `npm run lint` / `npx tsc --noEmit` / `npm run build` để xác nhận không lỗi (không tự ý sửa code gốc nếu lỗi do thiếu file từ task sau).
5. **Push & PR:** Push nhánh lên `origin` và tạo Pull Request vào `main`.

---

## 2. Bộ Prompt Mẫu Chuẩn (Copy-Paste Ready)

> **Lưu ý khi dùng OpenCode:** File `opencode.json` trong repo đang đặt `"bash": "ask"` và `"edit": "ask"`. Khi Agent xin quyền chạy lệnh, bạn cần bấm **Allow** (hoặc Allow for session nếu muốn chạy mượt).

### Prompt 1 — Chuẩn bị môi trường & Clone repo (Chạy 1 lần đầu tiên)

Dùng prompt này khi bạn mới mở máy, chưa có thư mục `sources/` hoặc chưa đủ 3 repo đích:

```text
Hãy đọc `sprint-guides/README.md` và `sprint-guides/<TÊN_FILE_CỦA_BẠN.md>`.
Thực hiện bước chuẩn bị môi trường (KHÔNG chạy commit/push task nào vội):
1. Kiểm tra trên máy đã có đủ 3 repo nguồn (`nmcnpm`, `nmcnpm-admin`, `locdz`) và 3 repo đích (`ViVuViet-frontend-user`, `ViVuViet-frontend-admin`, `ViVuViet-frontend-driver`) theo đúng đường dẫn trong Bước 0 của file hướng dẫn chưa.
2. Nếu repo nào chưa có, hãy `git clone` từ URL trong `sprint-guides/README.md` vào đúng đường dẫn Bước 0.
3. Kiểm tra `user.name` và `user.email` trong file hướng dẫn của tôi: nếu vẫn là `@example.com` hoặc chưa khớp tài khoản GitHub của tôi, hãy DỪNG LẠI và hỏi tôi tên + email GitHub thật để cập nhật.
4. Báo cáo lại trạng thái các thư mục repo, nhánh hiện tại (`git status`, `git branch`) và xác nhận sẵn sàng.
```

---

### Prompt 2 — Thực thi 1 Task cụ thể (Dùng cho mọi Task)

Thay `<TÊN_FILE_CỦA_BẠN.md>` và `<MÃ_TASK>` (ví dụ: `Task 1.9`, `Task 1.10`, `Task 2.8a`, `Task 2.11`):

```text
Hãy đọc `sprint-guides/README.md` và `sprint-guides/<TÊN_FILE_CỦA_BẠN.md>`, sau đó thực hiện DUY NHẤT `<MÃ_TASK>`.

Yêu cầu bắt buộc khi thực thi:
1. SCOPE LOCK: Chỉ chạm vào các repo, nhánh và danh sách file được liệt kê trong `<MÃ_TASK>`. Tuyệt đối không sửa code gốc, không copy thư mục `.agents/`.
2. PRE-FLIGHT CHECK:
   - Xác nhận `GIT_EMAIL` không phải `@example.com`. Nếu là `@example.com`, hỏi tôi trước khi commit.
   - Chạy `git fetch origin` trên repo đích và kiểm tra nhánh tiên quyết (được ghi chú ngay dưới tiêu đề `<MÃ_TASK>`) đã có trong `origin/main` chưa. Nếu chưa merge vào `origin/main`, DỪNG LẠI và báo tôi ngay.
   - Đảm bảo working tree đang sạch trước khi checkout `main` và tạo nhánh mới.
3. CHẠY TRONG CÙNG 1 PHIÊN SHELL: Khai báo đầy đủ biến & hàm ở Bước 0 cùng với các lệnh của `<MÃ_TASK>` trong cùng 1 lần thực thi (không tách rời khiến mất biến `$SRC_*`, `$DST_*` hoặc hàm `Copy-Rel`/`Fake-Commit`).
4. FAIL-FAST: Nếu xuất hiện bất kỳ cảnh báo `Khong tim thay:` nào khi copy, DỪNG lại trước khi `git push` và báo rõ file nào bị thiếu.
5. VERIFY TRƯỚC KHI BÁO XONG:
   - Chạy `git -C <repo_đích> log -n 8 --format="%h | %ai | %an <%ae> | %s"` để kiểm tra timestamp `+07:00`, tác giả và commit message.
   - Chạy `git -C <repo_đích> status` để chắc chắn không còn file thừa/untracked ngoài ý muốn.
   - Sau khi `git push -u origin <branch>`, báo lại: tên nhánh vừa push, danh sách commit đã tạo, và link/lệnh tạo Pull Request vào `main`.
```

#### Copy nhanh theo từng thành viên (chỉ cần sửa `<MÃ_TASK>`):

- **Đỗ Lê Hoàng (`do-le-hoang.md`):**
  > Đọc `sprint-guides/README.md` và `sprint-guides/do-le-hoang.md`, thực hiện DUY NHẤT `Task 1.2` (hoặc `Task 1.11` / `Task 2.10` / `Task 2.11`). Chạy Bước 0 và Task trong cùng 1 phiên PowerShell, kiểm tra điều kiện tiên quyết đã merge vào `origin/main`, verify `git log` đúng `+07:00` rồi mới `git push` và báo tên nhánh tạo PR.

- **Hà Đức Duy (`ha-duc-duy.md` — macOS):**
  > Đọc `sprint-guides/README.md` và `sprint-guides/ha-duc-duy.md`, thực hiện DUY NHẤT `Task 1.9` (hoặc `Task 1.10` / `Task 2.8a` / `Task 2.8b` / `Task 2.9`). Xác nhận `GIT_EMAIL` là `duy.hd2416182@sis.hust.edu.vn`, kiểm tra nhánh tiên quyết đã merge vào `origin/main`, chạy Bước 0 + `sync_icons_index` + Task trong cùng 1 phiên bash/zsh, verify `git log` đúng `+07:00` rồi `git push` và báo tên nhánh tạo PR.

- **Lại Quốc Minh (`lai-quoc-minh.md`):**
  > Đọc `sprint-guides/README.md` và `sprint-guides/lai-quoc-minh.md`, thực hiện DUY NHẤT `Task 1.11` (hoặc `Task 2.10` / `Task 2.11`). Xác nhận `GIT_EMAIL` là `laiminh942@gmail.com`, kiểm tra nhánh tiên quyết đã merge vào `origin/main`, chạy Bước 0 + Task trong cùng 1 phiên PowerShell, verify `git log` đúng `+07:00` rồi `git push` và báo tên nhánh tạo PR.

- **Nguyễn Thái Bình (`nguyen-thai-binh.md`):**
  > Đọc `sprint-guides/README.md` và `sprint-guides/nguyen-thai-binh.md`, thực hiện DUY NHẤT `Task 1.9` (hoặc `Task 1.10` / `Task 2.8a` / `Task 2.8b` / `Task 2.9`). Xác nhận `GIT_EMAIL` là `nguyenthaibinh.tink32chl@gmail.com`, kiểm tra nhánh tiên quyết đã merge vào `origin/main`, chạy Bước 0 + `Sync-IconsIndex` + Task trong cùng 1 phiên PowerShell, verify `git log` đúng `+07:00` rồi `git push` và báo tên nhánh tạo PR.

---

### Prompt 3 — Kiểm tra Build / Typecheck / Lint (Bắt buộc sau Task `1.11`, `2.10` driver, `2.11`)

> **Lưu ý:** Không nên bắt Agent tự sửa code nếu build lỗi ở giữa sprint (vì các PR UI `1.9`, `1.10`, `2.8a`, `2.8b` merge trước `1.11`/`2.11` nên có thể thiếu `@/api/*` hoặc `@/components/providers`). Chỉ dùng prompt này làm **Quality Gate bắt buộc** sau khi merge xong `1.11` (cuối Sprint 1), `2.10` (`driver`), và `2.11` (cuối Sprint 2).

```text
Hãy kiểm tra chất lượng build cho repo `<TÊN_REPO_ĐÍCH>` trên nhánh hiện tại:
1. Kiểm tra đã có `node_modules` chưa; nếu chưa có thì chạy `npm install`.
2. Chạy lần lượt:
   - `npx tsc --noEmit`
   - `npm run lint`
   - `npm run build`
3. Báo cáo nguyên văn kết quả (PASS/FAIL) và lỗi cụ thể nếu có.
4. QUY TẮC AN TOÀN: KHÔNG tự ý sửa code nếu lỗi do thiếu file/API thuộc task sau chưa merge. Chỉ đề xuất nguyên nhân và hỏi tôi trước khi sửa bất kỳ file nào.
```

---

### Prompt 4 — Xử lý khi bị kẹt (Chưa merge nhánh trước / Conflict / Lỡ commit sai)

```text
Quá trình chạy `<MÃ_TASK>` đang gặp vấn đề: <MÔ_TẢ_LỖI_HOẶC_DÁN_LOG>.
Hãy thực hiện các bước sau (KHÔNG force push, KHÔNG reset cứng khi chưa hỏi tôi):
1. Chạy `git status`, `git branch -a`, và `git log -n 5 --oneline` trên repo đang lỗi.
2. Xác định nguyên nhân chính xác (ví dụ: nhánh của thành viên trước chưa merge vào `origin/main`, sai đường dẫn `$SRC_*`, thiếu file nguồn, hoặc sai email commit).
3. Đề xuất phương án xử lý an toàn nhất và chờ tôi xác nhận trước khi chạy lệnh sửa Git.
```

---

## 3. Nguyên tắc vàng & Checklist chống AI làm hỏng code

Trước khi bấm **Merge Pull Request** trên GitHub, hãy kiểm tra nhanh 6 điểm sau:

- [ ] **Đúng thứ tự merge:** Không bao giờ tạo nhánh task sau khi nhánh tiên quyết chưa merge vào `main` (xem mục *Thứ tự merge vào `main` khuyến nghị* trong [README.md](../README.md)).
- [ ] **Đúng tác giả Git:** `git log` không còn email `@example.com`.
- [ ] **Đúng múi giờ `+07:00`:** Ngày giờ commit khớp với lịch Sprint trong file hướng dẫn.
- [ ] **Không copy `.agents/`:** Repo đích không chứa thư mục `.agents/` từ repo nguồn.
- [ ] **Không sửa code gốc bừa bãi:** Nếu AI báo thiếu module ở giữa sprint, kiểm tra xem file đó có thuộc task của bạn hay task của thành viên sau — tuyệt đối không để AI tự bịa code hoặc tự viết lại file để "chữa cháy".
- [ ] **Giữ nguyên `AGENTS.md` / `opencode.json` ở repo đích:** Không xóa nhầm cấu hình agent có sẵn của repo đích khi `git add -A`.

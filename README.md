
# bytequeens_adm
## 1. Giới thiệu thành viên
- Hoàng Thanh Thảo Nguyên - 22120235
- Nguyễn Lê Anh Thư - 22120354
- Nguyễn Lê Thanh Trúc - 22120393

## 2. Giới thiệu đề tài
- ByteQueens ADM là ứng dụng di động được phát triển bằng Flutter, lấy cảm hứng từ trợ lý thông minh Jarvis trong việc hỗ trợ người dùng quản lý và tương tác với các nhóm làm việc một cách trực quan và tự động.
- Mục tiêu chính:

    - Cung cấp một hệ thống quản lý nhóm (Group Management) thân thiện và dễ sử dụng.
    - Cho phép người dùng tạo, chỉnh sửa, xóa và xem chi tiết nhóm.
    - Hỗ trợ tìm kiếm, lọc và thêm thành viên nhanh chóng.

`Milestone 1`
## 3. Widget Tree Link
### 3.1 Bố cục Widget Tree
- Nhóm thiết kế **Widget Tree** đi từ **tổng quan** đến **chi tiết**, giúp quản lý cấu trúc giao diện, dễ mở rộng và bảo trì.
#### 🔹Nguyên tắc thiết kế
- **Tách UI theo chức năng (feature-based)**: Mỗi chức năng là một module riêng, chứa các màn hình (pages) và widget con.
- **Đi từ tổng quan → chi tiết → component**:
  1. Tổng quan: liệt kê các chức năng chính và màn hình.
  ![alt text](image.png)
  2. Chi tiết: mỗi màn hình (page) có widget tree riêng.
  ![alt text](image-1.png)
  3. Component: các widget con (Card, ListTile, Form, Button) được thiết kế riêng, có thể tái sử dụng.
  ![alt text](image-2.png)
- **Widget Tree chỉ bao gồm UI**, không đưa logic, service hay model vào.



### 3.2 Draw.io link: 
- https://app.diagrams.net/#G1-qID_CS0izfY-nX7yjrqOXDxm3f7N7XF#%7B%22pageId%22%3A%22afPgoWwypiOKziJLwe3N%22%7D 

## 4. Mock UI 
| STT | Tên màn hình       | Mục đích / Chức năng chính                          | Ghi chú / Thành phần nổi bật                  |
|-----|------------------|----------------------------------------------------|----------------------------------------------|
| 1   | Splash            | Hiển thị logo, loading ứng dụng                   | Logo trung tâm, animation loading            |
| 2   | Log In            | Đăng nhập tài khoản người dùng                     | Email, Password, Button Login, Link Forgot Password, Sign Up |
| 3   | Sign Up           | Đăng ký tài khoản mới                              | Email, Password, Confirm Password, Button Sign Up |
| 4   | Verification      | Xác thực tài khoản qua mã OTP                      | Nhập OTP, Button Xác nhận                     |
| 5   | Forgot Password   | Khôi phục mật khẩu                                 | Email, Button gửi mã, Reset Password          |
| 6   | Main Page         | Trang chính sau khi đăng nhập                      | Tab navigation, Quick access (Bots, Groups) |
| 7   | Bot List          | Danh sách các bot                                   | Search bar, Filter, ListView BotCard, FAB Tạo Bot |
| 8   | Create Bot        | Tạo bot mới                                       | Form (Tên bot, Mô tả, Chọn model), Action Buttons |
| 9   | Bot Detail        | Xem chi tiết bot                                   | Info, Description, Action Buttons (Edit, Delete, Chat) |
| 10  | Bot Preview       | Preview bot trước khi tương tác                     | Chat interface giả lập, Model info           |
| 11  | Create Group      | Tạo nhóm mới                                      | Form (Tên nhóm, Mô tả), Add Members, Action Buttons |
| 12  | Group List        | Danh sách nhóm                                     | Search bar, ListView GroupCard, FAB Tạo nhóm |

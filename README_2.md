
## Quy Trình Phát Triển Phần Mềm Trên Git Và GitHub

### I. Với Project lớn
#### 1. Khởi Tạo Repository (Lead teams)

- **Bước 1**: Tạo một repository mới trên GitHub.
  - Truy cập GitHub, nhấn nút "New" và điền thông tin cần thiết.
  - Chọn "Initialize this repository with a README".

- **Bước 2**: Sao chép repository về máy cục bộ.
  ```sh
  git clone <link-to-repository>
  ```

#### 2. Tạo các issues trên github
- **Yêu cầu bắt buộc**: gắn link lable, Assignees, Projects, Miolestone, đối với các project có spint thì phải thêm, 


`các task đang thực hiện để in Progress`, `Task đã tạo chưa làm sẽ để todo`.

các task cha sẽ tạo branch và thực hiện các task con trên branch đó 

#### 3. Thiết Lập Quy Trình Làm Việc (Workflow)

- **Branch chính**: `main`, được bảo vệ, chỉ merge code đã qua kiểm tra qua nhánh `test`, các dev không sử dụng nhánh main.
- **Branch phát triển**: `dev`, nơi thực hiện các tính năng mới. các thành viên sẽ làm việc trong nhánh này
- **Branch tính năng**: `<số issues>` đã tạo từ `issues`, branch riêng cho từng tính năng, khi commit thì thêm 
+ "+ `(refs: #<số issues>)` ".
khi hoàn tất, tạo `pull request` báo lại cho lead teams để kiểm tra, khi merge code thì thực hiện xóa nhánh đã tạo

+ `dev` -> `test` -> `main`

### II. Các project nhỏ tùy thuộc vào 2->3 nhân sự làm 
Lead Teams sẽ chịu tránh nhiệm quản lí và thực hiện như trên


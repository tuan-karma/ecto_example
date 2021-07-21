# Overview of Associations in Ecto

## Ecto.build_assoc/3

`build_assoc(struct, assoc, attributes \\ %{})`

Tạo dựng một cấu trúc từ mối liên kết `assoc` cho trước trong cấu trúc `struct`.

### Ví dụ

Nếu mối liên hệ là `has_one` hoặc `has_many` và khóa chủ (PK) đã được đặt trong cấu trúc mẹ, thì khóa này sẽ tự động được đặt vào trong cấu trúc liên kết được tạo ra:
```elixir
iex> post = Repo.get(Post, 13)
%Post{id: 13}

iex> Ecto.build_assoc(post, :comments)
%Comment{id: nil, post_id: 13}
```

Lưu ý rằng điều kể trên không xảy ra với các trường hợp `belongs_to`, vì khóa thường là khóa chính và nó thường được cấp phát tự động

```elixir
iex> comment = Repo.get(Comment, 13)
%Comment{id: 13, post_id: 25}

iex> Ecto.build_assoc(comment, :post)
%Post{id: nil}
```

Bạn cũng có thể đưa vào các thuộc tính (trong lúc xây dựng cấu trúc liên kết aka `build_assoc`), có thể là từ một `map` hoặc `keyword list`, để thiết lập các trường trong cấu trúc liên hệt, ngoại trừ khóa liên kết (FK).

```elixir
iex> Ecto.build_assoc(post, :comments, text: "cool")
%Comment{id: nil, post_id: 13, text: "cool"}

iex> Ecto.build_assoc(post, :comments, %{text: "cool"})
%Comment{id: nil, post_id: 13, text: "cool"}

iex> Ecto.build_assoc(post, :comments, post_id: 1)
%Comment{id: nil, post_id: 13}
```

Các thuộc tính cho vào được mong đợi là dữ liệu có cấu trúc. Nếu bạn muốn xây dựng một cấu trúc liên kết từ dữ liệu bên ngoài, chẳng hạn như các tham số truy vấn từ web `request params`, bạn có thể sử dụng `Ecto.Changeset.cast/3` sau `buid_assoc/3`:

```elixir
parent
|> Ecto.build_assoc(:child)
|> Ecto.Changeset.cast(params, [:field1, :field2])
```

## Ecto.Changeset.put_assoc/4

`put_assoc(changeset, name, value, opts \\ [])`

Đẩy một cấu trúc liên kết dưới dạng một thay đổi (change) trong `changeset`.

Hàm này được sử dụng để làm việc với toàn bộ các liên kết của thực thể đang xét. Ví dụ: nếu một `Post` có nhiều `comments`, hàm này có phép bạn thêm, xóa, hoặc cập nhật tất cả các `comments` cùng một lượt. Nếu mục đích của bạn chỉ là thêm một `comment` mới vào `post`, thì bạn nên làm điều đó một cách thủ công, như sẽ mô tả sau trong phần "Ví dụ: Thêm comments vào post".

Hàm này yêu cầu dữ liệu liên kết phải được tải trước `preload`, ngoại trừ khi tập thay đổi mẹ (`parent changeset`) mới được tạo ra và chưa được ghi xuống DB. Dữ liệu bị thiếu sẽ gọi đến hành vi `:on_replace` - một lựa chọn được định nghĩa trong lược đồ dữ liệu liên kết tương ứng.

Đối với các liên kết đơn (kiểu `has_one`, `belongs_to`), nil có thể được sử dụng để xóa mục nhập hiện có. Đối với các liên kết đa (kiểu `has_many`, `many_to_many`), dùng `list` trống để xóa các mục nhập hiện có.

Nếu cấu trúc liên kết không có gì thay đổi, nó sẽ bị bỏ qua. Nếu cấu trúc liên kết không hợp lệ, tập thay đổi - `changeset` se bị đánh dấu là không hợp lệ. Nếu giá trị đưa vào không phải là bất kỳ giá trị nào dưới đây, nó sẽ phát lỗi.

### Dữ liệu liên kết được cho dưới các dạng sau:

  * Một `map` hoặc `keyword list` biểu diễn các thay đổi sẽ được áp dụng cho dữ liệu bị liên kết. Một `map` hoặc một `keyword list` có thể được cho để cập nhật dữ liệu liên kết miễn là chúng có khóa chính (PK) khớp với dữ liệu bị liên kết (FK?). Ví dụ: `put_assoc(changeset, :comments, [%{id: 1, title: "changed"}])` sẽ tìm bình luận `comment` với `id = 1` để cập nhật tiêu đề `title`. Nếu không có `comment` nào với `id` như vậy tồn tại, một cái `comment` mới sẽ được tạo ra nhanh chóng. Vì chỉ duy nhất một `comment` được cho, nên bất kỳ comment liên kết nào khác sẽ bị thay thế. Trong tất cả các trường họp, các `key` đưa vào phải là dạng `:atom`. Đối lập với `cast_assoc` và `embed_assoc`, `map` hoặc `struct` cho trước không được xác thực `validate` theo bất kỳ cách nào và sẽ được chèn vào nguyên trạng. API này chủ yếu được sử dụng trong các `script` và `tests`, để tạo ra một lược đồ đơn giản trực tiếp, dạng như:
  ```elixir
  Ecto.Changeset.change(
    %Post{},
    title: "foo",
    comments: [
      %{body: "first"},
      %{body: "second"}
    ]
  )
  ```
  * `changeset` hoặc `struct` - khi một changeset hoặc struct được cung cấp, chúng được coi là dữ liệu chuẩn và các dữ liệu liên kết hiện được lưu trong liên kết sẽ bị bỏ qua. Ví dụ: hành động `put_assoc(changeset, :comments, [%Comment{id: 1, title: "changed"}])` sẽ gửi `Comment` nguyên dạng đến CSDL, bỏ qua bất kỳ `comment` nào đang được liên kết, kể cả khi `id` trùng hớp được tìm thấy. Nếu `commnet` đó đã có sẵn trong CSDL, thì hàm `put_assoc/4` chỉ đảm bảo rằng các `comment` và dữ liệu mẹ được liên kết với nhau. Điều này cực kỳ hữu ích khi liên kết các dữ liệu hiện có sẵn, như chúng ta thấy trong phần "Ví dụ: Thêm thẻ vào bài đăng".

Khi một `changeset` được cấp cho hàm Ecto.Repo, tất cả các mục nhập sẽ được chèn/cập nhật/xóa trong cùng một giao dịch - `transaction`.

### Ví dụ: Thêm bình luận vào bài đăng

Hình dung một mối quan hệ liên kết khi `Post` có nhiều `comments` (Post has_many comments), và bạn muốn thêm một `comment` mới vào một `post` hiện có. Mặc dù có thể sử dụng `put_assoc/4` cho việc này, nhưng nó sẽ là sự phức tạp không cần thiết. Hãy xem xét một ví dụ.

Trước tiên, tìm nạp bài đăng `post` cùng với tất cả các bình luận - `comments` hiện có:
```elixir
post = Post |> Repo.get!(1) |> Repo.preload(:comments)
```

Sau đây là cách làm sai:
```elixir
post
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:comments, [%Comment{body: "bad example!"}])
|> Repo.update!()
```

Lý do cách làm trên sai là vì `put_assoc/4` luôn hoạt động với toàn bộ dữ liệu. Do vậy ví dụ bên trên sẽ xóa toàn bộ `comments` có trước đó và chỉ giữ `comment` bạn vừa thêm vào. Thay vào đó, bạn có thể thử:

```elixir
post
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:comments, [%Comment{body: "so-so example!"} | post.comments])
|> Repo.update!()
```

Trong ví dụ trên, chúng ta nối `comment` mới vào danh sách các `comments` hiện có trong `post`. Ecto sẽ làm phép loại trừ - `diff` danh sách các `comments` trong `post` với danh sách `comment` được đưa vào và chèn chính xác các `comment` mới vào CSDL. Tuy vậy, cần lưu ý rằng Ecto phải làm rất nhiều việc để tìm ra điều mà chúng ta biết ngay từ đầu, đó là chỉ có một nhận xét mới chúng ta đưa vào.

Trong những trường hợp như trên, khi bạn chỉ muốn nhập một mục duy nhất, bạn chỉ cần làm việc trực tiếp trên mục được liên kết sẽ dễ dàng hơn rất nhiều. Chẳng hạn, thay vào đó, chúng ta có thể đặt lên kết `post` vào trong `comment` (nghĩa là thao tác theo chiều liên kết ngược lại - `child` belongs_to `parent`).

```elixir
%Comment{body: "better example"}
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:post, post)
|> Repo.insert!()
```

Có một cách thay thế tốt hơn, là chúng ta có thể đảm bảo rằng khi chúng ta tạo ra `comment` nó đã được lên kết với `post`:

```elixir
Ecto.build_assoc(post, :comments)
|> Ecto.Changeset.change(body: "great example!")
|> Repo.insert!()
```

Hoặc chúng ta có thể trực tiếp set `post_id` vào trong chính `comment`, như sau:
```elixir
%Comment{body: "better example", post_id: post.id}
|> Repo.insert!()
```

Nói cách khác, khi bạn thấy mình chỉ muốn làm việc với một phần con của dữ liệu, thì việc sử dụng `put_assoc/4` rất có thể là không cần thiết. Thay vào đó, bạn sẽ cần phải làm việc với chiều bên kia của liên kết.

Hãy xem một ví dụ phù hợp với sử dụng của `put_assoc/4`.

### Ví dụ: Gắn các thẻ vào bài đăng

Hãy tưởng tượng bạn nhận được một tập hợp các `tags` (từ web UI) cần phải liên kết với một `post`. Các giá trị của `tags` đã tồn tại trong CSDL từ trước. Giả thiết rằng chúng ta lấy dữ liệu ở định dạng như sau:

```elixir
post_params = %{"title" => "new post", "tags" => ["learner", "news"]}
```

Bây giờ, vì các giá trị `tags` đã tồn tại sẵn, chúng ta sẽ mang tất cả chúng từ CSDL và đưa trực tiếp vào post như sau:

```elixir
tags = Repo.all(from t in Tag, where: t.name in ^post_params["tags"])

post
|> Repo.preload(:tags)
|> Ecto.Changeset.cast(post_params, [:title])
|> Ecto.Changeset.put_assoc(:tags, tags)
```

Trong trường hợp này, chúng ta luôn yêu cầu người dùng chuyển trực tiếp danh sách thẻ `tags` cần gắn, nên sử dụng `put_assoc/4` là một lựa chọn rất hợp lý. Nó sẽ tự động loại bỏ bất kỳ thẻ nào không được cung cấp bởi người dùng và liên kết đúng đến tất cả các thẻ đã được cho cùng bài đăng.

Hơn nữa, vì thông tin thẻ được cung cấp dưới dạng cấu trúc được đọc trực tiếp từ CSDL, Ecto sẽ coi dữ liệu là chính xác và chỉ làm những điều tối thiểu cần thiết để đảm bảo rằng các `posts` và `tags` được liên kết đúng như thiết kế với nhau mà không cần cố gắng cập nhật hay loại trừ bất kỳ trường nào trong cấu trúc thẻ.

Mặc dù `put_assoc/4` nhận vào tham số cuối là `opts // []`, nhưng hiện không có tùy chọn nào được hỗ trợ.

## Ecto.Changeset.cast_assoc/3

`cast_assoc(changeset, name, opts \\[])`

Truyền liên hết đã cho với các tham số `changeset`.

Hàm này nên được sử dụng khi làm việc với toàn thể liên kết cùng lúc (và không phải một phần tử đơn lẻ của kiểu nhiều - `many`) và nhận dữ liệu từ bên ngoài ứng dụng.

Hàm `cast_assoc/3` hoạt động khớp với các bản ghi được trích xuất từ CSDL và so sánh nó với các tham số nhận được từ nguồn bên ngoài. Do đó, nó yêu cầu dữ liệu trong `changeset` cần phải tải trước mối liên kết sắp được truyền - `cast` và rằng tất cả các ID đều tồn tại và duy nhất.

Ví dụ, một người dùng có mối quan hệ nhiều địa chỉ nơi dữ liệu được `post` về như sau:

```elixir
%{"name" => "john doe", "addresses" => [
  %{"street" => "somewhere", "country" => "brazil", "id" => 1},
  %{"street" => "elsewhere", "country" => "poland"},
]}
```

và sau đó

```elixir
User
|> Repo.get!(id)
|> Repo.preload(:address) # Only required when updating data
|> Ecto.Changeset.cast(params, [])
|> Ecto.Changeset.cast_assoc(:address, with: &MyApp.Address.changeset/2)
```

Các tham số cho liên kết đã cho sẽ được truy xuất từ `changeset.params`. Các tham số đó được mong đợi là một `map` có các thuộc tính, tương tự như cái được truyền cho hàm `cast/4`. Khi các tham số được truy xuất, `cast_assoc/3` sẽ khớp các tham số đó với các liên kết đã có sẵn trong bản ghi của `changeset`.

Khi `cast_assoc/3` được gọi, Ecto sẽ so sánh từng tham số với các địa chỉ đã được `preload` - tải trước của người dùng - `user` và hành động theo các kịch bản sau:

  * Khi trong tham số `params` không chứa ID, dữ liệu từ tham số sẽ được chuyển đến `MyApp.Address.changeset/2` với một `struct` mới và trở thành một thao tác chèn dữ liệu - `insert operation`.
  * Khi tham số chứa `ID` và không có liên kết con nào có ID như vậy, tham số sẽ được truyền tới `MyApp.Address.changeset/2` với một `struct` mới và trở thành một thao tác chèn dữ liệu - như trường hợp trên.
  * Khi tham số chứa `ID` và có liên kết con trong user với ID như vậy, dữ liệu liên kết sẽ được truyền tới `MyApp.Address.changeset/2` với cấu trúc có sẵn và trở thành một thao tác cập nhật dữ liệu - `update operation`.
  * Nếu có một liên kết con với một ID không có trong tham số, thì hàm callback `:on_replace` cho liên kết đó sẽ được gọi.

Mỗi khi hàm `MyApp.Address.changeset/2` được gọi, nó phải trả về một `changeset`. Khi `changeset` mẹ được đưa đến hàm Ecto.Repo, tất cả các mục nhập sẽ được chèn/cập nhật/xóa trong cùng một giao dịch (cùng với liên kết con).

Chi tiết thêm, tham khảo: https://hexdocs.pm/ecto/Ecto.Changeset.html#cast_assoc/3

Khi đã có đủ kiến thức về SQL và DB Queries, và cơ bản về Ecto.Schema, Changeset, Migration rồi thì hãy đọc bài này của Jose Valim. Bài viết rất dễ hiểu và bản chất, nhưng cần phải nắm vững cơ bản để có thể lĩnh hội được và hiểu sâu vấn đề
http://blog.plataformatec.com.br/2015/08/working-with-ecto-associations-and-embeds/




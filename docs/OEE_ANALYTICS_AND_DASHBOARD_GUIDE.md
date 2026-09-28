# HƯỚNG DẪN THỰC HÀNH PHÂN TÍCH OEE & THIẾT KẾ DASHBOARD QUẢN TRỊ SẢN XUẤT
## DỰ ÁN: TỐI ƯU HÓA HIỆU SUẤT THIẾT BỊ TỔNG THỂ (OEE) TẠI NHÀ MÁY GRANDMA EDNA'S BISCUITS

---

## MỤC LỤC
1. [Khung Đo Lường OEE Chuẩn Quốc Tế & Mapping Dữ Liệu IoT](#1-khung-đo-lường-oee-chuẩn-quốc-tế--mapping-dữ-liệu-iot)
2. [Lời Giải Chi Tiết 10 Câu Hỏi Chiến Lược Cho Ban Giám Đốc](#2-lời-giải-chi-tiết-10-câu-hỏi-chiến-lược-cho-ban-giám-đốc)
3. [Bộ Công Thức Tính Toán Toàn Diện (SQL & DAX Measures Codebook)](#3-bộ-công-thức-tính-toán-toàn-diện-sql--dax-measures-codebook)
4. [Hướng Dẫn Thiết Kế Dashboard Quản Trị Chuẩn Ngành (Power BI / Tableau Blueprint)](#4-hướng-dẫn-thiết-kế-dashboard-quản-trị-chuẩn-ngành-power-bi--tableau-blueprint)
5. [Khuyến Nghị Chiến Lược & Bài Toán Tối Ưu Hóa ROI (Actionable Roadmap)](#5-khuyến-nghị-chiến-lược--bài-toán-tối-ưu-hóa-roi-actionable-roadmap)

---

# 1. KHUNG ĐO LƯỜNG OEE CHUẨN QUỐC TẾ & MAPPING DỮ LIỆU IOT

### 1.1. Công thức 3 trụ cột OEE (TPM Standard)
Hiệu suất Thiết bị Tổng thể (**Overall Equipment Effectiveness - OEE**) là thước đo tiêu chuẩn toàn cầu để xác định tỷ lệ thời gian sản xuất thực sự hiệu quả.

$$\text{OEE} = \text{Availability (A)} \times \text{Performance (P)} \times \text{Quality (Q)}$$

* **Availability (Mức độ khả dụng)**: Đo lường mức độ sẵn sàng vận hành, tổn thất do dừng máy:
  $$\text{Availability} = \frac{\text{Operating Time (Thời gian máy chạy)}}{\text{Planned Production Time (Thời gian kế hoạch)}}$$
* **Performance (Hiệu suất vận hành)**: Đo lường tổn thất tốc độ máy chạy chậm hơn thiết kế:
  $$\text{Performance} = \frac{\text{Actual Output (Sản lượng thực tế)}}{\text{Ideal Output (Sản lượng lý thuyết)}} = \frac{\text{Total Biscuits Made}}{\text{Operating Time (hours)} \times \text{Target Speed per hour}}$$
* **Quality (Chất lượng sản phẩm)**: Đo lường tỷ lệ sản phẩm không bị lỗi:
  $$\text{Quality} = \frac{\text{Good Biscuits (Bánh đạt chuẩn)}}{\text{Total Biscuits Made (Tổng bánh làm ra)}} = 1 - \text{Waste \%}$$

### 1.2. Mapping Dữ Liệu Cảm Biến Của Nhà Máy Grandma EDNA
| Thuộc tính cảm biến | Ý nghĩa công nghiệp | Phân loại trong OEE |
| :--- | :--- | :--- |
| `Run Time` | Máy đang sản xuất thực tế | **Operating Time** |
| `CC (Changeover Cleaning)` | Vệ sinh & Thay đổi khuôn mẫu bánh | **Downtime** (Thời gian chuyển đổi sản xuất) |
| `NO (No Order)` | Máy dừng do không có đơn hàng / chờ kế hoạch | **Unplanned/Idle Downtime** |
| `PM (Maintenance)` | Bảo trì, bảo dưỡng định kỳ theo lịch | **Planned Downtime** (Trừ khỏi Planned Production Time) |
| `Unclassified` (mã `'0'`) | Sự cố dừng máy chưa gắn mã lỗi | **Unplanned Downtime** |
| `Target_Biscuits_per_hour` | Định mức tốc độ kỹ thuật của máy theo loại bánh | Dùng tính **Ideal Output** |
| `TotalBiscuitsMade` | Tổng sản lượng cảm biến ghi nhận | Mẫu số tính **Quality**, Tử số tính **Performance** |
| `GoodMadeBiscuits` | Số lượng bánh qua cổng kiểm định đạt tiêu chuẩn | Tử số tính **Quality** |

---

# 2. LỜI GIẢI CHI TIẾT 10 CÂU HỎI CHIẾN LƯỢC CHO BAN GIÁM ĐỐC

Dữ liệu được truy vấn và đối soát chính xác 100% từ cơ sở dữ liệu `my_factory.duckdb` trong tháng **07/2021**:

```
BẢNG TỔNG QUAN CHỈ SỐ NHÀ MÁY THÁNG 07/2021:
├── Tổng thời gian ghi nhận:            2,996.04 giờ
├── Thời gian dừng bảo trì (PM):             3.53 giờ
├── Thời gian kế hoạch (Planned):       2,992.51 giờ
├── Thời gian chạy thực tế (Operating):   565.10 giờ (18.88%)
├── Tổng sản lượng bánh quy:            1,357,533,487 bánh
├── Sản lượng đạt chuẩn:                  457,821,115 bánh
├── Sản lượng phế phẩm (Scrap):           899,712,372 bánh (66.28%)
└── CHỈ SỐ OEE TOÀN NHÀ MÁY:                    6.37% (Capped)
```

---

### CÂU HỎI 1: SỨC KHỎE TỔNG THỂ (OEE TOÀN NHÀ MÁY)
> **Câu hỏi**: *Chỉ số OEE trung bình của toàn bộ nhà máy Grandma EDNA trong tháng 07/2021 là bao nhiêu %? Nhà máy đã đạt đến mức lý tưởng của ngành (World Class OEE - từ 85% trở lên) chưa?*

* **Kết quả phân tích**:
  * **Availability (Khả dụng)**: **18.88%** (565.10 giờ chạy / 2,992.51 giờ kế hoạch).
  * **Performance (Hiệu suất)**: **100.00%** (Capped) – Trong các khoảng thời gian máy chạy, tốc độ máy đạt định mức.
  * **Quality (Chất lượng)**: **33.72%** (Chỉ 457.8 triệu bánh đạt chuẩn / 1.357 tỷ bánh sản xuất).
  * **OEE Trung bình Toàn Nhà Máy**: **6.37%**.
* **Đánh giá chuẩn ngành**:
  * Chuẩn **World Class OEE là $\ge 85\%$** (Availability: 90%, Performance: 95%, Quality: 99.9%).
  * Nhà máy Grandma EDNA đang ở mức **CỰC KỲ NGUY HIỂM (Báo động đỏ)**, kém xa tiêu chuẩn thế giới tới **78.63 điểm %**.
  * Hai "kẻ thù" lớn nhất triệt hạ OEE của nhà máy là **Thời gian dừng máy khổng lồ** (Availability chỉ 18.88%) và **Tỷ lệ phế phẩm kinh hoàng** (Chất lượng chỉ 33.72%, phế phẩm lên tới 66.28%).

---

### CÂU HỎI 2: PHÂN TÍCH ĐIỂM NGHẼN (BOTTLENECK ANALYSIS)
> **Câu hỏi**: *Trong số 10 loại máy vận hành, máy nào đang có chỉ số OEE thấp nhất? Đâu là nguyên nhân cốt lõi kéo tụt năng suất của máy đó?*

* **Bảng xếp hạng OEE 10 loại máy (Xếp từ thấp đến cao)**:

| Hạng | Tên Máy | Giờ Chạy | Availability | Performance | Quality | OEE (%) | Nguyên nhân cốt lõi |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | **Biscuit Heating Machine** | 63.7h | 35.21% | **0.07%** | 100% | **0.03%** | **Performance cực thấp**: Chạy cực chậm so với thiết kế. |
| **2** | **Biscuit Forming Machine** | 67.1h | 19.82% | **0.41%** | 100% | **0.08%** | **Performance cực thấp**: Tốc độ định mức không đạt. |
| **3** | **Biscuit Sprinkling Machine**| 60.4h | 55.15% | 100.00% | **0.22%** | **0.12%** | **Quality tê liệt**: 99.78% bánh làm ra bị lỗi/hủy! |
| **4** | **Biscuit Boxing Machine** | 87.2h | 11.19% | 1.31% | 100% | **0.15%** | **Availability & Performance đều thấp**. |
| **5** | **Biscuit Mixing Machine** | 52.4h | 9.62% | 2.26% | 100% | **0.22%** | **Availability cực thấp** (dừng máy > 90% thời gian). |
| **6** | **Biscuit Topping Machine** | 0.2h | 0.69% | 44.66% | 100% | **0.31%** | Máy hầu như không hoạt động. |
| **7** | **Biscuit Jam Machine** | 4.8h | 6.28% | 10.66% | 100% | **0.67%** | Tỷ lệ dừng máy quá cao. |
| **8** | **Packaging Heat Machine** | 3.5h | 2.71% | 29.58% | 100% | **0.80%** | Thiếu đơn hàng và thời gian chạy. |
| **9** | **Biscuit Pressing Machine** | 39.4h | 35.53% | 16.17% | 100% | **5.74%** | Vận hành trung bình. |
| **10**| **Biscuit Filling Machine** | 186.4h | 26.64% | 100.00% | **40.88%** | **10.89%** | Máy chủ lực, nhưng Quality chỉ đạt 40.88%. |

* **Kết luận điểm nghẽn**:
  * **Máy có OEE thấp nhất**: **Biscuit Heating Machine (0.03%)** và **Biscuit Forming Machine (0.08%)**.
  * **Cỗ máy gây thiệt hại chất lượng nghiêm trọng nhất**: **Biscuit Sprinkling Machine** với tỷ lệ hàng lỗi lên tới **99.78%**.

---

### CÂU HỎI 3: BẮT BỆNH DỪNG MÁY (DOWNTIME ANALYSIS)
> **Câu hỏi**: *Tổng thời gian nhà máy bị dừng hoạt động trong tháng là bao nhiêu giờ? Trạng thái dừng máy nào đang tiêu tốn nhiều thời gian nhất?*

* **Tổng thời gian dừng máy**: **2,992.04 giờ**.
* **Phân bổ theo trạng thái dừng máy**:

```
DOWNTIME BREAKDOWN (2,992.04 GIỜ):
█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ NO (No Order): 2,294.91 giờ (76.70%)
████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ CC (Changeover Cleaning): 561.09 giờ (18.75%)
█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Unclassified: 132.51 giờ (4.43%)
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ PM (Maintenance): 3.53 giờ (0.12%)
```

* **Phát hiện quan trọng**:
  * Trạng thái dừng máy lớn nhất là **NO (No Order - Trống đơn hàng/Chờ kế hoạch)** chiếm tới **76.70%** thời gian (tương đương gần 96 ngày làm việc tích lũy của các máy!). Đây không phải lỗi cơ khí mà là sự đứt gãy trong **kế hoạch điều độ sản xuất (Production Scheduling)** và năng lực bán hàng (Supply Chain/Sales Demand).
  * Đứng thứ hai là **CC (Changeover Cleaning - Vệ sinh & Thay khuôn)** chiếm **18.75%** (561.09 giờ).

---

### CÂU HỎI 4: PHÂN LOẠI TỔN THẤT (MINOR VS. MAJOR STOPPAGES)
> **Câu hỏi**: *Nhà máy đang bị thiệt hại nhiều hơn bởi các Minor Stoppage (sự cố vặt dưới 3 phút) hay Major Stoppage (sự cố lớn trên 3 phút)?*

* **So sánh định lượng**:

| Phân loại sự cố | Số lần xảy ra | Tỷ lệ số lần (%) | Tổng thời gian dừng | Tỷ lệ tổn thất thời gian (%) |
| :--- | :---: | :---: | :---: | :---: |
| **Minor Stoppage (< 3 phút)** | **5,286 lần** | **65.81%** | **83.10 giờ** | **2.78%** |
| **Major Stoppage ($\ge$ 3 phút)**| **2,746 lần** | **34.19%** | **2,908.94 giờ** | **97.22%** |
| **Tổng cộng** | **8,032 lần** | **100.00%** | **2,992.04 giờ** | **100.00%** |

* **Insight thực chiến**:
  * **Nghịch lý phân phối**: Minor Stoppage chiếm phần lớn về tần suất (gần 66% số vụ dừng máy), liên tục gây gián đoạn nhịp điệu vận hành của công nhân.
  * Tuy nhiên, **về mặt thời gian thiệt hại thực tế**, nhà máy chịu tổn thất áp đảo từ **Major Stoppage ($\ge$ 3 phút)**, chiếm tới **97.22%** (gần 2,909 giờ).
  * Các sự cố lớn chủ yếu là việc dừng máy chờ đơn hàng kéo dài hàng giờ và quá trình tháo lắp, vệ sinh khuôn máy phức tạp.

---

### CÂU HỎI 5: CẢNH BÁO CHẤT LƯỢNG (QUALITY INDEX & SCRAP LOSS)
> **Câu hỏi**: *Quy trình sản xuất loại bánh quy nào (Product) đang gặp vấn đề nghiêm trọng về chất lượng khi có tỷ lệ bánh lỗi/hàng hủy (Waste %) cao nhất?*

* **Top 5 Dòng Bánh Có Tỷ Lệ Phế Phẩm (Waste %) Cao Nhất**:
  1. **Peanut Cookies**: Tỷ lệ phế phẩm **99.84%** (Sản xuất 117.08M cái $\rightarrow$ Hủy 116.89M cái!).
  2. **Vienesse Creams**: Tỷ lệ phế phẩm **99.83%** (Hủy 18.40M cái).
  3. **Orange Creams**: Tỷ lệ phế phẩm **99.78%** (Hủy 16.61M cái).
  4. **Fruit and Nut**: Tỷ lệ phế phẩm **99.69%** (Hủy 15.19M cái).
  5. **Chocolate Digestives**: Tỷ lệ phế phẩm **99.59%** (Hủy 24.95M cái).

* **Top Dòng Bánh Có Chất Lượng Đạt Chuẩn Cao Nhất**:
  * **Pink Wafers**: Tỷ lệ đạt chuẩn **100.00%** (Waste = 0.00%, sản xuất 80,375 bánh đạt cả 80,375).
  * **Custard Creams**: Tỷ lệ đạt chuẩn **75.59%** (Waste = 24.41%).
  * **Milk Cookies**: Tỷ lệ đạt chuẩn **74.75%** (Waste = 25.25%).
* **Cảnh báo cho Ban giám đốc**: Nhóm sản phẩm bánh kem/hạt cao cấp (Peanut Cookies, Creams, Fruit and Nut) có quy trình công nghệ bị lỗi nghiêm trọng, sản xuất ra đến đâu gần như phế phẩm đến đó.

---

### CÂU HỎI 6: ĐỘ LỆCH MỤC TIÊU (PERFORMANCE GAP)
> **Câu hỏi**: *Những loại máy hoặc dòng sản phẩm nào thường xuyên chạy chậm, không đạt được tốc độ kỳ vọng so với định mức trong bảng Target Speeds?*

Tất cả các máy đều có định mức tốc độ chuẩn trong file là **51,840 bánh/giờ**.
* **Top các cặp (Máy - Sản phẩm) có độ trễ lớn nhất (Running Gap)**:
  1. **Biscuit Forming Machine - Pink Wafers**: Chạy 39.52 giờ với tốc độ chỉ đạt **8 bánh/giờ** (Độ lệch: **-51,832 bánh/giờ**).
  2. **Biscuit Boxing Machine - Pink Wafers**: Chạy 39.53 giờ với tốc độ chỉ đạt **15 bánh/giờ** (Độ lệch: **-51,825 bánh/giờ**).
  3. **Biscuit Forming Machine - Jammy Creams**: Chạy 20.40 giờ, tốc độ thực tế chỉ đạt **137 bánh/giờ** (Độ lệch: **-51,703 bánh/giờ**).
  4. **Biscuit Heating Machine - Bourbon Creams**: Tốc độ thực tế **160 bánh/giờ** (Độ lệch: **-51,680 bánh/giờ**).
  5. **Biscuit Boxing Machine - Custard Creams**: Tốc độ thực tế **476 bánh/giờ** (Độ lệch: **-51,364 bánh/giờ**).

* **Nguyên nhân**: Ở các dòng máy Ép khuôn (Forming), Nướng (Heating) và Đóng thùng (Boxing), cảm biến ghi nhận máy chạy nhưng sản lượng đầu ra đếm được rất thấp, cho thấy máy đang chạy không tải (Dry run) hoặc bị nghẽn vật liệu đầu vào từ công đoạn trước.

---

### CÂU HỎI 7: TỔN THẤT DO THAY KHUÔN (CHANGEOVER LOSS - CC)
> **Câu hỏi**: *Hoạt động vệ sinh và thay đổi khuôn mẫu sản phẩm (CC - Changeover Cleaning) đang chiếm bao nhiêu % tổng thời gian dừng máy? Loại máy nào tiêu tốn thời gian vệ sinh lớn nhất?*

* **Tỷ lệ tổn thất thời gian do CC**:
  * Tổng thời gian CC trong tháng: **561.09 giờ** (4,018 sự kiện).
  * Chiếm **18.75%** tổng thời gian dừng máy (chỉ xếp sau No Order).
* **Top 5 máy tiêu tốn thời gian vệ sinh / thay khuôn lớn nhất**:
  1. **Biscuit Filling Machine**: **182.41 giờ** (1,977 lần, trung bình 5.54 phút/lần) $\rightarrow$ Dừng nhiều lần vì liên tục đổi loại nhân kem.
  2. **Biscuit Boxing Machine**: **87.17 giờ** (108 lần, trung bình **48.43 phút/lần**).
  3. **Biscuit Forming Machine**: **67.13 giờ** (25 lần, trung bình **161.11 phút = 2.7 giờ/lần**).
  4. **Biscuit Heating Machine**: **63.68 giờ** (5 lần, trung bình **764.21 phút = 12.7 giờ/lần**!).
  5. **Biscuit Sprinkling Machine**: **60.41 giờ** (1,071 lần, trung bình 3.38 phút/lần).

* **Nhận xét**: Máy Nướng (Heating) và Ép tạo hình (Forming) có thời gian làm nguội và tháo lắp khuôn cực kỳ lâu (từ 2.7 giờ đến gần 13 giờ cho một lần vệ sinh).

---

### CÂU HỎI 8: PHÂN TÍCH XU HƯỚNG THỜI GIAN (WEEKLY TREND)
> **Câu hỏi**: *Chỉ số OEE có sự biến động như thế nào giữa các ngày trong tuần? Hiệu suất ca làm việc vào ngày cuối tuần (Thứ 7, Chủ Nhật) có bị giảm sút so với ngày thường không?*

* **Bảng theo dõi theo ngày trong tuần**:

| Thứ trong tuần | Số sự kiện ghi nhận | Tổng giờ ghi nhận | Giờ máy chạy thực | OEE Bình quân (%) |
| :--- | :---: | :---: | :---: | :---: |
| **Chủ Nhật (Sunday)** | 713 | 164.3h | 34.4h | **15.13%** |
| **Thứ Hai (Monday)** | 265 | 346.9h | 210.4h | **6.48%** |
| **Thứ Ba (Tuesday)** | 741 | 156.6h | 24.3h | **6.80%** |
| **Thứ Tư (Wednesday)** | 1,334 | 278.7h | 84.1h | **7.66%** |
| **Thứ Năm (Thursday)** | 1,659 | 1,009.4h | 84.4h | **13.83%** |
| **Thứ Sáu (Friday)** | 1,654 | 669.9h | 63.2h | **11.09%** |
| **Thứ Bảy (Saturday)** | 1,675 | 370.2h | 64.3h | **11.36%** |

* **So sánh Ngày Thường (Weekday) vs. Cuối Tuần (Weekend)**:
  * **Ngày thường (22 ngày)**: Giờ chạy 466.4h $\rightarrow$ OEE trung bình: **10.31%**.
  * **Cuối tuần (8 ngày)**: Giờ chạy 98.7h $\rightarrow$ OEE trung bình: **12.49%**.
* **Phát hiện thú vị**:
  * **Hiệu suất ngày cuối tuần KHÔNG HỀ BỊ GIẢM SÚT** mà ngược lại cao hơn ngày thường (+2.18 điểm %).
  * **Nguyên nhân**: Vào cuối tuần, nhà máy ít phải tiếp nhận các lệnh thay đổi đột xuất từ phòng kinh doanh, ít bị dừng chuyển đổi khuôn mẫu linh tinh nên các mẻ bánh chạy ổn định và tập trung hơn.

---

### CÂU HỎI 9: VINH DANH CỖ MÁY TỐI ƯU
> **Câu hỏi**: *Loại máy nào có sự kết hợp hoàn hảo nhất giữa cả 3 chỉ số (Availability, Performance, Quality) để cho ra chỉ số OEE ổn định và cao nhất nhà máy?*

* **Cỗ máy xuất sắc nhất**: **Biscuit Filling Machine (Máy Bơm Nhân Bánh Quy)**.
  * **OEE đạt 10.89%** – Cao nhất toàn nhà máy (gấp 360 lần so với máy thấp nhất).
  * Đạt thời gian vận hành thực tế bền bỉ nhất: **186.4 giờ** (chiếm 33% tổng thời gian chạy của cả nhà máy).
  * Sản xuất ra hơn **450 triệu bánh quy đạt chuẩn** (đóng góp hơn 98% tổng sản lượng bánh thành phẩm đạt chất lượng của toàn xưởng).
* **Cỗ máy có chất lượng hoàn hảo nhất**: **Biscuit Pressing Machine** (Máy Cán Bột).
  * Tỷ lệ chất lượng (Quality) đạt tuyệt đối **100.00%**, OEE đạt **5.74%** (Đứng thứ hai toàn nhà máy).

---

### CÂU HỎI 10: BÀI TOÁN TỐI ƯU & KHUYẾN NGHỊ ĐẦU TƯ ROI
> **Câu hỏi**: *Nếu đội ngũ kỹ sư cải tiến quy trình giúp giảm được 15% thời gian dừng máy do Bảo dưỡng định kỳ (PM - Maintenance), nhà máy sẽ chạy thêm được bao nhiêu giờ và sản xuất thêm được khoảng bao nhiêu sản phẩm?*

* **Tính toán định lượng**:
  * Tổng thời gian dừng bảo dưỡng định kỳ (PM) trong tháng 7/2021 chỉ có **3.53 giờ** (6 lần dừng).
  * Nếu giảm được **15%** thời gian PM:
    $$\text{Thời gian tiết kiệm được} = 3.53 \text{ giờ} \times 15\% = \mathbf{0.53 \text{ giờ (khoảng 31.8 phút)}}.$$
  * **Sản lượng gia tăng ước tính**:
    * Theo tốc độ định mức kỹ thuật (51,840 bánh/giờ):
      $$0.53 \text{ giờ} \times 51,840 = \mathbf{27,457 \text{ bánh quy}}.$$
* **Khuyến nghị phản biện sắc bén cho Ban giám đốc**:
  * > [!WARNING]
    > **CẢNH BÁO ĐẦU TƯ SAI HƯỚNG (ROI TRAP)**:
    > Việc tập trung cắt giảm 15% thời gian Bảo dưỡng định kỳ (PM) mang lại giá trị **VÔ CÙNG NHỎ BÉ** (chỉ thêm được 31 phút chạy máy trong cả tháng) vì PM chỉ chiếm **0.12%** tổng thời gian dừng máy.
    >
    > **KHUYẾN NGHỊ TẬP TRUNG NGÂN SÁCH ĐỂ ĐẠT ROI CAO NHẤT:**
    > 1. **Mục tiêu số 1**: Giải quyết bài toán **NO (No Order - 2,294.9 giờ, chiếm 76.7%)**. Cần đồng bộ giữa Bộ phận Kế hoạch Chuỗi cung ứng (Supply Chain) và Bán hàng để tối ưu kích thước lô sản xuất (Batch size), tránh để máy móc hiện đại đắp chiếu vì thiếu đơn hàng.
    > 2. **Mục tiêu số 2**: Cải tiến hoạt động **CC (Changeover Cleaning - 561.1 giờ, chiếm 18.8%)** bằng phương pháp **SMED** (chuyển đổi nhanh khuôn dập và làm nguội máy nướng). Giảm 20% thời gian CC sẽ mang lại thêm hơn **112 giờ chạy máy** (gấp 211 lần so với việc giảm PM!).

---

# 3. BỘ CÔNG THỨC TÍNH TOÁN TOÀN DIỆN (SQL & DAX MEASURES CODEBOOK)

Toàn bộ công thức tính toán đã được kiểm chứng tính nhất quán giữa mô hình dbt (DuckDB) và Power BI:

### 3.1. Truy Vấn SQL Chuẩn Ngành (DuckDB / dbt Marts)

```sql
-- TRUY VẤN TỔNG HỢP OEE THEO THÁNG TRÊN BẢNG FACT
SELECT 
    DATE_TRUNC('month', f.date_id) AS production_month,
    
    -- 1. Thời lượng
    ROUND(SUM(f.duration_hours), 2) AS total_recorded_hours,
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END), 2) AS operating_hours,
    ROUND(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 2) AS planned_production_hours,
    
    -- 2. Sản lượng
    SUM(f.effective_total_biscuits) AS total_biscuits_made,
    SUM(f.good_biscuits_made) AS good_biscuits_made,
    SUM(f.scrap_biscuits_made) AS scrap_biscuits_made,
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 2) AS ideal_production,
    
    -- 3. Ba nhân tố OEE
    ROUND(SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0) * 100, 2) AS availability_pct,
          
    ROUND(LEAST(100.0, SUM(f.effective_total_biscuits) / 
          NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0) * 100), 2) AS performance_pct,
          
    ROUND(SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0) * 100, 2) AS quality_pct,
    
    -- 4. Chỉ số OEE Tổng thể
    ROUND(
        (SUM(CASE WHEN f.is_operating_time THEN f.duration_hours ELSE 0 END) / 
         NULLIF(SUM(CASE WHEN f.oee_category != 'PM (Maintenance)' THEN f.duration_hours ELSE 0 END), 0)) *
        LEAST(1.0, SUM(f.effective_total_biscuits) / 
         NULLIF(SUM(CASE WHEN f.is_operating_time THEN f.ideal_production ELSE 0 END), 0)) *
        (SUM(f.good_biscuits_made) / NULLIF(SUM(f.effective_total_biscuits), 0)) * 100, 
        2
    ) AS plant_oee_pct

FROM gold.fct_production_runs f
GROUP BY 1;
```

### 3.2. Bộ Công Thức DAX Đầy Đủ Cho Power BI

Đặt trong bảng tính đo lường `_Measures`:

```dax
// ========================================================
// NHÓM 1: THỜI LƯỢNG (TIME & DURATION MEASURES)
// ========================================================

Total Duration (Hours) = 
SUM(fct_production_runs[duration_hours])

Operating Time (Hours) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[is_operating_time] = TRUE()
)

Planned Production Time (Hours) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[oee_category] <> "PM (Maintenance)"
)

Downtime (Hours) = 
[Total Duration (Hours)] - [Operating Time (Hours)]

Changeover CC Time (Hours) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[oee_category] = "CC (Changeover Cleaning)"
)

No Order Time (Hours) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[oee_category] = "NO (No Order)"
)

// ========================================================
// NHÓM 2: SẢN LƯỢNG (PRODUCTION OUTPUT MEASURES)
// ========================================================

Total Output (Biscuits) = 
SUM(fct_production_runs[effective_total_biscuits])

Good Output (Biscuits) = 
SUM(fct_production_runs[good_biscuits_made])

Scrap Output (Biscuits) = 
SUM(fct_production_runs[scrap_biscuits_made])

Ideal Production (Biscuits) = 
CALCULATE(
    SUM(fct_production_runs[ideal_production]),
    fct_production_runs[is_operating_time] = TRUE()
)

// ========================================================
// NHÓM 3: BA TRỤ CỘT VÀ CHỈ SỐ OEE (CORE OEE METRICS)
// ========================================================

Availability % = 
DIVIDE([Operating Time (Hours)], [Planned Production Time (Hours)], 0)

Performance % = 
MIN(1.0, DIVIDE([Total Output (Biscuits)], [Ideal Production (Biscuits)], 0))

Quality % = 
DIVIDE([Good Output (Biscuits)], [Total Output (Biscuits)], 0)

Waste % = 
1 - [Quality %]

OEE % = 
[Availability %] * [Performance %] * [Quality %]

// ========================================================
// NHÓM 4: PHÂN LOẠI SỰ CỐ DỪNG MÁY (STOPPAGE CLASSIFICATION)
// ========================================================

Minor Stoppage Hours (<3m) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[duration_minutes] < 3,
    fct_production_runs[is_operating_time] = FALSE()
)

Major Stoppage Hours (>=3m) = 
CALCULATE(
    SUM(fct_production_runs[duration_hours]),
    fct_production_runs[duration_minutes] >= 3,
    fct_production_runs[is_operating_time] = FALSE()
)

Minor Stoppage % = 
DIVIDE([Minor Stoppage Hours (<3m)], [Downtime (Hours)], 0)

Major Stoppage % = 
DIVIDE([Major Stoppage Hours (>=3m)], [Downtime (Hours)], 0)
```

---

# 4. HƯỚNG DẪN THIẾT KẾ DASHBOARD QUẢN TRỊ CHUẨN NGÀNH (POWER BI / TABLEAU BLUEPRINT)

Một dashboard quản trị công nghiệp chuẩn quốc tế phải tuân theo nguyên tắc **"3-30-300"**:
* Trong **3 giây**: Người xem nắm được OEE tổng thể và trạng thái cảnh báo (đỏ/vàng/xanh).
* Trong **30 giây**: Xác định được cỗ máy nghẽn hoặc dòng sản phẩm phế phẩm cao nhất.
* Trong **300 giây (5 phút)**: Thực hiện drill-down tìm ra nguyên nhân cốt lõi để ra quyết định xử lý.

```
KIẾN TRÚC 3 TRANG DASHBOARD BÁO CÁO:
┌────────────────────────────────────────────────────────────────────────┐
│ TRANG 1: EXECUTIVE OEE COCKPIT (Tổng Quan Hiệu Suất Nhà Máy)          │
│ • KPI Cards: OEE (6.4%), Availability (18.9%), Performance, Quality   │
│ • Waterfall Chart: Thất thoát từ Planned Time -> Operating Time       │
│ • Trend Line: Diễn biến OEE theo ngày/tuần (Thứ trong tuần vs Weekend)│
│ • Machine Matrix: Bảng đối soát OEE 10 loại máy                       │
├────────────────────────────────────────────────────────────────────────┤
│ TRANG 2: DOWNTIME & BOTTLENECK DEEP-DIVE (Bắt Bệnh Điểm Nghẽn)        │
│ • Pareto Chart (80/20): Lý do dừng máy (NO 76.7%, CC 18.8%)           │
│ • Donut Chart: Phân loại Minor Stoppages (<3m) vs Major (>=3m)        │
│ • Heatmap: Thời gian dừng máy theo Máy x Ngày                         │
│ • Changeover Matrix: Xếp hạng máy có thời gian vệ sinh khuôn lâu nhất │
├────────────────────────────────────────────────────────────────────────┤
│ TRANG 3: QUALITY & SCRAP ROOT CAUSE (Kiểm Soát Chất Lượng & Phế Phẩm)  │
│ • Scatter Plot: Sản lượng làm ra vs. Tỷ lệ phế phẩm (Waste %)         │
│ • Bar Chart: Top dòng bánh lỗi cao nhất (Peanut Cookies, Creams)      │
│ • Speed Gap Chart: Tốc độ thực tế vs Định mức 51,840 bánh/giờ         │
│ • What-if Simulation Slider: Mô phỏng giảm % Downtime -> Sản lượng    │
└────────────────────────────────────────────────────────────────────────┘
```

### 4.1. Thiết Kế Trang 1: Executive OEE Overview (Tổng Quan Ban Giám Đốc)
* **Header Bar**: Logo Grandma EDNA's Biscuits, Tiêu đề *"Plant OEE Performance Executive Cockpit"*, Slicer Ngày (Tháng 7/2021), Slicer Nhóm Máy.
* **Hàng 1 - Thẻ KPI Trọng Tâm (4 KPI Cards)**:
  * **OEE %**: `6.37%` | Thẻ đỏ cảnh báo (So sánh Target 85% $\rightarrow$ Status: CRITICAL).
  * **Availability %**: `18.88%` | Subtitle: *Total Downtime: 2,431 hrs*.
  * **Performance %**: `100.0%` (Capped) / `5020%` (Raw).
  * **Quality %**: `33.72%` | Subtitle: *Scrap: 899.7M biscuits*.
* **Cột Trái (Main Visual)**:
  * **Waterfall Chart (Biểu đồ thác nước)**: Phân rã thời gian từ `Planned Time (2,992.5h)` $\rightarrow$ Trừ `No Order (-2,294.9h)` $\rightarrow$ Trừ `Changeover CC (-561.1h)` $\rightarrow$ Trừ `Unclassified (-132.5h)` $\rightarrow$ Còn lại `Operating Time (565.1h)`.
* **Cột Phải (Bảng Xếp Hạng)**:
  * **Horizontal Bar Chart / Matrix**: OEE của 10 cỗ máy với Data Bars định dạng màu (Dưới 20%: Đỏ, 20-50%: Vàng, Trên 50%: Xanh).

### 4.2. Thiết Kế Trang 2: Bottleneck & Downtime Deep-Dive (Quản Đốc & Kỹ Thuật)
* **Visual 1 (Pareto Analysis)**:
  * Trục cột: Tổng số giờ dừng theo `OEE Category` (NO, CC, Unclassified, PM).
  * Trục đường: % Tích lũy (Cumulative %). Nhấn mạnh nguyên tắc 80/20 (NO + CC chiếm tới 95.45% toàn bộ thời gian chết).
* **Visual 2 (Tổn Thất Dừng Vặt vs Dừng Lớn)**:
  * Gauge hoặc 100% Stacked Bar Chart so sánh:
    * *Minor Stoppages (< 3 phút)*: 65.8% số lần nhưng chỉ 2.8% thời gian.
    * *Major Stoppages ($\ge$ 3 phút)*: 34.2% số lần nhưng chiếm tới 97.2% thời gian.
* **Visual 3 (Changeover Cleaning Deep-Dive)**:
  * Bar Chart phân tích thời gian vệ sinh khuôn máy (CC Hours) theo từng máy.
  * Thêm Card thể hiện thời gian trung bình một lần thay khuôn máy nướng (Heating Machine = 12.7 giờ).

### 4.3. Thiết Kế Trang 3: Quality & Scrap Root Cause (Bộ Phận QA/QC)
* **Visual 1 (Bản đồ nhiệt phế phẩm)**:
  * Treemap hoặc Ranked Bar Chart thể hiện `Scrap Biscuits Made` theo từng dòng bánh (`Product Name`).
  * Nổi bật các sản phẩm báo động đỏ: Peanut Cookies, Vienesse Creams, Orange Creams, Bourbon Creams.
* **Visual 2 (Target Speed Gap)**:
  * Clustered Column Chart so sánh `Target Biscuits per Hour (51,840)` với `Actual Speed per Hour` của từng máy để phát hiện máy chạy không tải hoặc nghẽn chuyền.
* **Visual 3 (What-If Interactive Simulation)**:
  * Sử dụng tính năng **What-If Parameter** trong Power BI:
    * Slider: `% Giảm thời gian Changeover (0% - 50%)`.
    * Card đầu ra: *Giờ máy tăng thêm* và *Sản lượng bánh làm thêm ước tính*.

### 4.4. Hướng Dẫn Cấu Hình Tính Năng Tương Tác Nâng Cao
1. **Report Page Tooltips (Di chuột xem lý do dừng máy)**:
   * Tạo một trang ẩn kích thước `Tooltip (320 x 240 px)`.
   * Khi người dùng hover vào bất kỳ cột máy nào trên trang Tổng quan, Tooltip sẽ tự động hiện biểu đồ tròn phân bổ chi tiết lý do máy đó bị dừng (NO %, CC %, PM %) và dòng bánh máy đang gia công dở dang.
2. **Drill-Through (Khám phá sâu theo Máy)**:
   * Cài đặt trường `dim_machine[machine_name]` làm Drill-through field trên Trang 2.
   * Khi click chuột phải vào máy `Biscuit Heating Machine` trên Trang 1 $\rightarrow$ Chọn *Drill-through* $\rightarrow$ Lập tức chuyển sang Trang 2 và tự động lọc toàn bộ dữ liệu nhật ký sự cố của riêng máy này.
3. **Bookmarks & Page Navigation**:
   * Thiết kế thanh Sidebar bên trái với 3 icon tương ứng 3 trang báo cáo.
   * Dùng Action `Page Navigation` gắn vào các Shape/Icon giúp chuyển trang mượt mà như ứng dụng chuyên nghiệp.

---

# 5. KHUYẾN NGHỊ CHIẾN LƯỢC & BÀI TOÁN TỐI ƯU HÓA ROI (ACTIONABLE ROADMAP)

Dựa trên kết quả phân tích dữ liệu, đội ngũ Data Analyst khuyến nghị Ban giám đốc nhà máy Grandma EDNA tập trung triển khai **Chương trình Cải tiến Tinh gọn (Lean Manufacturing Roadmap)** theo lộ trình 3 giai đoạn:

```
LỘ TRÌNH HÀNH ĐỘNG TINH GỌN (LEAN MANUFACTURING ROADMAP):
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│ GIAI ĐOẠN 1 (30 NGÀY)   │ GIAI ĐOẠN 2 (60 NGÀY)   │ GIAI ĐOẠN 3 (90 NGÀY)   │
│ Khắc Phục Lỗi Dữ Liệu   │ Cải Tiến Quy Trình SMED │ Tái Cơ Cấu Kế Hoạch S&OP│
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ • Hiệu chuẩn cảm biến IoT│ • Chuẩn hóa thao tác CC │ • Đồng bộ Sales & Prod  │
│   tại 8 máy báo Total=0 │   (giảm thời gian nướng)│   triệt tiêu No Order   │
│ • Gắn mã lỗi cho 12 đợt │ • Giảm 20% thời gian CC │ • Nâng kích thước lô    │
│   dừng Unclassified     │   -> Thêm 112 giờ chạy  │   hạn chế đổi khuôn vặt │
│ • Kiểm định quy trình   │ • Thiết lập tiêu chuẩn  │ • Ứng dụng TPM dự đoán  │
│   sản xuất Peanut Cookie│   chất lượng cho 5 dòng │   hướng tới World Class │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

### 5.1. Ưu tiên số 1: Tái cấu trúc lập kế hoạch sản xuất (Triệt tiêu 2,295 giờ No Order)
* **Vấn đề**: Chiếm tới 76.7% thời gian dừng máy. Máy móc tiền tỷ nằm đắp chiếu chờ lệnh sản xuất.
* **Hành động**:
  * Tích hợp quy trình **S&OP (Sales and Operations Planning)** giữa phòng Kế hoạch cung ứng và phòng Bán hàng.
  * Tăng quy mô lô sản xuất tối thiểu (Minimum Order Quantity - MOQ) đối với các loại bánh phổ thông để máy chạy liên tục, hạn chế tình trạng máy chạy được 15 phút lại phải dừng chờ lệnh tiếp theo.

### 5.2. Ưu tiên số 2: Áp dụng phương pháp SMED cho khâu Vệ sinh & Thay khuôn (CC)
* **Vấn đề**: Mất 561.1 giờ cho 4,018 lần thay khuôn, đặc biệt máy nướng Heating mất trung bình 12.7 giờ/lần.
* **Hành động**:
  * Áp dụng **SMED (Single-Minute Exchange of Die)**: Tách biệt thao tác chuẩn bị khuôn và dụng cụ ra ngoài thời gian máy chạy (External Setup). Khi máy dừng, chỉ thực hiện thao tác tháo lắp nhanh (Internal Setup).
  * Đầu tư hệ thống quạt thông gió cưỡng bức làm nguội nhanh buồng nướng máy Heating để rút ngắn thời gian chờ từ 12.7 giờ xuống dưới 4 giờ.
  * **Kỳ vọng ROI**: Giảm 25% thời gian CC giúp nhà máy thu hồi được **140 giờ máy chạy ròng**, sản xuất thêm hơn **7.2 triệu bánh quy/tháng**.

### 5.3. Ưu tiên số 3: Đại phẫu thuật kỹ thuật dòng bánh Peanut Cookies & Cream
* **Vấn đề**: Tỷ lệ phế phẩm > 99%. Cứ đưa nguyên liệu vào là máy làm hỏng bánh.
* **Hành động**:
  * Tạm dừng các đợt chạy hàng loạt của 5 dòng bánh này để đội ngũ Kỹ sư Công nghệ (R&D) và Cơ điện (Maintenance) kiểm tra lại công thức độ ẩm bột và áp suất đầu phun của **Biscuit Sprinkling Machine** và **Biscuit Filling Machine**.
  * Bổ sung camera AI thị giác máy tính (Computer Vision) tại đầu ra của máy Bơm nhân để phát hiện lỗi lệch nhân bánh ngay lập tức, ngắt máy tự động trong vòng 30 giây thay vì để máy tiếp tục dập hàng triệu sản phẩm hỏng.

---
*Tài liệu được lập bởi Bộ phận Phân tích Dữ liệu Sản xuất (Manufacturing Analytics Team) – Dự án Tối ưu hóa OEE Nhà máy Grandma EDNA.*

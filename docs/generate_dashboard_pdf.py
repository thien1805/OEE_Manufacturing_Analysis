import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas

# 1. Đăng ký Font chữ Arial hỗ trợ 100% tiếng Việt
pdfmetrics.registerFont(TTFont('Arial', '/System/Library/Fonts/Supplemental/Arial.ttf'))
pdfmetrics.registerFont(TTFont('Arial-Bold', '/System/Library/Fonts/Supplemental/Arial Bold.ttf'))
pdfmetrics.registerFont(TTFont('Arial-Italic', '/System/Library/Fonts/Supplemental/Arial Italic.ttf'))
pdfmetrics.registerFont(TTFont('Arial-BoldItalic', '/System/Library/Fonts/Supplemental/Arial Bold Italic.ttf'))

pdfmetrics.registerFontFamily(
    'Arial',
    normal='Arial',
    bold='Arial-Bold',
    italic='Arial-Italic',
    boldItalic='Arial-BoldItalic'
)

# 2. Canvas tự động đánh số trang (NumberedCanvas)
class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Arial", 8)
        self.setFillColor(colors.HexColor("#718096"))
        
        # Header (từ trang 2)
        if self._pageNumber > 1:
            self.drawString(54, A4[1] - 36, "OEE MANUFACTURING DASHBOARD BLUEPRINT & TECHNICAL SPECIFICATION")
            self.setStrokeColor(colors.HexColor("#CBD5E0"))
            self.setLineWidth(0.75)
            self.line(54, A4[1] - 42, A4[0] - 54, A4[1] - 42)
            
        # Footer
        self.setStrokeColor(colors.HexColor("#CBD5E0"))
        self.setLineWidth(0.75)
        self.line(54, 45, A4[0] - 54, 45)
        self.drawString(54, 32, "Confidential - OEE Manufacturing Analysis Project (DuckDB / dbt / Power BI)")
        page_text = f"Trang {self._pageNumber} / {page_count}"
        self.drawRightString(A4[0] - 54, 32, page_text)
        self.restoreState()

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()
    
    # Bảng màu chuẩn
    c_primary = colors.HexColor("#1A365D")   # Deep Navy
    c_secondary = colors.HexColor("#2B6CB0") # Slate Blue
    c_dark = colors.HexColor("#2D3748")      # Charcoal Body Text
    c_red = colors.HexColor("#C53030")       # Dark Red
    c_amber = colors.HexColor("#DD6B20")     # Amber Orange
    c_green = colors.HexColor("#2F855A")     # Emerald Green
    c_bg_light = colors.HexColor("#F7FAFC")  # Very Light Gray

    # Typography Styles
    title_style = ParagraphStyle(
        'DocTitle',
        fontName='Arial-Bold',
        fontSize=20,
        leading=25,
        textColor=c_primary,
        spaceAfter=6
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        fontName='Arial',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#4A5568"),
        spaceAfter=14
    )
    
    meta_style = ParagraphStyle(
        'DocMeta',
        fontName='Arial-Italic',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor("#718096")
    )
    
    h1_style = ParagraphStyle(
        'Heading1_Custom',
        fontName='Arial-Bold',
        fontSize=13,
        leading=17,
        textColor=c_primary,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    
    h2_style = ParagraphStyle(
        'Heading2_Custom',
        fontName='Arial-Bold',
        fontSize=10.5,
        leading=14,
        textColor=c_secondary,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        fontName='Arial',
        fontSize=9,
        leading=13.5,
        textColor=c_dark,
        spaceAfter=5
    )

    body_bold = ParagraphStyle(
        'Body_Bold_Custom',
        fontName='Arial-Bold',
        fontSize=9,
        leading=13.5,
        textColor=c_dark
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        fontName='Arial',
        fontSize=9,
        leading=13.5,
        textColor=c_dark,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=3
    )

    callout_style = ParagraphStyle(
        'Callout_Text',
        fontName='Arial',
        fontSize=8.5,
        leading=13,
        textColor=colors.HexColor("#1A202C")
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Arial-Bold',
        fontSize=8.5,
        leading=11,
        textColor=colors.white,
        alignment=1 # Center
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Arial',
        fontSize=8,
        leading=11,
        textColor=c_dark
    )

    table_cell_center = ParagraphStyle(
        'TableCellCenter',
        fontName='Arial',
        fontSize=8,
        leading=11,
        textColor=c_dark,
        alignment=1
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        fontName='Arial-Bold',
        fontSize=8,
        leading=11,
        textColor=c_dark
    )

    code_style = ParagraphStyle(
        'CodeStyle',
        fontName='Arial',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor("#2C5282")
    )

    story = []

    # =========================================================================
    # HEADER & TRANG BÌA
    # =========================================================================
    story.append(Paragraph("TÀI LIỆU ĐẶC TẢ THIẾT KẾ OEE DASHBOARD", title_style))
    story.append(Paragraph("Manufacturing Performance & Root Cause Analysis - Plant Overview (Tháng 07/2021)", subtitle_style))
    
    meta_text = "<b>Dự án:</b> OEE Manufacturing Analysis &nbsp;|&nbsp; <b>Nền tảng:</b> DuckDB &bull; dbt &bull; Power BI &bull; Excel &nbsp;|&nbsp; <b>Ngày ban hành:</b> Tháng 10/2026"
    story.append(Paragraph(meta_text, meta_style))
    story.append(Spacer(1, 8))
    story.append(HRFlowable(width="100%", thickness=2, color=c_primary, spaceBefore=2, spaceAfter=14))

    # =========================================================================
    # 1. TỔNG QUAN ĐIỀU HÀNH & HIỆN TRẠNG NHÀ MÁY
    # =========================================================================
    story.append(Paragraph("1. TỔNG QUAN ĐIỀU HÀNH & BỨC TRANH SỨC KHỎE NHÀ MÁY", h1_style))
    story.append(Paragraph(
        "Dự án phân tích hiệu suất thiết bị tổng thể (OEE) cho toàn bộ nhà máy sản xuất bánh quy trong tháng 07/2021. "
        "Mô hình dữ liệu được làm sạch qua kho dữ liệu <b>DuckDB + dbt</b> và trực quan hóa toàn diện. Dưới đây là 6 chỉ số cốt tử:",
        body_style
    ))

    # Bảng 6 KPI Cards
    kpi_data = [
        [
            Paragraph("<b>PLANT OEE</b>", table_header_style),
            Paragraph("<b>AVAILABILITY (A)</b>", table_header_style),
            Paragraph("<b>PERFORMANCE (P)</b>", table_header_style),
            Paragraph("<b>QUALITY (Q)</b>", table_header_style),
            Paragraph("<b>TOTAL DOWNTIME</b>", table_header_style),
            Paragraph("<b>TOTAL SCRAP</b>", table_header_style)
        ],
        [
            Paragraph("<font size=13 color='#C53030'><b>6.37%</b></font><br/><font size=7 color='#718096'>Target: 85.0%</font>", table_cell_center),
            Paragraph("<font size=13 color='#C53030'><b>18.89%</b></font><br/><font size=7 color='#718096'>Target: 90.0%</font>", table_cell_center),
            Paragraph("<font size=13 color='#2F855A'><b>100.00%</b></font><br/><font size=7 color='#718096'>Target: 95.0%</font>", table_cell_center),
            Paragraph("<font size=13 color='#C53030'><b>33.72%</b></font><br/><font size=7 color='#718096'>Target: 99.0%</font>", table_cell_center),
            Paragraph("<font size=13 color='#DD6B20'><b>2,992.0 h</b></font><br/><font size=7 color='#718096'>8,032 lần dừng</font>", table_cell_center),
            Paragraph("<font size=13 color='#C53030'><b>899.7 M</b></font><br/><font size=7 color='#718096'>Hàng hủy: 66.3%</font>", table_cell_center)
        ]
    ]
    t_kpi = Table(kpi_data, colWidths=[81, 81, 81, 81, 81, 83])
    t_kpi.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('BOTTOMPADDING', (0,0), (-1,0), 5),
        ('TOPPADDING', (0,0), (-1,0), 5),
        ('BACKGROUND', (0,1), (-1,1), c_bg_light),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,1), (-1,1), 8),
        ('BOTTOMPADDING', (0,1), (-1,1), 8),
    ]))
    story.append(t_kpi)
    story.append(Spacer(1, 10))

    # Ba phát hiện cốt lõi
    story.append(Paragraph("<b>Ba điểm nghẽn nghiêm trọng nhất cần tháo gỡ ngay:</b>", body_bold))
    story.append(Paragraph("&bull; <b>Tổn thất Khả dụng (Availability = 18.89%):</b> Nhà máy lãng phí tới <b>2,992 giờ dừng máy</b>. Trong đó, riêng 2 trạng thái <b>Thiếu đơn hàng (NO) chiếm 76.7%</b> và <b>Vệ sinh/thay khuôn (CC) chiếm 18.8%</b> đã cấu thành nên <b>95.5%</b> tổng thời gian chết toàn xưởng.", bullet_style))
    story.append(Paragraph("&bull; <b>Tổn thất Chất lượng (Quality = 33.72%):</b> Có tới <b>899.7 triệu chiếc bánh</b> bị phế phẩm (Scrap rate 66.28%). Đáng kinh ngạc, <b>100% phế phẩm chỉ phát sinh tại đúng 2 cỗ máy</b>: Máy kẹp kem <i>Biscuit Filling Machine</i> (73.4% phế phẩm) và Máy rắc hạt <i>Biscuit Sprinkling Machine</i> (26.6% phế phẩm - tỷ lệ hỏng 99.8%). 8 cỗ máy còn lại đạt chất lượng 100%.", bullet_style))
    story.append(Paragraph("&bull; <b>Cỗ máy tối ưu (Quán quân OEE):</b> <i>Biscuit Filling Machine</i> đạt OEE cao nhất xưởng là <b>10.89%</b> (gấp đôi Á quân Pressing 5.74% và vượt trội hoàn toàn 8 máy còn lại đều dưới 1%), vận hành bền bỉ 29/31 ngày trong tháng.", bullet_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # 2. KIẾN TRÚC DASHBOARD PHÂN TẦNG (3-TIER ARCHITECTURE)
    # =========================================================================
    story.append(Paragraph("2. KIẾN TRÚC PHÂN TẦNG DASHBOARD (DÀNH CHO 3 CẤP QUẢN TRỊ)", h1_style))
    story.append(Paragraph(
        "Dashboard được thiết kế theo nguyên lý kim tự tháp <i>'Từ Tổng quan đến Chi tiết'</i> (Overview to Drill-down) để đáp ứng chuẩn xác nhu cầu ra quyết định của từng nhóm người dùng:",
        body_style
    ))

    arch_data = [
        [
            Paragraph("<b>Phân tầng Quản trị</b>", table_header_style),
            Paragraph("<b>Đối tượng sử dụng</b>", table_header_style),
            Paragraph("<b>Mục tiêu & Chức năng trọng tâm trên Dashboard</b>", table_header_style),
            Paragraph("<b>Hành động chiến lược</b>", table_header_style)
        ],
        [
            Paragraph("<b>TẦNG 1:<br/>EXECUTIVE SUMMARY</b>", table_cell_bold),
            Paragraph("Tổng Giám Đốc (CEO),<br/>Giám Đốc Nhà Máy", table_cell_style),
            Paragraph("&bull; 6 Thẻ KPI tổng quan sức khỏe toàn xưởng.<br/>&bull; Biểu đồ Pareto tổn thất 80/20 (NO vs CC).<br/>&bull; Xếp hạng OEE 10 cỗ máy.", table_cell_style),
            Paragraph("Tái cơ cấu kế hoạch bán hàng & gom lô sản xuất để giảm 76.7% thời gian thiếu đơn hàng (NO).", table_cell_style)
        ],
        [
            Paragraph("<b>TẦNG 2:<br/>OPERATIONAL DRILL-DOWN</b>", table_cell_bold),
            Paragraph("Quản Đốc Phân Xưởng,<br/>Trưởng Nhóm Sản Xuất", table_cell_style),
            Paragraph("&bull; Phân rã phế phẩm theo từng dòng bánh.<br/>&bull; So sánh OEE Ngày thường vs Cuối tuần.<br/>&bull; Soi chi tiết cỗ máy Quán quân và các điểm nghẽn.", table_cell_style),
            Paragraph("Áp dụng kỹ thuật tinh gọn SMED trên máy kẹp kem Filling để giảm 182h thay khuôn vệ sinh.", table_cell_style)
        ],
        [
            Paragraph("<b>TẦNG 3:<br/>MACHINE DEEP-DIVE & SIMULATION</b>", table_cell_bold),
            Paragraph("Giám Sát Máy, Kỹ Sư Bảo Trì,<br/>Kỹ Thuật Viên Cơ Điện", table_cell_style),
            Paragraph("&bull; Drillthrough trang chi tiết riêng từng máy.<br/>&bull; Phân tích Stoppages lớn (>= 3p) vs nhỏ (< 3p).<br/>&bull; Thanh trượt What-If Parameter mô phỏng cải tiến.", table_cell_style),
            Paragraph("Sửa chữa cảm biến máy rắc hạt Sprinkling; chấn chỉnh kỷ luật ghi nhận lỗi MES (xóa sổ mã 0).", table_cell_style)
        ]
    ]
    t_arch = Table(arch_data, colWidths=[100, 95, 175, 117])
    t_arch.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, c_bg_light]),
    ]))
    story.append(t_arch)
    story.append(Spacer(1, 14))

    # =========================================================================
    # 3. ĐẶC TẢ CHI TIẾT 4 KHUNG BIỂU ĐỒ CHIẾN LƯỢC
    # =========================================================================
    story.append(PageBreak()) # Chuyển sang Trang 2
    story.append(Paragraph("3. ĐẶC TẢ CHI TIẾT 4 KHUNG BIỂU ĐỒ CHIẾN LƯỢC", h1_style))
    story.append(Paragraph(
        "Bốn khung trực quan hóa này là trung tâm phân tích của Dashboard, cung cấp đầy đủ thông tin để định vị nguyên nhân gốc rễ:",
        body_style
    ))

    # Bảng 10 cỗ máy OEE
    story.append(Paragraph("<b>Khung 1: Xếp hạng OEE và Nhận diện Điểm nghẽn (Bottleneck & Machine Ranking)</b>", h2_style))
    story.append(Paragraph("<i>Loại visual: Clustered Bar Chart (Thanh ngang). Sắp xếp từ OEE cao nhất xuống thấp nhất.</i>", body_style))
    
    mach_data = [
        [
            Paragraph("<b>Tên Máy Móc (Machine)</b>", table_header_style),
            Paragraph("<b>Giờ Chạy (h)</b>", table_header_style),
            Paragraph("<b>Availability</b>", table_header_style),
            Paragraph("<b>Performance</b>", table_header_style),
            Paragraph("<b>Quality</b>", table_header_style),
            Paragraph("<b>OEE (%)</b>", table_header_style),
            Paragraph("<b>Đánh giá & Chẩn đoán</b>", table_header_style)
        ],
        [Paragraph("<b>Biscuit Filling Machine</b>", table_cell_bold), Paragraph("186.4 h", table_cell_center), Paragraph("26.64%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("40.88%", table_cell_center), Paragraph("<font color='#2F855A'><b>10.89%</b></font>", table_cell_center), Paragraph("🏆 <b>Quán quân</b> (Chạy bền bỉ 29/31 ngày)", table_cell_style)],
        [Paragraph("<b>Biscuit Pressing Machine</b>", table_cell_style), Paragraph("39.4 h", table_cell_center), Paragraph("35.53%", table_cell_center), Paragraph("16.17%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("<b>5.74%</b>", table_cell_center), Paragraph("🥈 <b>Á quân</b> (Chất lượng 100% hoàn hảo)", table_cell_style)],
        [Paragraph("Packaging Heat Machine", table_cell_style), Paragraph("3.5 h", table_cell_center), Paragraph("2.71%", table_cell_center), Paragraph("29.58%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.80%", table_cell_center), Paragraph("Máy chạy quá ít trong tháng", table_cell_style)],
        [Paragraph("Biscuit Jam Machine", table_cell_style), Paragraph("4.9 h", table_cell_center), Paragraph("6.28%", table_cell_center), Paragraph("10.66%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.67%", table_cell_center), Paragraph("Tốc độ chậm", table_cell_style)],
        [Paragraph("Biscuit Topping Machine", table_cell_style), Paragraph("0.2 h", table_cell_center), Paragraph("0.69%", table_cell_center), Paragraph("44.66%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.31%", table_cell_center), Paragraph("Vận hành chưa tới 1 giờ", table_cell_style)],
        [Paragraph("Biscuit Mixing Machine", table_cell_style), Paragraph("52.4 h", table_cell_center), Paragraph("9.62%", table_cell_center), Paragraph("2.26%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.22%", table_cell_center), Paragraph("Tốc độ trộn sụp đổ (< 3% định mức)", table_cell_style)],
        [Paragraph("Biscuit Boxing Machine", table_cell_style), Paragraph("87.2 h", table_cell_center), Paragraph("11.19%", table_cell_center), Paragraph("1.31%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.15%", table_cell_center), Paragraph("Tốc độ đóng thùng quá chậm", table_cell_style)],
        [Paragraph("Biscuit Sprinkling Machine", table_cell_style), Paragraph("60.4 h", table_cell_center), Paragraph("55.15%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("<font color='#C53030'>0.22%</font>", table_cell_center), Paragraph("0.12%", table_cell_center), Paragraph("🚨 <b>Cảm biến rắc hạt hỏng</b> (Phế phẩm 99.8%)", table_cell_style)],
        [Paragraph("Biscuit Forming Machine", table_cell_style), Paragraph("67.1 h", table_cell_center), Paragraph("19.82%", table_cell_center), Paragraph("0.41%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("0.08%", table_cell_center), Paragraph("Điểm nghẽn dập khuôn", table_cell_style)],
        [Paragraph("Biscuit Heating Machine", table_cell_style), Paragraph("63.7 h", table_cell_center), Paragraph("35.21%", table_cell_center), Paragraph("0.07%", table_cell_center), Paragraph("100.0%", table_cell_center), Paragraph("<font color='#C53030'><b>0.03%</b></font>", table_cell_center), Paragraph("🚨 <b>Đội sổ</b> (Chạy lò nướng nhưng không có bánh)", table_cell_style)],
    ]
    t_mach = Table(mach_data, colWidths=[120, 48, 55, 55, 52, 45, 112])
    t_mach.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 3.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, c_bg_light]),
    ]))
    story.append(t_mach)
    story.append(Spacer(1, 10))

    # Khung 2: Pareto Dừng máy
    story.append(Paragraph("<b>Khung 2: Biểu đồ Pareto Dừng Máy 80/20 (Downtime Root-Cause)</b>", h2_style))
    story.append(Paragraph("<i>Loại visual: Line and Clustered Column Chart (Cột: Giờ dừng | Đường: % Tích lũy).</i>", body_style))
    story.append(Paragraph("&bull; <b>NO (No Order):</b> Chiếm <b>2,294.9 giờ (76.7%)</b> với 3,996 lần dừng ➡️ Cần xử lý ở cấp Giám đốc Kế hoạch & Kinh doanh.", bullet_style))
    story.append(Paragraph("&bull; <b>CC (Changeover Cleaning):</b> Chiếm <b>561.1 giờ (18.8%)</b> với 4,018 lần dừng ➡️ Tần suất xuất hiện nhiều nhất xưởng, cần xử lý bằng kỹ thuật SMED.", bullet_style))
    story.append(Paragraph("&bull; <b>Quy luật 95.5%:</b> Chỉ 2 nguyên nhân NO và CC đã gây ra 95.5% thiệt hại dừng máy. Bảo dưỡng PM chỉ chiếm 3.53h (0.12%).", bullet_style))
    story.append(Spacer(1, 6))

    # Khung 3 & 4: Quality & Weekly Trend
    story.append(Paragraph("<b>Khung 3: Phân tích Chất lượng & Khủng hoảng Phế phẩm (Scrap Breakdown)</b>", h2_style))
    story.append(Paragraph("&bull; <b>Biscuit Filling Machine (660.5M bánh hỏng):</b> Phá hủy 367.5M bánh Bourbon Creams và 163.1M bánh Chocolate cookies do tràn/lệch kẹp kem.", bullet_style))
    story.append(Paragraph("&bull; <b>Biscuit Sprinkling Machine (239.2M bánh hỏng):</b> Tỷ lệ phế phẩm 99.8% trên Peanut Cookies (116.9M), Vienesse Creams (18.4M), Party Rings (17.7M)... do lỗi cảm biến/đầu phun hạt.", bullet_style))
    story.append(Spacer(1, 6))

    story.append(Paragraph("<b>Khung 4: Xu hướng Tuần & So sánh Cuối tuần (Weekly Run Trend)</b>", h2_style))
    story.append(Paragraph("&bull; <b>Đỉnh cao Thứ Hai (OEE = 19.91%):</b> Availability đạt tới 61.27% khi nhà máy dồn công suất chạy bù đầu tuần.", bullet_style))
    story.append(Paragraph("&bull; <b>Điểm trũng Thứ Tư (OEE = 2.82%):</b> Tỷ lệ chất lượng rớt thảm hại còn 9.36% do xếp lịch chạy bánh Peanut Cookies và Chocolate Digestives.", bullet_style))
    story.append(Paragraph("&bull; <b>Ngày thường (6.58%) vs. Cuối tuần (5.93%):</b> Cuối tuần OEE giảm nhẹ -0.65% do Chất lượng giảm từ 34.7% xuống 32.1% (Thứ 7 chạm đáy 4.81%, nhưng Chủ Nhật hồi phục tốt lên 9.49%).", bullet_style))
    story.append(Spacer(1, 14))

    # =========================================================================
    # 4. HƯỚNG DẪN KỸ THUẬT TRIỂN KHAI TRÊN POWER BI
    # =========================================================================
    story.append(PageBreak()) # Chuyển sang Trang 3
    story.append(Paragraph("4. QUY TRÌNH KỸ THUẬT TRIỂN KHAI TRÊN POWER BI", h1_style))
    story.append(Paragraph(
        "Quy trình từng bước để kết nối trực tiếp kho dữ liệu <b>my_factory.duckdb</b> và thiết lập mô hình Power BI hoàn chỉnh:",
        body_style
    ))

    tech_steps = [
        [
            Paragraph("<b>Bước</b>", table_header_style),
            Paragraph("<b>Công đoạn kỹ thuật</b>", table_header_style),
            Paragraph("<b>Chi tiết thao tác thực hiện</b>", table_header_style)
        ],
        [
            Paragraph("<b>1</b>", table_cell_center),
            Paragraph("<b>Cài DuckDB ODBC Driver</b>", table_cell_bold),
            Paragraph("Tải <i>duckdb_odbc-windows-amd64.zip</i> từ GitHub DuckDB ➡️ Chạy file <i>odbc_install.exe</i> quyền Admin để đăng ký driver vào Windows.", table_cell_style)
        ],
        [
            Paragraph("<b>2</b>", table_cell_center),
            Paragraph("<b>Cấu hình DSN</b>", table_cell_bold),
            Paragraph("Mở <i>ODBC Data Sources (64-bit)</i> ➡️ System DSN ➡️ Add <b>DuckDB Driver</b> ➡️ Đặt DSN Name: <b>DuckDB_Factory</b> ➡️ Trỏ Database tới file <i>my_factory.duckdb</i> ➡️ Thêm option: <i>access_mode=READ_ONLY</i> (tránh lock file DBeaver).", table_cell_style)
        ],
        [
            Paragraph("<b>3</b>", table_cell_center),
            Paragraph("<b>Kết nối Power BI</b>", table_cell_bold),
            Paragraph("Power BI Desktop ➡️ Get Data ➡️ ODBC ➡️ Chọn DSN <b>DuckDB_Factory</b> ➡️ Chọn schema <b>gold</b> ➡️ Tích chọn 4 bảng: <i>fct_production_runs, dim_machine, dim_product, dim_date</i> ➡️ Bấm <b>Transform Data</b>.", table_cell_style)
        ],
        [
            Paragraph("<b>4</b>", table_cell_center),
            Paragraph("<b>Power Query & Types</b>", table_cell_bold),
            Paragraph("Chuẩn hóa Data Types: <i>start_datetime</i> (Date/Time), <i>date_id</i> (Date), <i>duration_hours</i> (Decimal), các cột sản lượng (Whole Number). Bấm <b>Close & Apply</b>.", table_cell_style)
        ],
        [
            Paragraph("<b>5</b>", table_cell_center),
            Paragraph("<b>Mô hình Star Schema</b>", table_cell_bold),
            Paragraph("Model View: Nối dây 1-* từ <i>dim_machine[machine_id]</i>, <i>dim_product[product_id]</i>, <i>dim_date[date_id]</i> sang bảng Fact <i>fct_production_runs</i>. Hướng lọc Single.", table_cell_style)
        ],
        [
            Paragraph("<b>6</b>", table_cell_center),
            Paragraph("<b>Tạo DAX Measures</b>", table_cell_bold),
            Paragraph("Tạo bảng <i>_Measures</i> chứa toàn bộ công thức OEE, A, P, Q, Downtime, Scrap và What-If Simulation.", table_cell_style)
        ],
        [
            Paragraph("<b>7</b>", table_cell_center),
            Paragraph("<b>Interactive Features</b>", table_cell_bold),
            Paragraph("&bull; <b>Drillthrough:</b> Kéo <i>dim_machine[machine_name]</i> vào trang Machine Deep-dive.<br/>&bull; <b>Sync Slicers:</b> Đồng bộ bộ lọc Máy & Ngày qua 3 trang báo cáo.<br/>&bull; <b>Tooltip Page:</b> Rê chuột vào máy hiện ngay tóm tắt nguyên nhân dừng & phế phẩm.", table_cell_style)
        ]
    ]
    t_tech = Table(tech_steps, colWidths=[25, 120, 342])
    t_tech.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, c_bg_light]),
    ]))
    story.append(t_tech)
    story.append(Spacer(1, 10))

    # Bộ công thức DAX chính
    story.append(Paragraph("<b>Các công thức DAX cốt lõi cần cài đặt trong bảng `_Measures`:</b>", h2_style))
    dax_code = (
        "<b>Availability Rate</b> = DIVIDE(CALCULATE(SUM(fct_production_runs[duration_hours]), fct_production_runs[is_operating_time]=TRUE()), CALCULATE(SUM(fct_production_runs[duration_hours]), fct_production_runs[oee_category]<>'PM (Maintenance)'), 0)<br/>"
        "<b>Performance Rate</b> = MIN(1.0, DIVIDE(SUM(fct_production_runs[effective_total_biscuits]), CALCULATE(SUM(fct_production_runs[ideal_production]), fct_production_runs[is_operating_time]=TRUE()), 0))<br/>"
        "<b>Quality Rate</b> = DIVIDE(SUM(fct_production_runs[good_biscuits_made]), SUM(fct_production_runs[effective_total_biscuits]), 0)<br/>"
        "<b>Plant OEE</b> = [Availability Rate] * [Performance Rate] * [Quality Rate]<br/>"
        "<b>Simulated OEE</b> = DIVIDE([Operating Hours] + ([Downtime CC]*'Reduce CC %'[Value]) + ([Downtime NO]*'Reduce NO %'[Value]), [Planned Hours], 0) * [Performance Rate] * [Quality Rate]"
    )
    
    t_dax = Table([[Paragraph(dax_code, code_style)]], colWidths=[487])
    t_dax.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#EDF2F7")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_dax)
    story.append(Spacer(1, 14))

    # =========================================================================
    # 5. MA TRẬN QUYẾT ĐỊNH CHIẾN LƯỢC DÀNH CHO LÃNH ĐẠO
    # =========================================================================
    story.append(Paragraph("5. MA TRẬN QUYẾT ĐỊNH CHIẾN LƯỢC DÀNH CHO LÃNH ĐẠO (ACTION MATRIX)", h1_style))
    story.append(Paragraph(
        "Kế hoạch hành động cụ thể phân bổ theo 3 cấp độ lãnh đạo dựa trên kết quả phân tích Dashboard:",
        body_style
    ))

    action_data = [
        [
            Paragraph("<b>Cấp Quản trị</b>", table_header_style),
            Paragraph("<b>Điểm đau phát hiện (Pain Points)</b>", table_header_style),
            Paragraph("<b>Quyết sách hành động chiến lược</b>", table_header_style),
            Paragraph("<b>Kỳ vọng kết quả (ROI)</b>", table_header_style)
        ],
        [
            Paragraph("<b>BAN GIÁM ĐỐC<br/>(CEO / Plant Director)</b>", table_cell_bold),
            Paragraph("&bull; Trống máy thiếu đơn (NO) mất tới <b>2,295 giờ</b> (76.7% thời gian chết).<br/>&bull; Target Speeds đang bị cào bằng phi thực tế (43k-52k u/h).", table_cell_style),
            Paragraph("1. Họp liên phòng Kinh doanh & Sản xuất: Tối ưu gom lô chạy liên tục, giảm dừng lắt nhắt.<br/>2. Chuẩn hóa lại bảng Target Speeds cơ học cho từng công đoạn.", table_cell_style),
            Paragraph("Giảm 15% thời gian NO ➡️ <b>Thu hồi 344 giờ chạy máy</b>, cứu hàng triệu đơn vị sản lượng.", table_cell_style)
        ],
        [
            Paragraph("<b>QUẢN ĐỐC PHÂN XƯỞNG<br/>(Production Manager)</b>", table_cell_bold),
            Paragraph("&bull; Vệ sinh thay khuôn (CC) ngốn <b>561 giờ</b> (tập trung 182h ở máy Filling và 67h ở máy Forming).", table_cell_style),
            Paragraph("1. Áp dụng kỹ thuật <b>SMED</b>: Chuẩn bị cụm khuôn dập ngoài máy.<br/>2. Xếp lịch chạy kem từ màu nhạt sang đậm (vani ➡️ socola) để giảm súc rửa ống.", table_cell_style),
            Paragraph("Giảm 15% thời gian CC ➡️ <b>Thu hồi 84.2 giờ</b>, sản xuất thêm <b>4.36M bánh</b>, OEE tăng từ 6.4% lên <b>7.32%</b>!", table_cell_style)
        ],
        [
            Paragraph("<b>GIÁM SÁT MÁY & BẢO TRÌ<br/>(Supervisors & Engineers)</b>", table_cell_bold),
            Paragraph("&bull; Máy Sprinkling hỏng cảm biến (Waste 99.8%).<br/>&bull; Máy Filling vỡ bánh kẹp kem (660.5M phế phẩm).<br/>&bull; 9 đợt dừng Unclassified mất 132.5h.", table_cell_style),
            Paragraph("1. Dừng máy cân chỉnh cảm biến đầu rắc hạt Sprinkling.<br/>2. Can thiệp cơ cấu căn chỉnh 2 mặt bánh kẹp kem máy Filling.<br/>3. Bắt buộc nhập mã dừng máy MES (xóa mã 0).", table_cell_style),
            Paragraph("Cứu vãn <b>239M bánh rắc hạt</b>, triệt tiêu 132.5h dừng máy vô lý, nâng Quality máy Filling từ 41% lên 80%.", table_cell_style)
        ]
    ]
    t_action = Table(action_data, colWidths=[95, 125, 160, 107])
    t_action.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E0")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, c_bg_light]),
    ]))
    story.append(t_action)

    # Build PDF
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"✅ Đã xuất thành công file PDF: {filename}")

if __name__ == "__main__":
    output_pdf = "/Users/thienngocpham/Documents/Study/OEE_Manufacturing_Analysis/docs/OEE_MANUFACTURING_DASHBOARD_SPECIFICATION.pdf"
    build_pdf(output_pdf)

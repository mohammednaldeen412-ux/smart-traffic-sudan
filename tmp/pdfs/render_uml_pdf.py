from reportlab.lib.colors import HexColor, white
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.units import mm

OUT = r"C:\Users\DATA\Desktop\Smart-Traffic-UML\UML-Diagrams.pdf"
PAGE = landscape(A4)
W, H = PAGE
NAVY = HexColor('#17365D')
BLUE = HexColor('#2F75B5')
TEAL = HexColor('#008C95')
GOLD = HexColor('#C6952D')
RED = HexColor('#C53B3B')
GREEN = HexColor('#2E8B57')
INK = HexColor('#17212B')
MUTED = HexColor('#5B6775')
PALE = HexColor('#F5F8FC')
LINE = HexColor('#B9C6D4')


def font_setup():
    pdfmetrics.registerFont(TTFont('Arial', r'C:\Windows\Fonts\arial.ttf'))
    pdfmetrics.registerFont(TTFont('Arial-Bold', r'C:\Windows\Fonts\arialbd.ttf'))


def header(c, title, subtitle):
    c.setFillColor(NAVY)
    c.rect(0, H - 20 * mm, W, 20 * mm, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont('Arial-Bold', 17)
    c.drawString(16 * mm, H - 12 * mm, title)
    c.setFont('Arial', 8.5)
    c.drawRightString(W - 16 * mm, H - 12 * mm, subtitle)


def footer(c, page):
    c.setStrokeColor(LINE)
    c.line(16 * mm, 12 * mm, W - 16 * mm, 12 * mm)
    c.setFillColor(MUTED)
    c.setFont('Arial', 8)
    c.drawString(16 * mm, 7 * mm, 'Smart Traffic Sudan - UML analysis')
    c.drawRightString(W - 16 * mm, 7 * mm, f'Page {page} of 5')


def box(c, x, y, w, h, title, lines=(), color=BLUE, fill=PALE, title_size=11):
    c.setFillColor(fill)
    c.setStrokeColor(color)
    c.setLineWidth(1.3)
    c.roundRect(x, y, w, h, 4 * mm, fill=1, stroke=1)
    c.setFillColor(color)
    c.roundRect(x, y + h - 10 * mm, w, 10 * mm, 4 * mm, fill=1, stroke=0)
    c.rect(x, y + h - 4 * mm, w, 4 * mm, fill=1, stroke=0)
    c.setFillColor(white)
    c.setFont('Arial-Bold', title_size)
    c.drawCentredString(x + w / 2, y + h - 6.7 * mm, title)
    c.setFillColor(INK)
    c.setFont('Arial', 8.5)
    cy = y + h - 15 * mm
    for line in lines:
        c.drawCentredString(x + w / 2, cy, line)
        cy -= 5.4 * mm


def arrow(c, x1, y1, x2, y2, label=None, color=INK, dashed=False):
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(1.1)
    c.setDash(3, 2) if dashed else c.setDash()
    c.line(x1, y1, x2, y2)
    c.setDash()
    import math
    a = math.atan2(y2 - y1, x2 - x1)
    s = 6
    c.line(x2, y2, x2 - s * math.cos(a - 0.45), y2 - s * math.sin(a - 0.45))
    c.line(x2, y2, x2 - s * math.cos(a + 0.45), y2 - s * math.sin(a + 0.45))
    if label:
        c.setFont('Arial', 7.6)
        c.drawCentredString((x1 + x2) / 2, (y1 + y2) / 2 + 4, label)


def actor(c, x, y, label, color):
    c.setStrokeColor(color)
    c.setLineWidth(1.5)
    c.circle(x, y + 14, 5, fill=0, stroke=1)
    c.line(x, y + 9, x, y - 8)
    c.line(x - 8, y + 3, x + 8, y + 3)
    c.line(x, y - 8, x - 7, y - 18)
    c.line(x, y - 8, x + 7, y - 18)
    c.setFillColor(INK)
    c.setFont('Arial-Bold', 9)
    c.drawCentredString(x, y - 30, label)


def page_architecture(c):
    header(c, 'SYSTEM ARCHITECTURE', 'Component diagram')
    actor(c, 55 * mm, 155 * mm, 'Citizen', BLUE)
    actor(c, 105 * mm, 155 * mm, 'Officer', TEAL)
    actor(c, 155 * mm, 155 * mm, 'Admin', GOLD)
    box(c, 84 * mm, 105 * mm, 58 * mm, 25 * mm, 'Flutter Application', ['Role router', 'Provider state'], NAVY)
    arrow(c, 55 * mm, 132 * mm, 99 * mm, 130 * mm)
    arrow(c, 105 * mm, 132 * mm, 113 * mm, 130 * mm)
    arrow(c, 155 * mm, 132 * mm, 127 * mm, 130 * mm)
    box(c, 27 * mm, 60 * mm, 45 * mm, 27 * mm, 'Citizen Portal', ['Vehicles', 'Violations', 'Payments'], BLUE)
    box(c, 91 * mm, 60 * mm, 45 * mm, 27 * mm, 'Officer Portal', ['Plate lookup', 'Issue ticket', 'Shift history'], TEAL)
    box(c, 155 * mm, 60 * mm, 45 * mm, 27 * mm, 'Admin Portal', ['Global metrics', 'Announcements'], GOLD)
    arrow(c, 101 * mm, 105 * mm, 50 * mm, 87 * mm)
    arrow(c, 113 * mm, 105 * mm, 113 * mm, 87 * mm)
    arrow(c, 125 * mm, 105 * mm, 177 * mm, 87 * mm)
    box(c, 220 * mm, 118 * mm, 55 * mm, 20 * mm, 'Firebase Auth', ['Identity and login'], RED)
    box(c, 220 * mm, 83 * mm, 55 * mm, 20 * mm, 'Cloud Firestore', ['Operational data'], RED)
    box(c, 220 * mm, 48 * mm, 55 * mm, 20 * mm, 'FCM and Device APIs', ['Notifications and biometrics'], RED)
    arrow(c, 142 * mm, 118 * mm, 220 * mm, 128 * mm, 'authenticate')
    arrow(c, 142 * mm, 111 * mm, 220 * mm, 93 * mm, 'read / write')
    arrow(c, 142 * mm, 105 * mm, 220 * mm, 58 * mm, 'events', dashed=True)
    footer(c, 1)
    c.showPage()


def page_use_cases(c):
    header(c, 'USE CASES', 'Role-based system functions')
    actor(c, 38 * mm, 145 * mm, 'Citizen', BLUE)
    actor(c, 38 * mm, 85 * mm, 'Officer', TEAL)
    actor(c, 38 * mm, 30 * mm, 'Admin', GOLD)
    c.setStrokeColor(NAVY)
    c.roundRect(75 * mm, 23 * mm, 196 * mm, 145 * mm, 6 * mm, fill=0, stroke=1)
    c.setFillColor(NAVY); c.setFont('Arial-Bold', 11); c.drawString(84 * mm, 158 * mm, 'Smart Traffic Sudan')
    citizen = [('Register and login', 140), ('Manage vehicles', 118), ('View violation and QR', 96), ('Pay violation', 74), ('Submit dispute', 52), ('Digital licence', 30)]
    officer = [('Lookup plate', 132), ('Issue ticket', 92), ('Review shift history', 52)]
    admin = [('Review global statistics', 130), ('Broadcast announcement', 82), ('Profile and settings', 34)]
    for text, yy in citizen:
        box(c, 105 * mm, yy * mm, 57 * mm, 13 * mm, text, (), BLUE, white, 8.5)
        arrow(c, 49 * mm, 145 * mm, 105 * mm, (yy + 6.5) * mm)
    for text, yy in officer:
        box(c, 177 * mm, yy * mm, 57 * mm, 13 * mm, text, (), TEAL, white, 8.5)
        arrow(c, 49 * mm, 85 * mm, 177 * mm, (yy + 6.5) * mm)
    for text, yy in admin:
        box(c, 246 * mm, yy * mm, 42 * mm, 13 * mm, text, (), GOLD, white, 7.8)
        arrow(c, 49 * mm, 30 * mm, 246 * mm, (yy + 6.5) * mm)
    footer(c, 2)
    c.showPage()


def page_data_model(c):
    header(c, 'DATA MODEL', 'Core entities and references')
    box(c, 22 * mm, 118 * mm, 47 * mm, 37 * mm, 'UserModel', ['id', 'nationalId', 'role', 'officerBadgeNumber'], BLUE)
    box(c, 105 * mm, 137 * mm, 47 * mm, 32 * mm, 'VehicleModel', ['id', 'userId', 'plateNumber', 'chassisNumber'], TEAL)
    box(c, 105 * mm, 70 * mm, 47 * mm, 42 * mm, 'ViolationModel', ['id', 'userId / vehicleId', 'amount', 'isPaid', 'violationStatus'], RED)
    box(c, 190 * mm, 134 * mm, 47 * mm, 32 * mm, 'AuditLogModel', ['id', 'userId', 'action', 'resourceId'], GOLD)
    box(c, 190 * mm, 94 * mm, 47 * mm, 32 * mm, 'DisputeModel', ['id', 'violationId', 'userId', 'status'], GOLD)
    box(c, 190 * mm, 54 * mm, 47 * mm, 32 * mm, 'PaymentReceiptModel', ['transactionId', 'violationId', 'amount', 'paymentMethod'], GREEN)
    box(c, 260 * mm, 74 * mm, 30 * mm, 30 * mm, 'Notification', ['userId', 'type', 'isRead'], BLUE, PALE, 8)
    arrow(c, 69 * mm, 140 * mm, 105 * mm, 153 * mm, 'owns')
    arrow(c, 69 * mm, 130 * mm, 105 * mm, 95 * mm, 'receives')
    arrow(c, 128 * mm, 137 * mm, 128 * mm, 112 * mm, 'cited in')
    arrow(c, 69 * mm, 123 * mm, 190 * mm, 150 * mm, 'actions')
    arrow(c, 152 * mm, 100 * mm, 190 * mm, 110 * mm, '0..1 dispute')
    arrow(c, 152 * mm, 80 * mm, 190 * mm, 70 * mm, '0..1 receipt')
    arrow(c, 69 * mm, 118 * mm, 260 * mm, 89 * mm, 'receives', dashed=True)
    c.setFillColor(MUTED); c.setFont('Arial', 8)
    c.drawString(22 * mm, 35 * mm, 'Relations are document references stored in Cloud Firestore.')
    footer(c, 3)
    c.showPage()


def page_payment(c):
    header(c, 'PAYMENT SEQUENCE', 'Current client-side implementation')
    actors = [('Citizen', 35), ('Payment UI', 88), ('PaymentService', 141), ('Firestore', 205), ('Receipt', 260)]
    for label, xx in actors:
        box(c, xx * mm - 18 * mm, 157 * mm, 36 * mm, 12 * mm, label, (), NAVY, white, 7.8)
        c.setStrokeColor(LINE); c.setDash(2, 2); c.line(xx * mm, 35 * mm, xx * mm, 157 * mm); c.setDash()
    steps = [
        (145, 35, 88, 'Select payment method', BLUE),
        (130, 88, 141, 'processRealBankPayment', TEAL),
        (115, 141, 205, 'Read violation and virtual account', INK),
        (95, 141, 205, 'Transaction: debit and mark paid', RED),
        (75, 141, 205, 'Create receipt and bank transaction', RED),
        (55, 141, 260, 'Return QR receipt', GREEN),
        (40, 260, 35, 'Display success', GREEN),
    ]
    for yy, xx1, xx2, text, color in steps:
        arrow(c, xx1 * mm, yy * mm, xx2 * mm, yy * mm, text, color)
    box(c, 70 * mm, 20 * mm, 170 * mm, 12 * mm, 'No external bank gateway or trusted server-side payment confirmation is present.', (), RED, HexColor('#FFF4F4'), 8)
    footer(c, 4)
    c.showPage()


def page_state(c):
    header(c, 'VIOLATION STATE', 'Observed data and display transitions')
    box(c, 35 * mm, 100 * mm, 50 * mm, 25 * mm, 'Pending', ['New violation'], BLUE)
    box(c, 125 * mm, 100 * mm, 50 * mm, 25 * mm, 'Paid', ['PaymentService'], GREEN)
    box(c, 125 * mm, 45 * mm, 50 * mm, 25 * mm, 'Disputed', ['Dispute submitted'], GOLD)
    box(c, 215 * mm, 45 * mm, 58 * mm, 25 * mm, 'Displayed Paid', ['Dispute accepted', 'isPaid = true'], RED)
    arrow(c, 85 * mm, 112 * mm, 125 * mm, 112 * mm, 'payment', GREEN)
    arrow(c, 60 * mm, 100 * mm, 145 * mm, 70 * mm, 'submit dispute', GOLD)
    arrow(c, 175 * mm, 58 * mm, 215 * mm, 58 * mm, 'accept', RED)
    arrow(c, 125 * mm, 53 * mm, 85 * mm, 100 * mm, 'reject', GOLD)
    box(c, 72 * mm, 22 * mm, 182 * mm, 14 * mm, 'Observation: accepting a dispute sets isPaid but does not update violationStatus or create a cancellation receipt.', (), RED, HexColor('#FFF4F4'), 8)
    footer(c, 5)
    c.showPage()


def main():
    font_setup()
    c = Canvas(OUT, pagesize=PAGE)
    c.setTitle('Smart Traffic Sudan - UML Diagrams')
    page_architecture(c)
    page_use_cases(c)
    page_data_model(c)
    page_payment(c)
    page_state(c)
    c.save()


if __name__ == '__main__':
    main()

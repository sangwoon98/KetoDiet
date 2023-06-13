import base64
import os
from io import BytesIO
from PIL import Image
from django.core.mail import EmailMultiAlternatives
from celery import shared_task

@shared_task
def send_email_task(email_subject, message, sender_email, email, image_encoded):
    # split_data = image_encoded.split(",")
    # image_encoded = split_data[1]
    # image_type = split_data[0]
    # image_type = split_data[0]

    # base64 디코딩
    image_data = base64.b64decode(image_encoded)
    
    # base64 + data:image/png;base64
    image_encoded= "data:image/png;base64,"+image_encoded
    
    # 이미지 데이터로 변환
    image = Image.open(BytesIO(image_data)).convert('RGB')

    # 이메일 객체 생성
    
    email_subject = 'KetoDiet에서 적정섭취량 계산결과가 도착했습니다.'
    sender_email = 'dbstkddns123456@gamail.com'
    recipient_emails = [email]

    # HTML 형식 이메일 작성
    email = EmailMultiAlternatives(email_subject, message, sender_email, recipient_emails)
    email.attach_alternative('<html><body><h2>'+message+'</h2><img src="'+image_encoded+'"style="width: 50vw; min-width: 140px;></body></html>', 'text/html')

    # 이미지 첨부 (인라인)
    image_filename = 'image.jpg'  # 첨부할 이미지 파일 이름
    image.save(image_filename, 'JPEG')  # 이미지 파일로 저장
    email.attach(image_filename, image_data, 'image/jpeg')

    # 이메일 전송
    email.send()

    # 임시 이미지 파일 삭제
    os.remove(image_filename)


# @shared_task
# def send_email_task(subject, message, from_email, recipient_list):
#     send_mail(subject, message, from_email, recipient_list)

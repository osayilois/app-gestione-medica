# MediCare

A Flutter medical app for patients and GPs to manage appointments, prescriptions, and medical data — built with Firebase and a responsive, animated UI.

## 📁 Directory structure

```plaintext
lib/
│
├── main.dart                        # Entry point
│
├── theme/
│   └── text_styles.dart             # Font, colori, stili testo
│
├── util/
│   ├── article_item_card.dart             # Widget riutilizzabili
│   ├── category_card.dart  
│   └── doctor_card.dart
│
│
├── services/
│   ├── auth_service.dart            # Login/Logout/Firebase auth
│   ├── firestore_service.dart       # Letture/scritture centralizzate
│   └── prescriptions_service.dart   # Servizio specifico per prescrizioni
│
├── widgets/
│   ├── search_bar.dart              # DoctorSearchBar personalizzata
│   ├── home_header.dart
│   ├── medical_banner.dart          # Banner per Homepage
│   ├── specialists_section.dart
│   ├── prescription_detail_dialogue.dart
│   ├── top_rated_doctors_section.dart
│   ├── chat_box.dart
│   ├── avatar_picker_bottom_sheet.dart
│   ├── health_articles_carousel.dart
│   └── upcoming_appointments_widget
│
├── pages/
│   ├── home/
│   │   ├── home_page.dart     # contiene anche HomeContent
│   │   └── notifications_page.dart 
│   │  
│   │
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── forgot_password_page.dart 
│   │ 
│   │    
│   ├── data/
│   │   ├── mock_doctors.dart
│   │   └── specialty_categories.dart
│   │
│   ├── articles/
│   │   ├── article_detail_page.dart
│   │   └── articles_page.dart
│   │
│   ├── appointments/
│   │   ├── appointment_page.dart
│   │   └── appointments_list_page.dart
│   │
│   ├── prescriptions/
│   │   ├── prescription_request.dart
│   │   └── prescriptions_page.dart
│   │
│   ├── profile/
│   │   ├── medical_card_page.dart
│   │   ├── profile_overview_bottom_sheet.dart      #panormica profilo utente
│   │   └── profile_page.dart
│   │
│   ├── admin/
│   │   ├── admin_home_page.dart
│   │   └── admin_prescription_page.dart
│   │   
│   └── doctor/
│   │   ├── doctor_detail_page.dart
│   │   ├── doctor_profile_page.dart
│   │   └── specialist_page.dart

```

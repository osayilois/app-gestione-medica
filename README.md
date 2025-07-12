# medicare_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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

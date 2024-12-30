# Yarvis

Aplicación Flutter que utiliza la API de Gemini para generar contenido de texto.

## Requisitos previos

- Flutter SDK (versión mínima: 3.x)
- Dart
- Emulador o dispositivo físico
- API Key de Gemini

## Instalación

1. Clonar el repositorio:

```bash
git clone https://github.com/cesardev31/yarvis.git
cd yarvis
```

2. Instalar dependencias:

```bash
flutter pub get
```

3. Configurar variables de entorno:
   - Crear archivo `.env` en la raíz
   - Agregar:
   ```
   API_KEY=tu_clave_api_de_gemini
   ```

## Estructura

```
lib/
├── models/
│   ├── chat_message.dart
├── screens/
│   ├── chat_screen.dart
│   ├── loading_screen.dart
│   └── virtual_assistant_screen.dart
├── services/
│   ├── llm_service.dart
│   ├── model_service.dart
│   ├── speech_service.dart
│   └── tts_service.dart
└── widgets/
    ├── chat_message.dart
    ├── input_bar.dart
    ├── loading_screen.dart
    └── main.dart
```

## Uso

```bash
flutter run
```

## Licencia

MIT

## Contacto

[@cesardev31](https://github.com/cesardev31)

# Subtexto

Aplicativo Flutter para interpretar mensagens com apoio do Gemini. O app inclui
um banco local de perguntas guiadas e salva as análises no dispositivo.

## Executar

Na raiz do projeto, rode no PowerShell:

```powershell
flutter pub get
flutter run -d chrome
```

Se `flutter` não estiver no PATH, use o caminho completo do SDK:

```powershell
& "C:\caminho\para\flutter\bin\flutter.bat" run -d chrome
```

Para trocar a chave padrão, use `--dart-define=GEMINI_API_KEY=SUA_CHAVE`. A
chave incluída no aplicativo fica visível em aplicações Flutter Web; para
produção, mova a chamada do Gemini para um backend.

## Publicar no Netlify

1. Gere o build de produção:

```powershell
flutter build web --release --no-pub
```

2. Acesse https://app.netlify.com/drop.
3. Arraste a pasta `build/web` para a área indicada.
4. Aguarde o upload terminar e abra o endereço gerado.

O arquivo `netlify.toml` já configura o fallback necessário para as rotas do
Flutter Web. Antes de publicar, lembre que a chave Gemini usada no frontend
fica visível para qualquer visitante; para uma aplicação pública, use um
backend ou uma Netlify Function para esconder a chave.

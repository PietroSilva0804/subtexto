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

No modo web, a chamada passa pela Netlify Function e a chave não fica no
navegador. Em plataformas nativas, configure `--dart-define=GEMINI_API_KEY=SUA_CHAVE`.

## Publicar na Vercel

1. Envie as alterações para o GitHub:

```powershell
git add .
git commit -m "Migra hospedagem para Vercel"
git push
```

2. Acesse https://vercel.com/new.
3. Escolha **Import Git Repository** e selecione o repositório do GitHub.
4. Em **Environment Variables**, crie `GEMINI_API_KEY` com sua chave válida.
5. Clique em **Deploy**.

O arquivo `vercel.json` configura o diretório `build/web` e o fallback das
rotas do Flutter Web. A função `api/analyze.mjs` usa a chave somente no servidor.

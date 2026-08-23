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

## Publicar no Netlify

1. Envie as alterações para o GitHub:

```powershell
git add .
git commit -m "Protege chamada Gemini com Netlify Function"
git push
```

2. No Netlify, escolha **Add new site > Import an existing project**.
3. Selecione o repositório do GitHub.
4. Deixe o publish directory como `build/web`.
5. Em **Site configuration > Environment variables**, crie `GEMINI_API_KEY`
	com sua chave válida do Google AI Studio.
6. Faça o deploy e abra o endereço gerado.

O arquivo `netlify.toml` já configura o fallback das rotas e o diretório da
Netlify Function. O upload manual de `build/web` não inclui Functions; use o
deploy conectado ao GitHub.

export default async function handler(request, response) {
  if (request.method !== 'POST') {
    return response.status(405).json({ error: 'Method Not Allowed' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return response.status(500).json({
      error: 'GEMINI_API_KEY não configurada na Vercel.',
    });
  }

  try {
    const { prompt } = request.body ?? {};
    if (typeof prompt !== 'string' || !prompt.trim()) {
      return response.status(400).json({ error: 'Prompt inválido.' });
    }

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.3,
            maxOutputTokens: 4096,
            responseMimeType: 'application/json',
          },
        }),
      },
    );

    const payload = await geminiResponse.json();
    if (!geminiResponse.ok) {
      return response.status(geminiResponse.status).json({
        error: payload?.error?.message ?? 'Erro na API Gemini.',
      });
    }

    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== 'string' || !text) {
      return response.status(502).json({ error: 'Gemini não retornou texto.' });
    }

    return response.status(200).json({ text });
  } catch (error) {
    return response.status(500).json({
      error: `Falha ao analisar: ${error.message}`,
    });
  }
}

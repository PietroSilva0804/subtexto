export default async (request) => {
  if (request.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return Response.json({ error: 'GEMINI_API_KEY não configurada no Netlify.' }, { status: 500 });
  }

  try {
    const { prompt } = await request.json();
    if (typeof prompt !== 'string' || !prompt.trim()) {
      return Response.json({ error: 'Prompt inválido.' }, { status: 400 });
    }

    const response = await fetch(
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

    const payload = await response.json();
    if (!response.ok) {
      return Response.json(
        { error: payload?.error?.message ?? 'Erro na API Gemini.' },
        { status: response.status },
      );
    }

    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== 'string' || !text) {
      return Response.json({ error: 'Gemini não retornou texto.' }, { status: 502 });
    }

    return Response.json({ text });
  } catch (error) {
    return Response.json({ error: `Falha ao analisar: ${error.message}` }, { status: 500 });
  }
};

export const config = { path: '/.netlify/functions/analyze' };

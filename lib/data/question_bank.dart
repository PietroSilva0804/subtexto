class QuestionBank {
  static const categories = <String, List<String>>{
    'Intenção': [
      'O que essa pessoa quis dizer de verdade?',
      'Essa mensagem demonstra interesse?',
      'A pessoa está sendo sincera ou apenas educada?',
      'Existe uma indireta nessa mensagem?',
      'A pessoa quer continuar a conversa?',
    ],
    'Relacionamentos': [
      'Essa pessoa está flertando comigo?',
      'É um sinal de interesse romântico?',
      'A resposta parece fria ou distante?',
      'Estou interpretando essa mensagem de forma ansiosa?',
      'Qual seria uma resposta equilibrada?',
    ],
    'Conversas': [
      'Por que a pessoa respondeu desse jeito?',
      'O que mudou no tom da conversa?',
      'Quem está investindo mais nessa conversa?',
      'Há algum sinal de desconforto?',
      'Como posso responder sem pressionar?',
    ],
    'Clareza': [
      'Como interpretar essa mensagem literalmente?',
      'Quais sinais são fatos e quais são suposições?',
      'Quais interpretações alternativas existem?',
      'O contexto muda o sentido da mensagem?',
      'O que eu deveria perguntar diretamente?',
    ],
  };

  static List<String> get all =>
      categories.values.expand((items) => items).toList();
}

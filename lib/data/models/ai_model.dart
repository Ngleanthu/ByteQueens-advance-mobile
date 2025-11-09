enum AIModel {
  gpt4oMini,
  gpt4o,
  gemini15Flash,
  gemini15Pro,
  gemini20Flash,
  claude3Haiku,
  claude35Sonnet,
  deepseekChat,
}

extension AIModelExtension on AIModel {
  String get displayName {
    switch (this) {
      case AIModel.gpt4oMini:
        return 'GPT-4o mini';
      case AIModel.gpt4o:
        return 'GPT-4o';
      case AIModel.gemini15Flash:
        return 'Gemini 1.5 Flash';
      case AIModel.gemini15Pro:
        return 'Gemini 1.5 Pro';
      case AIModel.gemini20Flash:
        return 'Gemini 2.0 Flash';
      case AIModel.claude3Haiku:
        return 'Claude 3 Haiku';
      case AIModel.claude35Sonnet:
        return 'Claude 3.5 Sonnet';
      case AIModel.deepseekChat:
        return 'Deepseek Chat';
    }
  }

  String get description {
    switch (this) {
      case AIModel.gpt4oMini:
        return 'OpenAI\'s latest model, very fast and great for most everyday tasks.\nCost 1 Tokens';
      case AIModel.gpt4o:
        return 'Most advanced OpenAI model, best for complex tasks.\nCost 10 Tokens';
      case AIModel.gemini15Flash:
        return 'Fast and efficient Google model.\nCost 1 Tokens';
      case AIModel.gemini15Pro:
        return 'Advanced Google model with enhanced capabilities.\nCost 5 Tokens';
      case AIModel.gemini20Flash:
        return 'Latest Google model with improved performance.\nCost 2 Tokens';
      case AIModel.claude3Haiku:
        return 'Fast and efficient Anthropic model.\nCost 1 Tokens';
      case AIModel.claude35Sonnet:
        return 'Advanced Anthropic model with superior reasoning.\nCost 8 Tokens';
      case AIModel.deepseekChat:
        return 'Efficient open-source model.\nCost 1 Tokens';
    }
  }

  String get iconColor {
    switch (this) {
      case AIModel.gpt4oMini:
      case AIModel.gpt4o:
        return 'black';
      case AIModel.gemini15Flash:
      case AIModel.gemini15Pro:
      case AIModel.gemini20Flash:
        return 'blue';
      case AIModel.claude3Haiku:
      case AIModel.claude35Sonnet:
        return 'orange';
      case AIModel.deepseekChat:
        return 'cyan';
    }
  }
}

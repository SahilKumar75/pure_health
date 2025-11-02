import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_message_model.dart';

class ProcessMessageUsecase {
  final ChatRepository repository;

  ProcessMessageUsecase(this.repository);

  Future<String> call(String message) async {
    return await repository.sendMessage(message);
  }
}

class GetWaterQualityPredictionUsecase {
  final ChatRepository repository;

  GetWaterQualityPredictionUsecase(this.repository);

  Future<WaterQualityPrediction?> call(
    Map<String, dynamic> parameters,
  ) async {
    return await repository.getWaterQualityPrediction(parameters);
  }
}

class GetRecommendationsUsecase {
  final ChatRepository repository;

  GetRecommendationsUsecase(this.repository);

  Future<List<String>> call(String status) async {
    return await repository.getRecommendations(status);
  }
}

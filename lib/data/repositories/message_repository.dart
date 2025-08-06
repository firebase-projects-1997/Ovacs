import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/dio_client.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/error/failure.dart';
import '../../services/storage_service.dart';
import '../models/login_response.dart';
import '../models/message_model.dart';
import '../models/message_with_pagination.dart';
import '../models/pagination_model.dart';

class MessageRepository {
  final DioClient _dioClient;
  final Dio dio = Dio();
  final StorageService _storageService;

  MessageRepository(this._dioClient, this._storageService);

  Future<Either<Failure, MessagesWithPaginationResponse>> getCaseMessages(
    int caseId, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final request = await _dioClient.get(
        '/cases/$caseId${AppUrls.messages}',
        queryParameters: query,
      );
      return request.fold((failure) => Left(failure), (res) {
        final List data = res.data['data']['data'];
        final messages = data
            .map((json) => MessageModel.fromJson(json))
            .toList();
        final pagination = PaginationModel.fromJson(
          res.data['data']['pagination'],
        );
        return Right(
          MessagesWithPaginationResponse(
            messages: messages,
            pagination: pagination,
          ),
        );
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Get message detail
  Future<Either<Failure, MessageModel>> getMessageDetail(int id) async {
    try {
      final request = await _dioClient.get('${AppUrls.messages}$id/');

      return request.fold((failure) => Left(failure), (res) {
        final message = MessageModel.fromJson(res.data['data']);
        return Right(message);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Create text message
  Future<Either<Failure, MessageModel>> createTextMessage(
    int caseId,
    String content,
  ) async {
    try {
      final body = {'type': 'text', 'content': content};
      final request = await _dioClient.post(
        '/cases/$caseId${AppUrls.messages}',
        data: body,
      );
      return request.fold((failure) => Left(failure), (res) {
        final message = MessageModel.fromJson(res.data['data']);
        return Right(message);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MessageModel>> createVoiceMessage(
    int caseId,
    File voiceFile,
    void Function(double)? onProgress,
  ) async {
    if (!await voiceFile.exists()) {
      return Left(ServerFailure('Audio file not found.'));
    }

    final length = await voiceFile.length();
    if (length == 0) {
      return Left(ServerFailure('Cannot send empty audio file.'));
    }

    // Get file extension and validate
    final extension = voiceFile.path.split('.').last.toLowerCase();
    final allowedExtensions = [
      'mp3',
      'wav',
      'm4a',
      'aac',
    ]; // Added 'aac' as it might be needed
    if (!allowedExtensions.contains(extension)) {
      return Left(
        ServerFailure('Only MP3, WAV, and M4A audio files are allowed'),
      );
    }

    String? token;
    final saved = await _storageService.getString(StorageKeys.loginResponse);
    if (saved != null) {
      final decoded = jsonDecode(saved);
      final loginResponse = LoginResponse.fromJson(decoded);
      token = loginResponse.accessToken;
    }

    // Determine MIME type based on extension
    String mimeType;
    switch (extension) {
      case 'mp3':
        mimeType = 'audio/mpeg';
        break;
      case 'wav':
        mimeType = 'audio/wav';
        break;
      case 'm4a':
      case 'aac':
        mimeType = 'audio/aac';
        break;
      default:
        mimeType = 'application/octet-stream';
    }

    final formData = FormData.fromMap({
      'type': 'voice',
      'voice_file': await MultipartFile.fromFile(
        voiceFile.path,
        filename: 'voice.$extension',
        contentType: MediaType.parse(mimeType),
      ),
    });

    try {
      final response = await dio.post(
        'https://ovacs.com/backend/api/cases/$caseId/messages/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = MessageModel.fromJson(response.data['data']);
        return Right(message);
      } else {
        return Left(
          ServerFailure(response.statusMessage ?? 'Unexpected error.'),
        );
      }
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message']?.toString() ??
              e.response?.data['data']?.toString() ??
              e.message ??
              'Failed to send voice message',
        ),
      );
    }
  }

  Future<Either<Failure, MessageModel>> editTextMessage(
    int id,
    String content,
  ) async {
    try {
      final body = {'type': 'text', 'content': content};
      final request = await _dioClient.put(
        '${AppUrls.messages}$id/',
        data: body,
      );
      return request.fold((failure) => Left(failure), (res) {
        final message = MessageModel.fromJson(res.data['data']);
        return Right(message);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Delete message
  Future<Either<Failure, Unit>> deleteMessage(int id) async {
    try {
      await _dioClient.delete('${AppUrls.messages}$id/');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

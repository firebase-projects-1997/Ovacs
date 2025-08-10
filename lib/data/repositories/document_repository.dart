import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/core/network/dio_client.dart';
import 'package:new_ovacs/data/models/pagination_model.dart';
import '../models/document_model.dart';
import '../models/document_group_model.dart';
import '../models/documents_with_pagenation_response.dart';

class DocumentRepository {
  final DioClient _dio;

  DocumentRepository(this._dio);

  // GET: List all documents (with optional filters)
  Future<Either<Failure, DocumentsWithPaginationResponse>> listDocuments({
    Map<String, dynamic>? params,
  }) async {
    final res = await _dio.get(AppUrls.documents, queryParameters: params);
    return res.fold((failure) => Left(failure), (response) {
      final data = response.data['data'] as Map<String, dynamic>;

      final pagination = PaginationModel.fromJson(data['pagination']);
      final docs = (data['data'] as List)
          .map((doc) => DocumentModel.fromJson(doc))
          .toList();
      return Right(
        DocumentsWithPaginationResponse(
          documents: docs,
          pagination: pagination,
        ),
      );
    });
  }

  // GET: Get document detail
  Future<Either<Failure, DocumentModel>> getDocumentDetail(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.get(
      '${AppUrls.documents}$id/',
      queryParameters: queryParams,
    );
    return res.fold(
      (failure) => Left(failure),
      (response) => Right(DocumentModel.fromJson(response.data['data'])),
    );
  }

  // PUT: Update a document
  Future<Either<Failure, DocumentModel>> updateDocument(
    int id,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParams,
  }) async {
    final request = await _dio.put(
      '${AppUrls.documents}$id/',
      data: body,
      queryParameters: queryParams,
    );
    return request.fold(
      (f) => Left(f),
      (res) => Right(
        DocumentModel.fromJson(res.data['data'] as Map<String, dynamic>),
      ),
    );
  }

  // DELETE: Delete a document
  Future<Either<Failure, Unit>> deleteDocument(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.delete(
      '${AppUrls.documents}$id/',
      queryParameters: queryParams,
    );
    return res.fold((f) => Left(f), (_) => const Right(unit));
  }

  // POST: Move document to group
  Future<Either<Failure, DocumentModel>> moveDocumentToGroup(
    int documentId,
    int groupId, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.patch(
      '${AppUrls.documents}$documentId/move-to-group/',
      data: {'group_id': groupId},
      queryParameters: queryParams,
    );
    return res.fold(
      (f) => Left(f),
      (res) => Right(
        DocumentModel.fromJson(res.data['data'] as Map<String, dynamic>),
      ),
    );
  }

  // POST: Upload documents (grouped or not)
  Future<Either<Failure, List<DocumentModel>>> uploadDocuments({
    required List<String> filePaths,
    required String securityLevel,
    required int sessionId,
    required bool storeAsGroup,
    int? groupId,
    String? groupName,
    String? groupDescription,
    Map<String, dynamic>? queryParams,
  }) async {
    final List<MultipartFile> files = await Future.wait(
      filePaths.map(
        (path) => MultipartFile.fromFile(path, filename: path.split('/').last),
      ),
    );

    final Map<String, dynamic> formMap = {
      'files': files,
      'security_level': securityLevel,
      'session_id': sessionId,
    };

    if (groupId != null) {
      formMap['group_id'] = groupId;
      formMap['store_as_group'] = true;
    } else {
      formMap['store_as_group'] = storeAsGroup;
      if (storeAsGroup) {
        formMap['group_name'] = groupName ?? '';
        formMap['group_description'] = groupDescription ?? '';
      }
    }

    final formData = FormData.fromMap(formMap);

    final response = await _dio.post(
      AppUrls.uploadDocument,
      data: formData,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      final List<dynamic> jsonList = res.data['data'];
      final docs = jsonList.map((e) => DocumentModel.fromJson(e)).toList();
      return Right(docs);
    });
  }

  // ===================== Groups =====================

  // GET: List groups
  Future<Either<Failure, List<DocumentGroupModel>>> listDocumentGroups({
    Map<String, dynamic>? params,
  }) async {
    final res = await _dio.get(AppUrls.documentGroups, queryParameters: params);
    return res.fold((failure) => Left(failure), (response) {
      final data = List<Map<String, dynamic>>.from(response.data['data']);
      return Right(data.map(DocumentGroupModel.fromJson).toList());
    });
  }

  // GET: Group detail
  Future<Either<Failure, DocumentGroupModel>> getGroupDetail(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.get(
      '${AppUrls.documentGroups}$id/',
      queryParameters: queryParams,
    );
    return res.fold((failure) => Left(failure), (response) {
      // The group detail API returns data directly, not wrapped in 'data' field
      final data = response.data;
      return Right(DocumentGroupModel.fromJson(data));
    });
  }

  // POST: Create group
  Future<Either<Failure, Unit>> createGroup(
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.post(
      AppUrls.documentGroups,
      data: body,
      queryParameters: queryParams,
    );
    return res.fold((f) => Left(f), (_) => const Right(unit));
  }

  // PUT: Update group
  Future<Either<Failure, Unit>> updateGroup(
    int id,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.put(
      '${AppUrls.documentGroups}$id/',
      data: body,
      queryParameters: queryParams,
    );
    return res.fold((f) => Left(f), (_) => const Right(unit));
  }

  // DELETE: Delete group
  Future<Either<Failure, Unit>> deleteGroup(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final res = await _dio.delete(
      '${AppUrls.documentGroups}$id/',
      queryParameters: queryParams,
    );
    return res.fold((f) => Left(f), (_) => const Right(unit));
  }

  // GET: Download/View via signed URL (assumed already obtained)
  Future<Either<Failure, Response>> getFileBySignedUrl(String signedUrl) async {
    try {
      final response = await _dio.dio.get(
        signedUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure('Download error: ${e.toString()}'));
    }
  }
}

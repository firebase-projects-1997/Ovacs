import 'package:flutter/material.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';

enum CaseDetailStatus { initial, loading, loaded, error }

class CaseDetailProvider extends ChangeNotifier {
  final CaseRepository caseRepository;

  CaseDetailProvider(this.caseRepository);

  CaseModel? caseModel;
  CaseDetailStatus status = CaseDetailStatus.initial;
  String? errorMessage;

  // جلب تفاصيل الحالة
  Future<void> fetchCaseDetail(int id) async {
    status = CaseDetailStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await caseRepository.getCaseDetail(id);
    result.fold(
      (failure) {
        status = CaseDetailStatus.error;
        errorMessage = failure.message;
        notifyListeners();
      },
      (caseData) {
        caseModel = caseData;
        status = CaseDetailStatus.loaded;
        notifyListeners();
      },
    );
  }

  // تحديث الحالة
  Future<bool> updateCase(int id, Map<String, dynamic> payload) async {
    status = CaseDetailStatus.loading;
    notifyListeners();

    final result = await caseRepository.updateCase(id, payload);
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        status = CaseDetailStatus.error;
        notifyListeners();
        return false;
      },
      (updatedCase) {
        caseModel = updatedCase;
        status = CaseDetailStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // حذف الحالة
  Future<bool> deleteCase(int id) async {
    status = CaseDetailStatus.loading;
    notifyListeners();

    final result = await caseRepository.deleteCase(id);
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        status = CaseDetailStatus.error;
        notifyListeners();
        return false;
      },
      (success) {
        status = CaseDetailStatus.initial;
        caseModel = null;
        notifyListeners();
        return true;
      },
    );
  }
}

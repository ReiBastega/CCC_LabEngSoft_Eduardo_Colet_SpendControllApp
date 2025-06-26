import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:spend_controll/modules/service/service.dart';
import 'package:uuid/uuid.dart';

class ReceiptUploadController extends Cubit<ReceiptUploadState> {
  final Service service;
  final ImagePicker _imagePicker = ImagePicker();

  ReceiptUploadController({
    required this.service,
  }) : super(const ReceiptUploadState.initial());

  // Seleciona imagem da galeria
  Future<void> pickImageFromGallery() async {
    emit(state.copyWith(status: UploadStatus.selecting));

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compressão para reduzir tamanho
      );

      if (pickedFile != null) {
        emit(state.copyWith(
          status: UploadStatus.selected,
          imageFile: File(pickedFile.path),
          imageUrl: null, // Limpa URL anterior se existir
        ));
      } else {
        // Usuário cancelou a seleção
        emit(state.copyWith(status: UploadStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Erro ao selecionar imagem: ${e.toString()}",
      ));
    }
  }

  // Captura imagem da câmera
  Future<void> takePhoto() async {
    emit(state.copyWith(status: UploadStatus.selecting));

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Compressão para reduzir tamanho
      );

      if (pickedFile != null) {
        emit(state.copyWith(
          status: UploadStatus.selected,
          imageFile: File(pickedFile.path),
          imageUrl: null, // Limpa URL anterior se existir
        ));
      } else {
        // Usuário cancelou a captura
        emit(state.copyWith(status: UploadStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Erro ao capturar foto: ${e.toString()}",
      ));
    }
  }

  // Faz upload da imagem para o Firebase Storage
  Future<void> uploadReceipt({
    required String groupId,
    required String expenseId,
  }) async {
    if (state.imageFile == null) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Nenhuma imagem selecionada para upload",
      ));
      return;
    }

    emit(state.copyWith(status: UploadStatus.uploading));

    try {
      // Gera um nome único para o arquivo
      final String fileName =
          '${const Uuid().v4()}${path.extension(state.imageFile!.path)}';

      // Referência para o local de armazenamento no Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('receipts')
          .child(groupId)
          .child(expenseId)
          .child(fileName);

      // Faz o upload do arquivo
      final uploadTask = storageRef.putFile(state.imageFile!);

      // Monitora o progresso do upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        emit(state.copyWith(
          status: UploadStatus.uploading,
          uploadProgress: progress,
        ));
      });

      // Aguarda a conclusão do upload
      await uploadTask.whenComplete(() => null);

      // Obtém a URL de download
      final String downloadUrl = await storageRef.getDownloadURL();

      // Atualiza o estado com a URL
      emit(state.copyWith(
        status: UploadStatus.success,
        imageUrl: downloadUrl,
        uploadProgress: 1.0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Erro ao fazer upload da imagem: ${e.toString()}",
      ));
    }
  }

  // Atualiza a referência da imagem na despesa
  Future<void> updateExpenseWithReceipt({
    required String groupId,
    required String expenseId,
  }) async {
    if (state.imageUrl == null) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Nenhuma URL de imagem disponível",
      ));
      return;
    }

    emit(state.copyWith(status: UploadStatus.updating));

    try {
      // Atualiza o documento da despesa com a URL da imagem
      await service.updateExpenseReceiptUrl(
        groupId: groupId,
        expenseId: expenseId,
        receiptUrl: state.imageUrl!,
      );

      emit(state.copyWith(status: UploadStatus.complete));
    } catch (e) {
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: "Erro ao atualizar despesa: ${e.toString()}",
      ));
    }
  }

  // Remove a imagem selecionada
  void removeSelectedImage() {
    emit(state.copyWith(
      status: UploadStatus.initial,
      imageFile: null,
      imageUrl: null,
      uploadProgress: 0.0,
    ));
  }

  // Limpa mensagens de erro
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// Estado do controller
class ReceiptUploadState {
  final UploadStatus status;
  final File? imageFile;
  final String? imageUrl;
  final double uploadProgress;
  final String? errorMessage;

  const ReceiptUploadState({
    required this.status,
    this.imageFile,
    this.imageUrl,
    required this.uploadProgress,
    this.errorMessage,
  });

  // Estado inicial
  const ReceiptUploadState.initial()
      : status = UploadStatus.initial,
        imageFile = null,
        imageUrl = null,
        uploadProgress = 0.0,
        errorMessage = null;

  // Método para criar uma cópia com alterações
  ReceiptUploadState copyWith({
    UploadStatus? status,
    File? imageFile,
    String? imageUrl,
    double? uploadProgress,
    String? errorMessage,
  }) {
    return ReceiptUploadState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage,
    );
  }
}

enum UploadStatus {
  initial,
  selecting,
  selected,
  uploading,
  success,
  updating,
  complete,
  error,
}

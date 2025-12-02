import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../models/image_adjustments.dart';

enum EditorStatus {
  initial,
  loading,
  loaded,
  processing,
  saving,
  saved,
  error,
}

class EditorState extends Equatable {
  final EditorStatus status;
  final String? imagePath;
  final Uint8List? imageBytes;
  final Uint8List? processedImageBytes;
  final ImageAdjustments adjustments;
  final List<ImageAdjustments> history;
  final int historyIndex;
  final bool isComparing;
  final bool isAIMagicProcessing;
  final String? errorMessage;

  const EditorState({
    this.status = EditorStatus.initial,
    this.imagePath,
    this.imageBytes,
    this.processedImageBytes,
    this.adjustments = const ImageAdjustments(),
    this.history = const [ImageAdjustments()],
    this.historyIndex = 0,
    this.isComparing = false,
    this.isAIMagicProcessing = false,
    this.errorMessage,
  });

  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < history.length - 1;
  bool get hasImage => imageBytes != null;
  bool get hasChanges => adjustments.hasChanges;

  EditorState copyWith({
    EditorStatus? status,
    String? imagePath,
    Uint8List? imageBytes,
    Uint8List? processedImageBytes,
    ImageAdjustments? adjustments,
    List<ImageAdjustments>? history,
    int? historyIndex,
    bool? isComparing,
    bool? isAIMagicProcessing,
    String? errorMessage,
  }) {
    return EditorState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
      adjustments: adjustments ?? this.adjustments,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      isComparing: isComparing ?? this.isComparing,
      isAIMagicProcessing: isAIMagicProcessing ?? this.isAIMagicProcessing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        imagePath,
        imageBytes,
        processedImageBytes,
        adjustments,
        history,
        historyIndex,
        isComparing,
        isAIMagicProcessing,
        errorMessage,
      ];
}

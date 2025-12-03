import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../../core/utils/image_processor.dart';
import '../models/image_adjustments.dart';
import 'editor_event.dart';
import 'editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _debounceTimer;
  bool _isProcessing = false;

  EditorBloc() : super(const EditorState()) {
    on<LoadImageEvent>(_onLoadImage);
    on<PickImageFromGalleryEvent>(_onPickImageFromGallery);
    on<PickImageFromCameraEvent>(_onPickImageFromCamera);
    on<UpdateAdjustmentEvent>(_onUpdateAdjustment);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<ApplyAIMagicEvent>(_onApplyAIMagic);
    on<ResetAdjustmentsEvent>(_onResetAdjustments);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<ToggleCompareEvent>(_onToggleCompare);
    on<SaveImageEvent>(_onSaveImage);
    on<ExportImageEvent>(_onExportImage);
    on<CropImageEvent>(_onCropImage);
    on<RotateImageEvent>(_onRotateImage);
    on<FlipImageEvent>(_onFlipImage);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    return super.close();
  }

  Future<void> _onLoadImage(
    LoadImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(status: EditorStatus.loading));
    try {
      final file = File(event.imagePath);
      final bytes = await file.readAsBytes();
      emit(state.copyWith(
        status: EditorStatus.loaded,
        imagePath: event.imagePath,
        imageBytes: bytes,
        processedImageBytes: bytes,
        adjustments: const ImageAdjustments(),
        history: [const ImageAdjustments()],
        historyIndex: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to load image: $e',
      ));
    }
  }

  Future<void> _onPickImageFromGallery(
    PickImageFromGalleryEvent event,
    Emitter<EditorState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        add(LoadImageEvent(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to pick image: $e',
      ));
    }
  }

  Future<void> _onPickImageFromCamera(
    PickImageFromCameraEvent event,
    Emitter<EditorState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        add(LoadImageEvent(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to capture image: $e',
      ));
    }
  }

  Future<void> _onUpdateAdjustment(
    UpdateAdjustmentEvent event,
    Emitter<EditorState> emit,
  ) async {
    final newAdjustments = state.adjustments.copyWithAdjustment(
      event.type,
      event.value,
    );
    
    // Update UI immediately with new adjustments
    emit(state.copyWith(adjustments: newAdjustments));
    
    // Cancel any pending processing
    _debounceTimer?.cancel();
    
    // Debounce the actual image processing
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (!isClosed && !_isProcessing) {
        _processImageDebounced(newAdjustments);
      }
    });
  }

  Future<void> _processImageDebounced(ImageAdjustments adjustments) async {
    if (state.imageBytes == null || _isProcessing || isClosed) return;
    
    _isProcessing = true;
    
    try {
      // Update history
      final newHistory = [
        ...state.history.sublist(0, state.historyIndex + 1),
        adjustments,
      ];
      
      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.copyWith(
        history: newHistory,
        historyIndex: newHistory.length - 1,
      ));
      
      final processedBytes = await ImageProcessor.processImage(
        state.imageBytes!,
        adjustments,
      );

      if (!isClosed) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(state.copyWith(
          status: EditorStatus.loaded,
          processedImageBytes: processedBytes,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(state.copyWith(
          status: EditorStatus.error,
          errorMessage: 'Failed to process image: $e',
        ));
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onApplyFilter(
    ApplyFilterEvent event,
    Emitter<EditorState> emit,
  ) async {
    final newAdjustments = state.adjustments.copyWith(filter: event.filter);
    
    emit(state.copyWith(
      status: EditorStatus.processing,
      adjustments: newAdjustments,
    ));

    await _processImage(emit, newAdjustments, addToHistory: true);
  }

  Future<void> _onApplyAIMagic(
    ApplyAIMagicEvent event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(isAIMagicProcessing: true));

    // Simulate AI processing delay for UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (isClosed) return;

    final newAdjustments = ImageAdjustments.aiMagic.copyWith(
      filter: state.adjustments.filter,
    );

    final newHistory = [
      ...state.history.sublist(0, state.historyIndex + 1),
      newAdjustments,
    ];

    emit(state.copyWith(
      adjustments: newAdjustments,
      history: newHistory,
      historyIndex: newHistory.length - 1,
    ));

    await _processImage(emit, newAdjustments, addToHistory: false);
    
    if (!isClosed) {
      emit(state.copyWith(isAIMagicProcessing: false));
    }
  }

  Future<void> _onResetAdjustments(
    ResetAdjustmentsEvent event,
    Emitter<EditorState> emit,
  ) async {
    _debounceTimer?.cancel();
    
    const newAdjustments = ImageAdjustments();
    
    final newHistory = [
      ...state.history.sublist(0, state.historyIndex + 1),
      newAdjustments,
    ];

    emit(state.copyWith(
      adjustments: newAdjustments,
      history: newHistory,
      historyIndex: newHistory.length - 1,
      processedImageBytes: state.imageBytes,
      status: EditorStatus.loaded,
    ));
  }

  Future<void> _onUndo(
    UndoEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (!state.canUndo) return;

    _debounceTimer?.cancel();
    
    final newIndex = state.historyIndex - 1;
    final newAdjustments = state.history[newIndex];

    emit(state.copyWith(
      status: EditorStatus.processing,
      adjustments: newAdjustments,
      historyIndex: newIndex,
    ));

    await _processImage(emit, newAdjustments, addToHistory: false);
  }

  Future<void> _onRedo(
    RedoEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (!state.canRedo) return;

    _debounceTimer?.cancel();
    
    final newIndex = state.historyIndex + 1;
    final newAdjustments = state.history[newIndex];

    emit(state.copyWith(
      status: EditorStatus.processing,
      adjustments: newAdjustments,
      historyIndex: newIndex,
    ));

    await _processImage(emit, newAdjustments, addToHistory: false);
  }

  void _onToggleCompare(
    ToggleCompareEvent event,
    Emitter<EditorState> emit,
  ) {
    emit(state.copyWith(isComparing: !state.isComparing));
  }

  Future<void> _onSaveImage(
    SaveImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (state.processedImageBytes == null) return;

    emit(state.copyWith(status: EditorStatus.saving));

    try {
      final result = await ImageGallerySaver.saveImage(
        state.processedImageBytes!,
        quality: 100,
        name: 'LumiEdit_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (isClosed) return;

      if (result['isSuccess'] == true) {
        emit(state.copyWith(status: EditorStatus.saved));
        // Reset to loaded state after showing success
        await Future.delayed(const Duration(milliseconds: 500));
        if (!isClosed) {
          emit(state.copyWith(status: EditorStatus.loaded));
        }
      } else {
        emit(state.copyWith(
          status: EditorStatus.error,
          errorMessage: 'Failed to save image',
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: EditorStatus.error,
          errorMessage: 'Failed to save image: $e',
        ));
      }
    }
  }

  Future<void> _onExportImage(
    ExportImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (state.imageBytes == null) return;

    emit(state.copyWith(status: EditorStatus.processing));

    try {
      final processedBytes = await ImageProcessor.processImage(
        state.imageBytes!,
        state.adjustments,
      );

      if (!isClosed) {
        emit(state.copyWith(
          status: EditorStatus.loaded,
          processedImageBytes: processedBytes,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: EditorStatus.error,
          errorMessage: 'Failed to export image: $e',
        ));
      }
    }
  }

  Future<void> _processImage(
    Emitter<EditorState> emit,
    ImageAdjustments adjustments, {
    bool addToHistory = true,
  }) async {
    if (state.imageBytes == null) return;

    try {
      if (addToHistory) {
        final newHistory = [
          ...state.history.sublist(0, state.historyIndex + 1),
          adjustments,
        ];
        emit(state.copyWith(
          history: newHistory,
          historyIndex: newHistory.length - 1,
        ));
      }

      final processedBytes = await ImageProcessor.processImage(
        state.imageBytes!,
        adjustments,
      );

      if (!isClosed) {
        emit(state.copyWith(
          status: EditorStatus.loaded,
          processedImageBytes: processedBytes,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: EditorStatus.error,
          errorMessage: 'Failed to process image: $e',
        ));
      }
    }
  }

  Future<void> _onCropImage(
    CropImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(status: EditorStatus.processing));
    try {
      final file = File(event.croppedPath);
      final bytes = await file.readAsBytes();
      emit(state.copyWith(
        status: EditorStatus.loaded,
        imagePath: event.croppedPath,
        imageBytes: bytes,
        processedImageBytes: bytes,
        adjustments: const ImageAdjustments(),
        history: [const ImageAdjustments()],
        historyIndex: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to crop image: $e',
      ));
    }
  }

  Future<void> _onRotateImage(
    RotateImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (state.imageBytes == null) return;
    emit(state.copyWith(status: EditorStatus.processing));
    try {
      final rotatedBytes = await ImageProcessor.rotateImage(state.imageBytes!, event.degrees);
      emit(state.copyWith(
        status: EditorStatus.loaded,
        imageBytes: rotatedBytes,
        processedImageBytes: rotatedBytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to rotate image: $e',
      ));
    }
  }

  Future<void> _onFlipImage(
    FlipImageEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (state.imageBytes == null) return;
    emit(state.copyWith(status: EditorStatus.processing));
    try {
      final flippedBytes = await ImageProcessor.flipImage(state.imageBytes!, horizontal: event.horizontal);
      emit(state.copyWith(
        status: EditorStatus.loaded,
        imageBytes: flippedBytes,
        processedImageBytes: flippedBytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.error,
        errorMessage: 'Failed to flip image: $e',
      ));
    }
  }
}

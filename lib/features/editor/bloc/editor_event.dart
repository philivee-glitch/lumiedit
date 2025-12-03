import 'package:equatable/equatable.dart';
import '../../../core/constants/editor_constants.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadImageEvent extends EditorEvent {
  final String imagePath;

  const LoadImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class PickImageFromGalleryEvent extends EditorEvent {}

class PickImageFromCameraEvent extends EditorEvent {}

class UpdateAdjustmentEvent extends EditorEvent {
  final AdjustmentType type;
  final double value;

  const UpdateAdjustmentEvent({required this.type, required this.value});

  @override
  List<Object?> get props => [type, value];
}

class ApplyFilterEvent extends EditorEvent {
  final FilterType filter;

  const ApplyFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ApplyAIMagicEvent extends EditorEvent {}

class ResetAdjustmentsEvent extends EditorEvent {}

class UndoEvent extends EditorEvent {}

class RedoEvent extends EditorEvent {}

class ToggleCompareEvent extends EditorEvent {}

class SaveImageEvent extends EditorEvent {}

class ExportImageEvent extends EditorEvent {
  final int quality;

  const ExportImageEvent({this.quality = 100});

  @override
  List<Object?> get props => [quality];
}

class CropImageEvent extends EditorEvent {
  final String croppedPath;

  const CropImageEvent(this.croppedPath);

  @override
  List<Object?> get props => [croppedPath];
}

class RotateImageEvent extends EditorEvent {
  final int degrees;

  const RotateImageEvent(this.degrees);

  @override
  List<Object?> get props => [degrees];
}

class FlipImageEvent extends EditorEvent {
  final bool horizontal;

  const FlipImageEvent({required this.horizontal});

  @override
  List<Object?> get props => [horizontal];
}

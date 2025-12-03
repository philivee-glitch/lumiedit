import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/editor_constants.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../widgets/adjustment_slider.dart';
import '../widgets/adjustment_button.dart';
import '../widgets/filter_preview.dart';
import '../widgets/ai_magic_button.dart';
import '../widgets/compare_slider.dart';
import '../widgets/tool_tab_bar.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  EditorTab _selectedTab = EditorTab.adjust;
  AdjustmentType? _activeAdjustment;
  bool _showRadialDial = false;

  void _showExitConfirmation(BuildContext context, EditorState state) {
    if (!state.hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Discard changes?', style: AppTheme.headlineMedium),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Editing',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Discard',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditorBloc(),
      child: BlocConsumer<EditorBloc, EditorState>(
        listener: (context, state) {
          if (state.status == EditorStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Image saved to gallery!'),
                  ],
                ),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state.status == EditorStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage ?? 'An error occurred')),
                  ],
                ),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: !state.hasChanges,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && state.hasChanges) {
                _showExitConfirmation(context, state);
              }
            },
            child: Scaffold(
              backgroundColor: AppTheme.backgroundDark,
              resizeToAvoidBottomInset: false,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildHeader(context, state),
                      Expanded(
                        child: _buildImageArea(context, state),
                      ),
                      _buildToolBar(context, state),
                      _buildToolPanel(context, state),
                      _buildActionBar(context, state),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EditorState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (state.hasChanges) {
                _showExitConfirmation(context, state);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                '✦',
                style: TextStyle(fontSize: 24, color: AppTheme.primaryOrange),
              ),
              const SizedBox(width: 8),
              Text('LumiEdit', style: AppTheme.headlineMedium),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: state.canUndo
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<EditorBloc>().add(UndoEvent());
                      }
                    : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.undo_rounded,
                    color: state.canUndo
                        ? AppTheme.textSecondary
                        : AppTheme.textTertiary.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: state.canRedo
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.read<EditorBloc>().add(RedoEvent());
                      }
                    : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.redo_rounded,
                    color: state.canRedo
                        ? AppTheme.textSecondary
                        : AppTheme.textTertiary.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea(BuildContext context, EditorState state) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: state.hasImage
                    ? state.isComparing && state.imageBytes != null
                        ? CompareSlider(
                            originalImage: state.imageBytes!,
                            editedImage: state.processedImageBytes ?? state.imageBytes!,
                          )
                        : Image.memory(
                            state.processedImageBytes ?? state.imageBytes!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          )
                    : _buildImagePlaceholder(context),
              ),
            ),
          ),
        ),

        if (state.hasImage)
          Positioned(
            top: 28,
            left: 28,
            right: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<EditorBloc>().add(ToggleCompareEvent());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: state.isComparing
                          ? AppTheme.primaryOrange.withOpacity(0.3)
                          : Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.isComparing
                            ? AppTheme.primaryOrange.withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.compare_rounded,
                          size: 16,
                          color: state.isComparing ? AppTheme.primaryOrange : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Compare',
                          style: AppTheme.bodyMedium.copyWith(
                            color: state.isComparing ? AppTheme.primaryOrange : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AIMagicButton(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.read<EditorBloc>().add(ApplyAIMagicEvent());
                  },
                  isProcessing: state.isAIMagicProcessing,
                ),
              ],
            ),
          ),

        if (state.status == EditorStatus.processing)
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Processing...', style: AppTheme.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),

        if (_showRadialDial && _activeAdjustment != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdjustmentSlider(
            label: _activeAdjustment!.label,
            value: state.adjustments.getValue(_activeAdjustment!),
            minValue: _activeAdjustment!.minValue,
            maxValue: _activeAdjustment!.maxValue,
            onChanged: (value) {
              context.read<EditorBloc>().add(
                    UpdateAdjustmentEvent(type: _activeAdjustment!, value: value),
                  );
            },
            onClose: () {
              setState(() {
                _showRadialDial = false;
                _activeAdjustment = null;
              });
            },
          ),
          ),

        if (state.isAIMagicProcessing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('AI analyzing your photo...', style: AppTheme.bodyLarge),
                ],
              ),
            ),
          ),

        if (state.status == EditorStatus.saving)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Saving image...', style: AppTheme.bodyLarge),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceLight, AppTheme.backgroundMedium],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('Select a photo to edit', style: AppTheme.bodyMedium),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSourceButton(
                context,
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.read<EditorBloc>().add(PickImageFromGalleryEvent());
                },
              ),
              const SizedBox(width: 16),
              _buildSourceButton(
                context,
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.read<EditorBloc>().add(PickImageFromCameraEvent());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context, EditorState state) {
    return ToolTabBar(
      selectedTab: _selectedTab,
      onTabSelected: (tab) {
        HapticFeedback.selectionClick();
        setState(() => _selectedTab = tab);
      },
    );
  }

  Widget _buildToolPanel(BuildContext context, EditorState state) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildPanelContent(context, state),
    );
  }

  Widget _buildPanelContent(BuildContext context, EditorState state) {
    switch (_selectedTab) {
      case EditorTab.adjust:
        return _buildAdjustPanel(context, state);
      case EditorTab.beauty:
        return _buildBeautyPanel(context, state);
      case EditorTab.filters:
        return _buildFiltersPanel(context, state);
      case EditorTab.crop:
        return _buildCropPanel(context, state);
    }
  }

  Widget _buildAdjustPanel(BuildContext context, EditorState state) {
    final adjustments = AdjustmentType.values.where((type) => !type.isBeauty).toList();
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: adjustments.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final type = adjustments[index];
        return AdjustmentButton(
          type: type,
          value: state.adjustments.getValue(type),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _activeAdjustment = type;
              _showRadialDial = true;
            });
          },
        );
      },
    );
  }

  Widget _buildBeautyPanel(BuildContext context, EditorState state) {
    final beautyAdjustments = AdjustmentType.values.where((type) => type.isBeauty).toList();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AIBeautyButton(
            onTap: () {
              HapticFeedback.mediumImpact();
              for (final type in beautyAdjustments) {
                final presetValue = type == AdjustmentType.skinSmooth
                    ? 50.0
                    : type == AdjustmentType.blemishRemoval
                        ? 65.0
                        : type == AdjustmentType.skinTone
                            ? 25.0
                            : 35.0;
                context.read<EditorBloc>().add(UpdateAdjustmentEvent(type: type, value: presetValue));
              }
            },
            isProcessing: false,
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: beautyAdjustments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = beautyAdjustments[index];
              return AdjustmentButton(
                type: type,
                value: state.adjustments.getValue(type),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _activeAdjustment = type;
                    _showRadialDial = true;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersPanel(BuildContext context, EditorState state) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: FilterType.values.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final filter = FilterType.values[index];
        return FilterPreview(
          filter: filter,
          imageBytes: state.imageBytes,
          isSelected: state.adjustments.filter == filter,
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<EditorBloc>().add(ApplyFilterEvent(filter));
          },
        );
      },
    );
  }

  Widget _buildCropPanel(BuildContext context, EditorState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCropButton(
            icon: Icons.crop_rounded,
            label: 'Crop',
            onTap: () => _openCropper(context, state),
          ),
          _buildCropButton(
            icon: Icons.rotate_left_rounded,
            label: 'Rotate Left',
            onTap: () => context.read<EditorBloc>().add(const RotateImageEvent(-90)),
          ),
          _buildCropButton(
            icon: Icons.rotate_right_rounded,
            label: 'Rotate Right',
            onTap: () => context.read<EditorBloc>().add(const RotateImageEvent(90)),
          ),
          _buildCropButton(
            icon: Icons.flip_rounded,
            label: 'Flip H',
            onTap: () => _flipImage(context, state, horizontal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCropButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryOrange, size: 28),
            const SizedBox(height: 6),
            Text(label, style: AppTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Future<void> _openCropper(BuildContext context, EditorState state) async {
    if (state.imagePath == null) return;
    
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: state.imagePath!,
      uiSettings: [
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: false,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
        ),
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppTheme.backgroundDark,
          toolbarWidgetColor: AppTheme.textPrimary,
          backgroundColor: AppTheme.backgroundDark,
          activeControlsWidgetColor: AppTheme.primaryOrange,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (croppedFile != null && context.mounted) {
      context.read<EditorBloc>().add(CropImageEvent(croppedFile.path));
    }
  }

  Future<void> _flipImage(BuildContext context, EditorState state, {required bool horizontal}) async {
    if (state.imageBytes == null) return;
    context.read<EditorBloc>().add(FlipImageEvent(horizontal: horizontal));
  }

  Widget _buildActionBar(BuildContext context, EditorState state) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          top: BorderSide(color: AppTheme.textPrimary.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (state.hasChanges) {
                  _showExitConfirmation(context, state);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.textPrimary.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: state.hasImage && state.status != EditorStatus.saving
                  ? () {
                      HapticFeedback.mediumImpact();
                      context.read<EditorBloc>().add(SaveImageEvent());
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: state.hasImage && state.status != EditorStatus.saving
                      ? AppTheme.primaryGradient
                      : null,
                  color: state.hasImage && state.status != EditorStatus.saving ? null : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: state.hasImage && state.status != EditorStatus.saving
                      ? [BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save_alt_rounded,
                      color: state.hasImage && state.status != EditorStatus.saving ? Colors.white : AppTheme.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Save',
                      style: AppTheme.bodyLarge.copyWith(
                        color: state.hasImage && state.status != EditorStatus.saving ? Colors.white : AppTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

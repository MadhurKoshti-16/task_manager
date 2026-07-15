import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../domain/entities/task_entity.dart';

class AddEditTaskPage extends StatefulWidget {
  const AddEditTaskPage({super.key, this.task});
  final TaskEntity? task;
  bool get isEditing => task != null;
  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDueDate;
  late int _status;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedDueDate =
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _status = task?.status ?? TaskStatus.pending;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime(now.year + 10),
    );
    if (selectedDate == null || !mounted) {
      return;
    }
    setState(() {
      _selectedDueDate = selectedDate;
    });
  }

  void _saveTask() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.sessionExpiredMessage)),
      );
      return;
    }
    final now = DateTime.now();

    final existingTask = widget.task;
    final task = TaskEntity(
      id: existingTask?.id ?? const Uuid().v4(),
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      status: _status,
      createdAt: existingTask?.createdAt ?? now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
    Navigator.pop(context, task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? AppStrings.taskEditPageTitle
              : AppStrings.taskAddPageTitle,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            widget.isEditing
                                ? Icons.edit_note_rounded
                                : Icons.add_task_rounded,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.isEditing
                                ? AppStrings.taskFormEditTitle
                                : AppStrings.taskFormAddTitle,
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.taskFormSubtitle,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextFormField(
                      fieldKey: const Key('task_title_field'),
                      controller: _titleController,
                      label: AppStrings.taskTitleLabel,
                      hint: AppStrings.taskTitleHint,
                      prefixIcon: Icons.title_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final title = value?.trim() ?? '';
                        if (title.isEmpty) {
                          return AppStrings.taskTitleRequiredError;
                        }
                        if (title.length < 3) {
                          return AppStrings.taskTitleTooShortError;
                        }
                        if (title.length > 80) {
                          return AppStrings.taskTitleTooLongError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const Key('task_description_field'),
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 7,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskDescriptionLabel,
                        hintText: AppStrings.taskDescriptionHint,
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.taskDueDateLabel,
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(_selectedDueDate.readableDate),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _status == TaskStatus.completed
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(AppStrings.taskCompletedTitle),
                          subtitle: Text(
                            _status == TaskStatus.completed
                                ? AppStrings.taskCompletedSubtitle
                                : AppStrings.taskPendingSubtitle,
                          ),
                          value: _status == TaskStatus.completed,
                          onChanged: (value) {
                            setState(() {
                              _status = value
                                  ? TaskStatus.completed
                                  : TaskStatus.pending;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      buttonKey: const Key('save_task_button'),
                      label: widget.isEditing
                          ? AppStrings.taskUpdateButtonLabel
                          : AppStrings.taskCreateButtonLabel,
                      icon: widget.isEditing
                          ? Icons.save_outlined
                          : Icons.add_task_rounded,
                      onPressed: _saveTask,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

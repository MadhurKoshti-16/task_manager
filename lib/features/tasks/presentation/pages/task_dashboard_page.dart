import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart' show AppRoutes;
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/widgets/logout_confirmation_dialog.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/delete_task_dialog.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_view.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_search_field.dart';
import 'add_edit_task_page.dart';
import 'package:flutter/rendering.dart';
import '../../domain/entities/task_page_cursor.dart';

class TaskDashboardPage extends StatefulWidget {
  const TaskDashboardPage({super.key});
  @override
  State<TaskDashboardPage> createState() => _TaskDashboardPageState();
}

class _TaskDashboardPageState extends State<TaskDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  TaskPageCursor? _lastRequestedCursor;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<TaskBloc>().add(const TaskStarted());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final taskBloc = context.read<TaskBloc>();
    final taskState = taskBloc.state;

    if (position.userScrollDirection == ScrollDirection.idle) {
      return;
    }

    if (position.maxScrollExtent <= 0) {
      return;
    }

    if (taskState.isLoadingMore) {
      return;
    }

    // No additional remote/local page exists.
    if (!taskState.hasMore) {
      return;
    }

    // The first page has not finished loading.
    if (taskState.status == TaskViewStatus.loading) {
      return;
    }

    final cursor = taskState.nextCursor;

    // Pagination requires a valid cursor.
    if (cursor == null) {
      return;
    }

    // Do not request the same cursor more than once.
    if (_lastRequestedCursor == cursor) {
      return;
    }

    const paginationThreshold = 250.0;

    // extentAfter means the remaining scrollable distance
    // below the current viewport.
    final isNearBottom = position.extentAfter <= paginationThreshold;

    if (!isNearBottom) {
      return;
    }

    _lastRequestedCursor = cursor;

    taskBloc.add(const TaskLoadMoreRequested());
  }

  Future<void> _logout() async {
    final shouldLogout = await showLogoutConfirmationDialog(context: context);
    if (!mounted || !shouldLogout) {
      return;
    }
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  Future<void> _openTaskForm({TaskEntity? task}) async {
    final result = await Navigator.push<TaskEntity>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditTaskPage(task: task);
        },
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    if (task == null) {
      context.read<TaskBloc>().add(TaskAddRequested(result));
    } else {
      context.read<TaskBloc>().add(TaskUpdateRequested(result));
    }
  }

  Future<void> _deleteTask(TaskEntity task) async {
    final shouldDelete = await showDeleteTaskDialog(
      context: context,
      taskTitle: task.title,
    );
    if (!mounted || !shouldDelete) {
      return;
    }
    context.read<TaskBloc>().add(TaskDeleteRequested(task));
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: AppStrings.dashboardDismissAction,
            onPressed: () {
              context.read<TaskBloc>().add(const TaskMessageCleared());
            },
          ),
        ),
      );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            switch (state) {
              case AuthLoggedOut():
              case AuthUnauthenticated():
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              case AuthFailure(:final message):
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(message),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              case AuthInitial():
              case AuthLoading():
              case AuthAuthenticated():
                break;
            }
          },
        ),
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) {
            return previous.nextCursor != current.nextCursor ||
                previous.hasMore != current.hasMore;
          },
          listener: (context, state) {
            // A new page produced a new cursor, so the next
            //// pagination request is allowed.
            if (_lastRequestedCursor != state.nextCursor) {
              _lastRequestedCursor = null;
            }
            // No additional page remains.
            if (!state.hasMore) {
              _lastRequestedCursor = null;
            }
          },
        ),
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) {
            return previous.message != current.message &&
                current.message != null;
          },
          listener: (context, state) {
            final message = state.message;
            if (message != null) {
              _showMessage(message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.dashboardTitle),
          actions: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return IconButton(
                  tooltip: brightness == Brightness.dark
                      ? AppStrings.dashboardThemeToggleLight
                      : AppStrings.dashboardThemeToggleDark,
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme(brightness);
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(brightness),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) {
                return previous is AuthLoading || current is AuthLoading;
              },
              builder: (context, state) {
                final isLoggingOut = state is AuthLoading;
                return IconButton(
                  tooltip: 'Logout',
                  onPressed: isLoggingOut ? null : _logout,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isLoggingOut
                        ? const SizedBox(
                            key: ValueKey('logout-loader'),
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                            key: ValueKey('logout-icon'),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openTaskForm(),
          icon: const Icon(Icons.add_rounded),
          label: const Text(AppStrings.dashboardAddTaskButton),
        ),
        body: SafeArea(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state.status == TaskViewStatus.loading &&
                  state.allTasks.isEmpty &&
                  !state.isLoadingMore) {
                return const Center(child: CircularProgressIndicator());
              }
              final hasFilters =
                  state.searchQuery.isNotEmpty ||
                  state.statusFilter != TaskStatusFilter.all ||
                  state.dueDateFilter != TaskDueDateFilter.all ||
                  state.selectedDueDate != null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (state.isOffline)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              color: colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.dashboardOfflineMessage,
                                style: TextStyle(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.isSynchronizing) const LinearProgressIndicator(),
                    if (state.isSynchronizing) const SizedBox(height: 12),

                    TaskSearchField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<TaskBloc>().add(TaskSearchChanged(query));
                      },
                    ),
                    const SizedBox(height: 16),
                    TaskFilterBar(
                      statusFilter: state.statusFilter,
                      dueDateFilter: state.dueDateFilter,
                      selectedDueDate: state.selectedDueDate,
                      onStatusChanged: (filter) {
                        context.read<TaskBloc>().add(
                          TaskStatusFilterChanged(filter),
                        );
                      },
                      onDueDateChanged: (filter) {
                        context.read<TaskBloc>().add(
                          TaskDueDateFilterChanged(filter),
                        );
                      },
                      onDateSelected: (date) {
                        context.read<TaskBloc>().add(TaskDueDateSelected(date));
                      },
                      onDateCleared: () {
                        context.read<TaskBloc>().add(
                          const TaskDueDateCleared(),
                        );
                      },
                    ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<TaskBloc>().add(
                            const TaskRefreshRequested(),
                          );
                          await context.read<TaskBloc>().stream.firstWhere(
                            (state) => !state.isSynchronizing,
                          );
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 120),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  const SizedBox(height: 22),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 320),
                                    child: state.visibleTasks.isEmpty
                                        ? TaskEmptyView(
                                            key: const ValueKey(
                                              'empty-task-view',
                                            ),
                                            hasFilters: hasFilters,
                                          )
                                        : Column(
                                            key: ValueKey(
                                              state.visibleTasks
                                                  .map((task) => task.id)
                                                  .join(),
                                            ),
                                            children: state.visibleTasks
                                                .map((task) {
                                                  return TaskCard(
                                                    key: ValueKey(task.id),
                                                    task: task,
                                                    onEdit: () {
                                                      _openTaskForm(task: task);
                                                    },
                                                    onDelete: () {
                                                      _deleteTask(task);
                                                    },
                                                    onStatusChanged: () {
                                                      context.read<TaskBloc>().add(
                                                        TaskStatusToggleRequested(
                                                          task,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                })
                                                .toList(growable: false),
                                          ),
                                  ),
                                  if (state.isLoadingMore &&
                                      state.allTasks.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (!state.hasMore &&
                                      state.allTasks.isNotEmpty) ...[
                                    const SizedBox(height: 22),
                                    Center(
                                      child: Text(
                                        AppStrings.dashboardEndOfListMessage,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'Task Manager';

  static const String splashWelcome = 'Welcome to';
  static const String splashTitle = 'Task Manager';
  static const String splashDescription =
      'Plan your day, organize your work,\nand achieve your goals.';

  static const String loading = 'Preparing your workspace...';

  static const String pageNotFound = 'Page not found';
  static const String pageNotExist = 'The requested page does not exist.';

  static const String tryAgain = 'Try again';
  static const String startUpFailed = 'Startup failed';

  static const String authWelcomeBackTitle = 'Welcome back';
  static const String authWelcomeBackDescription =
      'Sign in to organize your tasks and continue achieving your goals.';
  static const String authEmailAddressLabel = 'Email address';
  static const String authEmailHint = 'you@example.com';
  static const String authPasswordLabel = 'Password';
  static const String authPasswordHint = 'Enter your password';
  static const String authPasswordShowTooltip = 'Show password';
  static const String authPasswordHideTooltip = 'Hide password';
  static const String authLoginButtonLabel = 'Sign in';
  static const String authNewToAppPrompt = 'New to Task Manager?';
  static const String authCreateAccountButtonLabel = 'Create account';

  static const String authRegisterTitle = 'Create your account';
  static const String authRegisterDescription =
      'Start planning smarter and keep every important task in one place.';
  static const String authRegisterPasswordHint = 'Create a strong password';
  static const String authConfirmPasswordLabel = 'Confirm password';
  static const String authConfirmPasswordHint = 'Enter the password again';
  static const String authRegisterButtonLabel = 'Create account';
  static const String authAlreadyRegisteredPrompt = 'Already registered?';
  static const String authSignInButtonLabel = 'Sign in';

  static const String sessionExpiredMessage =
      'Your session has expired. Please log in again.';

  static const String taskAddPageTitle = 'Add task';
  static const String taskEditPageTitle = 'Edit task';
  static const String taskFormEditTitle = 'Update your task';
  static const String taskFormAddTitle = 'Plan something new';
  static const String taskFormSubtitle =
      'Add clear details and choose when it should be completed.';
  static const String taskTitleLabel = 'Title';
  static const String taskTitleHint = 'Enter task title';
  static const String taskTitleRequiredError = 'Task title is required.';
  static const String taskTitleTooShortError = 'Enter at least 3 characters.';
  static const String taskTitleTooLongError =
      'Title cannot exceed 80 characters.';
  static const String taskDescriptionLabel = 'Description';
  static const String taskDescriptionHint =
      'Add more information about this task';
  static const String taskDueDateLabel = 'Due date';
  static const String taskCompletedTitle = 'Task completed';
  static const String taskCompletedSubtitle =
      'This task is marked as completed.';
  static const String taskPendingSubtitle = 'This task is currently pending.';
  static const String taskCreateButtonLabel = 'Create task';
  static const String taskUpdateButtonLabel = 'Update task';

  static const String dashboardTitle = 'My Tasks';
  static const String dashboardThemeToggleLight = 'Use light theme';
  static const String dashboardThemeToggleDark = 'Use dark theme';
  static const String dashboardAddTaskButton = 'Add task';
  static const String dashboardDismissAction = 'Dismiss';
  static const String dashboardOfflineMessage =
      'Offline mode. Changes will synchronize later.';
  static const String dashboardEndOfListMessage = 'You have reached the end.';

  static const String taskSearchHint = 'Search tasks by title';
  static const String taskSearchClearTooltip = 'Clear search';
  static const String taskFilterDueDateLabel = 'Due date filter';
  static const String taskFilterAll = 'All';
  static const String taskFilterPending = 'Pending';
  static const String taskFilterCompleted = 'Completed';
  static const String taskFilterAllDates = 'All dates';
  static const String taskFilterToday = 'Today';
  static const String taskFilterUpcoming = 'Upcoming';
  static const String taskFilterOverdue = 'Overdue';
  static const String taskCardSyncTooltip = 'Waiting for synchronization';
  static const String taskCardTodayLabel = 'Today';
  static const String taskCardActionsTooltip = 'Task actions';
  static const String taskCardEditAction = 'Edit';
  static const String taskCardDeleteAction = 'Delete';

  static const String taskEmptyNoMatching = 'No matching tasks';
  static const String taskEmptyNoTasks = 'No tasks yet';
  static const String taskEmptyNoMatchingHelp =
      'Try changing the search text or selected filters.';
  static const String taskEmptyNoTasksHelp =
      'Tap the add button to create your first task.';

  static const String deleteTaskDialogTitle = 'Delete task?';
  static String deleteTaskDialogMessage(String taskTitle) =>
      '“$taskTitle” will be removed. This action cannot be undone.';
  static const String deleteTaskDialogCancel = 'Cancel';
  static const String deleteTaskDialogDelete = 'Delete';

  static const String logout = 'Logout';
  static const String logoutContent =
      'Are you sure you want to logout from Task Manager?';
  static const String cancel = 'Cancel';
}

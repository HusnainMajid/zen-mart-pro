# Implementation Plan - Admin UI Dark Theme Fixes

Fix visibility issues in the Admin Dashboard and Analytics screens when using Dark Theme.

## User Review Required

> [!IMPORTANT]
> The current UI uses some hardcoded colors (like `Colors.grey[700]`) and relies on `Theme.of(context).primaryColor`, which might not provide enough contrast in Material 3 Dark mode. I will switch these to use `Theme.of(context).colorScheme` and themed `TextTheme`.

## Proposed Changes

### Admin Dashboard

#### [MODIFY] [admin_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/admin_dashboard.dart)
- Update `_SummaryCard` to use themed colors for the title text instead of hardcoded `Colors.grey[700]`.
- Update `_QuickActionButton` to use `Theme.of(context).colorScheme.primary` for icons and labels, ensuring they are bright in dark mode.
- Adjust the background and border colors of `_QuickActionButton` to use `colorScheme.primaryContainer` or themed alpha values for better visibility.

### Analytics & Reports

#### [MODIFY] [analytics_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/analytics_screen.dart)
- Update `_RevenueChartCard` (LineChart):
    - Implement `getTitlesWidget` for `bottomTitles` to use themed text colors.
    - Set `gridData` colors to be more subtle but themed.
    - Ensure the chart line color uses `Theme.of(context).colorScheme.primary`.
- Update `_LegendItem` to use `Theme.of(context).textTheme.bodySmall` for text.
- Update `_TopListCard` to ensure list items and trailing text use themed colors.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero errors.

### Manual Verification
- Switch the app to Dark Theme.
- Verify that "Quick Actions" labels and icons in the Admin Dashboard are clearly visible.
- Verify that the "Revenue Trends" chart in the Analytics screen has visible titles and a clear line.
- Verify that all text in analytics cards is readable against the dark background.

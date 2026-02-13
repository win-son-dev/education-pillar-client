import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Screen size breakpoints
enum ScreenSize { small, medium, large }

/// Height mode for grid items
enum GridHeightMode {
  /// Use fixed aspect ratio
  aspectRatio,

  /// Use height as factor of screen width
  widthFactor,

  /// Use height as factor of screen height
  screenHeightFactor,
}

/// Configuration for responsive grid behavior
class ResponsiveGridConfig {
  final int smallColumns;
  final int mediumColumns;
  final int largeColumns;
  final double mediumBreakpoint;
  final double largeBreakpoint;
  final double? fixedAspectRatio;
  final double? heightFactor;
  final double? screenHeightFactor;
  final GridHeightMode heightMode;

  const ResponsiveGridConfig({
    this.smallColumns = 1,
    this.mediumColumns = 2,
    this.largeColumns = 3,
    this.mediumBreakpoint = 600,
    this.largeBreakpoint = 900,
    this.fixedAspectRatio,
    this.heightFactor,
    this.screenHeightFactor,
  }) : heightMode = screenHeightFactor != null
      ? GridHeightMode.screenHeightFactor
      : heightFactor != null
      ? GridHeightMode.widthFactor
      : GridHeightMode.aspectRatio,
        assert(
        (fixedAspectRatio != null ? 1 : 0) +
            (heightFactor != null ? 1 : 0) +
            (screenHeightFactor != null ? 1 : 0) <=
            1,
        'Can only use one of: fixedAspectRatio, heightFactor, or screenHeightFactor',
        );

  /// Half-screen height cards (for product cards with internal text)
  static const halfScreenHeight = ResponsiveGridConfig(
    smallColumns: 1,
    mediumColumns: 1,
    largeColumns: 2,
    screenHeightFactor: 0.55,
  );

  /// Product grid with dynamic height (height = width * 0.75)
  static const productGrid = ResponsiveGridConfig(
    smallColumns: 2,
    mediumColumns: 2,
    largeColumns: 3,
    heightFactor: 0.75,
  );


  static const videoGrid = ResponsiveGridConfig(
    smallColumns: 2,
    mediumColumns: 2,
    largeColumns: 3,
    mediumBreakpoint: 600,
    largeBreakpoint: 900,
    screenHeightFactor: 0.33,
  );

  /// Standard grid with fixed aspect ratio
  static const standardGrid = ResponsiveGridConfig(
    smallColumns: 1,
    mediumColumns: 2,
    largeColumns: 3,
    fixedAspectRatio: 0.75,
  );

  /// Compact grid (more columns)
  static const compactGrid = ResponsiveGridConfig(
    smallColumns: 2,
    mediumColumns: 3,
    largeColumns: 4,
    fixedAspectRatio: 1.0,
  );
}

/// A responsive sliver grid that automatically adjusts columns and aspect ratio
/// based on screen width breakpoints with built-in skeleton loading support
class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ResponsiveGridConfig config;
  final bool isLoading;
  final int skeletonCount;

  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.config = ResponsiveGridConfig.productGrid,
    this.isLoading = false,
    this.skeletonCount = 6,
  });

  ScreenSize _getScreenSize(double width) {
    if (width >= config.largeBreakpoint) return ScreenSize.large;
    if (width >= config.mediumBreakpoint) return ScreenSize.medium;
    return ScreenSize.small;
  }

  int _getCrossAxisCount(double width) {
    final screenSize = _getScreenSize(width);
    switch (screenSize) {
      case ScreenSize.large:
        return config.largeColumns;
      case ScreenSize.medium:
        return config.mediumColumns;
      case ScreenSize.small:
        return config.smallColumns;
    }
  }

  double _getChildAspectRatio(BuildContext context, double width) {
    if (config.fixedAspectRatio != null) {
      return config.fixedAspectRatio!;
    }

    final columns = _getCrossAxisCount(width);
    final availableWidth = width - padding.horizontal;
    final itemWidth = (availableWidth - (crossAxisSpacing * (columns - 1))) / columns;

    double itemHeight;

    switch (config.heightMode) {
      case GridHeightMode.aspectRatio:
        return 0.75;

      case GridHeightMode.widthFactor:
        itemHeight = width * (config.heightFactor ?? 0.75);
        break;

      case GridHeightMode.screenHeightFactor:
        final screenHeight = MediaQuery.of(context).size.height;
        itemHeight = screenHeight * (config.screenHeightFactor ?? 0.5);
        break;
    }

    return itemWidth / itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    final displayChildren = isLoading
        ? List.generate(skeletonCount, (index) => children.first)
        : children;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;

        return SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(width),
              childAspectRatio: _getChildAspectRatio(context, width),
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => Skeletonizer(
                enabled: isLoading,
                child: displayChildren[index],
              ),
              childCount: displayChildren.length,
            ),
          ),
        );
      },
    );
  }
}

/// Non-sliver version for regular scrollable content
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ResponsiveGridConfig config;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool isLoading;
  final int skeletonCount;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.config = ResponsiveGridConfig.productGrid,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.isLoading = false,
    this.skeletonCount = 6,
  });

  ScreenSize _getScreenSize(double width) {
    if (width >= config.largeBreakpoint) return ScreenSize.large;
    if (width >= config.mediumBreakpoint) return ScreenSize.medium;
    return ScreenSize.small;
  }

  int _getCrossAxisCount(double width) {
    final screenSize = _getScreenSize(width);
    switch (screenSize) {
      case ScreenSize.large:
        return config.largeColumns;
      case ScreenSize.medium:
        return config.mediumColumns;
      case ScreenSize.small:
        return config.smallColumns;
    }
  }

  double _getChildAspectRatio(BuildContext context, double width) {
    if (config.fixedAspectRatio != null) {
      return config.fixedAspectRatio!;
    }

    final columns = _getCrossAxisCount(width);
    final availableWidth = width - padding.horizontal;
    final itemWidth = (availableWidth - (crossAxisSpacing * (columns - 1))) / columns;

    double itemHeight;

    switch (config.heightMode) {
      case GridHeightMode.aspectRatio:
        return 0.75;

      case GridHeightMode.widthFactor:
        itemHeight = width * (config.heightFactor ?? 0.75);
        break;

      case GridHeightMode.screenHeightFactor:
        final screenHeight = MediaQuery.of(context).size.height;
        itemHeight = screenHeight * (config.screenHeightFactor ?? 0.5);
        break;
    }

    return itemWidth / itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    final displayChildren = isLoading
        ? List.generate(skeletonCount, (index) => children.first)
        : children;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GridView.builder(
          controller: scrollController,
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(width),
            childAspectRatio: _getChildAspectRatio(context, width),
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: displayChildren.length,
          itemBuilder: (context, index) => Skeletonizer(
            enabled: isLoading,
            child: displayChildren[index],
          ),
        );
      },
    );
  }
}
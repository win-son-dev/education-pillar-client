import 'package:flutter/material.dart';

import '../../../../data/content_block_entity.dart';
import 'content_block.dart';
import 'content_block_config.dart';

class ContentBlocksRenderer extends StatelessWidget {
  final List<ContentBlockEntity> blocks;
  final ContentBlocksConfig? config;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const ContentBlocksRenderer({
    super.key,
    required this.blocks,
    this.config,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return _buildShrinkWrapContent();
    }

    return ListView.builder(
      controller: controller,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        return ContentBlock(
          block: blocks[index],
          config:  config,
        );
      },
    );
  }

  Widget _buildShrinkWrapContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) {
        return ContentBlock(
          block: block,
          config: config,
        );
      }).toList(),
    );
  }
}
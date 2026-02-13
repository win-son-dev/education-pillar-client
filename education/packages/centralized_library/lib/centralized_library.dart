library;

export 'domain/routes/app_route_constants.dart';
export 'domain/firebase/firebase_log.dart';

// Management
export 'package:flutter_svg/flutter_svg.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:flutter_cache_manager/flutter_cache_manager.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:go_router/go_router.dart';
export 'package:dio/dio.dart';
export 'package:path_provider/path_provider.dart';
export 'package:get_it/get_it.dart';
export 'package:uuid/uuid.dart';
export 'package:url_launcher/url_launcher.dart';

//Visualization
export 'package:lottie/lottie.dart';
export 'package:skeletonizer/skeletonizer.dart';
export 'package:animated_text_kit/animated_text_kit.dart';
export 'package:json_dynamic_widget/json_dynamic_widget.dart';
export 'package:json_theme/json_theme.dart';
export 'package:provider/provider.dart';

//Videos
export 'package:cached_video_player_plus/cached_video_player_plus.dart';
export 'package:video_player/video_player.dart';

// State Management
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:hydrated_bloc/hydrated_bloc.dart';
export 'package:equatable/equatable.dart';
export 'domain/firebase/firebase_asset_download_manager.dart';

//Language
export 'domain/models/language_model.dart';
export 'domain/models/translation_model.dart';
export 'domain/presentation/blocs/language_bloc.dart';
export 'domain/repositories/language_repository.dart';

// Firebase
export 'package:firebase_remote_config/firebase_remote_config.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_app_check/firebase_app_check.dart';
export 'package:cloud_functions/cloud_functions.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'domain/presentation/widgets/firebase_notification_service.dart';
export 'domain/presentation/widgets/local_notification_service.dart';


// Storage
export 'package:shared_preferences/shared_preferences.dart';
export 'package:hive_ce/hive.dart';
export 'package:hive_ce_flutter/hive_flutter.dart';
export 'domain/presentation/widgets/network_image_card.dart';
export 'domain/presentation/widgets/default_progress_indicator.dart';
export 'domain/presentation/widgets/lottie_loader.dart';
export 'domain/presentation/clippers/wave_clipper.dart';
export 'domain/presentation/widgets/media_loader.dart';
export 'domain/presentation/media/video_loader.dart';
export 'domain/presentation/widgets/contents/content_block_renderer.dart';
export 'domain/presentation/widgets/contents/content_block.dart';
export 'domain/presentation/widgets/contents/content_block_config.dart';
export 'data/content_block_entity.dart';
export 'domain/presentation/widgets/responsive_grid_config.dart';
export 'domain/presentation/media/audio_player_widget.dart';
export 'domain/presentation/media/fullscreen_image_viewer.dart';
export 'domain/presentation/media/full_screen_video_player.dart';
export 'domain/presentation/media/video_config.dart';
export 'domain/permissions/app_permission_handler.dart';
export 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Pagination
export 'domain/models/paginated_result.dart';

// API Content
export 'data/api_content_entity.dart';
export 'domain/repositories/i_api_content_repository.dart';
export 'domain/repositories/api_content_repository.dart';
export 'domain/repositories/cloud_api_content_repository.dart';
export 'utils/html_block_parser.dart';

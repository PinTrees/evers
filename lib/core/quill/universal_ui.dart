library universal_ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/youtube.dart';
import 'package:evers/core/context_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'responsive_widget.dart';
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui_instance;



/// Web 페이지의 Quill 디자인

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();

class ImageEmbedBuilderWeb extends EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
      BuildContext context,
      QuillController controller,
      Embed node,
      bool readOnly,) {
    final imageUrl = node.value.data;
    if (isImageBase64(imageUrl)) {
      // TODO: handle imageUrl of base64
      return const SizedBox();
    }
    final size = MediaQuery.of(context).size;
    UniversalUI().platformViewRegistry.registerViewFactory(imageUrl, (viewId) {
      return html.ImageElement()
        ..src = imageUrl
        ..style.height = 'auto'
        ..style.width = 'auto';
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.maxFinite,
      child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain,),
    );
  }
}


class VideoEmbedBuilderWeb extends EmbedBuilder {
  @override
  String get key => BlockEmbed.videoType;

  @override
  Widget build(
      BuildContext context,
      QuillController controller,
      Embed node,
      bool readOnly,
      ) {
    var videoUrl = node.value.data;

    UniversalUI().platformViewRegistry.registerViewFactory(
        videoUrl,
            (id) => html.IFrameElement()
          ..width = MediaQuery.of(context).size.width.toString()
          ..height = MediaQuery.of(context).size.height.toString()
          ..src = videoUrl
          ..style.border = 'none');

    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
      child: YoutubeContainer(style: YoutubeStyle(padding: EdgeInsets.all(18)),
      params: YoutubeParams(url: videoUrl),)
    );
  }
}


List<EmbedBuilder> get defaultEmbedBuildersWeb => [
  ImageEmbedBuilderWeb(),
  VideoEmbedBuilderWeb(),
];

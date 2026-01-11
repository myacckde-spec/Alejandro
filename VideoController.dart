
// CODE-REVIEW: стабильная VideoController-сессия

// Video widget всегда остаётся в дереве
//    Не пересоздаём Video по key при смене типа контента
//    Для слайдов и аудио будет работать  overlay / Offstage / Opacity

Stack(
  children: [
    Video(controller: controller), // всегда в дереве
    if (mediaState == MediaState.slide)
      RawImage(
        key: ValueKey(file.path),
        image: slideImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    if (mediaState == MediaState.audio)
      AudioPlaceholder(controller: controller),
  ],
);

//  Pause при slide


if (fileType == FileType.slide) {
  await controller.pause(); 
  _mediaState = MediaState.slide;
}


// Подготовка нового видео (замена source)


Future<void> prepareForNewVideo(VideoController controller, File newVideo) async {
  await controller.pause();           // остановить текущее видео
  await controller.seek(Duration.zero); // сбросить кадр
  await Future.delayed(const Duration(milliseconds: 50)); // делаем пауза для surface

  // Плейлист/Player: установить новый трек
  final index = scheduleTrackPlayerService.findOrAddTrack(newVideo);
  await scheduleTrackPlayerService.jumpTo(index);

  await controller.play();           

// Вызов в ViewModel при смене track:
if (fileType == FileType.video) {
  await scheduleTrackPlayerService.prepareForNewVideo(controller, file);
  _mediaState = MediaState.video;
}


// Auto-play / auto-advance


// Автоплей только для видео
final allowAutoPlay = fileType == FileType.video;
if (allowAutoPlay) {
  await scheduleTrackPlayerService.playTrack(
    file,
    seekDuration,
    track.tag,
    track.track.playlistSk,
    track.track.sk,
    track.track.filename,
    track.track.type,
    track.track.title,
    track.track.artist,
    track.track.campaignSk,
  );
}


// Итого


// VideoController живой, но работать должен  один на весь эфир
// Видео всегда в дереве
// Slide / Audio — overlay / Offstage
//  Перед новым видео: pause + seek + delay + jump
// Автоплей только для видео

// Это полностью должно  устранить мелькание старого кадра,
// дерганье при переключении slide -> video

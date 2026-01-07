// 1 Правку делаем этой части https://pastebin.com/758DLd8F

// Упрощайте сигнатуру метода

Widget _buildMediaByType(
  BuildContext context,
  FileType fileType,
  File? file,
  VideoController? controller,
)


// На такой вариант

Widget _buildMediaByType({
  required FileType fileType,
  File? file,
  VideoController? controller,
  ui.Image? slideImage,
})



// примерно так дожно выглядеть вцелом:

Widget _buildMediaByType({
  required FileType fileType,
  File? file,
  VideoController? controller,
  ui.Image? slideImage,
}) {
  switch (fileType) {
    case FileType.video:
      if (controller == null) {
        return const SizedBox.shrink(key: ValueKey('video_empty'));
      }

      return MediaPlayerWrapper(
        key: const ValueKey('video_player'),
        controller: controller,
      );

    case FileType.slide:
      if (slideImage != null && file != null) {
        return RawImage(
          key: ValueKey(file.path),
          image: slideImage,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
      }

      return Image.asset(
        'assets/no_image.jpg',
        key: const ValueKey('slide_asset'),
        fit: BoxFit.contain,
      );

    case FileType.audio:
      return _AudioPlaceholder(controller: controller);

    default:
      return const SizedBox.shrink(key: ValueKey('empty'));
  }
}


// Вынесите audio в отдельный widget
// что то такое наприммер


class _AudioPlaceholder extends StatelessWidget {
  final VideoController? controller;

  const _AudioPlaceholder({this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Icon(
            Icons.music_note,
            size: 120,
            color: Colors.white,
          ),
        ),
        if (controller != null)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Video(controller: controller),
          ),
      ],
    );
  }
}

// По идее :
// Метод _buildMediaByType сейчас выполняет слишком много задач:
// он выбирает тип медиа, обращается к ViewModel и думаю управляет анимациями.

// Наверно имеет смысл такое сделать:

// убрать доступ к context.read из метода

// передавать уже подготовленные данные (например, slideImage) параметрами

// вынести audio/video UI в отдельные widgets

// Это упростит хотя юы тестирование и повторное использование кода





Чтоб решить проблему думаю нужно


 удерживать VideoController живым между треками или хотя бы между типами контента.

т е один VideoController на весь эфир

Проблема в том, что:

video surface не очищается или не перекрывается наверняка

  т е 
  
  вместо

   switch (fileType) {
      case FileType.video:
        return controller != null
            ? MediaPlayerWrapper(
          key: const ValueKey('video_player'),
          controller: controller,
        )
            : const SizedBox.shrink(key: ValueKey('video_empty'));


  Сделать что то такое

    Stack(
      children: [
        Video(controller: controller), // всегда
        if (fileType == FileType.slide)
          RawImage(...)
        if (fileType == FileType.audio)
          AudioPlaceholder(...)
      ],
    )

  // видео не исчезает, не теряет surface и не по идее не будеьт всплывает старым кадром

  // Никогда не пересоздавайте Video widget по key

    // вместо этого:
       
    key: ValueKey(file.path)

  // для видео 
      // лучше так


  key: const ValueKey('video_surface')


// Итого
// Это должно помочь решить 
//     Старый кадр после слайда
//     Дёрганье при переключениях
//     Немного Архитектуру подправить
//     Может даже Чёрный экран при одиночных видео

// Короче говоря я думаю -  Артефакт со старым кадром возникает из-за того, что Video widget удаляется из дерева при показе слайдов.
// Flutter повторно использует video surface, и на 0.5–1 секунды появляется последний кадр предыдущего видео.

// Видео должно всегда оставаться в widget tree.
// При показе слайдов или аудио его нужно скрывать (Opacity / Offstage) - желательно а не удалять.

// _buildMediaByType отвечает только за выбор UI, 
//     но сам жизненный цикл 
//      video surface должен быть стабильным.
  


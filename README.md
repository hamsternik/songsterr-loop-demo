# Songsterr Loop Test -- Demo 

Demo iOS application to demonstrate the custom UI component (SwiftUI) to select loop section on the guitar tablature interface.

There are 2 main SwiftUI custom components that represent the entire UI/UX application logic:

- FretboardView (see the `FretboardView.swift`) represents single unified guitar fretboard measure.
- MultiFretboardContentView (see the `MultiFretboardContentView.swift`) represents the entire guitar tablature interface (w/o external components).

> [!WARNING]
> Almost the entire codebase was igenerated with the `claude code` CLI tool. I believe I will not achieve the same level of application behaviour for the 2.5 hours I spent working on the demo project. Good or bad, I hope as part of the prerequisites to the demo "using ai" is not a big problem. Even if the almost entire codebase was generated, the operator takes the key role!

Here is the approximate algorithm I was following while working out project requirements.

1. Formulate the initial prompt asking claude code to build the core functionalities of the app. The exact line to command looks like "to build guitar fretboard diagram component (guitar tabular interface) with capability to put guitar fret numbers based on the real song data." 
2. Simultaneously, I have worked out with domain knowledge related to the music theory, using Claude. Feeding the Figma mockup helps me a lot to build the core domain knowledge about the terminology, e.g. guitar fretboard diagram or guitar tablature interface.
3. Weaponised with domain knowledge about what things on the mock up are, I ended up to define the init prompt for claude code. Results: ready SwiftUI components such as `FretboardView`, `MultiFretboardContentView` and `MainView`. 
4. Built bottom controls subview to keep "Play" and "Loop" buttons in one place instead of having both in the navigation toolbar. 
5. Working over the "Capo" (green) line simple movement animation algorithm. Defined features as "infinite loop" animation and conditional animations, using `isPlaying` and `isLoopSelected`. 
6. Drove `claude code` from the wrong direction. Using `TabData` custom data structure in the `FretboardView` view was the mistake, so I asked to redesign that part: to remove TabData from FretboardView and to manage animation state only in the MultiFretboardContentView. Using Timer-based Animation (60fps) to be able to drive the animation process programmatically. 
7. Iterativally fixed many bugs happen during the development. E.g. "when user does not select a particular measure with the Loop button, the Play button does not trigger the animation.". 

## Demo Requirements (ru)

```text
Запишите скринкаст создания демо-проекта и реализации UI-контрола выделения зацикленного участка таба. Поведение — по аналогии с поведением функции Loop на вебе: https://www.songsterr.com/a/wsa/led-zeppelin-stairway-to-heaven-tab-s27 (если недоступна — Loop > Try out Loop Mode on the Demo Song). Нам важно понять ход ваших мыслей, не стесняйтесь их проговаривать в микрофон.

Технологии и ресурсы:

Можно использовать любой вариант реализации (UIKit или SwiftUI) и ресурсы — нейросети, документацию, поиск.
```

## Resources

1. Stairway to Heaven Tab -- Loop feature | Demo

URL: https://www.songsterr.com/a/wsa/led-zeppelin-stairway-to-heaven-tab-s27t1

# iProBonus SwiftUI UI Components V7

## Overview

`ipbswiftui_v7` is a SwiftUI-based UI component library designed to work seamlessly with the [ipbswiftapi_v7](https://github.com/progressterra/ipbswiftapi_v7) package. This library provides a comprehensive suite of user interface components tailored for the [iProBonus](https://iprobonus.com) platform, making it easier to create visually appealing and functional iOS applications. It leverages SwiftUI's declarative syntax and modern iOS design principles to provide a rich user experience.

## Features
- **SwiftUI-Optimized Components:** Designed specifically for SwiftUI, ensuring smooth integration and optimal performance.
- **Customizable UI Elements:** Highly customizable components to match your app's design language.
- **Reactive User Interface:** Built to work naturally with Combine for reactive and dynamic UI updates.
- **Seamless Integration with ipbswiftapi_v7:** Components are designed to interact efficiently with the `ipbswiftapi_v7` package for backend communications.

## Installation

To add `ipbswiftui_v7` to your SwiftUI project, follow these steps:

### Steps

1. **Open Your Project in Xcode:**
   - Launch Xcode and open your project.

2. **Add Package Dependency:**
   - Navigate to `File` > `Add Package Dependencies...`.
   - Enter the package repository URL: `https://github.com/progressterra/ipbswiftui_v7.git`.

3. **Specify the Version:**
   - Select the version of `ipbswiftui_v7` you wish to use.
   - Click `Add Package`.

4. **Import and Use the Package:**
   - In your SwiftUI views where you want to use the package, add `import ipbswiftui_v7`.
   - Start integrating the UI components into your app.

5. **Build Your Project:**
   - Compile your project to fetch and build the `ipbswiftui_v7` package.

### Troubleshooting

- Ensure that your Xcode and project settings are compatible with SwiftUI and the `ipbswiftui_v7` package.
- For issues or errors, refer to the [GitHub Issues page](https://github.com/progressterra/ipbswiftui_v7/issues) for `ipbswiftui_v7`.

## Configuration

### Style Configuration

`ipbswiftui_v7` can be customized using the `StyleConfig.json` file. This file allows you to define various UI attributes such as colors, button styles, and URLs. Below is the structure of the `StyleConfig.json` file with example values:

```json
{
    "offerURL": "https://progressterra.com",
    "privacyURL": "https://progressterra.com",

    "mandatoryProfileFields": ["photo", "name", "surname", "patronymic", "birthday", "sex", "phone"],
    "customProfileNavigationTitle": "Личные данные",
    "customProfileButtonTitle": "Далее",

    "buttonHeight": 50,
    "buttonCornerRadius": 14,

    "background": "#262223",
    "onBackground": "#001001",
    "primaryStart": "#7209b7",
    "primaryEnd": "#f72585",
    "secondary": "#3E4555",
    "secondary2": "#CDCDD6",
    "tertiary": "#B5B5BC",
    "surface": "#2e2e2d",
    "surface2": "#111111",
    "onSurface": "#54544e",
    "onSurface2": "#101010",
    
    "error": "#DF3636",
    "success": "#7ADB6B",
    "info": "#6980CF",
    "warning": "#DB742A",
    
    "iconsPrimary": "#111111",
    "iconsPrimary2": "#E82741",
    "iconsPrimary3": "#656565",
    "iconsSecondary": "#FFFFFF",
    "iconsTertiary": "#B5B5BC",
    "iconsTertiary2": "#4578DC",
    "iconsTertiary3": "#B2FF75",
    "iconsTertiary4": "#F6E651",
    
    "textPrimary": "#FFFFFF",
    "textPrimary2": "#E82741",
    "textSecondary": "#6E7289",
    "textTertiary": "#9191A1",
    "textTertiary2": "#453896",
    "textTertiary3": "#28AB13",
    "textTertiary4": "#CA451C",
    "textButtonPrimary": "#FFFFFF",
    
    "primaryPressed": "#3D3D3D",
    "primaryDisabled": "#70103c",
    "secondaryPressed": "#232427",
    "iconsPressed": "#0F1215",
    "iconsDisabled": "#B5B5B5",
    "textPressed": "#24282E",
    "textDisabled": "#B5B5B5"
}
```
### Loading the Configuration

Upon launching your app, you should load the configuration from the `StyleConfig.json` file in your project folder. This ensures that all the style settings you have defined are applied to the UI components of your app. To load the configuration, add the following line of code in a suitable place in your app's initialization process, such as in the `AppDelegate` or the SwiftUI `App` struct:

```swift
Style.loadConfiguration()
```

### Custom Fonts
By default `ipbswiftui_v7` uses system dynamic fonts:
```swift
public static var largeTitle = Font.largeTitle.bold()
public static var title = Font.title3.bold()
public static var headline = Font.headline.bold()
public static var body = Font.body
public static var body2 = Font.subheadline
public static var subheadlineRegular = Font.subheadline
public static var subheadlineItalic = Font.subheadline.weight(.semibold).italic()
public static var subheadlineBold = Font.subheadline.bold()
public static var footnoteRegular = Font.footnote
public static var footnoteBold = Font.footnote.bold()
public static var captionBold = Font.caption.bold()
```
But you can also specify custom fonts in your app. Here's how you can set them:
```swift
Style.largeTitle = .custom("Raleway-Bold", size: 28, relativeTo: .title)
Style.title = .custom("Raleway-Bold", size: 20, relativeTo: .title3)
Style.headline = .custom("Raleway-SemiBold", size: 17, relativeTo: .headline)
Style.body = .custom("Raleway-Regular", size: 17, relativeTo: .body)
Style.body2 = .custom("Raleway-SemiBold", size: 15, relativeTo: .subheadline)
Style.subheadlineRegular = .custom("Raleway-Regular", size: 15, relativeTo: .subheadline)
Style.subheadlineItalic = .custom("Raleway-Regular", size: 15, relativeTo: .subheadline)
Style.subheadlineBold = .custom("Raleway-SemiBold", size: 15, relativeTo: .subheadline)
Style.footnoteRegular = .custom("Raleway-Regular", size: 13, relativeTo: .footnote)
Style.footnoteBold = .custom("Raleway-SemiBold", size: 13, relativeTo: .footnote)
Style.captionBold = .custom("Raleway-SemiBold", size: 12, relativeTo: .caption2)
```

## Image Caching

The `ipbswiftui_v7` library leverages the Kingfisher library for efficient image loading and caching. You can configure the cache limits for both memory and disk to optimize performance based on your application's requirements.

To set up the cache limits, add the following code snippet at an appropriate place in your app, such as during initialization:

```swift
import Kingfisher

let imageCache = ImageCache.default

// Set the memory cache size to 256 MB
imageCache.memoryStorage.config.totalCostLimit = 256 * 1024 * 1024

// Set the disk cache size to 512 MB
imageCache.diskStorage.config.sizeLimit = 512 * 1024 * 1024
```

## Setting up ipbswiftapi_v7

Before you begin using `ipbswiftui_v7`, ensure that `ipbswiftapi_v7` is properly set up in your project. For detailed instructions on how to configure `ipbswiftapi_v7`, please refer to its official [documentation](https://github.com/progressterra/ipbswiftapi_v7).

Following the configuration guidelines for `ipbswiftapi_v7` will ensure seamless integration with `ipbswiftui_v7`, enabling you to leverage the full potential of both libraries in your SwiftUI applications.

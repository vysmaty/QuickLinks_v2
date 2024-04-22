<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->

<!-- Based on Best-README-Template. And we are creating something AMAZING! : See: https://github.com/vysmaty/QuickLinks_v2 -->

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/vysmaty/QuickLinks_v2">
    <img src="images/logo.png" alt="Logo" width="140" height="140">
  </a>

  <h3 align="center">QuickLinks v2</h3>

  <p align="center">
    Open anything anywhere!
    <br />
    <a href="https://github.com/vysmaty/QuickLinks_v2"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/vysmaty/QuickLinks_v2/archive/refs/heads/main.zip">Get It</a>
    ·
    <a href="https://github.com/vysmaty/QuickLinks_v2/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/vysmaty/QuickLinks_v2/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#written-with">Written with</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#setup">Setup</a></li>
        <li><a href="#translation">Translation</a></li>
        <li><a href="#script-files-structure">Script files structure</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
            <ul>
        <li><a href="#key-bindings">Key bindings</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com) <!-- TODO: Gif with menu -->

This script is based on **[QuickLinks](http://www.computoredge.com/AutoHotkey/AutoHotkey_Quicklinks_Menu_App.html)**, by [Jack Dunning](https://jacksautohotkeyblog.wordpress.com/2021/07/12/barebones-autohotkey-quicklinks-app/) and of subsequent adaptation **[QuickLinksMenu v2](https://github.com/dmtr99/QuickLinksMenu_V2)**, by [AHK_user](https://www.autohotkey.com/boards/viewtopic.php?p=429206#p429206) (aka dmtr99). It has been extended of functions from **[Easy Access to Favorite Folders](https://www.autohotkey.com/docs/v2/scripts/#FavoriteFolders)** (based on the v1 script by [Savage](https://www.autohotkey.com/docs/v1/scripts/#FavoriteFolders)).

The purpose of the script is to:
> Briskly **navigate** in Windows Explorer or dialogs ( Open / Save as ... ) **or just open** folder or run file from anywhere.

It is a simple tool combining the usefulness of amazing
**[Direct Folders](https://www.codesector.com/directfolders)** by [Code Sector](https://www.codesector.com/about)
and
**[Quick Access Popup](https://www.quickaccesspopup.com)** by [Jean Lalonde](http://www.jeanlalonde.ca)
that are better in every way at what they focus on.

This code creates a menu based on a directory, so it is easy to change and manage without changing any code. The source is open, and modifying or adding features to work with other file managers and non-typical dialogs is possible and **welcome**.

> Main features:
>
> * Create menu links from own shortcuts, files a folders
> * Show menu anywhere you want
> * Open linked folder/file/url
> * At file manager use link to navigate to path
> * At dialogue window use link to navigate to path
> * If window/tab with link path is open, switch to it
> * Quickly open/navigate/switch to recent files/folders
> * Quickly open/navigate/switch to opened file manager paths
> * Use icons from files/folders

There are many similar tools, but you usually need more of them because they can't do everything. They're not free to use for work - well, try to convince your employer to buy it – and you can't customize them for your workflow.

> Here's why you need something like this:
>
> * Your files should not be lost in dialogs and explorers. What you need to do your job should be at your fingertips.
> * Your time should be focused on creating something amazing. Not to searching for your things.
> * You shouldn't be doing the same tasks over and over like click through same folder structure.

_The aim is to make the menu visually simple, swift and helpful. The extra stuff has to be reducible and optional._

You may also suggest changes by creating a pull request or opening an issue. Thanks to all the people have contributed to this script!

Run the `QuickLinks.ahk` to get started.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Written with

[![Autohotkey][Autohotkey]][Autohotkey-url]

A free, open-source scripting language for Windows that allows users to easily create small to complex scripts for all kinds of tasks such as: form fillers, auto-clicking, macros, etc.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

You'll need `Autohotkey` `v2`. You can install it for a user or for everyone. Or you may just download it in a zip file. Whatever, but you have to be able to run the `.ahk`

> [!TIP]
> **[How to install Autohotkey](https://www.autohotkey.com/docs/v2/howto/Install.htm)**
>

### Setup

Since I haven't prepared a release, download [ziped repo](https://github.com/vysmaty/QuickLinks_v2/archive/refs/heads/main.zip) and unzip it where you need it.

There is no need to prepare much more.

* Start `QuickLinks.ahk` . The `Links` folder will create itself.
* Add `shortcuts` inside this folder for whatever you want.

>[!TIP]
> <kbd>Alt</kbd>+<kbd>Drag</kbd> or <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Drag</kbd>
>
> [Will create a shortcut to the file/folder in the new location](https://lifehacker.com/copy-move-and-create-shortcuts-in-windows-with-drag-a-1578530489)

* Structure your menu by creating `subfolders`.
* If you need you can edit the settings (_enable/disable features, etc..._) at the `settings.ini`.
* `Reload Script` and its changed settings using the command from `trayicon menu`.

>[!TIP]
> If you just need to rebuild the menu after changes in `Links` folder you can use the `Reload QuickLinks Menu` from the `Extended menu`

And that's it for the basic setup.

### Translation

If you want to have items in your language just turn on creating `lang_en.ini` in `settings.ini`. **Translate it** and save as new `lang_XX.ini`. And set `language code` in `settings.ini`.

### Script files structure

The script has uses this basic skeleton:

```bash
├── QuickLinks.ahk ;(<- Mandatory - Main Script )
├── settings.ini   ;(<- Mandatory - Your Config )
│
├── dependency     ;(<- Mandatory - Scripts Dependencies )
│       ├── ini_v2.ahk
│       └── …
│
├── lang_en.ini    ;(<- Optional - Translation)
│
└── Links          ;(<- Default folder for your links )
    │              ;(   Will be created if not exist! )
    │              ;(   Put Your Shortcuts, Folders, Files Here! )
    │
    ├── example_shortcut1.lnk
    ├── …
    └── example_submenu_folder
        ├── example_file.txt
        ├── example_shortcut2.lnk
        └── …
            └── …
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Key bindings

Default shortcuts are:

| Hotkey                                                             | Description        |
| :----------------------------------------------------------------- | :----------------- |
| <kbd>Ctrl</kbd> + <kbd>Right Mouse Button</kbd>                    | Show Simple Menu   |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Right Mouse Button</kbd> | Show Extended Menu |

<!--TODO: Examples. Screenshots. -->
Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

<!-- TODO: Wiki. If needed.
_For more examples, please refer to the [Documentation](https://example.com)_ -->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

* [x] Release first version
* [ ] Prepare README
  * [ ] Add Changelog

See the [open issues](https://github.com/vysmaty/QuickLinks_v2/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the GPL-3.0 license. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Autor: [https://github.com/vysmaty](https://github.com/vysmaty)

Project Link: [https://github.com/vysmaty/QuickLinks_v2](https://github.com/vysmaty/QuickLinks_v2)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

_Backbone:_

* [QuickLinks](http://www.computoredge.com/AutoHotkey/AutoHotkey_Quicklinks_Menu_App.html) by [Jack Dunning](https://jacksautohotkeyblog.wordpress.com/2021/07/12/barebones-autohotkey-quicklinks-app/)
* [QuickLinksMenu v2](https://github.com/dmtr99/QuickLinksMenu_V2) by [AHK_user](https://www.autohotkey.com/boards/viewtopic.php?p=429206#p429206) with special thanks to @swagfag and @just_me for helping with translating the DLLCall, NumGet and Numput functions to the v2
* [Easy Access to Favorite Folders](https://www.autohotkey.com/docs/v2/scripts/#FavoriteFolders) (based on the v1 script by [Savage](https://www.autohotkey.com/docs/v1/scripts/#FavoriteFolders)).

_Idols:_

* [Direct Folders](https://www.codesector.com/directfolders) by [Code Sector](https://www.codesector.com/about)
* [Quick Access Popup](https://www.quickaccesspopup.com) by [Jean Lalonde](http://www.jeanlalonde.ca)

_Conceiver:_

* [Microsoft](https://www.microsoft.com/cs-cz/), because if they weren't preventing efficient work, no one would have to create this

_And further credit belongs to:_

<!-- Use this space to list resources you find helpful and would like to give credit to. -->

* [Choose an Open Source License](https://choosealicense.com)
* [Img Shields](https://shields.io)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/vysmaty/QuickLinks_v2.svg?style=for-the-badge
[contributors-url]: https://github.com/vysmaty/QuickLinks_v2/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/vysmaty/QuickLinks_v2.svg?style=for-the-badge
[forks-url]: https://github.com/vysmaty/QuickLinks_v2/network/members
[stars-shield]: https://img.shields.io/github/stars/vysmaty/QuickLinks_v2.svg?style=for-the-badge
[stars-url]: https://github.com/vysmaty/QuickLinks_v2/stargazers
[issues-shield]: https://img.shields.io/github/issues/vysmaty/QuickLinks_v2.svg?style=for-the-badge
[issues-url]: https://github.com/vysmaty/QuickLinks_v2/issues
[license-shield]: https://img.shields.io/github/license/vysmaty/QuickLinks_v2.svg?style=for-the-badge
[license-url]: https://github.com/vysmaty/QuickLinks_v2/blob/master/LICENSE
[product-screenshot]: images/screenshot.png
[Autohotkey]: https://img.shields.io/badge/autohotkey-green?style=for-the-badge&logo=autohotkey&logoColor=white
[Autohotkey-url]: https://www.autohotkey.com

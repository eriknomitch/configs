module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 15,

    // font family with optional fallbacks
    //fontFamily: 'Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',
    fontFamily: 'Inconsolata, Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: 'rgba(248,28,229,0.7)',

    // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    cursorShape: 'BLOCK',

    // color of the text
    foregroundColor: '#fff',

    // terminal background color
    //backgroundColor: 'rgba(0, 0, 0, 0.8)',
    backgroundColor: 'rgb(0, 0, 0)',

    // border color (window, tabs)
    borderColor: '#0f0f0f',

    // custom css to embed in the main window
    css: '.tab_tab.tab_active { background: #222; } .tab_tab:not(.tab_active) { background: #0f0f0f; }',

    // custom css to embed in the terminal window
    termCSS: '',

    // set to `true` if you're using a Linux set up
    // that doesn't shows native menus
    // default: `false` on Linux, `true` on Windows (ignored on macOS)
    showHamburgerMenu: '',

    // set to `false` if you want to hide the minimize, maximize and close buttons
    // additionally, set to `'left'` if you want them on the left, like in Ubuntu
    // default: `true` on windows and Linux (ignored on macOS)
    showWindowControls: '',

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: '0px 0px',

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#000000',
      red: '#ff0000',
      green: '#33ff00',
      yellow: '#ffff00',
      blue: '#0066ff',
      magenta: '#cc00ff',
      cyan: '#00ffff',
      white: '#d0d0d0',
      lightBlack: '#808080',
      lightRed: '#ff0000',
      lightGreen: '#33ff00',
      lightYellow: '#ffff00',
      lightBlue: '#0066ff',
      lightMagenta: '#cc00ff',
      lightCyan: '#00ffff',
      lightWhite: '#ffffff'
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: '',

    // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
    // by default ['--login'] will be used
    shellArgs: ['--login'],

    // for environment variables
    env: {},

    // set to false for no bell
    bell: false,

    // if true, selected text will automatically be copied to the clipboard
    copyOnSelect: false,

    // URL to custom bell
    // bellSoundURL: 'http://example.com/bell.mp3',

    // for advanced config flags please refer to https://hyper.is/#cfg
    // other config...
    visor: {
      hotkey: 'CommandOrControl+Shift+Z',
      position: 'top', // or left, right, bottom
      width: 200, // Optional, defaults to half of viewable area for horizontal positions, 100% for vertical
      height: 900 // Optional, defaults to half of viewable area for vertical positions, 100% for horizontal
    }
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    'hyper-statusline'
  ],

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []

};
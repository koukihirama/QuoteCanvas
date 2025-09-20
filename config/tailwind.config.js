const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class', // OSのダークに引っ張られない
  // ※ 将来、[data-theme="dark"]でもdark:を効かせたいなら↓も可
  // darkMode: ['class', '[data-theme="dark"]'],
  content: [
    './public/*.html',
    './app/views/**/*.{erb,html,haml,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,ts}',
  ],
  theme: {
    extend: {
      fontFamily: { sans: ['Inter var', ...defaultTheme.fontFamily.sans] },
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ['light'], // v5で確実に存在するテーマに固定
  },
}
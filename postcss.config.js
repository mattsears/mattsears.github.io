
let environment = {
  plugins: [
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('autoprefixer'),
    require('tailwindcss/nesting')(require('postcss-nesting')),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
    require('tailwindcss')
  ]
}
module.exports = environment

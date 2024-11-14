// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../lib/*_web/**/*.*eex",
    "../lib/*_web/**/*.*heex",
    "../lib/*_web/**/*.*leex",
  ],
  theme: {
    data: {
      solved: 'solved~="true"',
    },
    extend: {
      fontFamily: {
        parking: ["Parking", "sans-serif"],
      },
    },
  },
};

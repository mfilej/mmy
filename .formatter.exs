[
  import_deps: [:ecto, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [TailwindFormatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]

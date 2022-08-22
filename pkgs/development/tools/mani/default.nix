{ buildGoModule, fetchFromGitHub, lib, installShellFiles, git, makeWrapper}:

buildGoModule rec {
  pname = "mani";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "alajmo";
    repo = "mani";
    rev = "v${version}";
    sha256 = "sha256-eH6V7J0KHGyR//kVr0dOdBYuoR3FDbW/pSh0RhHd4A8=";
  };

  vendorSha256 = "sha256-g336is8Jjbbzmtsu3suhO9SNq3IJyy1MQ3s8P39MhvU=";

  nativeBuildInputs = [ installShellFiles makeWrapper ];

  ldflags = [ "-s" "-w" "-X github.com/alajmo/mani/cmd.version=${version}" ];

  postInstall = ''
    installShellCompletion --cmd mani \
      --bash <($out/bin/mani completion bash) \
      --fish <($out/bin/mani completion fish) \
      --zsh <($out/bin/mani completion zsh)

    wrapProgram $out/bin/mani \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  # Skip tests
  # The repo's test folder has a README.md with detailed information. I don't
  # know how to wrap the dependencies for these integration tests so skip for now.
  doCheck = false;

  meta = with lib; {
    description = "CLI tool to help you manage multiple repositories";
    longDescription = ''
      mani is a CLI tool that helps you manage multiple repositories. It's useful
      when you are working with microservices, multi-project systems, many
      libraries or just a bunch of repositories and want a central place for
      pulling all repositories and running commands over them.
    '';
    homepage = "https://manicli.com/";
    changelog = "https://github.com/alajmo/mani/releases/tag/v${version}";
    license = licenses.mit;
  };
}

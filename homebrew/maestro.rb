# Homebrew formula for maestro
# To install: brew install Aditya060806/tap/maestro
# Or: brew tap Aditya060806/tap && brew install maestro

class Maestro < Formula
  desc "Maestro Framework - AI-assisted development workflows and automation"
  homepage "https://maestro.sh"
  url "https://github.com/Aditya060806/Maestro/archive/refs/tags/v3.6.113.tar.gz"
  sha256 "f01f343db6b3a8d77bc126d1d9fcd9798d24dff3f7d8387721aaadf98b7d6096"
  license "MIT"
  head "https://github.com/Aditya060806/Maestro.git", branch: "main"

  depends_on "bash"
  depends_on "jq"
  depends_on "curl"

  def install
    # Install the CLI script to libexec (not bin, to avoid double-write conflict)
    libexec.install "maestro.sh"
    (libexec/"maestro.sh").chmod 0755
    
    # Install setup script for manual setup
    libexec.install "setup.sh"
    (libexec/"setup.sh").chmod 0755
    
    # Install agent files
    (share/"maestro").install ".agents"
    (share/"maestro").install "VERSION"
    
    # Create wrapper in bin that prefers the git repo copy (always current
    # via 'maestro update') over the Homebrew-installed snapshot.
    (bin/"maestro").write <<~EOS
      #!/usr/bin/env bash
      # Prefer git repo copy — always current via 'maestro update'
      if [[ -f "$HOME/Git/maestro/maestro.sh" ]]; then
        exec bash "$HOME/Git/maestro/maestro.sh" "$@"
      fi
      # Fall back to Homebrew-installed copy
      export MAESTRO_SHARE="#{share}/maestro"
      exec "#{libexec}/maestro.sh" "$@"
    EOS
    (bin/"maestro").chmod 0755
  end

  def post_install
    # Run setup to deploy agents (non-interactive)
    ENV["MAESTRO_NON_INTERACTIVE"] = "true"
    system "bash", "#{libexec}/setup.sh", "--non-interactive"
  end

  def caveats
    <<~EOS
      maestro has been installed!

      Quick start:
        maestro status    # Check installation
        maestro init      # Initialize in a project
        maestro help      # Show all commands

      Agents deployed to: ~/.maestro/agents/

      To update:
        brew upgrade maestro
        # or
        maestro update
    EOS
  end

  test do
    assert_match "maestro", shell_output("#{bin}/maestro version")
  end
end

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    unzip \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (via NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create m4rocks user with zsh as default shell and passwordless sudo
RUN useradd -m -s /bin/zsh m4rocks \
    && echo "m4rocks ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/m4rocks \
    && chmod 0440 /etc/sudoers.d/m4rocks

USER m4rocks

# Install Oh My Zsh (unattended)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/home/m4rocks/.bun/bin:$PATH"

# Copy your .zshrc (overwrites the one Oh My Zsh generated)
COPY --chown=m4rocks:m4rocks .zshrc /home/m4rocks/.zshrc

# Make sure .zshrc has linux line endings
RUN sed -i 's/\r//' /home/m4rocks/.zshrc

# Fix GPG
RUN mkdir -p /home/m4rocks/.gnupg \
    && chmod 700 /home/m4rocks/.gnupg

# Trust directory for Git
RUN git config --global --add safe.directory "*"

WORKDIR /home/m4rocks

CMD ["/bin/zsh"]
FROM gitpod/workspace-full:latest

USER root
# Install custom tools, runtime, etc.
RUN apt-get update && apt-get install -y \
    zsh \
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* \
    && chsh --shell /usr/bin/zsh gitpod

USER gitpod
# Apply user-specific settings
#ENV ...

# Give back control
USER root
# set the base image to create the image for react app
FROM node:20-alpine as frontend

# create a user with permissions to run the app
# -S -> create a system user
# -G -> add the user to a group
# This is done to avoid running the app as root
# If the app is run as root, any vulnerability in the app can be exploited to gain access to the host system
# It's a good practice to run the app as a non-root user
RUN addgroup app && adduser -S -G app app

# set the user to run the app
USER app

# set the working directory to /app
WORKDIR /app

# copy package.json and package-lock.json to the working directory
# This is done before copying the rest of the files to take advantage of Docker’s cache
# If the package.json and package-lock.json files haven’t changed, Docker will use the cached dependencies
COPY frontend/package*.json ./

# sometimes the ownership of the files in the working directory is changed to root
# and thus the app can't access the files and throws an error -> EACCES: permission denied
# to avoid this, change the ownership of the files to the root user
USER root

# change the ownership of the /app directory to the app user
# chown -R <user>:<group> <directory>
# chown command changes the user and/or group ownership of for given file.
RUN chown -R app:app .

# change the user back to the app user
USER app

# install dependencies
RUN npm install

# copy the rest of the files to the working directory
COPY frontend .

# expose port 5173 to tell Docker that the container listens on the specified network ports at runtime

FROM alpine:latest as backend

RUN apk update && apk upgrade
RUN apk add --no-cache nodejs npm git curl zsh build-base gcc libc-dev pkgconfig libressl-dev musl-dev

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]
ENV SHELL /bin/zsh

# For security reason, it's best to create a user to avoid using root by default
RUN adduser -D appuser
USER appuser

ENV HOME /home/appuser
ENV PATH $PATH:$HOME/.local/bin:$HOME/.cargo/bin

# Install oh-my-zsh
RUN ash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Scarb
RUN ash -c "$(curl -fsSL https://docs.swmansion.com/scarb/install.sh)" -s -- -v 2.8.4

# Install Starknet Foundry
RUN ash -c "$(curl -fsSL https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh)" -s

RUN snfoundryup -v 0.31.0

# Verify installations
RUN scarb --version && \
    snforge --version

# Install Starknet devnet
# RUN ash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
# RUN cargo install starknet-devnet

WORKDIR /app
COPY --chown=appuser:appuser gruft-contract/ ./

RUN scarb build                                                                                      
# RUN snforge test

FROM alpine:latest

# Install system dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    zsh \
    gcompat

# Create user
RUN adduser -D appuser
USER appuser
ENV HOME /home/appuser
WORKDIR /app

# Copy frontend with its node_modules
COPY --from=frontend /app /app/frontend
# Copy backend
COPY --from=backend /app /app/gruft-contract

# Set permissions
USER root
RUN chown -R appuser:appuser /app
USER appuser

# Set working directory to frontend for running the dev server
WORKDIR /app/frontend

EXPOSE 5173

# command to run the app
CMD npm run dev
# Start both services
# CMD cd frontend && npm run dev & cd backend && scarb build

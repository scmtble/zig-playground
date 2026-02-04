# Zig Playground

A simple HTTP server example built with Zig and Nix.

## Features

- 🚀 HTTP server powered by Zig
- 📦 Development environment managed with Nix Flakes
- 🐳 Docker image build support

## Project Structure

```
.
├── build.zig        # Zig build configuration
├── build.zig.zon    # Zig package manifest
├── flake.nix        # Nix Flakes configuration
├── README.md
└── src/
    └── main.zig     # HTTP server main program
```

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download.html) (with Flakes enabled)

### Enter Development Shell

```bash
nix develop
```

### Build

```bash
zig build
```

### Run

```bash
zig build run
```

The server will start at `http://0.0.0.0:8080`.

### Build Docker Image

```bash
nix build .#docker
docker load < result
docker run -p 8080:8080 zig-playground:latest
```

## API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Returns "HELLO WORLD!" |

## License

MIT

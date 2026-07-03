FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV FLUTTER_SUPPRESS_ANALYTICS=true

WORKDIR /app

RUN flutter config --no-analytics \
    && flutter precache --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

CMD ["flutter", "analyze", "lib"]

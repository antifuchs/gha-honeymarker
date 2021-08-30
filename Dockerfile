FROM alpine:latest

LABEL "com.github.actions.name"="Honeycomb Honeymarker Github Actions"
LABEL "com.github.actions.description"="Add Honeycomb Markers to your GitHub Actions workflows."
LABEL "com.github.actions.color"="yellow"
LABEL "com.github.actions.icon"="activity"

LABEL "repository"="https://github.com/naiduarvind/gha-honeymarker"
LABEL "homepage"="https://github.com/naiduarvind"
LABEL "maintainer"="Arvind Naidu <no-reply@thebility.engineer>"

RUN apk add jq curl bash && \
    curl -L -o /bin/honeymarker https://github.com/honeycombio/honeymarker/releases/download/v0.2.0/honeymarker-linux-amd64 && \
    chmod +x /bin/honeymarker && \
    apk del curl
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Flagship — multi-stage, static binary on distroless nonroot (Kyverno-compliant: non-root, no shell).
FROM golang:1.25-alpine AS build
WORKDIR /src
# Cache deps.
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/flagship ./cmd/flagship

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/flagship /flagship
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/flagship"]

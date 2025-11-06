[![Image Publishing](https://img.shields.io/github/actions/workflow/status/snazy/minio-daily/build.yml?branch=main&event=schedule&label=Image+Publishing&logo=Github&style=flat-square)](https://github.com/users/snazy/packages/container/minio-daily/)

# MinIO daily container publishing

The MinIO container images are published to the GitHub Container Registry
[https://github.com/users/snazy/packages/container/minio-daily/](https://github.com/users/snazy/packages/container/minio-daily/)

The container repository contains both releases and daily builds.
Releases are tagged with the MinIO release tags, which start with `RELEASE.`.
The latest release is tagged `latest`.
Tags of daily builds start with `DAILY.` followed by the RFC-3339 timestamp of the build.
There is no latest-tag for daily builds.

## Console UI included

All built images include the most recent release of [console](https://github.com/georgmangold/console/) at the
time the image was built.

The console UI is started by default and exposed on port 9090.

To start the images _without_ the console UI, either pass the environment variable `NO_CONSOLE_UI=x` or 
specify the Docker entry point `/usr/bin/docker-entrypoint.sh`.
Both options do the effectively the same. 
```bash
docker run \
  --entrypoint /usr/bin/docker-entrypoint.sh \ 
  ghcr.io/snazy/minio-daily:latest
```
```bash
docker run \
  --env NO_CONSOLE_UI=x \ 
  ghcr.io/snazy/minio-daily:latest
```

## Ports by the images

- 9000: MinIO server
- 9090: Console UI (unless disabled)

## Disclaimer

The images built by this project are provided **as is** without any warranty or support!
Use at your own risk.

Issues in/with MinIO should be reported to the MinIO project:
[https://github.com/minio/minio](https://github.com/minio/minio).

MinIO® is a registered trademark of the MinIO Inc.
Neither this project nor its maintainers are affiliated, associated, authorized, endorsed by,
or in any way officially connected with MinIO Inc.

## Motivation

In October 2025 the MinIO project stopped publishing MinIO releases. Many open source projects rely on MinIO
and since then no longer receive MinIO updates via the binary distribution.

This project has been started to provide daily builds of MinIO,
initially with a multiplatform container image for the `linux/amd64` and `linux/arm64` platforms.

All published builds are generated using publicly inspectable GitHub workflow runs. 

## Build/publishing

This project is not a fork of the MinIO project, nor does it contain any code from the MinIO project.

The build/publishing workflow pulls from the MinIO project's
[minio/minio](https://github.com/minio/minio) and [minio/mc](https://github.com/minio/mc) repositories.
The binaries for the platforms mentioned above are built and eventually published to the
GitHub Container Registry.

## Contributing

See [Contributing to the project](CONTRIBUTING.md)

## Licensing

This project is licensed under the [Apache License v2](./LICENSE) (SPDX: `Apache-2.0`).
Code of the MinIO project is not and will not be included in this repository.

MinIO and therefore the images published via this project are licensed under the
[GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) (SPDX: `AGPL-3.0`).

Console, as a fork of the MinIO project, is licensed under the
[GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) (SPDX: `AGPL-3.0`).

When using the published images, please make sure to comply with the AGPL3 license.

The `LICENSE` and `NOTICE` of all included projects are included in the images' root directory.
You can inspect these files by starting the image using a shell. 
```bash
docker run \
  --rm \
  --interactive \
  --tty \
  --entrypoint /bin/bash \
  ghcr.io/snazy/minio-daily:latest
```
and then list the files using `ls -al` and inspect those for example with `cat LICENSE.minio`.

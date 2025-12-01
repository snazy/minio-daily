# Copyright (C) 2025 Robert Stupp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM registry.access.redhat.com/ubi9-minimal:9.7-1764578379

# Luckily Docker's TARGETPLATFORM matches Go's GOOS/GOARCH :)
# I.e.
#   linux/amd64 == $TARGETPLATFORM == $GOOS/$GOARCH
#   linux/arm64 == $TARGETPLATFORM == $GOOS/$GOARCH

ARG BUILDPLATFORM
ARG TARGETPLATFORM
RUN echo "Running on $BUILDPLAFORM, building for $TARGETPLATFORM"
COPY $TARGETPLATFORM .

RUN chmod 755 \
    /usr/bin/console \
    /usr/bin/minio \
    /usr/bin/mc \
    /usr/bin/docker-entrypoint.sh \
    /usr/bin/console-minio-entrypoint.sh

ENTRYPOINT ["/usr/bin/console-minio-entrypoint.sh"]

EXPOSE 9000
EXPOSE 9090
VOLUME ["/data"]

CMD ["minio"]

FROM buildpack-deps:sid-scm

RUN apt-get update && apt-get install -y --no-install-recommends \
		openjdk-8-jre-headless \
		openssh-server \
		\
		aufs-tools \
		btrfs-tools \
		e2fsprogs \
		iptables \
		xz-utils \
		\
		bsdmainutils \
	&& rm -rf /var/lib/apt/lists/* \
	&& sed -ri 's/^#?PermitRootLogin[[:space:]].*$/PermitRootLogin yes/g' /etc/ssh/sshd_config

ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034
RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
	&& chmod +x /usr/local/bin/dind

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.11.0 
ENV DOCKER_SHA256 87331b3b75d32d3de5d507db9a19a24dd30ff9b2eb6a5a9bdfaba954da15e16b 

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

ENV ENTRYPOINT_COMMIT 866c3fbd87e8eeed524fdf19ba2d63288ad49cd2
RUN curl -fSL "https://github.com/docker-library/docker/raw/${ENTRYPOINT_COMMIT}/${DOCKER_VERSION%.*}/dind/dockerd-entrypoint.sh" -o /usr/local/bin/dockerd-entrypoint.sh \
	&& chmod +x /usr/local/bin/dockerd-entrypoint.sh \
	&& sed -i 's!/bin/sh!/bin/bash!g' /usr/local/bin/dockerd-entrypoint.sh

RUN ssh-keygen -A
RUN echo 'root:docker' | chpasswd

# let's make /root a volume so ~/.ssh/authorized_keys is easier to save
VOLUME /root

EXPOSE 22
COPY i-am-a-terrible-person.sh /
ENTRYPOINT ["/i-am-a-terrible-person.sh"]
CMD []

FROM gitpod/workspace-full

ARG YB_RELEASE=2.20.0.0-b76
ARG YB_BIN_PATH=/usr/local/yugabyte
ARG ROLE=gitpod

USER $ROLE
# create bin and data path
RUN sudo mkdir -p $YB_BIN_PATH

# set permission
RUN sudo chown -R $ROLE:$ROLE /usr/local/yugabyte

# fetch the binary
RUN set -e && \
  export YB_RELEASE=${YB_RELEASE} && \
  export YB_VERSION=${YB_RELEASE%-*} && \
  curl -sSLo ./yugabyte.tar.gz https://downloads.yugabyte.com/releases/${YB_VERSION}/yugabyte-${YB_RELEASE}-linux-x86_64.tar.gz \
  && tar -xvf yugabyte.tar.gz -C $YB_BIN_PATH --strip-components=1 \
  && chmod +x $YB_BIN_PATH/bin/* \
  && rm ./yugabyte.tar.gz

# configure the interpreter
RUN ["/usr/local/yugabyte/bin/post_install.sh"]

# set the execution path and other env variables
ENV PATH="$YB_BIN_PATH/bin/:$PATH"
ENV HOST=127.0.0.1
ENV HOST_LB=127.0.0.1
ENV HOST_LB2=127.0.0.2
ENV HOST_LB3=127.0.0.3
ENV HOST_LB4=127.0.0.4
ENV HOST_LB5=127.0.0.5
ENV HOST_LB6=127.0.0.6
ENV YSQL_SOCK=5433
ENV YCQL_SOCK=9042
ENV MASTER_UI=7000
ENV TSERVER_UI=9000
ENV META_UI=15433
ENV YCQL_API=12000
ENV YSQL_API=13000

EXPOSE ${YSQL_SOCK} ${YCQL_SOCK} ${MASTER_UI} ${TSERVER_UI} ${META_UI} ${YSQL_API} ${YCQL_API}

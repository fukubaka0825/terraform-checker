FROM hashicorp/terraform:0.12.0

ENV TERRAFORM_VERSION=0.12.0
ENV TERRAGRUNT_VERSION=0.19.9
ENV TERRAGRUNT_TFPATH=/bin/terraform
ENV TFNOTIFY_VERSION=0.3.0

RUN apk add --update --no-cache --virtual .build-deps curl \
    && curl -sL https://github.com/mercari/tfnotify/releases/download/v${TFNOTIFY_VERSION}/tfnotify_v${TFNOTIFY_VERSION}_linux_amd64.tar.gz -o /tmp/tfnotify.tar.gz \
    && curl -sL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VERSION/terragrunt_linux_amd64 -o /bin/terragrunt && chmod +x /bin/terragrunt \
    && curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh \
    && tar zxvf /tmp/tfnotify.tar.gz -C /tmp \
    && cp /tmp/tfnotify_v${TFNOTIFY_VERSION}_linux_amd64/tfnotify /usr/local/bin/tfnotify \
    && rm -rf /tmp/* \
    && apk del --purge .build-deps

COPY . .
RUN terraform fmt -recursive -diff=true -check=true

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG SLACK_TOKEN
ARG SLACK_CHANNEL_ID
ARG SLACK_BOT_NAME
WORKDIR ./infra/aws/stage/test_ci
RUN ls -al
# terragrunt管理下のinfraチェック
RUN terragrunt init
RUN terraform plan | tfnotify plan

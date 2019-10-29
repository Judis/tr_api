FROM elixir:1.9.1

RUN mix local.hex --force \
 && mix archive.install --force  https://github.com/phoenixframework/archives/raw/master/phx_new-1.3.4.ez \
 && apt-get update \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && mix local.rebar --force

ENV APP_HOME /app
ENV DB_USERNAME postgres
ENV DB_PASSWORD postgres
ENV DB_HOSTNAME a63965570486_a63965570486_a63965570486_i18napi_db_1
ENV DB_NAME i18napi
ENV DB_PORT 25060
ENV BASE_SECRET_KEY 12345678
ENV GUARDIAN_SECRET_KEY 12345678
RUN mkdir -p $APP_HOME
COPY . $APP_HOME
WORKDIR $APP_HOME

EXPOSE $PORT

RUN ls -la
RUN mix local.hex --force
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile
RUN mix phx.digest
CMD mix ecto.create && mix ecto.migrate && mix phx.server

# Selenide Stub Project

Минимальный проект-заглушка на `Java 11` с одним UI-тестом на `Selenide 6.12.4`.

Что есть в проекте:

- `JUnit 5`
- `Selenide 6.12.4`
- один тест `ExampleDotOrgTest`
- настройка `chromedriver` под `Chrome 114`

Запуск:

```bash
mvn -Dmaven.repo.local=.m2 test
```

Если нужен запуск через удаленный Selenium-хаб с браузером `Chrome 114`, используйте системное свойство:

```bash
mvn -Dmaven.repo.local=.m2 -Dselenide.remote=http://localhost:4444/wd/hub test
```

Тест:

- открывает `https://example.org`
- проверяет заголовок `Example Domain`

Важно:

- локально на текущей машине установлен `Google Chrome 147`, поэтому exact-match запуск именно на локальном `Chrome 114` здесь не подтвержден;
- для строгой фиксации версии браузера `114` лучше запускать тесты через отдельный Selenium-контейнер или удаленный стенд с Chrome 114.

## Запуск в Docker

Для запуска тестов в контейнере добавлены:

- `Dockerfile` на базе `ubuntu:22.04`
- `docker-compose.yml` для запуска `mvn test` внутри контейнера
- поддержка установки `CryptoPro CSP`/`cryptcp` из локально подложенного дистрибутива

Что устанавливается в контейнер:

- `Java 11`
- `Maven`
- `Google Chrome 114.0.5735.90` из локального `.deb` в `src/main/resources`
- `cryptcp`, если положить дистрибутив КриптоПро в папку `cryptopro/`

Запуск:

```bash
docker compose up --build tests
```

Для Chrome используется локальный файл:

```bash
src/main/resources/google-chrome-stable_114.0.5735.90-1_amd64.deb
```

`chromedriver` отдельно больше не нужен: его подберет `WebDriverManager` во время запуска теста.

## Установка CryptoPro CSP и cryptcp

Из-за лицензирования дистрибутив КриптоПро в репозиторий не включен. Для установки положите ваш архив или набор пакетов в папку:

```bash
cryptopro/
```

Поддерживаются такие варианты:

- архив с установщиком, например `*.tgz` или `*.tar.gz`
- набор `*.deb`
- набор `*.rpm`

Во время сборки образа `Dockerfile` вызовет скрипт `install-cryptopro.sh`, который попробует:

- запустить `_FNS_INSTALLER.sh`
- или `install.sh`
- или установить `*.deb`
- или конвертировать и установить `*.rpm` через `alien`

После установки в контейнере ожидается стандартный путь КриптоПро:

```bash
/opt/cprocsp/bin/amd64/cryptcp
```

## Импорт ключа и сертификата в контейнер

В образ добавлен скрипт:

```bash
/usr/local/bin/import-cryptopro-materials.sh
```

Он умеет:

- импортировать `PFX` в контейнер `HDIMAGE`
- установить личный сертификат в контейнер
- установить корневой сертификат в `root`
- установить промежуточный сертификат в `uCA`

Переменные окружения:

- `CRYPTOPRO_AUTO_IMPORT=true` — выполнить импорт при старте контейнера
- `CRYPTOPRO_PFX_PATH` — путь к `pfx`
- `CRYPTOPRO_PFX_PIN` — пароль от `pfx`
- `CRYPTOPRO_CONTAINER_NAME` — имя контейнера, например `test`
- `CRYPTOPRO_CONTAINER_PIN` — PIN контейнера
- `CRYPTOPRO_CERT_PATH` — путь к личному сертификату `cer`, если его нужно отдельно привязать к контейнеру
- `CRYPTOPRO_ROOT_CERT_PATH` — путь к корневому сертификату
- `CRYPTOPRO_CA_CERT_PATH` — путь к промежуточному сертификату

Пример:

```bash
docker compose run --rm \
  -e CRYPTOPRO_AUTO_IMPORT=true \
  -e CRYPTOPRO_PFX_PATH=/run/secrets/client.pfx \
  -e CRYPTOPRO_PFX_PIN=123456 \
  -e CRYPTOPRO_CONTAINER_NAME=test \
  -e CRYPTOPRO_CONTAINER_PIN=123456 \
  -v ./secrets:/run/secrets:ro \
  tests bash
```

Особенности:

- в `docker-compose.yml` выставлен `platform: linux/amd64`, потому что пакет `Chrome 114` здесь зафиксирован под `amd64`;
- проект монтируется в `/workspace`, поэтому изменения в коде сразу видны контейнеру;
- Maven-репозиторий сохраняется в локальной папке проекта `.m2`.

Важно:

- сам дистрибутив CryptoPro CSP в этом шаблоне не скачивается автоматически;
- команды импорта зависят от вашей версии CSP и формата ключевого материала;
- если у вас ключ не в `PFX`, а отдельным контейнером или токеном, схему импорта нужно будет адаптировать.

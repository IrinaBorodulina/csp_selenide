# Selenide Stub Project

Минимальный проект-заглушка на `Java 8` с одним UI-тестом на `Selenide 6.12.4`.

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

Что устанавливается в контейнер:

- `Java 8`
- `Maven`
- `Google Chrome 114.0.5735.90`
- `chromedriver 114.0.5735.90`

Запуск:

```bash
docker compose up --build tests
```

Особенности:

- в `docker-compose.yml` выставлен `platform: linux/amd64`, потому что пакет `Chrome 114` здесь зафиксирован под `amd64`;
- проект монтируется в `/workspace`, поэтому изменения в коде сразу видны контейнеру;
- Maven-репозиторий сохраняется в локальной папке проекта `.m2`.

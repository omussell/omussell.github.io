# Modern Python

## Summary

The following tools and libraries are known to work well with modern python. They are modular, so you can pick and choose the components you want based on your need.

A minimal project might have:

- Dependencies managed with `uv`
- Formatting with `ruff`
- Typing/validation with `attrs`
- HTTP server with `litestar` running with `uvicorn`
- HTTP requests with `httpx`
- Documentation with `mkdocs`
- Tests with `pytest`

## HTTP

### Client

- [HTTPX](https://github.com/encode/httpx)

### Server

- [Litestar](https://litestar.dev/)
- [Uvicorn](https://www.uvicorn.org/)

## Databases

- [Advanced Alchemy](https://docs.advanced-alchemy.litestar.dev/latest/)
- [Alembic](https://alembic.sqlalchemy.org/en/latest/tutorial.html)

## Async Task Processes

- [Celery](https://docs.celeryq.dev/en/v5.5.3/getting-started/introduction.html)

## Cryptography

- [pynacl](https://pynacl.readthedocs.io/en/latest/)
- [secrets](https://docs.python.org/3/library/secrets.html)

## Dev Tools

### Project management

- [uv](https://docs.astral.sh/uv/)

### Formatting/Styling

- [ruff](https://github.com/astral-sh/ruff)

### Typing and Validation

- [attrs](https://www.attrs.org/en/stable/)
- [cattrs](https://catt.rs/en/stable/index.html)

- [Pydantic](https://pydantic-docs.helpmanual.io/)
- [Mypy](https://github.com/python/mypy)

### Tests

- [pytest](https://docs.pytest.org/en/stable/)
- [playwright](https://playwright.dev/)

### Documentation

- [mkdocs](https://www.mkdocs.org/)
- [mkdocs-material](https://squidfunk.github.io/mkdocs-material/)
- [mkdocstrings](https://github.com/mkdocstrings/mkdocstrings)

### Code Complexity
- [lizard](https://pypi.org/project/lizard/)
- [radon](https://pypi.org/project/radon/)

#### Lizard

`lizard -x'*/tests/*' -l python -w src`

#### Radon

```
radon cc --min B --average --total-average src
radon mi --min B src
```


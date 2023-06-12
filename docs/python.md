# Modern Python

## Summary

The following tools and libraries are known to work well with modern python. They are modular, so you can pick and choose the components you want based on your need.

## HTTP

### Client

- [HTTPX](https://github.com/encode/httpx)

### Server

- [FastAPI](https://fastapi.tiangolo.com/)
- [Uvicorn](https://www.uvicorn.org/)

## Databases

- [SQLModel](https://github.com/tiangolo/sqlmodel)
- [Alembic](https://alembic.sqlalchemy.org/en/latest/tutorial.html)

## Async Processes

- [Arq](https://github.com/samuelcolvin/arq)

## Cryptography

- [pynacl](https://pynacl.readthedocs.io/en/latest/)
- [secrets](https://docs.python.org/3/library/secrets.html)

## Tools

### Formatting/Styling
- [ruff](https://github.com/astral-sh/ruff)

### Linting

- [black](https://black.readthedocs.io/en/stable/)

### Typing

- [Pydantic](https://pydantic-docs.helpmanual.io/)
- [Mypy](https://github.com/python/mypy)

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


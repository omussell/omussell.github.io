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

#### Formatting/Styling
- [isort](https://pypi.org/project/isort/)
- [flake8](https://flake8.pycqa.org/en/latest/)
- [flake8-blind-except](https://pypi.org/project/flake8-blind-except/)
- [flake8-bugbear](https://pypi.org/project/flake8-bugbear/)
- [flake8-coding](https://pypi.org/project/flake8-coding/)
- [flake8-commas](https://pypi.org/project/flake8-commas/)
- [flake8-debugger](https://pypi.org/project/flake8-debugger/)
- [flake8-docstrings](https://pypi.org/project/flake8-docstrings/)
- [flake8-isort](https://pypi.org/project/flake8-isort/)
- [flake8-quotes](https://pypi.org/project/flake8-quotes/)
- [flake8-sfs](https://pypi.org/project/flake8-sfs/)

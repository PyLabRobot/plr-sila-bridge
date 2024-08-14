ARG PYTHON_BASE

FROM python:${PYTHON_BASE} as base
ARG PYPI_URL

RUN mkdir /pylabrobot_sila_bridge
WORKDIR /pylabrobot_sila_bridge

# copy build files
COPY pyproject.toml poetry.lock README.rst setup.cfg setup.py VERSION /pylabrobot_sila_bridge/
COPY pylabrobot_sila_bridge /pylabrobot_sila_bridge/pylabrobot_sila_bridge

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=0 \
    PIP_INDEX_URL=$PYPI_URL

#RUN sed -i 's|http://|https://artifactory.aws.gel.ac/artifactory/apt_|g' /etc/apt/sources.list

# libcurl4-gnutls-dev is necessary for Pysam. See PCA-179
RUN apt-get update -qq && apt-get install -qqy -f \
    build-essential \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libpq-dev \
    libsasl2-dev \
    libyaml-dev \
    libcurl4-gnutls-dev \
    nano \
    zlib1g-dev \
    && pip install -Iv --prefer-binary --index-url $PYPI_URL --upgrade \
    pip \
    setuptools \
    poetry==1.2.1 \
    poetry-plugin-export

# Use poetry to resolve dependencies, output to requirements.txt and requirements_dev.txt, and pip to install
RUN poetry export --without dev --without-hashes -f requirements.txt -o requirements.txt \
    && poetry export --only dev --without-hashes -f requirements.txt -o requirements_dev.txt \
    && python -m pip install --prefer-binary --index-url $PYPI_URL -r requirements.txt \
    && python -m pip install --prefer-binary --index-url $PYPI_URL -e .

FROM base as test
ARG PYPI_URL

WORKDIR /pylabrobot_sila_bridge
COPY tests /pylabrobot_sila_bridge/tests

# required to make sure pytest runs the right coverage checks
ENV PYTHONPATH .

RUN python -m pip install --prefer-binary --index-url $PYPI_URL -r requirements_dev.txt .[tests]

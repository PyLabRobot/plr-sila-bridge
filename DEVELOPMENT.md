Development
===========

Get Started!
------------

Ready to contribute? Here\'s how to set up [pylabrobot_sila_bridge]{.title-ref} for local development.

1.  Clone the [pylabrobot_sila_bridge]{.title-ref} repo from
    GitLab:

    ``` {.shell}
    $ git clone https://gitlab.com/opensourcelab/plr-sila-bridge.git
    ```

3.   Start your virtualenv and install dependencies:


    # create a virtual environment and activate it then run to install development dependencies:

     pip install -e .[dev]

    # run unittests

    invoke test   # use the invoke environment to manage development
   

4.  Create a branch for local development:

    ``` {.shell}
    $ git checkout -b feature/IssueNumber_name-of-your-bugfix-or-feature

    # please do not use the '#' in branch names !
    ```

Now you can make your changes locally.

1.  When you\'re done making changes, check that your changes pass the
    tests, including testing other Python versions, with tox:

    ``` {.shell}
    $ tox
    ```

2.  Commit your changes and push your branch to GitLab:

    ``` {.shell}
    $ git add .
    $ git commit -m "fix: Your detailed description of your changes."
    $ git push origin feature/IssueNumber_name-of-your-bugfix-or-feature
    ```

3.  Submit a merge request through GitLab

Merge Request Guidelines
------------------------

Before you submit a merge request, check that it meets these guidelines:

1.  The merge request should only include changes relating to one
    ticket.
2.  The merge request should include tests to cover any added changes
    and check that all existing and new tests pass.
3.  If the merge request adds functionality, the docs should be updated.
    Put your new functionality into a function with a docstring, and add
    the feature to the list in README.rst.
4.  The team should be informed of any impactful changes.

Documentation
-------------

The Sphinx Documentation Sytem is used,

markdown is supported via the mystparser (
<https://cerodell.github.io/sphinx-quickstart-guide/build/html/markdown.html>
)

To build the documentation, run

> \$ invoke docs

Tips
----

1.  To run a subset of tests:

    ``` {.shell}
    $ pytest tests.test_pylabrobot_sila_bridge
    ```

Deploying to Gitlab/Github/PyPI Package Registry
---------------------------------------------------

For every release:

1.  Update HISTORY.md

2.  Update version number (can also be patch or major):
    
    pre-commit hooks can be either installed with the provided script 
    or with the [pre-commit package](https://pre-commit.com)
    

    ``` {.shell}
    bumpversion --verbose patch
    ```

3.  Run the static analysis and tests:

    ``` {.shell}
    tox
    ```

4.  Commit the changes:

    ``` {.shell}
    git add HISTORY.md
    git commit -m "Changelog for upcoming release <#.#.#>"
    ```

5.  Push the commit:

    ``` {.shell}
    git push
    ```

6.  Add the release tag (version) on GitLab: <https://gitlab.com/>
https://gitlab.com/opensourcelab/pylabrobot-sila-bridge/-/tags

The GitLab CI pipeline will then deploy to PyPI if tests pass.

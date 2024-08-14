#!/usr/bin/env python


#  shall be replaced by https://pre-commit.com/

import os
import stat
import sys
from os.path import dirname, join

hook_file = join(dirname(__file__), ".git", "hooks", "pre-commit")

# short-running tests
pytest_target_files = " ".join(
    [
        "tests/test_*.py",
    ]
)

# write pre-commit hook script to .git/hooks/pre-commit
with open(hook_file, "w", encoding="utf-8") as fp:
    fp.write(
        f"""\
#!/bin/sh
set -ex

# ensure correct environment is used (workaround for PyCharm)
alias python={sys.executable}

python -m isort --check-only .
python -m black --check .
python -m pflake8 .
python -m pytest {pytest_target_files}
"""
    )

# make script executable
os.chmod(hook_file, os.stat(hook_file).st_mode | stat.S_IEXEC)

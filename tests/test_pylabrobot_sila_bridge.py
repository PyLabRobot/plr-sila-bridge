#!/usr/bin/env python
"""Tests for `pylabrobot_sila_bridge` package."""
# pylint: disable=redefined-outer-name
from pylabrobot_sila_bridge import __version__
from pylabrobot_sila_bridge.pylabrobot_sila_bridge_interface import GreeterInterface
from pylabrobot_sila_bridge.pylabrobot_sila_bridge_impl import HelloWorld

def test_version():
    """Sample pytest test function."""
    assert __version__ == "0.0.1"

def test_GreeterInterface():
    """ testing the formal interface (GreeterInterface)
    """
    assert issubclass(HelloWorld, GreeterInterface)

def test_HelloWorld():
    """ Testing HelloWorld class
    """
    hw = HelloWorld()
    name = 'yvain'
    assert hw.greet_the_world(name) == f"Hello world, {name} !"


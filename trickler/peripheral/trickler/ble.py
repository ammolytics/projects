#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import logging

import pybleno


def main(args):
    pass


if __name__ == '__main__':
    import argparse

    import pymemcache.client.base
    import pymemcache.serde

    parser = argparse.ArgumentParser(description='Test bluetooth')
    args = parser.parse_args()

    memcache = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    main(args)

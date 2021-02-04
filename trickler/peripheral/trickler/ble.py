#!/usr/bin/env python3
"""
Copyright (c) Ammolytics and contributors. All rights reserved.
Released under the MIT license. See LICENSE file in the project root for details.

OpenTrickler
https://github.com/ammolytics/projects/tree/develop/trickler
"""

import logging

import bluezero

import helpers


def main(config, args):
    memcache = helpers.get_mc_client()
    pass


if __name__ == '__main__':
    import argparse
    import configparser

    parser = argparse.ArgumentParser(description='Test bluetooth')
    parser.add_argument('config_file')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read_file(open(args.config_file))

    helpers.setup_logging()

    main(config, args)

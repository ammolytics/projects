#!/usr/bin/env python3

import logging

import pybleno
import pymemcache.client.base
import pymemcache.serde


memcache = pymemcache.client.base.Client('127.0.0.1:11211', serde=pymemcache.serde.PickleSerde())


def main(args):
    pass


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Test bluetooth')
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s.%(msecs)06dZ %(levelname)-4s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S')

    main(args)

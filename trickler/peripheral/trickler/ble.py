#!/usr/bin/env python3

import pybleno
import pymemcache.client.base

memcache = pymemcache.client.base.Client('localhost')


def main(args):
    pass


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Test bluetooth')
    args = parser.parse_args()

    main(args)

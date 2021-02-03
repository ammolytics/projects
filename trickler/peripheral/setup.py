from setuptools import setup

SHORT_DESCRIPTION = """
""".strip()

LONG_DESCRIPTION = """
DIY powder trickler control software.""".strip()

DEPENDENCIES = [
    'pybleno',
    'pyserial',
    'gpiozero',
    'pymemcache',
    'RPi.GPIO',
]

TEST_DEPENDENCIES = []

VERSION = '2.0.0-dev'
URL = 'https://github.com/ammolytics/projects/trickler'

setup(
    name='opentrickler',
    version=VERSION,
    description=SHORT_DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    url=URL,

    author='Eric Higgins',
    author_email='eric@ammolytics.com',
    license='MIT',

    classifiers=[
        'License :: OSI Approved :: MIT License',

        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
    ],

    keywords='',

    packages=[],

    install_requires=DEPENDENCIES,
    tests_require=TEST_DEPENDENCIES,
)

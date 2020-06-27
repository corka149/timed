from setuptools import setup

setup(
    name='timed',
    version='1.0.0',
    packages=[''],
    package_dir={'': 'src'},
    url='https://github.com/corka149/timed/tree/master',
    license='MIT',
    author='corka149',
    author_email='corka149@mailbox.org',
    description='Manages my working times.',
    install_requires=[
        "click"
    ],
    entry_points={
        "console_scripts": [
            "timed = timed:cli"
        ]
    }
)

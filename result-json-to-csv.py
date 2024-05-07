#! /usr/bin/env python3

import pathlib

import click
import pandas

@click.command()
@click.argument("json_file", type=pathlib.Path)
def main(json_file:pathlib.Path):
    df = pandas.read_json(json_file, lines=True)
    df.to_csv(json_file.parent / f"{json_file.stem}.csv", index=False)


if __name__ == '__main__':
    main()
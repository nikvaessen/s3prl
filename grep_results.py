#!/usr/bin/env python3
import pathlib
from typing import Optional

import click


def get_metric(
    result_dir: pathlib.Path,
    task_name: str,
    metric_name: str,
    make_percentage: bool = True,
    file_id: Optional[str] = None,
):
    out_file = (
        result_dir
        / task_name
        / f"superb.{task_name if file_id is None else file_id}.txt"
    )

    with out_file.open("r") as f:
        for ln in f.readlines():
            if metric_name in ln:
                value = float(ln.split(metric_name + ":")[1].strip())

                if make_percentage:
                    value *= 100

                return value

    raise ValueError(f"could not find metric `{metric_name}` for {out_file}")


@click.command()
@click.argument("result_directory", type=pathlib.Path)
def main(result_directory: pathlib.Path):
    # pr
    pr_per = get_metric(result_directory, "pr", "test per")
    print(f"{pr_per=:.2f}")

    # asr
    asr_wer = get_metric(result_directory, "asr", "test-clean wer", False)
    print(f"{asr_wer=:.2f}")

    # asr-ood
    asr_wer_es = get_metric(
        result_directory, "asr-ood", "test wer", file_id="es.ood-asr"
    )
    asr_wer_ar = get_metric(
        result_directory, "asr-ood", "test wer", file_id="ar.ood-asr"
    )
    asr_cer_zh = get_metric(
        result_directory, "asr-ood", "test cer", file_id="zh-CN.ood-asr"
    )
    asr_wer_spoken = get_metric(
        result_directory, "asr-ood", "test wer", file_id="sbcsae.ood-asr"
    )

    print(f"{asr_wer_es=:.2f}")
    print(f"{asr_wer_ar=:.2f}")
    print(f"{asr_cer_zh=:.2f}")
    print(f"{asr_wer_spoken=:.2f}")

    # ks
    ks_acc = get_metric(result_directory, "ks", "test acc")
    print(f"{ks_acc=:.2f}")

    # qbe


if __name__ == "__main__":
    main()

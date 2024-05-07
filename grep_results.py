#!/usr/bin/env python3
########################################################################################
#
# Scripts to collect all results from a SUPERB slurm run.
#
# Author(s): Nik Vaessen
########################################################################################
import json
import pathlib
import re
import warnings

import click
import pandas


########################################################################################
# function grabbing results from task directory


def get_metric(
    task_dir: pathlib.Path,
    metric_name: str,
    make_percentage: bool = True,
    split_token: str = ":",
    split_idx: int = 1,
    task_name: str = None,
    custom_filename: str = None,
):
    if task_name is None and custom_filename is None:
        potential_result_files = [*task_dir.glob("evaluate.*.txt")]

        if len(potential_result_files) == 1:
            result_file = potential_result_files[0]
        else:
            warnings.warn(f"could not find 'evaluate.*.txt' in directory {task_dir}")
            return -1
    elif custom_filename is None:
        result_file = task_dir / f"evaluate.{task_name}.txt"
    else:
        result_file = task_dir / custom_filename

    if not result_file.exists():
        warnings.warn(f"{result_file} does not exist!")
        return -1

    with result_file.open("r") as f:
        for ln in f.readlines():
            if metric_name in ln:
                value = float(ln.strip().split(split_token)[split_idx].strip())

                if make_percentage:
                    value *= 100

                return value

    warnings.warn(f"could not find line with '{metric_name}' for {result_file}")
    return -1


def get_learning_rate(task_dir: pathlib.Path):
    return get_metric(
        task_dir,
        metric_name="learning rate",
        custom_filename="learning_rate.txt",
        make_percentage=False,
    )


def get_der(der_file: pathlib.Path):
    if not der_file.exists():
        warnings.warn(f"{der_file} does not exist!")
        return -1

    last_line = der_file.open("r").readlines()[-1]
    der_score = last_line.split("*** OVERALL ***")[1].strip().split(" ")[0]

    return float(der_score)


def get_qbe_mtwv(task_dir: pathlib.Path):
    dev_dirs = sorted(
        [d for d in task_dir.iterdir() if d.is_dir() and "dev" in d.name],
        key=lambda d: d.name.split("_")[1],
    )
    test_dirs = sorted(
        [d for d in task_dir.iterdir() if d.is_dir() and "test" in d.name],
        key=lambda d: d.name.split("_")[1],
    )

    def _get_score(outf):
        if not outf.exists():
            warnings.warn(f"{outf} does not exist!")
            return -1

        with outf.open("r") as f:
            for ln in f.readlines():
                if "maxTWV" in ln:
                    start_idx = ln.find("maxTWV")
                    end_idx = ln.find("Threshold")
                    return float(ln[start_idx:end_idx].split(":")[1].strip()) * 100

        warnings.warn(f"{outf} does not contain maxTWV")
        return -1

    best_layer = -1
    best_mtwv = -1

    print("layer scores for QbE")
    for idx, dev_dir in enumerate(dev_dirs):
        score_file = dev_dir / "score.out"
        score = _get_score(score_file)
        print(f"layer {idx} {score=}")
        if score > best_mtwv:
            best_layer = idx
            best_mtwv = score

    test_score = _get_score(test_dirs[best_layer] / "score.out")

    return test_score, best_layer


def get_er_acc_and_lr(subdir: pathlib.Path):
    accuracy_list = []
    lr_list = []

    for fold_idx in range(1, 6):
        fold_dir = subdir / f"fold{fold_idx}"
        acc = get_metric(fold_dir, "test acc")
        accuracy_list.append(acc)

        if acc == -1:
            continue

        lr = get_learning_rate(fold_dir)
        lr_list.append(lr)

    if len(accuracy_list) == 0:
        warnings.warn("all folds for emotion recognition failed")
        return -1

    cv_acc = sum(accuracy_list) / len(accuracy_list)
    assert all(lr_list[0] == lr_list[idx] for idx in range(len(lr_list)))
    cv_lr = lr_list[0]

    return cv_acc, cv_lr


def get_vc_metrics(result_dir: pathlib.Path):
    mcd_list = []
    wer_list = []
    ar_list = []
    lr_list = []

    for spk in ["TEM1", "TEM2", "TEF1", "TEF2"]:
        mcd_list.append(
            get_metric(
                result_dir / spk,
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=9,
                make_percentage=False,
            )
        )
        wer_list.append(
            get_metric(
                result_dir / spk,
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=14,
                make_percentage=False,
            )
        )
        ar_list.append(
            get_metric(
                result_dir / spk,
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=15,
                make_percentage=False,
            )
        )
        lr_list.append(get_learning_rate(result_dir / spk))

    mcd = sum(mcd_list) / 4
    wer = sum(wer_list) / 4
    ar = sum(ar_list) / 4
    lr = lr_list[0]

    assert all(lr_list[0] == lr_list[idx] for idx in range(len(lr_list)))

    return mcd, wer, ar, lr


@click.command()
@click.argument("result_directory", type=pathlib.Path)
@click.option("--name", required=False, type=str, default=None)
def main(result_directory: pathlib.Path, name: str):
    output_json = []

    if name is None:
        name = result_directory.name

        pattern_qbe = r"(.+?)-qbe$"
        pattern_se = r"-?\d+\.?\d*e[+-]?\d+"
        name = re.sub(pattern_qbe, r"\1", name)
        name = re.sub(pattern_se, "", name)

        print(f"selected {name=} for directory {result_directory}")

    for subdir in sorted([d for d in result_directory.iterdir() if d.is_dir()]):
        if subdir.name == "asr":
            asr_wer = get_metric(subdir, "test-clean wer", False)
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "wer",
                    "metric-is-better-when": "lower",
                    "metric-value": asr_wer,
                }
            )

        elif subdir.name == "asr-ood":
            asr_wer_es = get_metric(subdir / "es", "test wer")
            lr_es = get_learning_rate(subdir / "es")

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name + "-es",
                    "learning-rate": lr_es,
                    "metric": "wer",
                    "metric-is-better-when": "lower",
                    "metric-value": asr_wer_es,
                }
            )

            asr_wer_ar = get_metric(subdir / "ar", "test wer")
            lr_ar = get_learning_rate(subdir / "ar")

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name + "-ar",
                    "learning-rate": lr_ar,
                    "metric": "wer",
                    "metric-is-better-when": "lower",
                    "metric-value": asr_wer_ar,
                }
            )

            asr_cer_zh = get_metric(subdir / "zh-CN", "test cer")
            lr_zh = get_learning_rate(subdir / "zh-CN")

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name + "-zh",
                    "learning-rate": lr_zh,
                    "metric": "cer",
                    "metric-is-better-when": "lower",
                    "metric-value": asr_cer_zh,
                }
            )

            asr_wer_spoken = get_metric(subdir / "sbcsae", "test wer")
            lr_spoken = get_learning_rate(subdir / "sbcsae")

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name + "-spoken",
                    "learning-rate": lr_spoken,
                    "metric": "wer",
                    "metric-is-better-when": "lower",
                    "metric-value": asr_wer_spoken,
                }
            )

        elif subdir.name == "asv":
            asv_eer = get_metric(subdir, "achieves EER", split_token=" ", split_idx=5)
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "eer",
                    "metric-is-better-when": "lower",
                    "metric-value": asv_eer,
                }
            )

        elif subdir.name == "er":
            er_acc, lr = get_er_acc_and_lr(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "acc",
                    "metric-is-better-when": "higher",
                    "metric-value": er_acc,
                }
            )

        elif subdir.name == "ic":
            ic_acc = get_metric(subdir, "test acc")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "acc",
                    "metric-is-better-when": "higher",
                    "metric-value": ic_acc,
                }
            )

        elif subdir.name == "ks":
            ks_acc = get_metric(subdir, "test acc")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "acc",
                    "metric-is-better-when": "higher",
                    "metric-value": ks_acc,
                }
            )

        elif subdir.name == "pr":
            pr_per = get_metric(subdir, "test per")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "per",
                    "metric-is-better-when": "lower",
                    "metric-value": pr_per,
                }
            )

        elif subdir.name == "qbe":
            qbe_mtwv, layer_used = get_qbe_mtwv(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": layer_used,
                    "metric": "mtwv",
                    "metric-is-better-when": "higher",
                    "metric-value": qbe_mtwv,
                }
            )

        elif subdir.name == "sd":
            sd_der = get_der(subdir / "evaluate.sd.txt")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "der",
                    "metric-is-better-when": "lower",
                    "metric-value": sd_der,
                }
            )

        elif subdir.name == "se":
            se_pesq = get_metric(
                subdir,
                "Average pesq",
                split_token=" ",
                split_idx=6,
                make_percentage=False,
            )
            se_stoi = get_metric(
                subdir,
                "Average stoi",
                split_token=" ",
                split_idx=6,
                make_percentage=True,
            )
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "pesq",
                    "metric-is-better-when": "higher",
                    "metric-value": se_pesq,
                }
            )

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "stoi",
                    "metric-is-better-when": "higher",
                    "metric-value": se_stoi,
                }
            )

        elif subdir.name == "sf":
            sf_f1 = get_metric(subdir, "slot_type_f1")
            sf_cer = get_metric(subdir, "slot_value_cer")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "f1",
                    "metric-is-better-when": "higher",
                    "metric-value": sf_f1,
                }
            )
            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "cer",
                    "metric-is-better-when": "lower",
                    "metric-value": sf_cer,
                }
            )

        elif subdir.name == "sid":
            sid_acc = get_metric(subdir, "test acc")
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "acc",
                    "metric-is-better-when": "higher",
                    "metric-value": sid_acc,
                }
            )

        elif subdir.name == "st":
            st_bleu = get_metric(
                subdir,
                "BLEU =",
                split_token=" ",
                split_idx=2,
                make_percentage=False,
            )
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "bleu",
                    "metric-is-better-when": "higher",
                    "metric-value": st_bleu,
                }
            )

        elif subdir.name == "ss":
            ss_si_sdri = get_metric(
                subdir,
                "si_sdr",
                split_token=" ",
                split_idx=5,
                make_percentage=False,
            )
            lr = get_learning_rate(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": lr,
                    "metric": "si_sdri",
                    "metric-is-better-when": "higher",
                    "metric-value": ss_si_sdri,
                }
            )

        elif subdir.name == "vc":
            vc_mcd, vc_wer, vc_asv_ar, vc_lr = get_vc_metrics(subdir)

            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": vc_lr,
                    "metric": "mcd",
                    "metric-is-better-when": "lower",
                    "metric-value": vc_mcd,
                }
            )
            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": vc_lr,
                    "metric": "wer",
                    "metric-is-better-when": "lower",
                    "metric-value": vc_wer,
                }
            )
            output_json.append(
                {
                    "checkpoint": name,
                    "superb_task": subdir.name,
                    "learning-rate": vc_lr,
                    "metric": "ar",
                    "metric-is-better-when": "higher",
                    "metric-value": vc_asv_ar,
                }
            )

        else:
            print(f"skipping {subdir} as {subdir.name} is an unknown task")

    with (result_directory / "results.json").open("w") as f:
        for j in output_json:
            print(j)
            json.dump(j, f)
            print(file=f)


if __name__ == "__main__":
    main()

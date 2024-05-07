#!/usr/bin/env python3
########################################################################################
#
# Scripts to collect all results from a SUPERB slurm run.
#
# Author(s): Nik Vaessen
########################################################################################

import pathlib
import warnings

import click

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
            raise ValueError(
                f"could not select result file from {potential_result_files=}"
            )
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

    raise ValueError(f"could not find line with '{metric_name}' for {result_file}")


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


def get_qbe_mtwv(result_dir: pathlib.Path):
    dev_dirs = sorted(
        [d for d in (result_dir / "qbe").iterdir() if d.is_dir() and "dev" in d.name],
        key=lambda d: d.name.split("_")[1],
    )
    test_dirs = sorted(
        [d for d in (result_dir / "qbe").iterdir() if d.is_dir() and "test" in d.name],
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

    for idx, dev_dir in enumerate(dev_dirs):
        score_file = dev_dir / "score.out"
        score = _get_score(score_file)

        if score > best_mtwv:
            best_layer = idx
            best_mtwv = score

    test_score = _get_score(test_dirs[best_layer] / "score.out")

    return test_score


def get_er_acc_and_lr(subdir: pathlib.Path):
    accuracy_list = []
    lr_list = []

    for fold_idx in range(1, 6):
        fold_dir = subdir / f"fold{fold_idx}"
        acc = get_metric(fold_dir, "test acc")
        accuracy_list.append(acc)

        lr = get_learning_rate(fold_dir)
        lr_list.append(lr)

    cv_acc = sum(accuracy_list) / len(accuracy_list)
    assert all(lr_list[0] == lr_list[idx] for idx in range(len(lr_list)))
    cv_lr = lr_list[0]

    return cv_acc, cv_lr


def get_vc_metrics(result_dir: pathlib.Path):
    mcd_list = []
    wer_list = []
    ar_list = []

    for spk in ["TEM1", "TEM2", "TEF1", "TEF2"]:
        mcd_list.append(
            get_metric(
                result_dir,
                f"vc/{spk}",
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=9,
                file_id=f"vc.{spk}",
                make_percentage=False,
            )
        )
        wer_list.append(
            get_metric(
                result_dir,
                f"vc/{spk}",
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=14,
                file_id=f"vc.{spk}",
                make_percentage=False,
            )
        )
        ar_list.append(
            get_metric(
                result_dir,
                f"vc/{spk}",
                metric_name="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
                split_token=" ",
                split_idx=15,
                file_id=f"vc.{spk}",
                make_percentage=False,
            )
        )

    mcd = sum(mcd_list) / 4
    wer = sum(wer_list) / 4
    ar = sum(ar_list) / 4

    return mcd, wer, ar


@click.command()
@click.argument("result_directory", type=pathlib.Path)
@click.option("--name", required=True, type=str)
def main(result_directory: pathlib.Path, name: str):
    output_json = []

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
            pass

        elif subdir.name == "ss":
            pass

        elif subdir.name == "vc":
            pass

        else:
            print(f"skipping {subdir} as {subdir.name} is an unknown task")

    for jsn in output_json:
        print(jsn)

    # # qbe
    # qbe_mtwv = -1  # get_qbe_mtwv(result_directory)
    #

    # # st
    # st_bleu = get_metric(
    #     result_directory,
    #     "st",
    #     "BLEU =",
    #     split_token=" ",
    #     split_idx=2,
    #     make_percentage=False,
    # )

    # # vc
    # vc_mcd, vc_wer, vc_asv_ar = get_vc_metrics(result_directory)

    # # write csv
    # with open(result_directory / "results.csv", "w") as f:
    #     # header
    #     print("pr", file=f, end=",")
    #     print("asr", file=f, end=",")
    #     print("asr-ood-es", file=f, end=",")
    #     print("asr-ood-ar", file=f, end=",")
    #     print("asr-ood-zh-CN", file=f, end=",")
    #     print("asr-ood-spoken", file=f, end=",")
    #     print("ks", file=f, end=",")
    #     print("qbe", file=f, end=",")
    #     print("sid", file=f, end=",")
    #     print("asv", file=f, end=",")
    #     print("sd", file=f, end=",")
    #     print("er", file=f, end=",")
    #     print("ic", file=f, end=",")
    #     print("sf-f0", file=f, end=",")
    #     print("sf-cer", file=f, end=",")
    #     print("st", file=f, end=",")
    #     print("vc-mcd", file=f, end=",")
    #     print("vc-wer", file=f, end=",")
    #     print("vc-asv-ar", file=f, end=",")
    #     print("se-pesq", file=f, end=",")
    #     print("se-stoi", file=f, end=",")
    #     print("ss", file=f, end="\n")
    #
    #     # results
    #     print(pr_per, file=f, end=",")
    #     print(asr_wer, file=f, end=",")
    #     print(asr_wer_es, file=f, end=",")
    #     print(asr_wer_ar, file=f, end=",")
    #     print(asr_cer_zh, file=f, end=",")
    #     print(asr_wer_spoken, file=f, end=",")
    #     print(ks_acc, file=f, end=",")
    #     print(qbe_mtwv, file=f, end=",")
    #     print(sid_acc, file=f, end=",")
    #     print(asv_eer, file=f, end=",")
    #     print(sd_der, file=f, end=",")
    #     print(er_acc, file=f, end=",")
    #     print(ic_acc, file=f, end=",")
    #     print(sf_f0, file=f, end=",")
    #     print(sf_cer, file=f, end=",")
    #     print(st_bleu, file=f, end=",")
    #     print(vc_mcd, file=f, end=",")
    #     print(vc_wer, file=f, end=",")
    #     print(vc_asv_ar, file=f, end=",")
    #     print(se_pesq, file=f, end=",")
    #     print(se_stoi, file=f, end=",")
    #     print(ss_si_sdri, file=f, end="\n")
    #
    # with open(result_directory / "results.drive.txt", "w") as f:
    #     # results
    #     print(pr_per, file=f)
    #     print(asr_wer, file=f)
    #     print(asr_wer_es, file=f)
    #     print(asr_wer_ar, file=f)
    #     print(asr_cer_zh, file=f)
    #     print(asr_wer_spoken, file=f)
    #     print(ks_acc, file=f)
    #     print(qbe_mtwv, file=f)
    #     print(file=f)
    #     print(sid_acc, file=f)
    #     print(asv_eer, file=f)
    #     print(sd_der, file=f)
    #     print(file=f)
    #     print(er_acc, file=f)
    #     print(file=f)
    #     print(ic_acc, file=f)
    #     print(sf_f0, file=f)
    #     print(sf_cer, file=f)
    #     print(st_bleu, file=f)
    #     print(file=f)
    #     print(vc_mcd, file=f)
    #     print(vc_wer, file=f)
    #     print(vc_asv_ar, file=f)
    #     print(se_pesq, file=f)
    #     print(se_stoi, file=f)
    #     print(ss_si_sdri, file=f)
    #
    # with open(result_directory / "results.txt", "w") as f:
    #     # results
    #     print(f"{pr_per=:.2f}", file=f)
    #     print(f"{asr_wer=:.2f}", file=f)
    #     print(f"{asr_wer_es=:.2f}", file=f)
    #     print(f"{asr_wer_ar=:.2f}", file=f)
    #     print(f"{asr_cer_zh=:.2f}", file=f)
    #     print(f"{asr_wer_spoken=:.2f}", file=f)
    #     print(f"{ks_acc=:.2f}", file=f)
    #     print(f"{qbe_mtwv=:.2f}", file=f)
    #     print(f"{sid_acc=:.2f}", file=f)
    #     print(f"{asv_eer=:.2f}", file=f)
    #     print(f"{sd_der=:.2f}", file=f)
    #     print(f"{er_acc=:.2f}", file=f)
    #     print(f"{ic_acc=:.2f}", file=f)
    #     print(f"{sf_f0=:.2f}", file=f)
    #     print(f"{sf_cer=:.2f}", file=f)
    #     print(f"{st_bleu=:.2f}", file=f)
    #     print(f"{vc_mcd=:.2f}", file=f)
    #     print(f"{vc_wer=:.2f}", file=f)
    #     print(f"{vc_asv_ar=:.2f}", file=f)
    #     print(f"{se_pesq=:.2f}", file=f)
    #     print(f"{se_stoi=:.2f}", file=f)
    #     print(f"{ss_si_sdri=:.2f}", file=f)
    #
    # with open(result_directory / "results.txt", "r") as f:
    #     print(f.read(), end="")


if __name__ == "__main__":
    main()

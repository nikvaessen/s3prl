#!/usr/bin/env python3
import pathlib
import warnings
from typing import Optional

import click


def get_metric(
    result_dir: pathlib.Path,
    task_name: str,
    line_id: str,
    make_percentage: bool = True,
    file_id: Optional[str] = None,
    split_token: str = ":",
    split_idx: int = 1,
):
    out_file = (
        result_dir
        / task_name
        / f"superb.{task_name if file_id is None else file_id}.txt"
    )

    if not out_file.exists():
        warnings.warn(f"{out_file} does not exist!")
        return -1

    with out_file.open("r") as f:
        for ln in f.readlines():
            if line_id in ln:
                value = float(ln.strip().split(split_token)[split_idx].strip())

                if make_percentage:
                    value *= 100

                return value

    raise ValueError(f"could not find line with '{line_id}' for {out_file}")


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


def get_er_acc(result_dir: pathlib.Path):
    accuracy_list = []
    for fold_idx in range(1, 6):
        acc = get_metric(result_dir, f"er/fold{fold_idx}", "test acc", file_id="er")
        accuracy_list.append(acc)

    return sum(accuracy_list) / len(accuracy_list)


def get_vc_metrics(result_dir: pathlib.Path):
    mcd_list = []
    wer_list = []
    ar_list = []

    for spk in ["TEM1", "TEM2", "TEF1", "TEF2"]:
        mcd_list.append(
            get_metric(
                result_dir,
                f"vc/{spk}",
                line_id="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
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
                line_id="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
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
                line_id="Mean MCD, f0RMSE, f0CORR, DDUR, CER, WER",
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
def main(result_directory: pathlib.Path):
    # pr
    pr_per = get_metric(result_directory, "pr", "test per")

    # asr
    asr_wer = get_metric(result_directory, "asr", "test-clean wer", False)

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

    # ks
    ks_acc = get_metric(result_directory, "ks", "test acc")

    # qbe
    qbe_mtwv = get_qbe_mtwv(result_directory)

    # sid
    sid_acc = get_metric(result_directory, "sid", "test acc")

    # asv
    asv_eer = get_metric(
        result_directory, "asv", "achieves EER", split_token=" ", split_idx=5
    )

    # sd
    sd_der = get_der(result_directory / "sd" / "superb.sd.txt")

    # er
    er_acc = get_er_acc(result_directory)

    # ic
    ic_acc = get_metric(result_directory, "ic", "test acc")

    # slot filling
    sf_f0 = get_metric(result_directory, "sf", "slot_type_f1")
    sf_cer = get_metric(result_directory, "sf", "slot_value_cer")

    # st
    st_bleu = get_metric(
        result_directory,
        "st",
        "BLEU =",
        split_token=" ",
        split_idx=2,
        make_percentage=False,
    )

    # vc
    vc_mcd, vc_wer, vc_asv_ar = get_vc_metrics(result_directory)

    # se
    se_pesq = get_metric(
        result_directory,
        "se",
        "Average pesq",
        split_token=" ",
        split_idx=6,
        make_percentage=False,
    )
    se_stoi = get_metric(
        result_directory,
        "se",
        "Average stoi",
        split_token=" ",
        split_idx=6,
        make_percentage=True,
    )

    # ss
    ss_si_sdri = get_metric(
        result_directory,
        "ss",
        "si_sdr",
        split_token=" ",
        split_idx=5,
        make_percentage=False,
    )

    # write csv
    with open(result_directory / "results.csv", "w") as f:
        # header
        print("pr", file=f, end=",")
        print("asr", file=f, end=",")
        print("asr-ood-es", file=f, end=",")
        print("asr-ood-ar", file=f, end=",")
        print("asr-ood-zh-CN", file=f, end=",")
        print("asr-ood-spoken", file=f, end=",")
        print("ks", file=f, end=",")
        print("qbe", file=f, end=",")
        print("sid", file=f, end=",")
        print("asv", file=f, end=",")
        print("sd", file=f, end=",")
        print("er", file=f, end=",")
        print("ic", file=f, end=",")
        print("sf-f0", file=f, end=",")
        print("sf-cer", file=f, end=",")
        print("st", file=f, end=",")
        print("vc-mcd", file=f, end=",")
        print("vc-wer", file=f, end=",")
        print("vc-asv-ar", file=f, end=",")
        print("se-pesq", file=f, end=",")
        print("se-stoi", file=f, end=",")
        print("ss", file=f, end="\n")

        # results
        print(pr_per, file=f, end=",")
        print(asr_wer, file=f, end=",")
        print(asr_wer_es, file=f, end=",")
        print(asr_wer_ar, file=f, end=",")
        print(asr_cer_zh, file=f, end=",")
        print(asr_wer_spoken, file=f, end=",")
        print(ks_acc, file=f, end=",")
        print(qbe_mtwv, file=f, end=",")
        print(sid_acc, file=f, end=",")
        print(asv_eer, file=f, end=",")
        print(sd_der, file=f, end=",")
        print(er_acc, file=f, end=",")
        print(ic_acc, file=f, end=",")
        print(sf_f0, file=f, end=",")
        print(sf_cer, file=f, end=",")
        print(st_bleu, file=f, end=",")
        print(vc_mcd, file=f, end=",")
        print(vc_wer, file=f, end=",")
        print(vc_asv_ar, file=f, end=",")
        print(se_pesq, file=f, end=",")
        print(se_stoi, file=f, end=",")
        print(ss_si_sdri, file=f, end="\n")

    with open(result_directory / "results.drive.txt", "w") as f:
        # results
        print(pr_per, file=f)
        print(asr_wer, file=f)
        print(asr_wer_es, file=f)
        print(asr_wer_ar, file=f)
        print(asr_cer_zh, file=f)
        print(asr_wer_spoken, file=f)
        print(ks_acc, file=f)
        print(qbe_mtwv, file=f)
        print(file=f)
        print(sid_acc, file=f)
        print(asv_eer, file=f)
        print(sd_der, file=f)
        print(file=f)
        print(er_acc, file=f)
        print(file=f)
        print(ic_acc, file=f)
        print(sf_f0, file=f)
        print(sf_cer, file=f)
        print(st_bleu, file=f)
        print(file=f)
        print(vc_mcd, file=f)
        print(vc_wer, file=f)
        print(vc_asv_ar, file=f)
        print(se_pesq, file=f)
        print(se_stoi, file=f)
        print(ss_si_sdri, file=f)

    with open(result_directory / "results.txt", "w") as f:
        # results
        print(f"{pr_per=:.2f}", file=f)
        print(f"{asr_wer=:.2f}", file=f)
        print(f"{asr_wer_es=:.2f}", file=f)
        print(f"{asr_wer_ar=:.2f}", file=f)
        print(f"{asr_cer_zh=:.2f}", file=f)
        print(f"{asr_wer_spoken=:.2f}", file=f)
        print(f"{ks_acc=:.2f}", file=f)
        print(f"{qbe_mtwv=:.2f}", file=f)
        print(f"{sid_acc=:.2f}", file=f)
        print(f"{asv_eer=:.2f}", file=f)
        print(f"{sd_der=:.2f}", file=f)
        print(f"{er_acc=:.2f}", file=f)
        print(f"{ic_acc=:.2f}", file=f)
        print(f"{sf_f0=:.2f}", file=f)
        print(f"{sf_cer=:.2f}", file=f)
        print(f"{st_bleu=:.2f}", file=f)
        print(f"{vc_mcd=:.2f}", file=f)
        print(f"{vc_wer=:.2f}", file=f)
        print(f"{vc_asv_ar=:.2f}", file=f)
        print(f"{se_pesq=:.2f}", file=f)
        print(f"{se_stoi=:.2f}", file=f)
        print(f"{ss_si_sdri=:.2f}", file=f)

    with open(result_directory / "results.txt", "r") as f:
        print(f.read(), end="")


if __name__ == "__main__":
    main()

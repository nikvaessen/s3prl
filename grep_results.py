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
                value = float(ln.split(metric_name)[1].removeprefix(":").strip())

                if make_percentage:
                    value *= 100

                return value

    raise ValueError(f"could not find metric `{metric_name}` for {out_file}")


def get_der(der_file: pathlib.Path):
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
        with outf.open("r") as f:
            for ln in f.readlines():
                if "maxTWV" in ln:
                    start_idx = ln.find("maxTWV")
                    end_idx = ln.find("Threshold")
                    return float(ln[start_idx:end_idx].split(":")[1].strip()) * 100

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
    qbe_mtwv = get_qbe_mtwv(result_directory)
    print(f"{qbe_mtwv=:.2f}")

    # sid
    sid_acc = get_metric(result_directory, "sid", "test acc")
    print(f"{sid_acc=:.2f}")

    # asv
    asv_eer = get_metric(result_directory, "asv", "achieves EER")
    print(f"{asv_eer=:.2f}")

    # sd
    sd_der = get_der(result_directory / "sd" / "superb.sd.txt")
    print(f"{sd_der=:.2f}")

    # er
    er_acc = get_er_acc(result_directory)
    print(f"{er_acc=:.2f}")

    # ic
    ic_acc = get_metric(result_directory, "ic", "test acc")
    print(f"{ic_acc=:.2f}")

    # slot filling
    sf_f0 = get_metric(result_directory, "sf", "slot_type_f1")
    sf_cer = get_metric(result_directory, "sf", "slot_value_cer")
    print(f"{sf_f0=:.2f}")
    print(f"{sf_cer=:.2f}")

    # st
    st_bleu = -1

    # vc
    vc_mcd = -1
    vc_wer = -1
    vc_asv_ar = -1

    # se
    se_pesq = -1
    se_stoi = -1

    # ss
    ss_si_sdri = -1

    # write txt
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


if __name__ == "__main__":
    main()

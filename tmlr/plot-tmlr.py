import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_json("tmlr.json", lines=True)


def to_batch_size_in_sec(x: str):
    split_values = x.split("-")
    gpu = split_values[1]

    if gpu == "0gpu":
        bs = 87.5
    elif gpu == "1gpu":
        bs = 150
    elif gpu == "2gpu":
        bs = 150 * 2
    elif gpu == "4gpu":
        bs = 150 * 4
    elif gpu == "8gpu":
        bs = 150 * 8
    elif gpu == "16gpu":
        bs = 150 * 16
    elif gpu == "32gpu":
        bs = 150 * 32
    elif gpu == "vc2":
        if split_values[2] == "5min":
            bs = 60 * 5
        elif split_values[2] == "40min":
            bs = 60 * 40
        else:
            raise ValueError(f"unknown {split_values=}")
    else:
        raise ValueError(f"{gpu=} is unknown")

    return bs


def to_steps(x: str):
    split_values = x.split("-")
    steps_as_int = None

    for s in split_values:
        if s.endswith("k"):
            steps_as_int = int(s.removesuffix("k")) * 1000

    if steps_as_int is None:
        raise ValueError(f"cannot extract steps from {split_values=}")

    return steps_as_int


def to_desc(x):
    if x <= 150:
        r = f"{int(x)} sec"
    else:
        r = f"{int(x//60):d} min"

    return r


def from_desc(x):
    value, unit = x.split(" ")

    if unit == "sec":
        return int(value)
    else:
        return int(value) * 60


df["batch_size"] = df["checkpoint"].apply(to_batch_size_in_sec)
df["batch size"] = df["batch_size"].apply(to_desc)
df["steps"] = df["checkpoint"].apply(to_steps)
df["hours_seen"] = df["batch_size"] * df["steps"] / 3600

# print(df.to_string())
tasks = df["superb_task"].unique()
hue_order = sorted(df["batch size"].unique(), key=from_desc)

print(tasks)
print(hue_order)

sns.set_style("darkgrid")

for task in tasks:
    plt.clf()

    task_df = df.loc[df["superb_task"] == task]
    if task == "asr":
        title = "English speech recognition"
    elif task == "asr-ood-zh":
        title = "Chinese speech recognition"
    elif task == "asv":
        title = "speaker recognition"
    elif task == "er":
        title = "emotion recognition"
    elif task == "ic":
        title = "intent classification"
    elif task == "pr":
        title = "english phoneme recognition"
    else:
        title = "unknown"

    g = sns.lineplot(
        task_df,
        x="hours_seen",
        y="metric-value",
        hue="batch size",
        hue_order=hue_order,
        marker="o",
    )
    plt.title(task)
    plt.ylabel(task_df["metric"].unique()[0])
    plt.xlabel("hours seen during self-supervised pre-training")
    plt.xscale("log")
    g.set_xticks([5000, 10_000, 50_000, 100_000, 500_000, 1_000_000])
    plt.title(title)
    plt.show()

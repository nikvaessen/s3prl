import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import scienceplots

plt.style.use(["science", "bright"])
df_list = []


df1 = pd.read_json("vc2.json", lines=True)
df1["variation"] = "vc2"
df_list.append(df1)

# df2 = pd.read_json("tmlr.json", lines=True)
# df2["variation"] = "base"
# df_list.append(df2)

# df3 = pd.read_json("large.json", lines=True)
# df3["variation"] = "large"
# df_list.append(df3)

df = pd.concat(df_list)


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
    elif gpu == "vc2" or gpu == "large":
        if split_values[2] == "5min":
            bs = 60 * 5
        elif split_values[2] == "10min":
            bs = 60 * 10
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
style_order = sorted(df["variation"].unique())

print(tasks)
print(hue_order)

# sns.set_style("darkgrid")

# Define the figure and a 2x3 grid of subplots
fig, axes = plt.subplots(
    2, 3, figsize=(12, 8)
)  # Adjust figsize as needed for better clarity
# fig.tight_layout(pad=5)  # Adds padding between plots

# Create a mapping of tasks to titles
titles = {
    "asr": "English speech recognition",
    "asr-ood-zh": "Chinese speech recognition",
    "asv": "Speaker recognition",
    "er": "Emotion recognition",
    "ic": "Intent classification",
    "pr": "English phoneme recognition",
}

# List to hold handles and labels for the legend
handles = []
labels = []

# Loop over tasks and their respective subplot positions
for idx, task in enumerate(tasks):
    row = idx // 3  # Determine the row number (0 or 1)
    col = idx % 3  # Determine the column number (0, 1, or 2)
    ax = axes[row, col]  # Get the subplot axis

    task_df = df.loc[df["superb_task"] == task]
    title = titles.get(task, "Unknown")  # Get the title or "Unknown" if not found

    # Create the lineplot on the specific subplot axis
    g = sns.lineplot(
        data=task_df,
        x="hours_seen",
        y="metric-value",
        hue="batch size",
        hue_order=hue_order,
        style="variation",
        style_order=style_order,
        marker="o",
        ax=ax,  # Specify the axis to plot on
        legend=True,
    )

    # Store handles and labels for the legend
    for handle, label in zip(*ax.get_legend_handles_labels()):
        if label not in labels:  # Avoid duplicates in the legend
            handles.append(handle)
            labels.append(label)

    g.legend().remove()

    # Set plot labels and title for each subplot
    ax.set_title(title)
    ax.set_ylabel(task_df["metric"].unique()[0])
    ax.set_xlabel("Hours seen during self-supervised pre-training")
    ax.set_xscale("log")
    # ax.set_xticks([5000, 10_000, 50_000])


# Create a single legend to the right of the figure
# fig.legend(
#     handles, labels,
#     loc='center right',  # Location of the legend
#     bbox_to_anchor=(1.1, 0.5),  # Position the legend outside to the right of the plots
#     fontsize='medium'  # Font size of the legend
# )
fig.legend(handles, labels, loc="center right", bbox_to_anchor=(1, 0.5))

# Show the plot
plt.tight_layout(rect=[0, 0, 0.90, 1])
plt.show()

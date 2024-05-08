import os
import time
import psutil
import torch

from torch.utils.data import IterableDataset, DataLoader
from psutil._common import bytes2human


def get_n_gb_of_memory(num_gb):
    # 1 int64 number is 64 bits / 8 bytes
    # pretend to have x times 5 mb 'files'
    num_files = num_gb // 0.005
    return torch.randint(0, 10, (num_files, 625000), device="cpu", dtype=torch.int64)


def pprint_ntuple(nt):
    for name in nt._fields:
        value = getattr(nt, name)
        if name != "percent":
            value = bytes2human(value)
        print("%-10s : %7s" % (name.capitalize(), value))


class VirtualMemoryDataset(IterableDataset):
    def __init__(self, gb):
        self.tensor = get_n_gb_of_memory(gb)

    def __len__(self):
        return 200

    def __iter__(self):
        while True:
            for i in range(int(self.tensor.shape[0])):
                yield self.tensor[i]


def print_memory_info():
    process = psutil.Process(os.getpid())

    print("virtual memory")
    pprint_ntuple(psutil.virtual_memory())

    print("process memory info")
    pprint_ntuple(process.memory_info())
    print()

    time.sleep(3)


def main():
    # settings of debug script
    num_workers = 10  # roughly increase virtual memory use by 2x this factor
    start_method = "fork"  # one of 'fork', 'spawn', or 'forkserver'
    sharing_strategy = "file_descriptor"  # one of 'file_descriptor' or 'file_system'
    train_gb = 1
    val_gb = 1

    # set torch multiprocessing settings
    torch.multiprocessing.set_start_method(start_method)
    torch.multiprocessing.set_sharing_strategy(sharing_strategy)

    # create fake data
    print(f"creating 'train set' of {train_gb} GB of data")
    train_set = VirtualMemoryDataset(train_gb)
    print(f"creating 'validation set' of {val_gb} GB of data")
    validation_set = VirtualMemoryDataset(val_gb)

    # simulate a machine learning algorithm
    print("starting 'train' loop")
    validation_every_x_iters = 5
    for idx, _ in enumerate(DataLoader(train_set, batch_size=None, num_workers=num_workers)):
        print(f"memory usage in iteration {idx+1} iteration of loop")
        print_memory_info()

        if idx > 0 and idx % validation_every_x_iters == 0:
            print("starting 'validation' loop of 3 iterations")
            for i, _ in enumerate(
                DataLoader(validation_set, batch_size=None, num_workers=num_workers)
            ):
                print(f"memory usage in iteration {i} of validation loop")
                print_memory_info()

                if i > 3:
                    break


if __name__ == "__main__":
    main()

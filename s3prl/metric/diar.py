"""
Author       Jiatong Shi
Source       Refactored from https://github.com/hitachi-speech/EEND
Copyright    Copyright(c), Johns Hopkins University
"""

import torch
import numpy as np
from itertools import permutations


def calc_diarization_error(pred, label, length):
    (batch_size, max_len, num_output) = label.size()
    # mask the padding part
    mask = np.zeros((batch_size, max_len, num_output))
    for i in range(batch_size):
        mask[i, : length[i], :] = 1

    # pred and label have the shape (batch_size, max_len, num_output)
    label_np = label.data.cpu().numpy().astype(int)
    pred_np = (pred.data.cpu().numpy() > 0).astype(int)
    label_np = label_np * mask
    pred_np = pred_np * mask
    length = length.data.cpu().numpy()

    # compute speech activity detection error
    n_ref = np.sum(label_np, axis=2)
    n_sys = np.sum(pred_np, axis=2)
    speech_scored = float(np.sum(n_ref > 0))
    speech_miss = float(np.sum(np.logical_and(n_ref > 0, n_sys == 0)))
    speech_falarm = float(np.sum(np.logical_and(n_ref == 0, n_sys > 0)))

    # compute speaker diarization error
    speaker_scored = float(np.sum(n_ref))
    speaker_miss = float(np.sum(np.maximum(n_ref - n_sys, 0)))
    speaker_falarm = float(np.sum(np.maximum(n_sys - n_ref, 0)))
    n_map = np.sum(np.logical_and(label_np == 1, pred_np == 1), axis=2)
    speaker_error = float(np.sum(np.minimum(n_ref, n_sys) - n_map))
    correct = float(1.0 * np.sum((label_np == pred_np) * mask) / num_output)
    num_frames = np.sum(length)
    return (
        correct,
        num_frames,
        speech_scored,
        speech_miss,
        speech_falarm,
        speaker_scored,
        speaker_miss,
        speaker_falarm,
        speaker_error,
    )
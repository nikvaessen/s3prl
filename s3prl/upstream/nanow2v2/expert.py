import logging

import torch

from .wav2vec2 import Wav2vec2, Wav2vec2Config, RelativePositionLayer
from .pad import collate_append_constant

logger = logging.getLogger(__name__)


class UpstreamExpert(torch.nn.Module):
    def __init__(self, ckpt, is_large=False, *args, **kwds):
        super().__init__()

        ckpt = torch.load(ckpt, map_location="cpu")
        if "network" in ckpt:
            state = ckpt["network"]
            state = {k.removeprefix("w2v2."): v for k, v in state.items()}
        else:
            state = ckpt["state_dict"]
            state = {k.removeprefix("network."): v for k, v in state.items()}
            state = {k.removeprefix("w2v2."): v for k, v in state.items()}
            RelativePositionLayer.use_new_weight_conv = True

        del state["quantization_layer.quantization_choices"]
        del state["quantization_layer.temp"]
        del state["quantization_layer.classification_layer.weight"]
        del state["quantization_layer.classification_layer.bias"]
        del state["project_context_feature.weight"]
        del state["project_context_feature.bias"]
        del state["project_quantized_feature.weight"]
        del state["project_quantized_feature.bias"]

        if is_large:
            self.network = Wav2vec2(
                Wav2vec2Config(
                    num_layers=24,
                    num_heads=16,
                    num_dim_context=1024,
                    num_dim_fnn=1024 * 4,
                )
            )
        else:
            self.network = Wav2vec2(Wav2vec2Config())

        self.network.load_state_dict(state)

    def get_downsample_rates(self, key: str = None) -> int:
        return 320

    def forward(self, wavs):
        lengths = [tensor.shape[0] for tensor in wavs]
        inp = collate_append_constant(wavs)

        context_features, lengths = self.network(inp, lengths)

        return {"hidden_states": context_features}

import logging

import torch

from .wav2vec2 import Wav2vec2, Wav2vec2Config
from .pad import collate_append_constant

logger = logging.getLogger(__name__)


class UpstreamExpert(torch.nn.Module):
    def __init__(self, ckpt, **kwds):
        super().__init__()

        self.network = Wav2vec2(Wav2vec2Config())

        state = torch.load(ckpt, map_location="cpu")["network"]
        state = {k.removeprefix("w2v2."): v for k, v in state.items()}

        del state['quantization_layer.quantization_choices']
        del state['quantization_layer.temp']
        del state['quantization_layer.classification_layer.weight']
        del state['quantization_layer.classification_layer.bias']
        del state['project_context_feature.weight']
        del state['project_context_feature.bias']
        del state['project_quantized_feature.weight']
        del state['project_quantized_feature.bias']

        self.network.load_state_dict(state)

    def get_downsample_rates(self, key: str = None) -> int:
        return 320

    def forward(self, wavs):
        lengths = [tensor.shape[0] for tensor in wavs]
        inp = collate_append_constant(wavs)

        context_features, lengths = self.network(inp, lengths)

        return {"hidden_states": context_features}

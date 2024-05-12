from .expert import UpstreamExpert as _UpstreamExpert


def nanow2v2(ckpt, *args, **kwargs):
    return _UpstreamExpert(ckpt, *args, **kwargs)

from .expert import UpstreamExpert as _UpstreamExpert


def nanow2v2(ckpt, *args, **kwargs):
    return _UpstreamExpert(ckpt, False, *args, **kwargs)


def nanow2v2_large(ckpt, *args, **kwargs):
    return _UpstreamExpert(ckpt, True, *args, **kwargs)

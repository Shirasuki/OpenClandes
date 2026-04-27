@0xe4f5a6b7c8d9e0f1;

using Common = import "common.capnp";

interface ProxyService {
  probeProxy @0 (proxyUrl :Text) -> (
    success   :Bool,
    message   :Text,
    proxyInfo :Common.ProxyInfo,
    timing    :Common.ProbeTiming
  );
}

@0xc2d3e4f5a6b7c8d9;

interface ClaudeAuthService {
  startLogin @0 (
    redirectUri :Text,
    proxyUrl    :Text,
    version     :Text
  ) -> (authUrl :Text, sessionId :Text);

  completeLogin @1 (
    sessionId   :Text,
    code        :Text,
    callbackUrl :Text
  ) -> (
    success        :Bool,
    message        :Text,
    accessToken    :Text,
    refreshToken   :Text,
    expiresIn      :UInt64,
    accountId      :Text,
    email          :Text,
    organizationId :Text
  );

  refreshToken @2 (
    refreshToken :Text,
    proxyUrl     :Text,
    version      :Text
  ) -> (
    success        :Bool,
    message        :Text,
    accessToken    :Text,
    refreshToken   :Text,
    expiresIn      :UInt64,
    accountId      :Text,
    email          :Text,
    organizationId :Text
  );

  refreshAccountToken @3 (
    accountId :Text
  ) -> (
    success        :Bool,
    message        :Text,
    accessToken    :Text,
    refreshToken   :Text,
    expiresIn      :UInt64,
    accountId      :Text,
    email          :Text,
    organizationId :Text
  );
}

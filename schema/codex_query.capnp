@0xa5353c64839c32f2;

interface CodexQueryService {
  getProfile @0 (accountId :Text) -> (
    success          :Bool,
    message          :Text,
    accountId        :Text,
    chatgptAccountId :Text,
    email            :Text,
    planType         :Text
  );
}

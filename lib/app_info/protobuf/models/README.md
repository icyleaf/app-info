# Protobuf binary manifest

## Convert to ruby model

```bash
cd lib/app_info/protobuf/models

protoc --ruby_out=. Resources.proto
protoc --ruby_out=. Configuration.proto
```

## Resouces

`Configuration.proto` and `Resources.proto` can be found in aapt2's github:

- https://github.com/aosp-mirror/platform_frameworks_base/tree/master/tools/aapt2/Configuration.proto
- https://github.com/aosp-mirror/platform_frameworks_base/tree/master/tools/aapt2/Resources.proto

Source: https://gist.github.com/Farious/e841ef85a8f4280e4f248ba8037ea2c0#file-rollback_aab-sh-L51

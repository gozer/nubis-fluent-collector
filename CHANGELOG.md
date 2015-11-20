# Change Log

## [v1.0.1](https://github.com/nubisproject/nubis-fluent-collector/tree/v1.0.1) (2015-11-20)
[Full Changelog](https://github.com/nubisproject/nubis-fluent-collector/compare/v1.0.0...v1.0.1)

**Implemented enhancements:**

- Ingest logs from ELBs [\#32](https://github.com/nubisproject/nubis-fluent-collector/issues/32)

**Closed issues:**

- Tag  release [\#42](https://github.com/nubisproject/nubis-fluent-collector/issues/42)
- SQS region needs its own configuration option [\#37](https://github.com/nubisproject/nubis-fluent-collector/issues/37)
- Allow sending of logs to SQS with AWS API keys [\#35](https://github.com/nubisproject/nubis-fluent-collector/issues/35)
- Provide the S3 buckets names as inputs instead of re-constructing them. [\#33](https://github.com/nubisproject/nubis-fluent-collector/issues/33)
- Add plugin for ELB logs [\#28](https://github.com/nubisproject/nubis-fluent-collector/issues/28)
- Add plugin for SQS output [\#27](https://github.com/nubisproject/nubis-fluent-collector/issues/27)
- Allow specifying a Consul ACL token for fluent [\#24](https://github.com/nubisproject/nubis-fluent-collector/issues/24)
- Add StacksVersion to lambda calls, to allow for graceful forward upgrades [\#23](https://github.com/nubisproject/nubis-fluent-collector/issues/23)

**Merged pull requests:**

- Update AMI IDs file for v1.0.1 release [\#45](https://github.com/nubisproject/nubis-fluent-collector/pull/45) ([tinnightcap](https://github.com/tinnightcap))
- Update StacksVersion for v1.0.1 release [\#44](https://github.com/nubisproject/nubis-fluent-collector/pull/44) ([tinnightcap](https://github.com/tinnightcap))
- Handle the possiblilty that the SQS queue isn't in our own region [\#38](https://github.com/nubisproject/nubis-fluent-collector/pull/38) ([gozer](https://github.com/gozer))
- Add AWS API key support to SQS [\#36](https://github.com/nubisproject/nubis-fluent-collector/pull/36) ([gozer](https://github.com/gozer))
- Consume ELB logs from the VPC log bucket. [\#34](https://github.com/nubisproject/nubis-fluent-collector/pull/34) ([gozer](https://github.com/gozer))
- pin plugin versions [\#31](https://github.com/nubisproject/nubis-fluent-collector/pull/31) ([gozer](https://github.com/gozer))
- add elb plugin. Fixes \#28 [\#30](https://github.com/nubisproject/nubis-fluent-collector/pull/30) ([gozer](https://github.com/gozer))
- Add sqs plugin. Fixes \#27 [\#29](https://github.com/nubisproject/nubis-fluent-collector/pull/29) ([gozer](https://github.com/gozer))
- Add StacksVersion to VPCInfo call [\#26](https://github.com/nubisproject/nubis-fluent-collector/pull/26) ([gozer](https://github.com/gozer))
-  Add ConsulToken input argument [\#25](https://github.com/nubisproject/nubis-fluent-collector/pull/25) ([gozer](https://github.com/gozer))

## [v1.0.0](https://github.com/nubisproject/nubis-fluent-collector/tree/v1.0.0) (2015-08-31)
[Full Changelog](https://github.com/nubisproject/nubis-fluent-collector/compare/v0.9.0...v1.0.0)

**Implemented enhancements:**

- Cleanup CF templates since v0.9.0 [\#13](https://github.com/nubisproject/nubis-fluent-collector/issues/13)

**Closed issues:**

- Need to suppot multiple deployments in a single account. [\#20](https://github.com/nubisproject/nubis-fluent-collector/issues/20)
- CloudFormation needs to allow fluent traffic into the instance \(missing security group\) [\#15](https://github.com/nubisproject/nubis-fluent-collector/issues/15)
- Switch stacks to release from master [\#12](https://github.com/nubisproject/nubis-fluent-collector/issues/12)
- Tag v1.0.0 release [\#11](https://github.com/nubisproject/nubis-fluent-collector/issues/11)
- CloudFormation missing IAM role for bucket access [\#7](https://github.com/nubisproject/nubis-fluent-collector/issues/7)
- Pull in bucket name and bucket region from confd [\#6](https://github.com/nubisproject/nubis-fluent-collector/issues/6)

**Merged pull requests:**

- Add Startup fixups. [\#19](https://github.com/nubisproject/nubis-fluent-collector/pull/19) ([gozer](https://github.com/gozer))
- Manage our bucket and IAM role ourselves [\#18](https://github.com/nubisproject/nubis-fluent-collector/pull/18) ([gozer](https://github.com/gozer))

## [v0.9.0](https://github.com/nubisproject/nubis-fluent-collector/tree/v0.9.0) (2015-07-22)
**Closed issues:**

- Change the reported hostname to the instance-id [\#2](https://github.com/nubisproject/nubis-fluent-collector/issues/2)

**Merged pull requests:**

- Updating changelog for v0.9.0 release [\#9](https://github.com/nubisproject/nubis-fluent-collector/pull/9) ([gozer](https://github.com/gozer))
- add CF teamplte [\#5](https://github.com/nubisproject/nubis-fluent-collector/pull/5) ([gozer](https://github.com/gozer))
- General improvements for fluentd and s3 [\#3](https://github.com/nubisproject/nubis-fluent-collector/pull/3) ([gozer](https://github.com/gozer))
- Add consul registred fluentd collector [\#1](https://github.com/nubisproject/nubis-fluent-collector/pull/1) ([gozer](https://github.com/gozer))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
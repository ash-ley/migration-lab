import json
import boto3

client = boto3.client('mgn')


def main():
    if not get_home_control_region():
        create_migration_hub_service_control()
    if not is_mgn_service_initialized():
        # create_mgn_roles()
        # client.initialize_service()
        create_replication_template()
        create_launch_template()
        # create_mgn_iam_user()


def get_account_id():
    sts_client = boto3.client("sts")
    accountID = sts_client.get_caller_identity()["Account"]
    return accountID


def get_home_control_region():
    mgh = boto3.client('migrationhub-config')
    response = mgh.describe_home_region_controls(
        Target={
            'Type': 'ACCOUNT',
            'Id': get_account_id()
        }
    )
    return response['HomeRegionControls']


def create_migration_hub_service_control():
    mgh = boto3.client('migrationhub-config')
    session = boto3.session.Session()
    response = mgh.create_home_region_control(
        HomeRegion=session.region_name,
        Target={
            'Type': 'ACCOUNT',
            'Id': get_account_id()
        }
    )


def is_mgn_service_initialized() -> bool:
    try:
        client.describe_replication_configuration_templates(
            replicationConfigurationTemplateIDs=[])
    except client.exceptions.UninitializedAccountException:
        return False
    return True


def get_replication_template():
    return client.describe_replication_configuration_templates(replicationConfigurationTemplateIDs=[])


def create_replication_template():
    client.create_replication_configuration_template(
        associateDefaultSecurityGroup=False,
        bandwidthThrottling=0,
        createPublicIP=False,
        dataPlaneRouting='PRIVATE_IP',
        defaultLargeStagingDiskType='GP3',
        ebsEncryption='CUSTOM',
        ebsEncryptionKeyArn=get_kms_key(),
        replicationServerInstanceType='t2.medium',
        replicationServersSecurityGroupsIDs=[get_replication_sg()],
        stagingAreaSubnetId=get_staging_area_subnet_id(),
        stagingAreaTags={},
        useDedicatedReplicationServer=False
    )


def create_launch_template():
    client.create_launch_configuration_template(
        postLaunchActions={
            'deployment': 'TEST_AND_CUTOVER',
            'ssmDocuments': [
                {
                    'actionName': 'cloudwatchAgent',
                    'mustSucceedForCutover': True,
                    'parameters': {
                        'action': [
                          'configure',
                        ],
                        'mode': [
                            'ec2',
                        ],
                        'optionalConfigurationLocation': [
                            "default",
                        ],
                        'optionalConfigurationSource': [
                            'default',
                        ],
                        'optionalRestart': [
                            'yes',
                        ],
                    },
                    'ssmDocumentName': 'AmazonCloudWatch-ManageAgent',
                    'timeoutSeconds': 120
                },
            ]
        }
    )


def get_replication_sg():
    ec2_client = boto3.client('ec2')
    sg = ec2_client.describe_security_groups(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                        'replication_sg',
                ]
            }
        ]
    )
    return sg['SecurityGroups'][0]['GroupId']


def get_kms_key():
    kms_client = boto3.client('kms')
    key = kms_client.describe_key(
        KeyId='alias/ebs-key'
    )
    return key['KeyMetadata']['Arn']


def get_staging_area_subnet_id() -> str:
    ec2_client = boto3.client('ec2')

    vpc = ec2_client.describe_vpcs(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'migration-vpc',
                ]
            }
        ]
    )
    subnet = ec2_client.describe_subnets(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'migration-vpc-private-eu-west-1a',
                ]
            },
            {
                'Name': 'vpc-id',
                'Values': [
                    vpc['Vpcs'][0]['VpcId'],
                ]
            }
        ]
    )
    return subnet['Subnets'][0]['SubnetId']


# def create_mgn_iam_user():
#     mgn_iam_user_name = "MGNUser"
#     boto3.client('iam').create_user(UserName=mgn_iam_user_name)
#     mgn_user = boto3.resource('iam').User(mgn_iam_user_name)
#     mgn_user.attach_policy(
#         PolicyArn='arn:aws:iam::aws:policy/AWSApplicationMigrationAgentPolicy')


# def create_mgn_roles():
#     assume_role_policy = {"Version": "2012-10-17", "Statement": [
#         {"Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}
#     iam_client = boto3.client('iam')
#     iam_resource = boto3.resource('iam')
#     for role_name in ["AWSApplicationMigrationReplicationServerRole", "AWSApplicationMigrationConversionServerRole", "AWSApplicationMigrationMGHRole"]:
#         try:
#             iam_client.create_role(Path='/service-role/', RoleName=role_name,
#                                    AssumeRolePolicyDocument=json.dumps(assume_role_policy))
#         except iam_client.exceptions.EntityAlreadyExistsException:
#             continue
#     iam_resource.Role("AWSApplicationMigrationReplicationServerRole").attach_policy(
#         PolicyArn="arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationReplicationServerPolicy")
#     iam_resource.Role("AWSApplicationMigrationConversionServerRole").attach_policy(
#         PolicyArn="arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationConversionServerPolicy")
#     iam_resource.Role("AWSApplicationMigrationMGHRole").attach_policy(
#         PolicyArn="arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationMGHAccess")


if __name__ == "__main__":
    main()

/**
* # Gitaly Module
*
* ## Additional details
*
* <b>Detail 1: Configuring an additional mounted EBS volume to route the git_data_dirs to</b>
*
* Use case: Store application repositories on its own volume
*
* 1. Create a new EBS volume. Choose the `Volume Type`, `Size (GiB)`, `Availability Zone`, `Encryption`. Attach this volume to the Gitaly instance. Fun fact: It can only attach to instances in the same AZ where it was created
* 2. [Making an Amazon EBS volume available for use on Linux documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html) describes how to mount an additional volume on an instance and auto mount an attached volume after reboot
* ```bash
* # 1. Get the Block Name which will be used thorughout
* lsblk
* # =====
* # Sample Output. In this case the volume is 100G and its name is nvme1n1
* # =====
* NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
* loop0         7:0    0 55.4M  1 loop /snap/core18/1932
* loop2         7:2    0 28.1M  1 loop /snap/amazon-ssm-agent/2012
* loop3         7:3    0 97.7M  1 loop /snap/core/10126
* loop4         7:4    0 97.8M  1 loop /snap/core/10185
* loop5         7:5    0 28.1M  1 loop /snap/amazon-ssm-agent/2333
* nvme0n1     259:0    0    8G  0 disk
* └─nvme0n1p1 259:1    0    8G  0 part /
* nvme1n1     259:2    0  100G  0 disk
*
* # 2. Verify that the volume is empty
* sudo file -s /dev/nvme1n1
* # =====
* # Sample Output. If the output shows data, there is no file system on the device. Must create one.
* # =====
* /dev/nvme1n1: data
*
* # 3. Create a file system on the volume.
* sudo mkfs -t xfs /dev/nvme1n1
* # =====
* # Sample Output.
* # =====
* meta-data=/dev/nvme1n1           isize=512    agcount=4, agsize=6553600 blks
*          =                       sectsz=512   attr=2, projid32bit=1
*          =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
* data     =                       bsize=4096   blocks=26214400, imaxpct=25
*          =                       sunit=0      swidth=0 blks
* naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
* log      =internal log           bsize=4096   blocks=12800, version=2
*          =                       sectsz=512   sunit=0 blks, lazy-count=1
* realtime =none                   extsz=4096   blocks=0, rtextents=0
*
* # 4. Create a mount point directory for the volume
* sudo mkdir /gitlab
*
* # 5. Mount the volume at the directory you created in the previous step
* sudo mount /dev/nvme1n1 /gitlab
*
* # 6. Create a backup of your /etc/fstab file that you can use if you accidentally destroy or delete this file while editing it.
* sudo cp /etc/fstab /etc/fstab.orig
*
* # 7. Use the blkid command to find the UUID of the device
* sudo blkid
* # =====
* # Sample Output. Retrieve the UUID of the last entry 333a116f-7e12-48b5-bf6a-1701cb5c8433
* # =====
* /dev/nvme0n1p1: LABEL="cloudimg-rootfs" UUID="2ce321d3-087f-4a58-8f97-ed6135e77fee" TYPE="ext4" PARTUUID="b93804ca-01"
* /dev/loop0: TYPE="squashfs"
* /dev/loop2: TYPE="squashfs"
* /dev/loop3: TYPE="squashfs"
* /dev/loop4: TYPE="squashfs"
* /dev/loop5: TYPE="squashfs"
* /dev/nvme0n1: PTUUID="b93804ca" PTTYPE="dos"
* /dev/nvme1n1: UUID="333a116f-7e12-48b5-bf6a-1701cb5c8433" TYPE="xfs"
*
* # 8. Add the following entry to /etc/fstab. Replace the UUID with the relevant one
* echo "UUID=333a116f-7e12-48b5-bf6a-1701cb5c8433  /gitlab  xfs  defaults,nofail  0  2" >> /etc/fstab
*
* # 9. Verify (should have no errors)
* sudo umount /gitlab
* sudo mount -a
* ```
*
* Useful helper function to find the file systems used by the different volumes: `df -T`
*
* <b>Detail 2: Change git_data_dirs path to the new volume</b>
*
* 1. Copy the files over to the new volume: `cp -r /var/opt/gitlab/git-data /gitlab/git-data`
* 2. Change directory to the new volume: `cd /gitlab`
* 3. Change permissions of the folder and sub-folders: `chown -R git:root git-data`
* 4. Change directory to the rb file: `cd /etc/gitlab`
* 5. Modify `gitla.rb`. Change the `git_data_dirs` path to `/gitlab/git-data` for the appropriate gitaly instance
* 6. Reconfigure. `sudo gitlab-ctl reconfigure`
*
*/

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200611"]
  }

  owners = ["099720109477"]
}

data "template_file" "this" {
  template = "${file("../../modules/gitaly_cluster/gitaly/gitaly_install_13_2_3.sh")}"

  vars = {
    praefect_internal_token = var.praefect_internal_token,
    secret_token            = var.secret_token,
    visibility              = var.visibility,
    lb_dns_name             = var.lb_dns_name,
    instance_dns_name       = var.instance_dns_name
  }
}

resource "aws_instance" "this" {
  count = length(var.private_ips_gitaly)

  ami                    = data.aws_ami.this.id
  iam_instance_profile   = var.iam_instance_profile
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = var.subnet_ids[count.index]
  private_ip             = var.private_ips_gitaly[count.index]
  key_name               = var.gitaly_key_name
  user_data              = data.template_file.this.rendered

  tags = {
    Name = "Gitaly-${1 + count.index}"
  }
}

resource "aws_security_group" "this" {
  name        = "gitaly-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitaly instance"

  tags = {
    Name = "gitaly-sec-group"
  }
}

resource "aws_security_group_rule" "ingress_ssh" {
  description              = "Allow ingress over SSH, port 22 (TCP), thru to gitaly"
  security_group_id        = aws_security_group.this.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.ssh_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_gitaly" {
  description              = "Allow custom ingress for praefect to communicate with Gitaly"
  security_group_id        = aws_security_group.this.id
  from_port                = 8075
  to_port                  = 8075
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.custom_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_prometheus" {
  description              = "Allow prometheus metrics access to praefect"
  security_group_id        = aws_security_group.this.id
  from_port                = 9236
  to_port                  = 9236
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.prometheus_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_prometheus_self" {
  description       = "Allow prometheus metrics access to gitaly"
  security_group_id = aws_security_group.this.id
  from_port         = 9236
  to_port           = 9236
  protocol          = "tcp"
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "egress_all" {
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.this.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
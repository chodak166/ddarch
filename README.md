# DDARCH

# Table of Contents

1. [Overview](#overview)  
1.1. [Motivation](#motivation)  
	1.2. [Main features](#main-features)  
	1.3. [Precautions](#precautions)  
2. [Quick start](#quick-start)  
	2.1. [Archiving](#archiving)  
	2.2. [Restoring](#restoring)  
	2.3. [Sourcing](#sourcing)  
3. [Installation](#installation)  
4. [Dependencies](#dependencies)  
5. [Usage](#usage)

-----

# Overview

Ddarch is a simple helper script that wraps `dd`, `fdisk`, `parted` along with other tools to easily create, preserve and restore disk images. 

 [Back to top](#table-of-contents)

## Motivation
Excluding sparse files (which have their drawbacks), `dd` leaves you with an image equal in size to the size of the input media. Such an image may contain empty spaces, unpartitioned volumes, and be cumbersome to compress and store. Restoring an image to a device of a different size may also require appropriate modifications to the image (partition resizing, trimming) or the device itself (enlarging the partition after restoring). This tool was created to make these steps a little easier.

 [Back to top](#table-of-contents)

## Main features
Ddarch may help you with:

- creating a disk image with dd;
- truncating unpartitioned space at the end of an image;
- resizing the last partition;
- filling free spaces with zeros for more efficient compression;
- compressing images (7z, zip, tgz);
- maintaining GUID Partition Table (GPT) integrity;
- restoring images with on-the-fly decompression (using pipes);
- expanding the last partition after restore;
- checking file systems after restore (by running fsck);
- making functions available for use in other scripts (sourcing).

 [Back to top](#table-of-contents)

## Precautions
In most cases, this script will require root user privileges. Backing up your disk images or using `dd` first is strongly recommended, especially when the `--in-place` flag is involved. You have been warned.

 [Back to top](#table-of-contents)

# Quick start

## Archiving

Create an archive from a block device (sdx) with the default output name
(clone, shrink, fill with zeroes, truncate, compress):

```
ddarch archive -i /dev/sdx
```

which is the same as:

```
ddarch -i /dev/sdx
```
Create ZIP archive from a block device (sdx) without resizing and truncating the output image:

```
ddarch -i /dev/sdx --no-resizepart --no-truncate --arch-type zip --name raspbian-buster
```

Create an .img file (no compression) from a block device with 10MiB free
space on the last partition and 5MiB of unpartitioned space:

```
ddarch -i /dev/sdx -a none --resizepart-tail $((10*1024*1024)) --truncate-tail $((10*1024*1024))
```
Resize and truncate given image (non-invasive, requires extra space):

```
ddarch -i my_image.img -o my_image_min.img --arch-type none
```

Resize and truncate given image (invasive! no extra space needed):

```
ddarch -i my_image.img -o my_image_min.img --arch-type none --in-place
```

## Restoring

Copy given image to the device, extend the last partition to the largest possible size and verify the file system:

```
ddarch restore -i my_image.img -o /dev/sdx --verify
```

Restore 7z archive to a block device without extending the last partition
(the image will be extracted through a pipe based on the file extension):

```bash
ddarch restore -i my_image.img.7z -o /dev/sdx --no-extend
```

 [Back to top](#table-of-contents)

## Sourcing
Ddarch offers several flags to customize the overall process. However, it can be helpful to simply call individual functions from other scripts or interactively from the command line. You can import all functions by executing:
```
source ddarch
```
to later use e.g:
```
shrinkLastPartition my_image.img 0
truncateImage my_image.img 0
```
See `ddarch --functions` to learn more.

 [Back to top](#table-of-contents)

# Installation
> TODO

 [Back to top](#table-of-contents)

# Dependencies
The script uses tools from the following Debian packages:

- `bash`
- `coreutils` (dd, head, tail, etc.)
- `parted`
- `fdisk`
- `e2fsprogs`
- `p7zip-full`, `zip`, `unzip` (optional)

 [Back to top](#table-of-contents)

# Usage
Call syntax:
```
ddarch [command] [options]
```
Commands:

- `archive` (default) - shrink, truncate and compress image file; clone first if the input is a block device.
- `restore` - copy the image to the device and extend the last partition; decompress and pass through a pipe if the input is an archive (identify by the extension).

The `archive` command options:

```text
  -i, --input [file]             input image file or block device
  -o, --output [file]            output file, defaults to '<yyyy-mm-dd>-image.<ext>'
  -d, --dd-args [string]         additional dd arguments
  -a, --arch-type [string]       archive type: tgz, zip, 7z, none
  -n, --name [string]            replace "image" suffix of the output file name with the given name
  --resizepart-tail [bytes]      additional empty space left in the shrunk partition (1MiB by default)
  --truncate-tail [bytes]        additional empty space left in the truncated image (1MiB by default)
  --no-resizepart                do not resize the last partition
  --no-truncate                  do not truncate the image
  --no-zero                      do not fill empty space with zeros
  --in-place                     edit input file when it's an image (and remove after compression)
  --mnt-dir [dir]                temporary mount location; defaults to /tmp/ddarch.mnt.<timestamp>
```

The `restore` command options:

```text
  -i, --input [file]             input .img file or an archive (tar.gz, tgz, zip, 7z)
  -o, --output [device]          target block device
  -d, --dd-args [string]         additional dd arguments
  --no-extend                    do not extend the last prtition to fit the target device size
  --verify                       compare input file and device checksums
```

Common options:

```text
  -V, --verbose                  print the commands being executed and additional information
  -q, --quiet                    do not print any output
  -y, --yes                      say yes to everything (non-interactive mode)
  -w, --work-dir [dir]               working directory for temporary files; defaults to /tmp/ddarch.<timestamp>
  -D, --debug                        Run in debug mode
  -f, --functions                List functions to be used after sourcing
  -h, --help                     Display this message
  -v, --version                  Display script version
```



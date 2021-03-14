# ddarch

A simple helper script for archiving dd imagesddarch v0.1.0

```
Usage: ddarch [command] [options]

Commands:

archive [default]                shrink, truncate and compress image file; clone first if the input is a block device
Options:
  -i, --input [file]             input image file or block device
  -o, --output [file]            output file, defaults to '<yyyy-mm-dd>-image.<ext>'
  -d, --dd-args [string]         additional dd arguments
  -a, --arch-type [string]       archive type: tgz, zip, 7z, none
  -n, --name [string]            replace "image" suffix of the output file name with the given name
  --resizepart-tail [bytes]      additional empty space left in the shrunk partition
  --truncate-tail [bytes]        additional empty space left in the truncated image
  --no-resizepart                do not resize the last partition
  --no-truncate                  do not truncate the image
  --no-zero                      do not fill empty space with zeros
  --in-place                     edit input file when it's an image (and remove after compression)
  --mnt-dir [dir]                temporary mount location; defaults to /tmp/ddarch.mnt.<timestamp>


restore                          copy the image to the device and extend the last partition; decompress first if the input is an archive
Options:
  -i, --input [file]             input .img file or an archive (tar.gz, tgz, zip, 7z)
  -o, --output [device]          target block device
  -d, --dd-args [string]         additional dd arguments
  --no-extend                    do not extend the last prtition to fit the target device size
  --verify                       compare input file and device checksums


Global options:
  -V, --verbose                  print the commands being executed and additional information
  -q, --quiet                    do not print any output
  -y, --yes                      say yes to everything (non-interactive mode)
  --work-dir [dir]               working directory for temporary files; defaults to /tmp/ddarch.<timestamp>
  --debug                        Run in debug mode
  -f, --functions                List functions to be used after sourcing
  -h, --help                     Display this message
  -v, --version                  Display script version


Examples (archiving):

Create an archive from a block device with default output name
(clone, shrink, fill with zeroes, truncate, compress):

  ddarch -i /dev/sdx # (the same as ddarch archive -i /dev/sdx)

Create ZIP archive from a block device without resizing and truncating:

  ddarch -i /dev/sdx --no-resizepart --no-truncate --arch-type zip --name raspbian-buster

Create img file (no compression) from a block device with 10MiB free
space on the last partition and 5MiB of unpartitioned space:

  ddarch -i /dev/sdx -a none --resizepart-tail $((10*1024*1024)) --truncate-tail $((10*1024*1024))

Resize and truncate given image (non-invasive, requires extra space):

  ddarch -i my_image.img -o my_image_min.img --arch-type none

Resize and truncate given image (invasive! no extra space needed):

  ddarch -i my_image.img -o my_image_min.img --arch-type none --in-place


Examples (restoring):

Copy given image to a block device, extend the last partition to its capacity
and verify restored filesystems:

  ddarch restore -i my_image.img -o /dev/sdx --verify

Restore 7z archive to a block device without extending the last partiion
(the image will be extracted through a pipe based on the file extension):

  ddarch restore -i my_image.img.7z -o /dev/sdx --no-extend
```

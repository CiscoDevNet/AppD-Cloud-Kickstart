#!/bin/sh -eux
# create new swap file on centos linux 7.x.

# set default values for swap file environment variables. ------------------------------------------
swap_file="${swap_file:-/swapfile}"         # [optional] swap file name (defaults to '/swapfile').
swap_size="${swap_size:-16}"                # [optional] swap file size (defaults to '16' [16GiB]).

# create swap file. --------------------------------------------------------------------------------
# allocate swap file and set file permissions.
dd if=/dev/zero of=${swap_file} bs=1G count=${swap_size}
chmod 600 ${swap_file}

# set up a linux swap area in the file.
mkswap ${swap_file}

# enable the swap file for paging and swapping.
swapon ${swap_file}

# verify swap configuration.
swapon -s

# persist the swap file configuration. -------------------------------------------------------------
fstab_file="/etc/fstab"
if [ -f "$fstab_file" ]; then
  cp -p $fstab_file ${fstab_file}.orig

  # append the 'swap' entry to the 'fstab' file.
  echo "${swap_file}   swap    swap    sw  0   0" >> ${fstab_file}

  # verify configuration.
  grep 'swap' "$fstab_file"
fi

./add_24bit_header.sh  $1 /tmp/tmpmusic.bin
ftdiflash -o 2M  /tmp/tmpmusic.bin


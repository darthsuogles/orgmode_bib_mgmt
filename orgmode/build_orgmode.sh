#!/bin/bash

ver=8.2.5h

function quit_with()
{
    printf "Error [ $0 ]\n"
    printf ">> %s\n" "$@"
    exit
}

if [ ! -d $ver ]; then
    fname=org-$ver
    tarball=$fname.tar.gz
    if [ ! -f $tarball ]; then
	curl -O http://orgmode.org/$tarball || \
	    quit_with "cannot download $tarball from url"
    fi
    echo "Uncompressing ... might take a while ... please be patient"
    ## Currently OSX's tar has problem with pipe
    #fname=`tar -zxvf $tarball | sed -e 's@/.*@@' | uniq`
    tar -zxvf $tarball
    #echo "fname: $fname"
    if [ -z "$fname" ] || [ ! -d "$fname" ]; then
	quit_with "failed to decompress $tarball"
    fi
    if [ $fname != $ver ]; then mv $fname $ver; fi
    rm $tarball
fi


cd $ver
make
make test
cd ..

ln -s $ver current
echo "!!!! **** !!!!"
echo 
echo ";; Add the followling line to your .emacs file, prior to setting up orgmode"
echo "  (setq org_install_path \"$PWD\") "
echo "  (load (concat org_install_path \"/org-customization.el\"))  "
echo 
echo "!!!! **** !!!!"

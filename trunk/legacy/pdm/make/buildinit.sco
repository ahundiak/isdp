#This script builds the PDMinit image for a SCO server.

echo
echo "Building PDMinit for SCO server"
echo

export TMPDIR=/usr/tmp
export INFORMIXDIR=/usr/informix
export NFM=/u2/ip32/nfmdp
export PDM=/u2/devpdm
export PDU=/u/devpdu
export LIBDIR=/u2/ip32/nfmdp
export RIS=/u2/ip32/ris/risdp
export DBA=/usr/ip32/dbadev
export EXNUC=/usr/ip32/exnucdp
export FORMS=/usr/ip32/forms
export FTR=/u2/ip32/ftrdp
export UMS=/usr/ip32/ums
export TARG2=i386
export PDULOGNAME=devpdu
export PDMLOGNAME=devpdm

export TARG=smp
export COMP=cc
export COMP_OPT="-ansi -O3 -Dsco"

echo
echo "Do you wish to remove .o files (y/n)? [n] \c"
read REMOVEOBJ
echo

if [ "$REMOVEOBJ" = "y" ]
then
export REMOVEOBJ=y
fi

echo
echo "Do you wish to collect the PDMinit image for delivery?"
read DELIVER
echo

if [ "$DELIVER" = "y" ]
then
export DELIVER=y
fi

if [ "$DELIVER" != "n" ]
then
echo "Please give post date/time for collecting and delivering PDMinit."
echo "Ex. 07271600 means July 27th @ 4:00 p.m.: \c"
read POSTDATE
echo
echo "Please give version reference for products to be collected."
echo "Ex. version 2.4.x.x would be reference with 24: \c"
read VERREF
export VERREF=$VERREF
echo

while [ "$VERREF" = "" ]
do
echo "Please give version reference for PDMinit."
read VERREF
export VERREF=$VERREF
echo
done
fi

echo
echo "Retrieving PDU cpio file"
echo
cd $PDU
ftp -n pdmdel <<- END
        user pdu24src pdubld
        binary
        get pdu24.cpio
        quit
        END

echo
echo "Retrieving PDM cpio file"
echo
cd $PDM
ftp -n pdmdel <<- END
        user pdm24src pdmbld
        binary
        get pdm24.cpio
        quit
        END

cd $PDU
cat pdu24.cpio | compress -d | cpio -ivmud
find . -print | xargs chmod 777
find . -print | xargs chown $PDULOGNAME
find . -print | xargs chgrp group
rm pdu24.cpio

cd $PDM
cat pdm24.cpio | compress -d | cpio -ivmud
find . -print | xargs chmod 777
find . -print | xargs chown $PDMLOGNAME
find . -print | xargs chgrp group
rm pdm24.cpio

if [ "$REMOVEOBJ" = "y" ]
then
echo "Removing object files and libraries"
cd $PDM/init
rm *.o
cd $PDM/tools
rm *.o
cd $PDM/ris
rm *.o
cd $PDM/lib/$TARG
rm PDMtools.a
rm PDMinit.a
rm PDUris_rc.a
cd $PDM/bin
rm PDMinit
fi

echo
echo "Compiling message files"
echo
cd $PDU/messages
./umsall

echo
echo "Compiling $PDM/init directory"
echo
cd $PDM/init
make -f makeinit.sco

echo
echo "Compiling $PDM/ris directory"
echo
cd $PDM/tools
make -f makefile.sco

echo
echo "Compiling $PDM/ris directory"
echo
cd $PDM/ris
make -f risscomake
make -f makefile.sco

echo
echo "Compiling PDMglobals.c"
echo
cd $PDM/make
cp $PDU/kernal/PDMglobals.c .
make -f globmake.sco

echo
echo "Linking PDMinit executable"
echo
make -f makeinit.sco

if [ "$DELIVER" != "n" ]
then
cd $PDM/delivery
echo "Calling collect_pdmsco"
echo
echo "***************************************************************"
echo "$TARG -- collect_pdm started at:"
date
echo "***************************************************************"

$PDM/delivery/./collect_pdmsco $POSTDATE

echo "Calling deliver_pdmsco"
echo
echo "***************************************************************"
echo "$TARG -- deliver_pdm started at:"
date
echo "***************************************************************"

$PDM/delivery/./deliver_pdmsco $POSTDATE
fi

#reset file permissions and ownerships
find . -print | xargs chmod 777
find . -print | xargs chown $PDMLOGNAME
find . -print | xargs chgrp group

echo
echo "SCO PDMinit build complete"
echo

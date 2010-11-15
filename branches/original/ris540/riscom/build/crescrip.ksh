#!/bin/ksh
#
#	The template file (template.ksh) is divided into several sections.
#	To add Section_X to the install script for a product, simply add
#	SECTION_X=p to that products section of the case statement below.
#
#	Currently, there are 6 sections in the template file
#
#	Section 1 contains all the initialization code: setting up variables,
#	commands and shell functions.  All scripts should use this section.
#
#	Section 1u contains declarations used for RIS user installation.
#
#	Section 1d contains declarations used for RIS developement installation.
#
#	Section 2 make the TCP/IP installations. This will be used by the
#	all servers and the client.
#
#	Section 3 make the DNP and XNS installations. This will be used only
#	by CLIX servers and the client.
#
#	Section 4 changes the owner and permissions for products with a single
#	executable.  This will be called by all the servers.
#
#	The followings are set only for the CLIX servers and the client.
#	XNSENTRY must be set for servers with valid xns entries in server.dat.
#	DNPENTRY must be set for servers with valid dnp entries in servers.reg.
#

if [ $# -ne 2 ]
then
	print "Usage: $0 product_name [D|U]"
	exit 1
fi

PRODUCT=$1
case $2 in
	D)	SECTION_1d=p
		SECTION_1u=
		;;
	U)	SECTION_1d=
		SECTION_1u=p
		;;
	*)	print "Usage: $0 product_name [D|U]"
		exit 1 ;;
esac

SECTION_1=p
SECTION_2=
SECTION_3=
SECTION_4=

XNSENTRY=
DNPENTRY=

case $PRODUCT in

	risdp)
		TITLE="RIS Development Platform"
		PROJECT=risapp
		;;

	risutl)
		TITLE="RIS Utilities"
		PROJECT=risutl
		;;

	riscli)
		TITLE="RIS Client"
		PROJECT=riscli
		SECTION_2=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			DNPENTRY=RISC
			SECTION_3=p
		fi
		;;

	rissybds)
		TITLE="RIS Sybase Dataserver"
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		;;

	risinfds|risinfns)
		if [ "$PRODUCT" = "risinfds" ]
		then
			TITLE="RIS Informix Dataserver"
		else
			TITLE="RIS Informix Netserver"
		fi
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			DNPENTRY=RISX
			SECTION_3=p
		fi
		;;

	risorads|risorans)
		if [ "$PRODUCT" = "risorads" ]
		then
			TITLE="RIS Oracle Dataserver"
		else
			TITLE="RIS Oracle Netserver"
		fi
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			XNSENTRY=31
			DNPENTRY=RISO
			SECTION_3=p
		fi
		;;

	risingds|risingns)
		if [ "$PRODUCT" = "risingds" ]
		then
			TITLE="RIS Ingres Dataserver"
		else
			TITLE="RIS Ingres Netserver"
		fi
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			XNSENTRY=32
			DNPENTRY=RISI
			SECTION_3=p
		fi
		;;

	risdb2ds)
		TITLE="RIS DB2 Dataserver"
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			DNPENTRY=RISD
			SECTION_3=p
		fi
		;;

	risos4ds)
		TITLE="RIS OS400 Dataserver"
		PROJECT=rissrv
		SECTION_2=p
		SECTION_4=p
		if [ "$TARGET" = "c100" -o "$TARGET" = "c400" ]
		then
			SECTION_3=p
		fi
		;;

	*)
		print "$0: unknown product $PRODUCT"
		exit 1
		;;
esac

sed -n  -e s!replace_this_word!"$TITLE"! \
		-e s!executable_name!$PRODUCT! \
		-e s!project_name!$PROJECT! \
		-e s!xns_entry_name!$XNSENTRY! \
		-e s!dnp_entry_name!$DNPENTRY! \
		-e s!SECTION_1:!!$SECTION_1 \
		-e s!SECTION_1d:!!$SECTION_1d \
		-e s!SECTION_1u:!!$SECTION_1u \
		-e s!SECTION_2:!!$SECTION_2 \
		-e s!SECTION_3:!!$SECTION_3 \
		-e s!SECTION_4:!!$SECTION_4 \
	$RISDEVDIR/riscom/build/template.ksh > \
	$RISDEVDIR/$PROJECT/bin/$PRODUCT.ksh

chmod +x $RISDEVDIR/$PROJECT/bin/$PRODUCT.ksh

/* $Id $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdtbl/xml/vditblxml.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vditblxml.m,v $
 *      Revision 1.1  2001/08/16 22:02:45  ylong
 *      Export table to xml
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDtblXml.I
#else
VDtblXml.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
$VDS_PATH/lib/vditblxml.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


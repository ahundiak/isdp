/* $Id: cicocp.m,v 1.1 2001/03/13 16:39:03 ad Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/pdu1/vdgr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cicocp.m,v $
 *	Revision 1.1  2001/03/13 16:39:03  ad
 *	Add files for ETL4007 & MP4079
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
PDMCheckOut.c
PDMcp_files.c

INCLUDE
$(PDM)/include
$(PDMDP)/include
$(PDM)/pdmapi/include
$(PDU)/include
$(PDUDP)/include
$(NFM)/include
$(PDUDP)/include
$(NFMDP)/include
$(RIS)/include
$(RIS)/errmsg
$(EXNUC)/include
$(INGRHOME)/include

CC
$(COMP)

COPT
$(COMP_OPT)

LIB
./Pdm.o


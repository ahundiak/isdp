/* $Id: VDCmdHole.S,v 1.1.1.1 2001/01/04 21:09:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/cmd / VDCmdHole.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdHole.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*  VDCmdHole.S
/*  P L
/*  26 MAY 1991
/*
/*  Abstract
/*	New class of CO to place an occurence of a hole on surface.
/*
/*  History
/*
/*---------------------------------------------------------------------------*/

class specification VDCmdHole (0:1) of COm_place;

#include "ACdb_info.h"

override
  init,
  wakeup,
  prompt_macro,
  pro_occ,
  get_default_template;

end specification VDCmdHole;

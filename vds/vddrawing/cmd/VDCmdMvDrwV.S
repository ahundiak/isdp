/* $Id: VDCmdMvDrwV.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddrawing/cmd /VDCmdMvDrwV.S
 *
 * Description:
 *      This file contains the specification for the Move Drawing View
 *      commands. This command is used to move drawing view object without 
 * 	recompute.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdMvDrwV.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/08/29  15:46:18  pinnacle
# Created: vddrawing/cmd/VDCmdMvDrwV.S by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/28/97        YZHU            Create
 * -------------------------------------------------------------------*/



class specification VDCmdMvDrwV (1:0) of COmanip;



#include "comndef.h"
#include "comn.h"


instance VDCmdMvDrwV
{
    IGRint	            Recomputeflag; /* flag for recompute
					    = 1 no recompute
                                            = 0 recompute */
};


message VDsetDrwRecomputeOn ( );
message VDsetDrwRecomputeOff ( );

end specification VDCmdMvDrwV;

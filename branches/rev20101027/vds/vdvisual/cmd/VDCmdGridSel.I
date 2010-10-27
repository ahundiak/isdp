/* $Id: VDCmdGridSel.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdGridSel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdGridSel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
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

class implementation DPvd;
/*--------------------------------------------------------------------------*
 * This file is a copy of DPvd_actwin and made some motification
 * 1. add:
 *	extern	GRclassid	 OPP_VDgragadGrid_class_id;
 * 2. modification:
 *
 *	
 *    Correction to find window grids (supported by I/VDS).
 *    modified on 4/26/94
 *
 *	IGRint ii;
 *	GRclassid classid;
 *
 *	for( ii = 0; ii < num_on_channel ; ii++ ){
 *
 *	    status =
 *	    om$get_classid(	objid = linkage[ii].S_objid,
 *				osnum = linkage[ii].osnum,
 *				p_classid = &classid );
 *
 *	   if( status && om$is_ancestry_valid(
 *				subclassid = classid,
 *				superclassid = OPP_VDgragadGrid_class_id ) ==
 *						OM_S_SUCCESS ){
 *
 *		found = TRUE;
 *      		awin->win_no     = lwin; 
 *  		awin->grid.osnum = linkage[ii].osnum;
 *     		awin->grid.objid = linkage[ii].S_objid;
 *
 *		break;
 *	   }
 *	}
 *---------------------------------------------------------------------------*/
   
#include <alloca.h>

#include "griomacros.h"
#include "OMerrordef.h"

#include "DPvd.h"
#include "dp.h"
#include "dpmacros.h"
#include "ex.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "igewinchan.h"
#include "exdef.h"
#include "msdef.h"
#include "msmacros.h"

extern	GRclassid	 OPP_VDgragadGrid_class_id;

/*--- DPvd_get_active_window_id ----------------------------------------*/

int DPvd_get_active_window_id (int hwwin, struct DPvd_actwin *awin)

/*
NAME
        DPvd_get_active_window_id

DESCRIPTION
        This function makes the given window number the active window number
        for view dynamics. (in case of changing the active window)

SYNOPSIS
        extern int DPvd_get_active_window_id(int hwwin, struct DPvd_actwin *awin)

PARAMETERS
        int hwwin (IN)                - hardware window number
        struct DPvd_actwin awin (OUT) - complete description of active window

GLOBALS USED
        none

RETURN VALUES
        status (1=OM_S_SUCCESS | 0)

NOTES

HISTORY
        06/05/93    G.Werner
           Creation Date

*/

{
   IGRint status;
   IGRint found=FALSE;
   WLuint32 lwin;
   OMuword win_os;
   OM_S_OBJID win_oid;
   OMuint num_on_channel;
   OM_S_OBJECT_LINKAGE *linkage;

   OM_S_CHANSELECT IGE_to_gragad_chan;
  
   /* win_no of IGEwindow */
   status = EX_trans_win( hwwin, &lwin, &win_os, &win_oid );
   if ( status != WL_SUCCESS )
   {
      return( FALSE );
   }

   om$make_chanselect( channame = "IGEgadget.to_children",
                       p_chanselect = &IGE_to_gragad_chan);


   if ( awin )
   {
      status = om$get_channel_count( osnum = win_os,
                                     objid = win_oid,
                                     p_chanselect = &IGE_to_gragad_chan,
                                     count = &num_on_channel );

      if ( !( status & 1 ) )
      {
         return(FALSE);
      }

      linkage = (OM_S_OBJECT_LINKAGE *) alloca( num_on_channel * sizeof( OM_S_OBJECT_LINKAGE ) );

      status = om$get_channel_objects( osnum = win_os,
                                       objid = win_oid,
                                       p_chanselect = &IGE_to_gragad_chan,
                                       list = linkage,
                                       size = num_on_channel,
                                       count = &num_on_channel );
      if ( !( status & 1 ) )
      {
         return(FALSE);
      }

      if ( num_on_channel > 0 ){

	/*
	 * Correction to find window grids (supported by I/VDS).
         * modified on 4/26/94
	 */
	IGRint ii;
	GRclassid classid;

	for( ii = 0; ii < num_on_channel ; ii++ ){

	    status =
	    om$get_classid(	objid = linkage[ii].S_objid,
				osnum = linkage[ii].osnum,
				p_classid = &classid );

	   if( status && om$is_ancestry_valid(
				subclassid = classid,
				superclassid = OPP_VDgragadGrid_class_id ) ==
						OM_S_SUCCESS ){

		found = TRUE;
      		awin->win_no     = lwin; 
   		awin->grid.osnum = linkage[ii].osnum;
      		awin->grid.objid = linkage[ii].S_objid;

		break;
	   }
	}

        if ( ! found ) {
          awin->win_no     = lwin; 
          awin->grid.osnum = linkage[0].osnum;
          awin->grid.objid = linkage[0].S_objid;
        }
      }
   }
   
   return( TRUE );
} /* DPvd_get_active_window_id */

end implementation DPvd;

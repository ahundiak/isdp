/* $Id: VDgrsetNmId.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrsetNmId.I
 *
 * Description:
 *
 * Dependencies:
 *   This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * Revision History:
 *      $Log: VDgrsetNmId.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:50  cvs
 *      Initial import to CVS
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
# Revision 1.5  1996/02/05  05:33:18  pinnacle
# Replaced: vdgraphics/imp/VDgrsetNmId.I for:  by rgade for vds.240
#
# Revision 1.4  1994/12/12  19:18:12  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetNmId.I r#
#
# Revision 1.3  1994/12/01  22:48:28  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetNmId.I r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/10/94        Chaya V. Rao
 *
 * --------------------------------------------------------------------------*/

/*===========================================================================*/

class implementation VDgrset;

#include <stdio.h>

#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdrefmacros.h"

extern struct GRid	VDsetmgr_grid;
extern	long	VDStrip_filename_from_setname();

/*===========================================================================*/
/*  function VDsetname_to_grid -This function gets GRid of a set given the   */
/*                              set name                                     */
/*===========================================================================*/

int VDsetname_to_grid( set_name, set_grid )

char		*set_name;	/* i - name of set to be constructed */
struct GRid	*set_grid;	/* o - objid/osnum of created set */

{
long	              status, msg;
OM_S_CHANSELECT	      GRcmpowner_to_connector_CS;
int                   found = FALSE;
long                  retmsg,rc;
int                   nbos,
                      ii;
GRspacenum            *oslist = NULL;
struct GRmd_env       *modenvlist = NULL;
struct GRid           mgr_id;
OM_S_OBJID            super_id;
IGRint                size = sizeof( struct GRmd_env );
struct  GRmd_env      locEnv;
char		      set_text[50];

/*
 * get the grid if it wasn't passed in
 */
 
    status =
    gr$get_module_env(      msg     = & status,
                            sizbuf  = & size,
                            buffer  = & locEnv,
                            nret    = & size );       
    status =
    om$make_chanselect( channame      = "GRcmpowner.to_components",
                        p_chanselect  = &GRcmpowner_to_connector_CS
                      );
    as$status();

    status =
    om$send(msg = message VDgrset.VDName_to_id(	&msg,
        					set_name,
				                set_grid ),
        	senderid = VDsetmgr_grid.objid,
		targetos = VDsetmgr_grid.osnum,
		p_chanselect = &GRcmpowner_to_connector_CS );


              if(status != OM_I_STOP_SENDING){
                 found = FALSE;
              }

    if ( status != OM_I_STOP_SENDING ){
        retmsg =
                   vd$get_ref_os_list( msg           =  &rc,
                                       main_os       =  &locEnv.md_id.osnum,
                                       num_ref_os    =  &nbos,
                                       ref_os_list   =  &oslist,
                                       ref_env_list  =  &modenvlist );

       if( nbos  ==  0 ) {
              goto wrapup;
       }

       for( ii = 0; ii < nbos; ii++ ){

              status = ex$get_objid_from_NOD (
                                                NODname   = "IGENOD",
                                                objname   = "VDsuperset",
                                                pobjid    = &super_id,
                                                mod_osnum = oslist[ii]  );

              mgr_id.objid = super_id;
              mgr_id.osnum = oslist[ii];
              status = VDStrip_filename_from_setname ( set_name, set_text,
								mgr_id.osnum );
            
              status =
              om$send( msg = message VDgrset. VDName_to_id(
                                                         &retmsg,
                                                         set_text,
                                                         set_grid
                                                           ),
                       senderid = mgr_id.objid,
                       targetos = mgr_id.osnum,
                       p_chanselect = &GRcmpowner_to_connector_CS ); 
              if(status == OM_I_STOP_SENDING){
             /*    found = TRUE; */
                 break;
              }

          }/* for(ii =  */

        }
        else found = TRUE;
 
wrapup:
  if( oslist ) free( oslist );
  if( modenvlist ) free( modenvlist );
  return( found );
}

/*============================================================================*/

end implementation VDgrset;

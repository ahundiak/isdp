/* I/VDS
 *
 * File:         ~VDS/vdset/VDgrsetNmId.I
 *
 * Description:
 *      This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 */
/*===========================================================================*/

class implementation VDgrset;

#include <stdio.h>
 
#include "OMprimitives.h"
#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdrefmacros.h"

extern struct GRid	VDsetmgr_grid;
extern long		VDStrip_filename_from_setname();

/*===========================================================================*/
/*  function VDsetname_to_grid -This function gets GRid of a set given the   */
/*                              set name                                     */
/*===========================================================================*/

int VDsetname_to_gridenv( set_name, VDset_grid )

char	        	*set_name;	/* i - name of set to be constructed */
struct GRobj_env	*VDset_grid;	/* o - objid/osnum of created set */

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
struct GRobj_env      locVDset_grid[1] ;
struct GRobj_env      set_grid ;
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
                                                &locVDset_grid[0].obj_id ),
        	senderid = VDsetmgr_grid.objid,
		targetos = VDsetmgr_grid.osnum,
		p_chanselect = &GRcmpowner_to_connector_CS );
    if ( status == OM_I_STOP_SENDING ){
         found = TRUE;
         locVDset_grid[0].mod_env = locEnv; 

    }
    else{
              
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
              as$status();

              mgr_id.objid = super_id;
              mgr_id.osnum = oslist[ii];
              status = VDStrip_filename_from_setname( set_name, set_text,
								mgr_id.osnum );
            
              status =
              om$send( msg = message VDgrset. VDName_to_id(
                                                         &retmsg,
                                                         set_text,
                                                         &locVDset_grid[0].obj_id 
                                                           ),
                       senderid = mgr_id.objid,
                       targetos = mgr_id.osnum,
                       p_chanselect = &GRcmpowner_to_connector_CS ); 
              as$status();
              if(status == OM_I_STOP_SENDING){
                 found = TRUE;
                 locVDset_grid[0].mod_env = modenvlist[ii]; 
                 break;
              }

          }/* for(ii =  */

        } 
        if( found == TRUE ){
               set_grid.obj_id = locVDset_grid[0].obj_id;
               set_grid.mod_env = locVDset_grid[0].mod_env;
               *VDset_grid = set_grid;
               return ( OM_S_SUCCESS );
        }
        else return( FALSE );
wrapup:
  if( oslist ) free( oslist );
  if( modenvlist ) free( modenvlist );
  return( OM_S_SUCCESS );

}

/*============================================================================*/

end implementation VDgrset;

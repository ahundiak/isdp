/* $Id: VDgrsetIdNm.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrsetIdNm.I
 *
 * Description:
 *  implementation functions for VDgrset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrsetIdNm.I,v $
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
# Revision 1.4  1995/03/19  22:31:50  pinnacle
# Replaced: vdgraphics/imp/VDgrsetIdNm.I by azuurhou r#
#
# Revision 1.3  1994/12/01  22:51:00  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetIdNm.I r#
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
 *-----------------------------------------------------------------------*/

/*===========================================================================*/

class implementation VDgrset;

#include        <stdio.h>
#include        <string.h>

#include        "OMprimitives.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "grgs.h"
#include        "grgsmacros.h"
#include        "grdpbmacros.h"
#include        "dpmacros.h"
#include        "grmacros.h"
#include        "exmacros.h"
#include        "AS_status.h"
#include        "vdrefmacros.h"
#include	"v_dbgmacros.h"

/*===========================================================================*/
/*  function VDsetgrid_to_name -This function gets the name of a set.        */
/*===========================================================================*/

int VDsetgrid_to_name( set_grid, maxchar, set_name )

struct GRid	*set_grid;	/* i - objid/osnum of created set */
int		maxchar;	/* i - max length of set name */
char		*set_name;	/* o - name of set to be constructed */
{

long	              sts, msg, status;
long                  retmsg, rc;
int                   nbos,
                      index, ii;
OMuint                numref_set = 0;
GRspacenum            *oslist = NULL;
struct GRmd_env       *modenvlist = NULL;
OM_S_CHANSELECT       GRcmpowner_to_connector_CS;
OM_S_OBJID            super_id;
struct GRid           mgr_id;
OM_S_OBJECT_LINKAGE   *ref_sets = NULL;
IGRint                size = sizeof( struct GRmd_env );
struct  GRmd_env      locEnv;

	SetProc( VDsetgrid_to_name ); Begin

        set_name[0] = '\0';
        mgr_id.objid = NULL_OBJID;

        
        status =
        gr$get_module_env(     msg     = & status,
                              sizbuf  = & size,
                              buffer  = & locEnv,
                              nret    = & size );
	sts =
	om$send( msg = message VDgrset.VDGet_name( &msg, maxchar,
				                         set_name ),
			senderid = NULL_OBJID,
			targetid = set_grid->objid,
			targetos = set_grid->osnum );

        if( set_name[0] == '\0' ){

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

                status =
                om$make_chanselect( channame      = "GRcmpowner.to_components",
                                    p_chanselect  = &GRcmpowner_to_connector_CS
                                  );
                as$status();
            
                if( ref_sets ){
                   free( ref_sets );
                   ref_sets = NULL ;
                }
                numref_set = 0;

                status =
                om$get_channel_count(  objid = mgr_id.objid,
                                       osnum = mgr_id.osnum,
                                       p_chanselect = &GRcmpowner_to_connector_CS,
                                       count = &numref_set );

                if( numref_set == 0 ) continue;

                ref_sets = (OM_S_OBJECT_LINKAGE *) malloc
                                (numref_set * sizeof(OM_S_OBJECT_LINKAGE));
                if( ! ref_sets ) goto wrapup;

                status =
                om$get_channel_objects(objid = mgr_id.objid,
                                       osnum = mgr_id.osnum,
                                       p_chanselect = &GRcmpowner_to_connector_CS,
                                       list = ref_sets,
                                       size = numref_set,
                                       count = &numref_set );
                for( index = 0; index < numref_set; index++ ){

                      if(( ref_sets[index].S_objid == set_grid->objid )
                          && ( ref_sets[index].osnum == set_grid->osnum) ){

                           sts =
                           om$send( msg = message VDgrset.VDGet_name( 
                                                          &msg,
                                                          maxchar,
                                                          set_name ),
                                    senderid = NULL_OBJID,
                                    targetid = set_grid->objid,
                                    targetos = set_grid->osnum ); 

                           break;         
                      } 
                }
           }
        }

wrapup:
        if( oslist ) free( oslist );
        if( modenvlist ) free( modenvlist );

        if( ref_sets ){
            free( ref_sets );
        }

	End
	return( OM_S_SUCCESS );
}

/*============================================================================*/

end implementation VDgrset;

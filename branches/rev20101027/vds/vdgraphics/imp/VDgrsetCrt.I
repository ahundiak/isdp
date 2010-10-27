/* $Id: VDgrsetCrt.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrsetCrt.I
 *
 * Description:
 *      This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset. 
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrsetCrt.I,v $
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
# Revision 1.9  1995/03/19  22:31:22  pinnacle
# Replaced: vdgraphics/imp/VDgrsetCrt.I by azuurhou r#
#
# Revision 1.8  1995/01/18  17:20:54  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetCrt.I r#
#
# Revision 1.6  1994/12/30  19:39:24  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetCrt.I r#
#
# Revision 1.4  1994/12/22  20:58:00  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetCrt.I r#
#
# Revision 1.3  1994/12/22  19:54:20  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetCrt.I r#
#
# Revision 1.2  1994/11/30  21:19:30  pinnacle
# Replaced:  vdgraphics/imp r#
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

#include "OMprimitives.h"
#include "OMmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "asmacros.h"
#include "exmacros.h"
#include "v_dbgmacros.h"

extern struct GRid	VDsetmgr_grid;
extern GRclassid        OPP_VDpretendin_class_id;

from     NDnodein    import   NDconnect;
/*============================================================================*/
/*     function VDcreate_set -This function creates a set                     */
/*============================================================================*/

int VDcreate_set(	set_name,
			delete_existing,
			comps,
			numcomps,
			set_env,
			set_grid )

char		*set_name;	/* i - name of set to be constructed */
char		delete_existing;/* i - if TRUE, delete any existing set
					by the same name */
struct GRobj_env *comps;	/* i - list of objects to connect to the set */
int		numcomps;	/* i - number of objects to connect to the set*/
struct GRmd_env *set_env;	/* i - module environment.		*/
struct GRid	*set_grid;	/* o - objid/osnum of created set 	*/

{
long			status, msg;
long			flag;
long			index;
struct GRid		grid, 
                        null_grid, temp;
struct GRvg_construct	cnst_list;
OM_S_CHANSELECT	        GRcmpowner_to_connector_CS;
struct GRid             pretend, temp1;
struct GRid             cur_mod;
IGRint                  ii, val;
struct GRobj_env        *loc_comps = NULL;


/*
 * check if there is an existing set with the input name
 */
        status = 
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &GRcmpowner_to_connector_CS
                          );
        as$status();

        val = 0;
 
	status =
	om$send(msg 	 = message VDgrset.VDName_to_id(&msg,
							set_name, 
                                                        &grid ),
		senderid = VDsetmgr_grid.objid,
		targetos = VDsetmgr_grid.osnum,
		p_chanselect = &GRcmpowner_to_connector_CS );

	if ( status == OM_I_STOP_SENDING ) /* set exists */
	{
	    if ( delete_existing )
	    {
		/* delete set object */
		status = om$send( msg = message GRowner.GRdelete_owner(
							&msg, set_env ),
			senderid = NULL_OBJID,
			targetid = grid.objid,
			targetos = grid.osnum );
                as$status();
	    }
	    else{
                val = 2;
		return( val );
            }
	}

/*
 * Construct the VDgrset object
 */
        cnst_list.env_info = set_env;
        cnst_list.properties = GRIS_NEW ;
        cnst_list.msg = &msg;
        cnst_list.newflag = FALSE;
        cnst_list.name = NULL;
        cnst_list.geometry = NULL;
        cnst_list.display = NULL;
        cnst_list.class_attr = NULL;

	set_grid->osnum = VDsetmgr_grid.osnum;
	status =
	om$construct(
		classid = OPP_VDgrset_class_id,
		msg 	= message GRgraphics.GRconstruct( &cnst_list ),
		p_objid = &set_grid->objid,
		osnum	= set_grid->osnum );

	status =
	om$send(msg	 = message VDgrset.VDSet_name( &msg, set_name ),
		senderid = NULL_OBJID,
		targetid = set_grid->objid,
		targetos = set_grid->osnum );  
        as$status();
/*
 * Add the graphic objects to the VDgrset
 */
        ex$get_cur_mod(osnum = &cur_mod.osnum, id = &cur_mod.objid);

	if ( comps )
	{
                loc_comps = ( struct GRobj_env * ) malloc
                            ( numcomps * sizeof( struct GRobj_env ));
                if( !loc_comps ){
                   val = 0;
                   return( val );
                }
                for( ii=0; ii<numcomps; ii++ ){
                     loc_comps[ii] = comps[ii];
                }
		pretend.osnum = cur_mod.osnum ;

		for( ii=0; ii<numcomps; ii++ ){
                     
		      __DBGpr_obj(" OBJECT ", loc_comps[ii].obj_id );

                      temp = loc_comps[ii].obj_id;
                      null_grid.objid = NULL_OBJID;
                      status =
                      as$make_source(go_grid = temp,
                                     mod_env = &loc_comps[ii].mod_env,
                                     as_os   = pretend.osnum,
                                     as_grid = &temp1);
                      as$status();
                      if( !(status & 1) )
                          continue;
                      loc_comps[ii].obj_id   = temp1;
                      loc_comps[ii].mod_env = *set_env ;

                      /* construct a VDpretendin on it */
                      status = 
                      om$construct(classid = OPP_VDpretendin_class_id,
                                   osnum   = pretend.osnum,
                                   p_objid = &pretend.objid,
                                   msg = message NDnodein.NDconnect(
                                                             1,
                                                             &temp1,
                                                             null_grid,
                                                             ND_NEW)); 

                      loc_comps[ii].obj_id   = pretend;

                } 

		status =
		om$send(msg = message GRowner.GRadd_components(
							&msg,
							set_env,
							&numcomps,
							loc_comps,
							NULL,
							NULL ),
			senderid = NULL_OBJID,
			targetid = set_grid->objid,
			targetos = set_grid->osnum );
                if(loc_comps) free(loc_comps);
	}

/*
 * connect the VDgrset to the VDsetmgr
 */
	flag = 1;
	index = OM_K_MAXINT;
	status =
	om$send(msg = message GRconnector.GRflexconn(	&msg,
							&flag,
							&VDsetmgr_grid,
							&index,
							&index ),
		senderid = NULL_OBJID,
		targetid = set_grid->objid,
		targetos = set_grid->osnum );
        as$status();
      
        val = 1; 
 
	return( val );
}

/*============================================================================*/

end implementation VDgrset;

/* $Id: VDgrsetAdd.I,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdgraphics/imp / VDgrsetAdd.I
 *
 * Description:
 *      This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 * 
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgrsetAdd.I,v $
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
# Revision 1.10  1995/03/09  23:05:40  pinnacle
# Replaced: vdgraphics/imp/VDgrsetAdd.I by azuurhou r#
#
# Revision 1.7  1995/01/11  20:15:32  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetAdd.I r#
#
# Revision 1.3  1994/12/01  22:55:08  pinnacle
# Replaced:  vdgraphics/imp/VDgrsetAdd.I r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/10/94        Chaya V. Rao
 *
 * --------------------------------------------------------------------------*/

/*===========================================================================*/

class implementation VDgrset;

#include <stdio.h>
#include "nddef.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "AS_status.h"
#include "asmacros.h"
#include "vdrefmacros.h"
#include "vdsetmacros.h"

#include "vderrmacros.h"


extern struct GRid	VDsetmgr_grid;

extern GRclassid        OPP_VDpretendin_class_id;

from     NDnodein    import   NDconnect;

/** #define   DEBUG  1 **/

/*============================================================================*//*   function VDadd_to_set -This function adds objects to a set.              *//*============================================================================*/

int VDadd_to_set(
 struct GRid	*set_grid,	/* i - GRid of set */
 char		*set_name,	/* i - name of set */
 struct GRobj_env *comps,	/* i - list of objects to be added to the set */
 int		numcomps	/* i - number of objects to be added to set*/
)
{
long			status, msg;
struct GRid		grid;
OM_S_CHANSELECT	        to_comps;
int                     val, 
                        nbos, pp, pp1;
struct GRid             temp1;
IGRint                  size = sizeof( struct GRmd_env );
struct GRmd_env         locEnv;
struct GRid             null_grid,
			pretend, cur_mod, temp;
struct GRobj_env        *loc_comps = NULL;
int			nbCompsOld, nbObjAdd;
struct GRid		*buffer = NULL;
IGRboolean		found;


	val = 1;
	if ( !numcomps ) goto wrapup;

	if ( !set_grid && !set_name ){
                 val = 0;
                 goto wrapup;
        }
        nbos = 0;
        grid.objid = NULL_OBJID; 
     
        status =
        gr$get_module_env(      msg     = & status,
                                sizbuf  = & size,
                                buffer  = & locEnv,
                                nret    = & size );
        status =
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &to_comps
                          );
        as$status();
/*
 * get the grid if it wasn't passed in
 */
	if ( !set_grid )
	{
		status =
		om$send(msg = message VDgrset.VDName_to_id(
							&msg,
							set_name,
							&grid ),
			senderid = VDsetmgr_grid.objid,
			targetos = VDsetmgr_grid.osnum,
			p_chanselect = &to_comps );
                as$status();

        	if ( status != OM_I_STOP_SENDING ){
                 goto wrapup;
                }

        }
        else {
             grid.objid = set_grid->objid;
             grid.osnum = set_grid->osnum;
        }

	/*
	 * get existing objects in the set
	 */
	{
	    char  setname[81];

	    status = vd$setgrid_toname( set_grid = &grid,
					maxchar  = 80,
					set_name = setname );

	    status = vd$give_setobjs( set_grid = &grid,
				      set_name = setname,
				      numcomps = &nbCompsOld );

	    if ( nbCompsOld )
	    {
		buffer = (struct GRid *)
			    malloc(sizeof( struct GRid) * nbCompsOld );
		if ( !buffer )	{  val = 0;  goto wrapup; }

	        status = vd$give_setobjs( set_grid = &grid,
				          set_name = setname,
				          numcomps = &nbCompsOld,
					  set_objs = buffer );
	    }
	}

/*
 * Add the graphic objects (which are not in the set) to the VDgrset
 */
	ex$get_cur_mod(osnum = &cur_mod.osnum, id = &cur_mod.objid);

	loc_comps = ( struct GRobj_env * ) malloc
				( numcomps * sizeof( struct GRobj_env ));
	if( !loc_comps ){ val = 0; goto wrapup;	}

        pretend.osnum = cur_mod.osnum ;

	nbObjAdd = 0;
        for( pp=0; pp<numcomps; pp++ )
	{
		/*
		 * check if the object is already is set. If found, skip it.
		 */
		found = FALSE;
		for( pp1=0; pp1<nbCompsOld; pp1++ )
		    if ( buffer[pp1].objid == comps[pp].obj_id.objid &&
			 buffer[pp1].osnum == comps[pp].obj_id.osnum  )
		    {
		      found = TRUE;
		      break;
		    }
		if ( found ) continue;

		temp = comps[pp].obj_id;
		null_grid.objid = NULL_OBJID;
		as$make_source( go_grid = temp,
				mod_env = &comps[pp].mod_env, 
				as_os   = pretend.osnum,
				as_grid = &temp1);
		as$status();
		if( !(status & 1) )
		{
		    /*
		     * something wrong with as$make_source
		     * add the object anyway
		     */
		    loc_comps[nbObjAdd].obj_id = comps[pp].obj_id;
		    loc_comps[nbObjAdd].mod_env = comps[pp].mod_env;
		    nbObjAdd++;
		    continue;
		}

		loc_comps[nbObjAdd].obj_id   = temp1;
		loc_comps[nbObjAdd].mod_env  = locEnv;
		nbObjAdd++;

		/* construct a VDpretendin on it */
		status = 
		om$construct(	classid = OPP_VDpretendin_class_id,
				osnum   = pretend.osnum,
				p_objid = &pretend.objid,
				msg = message NDnodein.NDconnect(     
                                                             1,
                                                             &temp1,
                                                             null_grid,
                                                             ND_NEW));

                loc_comps[nbObjAdd-1].obj_id   = pretend;
	}

	if ( nbObjAdd )
	{
	  status =
	  om$send(msg = message GRowner.GRadd_components(
							&msg,
							&locEnv,
							&nbObjAdd,
							loc_comps,
							NULL,
							NULL ),
			senderid = NULL_OBJID,
			targetid = grid.objid,
			targetos = grid.osnum );
	  as$status();
	}

wrapup:
  if( loc_comps )free( loc_comps );
  if ( buffer ) free ( buffer );
  return( val );

}

/*============================================================================*/

end implementation VDgrset;

/* $Id: headcontco.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / headcontco.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: headcontco.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
	Fix set a bad State whe context is not a macro.
	2 june 93	RD & LLC
*/

class implementation ACheader;

#include "OMmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "exmacros.h"

#include "acrepdef.h"
#include "acrepmacros.h"

#include "grsymdef.h"

#define	gen_rg_collect		0x00010800	/* temp def */
#define	ACS_NO_VALID_PATH	'\007'

#define	AS_DEBUG

from	ACmacro_defn	import	ACgive_upscan;
from	ACcpx_defn	import	ACgive_temp_desc,ACgive_name;
from	ACmodel_mgr	import	ACreturn_model;
from 	ACmodel		import 	ACsame_temp_values,ACdisconnect_head;

extern	IGRboolean	ASbroadcast_in_progress;

/* ************* MSG ACcontext_compute () *****************************	*/

method ACcontext_compute ( IGRlong *rc; IGRint cn_type;
                        IGRint num_temp; struct GRid temp_list [];
                        struct GRid *context;
                        struct GRmd_env *md_env)
{
IGRlong			msg,sts;
struct	ret_struct	pardef;
IGRint			i;
struct	GRid		model;
struct	GRid		new_model;
struct	GRid		md_mgr;
IGRchar			*mac_name;
IGRboolean		ref_flag;
IGRlong			fd_msg;
struct	GRid		mac_def;
struct	GRid		my_grid;
IGRint			tmp_nb;
struct	stemp		*temp_desc;
IGRint			int_msg;
struct GRid *list;
int			rep;


	/*| initialization */
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;

	*rc 	 = ND_COMP_SUCC;
	ref_flag = FALSE;
        list = NULL;

	if( me->state & ND_DEGRADED ){

		as$status( sts = 0, string =("element %d not updated because degraded\n",my_id));
		return	OM_W_ABORT;
	}

/* Transfer context if any */

    if(    context->objid != NULL_OBJID
       &&( context->objid != my_id || context->osnum != OM_Gw_current_OS))
   {
	IGRint                  STATE;
	IGRshort                own_prop;
	struct  GRsymbology     symb;
	GRclassid               cid;

	if( ! ( me->STATE & ncpx_root )){

		sts = om$send(	msg	 =  message ACncpx.ACget_STATE
						( &STATE ),
				targetid = context->objid,
				targetos = context->osnum ); 
		if( sts & 1 ){

			STATE = ( ncpx_consumed | ncpx_missing ) & STATE;
			me->STATE = (~(ncpx_consumed|ncpx_missing)) &  me->STATE;
			me->STATE= STATE|me->STATE;
		}
	}
	
	/*| modify symbologie */
	sts = om$send(	msg	 = message GRvg.GRgetsymb
					( &msg, &symb ),
			targetid = context->objid,
			targetos = context->osnum ); 
	as$status( sts = sts );

	sts = om$send(	msg	 = message GRvg.GRputsymb
					( &msg, &symb ),
			targetid = my_id );
	as$status( sts = sts );

	/*| reset context owner properties */
	
	sts = om$get_classid(	objid	= context->objid,
				osnum	= context->osnum,
				p_classid = &cid );
	as$status( sts = sts );

	if( om$is_ancestry_valid(	subclassid	= cid,
					superclassid	= OPP_ACheader_class_id )
		== OM_S_SUCCESS ){

		sts = om$send(	msg	 = message GRowner.GRget_owner_properties
						( &msg, &own_prop ),
				targetid = context->objid,
				targetos = context->osnum ); 
		as$status( sts = sts );

		sts = om$send(	msg	 = message GRowner.GRchg_owner_properties
						( &msg, 1, &own_prop ),
				targetid = my_id );
		as$status( sts = sts );
	}
      }

 

	if( me->STATE & ncpx_root ){

		/*| object STATE is ncpx_root */
		return	OM_S_SUCCESS;
	}

    /* Do I need to generate an extra template for representation ? */

    sts = om$send(msg = message ACncpx.ACget_rep(&rep),
                     targetid = my_id);

    if((sts&1) && rep&(AC_FREE_REP|AC_DEP_REP))
      {
       sts = ac$compute_rep_value(initial_rep = rep,
                                     p_root = temp_list,
                                     nb_root = num_temp,
                                     resulting_rep = &rep);
       if(rep&AC_ERROR_REP)
        {
         char dummy_rep;
         struct GRsymbology symb;

         /*| Turn to error */
         ac$get_def_rep(prep = &dummy_rep,
                        esymb = &symb);
         sts = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
                       targetid = my_id);
         as$status(sts = sts);
         goto wrapup;
        }

       list =(struct GRid *)om$malloc(size = (num_temp+1)*sizeof(struct GRid));
       if(!list) goto wrapup;
       OM_BLOCK_MOVE(temp_list,list+1,num_temp*sizeof(struct GRid));
       temp_list = list;

       rep  = rep&AC_VDS_REP;
       /*" call generate_rep with value %x rep\n",rep */
       sts = ACgenerate_rep(rep,OM_Gw_current_OS,temp_list);
       num_temp += 1;
      }



	/*| find ref in template list */
	for( i=0; i<num_temp; i++ ){

		sts = om$send(	msg	 =  message NDnode.NDgive_structure( 
						&msg, 
						&pardef, 
						md_env ),
				targetid = temp_list[i].objid,
				targetos = temp_list[i].osnum );
	        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

		if( pardef.type & ref_generic ){

			ref_flag = TRUE;
			break;
		}
	}

	if( ref_flag != TRUE ){

		/*| try to find ref in edit template */

		sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
				targetid = my_id );
	        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

		sts = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc(
					&tmp_nb,
					&temp_desc ),
			targetid = mac_def.objid,
			targetos = mac_def.osnum );
		as$status( sts = sts );

		for( i=0; i<tmp_nb; i++ )
			if( temp_desc[i].type & ref_generic ) break;

		if( i<tmp_nb ){

			sts = om$send(	msg	 = message NDmacro.ACgive_structure(
							&int_msg,
							NULL,
							temp_desc[i].name,
							&pardef,
							md_env ),
				targetid = temp_list[temp_desc[i].back].objid,
				targetos = temp_list[temp_desc[i].back].osnum );
			as$status( sts = sts );
			if( ( int_msg&1 ) && (pardef.type & ref_generic )){

				/*| get the ref */
				ref_flag = TRUE;
			}
		}

	}/*end edit ref*/

	if( ref_flag != TRUE ){
		printf(" no referentiel in template \n");
		*rc	= ND_COMP_FAIL;
		return	OM_W_ABORT;
	}

	/*| set instance data */
	me->origin[0] = pardef.var.ref_st.t[3];
	me->origin[1] = pardef.var.ref_st.t[7];
	me->origin[2] = pardef.var.ref_st.t[11];

	for( i=0; i<3; i++ ){

		me->matrix[i]   = pardef.var.ref_st.t[i];
		me->matrix[i+3] = pardef.var.ref_st.t[i+4];
		me->matrix[i+6] = pardef.var.ref_st.t[i+8];
	}

	/*| get model model attach on chn cmp ind 0 */
	sts = om$send(	msg	 = message ACheader.ACfind_model
						( &fd_msg, &model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model" );
	/*" model : id/os = (%d/%d)\n", model.objid, model.osnum */

	if( fd_msg&1 ){	
		msg = TRUE;
		sts = om$send(	msg	 = message ACmodel.ACsame_temp_values( 
						&msg,
						num_temp, 
						temp_list,
						md_env ),
				targetid = model.objid,
				targetos = model.osnum );
	        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
	}

	if( (!(fd_msg&1)) || (!(msg&1)) ){

		/*| find a new model */
		sts = om$send(	msg	 = message ACheader.ACget_model_mgr
						( &msg, &md_mgr ),
				targetid = my_id );
		as$status( sts = sts, msg = "Error in msg ACget_model_mgr" );
		/*" md_mgr : id/os = (%d/%d)\n", md_mgr.objid, md_mgr.osnum */

		sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
				targetid = my_id );
	        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

		/*| get macro def name */
		sts = om$send(	msg	 = message ACcpx_defn.ACgive_name
						( &mac_name ),
				targetid = mac_def.objid, 
				targetos = mac_def.osnum );
		as$status( sts = sts, msg = "Error in msg ACgive_name" );

		new_model.objid = NULL_OBJID;
		sts = om$send(	msg	= message ACmodel_mgr.ACreturn_model(
						&msg,
						AChdr_norange | AChdr_nodisplay,
						0,
						mac_name,
						num_temp,
						temp_list,
						&model,
						md_env,
						&new_model ),
				targetid = md_mgr.objid,
				targetos = md_mgr.osnum );
		as$status( sts = sts, msg = "Error in msg ACreturn_model" );
		/*" new_model : id/os = (%d/%d)\n", new_model.objid, new_model.osnum */

		if( fd_msg & 1 ) {

			/*| disconnect old model and header */
			sts = om$send(	msg	 = message ACmodel.ACdisconnect_head(
							&msg,
							&my_grid,
							md_env ),
					targetid = model.objid,
					targetos = model.osnum );
			as$status( sts = sts, msg = "Error in msg ACdisconnect_head" );
		}

		/*| connect new model and header */
		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						0,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						OM_K_MAXINT ),
				targetid = new_model.objid,
				targetos = new_model.osnum );
		as$status( sts = sts, msg = "Error in msg connect" );

	}

wrapup :

if(list != NULL) om$dealloc(ptr = list);
return	sts;
}

end implementation ACheader;


/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: passdim.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:59  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:24:07  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/08/11  06:25:58  gvk
# COMMENT : Dimensions: Added a PPL tool for correcting corrupt coordinate dimensions
#
# Revision 320.0  1994/12/12  17:53:30  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/11/01  10:12:41  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.0  1992/12/06  23:49:27  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.1  1992/10/16  19:25:04  poo
# COMMENT : Checking in 2.1 Fixes to 2.2 RCS
#
Revision 201.18  1992/10/05  19:33:59  mrudula
COMMENT : Fix for save restore form on Sun.

Revision 201.17  1992/07/19  15:33:06  gvk
COMMENT : ANSI compilation and deleting obsolete functions.

Revision 201.13  1992/02/13  11:40:05  prasad
COMMENT : Fixed the parameter mismatch in MAmulmx

Revision 201.12  1992/02/12  07:18:59  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 12 Feb. 1992

Revision 201.10  1992/02/03  13:00:02  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

*/


class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimlinear.h"
#include "dimweld.h"
#include "dimgraph.h"
#include "griodef.h"
#include "griomacros.h"
#include "gotextdef.h"

from DMsuper import get_dim_param, set_dim_stan;
from DMsuper import update_dim_param, pass_message;
from DMplan_mgr import get_dim_plane;
from dim_param import give_internal;
from dim_plan import give_info, give_plane;
from Super_rfmgr import GRget_channel_count, GRget_channel_objects;
from GRreffile import GRgetenvironment;
from expression import NDgive_value, give_formula;
from dim_src import DMgive_structure;
from GRtext import GRgettxattr;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "maidmx.h"

extern GRclassid OPP_dim_plan_class_id;
extern GRclassid OPP_ASsource_class_id;

IGRint DMglupdate (target,
		   g_type,
		   g_mask,
		   d_type,
		   d_mask,
		   compute,
		   md_env)
		   /*(
	 IGRint  target,
	 IGRchar  g_type,
	 IGRchar  g_mask,
	 IGRchar  d_type,
	 IGRchar  d_mask,
	 IGRboolean  compute,
	 struct GRmd_env  *md_env
	)
	*/
IGRint  target;
IGRchar g_type;
IGRchar g_mask;
IGRchar d_type;
IGRchar d_mask;
IGRboolean compute;
struct GRmd_env *md_env;
/*.DMglupdate*/
{
	IGRint status;

	status =
	dm$pass_message(
		msg = message DMroot.GLupdate(
				g_type,
				g_mask,
				d_type,
				d_mask,
				compute,
				md_env),
		target = target,
		md_env = md_env,
		osnum  = md_env->md_id.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMpass_message (p_msg,
                       target,
		       osnum,
		       md_env,
		       all_contexts)
		       /*(
	 OM_p_MESSAGE  p_msg,
	 IGRint  target,
	 OMuword  osnum,
	 struct GRmd_env  *md_env,
	 IGRboolean  all_contexts
	)
	*/
OM_p_MESSAGE p_msg;
IGRint target;
OMuword osnum;
struct GRmd_env *md_env;
IGRboolean all_contexts;
/*.DMpass_message*/
{
	IGRint status, rc;
	IGRlong long_rc;
	struct GRmd_env new_env;
	struct GRid dim_super, ref_mgr;
	IGRlong    count, scount, i, j;
	IGRlong    ref_prop, size;
	struct GRid *supers, s_supers[20];
	OM_S_OBJID *objids, s_objids[20], md_id;
	OMuword    *osnums, s_osnums[20], md_os;
	IGRboolean duplicate;
	IGRshort   nested_attach, props;
	IGRint	   *sdim_count, s_sdim_count[20];
	IGRint	   *simp_count, s_simp_count[20];
	extern IGRint Dim_count, Imp_count;

	if ((target == PASS_BY_OSNUM) ||
	    (target == PASS_TO_CUROS) ||
	    (target == PASS_TO_ALLOS))
	{
		/*|- Pass to Cur OS */

		if (target == PASS_BY_OSNUM)
		{
			status =
			ex$get_modid(
				mod_osnum = (md_os = osnum),
				mod_id = &md_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			ex$get_cur_mod(
				id = &md_id,
				osnum = &md_os);
			dm$status(action = RET_STATUS);
		}

		status =
		dm$get_super(
			md_os = md_os,
			md_id = md_id,
			p_grid = &dim_super,
			create = FALSE);
		if (!(status & 1) || (dim_super.objid == NULL_OBJID))
			return(OM_S_SUCCESS);

		status =
		om$send(msg = message DMsuper.pass_message(p_msg),
			senderid = NULL_OBJID,
			targetid = dim_super.objid,
			targetos = dim_super.osnum);
		dm$status(action = RET_STATUS);
	}

	if ((target == PASS_TO_REFOS) || (target == PASS_TO_ALLOS))
	{
		/*|- Get Ref_Mgr ID -*/

		if (!md_env)
		{
			dbg$error(msg = "md_env is NULL");
			return(OM_E_ABORT);
		}

		status =
		ex$get_cur_mod(id = &md_id, osnum = &md_os);
		dm$status(action = RET_STATUS);

		status =
		ex$get_objid_from_NOD(
			NODname = "IGENOD",
			objname = "Ref Mgr",
			pobjid = &ref_mgr.objid,
			modid = md_id,
			mod_osnum = (ref_mgr.osnum = md_os));
		if (!(status & 1) || (ref_mgr.objid == NULL_OBJID))
			return(OM_S_SUCCESS);

		ref_prop = 0;
		size = 20;
		nested_attach = FALSE;

		status =
		om$send(msg = message Super_rfmgr.GRget_channel_count(
						&long_rc,
						(IGRulong *)&ref_prop,
						&nested_attach,
						&size),
			senderid = NULL_OBJID,
			targetid = ref_mgr.objid,
			targetos = ref_mgr.osnum);
		dm$status(action = RET_STATUS);

		if (!size)
		{
			/*|- No attachments -*/
			return(OM_S_SUCCESS);
		}

		if (size < 20)
		{
			objids = s_objids;
			osnums = s_osnums;
			supers = s_supers;
			sdim_count = s_sdim_count;
			simp_count = s_simp_count;
		}
		else
		{
			objids = (OM_S_OBJID *)om$malloc(size = sizeof(OM_S_OBJID) * size);
			osnums = (OMuword *)om$malloc(size = sizeof(OMuword) * size);
			supers = (struct GRid *)om$malloc(size = sizeof(struct GRid) * size);
			sdim_count = (IGRint *)om$malloc(size = sizeof(IGRint) * size);
			simp_count = (IGRint *)om$malloc(size = sizeof(IGRint) * size);
			if ((!objids) || (!osnums) || (!supers) || (!sdim_count) || (!simp_count))
			{
				dm$status(sts = OM_E_NODYNMEM,
					action = RET_STATUS);
			}
		}

		status =
		om$send(msg = message Super_rfmgr.GRget_channel_objects(
						&long_rc,
						(IGRulong *)&ref_prop,
						&nested_attach,
						&size,
						objids,
						osnums,
						&count),
			senderid = NULL_OBJID,
			targetid = ref_mgr.objid,
			targetos = ref_mgr.osnum);
		dm$status(action = GOTO_VALUE, value = wrap_up);

		for(i=scount=0; i<count; i++)
		{
			sdim_count[scount] = 0;
			simp_count[scount] = 0;

			status =
			om$send(msg = message GRgraphics.GRgetprops(
							&long_rc,
							&props),
				senderid = NULL_OBJID,
				targetid = objids[i],
				targetos = osnums[i]);
			dm$status(action = GOTO_VALUE, value = wrap_up);

			/* If the reffile attachement was not locatable
			   and displayable do not pass to that attachement*/

			if (!(props & GRIS_DISPLAYABLE) &&
			    !(props & GRIS_LOCATABLE))
			{
				/*|- Dummy attachement*/
				continue;
			}

			md_env->md_env.matrix_type = MAIDMX;
			MAidmx(&long_rc, md_env->md_env.matrix);

			status =
			om$send(msg = message GRreffile.GRgetenvironment(
							&long_rc,
							md_env,
							&new_env),
				senderid = NULL_OBJID,
				targetid = objids[i],
				targetos = osnums[i]);
			dm$status(action = GOTO_VALUE, value = wrap_up);

			/*"cur_module=%d,%d\n", md_env->md_id.objid, md_env->md_id.osnum*/
			/*"new_module=%d,%d\n", new_env.md_id.objid, new_env.md_id.osnum*/

			md_env->md_env = new_env.md_env;
			duplicate = FALSE;
			for(j=0; j<scount; j++)
			{
				if (supers[j].osnum == new_env.md_id.osnum)
				{
					duplicate = TRUE;
					break;
				}
			}

			if ((!duplicate) || (all_contexts))
			{
				Dim_count = 0;
				Imp_count = 0;

				status =
				dm$get_super(
					md_os = new_env.md_id.osnum,
					md_id = new_env.md_id.objid,
					create = FALSE,
					p_grid = &supers[scount]);
				if (!(status & 1) || (supers[scount].objid == NULL_OBJID))
					continue;

				status =
				om$send(msg = message DMsuper.pass_message(p_msg),
					senderid = NULL_OBJID,
					targetid = supers[scount].objid,
					targetos = supers[scount].osnum);
				dm$status(action = GOTO_VALUE, value = wrap_up);

				/*"Dim_count = %d, Imp_count = %d\n",
					Dim_count, Imp_count*/

				if (!duplicate)
				   sdim_count[scount] = Dim_count;
				simp_count[j] = Imp_count;
				scount++;
			}
		}

		Dim_count = Imp_count = 0;
		for (i=0; i<scount; i++)
		{
			Dim_count += sdim_count[i];
			Imp_count += simp_count[i];
		}

		/*"Dim_count = %d, Imp_count = %d\n", Dim_count, Imp_count*/

		wrap_up:

		if (objids != s_objids)
		{
			om$dealloc(ptr = objids);
			om$dealloc(ptr = osnums);
			om$dealloc(ptr = supers);
			om$dealloc(ptr = sdim_count);
			om$dealloc(ptr = simp_count);
		}

		md_env->md_env.matrix_type = MAIDMX;
		MAidmx(&long_rc, md_env->md_env.matrix);
	}
	return(OM_S_SUCCESS);
}

IGRint DMpass_to_feadim (fea,
			 p_msg)
			 /*(
	 struct GRid  fea,
	 OM_p_MESSAGE  p_msg
	)
	*/
struct GRid fea;
OM_p_MESSAGE p_msg;
/*.DMpass_to_feadim*/
{
	IGRint status, nb_root, size, nb_node;
	IGRint i, j, count;
	struct GRid *p_root, *p_list, comp;
	OM_S_OBJECT_LINKAGE notif[20];
	IGRboolean is_owner, is_node;
	extern GRclassid OPP_ASsource_class_id;

	nb_root = 0;
	size = 0;
	p_root = NULL;

	DMget_obj_type(fea, &is_owner, &is_node, TRUE);
	/*"is_owner=%d, is_node=%d\n", is_owner, is_node*/

	if (is_node || !is_owner)
	{
		p_root = (struct GRid *)om$malloc(size = sizeof(struct GRid) * 10);
		if (!p_root) return(OM_E_NODYNMEM);			

		p_root[0] = fea;
		nb_root = 1;
		size = 10;
	}

	if (is_owner);
	{
		status =
		DMget_components(
			fea,
			&size,
			&p_root,
			&nb_root);
		dm$status(action = RET_STATUS);
	}

	/*^
		printf("Roots:\n");
		for (i=0; i<nb_root; i++)
			printf("%d, %d\n",
				p_root[i].objid,
				p_root[i].osnum);
	*/

	for (i=0; i<nb_root; i++)
	{
		if (DMancestry_valid(p_root[i], OPP_NDnode_class_id))
			continue;

		status =
		om$get_channel_objects(
			objid = p_root[i].objid,
			osnum = p_root[i].osnum,
			p_chanselect = &AS_notification,
			list = notif,
			size = 20,
			count = (OMuint *) &count);
		dm$status(action = RET_STATUS);

		p_root[i].objid = NULL_OBJID;
		for (j=0; j<count; j++)
		{
			comp.objid = notif[j].S_objid;
			comp.osnum = notif[j].osnum;

			if (DMancestry_valid(comp, OPP_ASsource_class_id))
			{
				p_root[i] = comp;
				break;
			}
		}
	}

	/*^
		printf("Source Roots:\n");
		for (i=0; i<nb_root; i++)
			printf("%d, %d\n",
				p_root[i].objid,
				p_root[i].osnum);
	*/

	for (i=j=0; i<nb_root; i++)
	{
		if (p_root[i].objid == NULL_OBJID)
			continue;

		if (i != j) p_root[j] = p_root[i];
		j++;
	}

	nd$get_graph(p_root = p_root, nb_root = j);
	om$dealloc(ptr = p_root);
	nd$get_list_in_graph(p_count = &nb_node, buf_addr = &p_list);

	for (i=0; i<nb_node; i++)
	{
		if (DMancestry_valid(p_list[i], OPP_DMroot_class_id))
		{
			status =
			om$send(msg = p_msg,
				targetid = p_list[i].objid,
				targetos = p_list[i].osnum,
				senderid = NULL_OBJID);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

IGRint DMdisplay_invisible (type,
			    md_env)
			    /*(
	 IGRint  type,
	 struct GRmd_env  *md_env
	)
	*/
IGRint type;
struct GRmd_env *md_env;
{
	IGRint status, target;
	IGRchar display, d_mask;
	extern IGRboolean display_invisible_dims;
	extern IGRboolean display_reffile_dims;

	display = target = 0;

	/*"type = %d\n",type*/

	if (type == DIMS_IN_CUROS)
	{
		display_invisible_dims = TRUE;
		target = PASS_TO_CUROS;
		display = DIM_DISPLAY_OFF;
		d_mask = TRUE;
	}
	else if (type == DIMS_IN_REFOS)
	{
		display_reffile_dims = TRUE;
		target = PASS_TO_REFOS;
		display = (char)'\0';
		d_mask = (char)'\0';
	}

	status =
	DMglupdate(
		target,
		(char)'\0',
		(char)'\0',
		display,
		d_mask,
		FALSE,
		md_env);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMdisplay_update (g_type,
			 g_mask,
			 d_type,
			 d_mask,
			 erase,
			 display,
			 parallel_only,
			 mode,
			 vw_orientation,
			 target,
			 md_env)
			 /*(
	 IGRchar  g_type,
	 IGRchar  g_mask,
	 IGRchar  d_type,
	 IGRchar  d_mask,
	 IGRboolean  erase,
	 IGRboolean  display,
	 IGRboolean  parallel_only,
	 enum GRdpmode  mode,
	 IGRmatrix  vw_orientation,
	 IGRint  target,
	 struct GRmd_env  *md_env
	)
	*/
IGRchar g_type, g_mask;
IGRchar d_type, d_mask;
IGRboolean erase;
IGRboolean display;
IGRboolean parallel_only;
enum GRdpmode mode;
IGRmatrix vw_orientation;
IGRint target;
struct GRmd_env *md_env;
/*.DMpass_display*/
{
	IGRint status;
	OM_p_MESSAGE p_msg;

	p_msg = message DMroot.display_update(
				g_type,
				g_mask,
				d_type,
				d_mask,
				erase,
				display,
				parallel_only,
				mode,
				vw_orientation,
				md_env);

	status =
	dm$pass_message(
		msg = p_msg,
		target = target,
		md_env = md_env,
		osnum = md_env->md_id.osnum,
		all_contexts = TRUE);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMcompare_dim (set0_clear1,
                      md_env)
		      /*(
	 IGRint  set0_clear1,
	 struct GRmd_env  *md_env
	)
	*/
IGRint set0_clear1;
struct GRmd_env *md_env;
/*.DMcompare_dim*/
{
	IGRint status;
	extern IGRboolean display_different_dims;

	if (set0_clear1)
		display_different_dims = FALSE;
	else	display_different_dims = TRUE;

	status =
	dm$pass_message(
		msg = message DMroot.compare_dimension(set0_clear1, md_env),
		target = PASS_TO_CUROS,
		md_env = md_env,
		osnum = md_env->md_id.osnum,
		all_contexts = TRUE);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
		
IGRint DMpost_conversion (md_env)
/*(
	 struct GRmd_env  *md_env
	)
	*/
struct GRmd_env *md_env;
/*.DMpost_conversion*/
{
	IGRint status;
	IGRlong long_rc;
	IGRint DMadd_dim_to_rtree();

	status =
	dm$pass_message(
		msg = message GRgraphics.GRfunction(&long_rc, DMadd_dim_to_rtree, (IGRchar *)NULL),
		target = PASS_TO_CUROS,
		md_env = md_env,
		osnum = md_env->md_id.osnum,
		all_contexts = TRUE);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

#argsused
IGRint DMpass_function (function_name,
			md_env)
			/*(
	 IGRint  (*function_name)(),
	 struct GRmd_env  *md_env
	)
	*/
IGRint (*function_name)();
struct GRmd_env *md_env;
/*.DMpass_function*/
{
	IGRint status;
	IGRlong long_rc;

	status =
	dm$pass_message(
		msg = message GRgraphics.GRfunction(&long_rc, function_name, (IGRchar *)NULL),
		target = PASS_TO_CUROS,
		md_env = md_env,
		osnum = md_env->md_id.osnum,
		all_contexts = TRUE);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMset_SR_lockout ()
{
/* We need to call FI_set_SR_lockout for save restore form on Sun .
   --TR11922183 --Mrudula. */

#ifdef BIG_ENDIAN
                FI_set_SR_lockout();
#endif
   return (1);
}

DMfixup_invalid_dimensions(msg,dim_grid,info)
IGRlong *msg;
struct GRid *dim_grid;
char *info;
{
  IGRint status, ret, count, rc;
  IGRint cpx_type, rel_pos,mod_graph;
  IGRlong long_rc;
  IGRdouble dim_value;
  struct GRmd_env mod_env;
  struct GRid list[MAX_DIM_ROOTS], grid, owner, next[2];
  struct GRid dim_before, dim_after, first_dim;
  IGRboolean last_in_cpx;
  enum  GRdpmode mode;
  IGRshort props,action;

  *msg =MSSUCC;
  DMget_module_info( &mod_env);

  
  nd$mod_graph(request = ND_INQ, p_ret_mode = &mod_graph);
  mod_graph &=~ND_BROAD_DEL;
  mod_graph |=ND_NO_BROAD_DEL;
  nd$mod_graph(request = ND_SET, p_ret_mode = &mod_graph);

  status =
  om$send(msg = message DMroot.DMreturn_roots(&count, list),
	  senderid = NULL_OBJID,
	  targetid = dim_grid->objid,
	  targetos = dim_grid->osnum);
  dm$status(action = RET_STATUS);

  /* Check if the orig parent is bad */

  if (DMancestry_valid(list[DIM_CPX_ORIG], OPP_ASsource_class_id))
    {
/*
      status = om$send(msg = message DMdim.get_dim_value( &dim_value),
		       senderid = NULL_OBJID,
		       targetid = dim_grid->objid,
		       targetos = dim_grid->osnum);
      printf(" dimension value:%lf\n",dim_value);
      printf(" dimid :%d,%d\n",dim_grid->objid,dim_grid->osnum);
*/

      action = 1;
      props = GRIS_LOCATABLE|GRIS_DISPLAYABLE;
      status = om$send( msg = message GRgraphics.GRchgprops( &long_rc,
							    &action,
							    &props),

		       senderid = NULL_OBJID,
		       targetid = dim_grid->objid,
		       targetos = dim_grid->osnum);

      mode = GRhd;
      dp$erase_hilite( msg = &status);
      status =
      om$send(msg = message GRgraphics.GRdisplay(
						&long_rc,
						&mod_env.md_env.matrix_type,
						mod_env.md_env.matrix,
						&mode,
						&mod_env.md_id),
	      senderid = NULL_OBJID,
	      targetid = dim_grid->objid,
	      targetos = dim_grid->osnum);
      dm$status(action = RET_STATUS);

      first_dim .objid = NULL_OBJID;
      DMreturn_locate_dim_element(&rc, &first_dim);

      if( first_dim.objid == NULL_OBJID)
	return(OM_S_SUCCESS);

      status =
      om$send(msg = message DMroot.get_complex_type(&cpx_type),
		senderid = NULL_OBJID,
		targetid = first_dim.objid,
		targetos = first_dim.osnum);
      dm$status(action = RET_STATUS);

      dim_before.objid = NULL_OBJID;
      dim_after.objid = NULL_OBJID;

      status =
      om$send(msg = message DMroot.find_position_in_cpx(
						&rc,
						cpx_type,
						*dim_grid,
						list[DIM_CPX_MEAS],
						&mod_env,
						&rel_pos,
						&dim_before,
						&dim_after),
	      senderid = NULL_OBJID,
	      targetid = first_dim.objid,
	      targetos = first_dim.osnum);
      dm$status(action = RET_STATUS);

      if(dim_after.objid != NULL_OBJID)
	{
	  status =
	  om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					next),
		    senderid = NULL_OBJID,
		    targetid = dim_grid->objid,
		    targetos = dim_grid->osnum);
	  dm$status(action = RET_STATUS);

	  if(last_in_cpx)
	    {
	      /* Insert this dimension as it is */
	      
	      status =
	      om$send(msg = message DMroot.insert_into_cpx(
						&rc,
						NO_ACTION, 
						&mod_env,
						rel_pos,
						&dim_before,
						&dim_after),
		      senderid = NULL_OBJID,
		      targetid = dim_grid->objid,
		      targetos = dim_grid->osnum);
		dm$status(action = RET_STATUS);
	    }
	  else
	    {
	      last_in_cpx = FALSE;
	      next[0]= dim_after;
	      while( last_in_cpx != TRUE)
		{
		  /* Get the last dimension in stack */
		  dim_before = next[0];

		  status =
		  om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					next),
			    senderid = NULL_OBJID,
			    targetid = next[0].objid,
			    targetos = next[0].osnum);
		  dm$status(action = RET_STATUS);		
		}
	      dim_after.objid = NULL_OBJID;

	      status =
	      om$send(msg = message DMroot.insert_into_cpx(
						&rc,
						NO_ACTION,
						&mod_env,
						rel_pos,
						&dim_before,
						&dim_after),
		      senderid = NULL_OBJID,
		      targetid = dim_grid->objid,
		      targetos = dim_grid->osnum);
	      dm$status(action = RET_STATUS);	      
	    }
	}
      else
	{
	  status =
	  om$send(msg = message DMroot.insert_into_cpx(
						&rc,
						NO_ACTION,
						&mod_env,
						rel_pos,
						&dim_before,
						&dim_after),
		    senderid = NULL_OBJID,
		    targetid = dim_grid->objid,
		    targetos = dim_grid->osnum);
	  dm$status(action = RET_STATUS);
	}
    }

  return(OM_S_SUCCESS);
}

end implementation DMroot;


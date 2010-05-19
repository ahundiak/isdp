/* $Id: VDtxboxi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDtxboxi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDtxboxi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.6  1996/05/02  12:09:38  pinnacle
# Replaced: ./vdannot/imp/VDtxboxi.I for:  by azuurhou for vds.240
#
# Revision 1.5  1996/03/18  11:01:42  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.4  1996/02/16  23:54:42  pinnacle
# Replaced: ./vdannot/imp/VDtxboxi.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/11/20  15:13:54  pinnacle
# Replaced: vdannot/imp/VDtxboxi.I for:  by tlbriggs for vds.240
#
# Revision 1.2  1995/07/25  22:47:14  pinnacle
# Replaced: vdannot/imp/* for:  by jwfrosch for vds.240
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
 *	11/17/95	tlb		Remove overriden method get_dim_params
 *	02/16/96	adz		Control error-messages.
 *
 * -------------------------------------------------------------------*/

class implementation VDtxbox;

#include <stdio.h>
#include <string.h>

#include "AS_debug.h"
#include "AS_status.h"
#include "dimdef.h"
#include "dimmod.h"
#include "dpdef.h"
#include "bsvalues.h"
#include "bspt_on_lne.h"
#include "bsdistptpts.h"

#include "VDSannot.h"
#include "VDSglobals.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

#define		AS_DEBUG 1
#define		AN_ROOT_EXPN	3

extern double fabs();
extern double sqrt();

from	dim_param	import give_internal, edit;
from	DMsrc		import DMgive_tangent, DMgive_src_info;
from 	DMsrc		import DMgive_structure;
from	GRtext		import GRgettxattr,GRfield_inquire; 
from 	GRtext		import GRreplace_text;
from 	DMplan		import give_info;
from	ACcpx		import ACfind_exp_temp_obj, find_macro;
from    ACcpx_defn      import ACgive_name;
from    expression      import NDgive_value,NDset_value, modify;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method GRgetobjinfo						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method GRgetobjinfo(
	IGRlong		  *msg;
	struct GRobj_info *info)
{
     *msg = MSSUCC;
     strcpy(info->type,"Text Expression with Leader");
     return(OM_S_SUCCESS);
}
 
/************************************************************************/
/* METHOD  GRxform                                                      */
/* moves annotation                                                     */
/************************************************************************/

method GRxform
(
  IGRlong		*msg; 
  struct GRmd_env	*md_env;
  IGRshort		*matrix_type;
  IGRmatrix		 matrix;
  GRobjid		*newobjid
)
{
  IGRint		 status = OM_S_SUCCESS ;
  struct GRid		 myObj, temp, macro;
  IGRint		 nb_temp, s_count, i, j,
			 s_count1, k, ii,
			 ind, s_count2;
  IGRshort		 rc;
  struct GRid		 roots[10];
  struct GRid		 parId;
  IGRchar		*c, c_name[80];
  OM_S_OBJECT_LINKAGE	 slist1[10],
			 slist [10],
			 slist2[10];
  IGRdouble		 new_val[3];

  __enterMethod ( name = "GRxform" );

  myObj.objid	= my_id;
  myObj.osnum	= OM_Gw_current_OS;
  macro.objid	= NULL_OBJID;
  
  for( ind=0; ind<3; ind++ )
  {
    new_val[ind] = 0.0 ;
  }

  /* 
   * get the roots of VDtxbox( located object )
   */
  status =
  om$send (	msg	 = message DMroot.DMreturn_roots( &nb_temp, roots ),
		targetid = myObj.objid,
		targetos = myObj.osnum );
  if( !(status&1)) goto wrapup ;

  /* for all roots of the located object check if DMsrc is a root.
   * if it is a root then get the ACpretend on its father channel.
   */
  parId.objid = NULL_OBJID;

  for ( i=0; i < nb_temp; i++ )
  {
    status =
    om$get_classname(	objid = roots[i].objid,
			osnum = roots[i].osnum,
			classname = c_name );
    as$status();

    if( om$is_ancestry_valid (	subclassname   = c_name,
				superclassname = "DMsrc" ) == OM_S_SUCCESS )
    {
      parId.objid = roots[i].objid ;
      parId.osnum = roots[i].osnum ;
      break;
    }
  }

  if( parId.objid == NULL_OBJID ) goto wrapup;

  /* 
   * get ACpretend
   */
  status =
  om$get_channel_count (	osnum   = parId.osnum,
				objid   = parId.objid,
				p_chanselect = &ND_father,
				count   = (OMuint *)&s_count );
  if ( s_count > 10 )
  {
    goto wrapup;
  }

  status =
  om$get_channel_objects (	osnum   = parId.osnum,
  				objid   = parId.objid,
  				p_chanselect = &ND_father,
  				size    = 10,
  				list    = slist,
				count   = (OMuint *) &s_count );
  /*
  * Get the nci_macro "src_obj"
  */ 
  for (j=0; j < s_count; j++ )
  {
    om$get_channel_count (	osnum   = slist[j].osnum,
				objid   = slist[j].S_objid,
				p_chanselect = &ND_father,
				count   = (OMuint *)&s_count1 );
    status =
    om$get_channel_objects (	osnum   = slist[j].osnum,
				objid   = slist[j].S_objid,
				p_chanselect = &ND_father,
				size    = 10,
				list    = slist1,
				count   = (OMuint *) &s_count1 );

    /*
     * test on objects for macro src_obj.
     */
	       
    om$send (	msg	 = message ACcpx.find_macro(&macro),
		targetid = slist1[j].S_objid,
		targetos = slist1[j].osnum);

    if( macro.objid == NULL_OBJID ) continue;

    status =
    om$send (	msg	 = message ACcpx_defn.ACgive_name( &c ),
		targetid = macro.objid,
		targetos = macro.osnum);
    as$status();

    if( strcmp( c, "src_obj" ) == 0 )
    {
      parId.objid = slist1[j].S_objid,
      parId.osnum = slist1[j].osnum ;

      break;
    }
  }
	
  if( macro.objid == NULL_OBJID )
  {
    __exitMethod ( name = "GRxform" );
    return OM_S_SUCCESS;
  }

  /*
   * get the parents of nci_macro "src_obj"
   */
  for (k=0; k < s_count1; k++ )
  {
    om$get_channel_count(   osnum   = slist1[k].osnum,
			    objid   = slist1[k].S_objid,
			    p_chanselect = &ND_father,
			    count   = (OMuint *)&s_count2 );
    status =
    om$get_channel_objects( osnum   = slist1[k].osnum,
			    objid   = slist1[k].S_objid,
			    p_chanselect = &ND_father,
			    size    = 10,
			    list    = slist2,
			    count   = (OMuint *) &s_count2 );
  }

  for( ii = 1; ii<2; ii++ )
  {
    int			pos;
    struct ret_struct	expr;

    temp.objid  =  slist2[ii].S_objid;
    temp.osnum  =  slist2[ii].osnum;

    __printf ( "temp = [%d,%d]", `temp.osnum, temp.objid` );

    status =
    om$send (	msg	 = message expression.NDgive_structure( msg, &expr, md_env ),
		targetid = temp.objid,
		targetos = temp.osnum  );
    CheckRC( status, *msg );

    __printf ( "<<< expr.var.text_st.text_string = <%s>", expr.var.text_st.text_string );;

    sscanf ( expr.var.text_st.text_string, "%d %lf %lf %lf", &pos, &new_val[0], &new_val[1], &new_val[2] );

    new_val[0] += matrix[ 3];
    new_val[1] += matrix[ 7];
    new_val[2] += matrix[11];

    sprintf ( expr.var.text_st.text_string, "%d %lf %lf %lf", pos, new_val[0], new_val[1], new_val[2] );

    __printf ( ">>> expr.var.text_st.text_string = <%s>", expr.var.text_st.text_string );;

    status =
    om$send (	msg	 = message expression.modify( "",
						  expr.var.text_st.text_string,
						  &rc ),
		targetid = temp.objid,
		targetos = temp.osnum  );
    as$status();
  }

  {
    int	cn_type = ND_COMP, wait_batch ;

    nd$wait_batch (	type       = GR_GEOM_POSTED,
			l_object   = &temp,
			l_obj_info = &cn_type,
			nb_obj     = 1);

    nd$mod_batch(	request    = ND_INQ,
			p_ret_mode = &wait_batch);

    nd$exec_batch(	mode = ND_IMMEDIATE );
  }

  __exitMethod ( name = "GRxform" );

  return status;

wrapup:

  status =
  om$send (	msg	 = message DMroot.GRxform( msg, md_env, matrix_type,
							matrix, newobjid ),
		mode	 = OM_e_wrt_message,
		targetid = my_id );

  __exit_error_Method ( name = "GRxform" );

  return status ;

}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* method DMcompute_node						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method DMcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	int count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	int status = OM_S_SUCCESS;
	IGRint			i, display, rc;	
	struct	ret_struct	ret_str ;
	struct	DMplan_info	plan_info ;
	struct	DMsenv_param	par_senv ;
	struct	GRid		text_grid ;

	/*
	 * delete the graphical component/owner object of the box.
	 */
	for(i=DIM_LINE1;i<=DIM_LINE4;i++){
	    status =
	    om$send(msg = message DMroot.delete_dim_go( &rc, i, md_env),
		    targetid = my_id);
	    as$status(action = RET_STATUS);
	}

	/*
	 * get the text expression
	 */  
	status =
	om$send(msg = message NDnode.NDgive_structure(msg, &ret_str, md_env),
		senderid = my_id,
		p_chanselect = &ND_father,
		from = AN_ROOT_EXPN, to = AN_ROOT_EXPN);
	as$status(action = RET_STATUS);
	as$status( sts = *msg, action = RET_STATUS );

	/*
	 * replace the text string.
	 */
	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_TEXT,
				&text_grid,
				md_env,
				strlen( ret_str.var.text_st.text_string ),
			        (IGRuchar *) ret_str.var.text_st.text_string ),
		targetid = my_id);
	as$status(action = RET_STATUS);
	as$status( sts = rc, action = RET_STATUS );

	/*
	 * recompute the object.
	 */
	status = om$send(msg = message DMtxldr.DMcompute_node(msg, cn_type,
						count, list, md_env),
			 targetid = my_id,
			 mode = OM_e_wrt_message);
        as$status(action = RET_STATUS);
	as$status( sts = *msg, action = RET_STATUS );

	/*
	 * delete the graphical component/owner ULINE of box.
	 */
	status =
	om$send(msg = message VDtxbox.disp_box_type(msg, &display ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	if( display ) {
	    status =
	    om$send(msg = message DMroot.delete_dim_go( &rc, DIM_ULINE, md_env),
		    targetid = my_id);
	    as$status(action = RET_STATUS);
	}

/*
	status =
	om$send(msg = message DMroot.debug(),
		targetid = my_id );
	as$status(action=RET_STATUS);
 */

	return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method gather_data						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRpoint start_pt;
	IGRpoint end_pt;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env)
{
	IGRint status, rc, index;
	struct dim_ret_struct dim_str;

	/*
	 * Get environment parameters
	 */
	status =
	om$send(msg = message DMannot.get_active_senv(par_senv),
			targetid = my_id);
	as$status(action = RET_STATUS);

	/*
	 * Get the dimension plane
	 */
	status =
	om$send(msg = message DMplan.give_info(&rc, plan_info, md_env),
		targetid = list[DIM_ROOT_PLAN].objid,
		targetos = list[DIM_ROOT_PLAN].osnum);
	as$status(action = RET_STATUS);

	/*
	 * find the start point of annotation leader line.
	 */
	status =
	om$send(msg = message DMsrc.DMgive_structure(	&rc,
							ORIG_INFO,
							FALSE,
							&dim_str,
							md_env ),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	as$status(action = RET_STATUS);

	math_v_equal(start_pt, dim_str.var.dm_ptdist.point);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
	}

	return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method txdynamics						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method txdynamics(IGRlong *msg;
	IGRint control;
	IGRint info_flag;
	IGRint *level;
	IGRchar *info;
	struct EX_button *cursor;
	unsigned char *character;
	IGRint numbytes;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env)
{
        /* - local variables */

        IGRint status, rc, last_vtx, i;
        IGRlong long_rc;
        IGRshort txt_just;
	struct GRid my_grid;
        struct DMdyn_annot *place_attr; /* buffer for annot structure */
        struct DMplan_info *plan_info;
        struct DPele_header *loc_ele_header;
        struct IGRlbsys *lbs_geom;

        IGRuchar *loc_text_string;
        IGRint dir_flag, hilite, num_poles;
        IGRdouble curr_dir[3],target_pt[3], text_pt[3];
        IGRvector perp_vec, refer_dir;
        IGRdouble *prev_point, y_offset,*proj_pt;
        IGRdouble active_angle = 0.0;
        extern IGRboolean dynamics_in_progress;

        /*
	 * initailizing pointers
	 */
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;
	prev_point      = NULL;

        place_attr	= (struct DMdyn_annot *)info;
        plan_info	= &place_attr->plan_info;
        loc_ele_header	= &place_attr->ele_header;

        loc_text_string = (loc_ele_header->ele_spec_att.text) ?
                          (unsigned char *)
                          loc_ele_header->ele_spec_att.text->text_string : NULL;

        proj_pt		= (IGRdouble *)cursor;

        if (( control & FILL_INFO ) || ( me->dim_state & DIM_NEEDS_UPDATE )) {

		/*
		 * Fill the Default Info
		 */
                status=
                om$send(msg = message DMannot.fill_info(&rc,
                                                control,
                                                0,
                                                info,
                                                md_env),
                        targetid =my_id );
                as$status(action = RET_STATUS);
        }

        num_poles	= om$dimension_of(varray =  me->break_pt)/3;
        last_vtx	= 3*(num_poles -1);

        /*"num poles:%d\n",num_poles*/
	/*
	 * delete the graphical component/owner object of the box.
	 */
	for(i=DIM_LINE1;i<=DIM_LINE4;i++){
	    status =
	    om$send(msg = message DMroot.delete_dim_go( &rc, i, md_env),
		    targetid = my_id);
	    as$status(action = RET_STATUS);
	}


        if ( me->leader && num_poles > 1 ) {

                prev_point = &me->break_pt[ last_vtx - 3];
                if( num_poles > 2)
                {
                        BSmkvec(&rc,refer_dir,prev_point,&me->break_pt[last_vtx - 6]);
                        BSnorvec(&rc,refer_dir);
                }
                else
                {
                        vec_equal(place_attr->src_dir,refer_dir);
                }

                DMinquire_hilite(
                        proj_pt,
                        prev_point,
                        target_pt,
                        NULL,
                        refer_dir,
                        NULL,
                        plan_info,
                        &place_attr->win_grid,
                        &hilite);

                vec_sub(target_pt,prev_point,curr_dir);
                memcpy(&me->break_pt[last_vtx],target_pt, 3*sizeof(IGRdouble));
        }
        else
        {
                for(i = 0; i < 3; i++)
                {
                        curr_dir[i] = place_attr->src_dir[i];
                        target_pt[i] = proj_pt[i];
                }
                hilite = FALSE;
        }

        if (dynamics_in_progress)
        {
                BSnorvec(&rc, curr_dir);

                DMget_annot_txt_info(plan_info,
                                &place_attr->par_senv,
                                place_attr->txt_orie,
                                &plan_info->win_plan.matrix[8],
                                &txt_just,
                                curr_dir);
                if (num_poles > 1)
                {
                        DMget_direction(prev_point,
                                        &me->break_pt[last_vtx],
                                        plan_info->win_plan.matrix,
                                        &dir_flag);

                        if( dir_flag == AN_BEFORE)
                        {
                                if (txt_just == LEFT_CENTER)
                                        txt_just = RIGHT_CENTER;
                                else if (txt_just == LEFT_CAP)
                                        txt_just = RIGHT_CAP;
                                else if (txt_just == LEFT_BASE)
                                        txt_just = RIGHT_BASE;
                        }
                        place_attr->txt_just = txt_just;
                }
                else    place_attr->txt_just = LEFT_CENTER;

                BScrossp(&rc,
                         &plan_info->win_plan.matrix[8],
                         place_attr->txt_orie,
                         perp_vec);

                y_offset =  0.5 * place_attr->par_senv.txt_heig;

                if (place_attr->par_senv.an_posn == ANNOT_JUST_BOTTOM)
                        y_offset = -y_offset;

                if ((place_attr->par_senv.an_posn == ANNOT_JUST_ABOVE)
                ||  (place_attr->par_senv.an_posn == ANNOT_JUST_BOTTOM)
                ||  (place_attr->par_senv.an_posn == ANNOT_JUST_UNDER))
                {
                        for(i=0; i<3; i++)
                           text_pt[i] = target_pt[i] + y_offset * perp_vec[i];
                }
                else
                {
                        vec_equal(target_pt,text_pt);
                }

                /*^  print_point("text_pt",text_pt); */
        }
        else
        {
                /*| Dynamics off, Replace text */
                status=
                om$send( msg = message DMroot.replace_text(
                                        &rc,
                                        DIM_NO_INDEX,
                                        &place_attr->go_grid[AN_ANNOT_TEXT],
                                        md_env,
                                        place_attr->text_length,
                                        place_attr->text_string),
                        targetid = my_id);
                as$status(action = RET_STATUS);

                status =
                om$send(msg = message DMannot.make_an_text(
                                        &rc,
                                        plan_info,
                                        &place_attr->par_senv,
                                        place_attr->go_grid[AN_ANNOT_TEXT],
                                        md_env),
                        targetid = my_id);
                as$status(action = RET_STATUS);
        }

	/*
	 * check if user likes to add text.
	 */
	if( info_flag & TEXT_ENTERED)
	{
		UI_status ( "Warning: No entered text allowed" );
	}

        place_attr->text_st.active_symb.Active_just = place_attr->txt_just;
        status=
        GRjust_string(&long_rc,
                      &place_attr->text_string,
                      &place_attr->text_length,
                      &place_attr->text_buff_size,
                      &place_attr->text_st.font_info,
                      &place_attr->text_st.active_display,
                      &place_attr->text_st.active_symb,
                      0,
                      NULL,
                      &place_attr->text_st.text_extents);
        as$status(action=RET_STATUS);
        place_attr->text_st.estx.text_length = place_attr->text_length;

        status=
        GRcreate_lbs(&long_rc,
                     &active_angle,
                     md_env->md_env.matrix,
                     text_pt,
                     &place_attr->text_st.text_extents,
                     loc_ele_header->geometry.lbsys);
        as$status(action=RET_STATUS);

        if( dynamics_in_progress)
        {
                lbs_geom = &place_attr->lbsys_geom;
                for( i = 0; i<3; i++)
                {
                   lbs_geom->matrix[3+4*i] = text_pt[i];
                   lbs_geom->matrix[i*4] = place_attr->txt_orie[i];
                   lbs_geom->matrix[i*4 +1] = perp_vec[i];
                   lbs_geom->matrix[i*4 +2] = plan_info->win_plan.matrix[8 +i];
                }

                status =
                om$send(msg = message DMannot.update_leader(
                                          &rc,
                                          &num_poles,
                                          (IGRdouble *)&place_attr->lbsys_geom,
                                          &place_attr->par_senv,
                                          plan_info,
                                          md_env),
                        targetid = my_id);
                as$status(action = RET_STATUS);

		status =
		om$send( msg = message VDtxbox.update_text_box(
                                                &long_rc,
                                                place_attr->text_string,
                                                &place_attr->text_st.estx,
                                                lbs_geom,
                                                md_env),
			targetid = my_id);
		as$status(action = RET_STATUS);

                status =
                om$send(msg = message DMannot.make_an_term(
                                                &rc,
                                                plan_info,
                                                &place_attr->par_senv,
                                                place_attr->go_grid[AN_TER_TEXT],
                                                md_env),
                        targetid = my_id);
                as$status(action = RET_STATUS);
        }

        if ( me->leader ){

                status=
                om$send(msg = message DMroot.position_line_string(
                                             &rc,
                                             DIM_NO_INDEX,
                                             &place_attr->go_grid[AN_POLY_LINE],
                                             md_env,
                                             num_poles,
                                             me->break_pt),
                        targetid = my_id);
                as$status(action = RET_STATUS);
        }

        if ( dynamics_in_progress ){

                place_attr->par_senv.dim_weig = (hilite) ? 2 : 0 ;

                status =
                om$send(msg = message DMannot.chg_an_dp( &rc,
                                                         &place_attr->par_senv),
                        targetid = my_id);
                as$status(action = RET_STATUS);
        }

        if ( ! dynamics_in_progress ){

                /*
		 * clear the break pts
		 */
                status =
                om$vla_set_dimension(varray = me->break_pt, size = 0);
                as$status(action = RET_STATUS);
        }

        return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* method get_disp_list							    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method get_disp_list(
        IGRint *msg;
        IGRint *count;
        struct GRid *list;
        struct GRmd_env *md_env)
{
        IGRint status,rc,index;
        IGRint go_index[10],go_type[10];
        IGRint num_obj;

	status =
	om$send(msg = message DMtxldr.get_disp_list( msg, count, list, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	as$status(action = RET_STATUS);

	index = 0;

	go_index[index++] = DIM_LINE1;
	go_index[index++] = DIM_LINE2;
	go_index[index++] = DIM_LINE3;
	go_index[index++] = DIM_LINE4;

	if( me->leader ) {

                go_index[index++] = DIM_LEADER;
                go_index[index++] = DIM_ORI_TERM;
	}
	num_obj = index;

        go_type[0] = DM_LINE;
        go_type[1] = DM_LINE;
        go_type[2] = DM_LINE;
        go_type[3] = DM_LINE;
        go_type[4] = ( me->leader ) ? DM_LINE_STR : DM_LINE ;
        go_type[5] = ( me->leader ) ? DM_TEXT     : DM_LINE ;

        *count = 0;
        for( index = 0 ; index<num_obj ; index++ ){

                status =
                om$send(msg = message DMroot.return_dim_go(
                                                &rc,
                                                go_index[index],
                                                FALSE,
                                                go_type[index],
                                                md_env,
                                                &list[*count]),
                        targetid = my_id);
                dm$status(action = RET_STATUS);

        	if(list[*count].objid != NULL_OBJID)
                        (*count)++;
        }

	/*^
	    for( index=0; index<*count; index++)
		printf("list[%d]:%d,%d\n",index,list[index].objid,
						list[index].osnum );
	 */

	return OM_S_SUCCESS ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method make_an_text						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method make_an_text(
        IGRint *msg;
        struct DMplan_info *plan_info;
        struct DMsenv_param *par_senv;
        struct GRid text_grid;
        struct GRmd_env *md_env)
{
        IGRint status;
        IGRlong long_rc;
        struct IGRestx attr;
        IGRuchar *text_string;
        struct IGRlbsys *lbs_geom;
	extern	IGRboolean	GRabsg_del_all();

	SetProc( VDtxbox_make_an_text_MTD ); Begin

	*msg = MSSUCC ;
	text_string = NULL ;

	/*
	 * First, calculate the TEXT_WITH_LEADER object
	 */
	status =
	om$send(msg = message DMtxldr.make_an_text(
				msg, plan_info, par_senv, text_grid, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	__CheckRC( status, 1, "DMtxldr.make_an_text", wrapup );

        /*
         * update the text_box values
         */
	GRabsg_del_all();
        status =
        om$send(msg = message GRvg.GRgenabsg(
                                &long_rc,
                                &md_env->md_env.matrix_type,
                                md_env->md_env.matrix,
                                (char **)&lbs_geom),
                targetid = text_grid.objid,
                targetos = text_grid.osnum);
	__CheckRC( status, long_rc, "GRvg.GRgenabsg", wrapup );

        status =
        om$send(msg = message GRtext.GRgettxattr(
                                        &long_rc,
                                        &attr,
                                        NULL,
                                        &text_string),
                targetid = text_grid.objid,
                targetos = text_grid.osnum);
	__CheckRC( status, long_rc, "GRtext.GRgettxattr", wrapup );

	__DBGpr_int(" textLength ", attr.text_length );

	status =
	om$send(msg = message VDtxbox.update_text_box(
       	                                &long_rc,
               	                        text_string,
                       	                &attr,
                               	        lbs_geom,
                                       	md_env),
                targetid = my_id);
	__CheckRC( status, long_rc, "VDtxbox.update_text_box", wrapup );

wrapup:
	_FREE( text_string );

	return( OM_S_SUCCESS );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method update_text_box						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method update_text_box(
	IGRlong *msg;
	IGRuchar *text_string;
	struct IGRestx *estx;
	struct IGRlbsys *lbs_geom;
	struct GRmd_env *md_env)
{
	IGRint			status, rc, i, index;
	IGRlong			long_rc;
	IGRdouble		box[4][3];
	IGRint			go_type[4];
	double			descent_r,box_orie[3];
	IGRdouble		*disp_line[4];
	IGRdouble		dim_line1[6], dim_line2[6],
				dim_line3[6],dim_line4[6];
	IGRdouble		dist1,dist2;
	IGRuchar		*contents, field_num;
	IGRint			display_box, num_disp_line;
	struct vfont_entry	font_info;
	struct DMsenv_param	par_senv;
	struct IGRdisplay	display;
	struct just_pts		just_pts;

	SetProc( VDtxbox_update_text_box_MTD ); Begin

	*msg = MSSUCC ;

	if( text_string ){
		__DBGpr_str(" text_string ", text_string );
	}

	/*
	 * see if we have to do with an box.
	 */	
	status =
	_VD_SEND_MY( VDtxbox.disp_box_type( &long_rc, &display_box ));
	__CheckRC( status, long_rc, "VDtxbox.disp_box_type", wrapup );

	if( ! display_box ) return OM_S_SUCCESS;

	/*
	 * get the four linestrings of the box.
	 */

	go_type[0] = DIM_LINE1;
	go_type[1] = DIM_LINE2;
	go_type[2] = DIM_LINE3;
	go_type[3] = DIM_LINE4;
	
	status =
	dm$get_dim_param(
		type = DM_SENV_PARAM,
		dim_objid = my_id,
		dim_osnum = OM_Gw_current_OS,
		p_data = &par_senv);
	__CheckRC( status, 1, "dm$get_dim_param", wrapup );
	
	if(me->dual_mode == DUAL_MODE_OFF)
	{
		__DBGpr_com(" Get font info ");

		status=
		font$get_info(
			msg = &long_rc,
			font_num = &par_senv.text_font,
			font_info = &font_info);
		__CheckRC( status, 1, "font$get_info", wrapup );

		MATH_get_box_points(&rc,lbs_geom,box);

		descent_r = (font_info.descent * 2 * par_senv.txt_heig )/
		    		(font_info.bodysize - font_info.descent);

		vec_sub( box[3],box[0],box_orie);
		BSnorvec(&rc,box_orie);

		MATH_ptdelta(&rc,box[0],box_orie,-descent_r,box[0]);
		MATH_ptdelta(&rc,box[1],box_orie,-descent_r,box[1]);
		MATH_ptdelta(&rc,box[2],box_orie, descent_r,box[2]);
		MATH_ptdelta(&rc,box[3],box_orie, descent_r,box[3]);

		vec_sub( box[1],box[0],box_orie);
		BSnorvec(&rc,box_orie);

		MATH_ptdelta(&rc,box[0],box_orie,-descent_r,box[0]);
		MATH_ptdelta(&rc,box[1],box_orie, descent_r,box[1]);
		MATH_ptdelta(&rc,box[2],box_orie, descent_r,box[2]);
		MATH_ptdelta(&rc,box[3],box_orie,-descent_r,box[3]);

		vec_equal(   box[0], &(dim_line1[0]) );
		vec_equal(   box[1], &(dim_line1[3]) );
		vec_equal(   box[1], &(dim_line2[0]) );
		vec_equal(   box[2], &(dim_line2[3]) );
		vec_equal(   box[2], &(dim_line3[0]) );
		vec_equal(   box[3], &(dim_line3[3]) );
		vec_equal(   box[3], &(dim_line4[0]) );
		vec_equal(   box[0], &(dim_line4[3]) );

		__DBGpr_vec(" box #0 ", box[0] );
		__DBGpr_vec(" box #1 ", box[1] );
		__DBGpr_vec(" box #2 ", box[2] );
		__DBGpr_vec(" box #3 ", box[3] );
		
		index = 0;
		disp_line[index++] = dim_line1;
		disp_line[index++] = dim_line2;
		disp_line[index++] = dim_line3;
		disp_line[index++] = dim_line4;
		num_disp_line = index;
	}
	else
	{
		display.color = par_senv.dim_colr;
		display.style = 0;
		display.weight = par_senv.txt_weig;
		for( index = 1;index< 4;index++)
		{
			contents = NULL;
			field_num = index;

			status =
			GRfield_inquire(&long_rc,
					text_string,
					estx,
					&display,
					lbs_geom,
					&field_num,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					NULL,
					&contents,
					NULL,
					NULL,
					NULL,
					&just_pts);
			__CheckRC( status, 1, "GRfield_inquire", wrapup );

			if( index == 1)
			{
			  DMlineptpt(	just_pts.left_cap,just_pts.right_cap,
					dim_line2);
			  DMlineptpt(	just_pts.left_base,just_pts.right_base,
					dim_line1);
			  for( i=0; i<3; i++){
				dim_line3[i] = (just_pts.right_cap[i] +
						just_pts.right_base[i])/2;
				dim_line3[i+3]  = dim_line3[i] + 
					        just_pts.right_cap[i] -
						just_pts.left_cap[i];
			  }
			}
			else if( index == 2)
			{
			  BSproj0(&rc,just_pts.right_base,dim_line3,
					&dim_line3[3]);
			  BSproj0(&rc,just_pts.right_cap,dim_line2,
					&dim_line2[3]);
			}
			else if( index == 3)
			{
			  dist1 =
			  BSdistptpts(&long_rc,dim_line3,&dim_line3[3]);
			  dist2 =
			  BSdistptpts(&long_rc,	just_pts.left_cap,
						just_pts.right_cap);
			  BSproj0(&rc,just_pts.right_base,
					dim_line1,&dim_line1[3]);
			  if( dist2 > dist1){
				BSproj0(&rc,just_pts.right_cap,
						dim_line3,&dim_line3[3]);
			  }
			}
		}

		num_disp_line = 3;
		disp_line[0] = dim_line1;
		disp_line[1] = dim_line2;
		disp_line[2] = dim_line3;

		__DBGpr_vec(" Line1-0 ", &(dim_line1[0]) );
		__DBGpr_vec(" Line1-1 ", &(dim_line1[3]) );
		__DBGpr_vec(" Line2-0 ", &(dim_line2[0]) );
		__DBGpr_vec(" Line2-1 ", &(dim_line2[3]) );
		__DBGpr_vec(" Line3-0 ", &(dim_line3[0]) );
		__DBGpr_vec(" Line3-1 ", &(dim_line3[3]) );
	}

	__DBGpr_int(" Num_disp_line ", num_disp_line );

	for(index = 0; index< num_disp_line;index++)
	{
		status=
		om$send(msg = message DMroot.position_line(&rc,
						go_type[index],
						(struct GRid *)NULL,
						md_env,
						disp_line[index]),
			targetid = my_id);
		__CheckRC( status, 1, "DMroot.position_line", wrapup );
	}

wrapup:
	End
	return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method disp_box_type						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method disp_box_type(
	IGRlong *msg;
	IGRint	*display)
{
	SetProc( VDtxbox_disp_box_type_MTD ); Begin

	*display = 0 ;

	if ( me->box_type & VD_box_DISPLAY ) {

		*display = 1;
	}
	else if ( me->box_type & VD_box_AUTOMATIC ) {

		/*
		 * get the object informations ...
		 */
		*display = 1;
	}

	End
	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method get_box_type						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method get_box_type(
	IGRlong *msg;
	IGRuchar *box_type )
{
	*(box_type) = me->box_type;

	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method set_box_type						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method set_box_type(
	IGRlong *msg;
	IGRuchar box_type )
{
	me->box_type = box_type ;

	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method get_att_type						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method get_att_type(
	IGRlong *msg;
	IGRchar *att_type;
        IGRchar *text_string;
        IGRdouble *value  )
{

	SetProc( VDtxbox_get_att_type_MTD ); Begin

	strcpy(att_type, me->att_type );
	(*value) = me->value;
	strcpy(text_string, me->text_string );

	End
	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*	method set_att_type						    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method set_att_type(
	IGRlong *msg;
	IGRchar *att_type;
        IGRchar *text_string;
        IGRdouble *value  )
{
	IGRint	len;

	SetProc( VDtxbox_set_att_type ); Begin

	/* initialization of values */

	me->value          = 0 ;
	me->att_type[0]    = '\0';
	me->text_string[0] = '\0';

	if( att_type &&  ( len=strlen(att_type)) < MAX_TEXT_STRING ){
	  strcpy( me->att_type, att_type );
	}

	if( value ) me->value = *value ;

	if( text_string &&  ( len=strlen(text_string)) < MAX_TEXT_STRING ){
	  strcpy(text_string, me->text_string );
	}

	End
	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method GRdelete( IGRlong *msg;
                 struct GRmd_env *md_env)
{
IGRint  status = OM_S_SUCCESS;
struct  GRid    list[10], parId, macro;
IGRint  index, count, j,
        s_count, s_count1;
IGRchar c_name[80],*c;
OM_S_OBJECT_LINKAGE slist1[10],
                    slist[10];

   parId.objid = NULL_OBJID;
   macro.objid = NULL_OBJID;
   
  /*
   * disconnect the ci_macro "src_obj" if it exists,
   * and delete it before deleting of the annotation itself
   */

   status =
   om$send(msg    = message DMroot.DMreturn_roots( &count, list ),
           targetid  = my_id);
   as$status( action = RET_STATUS );

   for( index=0 ; index<count ; index++ ){

       status =
       om$get_classname(objid     = list[index].objid,
                        osnum     = list[index].osnum,
                        classname = c_name );
       if( !(status & 1)) continue; 
       if( om$is_ancestry_valid(
                                subclassname = c_name,
                              superclassname = "DMsrc" ) == OM_S_SUCCESS ){

                 parId.objid = list[index].objid ;
                 parId.osnum = list[index].osnum ;
                 break;
      }
  }

  if( parId.objid != NULL_OBJID ){
        /*
         * get ACpretend
         */
        status =
        om$get_channel_count(osnum   = parId.osnum,
                             objid   = parId.objid,
                             p_chanselect = &ND_father,
                             count   = (OMuint *)&s_count );

        status =
        om$get_channel_objects( osnum   = parId.osnum,
                                objid   = parId.objid,
                                p_chanselect = &ND_father,
                                size    = 10,
                                list    = slist,
                                count   = (OMuint *) &s_count );
       /*
        * Get the nci_macro "src_obj"
        */

        for (j=0; j < s_count; j++ ){

                om$get_channel_count(   osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        count   = (OMuint *)&s_count1 );
                status =
                om$get_channel_objects( osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        size    = 10,
                                        list    = slist1,
                                        count   = (OMuint *) &s_count1 );

                /*
                 * test on objects for macro src_obj.
                 */

                om$send(msg = message ACcpx.find_macro(&macro),
                        targetid = slist1[j].S_objid,
                        targetos = slist1[j].osnum);

                if( macro.objid == NULL_OBJID ) continue;

                status =
                om$send(msg = message ACcpx_defn.ACgive_name( &c ),
                        targetid = macro.objid,
                        targetos = macro.osnum);
		if(( status&1 ) && ( strcmp( c, "src_obj" ) == 0 )){
                        break;
                }
         }
         if( macro.objid != NULL_OBJID ){
	   status =
           om$send(msg = message GRgraphics.GRdelete( msg, md_env ),
                   targetid = slist1[j].S_objid,
                   targetos = slist1[j].osnum);
	   CheckRC( *msg, status );
         }
  }

  status =
  om$send(msg = message DMroot.GRdelete( msg, md_env ),
          mode = OM_e_wrt_message,
          targetid = my_id);
  CheckRC( *msg, status );
  
  return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

end implementation VDtxbox;

/*$Id: VDfrmtxti.I,v 1.3 2001/01/23 15:35:20 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDfrmtxti.I
 *
 * Description:
 *
 * Dependencies:
 *
 o Revision History:
 *	$Log: VDfrmtxti.I,v $
 *	Revision 1.3  2001/01/23 15:35:20  build
 *	ah
 *	
 *	Revision 1.2  2001/01/19 23:21:56  jayadev
 *	*** empty log message ***
 *	
# Revision 1.3  2000/05/04  14:44:08  pinnacle
# Replaced: vds/vdannot/imp/VDfrmtxti.I for:  by azuurhou for Service Pack
#
# Revision 1.2  2000/05/04  00:34:52  pinnacle
# Replaced: vds/vdannot/imp/VDfrmtxti.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/03  21:08:26  pinnacle
# Created: vds/vdannot/imp/VDfrmtxti.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/18  23:10:56  pinnacle
# Replaced: vdannot/imp/VDfrmtxti.I for:  by mdong for vds
#
# Revision 1.3  1997/09/18  03:06:44  pinnacle
# Replaced: vdannot/imp/VDfrmtxti.I for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:10:08  pinnacle
# Replaced: vdannot/imp/VDfrmtxti.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/12  22:08:06  pinnacle
# Replaced: vdannot/imp/VDfrmtxti.I for:  by yzhu for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/09  22:31:26  pinnacle
# Created: vdannot/imp/VDfrmtxti.I by yzhu for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/07/96	yzhu		copy it from VDtxboxi.I
 *                                      and remove get_att_type
 *                                      and set_att_type 
 *	05/03/2000	Alwin		Modified the update_text_box method to implement
 *							Box Ratio, for the text boxes. CR179901299
 *      01/23/01        ah             Uncommented %safe stuff
 * -------------------------------------------------------------------*/

class implementation VDfrmtxt;

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
#include "dim.h"

#include "VDSannot.h"
#include "VDSglobals.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "comnmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

#define		AS_DEBUG 1
#define		AN_ROOT_EXPN	3

extern double fabs();
extern double sqrt();
extern IGRboolean GRabsg_del_all();


%safe
  IGRdouble 	VDCmdtxldr_text_angle = 0.0;
  unsigned char VDCmdtxldr_flag = 0;
  IGRlong	VDCmdtxldr_text_flag = 0;
%endsafe
  static IGRint	TEXT_length;

from	dim_param	import give_internal, edit;
from	DMsrc		import DMgive_tangent, DMgive_src_info;
from 	DMsrc		import DMgive_structure;
from	GRtext		import GRgettxattr,GRfield_inquire; 
from 	GRtext		import GRreplace_text;
from 	DMplan		import give_info;
from	ACcpx		import ACfind_exp_temp_obj, find_macro;
from    ACcpx_defn      import ACgive_name;
from    expression      import NDgive_value,NDset_value, modify;
from    GRtext          import GRchgtextattr;

#omdef dm$return_dim_go(index, p_grid, obj_type)
{
        if (p_grid == NULL)
        {
                if (index == DIM_NO_INDEX)
                {
                        *msg = DIM_E_BAD_OBJSPEC;
                        return(OM_E_ABORT);
                }

                p_grid = &tmp_grid;
        }

        if (index != DIM_NO_INDEX)
        {
                status =
                om$send(msg = message DMroot.return_dim_go(
                                                msg,
                                                index,
                                                TRUE,
                                                obj_type,
                                                md_env,
                                                p_grid),
                        targetid = my_id);
                dm$status(action = RET_STATUS);
        }

        /*      printf("go = %d, %d\n", p_grid->objid, p_grid->osnum); */
}
#endomdef

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*      method get_box_caps_parser_typ                                      */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method get_box_caps_parser_type(
        IGRlong           *msg;
        IGRuchar          *box_type;
        IGRuchar          *cap_type;
        IGRuchar          *par_type)
{
     SetProc( VDfrmtxti.get_box_caps_parser_type ); Begin
     *msg = MSSUCC;
     *(box_type) = 1;
     *(cap_type) = 0;
     *(par_type) = 0;

     if( me->box_type & VD_box_NO_DISPLAY ) *(box_type) = 1;
     if( me->box_type & VD_box_DISPLAY ) *(box_type) = 4;
     if( me->box_type & VD_box_ELLIPSE ) *(box_type) = 8;
     if( me->box_type & VD_text_CAPS ) *(cap_type) = 1;
     if( me->box_type & VD_text_QUERY_INFO ) *(par_type) = 1;

     __DBGpr_int( "me->box_type", me->box_type);
     __DBGpr_int( "box_type",   *(box_type));
     __DBGpr_int( "cap_type",   *(cap_type));
     __DBGpr_int( "par_type",   *(par_type));

     End
     return(OM_S_SUCCESS);
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*      method set_box_caps_parser_typ                                      */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method set_box_caps_parser_type(
        IGRlong           *msg;
        IGRuchar          *box_type;
        IGRuchar          *cap_type;
        IGRuchar          *par_type)
{
     int 	n;

     SetProc( VDfrmtxti.set_box_caps_parser_type ); Begin
     *msg = MSSUCC;

     n = 0;
     if( *box_type == 4) n = n | VD_box_DISPLAY;
     if( *box_type == 8) n = n | VD_box_ELLIPSE;
     if( *box_type == 1) n = n | VD_box_NO_DISPLAY;
     if( *cap_type == 1) n = n | VD_text_CAPS;
     if( *par_type == 1) n = n | VD_text_QUERY_INFO;

     me->box_type = n;

     __DBGpr_int( "me->box_type", me->box_type);
     __DBGpr_int( "box_type",   *(box_type));
     __DBGpr_int( "cap_type",   *(cap_type));
     __DBGpr_int( "par_type",   *(par_type));

     End
     return(OM_S_SUCCESS);
}

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
  IGRint		 nb_temp, s_count, i, j,j1,
			 s_count1, ii,
			 ind, s_count2;
  IGRshort		 rc;
  struct GRid		 roots[10];
  struct GRid		 parId;
  IGRchar		*c, c_name[80];
  OM_S_OBJECT_LINKAGE	 slist1[10],
			 slist [10],
			 slist2[10];
  IGRdouble		 new_val[3];

  SetProc( VDfrmtxti.GRxform ); Begin
  __enterMethod ( name = "GRxform" );

  myObj.objid	= my_id;
  myObj.osnum	= OM_Gw_current_OS;
  macro.objid	= NULL_OBJID;
 
  __DBGpr_obj(" myObj ", myObj); 
  for( ind=0; ind<3; ind++ )
  {
    new_val[ind] = 0.0 ;
  }

  /* 
   * get the roots of VDfrmtxt( located object )
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
    
    __DBGpr_obj(" roots ", roots[i]); 
    __DBGpr_str(" classname ", c_name); 

    if( om$is_ancestry_valid (	subclassname   = c_name,
				superclassname = "DMsrc" ) == OM_S_SUCCESS )
    {
      parId.objid = roots[i].objid ;
      parId.osnum = roots[i].osnum ;
      break;
    }
  }

  if( parId.objid == NULL_OBJID ) goto wrapup;

  __DBGpr_obj(" parId ", parId); 

  /* 
   * get ACpretend
   */
  status =
  om$get_channel_count (	osnum   = parId.osnum,
				objid   = parId.objid,
				p_chanselect = &ND_father,
				count   = (OMuint *)&s_count );
  if ( s_count > 10 ) { goto wrapup; }

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
  parId.objid = NULL_OBJID ;
  __DBGpr_int(" s_count ", s_count); 
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

    
    __DBGpr_int(" slist.S_objid ", slist[j].S_objid); 
    __DBGpr_int(" s_count1 ", s_count1); 
    for (j1=0; j1 < s_count1; j1++ ){
    	/*
     	* test on objects for macro src_obj.
     	*/
    	macro.objid = NULL_OBJID ;
    	om$send (	msg	 = message ACcpx.find_macro(&macro),
		targetid = slist1[j1].S_objid,
		targetos = slist1[j1].osnum);

        __DBGpr_int(" slist1.S_objid ", slist1[j1].S_objid); 
    	if( macro.objid == NULL_OBJID ) continue;

        __DBGpr_obj(" macro ", macro); 
    	status =
    	om$send (	msg	 = message ACcpx_defn.ACgive_name( &c ),
		targetid = macro.objid,
		targetos = macro.osnum);
    	as$status();

        __DBGpr_str(" macro name ", c); 
    	if( strcmp( c, "src_obj" ) == 0 )
    	{
      		parId.objid = slist1[j1].S_objid,
      		parId.osnum = slist1[j1].osnum ;
      		break;
        }

        if( parId.objid != NULL_OBJID )  break;
    } /* for j1 */
  }
	
  if( parId.objid == NULL_OBJID )
  {
    __exitMethod ( name = "GRxform" );
    return OM_S_SUCCESS;
  }

  __DBGpr_obj(" src_obj ", parId); 
  /*
   * get the parents of nci_macro "src_obj"
   */
  om$get_channel_count(   osnum   = parId.osnum,
			    objid   = parId.objid,
			    p_chanselect = &ND_father,
			    count   = (OMuint *)&s_count2 );
  if ( s_count2 > 10 ) { goto wrapup; }

  status =
  om$get_channel_objects( osnum   = parId.osnum,
			    objid   = parId.objid,
			    p_chanselect = &ND_father,
			    size    = 10,
			    list    = slist2,
			    count   = (OMuint *) &s_count2 );

  __DBGpr_int(" s_count2 ", s_count2); 
  for( ii = 1; ii<2; ii++ )
  {
    int			pos;
    struct ret_struct	expr;

    temp.objid  =  slist2[ii].S_objid;
    temp.osnum  =  slist2[ii].osnum;

    __printf ( "temp = [%d,%d]", `temp.osnum, temp.objid` );
    __DBGpr_obj(" temp ", temp); 

    status =
    om$send (	msg	 = message expression.NDgive_structure( 
                                           msg, &expr, md_env ),
		targetid = temp.objid,
		targetos = temp.osnum  );
    CheckRC( status, *msg );

    __printf ( "<<< expr.var.text_st.text_string = <%s>", 
                                expr.var.text_st.text_string );;

    sscanf ( expr.var.text_st.text_string, "%d %lf %lf %lf", 
                        &pos, &new_val[0], &new_val[1], &new_val[2] );

    new_val[0] += matrix[ 3];
    new_val[1] += matrix[ 7];
    new_val[2] += matrix[11];

    sprintf ( expr.var.text_st.text_string, "%d %lf %lf %lf", 
                            pos, new_val[0], new_val[1], new_val[2] );

    __printf ( ">>> expr.var.text_st.text_string = <%s>", 
                                      expr.var.text_st.text_string );

    status =
    om$send (	msg	 = message expression.modify( "",
						  expr.var.text_st.text_string,
						  &rc ),
		targetid = temp.objid,
		targetos = temp.osnum  );
    CheckRC( status, 1 );
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

  End
  return status;

wrapup:

  status =
  om$send (	msg	 = message DMroot.GRxform( msg, md_env, matrix_type,
							matrix, newobjid ),
		mode	 = OM_e_wrt_message,
		targetid = my_id );

  __exit_error_Method ( name = "GRxform" );

  End
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
	IGRint			i, display, rc, len;	
	struct	ret_struct	ret_str ;
	struct	GRid		text_grid ;
	IGRchar                 temp[256];
	IGRuchar 		cap_type, reverse_type;

        SetProc( VDfrmtxti.DMcompute_node ); Begin
	/*
	 * delete the graphical component/owner object of the box.
	 */
	for(i=DIM_LINE1;i<=DIM_LINE4;i++){
	    status =
	    om$send(msg = message DMroot.delete_dim_go( &rc, i, md_env),
		    targetid = my_id);
	    as$status(action = RET_STATUS);
	}

	status =
        om$send(msg = message DMroot.delete_dim_go( &rc,
                                                    DIM_BALLOON,
                                                    md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);
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

        /* tr179701438 */
        __DBGpr_str( "ret_str.var.text_st.text_string",
                      ret_str.var.text_st.text_string);
        len = 0;
        len = strlen( ret_str.var.text_st.text_string );

        strcpy(temp, ret_str.var.text_st.text_string);
        __DBGpr_str( "temp", temp);
        temp[len] = '\0';

	if(VDCmdtxldr_flag)
	{
	  status =
          om$send(msg = message VDfrmtxt.VDgetCapsFlag(
                                msg,
                                &cap_type ),
                  targetid = my_id);
          as$status(action = RET_STATUS);

          if( cap_type ) 
	  {
            VDstr_caps(temp);
            __DBGpr_str( "Capital letter", temp);
          }

	  status =
          om$send(msg = message VDfrmtxt.VDgetReverseFlag(
                                msg,
                                &reverse_type ),
                  targetid = my_id);
          as$status(action = RET_STATUS);

          if( reverse_type )
          {
            VDstr_reverse(temp);
            __DBGpr_str( "Reverse letter", temp);
          }
        }
 
	/*
	 * replace the text string.
	 */
	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_TEXT,
				&text_grid,
				md_env,
				len,
			        (IGRuchar *)temp ),
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
	om$send(msg = message VDfrmtxt.disp_box_type(msg, &display ),
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

        End
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

        SetProc( VDfrmtxti.gather_data ); Begin
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

        End
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
        IGRvector perp_vec, refer_dir, orie_vec;
        IGRdouble *prev_point, y_offset,*proj_pt;
        IGRdouble active_angle = 0.0;
        IGRmatrix       trans_matrix;
        IGRlong         msg_rc;
        BSrc            bs_rc;
        IGRdouble       PlaceAngle;
        IGRdouble       norm[3];
	IGRvector	req_dir;
	IGRdouble	original_p[3], rotate_matrix[9];
	IGRuchar	cap_type, reverse_type;

        extern IGRboolean dynamics_in_progress;

	SetProc( VDfrmtxti.txdynamics); Begin
        /*
	 * initailizing pointers
	 */
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;
	prev_point      = NULL;
	for(i = 0 ; i < 3 ; i++) original_p[i]= 0.0;

        place_attr	= (struct DMdyn_annot *)info;
        plan_info	= &place_attr->plan_info;
        loc_ele_header	= &place_attr->ele_header;

        loc_text_string = (loc_ele_header->ele_spec_att.text) ?
                          (unsigned char *)
                          loc_ele_header->ele_spec_att.text->text_string : NULL;

        proj_pt		= (IGRdouble *)cursor;
        hilite 		= FALSE;

	if(loc_text_string == NULL)
	  TEXT_length = place_attr->text_length;

        if(VDCmdtxldr_flag && (place_attr->text_length == TEXT_length))
        {
          status =
          om$send(msg = message VDfrmtxt.VDgetCapsFlag(
                                msg,
                                &cap_type ),
                  targetid = my_id);
          as$status(action = RET_STATUS);

          if( cap_type )
          {
            VDstr_caps((IGRchar *)place_attr->text_string);
            __DBGpr_str( "Capital letter", place_attr->text_string);
          }

	  status =
          om$send(msg = message VDfrmtxt.VDgetReverseFlag(
                                msg,
                                &reverse_type ),
                  targetid = my_id);
          as$status(action = RET_STATUS);

          if( reverse_type )
          {
            VDstr_reverse((IGRchar *)place_attr->text_string);
            __DBGpr_str( "Reverse letter", (IGRchar *)place_attr->text_string);
          }
        }

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

	status =
        om$send(msg = message DMroot.delete_dim_go( &rc,
                                                    DIM_BALLOON,
                                                    md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

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

                status=
                om$send( msg = message VDfrmtxt.VDgetAngle(&msg_rc,
                                                           &PlaceAngle),
                         targetid = my_id);
                as$status(action = RET_STATUS);

      	        for( i = 0; i<3; i++)
                {
                  norm[i] = plan_info->win_plan.matrix[i+8];
                }
                BSnorvec(&bs_rc, norm);

                MAgrotmx (&msg_rc,norm,original_p, &PlaceAngle,trans_matrix);
  
	        for( i = 0 ; i < 3 ; i++)
	        {
	          rotate_matrix[i] = trans_matrix[i];
         	  rotate_matrix[i+3] = trans_matrix[i+4];
	          rotate_matrix[i+6] = trans_matrix[i+8];
	        }

		for( i = 0 ; i < 3 ; i++)
                {
                  orie_vec[i] = plan_info->win_plan.matrix[i];
                }
                BSnorvec(&bs_rc, orie_vec);

	        BSmult_mats(3, 3, rotate_matrix, FALSE, 3, 1, 
		            orie_vec, FALSE, 
			    req_dir, &bs_rc);

	        BSnorvec(&rc,req_dir);

                DMinquire_hilite(
                        proj_pt,
                        prev_point,
                        target_pt,
                        NULL,
                        refer_dir,
                        req_dir,
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
		
		if(VDCmdtxldr_flag)
		{
		  status =
          	  om$send(msg = message VDfrmtxt.VDgetReverseFlag(
                                        msg,
                                        &reverse_type ),
                          targetid = my_id);
                  as$status(action = RET_STATUS);

		  if(reverse_type)
		  {
		    if (txt_just == LEFT_CENTER)
                      txt_just = RIGHT_CENTER;
                    else if (txt_just == LEFT_CAP)
                      txt_just = RIGHT_CAP;
                    else if (txt_just == LEFT_BASE)
                      txt_just = RIGHT_BASE;
		    else if (txt_just == LEFT_BOTTOM)
                      txt_just = RIGHT_BOTTOM;
                    else if (txt_just == LEFT_TOP)
                      txt_just = RIGHT_TOP;
		  }
		}

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
		else
		{
		  place_attr->txt_just = txt_just;
	        }

                BScrossp(&rc,
                         &plan_info->win_plan.matrix[8],
                         place_attr->txt_orie,
                         perp_vec);

                y_offset =  0.5 * place_attr->par_senv.txt_heig;

		status=
                om$send( msg = message VDfrmtxt.VDgetAngle(&msg_rc,
                                                           &PlaceAngle),
                         targetid = my_id);
                as$status(action = RET_STATUS);

                if (place_attr->par_senv.an_posn == ANNOT_JUST_BOTTOM ||
		    (place_attr->par_senv.an_posn == ANNOT_JUST_UNDER &&
                    PlaceAngle > 3.1415926/2.0 && 
                    PlaceAngle < 3.0*3.1415926/2.0) )
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

	        status=
                om$send( msg = message VDfrmtxt.VDgetAngle(&msg_rc,
                                                           &PlaceAngle),
                         targetid = my_id);
                as$status(action = RET_STATUS);

                for( i = 0; i<3; i++)
                {
                  norm[i] = plan_info->win_plan.matrix[i+8];
                }
		BSnorvec(&bs_rc, norm);

                MAgrotmx (&msg_rc,norm,text_pt,
                          &PlaceAngle,trans_matrix);
		
		for( i = 0 ; i < 3 ; i++)
                {
                  rotate_matrix[i] = trans_matrix[i];
                  rotate_matrix[i+3] = trans_matrix[i+4];
                  rotate_matrix[i+6] = trans_matrix[i+8];
                }

		for( i = 0 ; i < 3 ; i++)
  		{
		  req_dir[i] = place_attr->txt_orie[i];
		}
		BSnorvec(&bs_rc, req_dir);

                BSmult_mats(3, 3, rotate_matrix, FALSE, 3, 1,
                            req_dir, FALSE,
                            orie_vec, &bs_rc);

		BSnorvec(&bs_rc, orie_vec);
                BScrossp(&bs_rc, norm, orie_vec, perp_vec);
		BSnorvec(&bs_rc, perp_vec);

                for( i = 0 ; i < 3 ; i++)
                {
		  lbs_geom->matrix[i*4]   = orie_vec[i];
                  lbs_geom->matrix[i*4+1] = perp_vec[i];
                  lbs_geom->matrix[i*4+2] = norm[i];
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
		om$send( msg = message VDfrmtxt.update_text_box(
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

        End
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

        SetProc( VDfrmtxti.get_disp_list );  Begin
	status =
	om$send(msg = message DMtxldr.get_disp_list( msg, count, list, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	as$status(action = RET_STATUS);

	index = 0;

        if(me->box_type == VD_box_ELLIPSE)
        {
	go_index[index++] = DIM_BALLOON;

        if( me->leader ) {

                go_index[index++] = DIM_LEADER;
                go_index[index++] = DIM_ORI_TERM;
        }
        num_obj = index;

        go_type[0] = DM_CIRCLE;
        go_type[1] = ( me->leader ) ? DM_LINE_STR : DM_LINE ;
	go_type[2] = ( me->leader ) ? DM_TEXT     : DM_LINE ;

        }
        else
        {

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
        }

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

        End
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

	SetProc( VDfrmtxt_make_an_text_MD ); Begin

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
	om$send(msg = message VDfrmtxt.update_text_box(
       	                                &long_rc,
               	                        text_string,
                       	                &attr,
                               	        lbs_geom,
                                       	md_env),
                targetid = my_id);
	__CheckRC( status, long_rc, "VDfrmtxt.update_text_box", wrapup );

wrapup:
	_FREE( text_string );

	End
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
        struct IGRbsp_curve     *bsp_curve;
        IGRdouble               poles[21],weights[7],knots[10];
        IGRdouble               majsemaxis, tmp_point[3];
        struct GRpost_info 	post_info;
        struct GRid 		bln_grid;
        IGRint                  msg_rc;
        BSrc                    bs_rc;
        IGRpoint                centerpt, majpt, rimpt;

	SetProc( VDfrmtxt_update_text_box_MTD ); Begin

	*msg = MSSUCC ;

	if( text_string ){
		__DBGpr_str(" text_string ", text_string );
	}

	/*
	 * see if we have to do with an box.
	 */	
	status =
	_VD_SEND_MY( VDfrmtxt.disp_box_type( &long_rc, &display_box ));
	__CheckRC( status, long_rc, "VDfrmtxt.disp_box_type", wrapup );

	if( ! display_box ) return OM_S_SUCCESS;

	if(me->box_type == VD_box_ELLIPSE)
	{

        status =
        om$send(msg = message DMroot.delete_dim_go( &msg_rc,
                                                    DIM_BALLOON,
                                                    md_env),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.return_dim_go( &msg_rc,
                                                    DIM_BALLOON,
                                                    TRUE,
                                                    DM_CIRCLE,
                                                    md_env,
                                                    &bln_grid),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        dm$get_dim_param(
                type = DM_SENV_PARAM,
                dim_objid = my_id,
                dim_osnum = OM_Gw_current_OS,
                p_data = &par_senv);
        __CheckRC( status, 1, "dm$get_dim_param", wrapup );

        status=
        font$get_info( msg = &long_rc,
                       font_num = &par_senv.text_font,
                       font_info = &font_info);
        __CheckRC( status, 1, "font$get_info", wrapup );

        MATH_get_box_points(&rc,lbs_geom,box);

        for( i = 0 ; i < 3 ; i++)
        {
          centerpt[i] = (box[0][i] + box[2][i])/2.0;
        }

        vec_sub(box[1], box[0], tmp_point);
        majsemaxis = vec_len(tmp_point) * 3.0 / 4.0;

        for (i=0;i<3;i++)
        {
          majpt[i] = centerpt[i] + majsemaxis * lbs_geom->matrix[i*4];
          rimpt[i]=box[2][i];
        }

        status =
        om$send(msg = message GRvg.GRgenabsg(
                              &long_rc,
                              &md_env->md_env.matrix_type,
                              md_env->md_env.matrix,
                              (char **)&bsp_curve),
                targetid = bln_grid.objid,
                targetos = bln_grid.osnum);
        dm$status( action = RET_STATUS);

        bsp_curve->poles = poles;
        bsp_curve->weights = weights;
        bsp_curve->knots = knots;

        status =
        BSellctaxrm( &bs_rc,
                     centerpt,
                     majpt,
                     rimpt,
                     bsp_curve);

        if(status != OM_S_SUCCESS || bs_rc != BSSUCC)
        {
          printf("Position Balloon : BSellctaxrm() Fails\n");
          printf("BSellctaxrm() Fails = %d\n",bs_rc);
          return(OM_E_ABORT);
        }

        post_info.construct_flag = FALSE;

        status =
        om$send(msg = message GRvg.GRpostabsg(&long_rc,
                                              md_env,
                                              &post_info,
                                              (char *)bsp_curve,
                                              &bln_grid.objid),
                targetid = bln_grid.objid,
                targetos = bln_grid.osnum);
        dm$status( action = RET_STATUS);

	}
	else
	{

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

		__DBGpr_dbl( " Balloon size", par_senv.bln_size );
		__DBGpr_dbl( " Char Space ", par_senv.car_spac );
		__DBGpr_dbl( " Line Space ", par_senv.lin_spac );

		/* Box Ratio is introduced at this point. ( 0.1 * Balloon size ).
		CR179901299 Alwin*/
		descent_r = 0.1 * par_senv.bln_size * 
					(font_info.descent * 2 * par_senv.txt_heig )/
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
	SetProc( VDfrmtxt_disp_box_type_MTD ); Begin

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
	else if ( me->box_type & VD_box_ELLIPSE ) {

                *display = 1;
        }

	*msg	= MSSUCC ;

	End
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

   SetProc( VDfrmtxti.GRdelete ); Begin
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

  End  
  return(status);
}

/* ************************************************************************ */
/* METHOD position_text                                                     */
/* ************************************************************************ */
method position_text(
        IGRint *msg;
        IGRboolean txt_flag;
        IGRint text_index;
        struct GRid *text_grid;
        struct GRmd_env *md_env;
        IGRshort  justification;
        IGRdouble origin[3];
        IGRdouble orie_vec[3];
        IGRdouble norm[3];
        struct DMloc_param *par_loc;
        struct DMenv_param *par_env)
{
        IGRint status, rc, i;
        IGRlong long_rc;
        BSrc bs_rc;
        IGRdouble perp_vec[3];
        struct IGRlbsys *lbsys_geom;
        struct GRid tmp_grid;
        struct GRdpb_text_symb text_symb;
        struct GRpost_info info;
        IGRint attr_num;
        struct GRmd_env mod_info;
        IGRdouble box[4][3];
        IGRmatrix       trans_matrix;
        IGRlong         msg_rc;
        IGRdouble       PlaceAngle;
	IGRuchar	reverse_type;
	IGRvector	trvec;
        IGRdouble	rotmat[9];
	struct DMsenv_param par_senv;
	IGRdouble	*break_pt;
 	IGRint		num_vertex;
	IGRdouble	y_offset;


	SetProc( VDfrmtxt_position_text ); Begin

        *msg = DIM_S_SUCCESS;
        mod_info = *md_env;
        mod_info.md_id.objid = NULL_OBJID;

        dm$return_dim_go(index=text_index, p_grid=text_grid, obj_type=DM_TEXT);

        /*^
                print_point("origin", origin);
                print_point("orie_vec", orie_vec);
                print_point("norm", norm);
        */

        if (justification != -1)
        {

		if(VDCmdtxldr_flag)
        	{
                  status =
                  om$send(msg = message VDfrmtxt.VDgetReverseFlag(
                                        &long_rc,
                                        &reverse_type ),
                          targetid = my_id);
                  dm$status(action = RET_STATUS);

		  if(reverse_type)
		  {
		    if (justification == LEFT_CENTER)
                      justification = RIGHT_CENTER;
                    else if (justification == LEFT_CAP)
                      justification = RIGHT_CAP;
                    else if (justification == LEFT_BASE)
                      justification = RIGHT_BASE;
		    else if (justification == LEFT_BOTTOM)
                      justification = RIGHT_BOTTOM;
                    else if (justification == LEFT_TOP)
                      justification = RIGHT_TOP;
		  }
		}

                text_symb.Active_just = justification;
                attr_num = GRTEXT_JUST;

                status =
                om$send(msg = message GRtext.GRchgtextattr(
                                                &long_rc,
                                                &mod_info,
                                                attr_num,
                                                &text_symb),
                        targetid = text_grid->objid,
                        targetos = text_grid->osnum);
                dm$status(action = RET_STATUS);
        }

        status =
        om$send(msg = message GRvg.GRgenabsg(
                                        &long_rc,
                                        &mod_info.md_env.matrix_type,
                                        mod_info.md_env.matrix,
                                        (char **)&lbsys_geom),
                targetid = text_grid->objid,
                targetos = text_grid->osnum);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.return_dim_go(
                                                   msg,
                                                   DIM_TEXT,
                                                   TRUE,
                                                   DM_TEXT,
                                                   md_env,
                                                   &tmp_grid),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        if(tmp_grid.objid == text_grid->objid &&
           tmp_grid.osnum == text_grid->osnum )
        {

	  status=
          om$send( msg = message VDfrmtxt.VDgetAngle(&msg_rc,
                                                     &PlaceAngle),
                   targetid = my_id);
          as$status(action = RET_STATUS);

          if (orie_vec && norm)
          {
	    if( PlaceAngle > 3.1415926/2.0 &&
                    PlaceAngle < 3.0*3.1415926/2.0 )
	    {

	      status =
              dm$get_dim_param( type      = DM_SENV_PARAM,
                                dim_objid = my_id,
                                dim_osnum = OM_Gw_current_OS,
                                p_data    = &par_senv );
              __CheckRC( status, 1, "dm$get_dim_param", wrapup );

	      if( me->dim_type == TEXT_WITH_LEADER && 
	      par_senv.an_posn == ANNOT_JUST_UNDER )
              {
	        BScrossp( &bs_rc, norm, orie_vec, perp_vec );
                BSnorvec( &bs_rc, perp_vec );
                y_offset = 0.5 * par_senv.txt_heig;

		num_vertex = om$dimension_of( varray = me->break_pt ) / 3;
                break_pt   = &me->break_pt[3*(num_vertex - 1)];
                for( i=0 ; i < 3 ; i++ )
                {
                  origin[i] = break_pt[i] - y_offset * perp_vec[i];
                }
	      }
 	    }

            MAgrotmx( &msg_rc,norm,origin,&PlaceAngle,trans_matrix );

            for( i = 0 ; i < 3 ; ++i )
            {
              rotmat[i] = trans_matrix[i];
              rotmat[i+3] = trans_matrix[i+4];
              rotmat[i+6] = trans_matrix[i+8];
            }

            BSmult_mats(3, 3, rotmat, FALSE,
                        3, 1, orie_vec, FALSE, trvec, &bs_rc);

            for( i = 0 ; i < 3 ; ++i )
            {
              orie_vec[0] = trvec[0];
              orie_vec[1] = trvec[1];
              orie_vec[2] = trvec[2];
            }
          }

        }

        if (orie_vec && norm)
        {
                BSnorvec(&bs_rc, orie_vec);
                BSnorvec(&bs_rc, norm);
                BScrossp(&bs_rc, norm, orie_vec, perp_vec);
                if (bs_rc != BSSUCC)
                {
                        *msg = DIM_E_BSMATH;
                        return(OM_E_ABORT);
                }
                BSnorvec(&bs_rc, perp_vec);

                for (i=0; i<3; i++)
                {
                        lbsys_geom->matrix[i*4] = orie_vec[i];
                        lbsys_geom->matrix[i*4+1] = perp_vec[i];
                        lbsys_geom->matrix[i*4+2] = norm[i];
                }
        }

        lbsys_geom->matrix[12] =
        lbsys_geom->matrix[13] =
        lbsys_geom->matrix[14] = 0.0;
        lbsys_geom->matrix[15] = 1.0;

        lbsys_geom->matrix[3]  = origin[0];
        lbsys_geom->matrix[7]  = origin[1];
        lbsys_geom->matrix[11] = origin[2];

        info.construct_flag = FALSE;

        /*^ print_matrix("matrix", lbsys_geom->matrix); */

        status =
        om$send(msg = message GRvg.GRpostabsg(
                                        &long_rc,
                                        &mod_info,
                                        &info,
                                        (char *)lbsys_geom,
                                        &text_grid->objid),
                targetid = text_grid->objid,
                targetos = text_grid->osnum);
        dm$status(action = RET_STATUS);

        if ((me->dim_type == TEXT_WITH_LEADER) && txt_flag)
        {
                /*|- Text with leader: text placement*/

                if (me->geom_type & DIM_INTERMEDIATE)
                {
                        /*|- Intermediate flag set*/

                        MATH_get_box_points(&rc, lbsys_geom, box);


                        status =
                        om$send( msg= message DMroot.position_line(
                                                &rc,
                                                DIM_ULINE,
                                                NULL,
                                                md_env,
                                                (IGRdouble *)box),
                        targetid = my_id);
                        dm$status( action= RET_STATUS);

                        me->geom_type &= ~DIM_INTERMEDIATE;
                }
                else
                {
                        /*|- No Intermediate Flag*/

                        status =
                        om$send(msg = message DMroot.delete_dim_go(
                                                        &rc,
                                                        DIM_ULINE,
                                                        md_env),
                        targetid = my_id);
                        dm$status(action = RET_STATUS);
                }
        }

        /*|- Clear the cache memory */

        status =
        GRabsg_del_all();
        dm$status(action = RET_STATUS);

	wrapup:
	End
        return(OM_S_SUCCESS);
}
/*************************************************************************/
/*      METHOD update_leader                                             */
/*************************************************************************/

method update_leader(
    IGRint *msg;
    IGRint *num_vertex;
    IGRdouble *geometry;
    struct DMsenv_param *par_senv;
    struct DMplan_info *plan_info;
    struct GRmd_env *md_env)
{
    IGRint		status, rc;
    IGRlong		long_rc, bsrc;
    struct IGRlbsys	*lbsys;
    struct IGRestx	attr;
    struct GRid		text_grid;
    IGRboolean		extend, intersect;
    IGRdouble		intpt[6], lea_line[6], lea_vec[3];
    IGRdouble		dotp, req_dir[3], *p1, *p2;
    IGRchar		just_attr;
    IGRdouble		box[12];
    IGRmatrix		trans_matrix;
    IGRlong		msg_rc;
    BSrc		bs_rc;
    IGRdouble		PlaceAngle;
    IGRdouble		norm[3];
    IGRdouble		original_p[3], rotate_matrix[9];
    IGRint		i;
    IGRvector		orie_vec;
    struct GRid         bln_grid;
    struct IGRbsp_curve bsp_curve1, bsp_curve2;
    IGRdouble 		poles[6], knots[4], weights[2];
    IGRdouble           poles2[21],weights2[7],knots2[10];
    IGRint 		num_pts, nint, index;
    IGRlong 		nover;
    IGRdouble 		*xpar1, *xpar2, *xover1, *xover2, *xintpt, *xendpt;
    IGRdouble		*req_pt, mdist, dist;
    struct vfont_entry  font_info;
    IGRpoint            centerpt, majpt, rimpt, tmp_point;
    IGRdouble           majsemaxis;
    struct GRpost_info  post_info;
    double              descent_r,box_orie[3];


    for(i = 0 ; i < 3 ; i++) original_p[i]= 0.0;

    *num_vertex = om$dimension_of(varray = me->break_pt) / 3;

    if (me->dim_type != TEXT_WITH_LEADER)
        return(OM_S_SUCCESS);

    if (*num_vertex < 2)
    {
        status =
        om$send(msg = message DMroot.delete_dim_go(
                        &rc,
                        DIM_LEADER,
                        md_env),
            targetid = my_id);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
    }

    /*"geometry:%d",geometrye*/

    if(!geometry)
    {
        status =
        om$send(msg = message DMroot.return_dim_go(
                        &rc,
                        DIM_TEXT,
                        FALSE,
                        DM_TEXT,
                        md_env,
                        &text_grid),
            targetid = my_id);
        dm$status(action = RET_STATUS);

        if( text_grid.objid == NULL_OBJID)
            return(OM_S_SUCCESS);

        status =
        om$send(msg = message GRtext.GRgettxattr(
                        &long_rc,
                        &attr,
                        NULL,
                        NULL),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);

        if (!attr.num_char)
        {
            /*| displayable chars = 0 */
            return(OM_S_SUCCESS);
        }

        status =
        om$send(msg = message GRvg.GRgenabsg(
                    &long_rc,
                    &md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    (char **)&lbsys),
            targetid = text_grid.objid,
            targetos = text_grid.osnum);
        dm$status(action = RET_STATUS);
    }
    else
    {
        lbsys = (struct IGRlbsys *)geometry;
    }

    status=
    font$get_info( msg = &long_rc,
                   font_num = &par_senv->text_font,
                   font_info = &font_info);
    dm$status(action = RET_STATUS);

    if(me->box_type == VD_box_ELLIPSE)
    {
      status =
      om$send(msg = message DMroot.delete_dim_go( &rc,
                                                  DIM_BALLOON,
                                                  md_env),
              targetid = my_id);
      dm$status(action = RET_STATUS);

      status =
      om$send(msg = message DMroot.return_dim_go( &rc,
                                                  DIM_BALLOON,
                                                  TRUE,
                                                  DM_CIRCLE,
                                                  md_env,
                                                  &bln_grid),
              targetid = my_id);
      dm$status(action = RET_STATUS);

      MATH_get_box_points(&rc,lbsys,box);

      for( i = 0 ; i < 3 ; i++)
      {
        centerpt[i] = (box[i] + box[i+6])/2.0;
      }

      vec_sub(&box[3], &box[0], tmp_point);
      majsemaxis = vec_len(tmp_point) * 3.0 / 4.0;

      for (i=0;i<3;i++)
      {
        majpt[i]=centerpt[i] + majsemaxis * lbsys->matrix[i*4];
        rimpt[i]=box[i+6];
      }

      bsp_curve2.poles = poles2;
      bsp_curve2.weights = weights2;
      bsp_curve2.knots = knots2;

      status =
      BSellctaxrm( &bs_rc,
                   centerpt,
                   majpt,
                   rimpt,
                   &bsp_curve2);

      if(status != OM_S_SUCCESS || bs_rc != BSSUCC)
      {
        printf("Position Balloon : BSellctaxrm() Fails\n");
        printf("BSellctaxrm() Fails = %d\n",bs_rc);
        return(OM_E_ABORT);
      }

      p1 = &me->break_pt[3 * (*num_vertex - 2)];
      p2 = centerpt;

      dist = BSdistptpts( &bsrc,p1,p2);

      if(fabs(dist) < 1e-8)
      {
        if (*num_vertex <= 2)
        {
          status =
          om$send(msg = message DMroot.delete_dim_go( &rc,
                        			      DIM_LEADER,
                        			      md_env),
            	  targetid = my_id);
          dm$status(action = RET_STATUS);

          return(OM_S_SUCCESS);
        }

        p1 = &me->break_pt[3 * (*num_vertex - 3)];
        p2 = &me->break_pt[3 * (*num_vertex - 2)];
      }

      BSmkvec(&bsrc, lea_vec, p1, p2);
      BSnorvec(&bsrc, lea_vec);

      for( i = 0 ; i < 3 ; i++ )
      {
        lea_line[i] = p1[i] - 10000000 * lea_vec[i];
        lea_line[i + 3] = p2[i] + 10000000 * lea_vec[i];
      }

      bsp_curve1.poles = poles;
      bsp_curve1.knots = knots;
      bsp_curve1.weights = weights;

      num_pts = 2;

      status =
      BSlininter(&bsrc, &num_pts, lea_line, &bsp_curve1, norm);
      if( !status || bsrc != BSSUCC)
      {
              return(OM_E_ABORT);
      }

      status =
      BScvcv_int( &bsrc,
                  &bsp_curve1,
                  &bsp_curve2,
                  &nint,
                  &xintpt,
                  &xpar1,
                  &xpar2,
                  &nover,
                  &xendpt,
                  &xover1,
                  &xover2);

      if( !status || bsrc != BSSUCC || !nint)
      {
        req_pt = centerpt;
      }
      else if( nint == 1)
      {
        req_pt = &xintpt[0];
      }
      else
      {
        index=0;

        mdist = BSdistptpts(&bsrc, p1, xintpt);

        for( i = 1 ; i < nint; i++ )
        {
          dist = BSdistptpts(&bsrc, p1, &xintpt[i*3]);
          if(dist < mdist)
          {
            mdist = dist;
            index = i;
          }
        }
        req_pt = &xintpt[index*3];
      }

      for( index = 0 ; index < 3; index++)
        me->break_pt[3*(*num_vertex-1) + index] = req_pt[index];

      post_info.construct_flag = FALSE;

      status =
      om$send(msg = message GRvg.GRpostabsg(&long_rc,
                                            md_env,
                                            &post_info,
                                            (char *)&bsp_curve2,
                                            &bln_grid.objid),
              targetid = bln_grid.objid,
              targetos = bln_grid.osnum);
      dm$status( action = RET_STATUS);

    }
    else
    {

    p1 = &me->break_pt[3 * (*num_vertex - 2)];
    p2 = &me->break_pt[3 * (*num_vertex - 1)];

    DMlineptpt(p1, p2, lea_line);
    BSmkvec(&bsrc, lea_vec, p1, p2);
    BSnorvec(&bsrc, lea_vec);

    just_attr = (me->dim_type == TEXT_WITH_LEADER)?
            par_senv->an_posn:ANNOT_JUST_CENTER;

    extend = FALSE;

    if (just_attr == ANNOT_JUST_UNDER)
    {
        /*| ANNOT_JUST_UNDER */

	status=
        om$send( msg = message VDfrmtxt.VDgetAngle(&msg_rc,
                                                   &PlaceAngle),
                 targetid = my_id);
        as$status(action = RET_STATUS);

	for( i = 0; i<3; i++)
        {
          norm[i] = plan_info->win_plan.matrix[i+8];
        }

        MAgrotmx (&msg_rc,norm,original_p, &PlaceAngle,trans_matrix);
 
        for( i = 0 ; i < 3 ; i++)
        {
          rotate_matrix[i] = trans_matrix[i];
          rotate_matrix[i+3] = trans_matrix[i+4];
          rotate_matrix[i+6] = trans_matrix[i+8];
        }

	for( i = 0 ; i < 3 ; i++)
        {
          orie_vec[i] = plan_info->win_plan.matrix[i];
        }
        BSnorvec(&bs_rc, orie_vec);

        BSmult_mats(3, 3, rotate_matrix, FALSE, 3, 1,
                    orie_vec, FALSE,
                    req_dir, &bs_rc);

        BSnorvec(&rc,req_dir);

        dotp = fabs(BSdotp(&bsrc, req_dir, lea_vec));
        if (dotp > 0.9999998 && dotp < 1.0000001)
          extend = TRUE;
    }

    MATH_get_box_points(&rc, lbsys, box);

    descent_r = (font_info.descent * 2 * par_senv->txt_heig )/
                (font_info.bodysize - font_info.descent);

    vec_sub( &box[9],&box[0],box_orie);
    BSnorvec(&rc,box_orie);

    MATH_ptdelta(&rc,&box[0],box_orie,-descent_r,&box[0]);
    MATH_ptdelta(&rc,&box[3],box_orie,-descent_r,&box[3]);
    MATH_ptdelta(&rc,&box[6],box_orie, descent_r,&box[6]);
    MATH_ptdelta(&rc,&box[9],box_orie, descent_r,&box[9]);

    vec_sub( &box[3],&box[0],box_orie);
    BSnorvec(&rc,box_orie);

    MATH_ptdelta(&rc,&box[0],box_orie,-descent_r,&box[0]);
    MATH_ptdelta(&rc,&box[3],box_orie, descent_r,&box[3]);
    MATH_ptdelta(&rc,&box[6],box_orie, descent_r,&box[6]);
    MATH_ptdelta(&rc,&box[9],box_orie,-descent_r,&box[9]);

    if (extend)
    {
        /*| Extend line */

        MATH_line_extend(
            &rc,
            lea_line,
            lea_line + 3,
            box,
            p2);

        intersect = FALSE;
    }
    else
    {
        /*| Intersect Line */

        MATH_intersect_box_line(
            &rc,
            lea_line,
            box,
            intpt,
            &intersect,
            plan_info->win_plan.matrix);
    }

    /*"intersect :%d\n",intersect*/
    /*^print_point("lea vec:",lea_vec);*/
    if (intersect)
    {
      for( i = 0 ; i < 3 ; ++i )
      {
        p2[i] = intpt[i];
      }
    }
    /*^
        print_point(" prev point",p1);
        print_point(" last point",p2);
    */
    }

    return(OM_S_SUCCESS);
}


/*************************************************************************/
/*      METHOD VDsetAttribute                                            */
/*************************************************************************/
method VDsetAttribute(   IGRlong             *msg;
			 IGRlong 	     text_flag;
                         IGRchar             *attr_ptr )
{

        IGRint          sts = OM_S_SUCCESS ;    /* OMreturn code   */
	IGRdouble	PlaceAngle;
	IGRint		status;
	IGRint 		size;
	struct VDFrmtxt VD_frmtxt;

        SetProc( VDfrmtxt.VDsetAttribute ); Begin

        *msg    = MSSUCC ;
	
	switch(text_flag)
	{
		case TEXTANGLE:

		PlaceAngle = *(IGRdouble *)attr_ptr;
        	PlaceAngle = PlaceAngle * 3.1415926 / 180.0;
		VD_frmtxt.textAngle = PlaceAngle;
		break;

		case TEXTCAPS:

		VD_frmtxt.textCaps = 1;
		break;

		case TEXTCAPS_NO:

		VD_frmtxt.textCaps = 0;
		break;

                case TEXTMIRROR:

                VD_frmtxt.textMirror = 1;
		break;

		case TEXTMIRROR_NO:

                VD_frmtxt.textMirror = 0;
                break;

                case TEXTREVERSE:

                VD_frmtxt.textReverse = 1;
		break;

		case TEXTREVERSE_NO:

                VD_frmtxt.textReverse = 0;
                break;

		default:

		printf("VDfrmtxt.VDsetAttribute: Invalid flag %d\n", text_flag);
                return(OM_E_ABORT);

	};

	size = sizeof(struct VDFrmtxt);

	status =
        om$vla_set_dimension(varray = me->info, size = size);
        dm$status(action = RET_STATUS);

        memcpy(me->info, &VD_frmtxt, size);

        End;
        return sts ;
}

/*************************************************************************/
/*      METHOD VDgetAngle                                                */
/*************************************************************************/
method VDgetAngle(       IGRlong             *msg;
                         IGRdouble           *angle )
{

        IGRint          sts = OM_S_SUCCESS ;    /* OMreturn code   */
        IGRdouble       PlaceAngle;
        IGRint          vla_size;
	struct VDFrmtxt VD_frmtxt;

        SetProc( VDfrmtxt.VDgetAngle ); Begin

        vla_size = om$dimension_of(varray = me->info);
        if (!vla_size)
        {
		PlaceAngle = 0.0;
		*angle = PlaceAngle;
                return sts;
        }

        memcpy(&VD_frmtxt, me->info, sizeof(struct VDFrmtxt));
	PlaceAngle = VD_frmtxt.textAngle;
        *angle = PlaceAngle;

        memcpy(me->info, &VD_frmtxt, sizeof(struct VDFrmtxt));

        *msg    = MSSUCC ;

        End;
        return sts ;
}

/*************************************************************************/
/*      METHOD VDgetCapsFlag                                             */
/*************************************************************************/
method VDgetCapsFlag(    IGRlong             *msg;
                         IGRuchar            *caps_flag )
{

        IGRint          sts = OM_S_SUCCESS ;    /* OMreturn code   */
        IGRint          vla_size;
        struct VDFrmtxt VD_frmtxt;

        SetProc( VDfrmtxt.VDgetCapsFlag ); Begin

        vla_size = om$dimension_of(varray = me->info);
        if (!vla_size)
        {
                return (OM_E_ABORT);
        }

        memcpy(&VD_frmtxt, me->info, sizeof(struct VDFrmtxt));
        *caps_flag = VD_frmtxt.textCaps;

        memcpy(me->info, &VD_frmtxt, sizeof(struct VDFrmtxt));

        *msg    = MSSUCC ;

        End;
        return sts ;
}

/*************************************************************************/
/*      METHOD VDgetReverseFlag                                          */
/*************************************************************************/
method VDgetReverseFlag( IGRlong             *msg;
                         IGRuchar            *reverse_flag )
{

        IGRint          sts = OM_S_SUCCESS ;    /* OMreturn code   */
        IGRint          vla_size;
        struct VDFrmtxt VD_frmtxt;

        SetProc( VDfrmtxt.VDgetReverseFlag ); Begin

        vla_size = om$dimension_of(varray = me->info);
        if (!vla_size)
        {
                return (OM_E_ABORT);
        }

        memcpy(&VD_frmtxt, me->info, sizeof(struct VDFrmtxt));
        *reverse_flag = VD_frmtxt.textReverse;

        memcpy(me->info, &VD_frmtxt, sizeof(struct VDFrmtxt));

        *msg    = MSSUCC ;

        End;
        return sts ;
}

/*************************************************************************/
/*      METHOD VDgetMirrorFlag                                           */
/*************************************************************************/
method VDgetMirrorFlag( IGRlong             *msg;
                        IGRuchar            *mirror_flag )
{

        IGRint          sts = OM_S_SUCCESS ;    /* OMreturn code   */
        IGRint          vla_size;
        struct VDFrmtxt VD_frmtxt;

        SetProc( VDfrmtxt.VDgetMirrorFlag ); Begin

        vla_size = om$dimension_of(varray = me->info);
        if (!vla_size)
        {
                return (OM_E_ABORT);
        }

        memcpy(&VD_frmtxt, me->info, sizeof(struct VDFrmtxt));
        *mirror_flag = VD_frmtxt.textMirror;

        memcpy(me->info, &VD_frmtxt, sizeof(struct VDFrmtxt));

        *msg    = MSSUCC ;

        End;
        return sts ;
}

end implementation VDfrmtxt;

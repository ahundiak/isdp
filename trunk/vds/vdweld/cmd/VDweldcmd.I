/* $Id: VDweldcmd.I,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/cmd/VDweldcmd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDweldcmd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/02/11  18:51:14  pinnacle
# tr179801917.
#
# Revision 1.3  1999/02/10  15:18:44  pinnacle
# tr179801917
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/01/12  19:36:42  pinnacle
# Replaced: vdweld/cmd/VDweldcmd.I for:  by impd for vds
#
# Revision 1.6  1998/01/03  19:06:46  pinnacle
# Build Problem
#
# Revision 1.5  1997/12/31  18:12:52  pinnacle
# Replaced: vdweld/cmd/VDweldcmd.I for:  by jwfrosch for vds
#
# Revision 1.4  1997/12/19  15:54:06  pinnacle
# Replaced: vdweld/cmd/VDweldcmd.I for:  by impd for vds
#
# Revision 1.3  1997/12/09  16:22:18  pinnacle
# Replaced: vdweld/cmd/*.[IS] for:  by impd for vds
#
# Revision 1.2  1997/11/26  21:36:56  pinnacle
# Replaced: vdweld/cmd/VDweldcmd.I for:  by impd for vds
#
# Revision 1.1  1997/11/21  17:08:24  pinnacle
# Created: vdweld/cmd/VDweldcmd.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Override at VDS level of some COweld methods :
 *					init, execute, LC_selection, wakeup, delete, notify_form, display_form
 *					Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 *	01/03/97	ah		Added VDmsg.h
 *      02/09/99        ylong           tr179801917
 * -------------------------------------------------------------------*/

class implementation VDweld;

#define AS_DEBUG 1

/* STATE for weld command */

#define STATE_P_LOC_ELEMENT	1
#define STATE_P_GET_EVENT	2
#define STATE_P_BUTT_POINT	3
#define STATE_P_FILLET_EDGE1	4
#define STATE_P_FILLET_EDGE2	5
#define STATE_P_FILLET_SIZE	6

#include "dimdef.h"
#include "dim.h"
#include "form_env.h"
#include "dimformdef.h"
#include "dimform.h"
#include "dimgraph.h"
#include "weldform.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "bspt_on_lne.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

#define	VD_DEBUG  1
#include	<VDdebug.h>

#include "ACattrib.h"
#include "VDobj.h"

#include "vsattr.h"
#include "vsjoint.h"
#include "vsoptdef.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vdparmacros.h"
#include "vsAPIwelddef.h"

#include "VDmsg.h"
#include "VDweldsym.h"

extern IGRboolean 		BSproj1();

from NDnode  import NDs_compute_node, NDdelete;
from GRvg    import GRgenabsg, GRkeypoint, GRgetattr;
from DMannot import ANadd_delete_vertex;
from DMroot  import set_dim_state;
from DMweld  import set_cross_section;

extern GRclassid OPP_GR3dtext_class_id,
		 OPP_GRbspline_class_id,
		 OPP_GR3dpoint_class_id,
		 OPP_DMweld_class_id;

extern struct DMweld_param	frm_weld;
extern double atof();
extern double fabs();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldsym.I						*/
/* 	Used also in :								*/
/*		vdweld/imp/weldtxt.I						*/
/*		vdweld/cmd/VDweldcmd.I						*/
/*		vdweld/cmd/weldform.I						*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern int				VDS_is_active_environment;
extern int				weld_sym_initialized;

extern struct VDweld_gadget_sym		sym_char[];

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static void	VDupdate_symbol_form ( Form form, int num_sym_chars, int idx )
{
  int i0, sts;
  for ( i0=0; i0 < num_sym_chars; i0++ )
  {
    sts = FIg_set_symbol_index ( form, sym_char[i0].symbol, sym_char[i0].snr[idx] );
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDupdate_weld_parameters (struct GRid located_obj)
{
  IGRlong		long_rc,status;
  VSpartAttr		myAttr ;	/* My part attributes	*/
  VSjointAttr		joint ;		/* My joint attributes	*/
  int			i0, n0 = 0, side = 0,
			code = 0, info = 0, process = 0, weld_pos = 0, field_w = 0;
  double		allowance = 0., weldsize = 0., pitch = 0., incrLength = 0.;
  struct DMweld_param	par_weld;
  struct GRmd_env	locEnv;

#define NUM_WLD_ATTR	9

  struct ACrg_coll	att_weld[NUM_WLD_ATTR];

  /*
   * Retrieve attribute data from "VSsrcJoint" object and linear element along joint
   */
    
  __enterFunction ( name = "VDupdate_weld_parameters" );

if ( 0 )
{
  strcpy( att_weld[n0].name , "weldCode"     ); n0++;
  strcpy( att_weld[n0].name , "weldSide"     ); n0++;
  strcpy( att_weld[n0].name , "weldInfo"     ); n0++;
  strcpy( att_weld[n0].name , "weld_position"); n0++;
  strcpy( att_weld[n0].name , "field_weld"   ); n0++;

  strcpy( att_weld[n0].name , "allowance"    ); n0++;
  strcpy( att_weld[n0].name , "pitch"        ); n0++;
  strcpy( att_weld[n0].name , "lengthOfIncr" ); n0++;
  strcpy( att_weld[n0].name , "weld_size"    ); n0=0;

  status =
    vd$review_params(	pMsg		= &long_rc,
			pComponent	= &located_obj,
			NbParams	= NUM_WLD_ATTR,
			pList		= att_weld,
			pMdEnv		= &locEnv );

  code	        = att_weld[n0].desc.value.att_exp; n0++;
  side		= att_weld[n0].desc.value.att_exp; n0++;
  info		= att_weld[n0].desc.value.att_exp; n0++;
  weld_pos	= att_weld[n0].desc.value.att_exp; n0++;
  field_w	= att_weld[n0].desc.value.att_exp; n0++;

  allowance	= att_weld[n0].desc.value.att_exp; n0++;
  pitch		= att_weld[n0].desc.value.att_exp; n0++;
  incrLength	= att_weld[n0].desc.value.att_exp; n0++;
  weldsize	= att_weld[n0].desc.value.att_exp; n0=0;

  for( i0=0 ; i0 < NUM_WLD_ATTR ; i0++ )
  {
    __printf ("Name[%d] = <%s>, value = %lg", `i0, att_weld[i0].name, att_weld[i0].desc.value.att_exp` );
  }
}
else	// ALTERNATE (faster !!)
{
  memset ( &joint   , 0, sizeof (VSjointAttr) );	// INITIALIZE, otherwise GRgetattr does NOT work
  memset ( &par_weld, 0, sizeof (par_weld) );

  myAttr.specific = (void *) &joint ;		// joint.weldAttr: side, code, info, process
  myAttr.Iwant    = VS_m_WeldAttr | VS_m_Allowance |  VS_m_Size | VS_m_Pitch | VS_m_IncrLength;
  status = om$send (	msg	 = message GRvg.GRgetattr( &long_rc, (char *) &myAttr ),
			senderid = NULL_OBJID,
			targetid = located_obj.objid,
			targetos = located_obj.osnum) ;

  side		= joint.weldAttr.side;
  code	        = joint.weldAttr.code;
  info		= joint.weldAttr.info;
  weld_pos	= joint.addWldAttr.position;
  field_w	= joint.addWldAttr.fieldweld;

  allowance	= joint.allowance;
  weldsize	= joint.size;
  pitch		= joint.pitch;
  incrLength	= joint.incrLength;
}

  dm$get_dim_param (type = DM_WELD_PARAM, p_data = &par_weld);
  par_weld.atext.ftext[0] = '\0';			// ABOVE TEXT
  par_weld.atext.rtext[0] = '\0';			// ABOVE TEXT
  par_weld.atext.ztext[0] = '\0';			// ABOVE TEXT
  par_weld.btext.ftext[0] = '\0';			// BELOW TEXT
  par_weld.btext.rtext[0] = '\0';			// BELOW TEXT
  par_weld.btext.ztext[0] = '\0';			// BELOW TEXT

#define	MIN_PITCH_INCR	.001

  par_weld.above	= 1;
  par_weld.below	= 0;
  par_weld.center	= 0;
  par_weld.flag		= info % 2;			// Odd value ==>> Field Weld

  par_weld.circle	=((info & VS_WI_No_No_Wa) ||
			  (info & VS_WI_Fw_No_Wa) ||
			  (info & VS_WI_No_Mt_Wa)) ? 1 : 0 ;

  par_weld.z_symb	= ( (fabs(pitch) > MIN_PITCH_INCR ) & ( fabs(incrLength) > MIN_PITCH_INCR ) );
  
  /* tr179801917, change par_weld.atext.rtext to par_weld.atext.ftext */
  sprintf ( par_weld.atext.ftext, "%lg", weldsize );	// ABOVE TEXT
  par_weld.btext.ftext[0] = '\0';			// BELOW TEXT

  if ( fabs(pitch) > MIN_PITCH_INCR )
  {
    sprintf ( par_weld.atext.rtext, "%lgX%lg", weldsize, fabs(pitch) );
  }

  if ( par_weld.z_symb && fabs(incrLength) > MIN_PITCH_INCR )
  {
    sprintf ( par_weld.atext.ztext, "%lg", fabs(incrLength) );
  }

  if ( joint.weldAttr.side == 2 )
  {
    par_weld.below	= 1;
  }

  par_weld.atext.weld_symbol	= sym_char[code].bezel;
  par_weld.btext.weld_symbol	= sym_char[code].bezel;

  par_weld.atext.weld_type	= 11;
  par_weld.btext.weld_type	= 11;

  __printf ( "joint.weldAttr: side = %d, info = %d, code = %d, weld_position = %d, field_weld = %d",
	     `side, info, code, weld_pos, field_w` );
  __printf ( "weld_bezel_symbol = %d, par_weld.z_symb = %d", `sym_char[code].bezel, par_weld.z_symb` );
  __printf ( "allowance = %lg, weldsize = %lg, pitch = %lg, incrLength = %lg", `allowance, weldsize, pitch, incrLength` );

  dm$put_dim_param (type = DM_WELD_PARAM, p_data = (char *)&par_weld);

  __exitFunction ( name = "VDupdate_weld_parameters" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method init(int type; char *string_ptr)
{
  IGRint status;
  IGRint index;

  __enterMethod ( name = "init", argfmt = "VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  status = om$send (	msg	 = message COdim.init(type, string_ptr),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
  dm$status(action = RET_STATUS);

  me->weld_grid.objid = NULL_OBJID;
  me->prev_weld.objid = NULL_OBJID;
  me->state = STATE_P_LOC_ELEMENT;
  me->form_display = FALSE;
  me->above_input = TRUE;

  me->mask1 |= GRm_STRING;
  me->mask2 |= GRm_STRING;

  for (index=0; index < NO_TEXT_LEADER_ROOTS; index++)
  {
    me->list[index].objid = me->context[index].objid = NULL_OBJID;
  }

  /*"me->mytype=%d, type=%d\n", me->mytype, type*/

  /*|- Create Forms */

  status = om$send (	msg	 = message COdim.create_form (MAIN_FORM,"DMWeld", &me->form),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  status = om$send (	msg	 = message COdim.create_form (SUB_FORM1,"VDWeldSbAbov", &me->subform1),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  status = om$send (	msg	 = message COdim.create_form (SUB_FORM2,"VDWeldSbBlow", &me->subform2),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  status = om$send (	msg	 = message COdim.create_form (SUB_FORM3,"DMWeldSbCntr", &me->subform3),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  status = om$send (	msg	 = message COdim.create_form (SUB_FORM4,"DMWeldSub", &me->subform4),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  status = om$send (	msg	 = message COweld.init_type(),
			targetid = my_id);
  dm$status(action = RET_STATUS);

  ex$message(msgnumb = DM_I_StatFormAvForOpt);
  GRstatus_display_button(1);

  VDS_is_active_environment = 1;
  if ( VDcomment )		// For CLIX debugging / printing to backscreen
  {
    FIf_cvrt_to_perm_win (me->subform1);
    FIf_cvrt_to_perm_win (me->subform2);
    FIf_cvrt_to_perm_win (me->subform3);
    FIf_cvrt_to_perm_win (me->subform4);
  }

  weld_sym_initialized = 0;
  if ( ! weld_sym_initialized )
  {
    int	sts, num_sym_chars = 0;

    sts = VDread_weld_sym_char( &num_sym_chars );
    if ( 1 & sts && num_sym_chars )
    {
      weld_sym_initialized = 1;
      VDupdate_symbol_form ( me->subform1, num_sym_chars, 0 );
      VDupdate_symbol_form ( me->subform2, num_sym_chars, 1 );
    }
  }

  __exitMethod ( name = "init", argfmt = "VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method execute(int *response; char *response_data; int pos)
{
  IGRint status, rc, i, cs_type;
  IGRlong long_rc;
  IGRpoint point;
  IGRdouble weld_size;
  struct ret_struct ret_str;
  struct GRevent weld_event;

  __enterMethod ( name = "execute", argfmt = "VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  while(TRUE)
  {
    if ((me->event1.response == EX_SINIT) &&
	(me->weld_grid.objid != NULL_OBJID))
    {
      /*|- Erase the dimension, cmd restarted*/

      status =
	DMdisplay_dimension(
			    &rc,
			    ROOT | CHILDREN,
			    ERASE | REMWRNG,
			    &me->md_env,
			    &me->weld_grid);
      dm$status(action = RET_STATUS);
    }

    erase_label          ( me->form, TOGGLE_DASH_LINE);		// Never use dash_line ?!?!?!?

//  UI_message ( "Place VDS Weld Symbol" );			// Override of EMS message
    ex$message ( msgnumb = VD_M_PlWlSy );			// Override of EMS message

    switch(me->state)
    {
    /*************************/
    case STATE_P_LOC_ELEMENT:
    /*************************/
      {
	__prints ( ">>>>> case STATE_P_LOC_ELEMENT >>>>>" );
	
	status =
	  om$send(msg = message COdim.locate_parent(
						    response,
						    response_data,
						    &me->loc_event,
						    TRUE,
						    me->loc_key,
						    me->acc_key,
						    me->rel_key),
		  targetid = my_id);
	dm$status(action = RET_STATUS);
			
	if (me->locate_rc == LC_OBJ_LOCATED)
	    me->state = STATE_P_GET_EVENT;
	else if ((*response == D_RESET) 
		 && (me->prev_weld.objid != NULL_OBJID))
	{
	  me->weld_grid.objid = me->prev_weld.objid;

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   ERASE|REMWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  me->prev_weld.objid = NULL_OBJID;
	  me->state = STATE_P_GET_EVENT;
	}
	__prints ( "<<<<< case STATE_P_LOC_ELEMENT <<<<<" );
	break;
      }
    /********************/
    case STATE_P_GET_EVENT:
    /********************/
      {
	__prints ( ">>>>> case STATE_P_GET_EVENT >>>>>" );
	
	/*|- get event */

	status =
	  om$send(msg = message COweld.place_dimension(),
		  targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	  om$send(msg = message COweld.position_dim(
						    DM_P_PosBrkPtM,
						    TRUE,
						    NULL,
						    NULL,
						    MOVE_BREAK_PT,
						    NULL,
						    NULL),
		  targetid = my_id);
	dm$status(action=RET_STATUS);

	status =
	  om$send(msg = message COdim.getevent(
					       DM_P_PosBrkPtM,
					       response,
					       response_data,
					       &me->event1),
		  targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^printf("getevnt : data point:%lf:%lf:%lf\n",me->event1.event.button.x,
	  me->event1.event.button.y,
	  me->event1.event.button.z);*/
			
	if( *response == DATA)
	{
	  /*|- response is DATA */

	  status =
	    om$send(msg = message COweld.position_dim(
						      DM_P_PosBrkPtM,
						      FALSE,
						      NULL,
						      NULL,
						      MOVE_BREAK_PT,
						      NULL,
						      NULL),
		    targetid = my_id);
	  dm$status(action=RET_STATUS);
				
	  /*| - Add a vertex */

	  status = 
	    om$send(msg = message DMannot.ANadd_delete_vertex(
							      &rc,
							      ADD_VERTEX,
							      NULL,
							      &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action= RET_STATUS);
					
	  status =
	    om$send(msg = message COweld.set_dim_state(
						       DIM_IN_PLACEMENT |
						       DIM_NEEDS_UPDATE ),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);
	}
	else if(*response == D_RESET)
	{
	  /*| - response is D_RESET */

	  status = 
	    om$send(msg = message DMannot.ANadd_delete_vertex(
							      &rc,
							      DELETE_VERTEX,
							      NULL,
							      &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action= RET_STATUS);

	  if(!rc)	me->state = STATE_P_LOC_ELEMENT;
	}
	else if(*response == RESET)
	{
	  /*| - Delete Vertex  */

	  status = 
	    om$send(msg = message DMannot.ANadd_delete_vertex(
							      &rc,
							      DELETE_VERTEX,
							      NULL,
							      &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action= RET_STATUS);

	  status =
	    om$send(msg = message NDnode.NDs_compute_node(
							  &long_rc,
							  0,
							  &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   DISPLAY | ADDWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  if (frm_weld.cross_section)
	  {
	    if (frm_weld.above)
	    {
	      if (frm_weld.atext.weld_symbol != FILLET)
		me->state = STATE_P_BUTT_POINT;
	      else me->state = STATE_P_FILLET_EDGE1;
	    }
	    else
	    {
	      if (frm_weld.btext.weld_symbol != FILLET)
		me->state = STATE_P_BUTT_POINT;
	      else me->state = STATE_P_FILLET_EDGE1;
	    }
	  }
	  else
	  {
	    me->prev_weld.objid = me->weld_grid.objid;
	    me->weld_grid.objid = NULL_OBJID;
	    me->state = STATE_P_LOC_ELEMENT;
	  }
	}
	__prints ( "<<<<< case STATE_P_GET_EVENT <<<<<" );
	break;
      }
    case STATE_P_BUTT_POINT:
      {
	status =
	  om$send(msg = message COdim.getevent(
					       DM_P_IdButtPt,
					       response,
					       response_data,
					       &me->event1),
		  targetid = my_id);
	dm$status(action = RET_STATUS);

	/*^printf("getevnt : data point:%lf:%lf:%lf\n",me->event1.event.button.x,
	  me->event1.event.button.y,
	  me->event1.event.button.z);*/
			
	if (*response == DATA)
	{
	  status =
	    DMnode_give_structure(
				  &rc,
				  DIM_NO_INDEX,
				  ORIG_INFO,
				  FALSE,
				  me->list[AN_ROOT_ELEM1].objid,
				  me->weld_grid.objid,
				  me->list[AN_ROOT_ELEM1].osnum,
				  &me->md_env,
				  &ret_str);
	  dm$status(action = RET_STATUS);

	  status =
	    BSproj1(&rc,
		    &me->event1.event.button.x,
		    &me->plan_info.win_plan.matrix[8],
		    ret_str.var.point_st.pt,
		    point);
	  dm$status(action = RET_STATUS);

	  for (i=0; i<3; i++)
	    me->vector[i] = point[i] - ret_str.var.point_st.pt[i];
 
	  if (frm_weld.above)
	    cs_type = (frm_weld.atext.weld_symbol == VWELD) ? VWELD_CS:BEVEL_CS;
	  else
	    cs_type = (frm_weld.btext.weld_symbol == VWELD) ? VWELD_CS:BEVEL_CS;
	  
	  status =
	    om$send(msg = message DMweld.set_cross_section(
							   cs_type,
							   0.0,
							   me->vector),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   ERASE | REMWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message NDnode.NDs_compute_node(
							  &long_rc,
							  0,
							  &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   DISPLAY | ADDWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  me->prev_weld.objid = me->weld_grid.objid;

	  me->weld_grid.objid = NULL_OBJID;

	  me->state = STATE_P_LOC_ELEMENT;
	}

	break;
      }
    /*************************/
    case STATE_P_FILLET_EDGE1:
    /*************************/
      {
	/*|- Fillet Weld --> Locate edge 1*/

	status =
	  om$send(msg = message COdim.locate_parent(
						    response,
						    response_data,
						    &me->loc_event,
						    TRUE,
						    DM_P_IdFlEdge1,
						    DM_P_IdFlEdge2,
						    me->rel_key),
		  targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->locate_rc == LC_OBJ_LOCATED)
	  me->state = STATE_P_FILLET_EDGE2;

	break;
      }
    /*************************/
    case STATE_P_FILLET_EDGE2:
    /*************************/
      {
	/*|- Fillet Weld --> locate Edge 2*/

	weld_size = 0.0;

	if (frm_weld.above)
	  weld_size = atof(frm_weld.atext.ftext);

	if ((weld_size <= 0.0) && (frm_weld.below))
	  weld_size = atof(frm_weld.btext.ftext);

	status =
	  om$send(msg = message COdim.locate_parent(
						    response,
						    response_data,
						    &me->loc_event,
						    TRUE,
						    DM_P_IdFlEdge2,
						    (weld_size > 0.0)?
						    DM_P_Ac:DM_P_KeFlWlSz,
						    me->rel_key),
		  targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->locate_rc == LC_OBJ_LOCATED)
	{
	  /*|- Object located */

	  if (weld_size > 0.0)
	  {
	    /*|- Weld Size present place weld */
					
	    status =
	      om$send(msg = message DMweld.set_cross_section(
							     FILLET_CS,
							     weld_size,
							     me->vector),
		      targetid = me->weld_grid.objid,
		      targetos = me->weld_grid.osnum);
	    dm$status(action = RET_STATUS);

	    status =
	      om$send(msg = message COweld.display_dimension(
							     ROOT,
							     ERASE | REMWRNG),
		      targetid = my_id);
	    dm$status(action = RET_STATUS);

	    status =
	      om$send(msg = message NDnode.NDs_compute_node(
							    &long_rc,
							    0,
							    &me->dyn_env),
		      targetid = me->weld_grid.objid,
		      targetos = me->weld_grid.osnum);
	    dm$status(action = RET_STATUS);

	    status =
	      om$send(msg = message COweld.display_dimension(
							     ROOT,
							     DISPLAY | ADDWRNG),
		      targetid = my_id);
	    dm$status(action = RET_STATUS);

	    me->prev_weld.objid = me->weld_grid.objid;
	
	    me->weld_grid.objid = NULL_OBJID;
	
	    me->state = STATE_P_LOC_ELEMENT;
	  }
	  else me->state = STATE_P_FILLET_SIZE;
	}
	break;
      }
    /*************************/
    case STATE_P_FILLET_SIZE:
    /*************************/
      {
	/*|- Get Fillet weld Size */

	status =
	  co$getevent(
		      msg = &rc,
		      event_mask = GRm_VALUE,
		      value_type = GRIO_DISTANCE,
		      msgnum = DM_P_KeFlWlSz,
		      response = response,
		      response_data = response_data,
		      event = &weld_event);

	if (weld_event.response == EX_VALUE)
	{
	  status =
	    om$send(msg = message DMweld.set_cross_section(
							   FILLET_CS,
							   weld_event.event.value,
							   me->vector),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   ERASE | REMWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message NDnode.NDs_compute_node(
							  &long_rc,
							  0,
							  &me->dyn_env),
		    targetid = me->weld_grid.objid,
		    targetos = me->weld_grid.osnum);
	  dm$status(action = RET_STATUS);

	  status =
	    om$send(msg = message COweld.display_dimension(
							   ROOT,
							   DISPLAY | ADDWRNG),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);

	  me->prev_weld.objid = me->weld_grid.objid;

	  me->weld_grid.objid = NULL_OBJID;

	  me->state = STATE_P_LOC_ELEMENT;
	}
	break;
      }
    /******/
    default:
    /******/
      {
	printf("COweld: Unknown state %d\n", me->state);
	*response = TERMINATE;
	goto quit;
      }
    }

    switch (*response)
    {
    case DATA:
    case RESET:
    case D_RESET:
    case MOVE_ON:
    case STRING:
      {
	break;
      }
    case TERMINATE:
      {
	if (me->weld_grid.objid != NULL_OBJID)
	{
	  status =
	    om$send(msg = message COweld.delete_dimension(),
		    targetid = my_id);
	  dm$status(action = RET_STATUS);
	}
	goto quit;
      }
    case STATUS_DISP:
      {
	status = 
	  om$send(msg = message VDweld.display_form(),
		  targetid = my_id);
	dm$status(action = RET_STATUS);
	break;
      }
    case EX_CMD_KEY:
    case CMD_STRING:
      {
	goto quit;

      }
    default:
      {
	goto quit;
      }
    }
  }

quit:
  VDS_is_active_environment = 0;
  __exitMethod ( name = "execute", argfmt = "*response = %d, VDS_is_active_environment = %d",
		 args = `*response, VDS_is_active_environment` );
  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
  struct IGRbsp_curve *bsp_curve;
  IGRlong	long_rc,status ;
  OMuword	cls_id  = 0,
		cls_id1 = 0;
  static int	jnt_cnt = 0;

  *msg = OM_S_SUCCESS;

  __enterMethod ( name = "LC_selection" );

  if (VDcomment)
  {
    char	cls_nm[DI_PATH_MAX];
    om$get_classname (	osnum = lc_info->located_obj.osnum,
			objid = lc_info->located_obj.objid,
			classname	= cls_nm );

    __printf ( "lc_info->located_obj = [%d,%d], classname = <%s>",
	       `lc_info->located_obj.osnum, lc_info->located_obj.objid, cls_nm` );
  }

/* tr179801917, Begin */

  /*
   * Check if the object is for drawing ("VDdrawing", "VDdrw2d")
   * If valid, check the parent class against the VSjoint.
   */
  
  om$get_classid ( classname = "VDdrawing", p_classid = &cls_id );
  om$get_classid ( classname = "VDdrw2d",   p_classid = &cls_id1 );

  if ( cls_id  && DMancestry_valid (lc_info->located_obj,  cls_id ) ||
       cls_id1 && DMancestry_valid (lc_info->located_obj,  cls_id1) ){

     struct GRid	pObject;

    /*
     * get parent object of drawing.
     */
    pObject.objid = NULL_OBJID ;

    vdobj$GetParent(	objID    = &lc_info->located_obj,
                        idx      = 0,
			parentID = &pObject );
    
   if( pObject.objid != NULL_OBJID ){

     lc_info->located_obj = pObject ;

     if (VDcomment)
     {
      char	cls_nm[DI_PATH_MAX];
      om$get_classname (osnum     = lc_info->located_obj.osnum,
			objid     = lc_info->located_obj.objid,
			classname = cls_nm );

      __printf ( "lc_info->located_obj = [%d,%d], classname = <%s>",
	       `lc_info->located_obj.osnum, lc_info->located_obj.objid, cls_nm` );
     }
    } /* if pObject != NULL_OBJID  */
  }
/* tr179801917, End */

  om$get_classid ( classname = "VSjoint", p_classid = &cls_id );

  if ( cls_id && DMancestry_valid (lc_info->located_obj,  cls_id ) )
  {
    VDupdate_weld_parameters (lc_info->located_obj);

    if ( me->form_display )
    {
      status = 
	om$send (	msg	 = message VDweld.display_form(),
			targetid = my_id);
    }

    erase_label ( me->form, TOGGLE_DASH_LINE);		// Never use dash_line ?!?!?!?

    *msg = OM_S_SUCCESS;
    jnt_cnt = 1;
  }

  if ( jnt_cnt && ( *msg = DMancestry_valid (lc_info->located_obj, OPP_GRbspline_class_id) ) )
  {
    jnt_cnt = 0;
  }
  else
  {
    *msg = 0;
    goto quit;
  }

  /* - Linear element is required for weld symbol with cross_section- */

  *msg = DMancestry_valid (lc_info->located_obj, OPP_GRbspline_class_id);

  if (*msg && (frm_weld.cross_section
	       || (me->state == STATE_P_FILLET_EDGE1)
	       || (me->state == STATE_P_FILLET_EDGE2)))
  {
    status =
      om$send(msg = message GRvg.GRgenabsg(
					   &long_rc,
					   &lc_info->module_info.md_env.matrix_type,
					   lc_info->module_info.md_env.matrix,
					   (char **)&bsp_curve),
	      targetid = lc_info->located_obj.objid,
	      targetos = lc_info->located_obj.osnum);
    dm$status(action = RET_STATUS);
	
    /*"order=%d, nump=%d\n", bsp_curve->order, bsp_curve->num_poles*/

    *msg = (bsp_curve->order == 2);
    *msg = ! DMancestry_valid (lc_info->located_obj, OPP_GR3dpoint_class_id);

    __exitMethod ( name = "LC_selection" );

    return(TRUE);
  }

  if (DMancestry_valid (lc_info->located_obj, OPP_GR3dtext_class_id))    *msg= TRUE;

quit:

  __exitMethod ( name = "LC_selection" );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method wakeup(int pos)
{
  IGRint status;

  __enterMethod ( name = "wakeup", argfmt = ">>>>>>>>>> VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  VDS_is_active_environment = 1;

  status =
    om$send (	msg	 = message COweld.wakeup(pos),
		mode	 = OM_e_wrt_message,
		targetid = my_id);
  dm$status(action = RET_STATUS);

  __exitMethod ( name = "wakeup", argfmt = "<<<<<<<<<< VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  return( OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method delete(int f_defer_flag)
{
  IGRint status;

  __enterMethod ( name = "delete", argfmt = ">>>>>>>>>> VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  VDS_is_active_environment = 0;

  status =
    om$send (	msg	 = message COweld.delete(f_defer_flag),
		mode	 = OM_e_wrt_message,
		targetid = my_id);
  dm$status(action = RET_STATUS);

  __exitMethod ( name = "delete", argfmt = "<<<<<<<<<< VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
  IGRint status;
  IGRboolean save_data, ignore_data;
  struct DMweld_param par_weld;

  __enterMethod ( name = "notify_form", argfmt = ">>>>>>>>>> VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  VDS_is_active_environment = 1;

  dm$get_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

  status =
    VDprocess_weld_form(			// REPLACES : DMprocess_weld_form
			form_label,
			label,
			value,
			me->form,
			me->subform1,
			me->subform2,
			me->subform3,
			me->subform4,
			(me->weld_grid.objid == NULL_OBJID),
			&me->above_input,
			&me->form_display,
			FALSE,
			FALSE,
			&save_data,
			&ignore_data,
			&par_weld);
  dm$status(action = RET_STATUS);

  if (save_data)
  {
    dm$put_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

    if (me->weld_grid.objid != NULL_OBJID)
    {
      status =
	om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_NEEDS_UPDATE),
		senderid = NULL_OBJID,
		targetid = me->weld_grid.objid,
		targetos = me->weld_grid.osnum);
      dm$status(action = RET_STATUS);
    }
  }

  __exitMethod ( name = "notify_form", argfmt = "<<<<<<<<<< VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method display_form()
{
  IGRint status;
  IGRboolean save_data, ignore_data;
  struct DMweld_param par_weld;

  __enterMethod ( name = "display_form", argfmt = ">>>>>>>>>> VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  VDS_is_active_environment = 1;

  dm$get_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

  status =
    VDprocess_weld_form(			// REPLACES : DMprocess_weld_form
			0,
			0,
			0.0,
			me->form,
			me->subform1,
			me->subform2,
			me->subform3,
			me->subform4,
			(me->weld_grid.objid == NULL_OBJID),
			&me->above_input,
			&me->form_display,
			TRUE,
			FALSE,
			&save_data,
			&ignore_data,
			&par_weld);
  dm$status(action = RET_STATUS);

  __exitMethod ( name = "display_form", argfmt = "<<<<<<<<<< VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDweld;

/*
$Author: cvs $
$Revision: 1.1.1.1 $
$Date: 2001/01/04 21:07:40 $
$Locker:  $
$Log: anplace.I,v $
Revision 1.1.1.1  2001/01/04 21:07:40  cvs
Initial import to CVS

# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/04/25  19:10:04  pinnacle
# Replaced: vdannot/dim/anplace.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/30  15:14:06  pinnacle
# Replaced: vdannot/dim/anplace.I for:  by azuurhou for vds.240
#
# Revision 1.3  1996/05/07  22:34:40  pinnacle
# Replaced: vdannot/dim/anplace.I for:  by v240_int for vds.240
#
# Revision 1.2  1996/05/07  21:58:18  pinnacle
# Replaced: vdannot/dim/anplace.I for:  by yzhu for vds.240
#
# Revision 1.1  1996/01/10  14:54:50  pinnacle
# Created: vdannot/dim/anplace.I by jwfrosch for vds.240
#
# Revision 320.4  1995/04/17  07:19:36  gvk
# COMMENT : Corrected argument mismath problem for annotations.
#
# Revision 320.3  1995/03/16  09:36:30  gvk
# COMMENT : Clear active layer and replace it with actual layer
#
# Revision 320.2  1995/01/31  12:02:26  samuel
# COMMENT : Fix for correct prompt seq for add leader line command
#
# Revision 320.1  1994/12/20  05:14:47  krish
# COMMENT : Assembly changes from 4.0 RCS
#
# Revision 400.2  1994/05/15  10:01:59  krish
# COMMENT : Fix for assemblies and purify fix from GRNUC
#
# Revision 240.7  1993/08/16  13:35:49  mike
# COMMENT : Hilite the Status Display Button.
#
# Revision 240.6  1993/06/02  20:46:23  grnuc20
# COMMENT : Removed reference to ms.h for build fix - JSD
#
# Revision 240.5  1993/05/19  07:07:38  laxmi
# COMMENT : Checking in Dimensioning TR fixes -Laxmi 19 may 1993.
#
# Revision 220.2  1992/12/27  19:27:58  gvk
# COMMENT : Prompts changed for Leader line command.
#
Revision 201.18  1992/07/23  19:53:40  doree
COMMENT : message subsystem compliance

Revision 201.17  1992/06/30  06:42:56  laxmi
COMMENT : Source code changed to comply with ANSI compilation.

Revision 201.16  1992/04/03  16:35:40  mike
COMMENT : TR92N3819: Erase the subform to the status form for Place Feature Control Frame when the command goes to sleep.

Revision 201.15  1992/02/14  15:26:52  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 14 Feb. '92

Revision 201.14  1992/02/03  13:00:19  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.13  1992/01/28  10:37:24  dimdp20
COMMENT : Dimension Fixes Checkin - S. Poovannan - Jan 28 1992

*/
/* ************************************************************************
 *
 * History:
 *	MM/DD/YY     AUTHOR	DESCRIPTION
 *	05/07/96     yzhu      add the check for class VDCmdAutxt in 
 *                             init and wakeup method:
 *	05/30/96	adz	new version from EMS.
	
****************************************************************************/

class implementation COanplace;

#define AS_DEBUG 1
#include <string.h>
#include "version.h"
#include "OMminimum.h"
#include "form_env.h"
#include "dimformdef.h"
#include "dimform.h"
#include "dimgraph.h"
#include "ciexecmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "grmessage.h"

#define VD_DEBUG

#include "VDdebug.h"

from ci     import exec_fun;
from NDnode import NDs_compute_node, NDdelete, ASreturn_go;
from GRvg   import GRgenabsg;
from DMannot import ANadd_delete_vertex, get_edit_attr;
from DMroot import DMplace,replace_text;
from DMroot import set_dim_state;
from DMroot import return_dim_go;
from GRtext import GRgettxattr;
from DMroot import remove_from_cpx,get_dimension_plane;
from DMsrc import DMmodify, DMdisplay_source;
from DMsuper import create_dim_param;
from DMtxbln import get_active_balloon;
from DMframe import get_profile_type,set_profile_type;

extern GRclassid OPP_GR3dtext_class_id,
		 OPP_GRbspline_class_id,
		 OPP_GR3dpoint_class_id;


extern INGR_S_PRODUCT_DEF MODEL_appl_version_id;

#define BLN_ATTR_TXT	48
#define GAD_BLN_ATTR	47
#define PATH_MAX        256

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* HF: 04/22/97		KLUDGE
/* The purpose of the following 2 'static' declarations and also the function :
/* VD_test_MODEL_version() is solely to differentiate between the external
/* variables : extern IGRchar my_term_type; as required by I/EMS 3.3 and later
/*    and    : extern IGRchar    term_type; as required by I/EMS 3.2 and before
/* at runtime, so that the same I/VDS version can be used with either version of
/* I/EMS without the problem of an undefined symbol at startup of I/VDS etc., p.e.
/* (%DLOAD-E-UNRESOLV, File not loaded due to 1 unresolved symbols: _my_term_type)
/*
/* Which one of two variables is to be used as external is determined at runtime
/* in methods 'init' & 'delete' by the return value of the function call :
/* if ( VD_test_MODEL_version() == 1 )	==>> extern IGRchar my_term_type;
/* else					==>> extern IGRchar    term_type;
/*
/* Remark: Maybe (?) this will cause multiply defined symbols when building an
/* integrated Model_Vds... executable on Intel/Solaris (for debug purposes).
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static IGRchar my_term_type;
static IGRchar term_type;

int VD_test_MODEL_version()
{
  char	appl[20], vers[20], date[20], *cr;
  int	major=0, minor=0, tst=0;

  __enterFunction ( name = "VD_test_MODEL_version" );

  __printf ("version = <%s>", `MODEL_appl_version_id.curr_version` );
  sscanf (MODEL_appl_version_id.curr_version, "%s %s %s", appl, vers, date );

//  printf ("appl = <%s>, vers = <%s>, date = <%s>\n",appl, vers, date );
  sscanf (vers, "%d", &major );

  __printf ("major = %d", major );
  cr = strstr (vers, ".");
  cr++;

  sscanf (cr, "%d", &minor );
  __printf ("minor = %d", minor );

  if ( major > 3 || (major == 3 && minor >= 3 ) )
  {
    tst = 1;
  }
  __exitFunction ( name = "VD_test_MODEL_version" );

  return tst;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method get_dim_param()
{
	IGRint status;

	status =
	dm$get_dim_param(type = DM_SENV_PARAM, 
		p_grid = &me->list[DIM_ROOT_SENV]);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(type = DM_MISC_PARAM, 
		p_data = (char *)&me->dyn_info.info.par_misc);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dim_plane()
{
	IGRint status;
	struct GRid win_grid;


	win_grid.objid = me->loc_event.event.button.objid;
	win_grid.osnum = me->loc_event.event.button.osnum;

	status =
	dm$get_dim_plane(win_grid = win_grid,
			md_env = &me->md_env,
			p_grid = &me->list[DIM_ROOT_PLAN]);
	dm$status(action = RET_STATUS);

	status =
	dm$get_plan_info(
		plan_objid = me->list[DIM_ROOT_PLAN].objid,
		osnum = me->list[DIM_ROOT_PLAN].osnum,
		md_env = &me->md_env,
		plan_info = &me->plan_info);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method init(int type; char *string_ptr)
{
	IGRint status;
	IGRint index;
	struct DMsenv_param par_senv;

	dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);

	if ( VD_test_MODEL_version() )
	{
	  extern IGRchar my_term_type;

	  my_term_type = par_senv.ter_type;
	}
	else
	{
	  extern IGRchar term_type;

	  term_type = par_senv.ter_type;
	}

	/** Unless I get the place where the par_env is initialized, this will 
	have to do. **/ 

	if (par_senv.attach_pt != ON_EDGE && par_senv.attach_pt != INSIDE_OBJECT)
		par_senv.attach_pt = ON_EDGE;
	if (par_senv.stk_orie != HORIZ_STK && par_senv.stk_orie != VERT_STK)
		par_senv.stk_orie = HORIZ_STK;
	if (par_senv.stk_dir != DEFAULT_DIR && par_senv.stk_dir != REVERSE_DIR)
		par_senv.stk_dir = DEFAULT_DIR;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->an_grid.objid = NULL_OBJID;
	me->prev_dim.objid = NULL_OBJID;
	me->leader = TRUE;
	me->an_type = me->mytype;
	me->state = STATE_P_LOC_ARROW_ELT;
	me->subform = NULL;

	me->mask1 |= GRm_STRING;
	me->mask2 |= GRm_STRING;


	for (index=0; index < me->count; index++)
	{
		me->list[index].objid =
		me->context[index].objid = NULL_OBJID;
	}

	/*"me->mytype=%d, type=%d\n", me->mytype, type*/

	/* | set text parameters*/

	me->dyn_info.info.text_string = (unsigned char *) om$malloc (size = 1024);
	if (me->dyn_info.info.text_string == NULL) return(OM_E_ABORT);

	me->dyn_info.info.text_buff_size = 1024;
	me->dyn_info.info.text_length = 0;
	me->dyn_info.info.text_string[0] = '\0';
	me->dyn_info.info.gtattr.fraction_flag = 0;

	switch (me->mytype)
	{
		case TEXT_WITH_LEADER:

		status =
		om$send(msg = message COdim.create_form(0, "DMPlTxtLead",
							&me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case LEADER_LINE:

		status =
		om$send(msg = message COdim.create_form(0, "DMSubTerm", 
							&me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case TEXT_WITH_BALLOON:

		status =
		om$send(msg = message COdim.create_form(0,"DMPlBalloon",
							&me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

  		case FEATURE_CONTROL_FRAME:
  		status =
  		om$send(msg = message COdim.create_form(MAIN_FORM,"DMFtCt",
  							&me->form),
  			targetid = my_id);
  		dm$status(action = RET_STATUS);

  		status =
  		om$send(msg = message COdim.create_form(SUB_FORM,"DMFtCtSb",
  							&me->subform),
  			targetid = my_id);
  		dm$status(action = RET_STATUS);
		/* - needs to fill only one during the init*/
		me->tol_sym = POSITION;
  		break;

  		case DATUM_FRAME:
		me->form = NULL;
		break;

		default:
		printf("Illegal message key:%ld\n",me->mytype);
		break;
	}

	if(me->an_type != DATUM_FRAME)
        {
          char  classname[PATH_MAX];

          classname[0] = '\0';
          om$get_classname ( objid = my_id, classname = classname );
          if ( strcmp ( classname, "VDCmdAutxt" ) != 0 )
          {
            GRstatus_display_button(1);
            ex$message(msgnumb = DM_I_StatFormAvForOpt);
          }
        }

	status =
	om$send(msg = message COanplace.init_type(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	dm$put_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);
	return(OM_S_SUCCESS);
}

method init_type()
{
	int symbol_num;
	extern GRclassid
		OPP_DMtxldr_class_id,
		OPP_DMleader_class_id,
		OPP_DMtxbln_class_id,
		OPP_DMframe_class_id;

	me->an_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->an_attr.dim_type  = me->mytype;

	switch (me->mytype)
	{
		case TEXT_WITH_LEADER:

		me->msgnumb = DMC_M_DMPTxLd;
		me->an_classid = OPP_DMtxldr_class_id;
		me->loc_key = DM_P_LocElforLd;
		me->acc_key = DM_P_LocTxBrkPt;
		me->rel_key = DM_E_EltNotFound;
		me->count = NO_TEXT_LEADER_ROOTS;
		me->arrow_index = AN_ROOT_ELEM1;
		break;

		case LEADER_LINE:

		me->msgnumb = DMC_M_DMAdLdLn;
		me->an_classid = OPP_DMleader_class_id;
		me->loc_key = DM_P_LocRunLdFr;
		me->acc_key = DM_P_ErArLoc;
		me->rel_key = DM_E_EltNotFound;
		me->count = NO_LEADER_ROOTS;
		me->arrow_index = AN_ROOT_ELEM1;
		me->lead_index = AN_ROOT_ELEM2;
		break;

		case TEXT_WITH_BALLOON:

		me->msgnumb = DMC_M_DMPLdTxBl;
		me->an_classid = OPP_DMtxbln_class_id;
		me->loc_key = DM_P_LocElAthBl; /* DM_P_LocElLd ; */
		me->acc_key = DM_P_LocTxBrkPt;
		me->rel_key = DM_E_EltNotFound;
		me->count = NO_TEXT_LEADER_ROOTS;
		me->arrow_index = AN_ROOT_ELEM1;
		break;

  		case FEATURE_CONTROL_FRAME:
  		me->msgnumb = DMC_M_DMPFtCnFr;
  		me->an_classid = OPP_DMframe_class_id;
  		me->loc_key = DM_P_LocElLd;
  		me->acc_key = DM_P_PosBrkTx;
  		me->rel_key = DM_E_EltNotFound;
  		me->count = NO_TEXT_LEADER_ROOTS;
  		me->arrow_index = AN_ROOT_ELEM1;
		me->an_attr.dual_mode = 0;
  		me->dyn_info.info.gtattr.sep_symbol = 'l';
		ANget_tol_symbol(
			me->tol_sym,
			&symbol_num,
			&me->dyn_info.info.gtattr,
			me->subform);
  		break;
 
  		case DATUM_FRAME:
  		me->msgnumb = DMC_M_DMPDtFr;
  		me->an_classid = OPP_DMframe_class_id;
  		me->loc_key = DM_P_LocElLd;
  		me->acc_key = DM_P_PosBrkTx;
  		me->rel_key = DM_E_EltNotFound;
  		me->count = NO_TEXT_LEADER_ROOTS;
  		me->arrow_index = AN_ROOT_ELEM1;
		me->an_attr.dual_mode = 0;
  		me->dyn_info.info.gtattr.sep_symbol = 'l';
		break;

		default:
		printf("Illegal message key:%ld\n",me->mytype);
		break;
	}

	return(OM_S_SUCCESS);
}
method sleep(int pos)
{
	IGRint status, displayed;

	status =
	om$send(msg = message COdim.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->form_display)
	{
		/* erase the subform first, if it is displayed */
		if (me->subform)
		{
	                status = FIf_is_displayed(me->subform, &displayed);
			if ((status == FI_SUCCESS) && displayed)
                        {
				FIf_erase(me->subform);
                        }
                }

		status = FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_erase fails*/
			return(OM_E_ABORT);
		}
	}

        ex$message(msgnumb = GR_I_Clear);
        GRstatus_display_button(0);

	return(OM_S_SUCCESS);
}
 
method wakeup(int pos)
{
	IGRint status;
	IGRboolean set_inq;
	IGRlong msg;

	status =
	om$send(msg = message COdim.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->form_display)
	{
		me->form_display = FALSE;
		status = 
		om$send(msg = message COanplace.display_form(),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if(me->an_type != DATUM_FRAME)
        {
          char  classname[PATH_MAX];

          /*
           * Do NOT highlight the option button TR179601331
           */
          classname[0] = '\0';
          om$get_classname ( objid = my_id, classname = classname );

          if ( strcmp ( classname, "VDCmdAutxt" ) != 0 )
          {
            GRstatus_display_button(1);
            ex$message(msgnumb = DM_I_StatFormAvForOpt);
          }
        }

	set_inq = 1;
    	DPdynflags(&msg,&set_inq,&me->dynamics_on,NULL);

	return( OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc;
	IGRint msgkey,control;
	struct DMsenv_param par_senv;
 

	while(TRUE)
	{
		if ((me->event1.response == EX_SINIT) &&
			(me->an_grid.objid != NULL_OBJID))
		{
			/*|- Erase the dimension, cmd restarted*/

			status =
			DMdisplay_dimension(
				&rc,
				ROOT | CHILDREN,
				ERASE | REMWRNG,
				&me->md_env,
				&me->an_grid);
			dm$status(action = RET_STATUS);
		}

		switch(me->state)
		{
			/*************************/
			case STATE_P_LOC_ARROW_ELT:
			/*************************/

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
			
    		dm$get_dim_param(type = DM_SENV_PARAM, 
                             p_data = (char *)&par_senv);
	
			if (me->locate_rc == LC_OBJ_LOCATED )
			{
				me->data_event = me->loc_event;

			        me->state = (me->an_type == LEADER_LINE)?
			   		STATE_P_POS_ARROW:STATE_P_GET_EVNT;

				/** If the attach_Pt in inside_object, ignore the dynamics
				routine after the locate object, process the next data event
				create the annotation object, and then start the dynamics 
				routine**/

				if (me->an_type == TEXT_WITH_BALLOON &&
                                    par_senv.attach_pt == INSIDE_OBJECT)
            	{
                	if (me->an_grid.objid != NULL_OBJID)
                	{
                		struct GRid newgrid,new2grid,go_grid;
                		struct GRmd_env mod_info;
                		IGRmatrix matrix;
                		IGRshort matrix_type;

                		om$get_objid_at_index(
                                objid = me->an_grid.objid,
                                osnum = me->an_grid.osnum,
                                p_chanselect = &ND_father,
                                index = 2,
                                objidaddr = &newgrid.objid,
                                osnumaddr = &newgrid.osnum);

                 		om$get_objid_at_index(
                                objid = newgrid.objid,
                                osnum = newgrid.osnum,
                                p_chanselect = &ND_father,
                                index = 0,
                                objidaddr = &new2grid.objid,
                                osnumaddr = &new2grid.osnum);

                		status = om$send( msg = message NDnode.ASreturn_go(
															&go_grid,
                   								             &matrix_type,
                   								             matrix),
                   					        targetid = new2grid.objid,
                   					        targetos = new2grid.osnum);

                		if( !(status &1) || (! (om$is_objid_valid(
                       				         osnum= new2grid.osnum,
                       				         objid = new2grid.objid) ) ) )
                		{
                       			DMget_module_info(&mod_info);
                       		 	status =
                       		 	om$send(msg = message NDnode.NDdelete(
															&mod_info),
                       		              targetid = me->an_grid.objid,
                       		              targetos = me->an_grid.osnum);
                       		 	dm$status(action = RET_STATUS);

                       		 	me->an_grid.objid= NULL_OBJID;
                		}
                	}

					if (me->an_grid.objid == NULL_OBJID)
					{
						status =
            			om$send(msg = message COanplace.place_dimension(),
                				targetid = my_id);
            			dm$status(action = RET_STATUS);

						status =
        				om$send(msg = message COanplace.set_dim_state(
                    					DIM_IN_PLACEMENT |
                    					DIM_NEEDS_UPDATE),
            					targetid = my_id);
        				dm$status(action = RET_STATUS);
					 }


					me->state = STATE_P_POS_ARROW;
					status =
            		om$send(msg = message COdim.getevent(DM_P_ErArLoc,
                   			        response,
                            		response_data,
                            		&me->event1),
                			targetid = my_id);
            		dm$status(action = RET_STATUS);
 
            		if(*response == DATA)
            		{
                		status =
                		om$send(msg = message COanplace.connect_leader(&me->event1),
                    			targetid = my_id);
                		dm$status(action=RET_STATUS);
            		}

					me->state = STATE_P_GET_EVNT;
				}
			}
			else if( *response == RESET && me->an_type != LEADER_LINE )
			{

				if( me->an_type == FEATURE_CONTROL_FRAME &&
				    ( me->tol_sym == PROFILE_SURFACE_TOT))
				{
					ex$message(msgnumb = DM_E_InvTol);
					break;
				}

				if (me->an_type != TEXT_WITH_BALLOON)
					me->leader = FALSE;

				if(me->an_type == TEXT_WITH_LEADER)
					me->loc_key = DM_P_LocElAthTx;
				else if(me->an_type == TEXT_WITH_BALLOON)
					me->loc_key = DM_P_LocElAthBl;
				else	me->loc_key = DM_P_LocElFr;	/* GT or DT*/
			}
			else if(*response == D_RESET && me->an_type != LEADER_LINE)
			{
				if( me->prev_dim.objid != NULL_OBJID)
				{
					status = 
					om$send(msg = message COanplace.get_prev_dim_data(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
					me->prev_dim.objid = NULL_OBJID;
					me->state = STATE_P_GET_EVNT;
				}
				else
				{
					if (me->an_type != TEXT_WITH_BALLOON)
						me->leader = TRUE;

					status = 
					om$send( msg = message COanplace.init_type(),
						targetid= my_id);
					dm$status(action = RET_STATUS);
				}
			}
			break;

			/*********************/
			case STATE_P_POS_ARROW:
			/*********************/

			status =
			om$send(msg = message COdim.getevent(DM_P_ErArLoc,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			
			if(*response == DATA)
			{
				status =
				om$send(msg = message COanplace.connect_leader(&me->event1),
					targetid = my_id);
				dm$status(action=RET_STATUS);
				
				me->state = STATE_P_LOC_LEAD_ELT;

			}
			else if( *response == D_RESET  || *response == RESET)
			{
				me->state = STATE_P_LOC_ARROW_ELT;
			}
			break;
			
			/************************/
			case STATE_P_LOC_LEAD_ELT:
			/************************/

			/*| Locate leader element */
			
			if (me->an_type == LEADER_LINE)
				me->acc_key = DM_P_PosBrkPt;
			
			status =
			om$send(msg = message COdim.locate_parent(
						response,
						response_data,
						&me->loc_event,
						TRUE,
						DM_P_EltEnLd,
						me->acc_key,
						me->rel_key),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			
			if( me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_P_GET_EVNT;
			else if( *response == D_RESET)
				me->state = STATE_P_POS_ARROW;
			break;
			
			/********************/
			case STATE_P_GET_EVNT:
			/********************/

			/*|- get event */

			status =
			om$send(msg = message COanplace.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/* Special processing for assemblies */

			if( me->an_type == TEXT_WITH_BALLOON )
			  {
			  struct GRid inst_grid;
			  char txt_str[256], attr_name[80];
			  IGRlong long_rc;
			  struct GRid partid;

			    /* If the file is a part, get keyedin attrname */
			    partid.objid = NULL_OBJID;
			    status = 
			    EMget_file_part( &long_rc, &me->dyn_env, &partid );
			    
			    if ( long_rc & status & 1 )
			    {
				FIg_get_text( me->form, GAD_BLN_ATTR, attr_name );

				if( strlen( attr_name ) )
				{
			    	    status =
			            EMget_feature_instance(&long_rc,
				        		   &me->loc_event.located_object[0].module_info,
					        	   &me->loc_event.located_object[0].located_obj,
						           &inst_grid);

/*
        			    dm$status(action = RET_STATUS);
	        		    dm$status(sts = long_rc,action = RET_STATUS);
*/
				    if( status & long_rc & 1 )
                                    {
		        	    status = 
			            EMget_attr_valstr( &long_rc, attr_name, &inst_grid,
							txt_str );
				    if( status & long_rc & 1 ) 
				    {
        			    	me->dyn_info.info.text_length = 
								strlen(txt_str);
        			    	memcpy( me->dyn_info.info.text_string,
					        txt_str, 
						me->dyn_info.info.text_length);

        			    	status = 
	        		    	om$send(msg = 
		        	    	message COanplace.update_text_string(),
			        	    	targetid = my_id);

        			    	dm$status(action = RET_STATUS);
				    }
				    else
				    {
					sprintf( txt_str,"Attribute :%s: not available", attr_name );
					UI_status(txt_str);
				    }
                                    }
                                }
                            }
			  }
			/* end special processing for assemblies */
			if(me->leader)
				msgkey = (me->an_type  == LEADER_LINE) ? 
					 DM_P_EnBrPt : DM_P_PosBrkTx;
			else	msgkey = DM_P_EnTxDt;
			
			control = (me->leader ? MOVE_BREAK_PT : 0);


			status =
			om$send(msg = message COanplace.position_dim(
						msgkey,
						TRUE,
						NULL,
						NULL,
						control,
						NULL,
						NULL),
			targetid = my_id);
			dm$status(action=RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(msgkey,
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
				om$send(msg = message COanplace.position_dim(
							msgkey,
							FALSE,
							NULL,
							NULL,
							control,
							NULL,
							NULL),
				targetid = my_id);
				dm$status(action=RET_STATUS);
				
				if(!me->leader)
				{
					/*|- Place annotation  without leader*/

					status = 
					om$send( msg = message COanplace.place_no_leader(&rc),
						 targetid = my_id);
					dm$status(action = RET_STATUS);
				}
				else
				{

					me->data_event = me->event1;
					/*| - Add a vertex */

					status = 
					om$send(msg = message DMannot.ANadd_delete_vertex(
									&rc,
									ADD_VERTEX,
									NULL,
									&me->dyn_env),
						targetid = me->an_grid.objid,
						targetos = me->an_grid.osnum);
					dm$status(action= RET_STATUS);
					
					status =
					om$send(msg = message COanplace.set_dim_state(
									DIM_IN_PLACEMENT |
									DIM_NEEDS_UPDATE ),
							targetid = my_id);
					dm$status(action = RET_STATUS);
				}
			}
			else if(   *response == STRING 
			        && me->an_type != LEADER_LINE)
			{
				status = 
				om$send(msg = message COanplace.add_text_to_object(
								response),
					targetid = my_id);
				dm$status(action= RET_STATUS);
			}
			else if( *response == D_RESET)
			{
				/*| - response is D_RESET */

				if(me->leader)
				{
					status = 
					om$send( msg = message COanplace.delete_vertex(&rc),
						targetid = my_id);
					dm$status(action =RET_STATUS);
					
					if(!rc)
					{
						me->state = ( me->an_type == LEADER_LINE) ?
								STATE_P_LOC_LEAD_ELT:
								STATE_P_LOC_ARROW_ELT;
					}
				}
				else
				{
					status =
					om$send(msg = message COanplace.delete_dimension(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
					if( me->prev_dim.objid != NULL_OBJID)
					{
						status = 
						om$send(msg = message COanplace.get_prev_dim_data(),
							targetid = my_id);
						dm$status(action = RET_STATUS);
						me->prev_dim.objid = NULL_OBJID;
						me->state = STATE_P_GET_EVNT;
					}
					else me->state = STATE_P_LOC_ARROW_ELT;
				}
				
			}
			else if( *response == RESET)
			{
				if(me->an_type != TEXT_WITH_BALLOON &&
				   me->an_type != LEADER_LINE)
				{
					status=
					om$send(msg = message COanplace.update_text_string(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}

				if( !me->leader)
				{
					status =
					om$send(msg = message COanplace.delete_dimension(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}
				else
				{
					/*| - Delete Vertex  */

					status = 
					om$send( msg = message COanplace.delete_vertex(&rc),
						targetid = my_id);
					dm$status(action=RET_STATUS);

					/*"rc = %d\n",rc*/

					if(me->an_type == LEADER_LINE) 
					{
						/*|- Connect leader */

						status =
						om$send(msg = message COanplace.connect_leader(&me->data_event),
							targetid = my_id);
						dm$status(action = RET_STATUS);
					}

					status =
					om$send(msg = message COanplace.compute_dimension(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
					DMupdate_active_layer_info(&rc, 
							  &me->an_grid,NULL);
					status =
					om$send(msg = message COanplace.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}

				status =
				om$send( msg = message COanplace.dealloc(),
					 targetid = my_id);
				dm$status(action = RET_STATUS);
				
				me->prev_dim.objid = me->an_grid.objid;

				me->an_grid.objid = NULL_OBJID;

				if (me->an_type != TEXT_WITH_BALLOON)
					me->leader = TRUE;


				me->state = STATE_P_LOC_ARROW_ELT;
				
				status = 
				om$send( msg = message COanplace.init_type(),
					targetid= my_id);
				dm$status(action = RET_STATUS);
			}
			break;

			/******/
			default:
			/******/

			printf("COanplace: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:
			case STRING:
			break;

			case TERMINATE:
			if (me->an_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message COanplace.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			return(OM_S_SUCCESS);
			case STATUS_DISP:

			status = 
			om$send(msg = message COanplace.display_form(),
					targetid = my_id);
			dm$status(action = RET_STATUS);
			break;
			case EX_CMD_KEY:
			case CMD_STRING:
			return(OM_S_SUCCESS);

			default:
			/*^ printf("response:%d\n",*response); */
			return(OM_S_SUCCESS);
		}
	}
}
method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status;
	

	me->event1.located_object[0] = *lc_info;
	me->loc_event = me->event1;
	
	switch(me->state)
	{
		/*************************/
		case STATE_P_LOC_ARROW_ELT:
		/*************************/
		
		status =
		om$send(msg = message COanplace.create_arrow(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		/*************************/
		case STATE_P_LOC_LEAD_ELT:
		/*************************/


		status =
		om$send(msg = message COanplace.create_lead(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;
		
		default:
			break;
	}
	return(OM_S_SUCCESS);
}
method LC_postproc()
{
	IGRint status;
	IGRint delete;


	/*^
		printf("event1.response=%d\n", me->event1.response);
		printf("event2.response=%d\n", me->event2.response);
	*/
	delete = FALSE;
	if (me->locate_rc == LC_OBJ_LOCATED)
		me->create_flag = TRUE;

	if (me->event2.response == RESET ||
	    me->event2.response == D_RESET)
	{
		delete = ((me->state == STATE_P_LOC_ARROW_ELT) ||
			(me->state == STATE_P_LOC_LEAD_ELT));
	}

	if (delete)
	{
		/*|Deleting dimension*/

		status =
		om$send(msg = message COanplace.delete_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event)
{
	IGRint status, msgkey, control;
	struct DMsenv_param par_senv;

    dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);

	*msg = DIM_S_SUCCESS;

	if (me->event1.subtype != GRst_REGULAR)
	{
		/*"event1.subtype = %d\n", me->event1.subtype */
		return(OM_S_SUCCESS);
	}

	/*^
		printf("event1.response=%d\n", me->event1.response);
		printf("event2.response=%d\n", me->event2.response);
		printf("event1.point=%lf, %lf, %lf\n",
			me->event1.event.button.x,
			me->event1.event.button.y,
			me->event1.event.button.z);
		printf("event1.grid=%d, %d\n",
			me->event1.located_object[0].located_obj.objid,
			me->event1.located_object[0].located_obj.osnum);
		print_grid("obj", obj);
	*/

	switch(me->state)
	{
		/*************************/
		case STATE_P_LOC_ARROW_ELT:
		/*************************/

		/** If the attach_pt fot balloon object is inside_object, then
		return back ignoring the creation and dynamics routine. The an-
		notation object will be created in the excute function itself **/

		if(me->an_type == LEADER_LINE ||
		  (me->an_type == TEXT_WITH_BALLOON &&
		   par_senv.attach_pt == INSIDE_OBJECT)) 
		{	
			return(OM_S_SUCCESS);
		}

		/*************************/
		case STATE_P_LOC_LEAD_ELT:
		/*************************/
	
           if (me->an_grid.objid != NULL_OBJID)
           { 
            struct GRid newgrid,new2grid,go_grid;
            struct GRmd_env mod_info;
            IGRmatrix matrix;
                IGRshort matrix_type;

                	om$get_objid_at_index(
                                objid = me->an_grid.objid,
                                osnum = me->an_grid.osnum,
                                p_chanselect = &ND_father,
                                index = 2,
                                objidaddr = &newgrid.objid,
                                osnumaddr = &newgrid.osnum);

                 	om$get_objid_at_index(
                                objid = newgrid.objid,
                                osnum = newgrid.osnum,
                                p_chanselect = &ND_father,
                                index = 0,
                                objidaddr = &new2grid.objid,
                                osnumaddr = &new2grid.osnum);

                	status = om$send( msg = message NDnode.ASreturn_go(
				&go_grid,
                                &matrix_type,
                                matrix),
                           targetid = new2grid.objid,
                           targetos = new2grid.osnum);

                	if( !(status &1) || (! (om$is_objid_valid(
                                osnum= new2grid.osnum,
                                objid = new2grid.objid) ) ) )
                	{
                       		DMget_module_info(&mod_info);
                        	status =
                        	om$send(msg = message NDnode.NDdelete(
					&mod_info),
                                     targetid = me->an_grid.objid,
                                     targetos = me->an_grid.osnum);
                        	dm$status(action = RET_STATUS);

                        	me->an_grid.objid= NULL_OBJID;
                	}
                }

           
		if (me->an_grid.objid == NULL_OBJID)
		{
			status =
			om$send(msg = message COanplace.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

    		    /* Special processing for assemblies */

		    if( me->an_type == TEXT_WITH_BALLOON )
		    {
		    struct GRid inst_grid;
		    char txt_str[256], attr_name[80];
		    IGRlong long_rc;
		    struct GRid partid;

		        /* If the file is a part, get keyedin attrname */
		        partid.objid = NULL_OBJID;
			status = 
			EMget_file_part( &long_rc, &me->dyn_env, &partid );
			    
			if ( long_rc & status & 1 )
			{
			    FIg_get_text( me->form, GAD_BLN_ATTR, attr_name );

			    if( strlen( attr_name ) )
			    {
			        status =
			        EMget_feature_instance(&long_rc,
			        		       &me->loc_event.located_object[0].module_info,
					               &me->loc_event.located_object[0].located_obj,
						       &inst_grid);

/*
        			dm$status(action = RET_STATUS);
	        		dm$status(sts = long_rc,action = RET_STATUS);
*/
                                if( status & long_rc & 1 )
                                {
		        	status = 
			        EMget_attr_valstr( &long_rc, attr_name, &inst_grid,
							txt_str );
				if( status & long_rc & 1 ) 
				{
        			    me->dyn_info.info.text_length = 
							strlen(txt_str);
        			    memcpy( me->dyn_info.info.text_string,
				            txt_str, 
					    me->dyn_info.info.text_length);

       			    	    status = 
	        		    om$send(msg = 
		        	    	message COanplace.update_text_string(),
			        	    	targetid = my_id);

        			        dm$status(action = RET_STATUS);
				}
				else
				{
				    sprintf( txt_str,"Attribute :%s: not available", attr_name );
				    UI_status(txt_str);
				}
                                }
                            }
                        }
		    }
                    /* end special processing for assemblies */
		}

		status =
		om$send(msg = message COanplace.set_dim_state(
					DIM_IN_PLACEMENT |
					DIM_NEEDS_UPDATE),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		if(me->leader)
			msgkey = (me->an_type == LEADER_LINE) ?
				DM_P_PosBrkPt : DM_P_PosBrkTx;
		else	msgkey = DM_P_EnTxDt;
		
		if(me->leader) control = MOVE_BREAK_PT;
		else control = 0;

		status =
		om$send(msg = message COanplace.position_dim(
					msgkey,
					TRUE,
					NULL,
					NULL,
					control,
					NULL,
					NULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		default:
		break;
	}
	return(OM_S_SUCCESS);
}

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	struct IGRbsp_curve *bsp_curve;
	IGRlong long_rc,status;
	*msg = OM_S_SUCCESS;
	/* - Linear element is required for feature control frame 
	     without leader - */


	if (DMancestry_valid(lc_info->located_obj, OPP_GR3dtext_class_id))
	{
		*msg= TRUE;
		return(TRUE);
	}

	*msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);

	if( *msg && (me->an_type == FEATURE_CONTROL_FRAME &&  !me->leader))
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
		*msg = !DMancestry_valid(lc_info->located_obj, OPP_GR3dpoint_class_id);
	}


	return(OM_S_SUCCESS);
}
method display_dimension(
	IGRint level;
	IGRint control)
{
	IGRint status, rc, count, index;
	IGRshort dim_state;
	struct GRid list[10];

	count = 0;

	status =
	DMget_graph(
		me->an_grid,
		ROOT | CHILDREN,
		10,
		list,
		&count);
	dm$status(action = RET_STATUS);

	for(index = 0; index < count; index ++)
	{
		status =
		DMdisplay_dimension(
			&rc,
			level,
			control,
			&me->md_env,
			&list[index]);
		dm$status(action = RET_STATUS);
	}

	dim_state = (control & DISPLAY)?0:DIM_IN_PLACEMENT;

	status =
	om$send(msg = message COanplace.set_dim_state(dim_state),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
method compute_dimension()
{
	IGRint status, count,index;
	IGRlong long_rc;
	struct GRid list[10];

	count = 0;

	status =
	DMget_graph(
		me->an_grid,
		ROOT | CHILDREN,
		10,
		list,
		&count);
	dm$status(action = RET_STATUS);

	for(index = 0; index < count; index ++)
	{
		status =
		om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
			targetid = list[index].objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);

	}

	return(OM_S_SUCCESS);
}
method position_dim(
	IGRint msgkey;
	IGRint dynamics;
	IGRint preproc;
	IGRint prestate;
	IGRint control;
	IGRint postproc;
	IGRint poststate)
{
	IGRint status, rc;

	if(!me->dynamics_on && dynamics)
		return(OM_S_SUCCESS);
	/*^
		printf("dynamics flag:%d\n",dynamics);
		printf("data point:%lf:%lf:%lf\n",me->event1.event.button.x,
						     me->event1.event.button.y,
						     me->event1.event.button.z);*/
			

	status =
	DMinvoke_txdynamics(
		&rc,
		dynamics,
		&me->dyn_info,
		msgkey,
		preproc,
		postproc,
		prestate,
		poststate,
		FALSE,  /* copy flag */
		NULL,   /* cp_grid  */
		control,
		&me->dyn_env,
		&me->event1,
		&me->an_grid);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method delete_dimension()
{
	IGRint status, index, count;
	struct GRid list[10];

	if (me->an_grid.objid == NULL_OBJID)
	{
		/*| No such dimension exists */
		return(OM_S_SUCCESS);
	}

	count = 0;

	status =
	DMget_graph(
		me->an_grid,
		ROOT | CHILDREN,
		10,
		list,
		&count);
	dm$status(action = RET_STATUS);

	for(index = 0; index < count; index++)
	{
		status =
		om$send( msg = message NDnode.NDdelete(&me->dyn_env),
			mode = OM_e_wrt_message,
			targetid = list[index].objid,
			targetos = list[index].osnum);
		if (!(status & 1))
		{
			/*"delete fails\n"*/
		}
	}

	me->an_grid.objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

method set_dim_attr()
{

	me->an_attr.dim_type	= me->mytype;
	me->an_attr.geom_type   = 0;
	me->an_attr.display	= 0;
	me->an_attr.dim_state	= DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->an_attr.leader 	= me->leader;
	me->an_attr.text_length = 0;
	me->an_attr.text_string = NULL;
	me->an_attr.num_brkpt  = 0;
	me->an_attr.dual_mode = 0;
	me->an_attr.brkpt      = NULL;
	me->an_attr.tol_symbol = (me->mytype == FEATURE_CONTROL_FRAME)?
				  me->tol_sym:0;
	me->an_attr.bln_dir    =  0; 

	return(OM_S_SUCCESS);
}

method set_dim_state(IGRshort dim_state)
{
	IGRint status, rc;
	struct GRid grid;


	if (me->an_type == TEXT_WITH_BALLOON)
	{
		status =
		om$send(msg = message DMtxbln.get_active_balloon(
						&rc,
						&grid),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
		dm$status(action = RET_STATUS);
	}
	else	grid = me->an_grid;

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_SET, dim_state),
		targetid = grid.objid,
		targetos = grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method place_dimension()
{
	IGRint status, rc;

	if (me->an_grid.objid != NULL_OBJID)
		return(OM_S_SUCCESS);

	status =
	om$send(msg = message COanplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COanplace.set_dim_attr(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COanplace.get_dim_param(),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*^ printf("mytype:%d\n",me->mytype); */

	me->an_grid.osnum = me->md_env.md_id.osnum;

	status =
	om$construct(
		classid = me->an_classid,
		p_objid = &me->an_grid.objid,
		osnum = me->an_grid.osnum,
		msg = message DMroot.DMplace(
					&rc,
					me->count,
					me->list,
					(char *)&me->an_attr,
					&me->dyn_env));
	dm$status(action = RET_STATUS);

	if(me->an_type == FEATURE_CONTROL_FRAME)
	{
		status =
		om$send(msg = message DMframe.set_profile_type(me->tol_sym),
				targetid = me->an_grid.objid,
				targetos = me->an_grid.osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}
method delete_vertex( int *rc)
{

	IGRint status;

	status = 
	om$send(msg = message DMannot.ANadd_delete_vertex(
						rc,
						DELETE_VERTEX,
						NULL,
						&me->dyn_env),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
	dm$status(action= RET_STATUS);

	return(OM_S_SUCCESS);
}
method create_arrow()
{
	IGRint status, rc;
	IGRdouble *attr, point[3];

	struct DMsenv_param par_senv;
 
    dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);	

	status =
	om$send(msg = message COdim.load_obj_info(&me->loc_event, &me->arrow),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COanplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->an_type == LEADER_LINE ||
	  (me->an_type == TEXT_WITH_BALLOON &&
       par_senv.attach_pt == INSIDE_OBJECT))
	{
		status =
		BSproj1(&rc,
			&me->loc_event.event.button.x, 
			&me->plan_info.win_plan.matrix[8],
			me->arrow.lnproj,
			point);
		dm$status(action = RET_STATUS);

		attr = &point[0];
	}
	else
		attr = &me->arrow.lnproj[0];

	status=
	dm$create_root(
		type = DMptdist,
		count = 1,
		list  = &me->arrow.grid,
		context = &me->arrow.context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[me->arrow_index]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
method create_lead()
{
	IGRint status, rc;
	IGRdouble *attr, point[3];


	status =
	om$send(msg = message COdim.load_obj_info(&me->loc_event, &me->lead),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COanplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->an_type == LEADER_LINE)
	{
		status =
		BSproj1(&rc,
			&me->loc_event.event.button.x, 
			&me->plan_info.win_plan.matrix[8],
			me->lead.lnproj,
			point);
		dm$status(action = RET_STATUS);

		attr = &point[0];
	}
	else
		attr = &me->lead.lnproj[0];

	status=
	dm$create_root(
		type = DMptdist,
		count = 1,
		list  = &me->lead.grid,
		context = &me->lead.context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[me->lead_index]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}
method connect_leader(struct GRevent *event)
{
	IGRint status,rc, index, display, project = 1, ptdist;
	IGRlong long_rc;
	struct IGRbsp_curve *bsp_curve;
	struct IGRline boreline;
	struct GRid *connect_grid = NULL,line_grid, win_grid;
	IGRdouble point2[3], point1[3], tolerance;
	struct dim_ret_struct dim_str;

	struct DMsenv_param par_senv;
 
    dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);	

	/* fill the window grid from event */
	win_grid.objid = event->event.button.objid;
	win_grid.osnum = event->event.button.osnum;

	/* get the tolerance band from the current window */

	DMget_dit_tol(&win_grid, &tolerance);

	if(me->state == STATE_P_POS_ARROW)
	{
		connect_grid = &me->list[me->arrow_index];

		status =
		om$send(msg = message COanplace.get_dim_plane(),
				targetid= my_id);
		dm$status(action=RET_STATUS);

		project = 1;
	}
	else if (me->state == STATE_P_GET_EVNT)
	{
		if (me->an_type == LEADER_LINE )
		{
			/*|- get last point of line string */

			connect_grid = &me->list[me->lead_index];

			status =
			om$send(msg = message DMroot.return_dim_go(
							&rc,
							DIM_LEADER,
							FALSE,
							DM_LINE_STR,
							&me->md_env,
							&line_grid),
				targetid = me->an_grid.objid,
				targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message GRvg.GRgenabsg(
						&long_rc,
						&me->md_env.md_env.matrix_type,
						me->md_env.md_env.matrix,
						(char **)&bsp_curve),
				targetid = line_grid.objid,
				targetos = line_grid.osnum);
			dm$status(action = RET_STATUS);

			index = (bsp_curve->num_poles - 1) * 3;

			point1[0] = bsp_curve->poles[index];
			point1[1] = bsp_curve->poles[index + 1];
			point1[2] = bsp_curve->poles[index + 2];
			boreline.point1 = point1;
			project = 0;
		}
		else
		{
			connect_grid = &me->list[me->arrow_index];
			project = 1;
		}
	}

	if(project)
	{
		status =
		DMsrc_give_structure(
				&rc,
				DIM_NO_INDEX,
				ORIG_INFO,
				FALSE,
				FALSE,
				connect_grid->objid,
				me->an_grid.objid,
				connect_grid->osnum,
				&me->md_env,
				&dim_str);
		dm$status(action = RET_STATUS);

		status =
		BSproj1(&rc,
			&event->event.button.x,
			&me->plan_info.win_plan.matrix[8],
			dim_str.var.dm_ptdist.point,
			point1);
		dm$status(action = RET_STATUS);

		boreline.point1 = point1;
	}

	point2[0] = boreline.point1[0] +
				me->plan_info.act_plan.matrix[8];
	point2[1] = boreline.point1[1] +
				me->plan_info.act_plan.matrix[9];
	point2[2] = boreline.point1[2] +
				me->plan_info.act_plan.matrix[10];

	boreline.point2 = point2;
		
	/*^     printf(" src grid:%d,%d\n",connect_grid->objid,connect_grid->osnum);
		print_point("boreline pt1",boreline.point1); 
	    	print_point("boreline pt2",boreline.point2);
	 */

	status =
	om$send(msg = message DMsrc.DMdisplay_source(
						&rc,
						&tolerance,
						&boreline,
						&display,
						&me->md_env),
		targetid = connect_grid->objid,
		targetos = connect_grid->osnum);
	dm$status(action = RET_STATUS);

	if( display )
		project = 0;
	else	project = 1;

	if( me->an_type != FEATURE_CONTROL_FRAME &&
	    me->an_type != DATUM_FRAME)
		ptdist = TRUE;
	else
	{
		ptdist = FALSE;
		project = (me->leader)? project:1;
	}

	status =
	om$send(msg = message DMsrc.DMmodify(
					&rc,
					&me->md_env,
					project,
					ptdist,
					&boreline),
		targetid = connect_grid->objid,
		targetos = connect_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method place_no_leader(IGRint *rc)
{
	IGRint status;
	

	if( me->an_type != TEXT_WITH_BALLOON && 
	    me->an_type != LEADER_LINE)
	{
		status =
		om$send(msg = message COanplace.update_text_string(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	status = 
	om$send( msg = message COanplace.connect_leader( &me->event1),
			targetid = my_id);
	dm$status(action=RET_STATUS);

	status =
	om$send(msg = message COanplace.compute_dimension(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	DMupdate_active_layer_info(rc, &me->an_grid, NULL);

	status =
	om$send(msg = message COanplace.display_dimension(
				ROOT,
				DISPLAY | ADDWRNG),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status = 
	om$send( msg = message COanplace.dealloc(),
		 targetid = my_id);
	dm$status(action = RET_STATUS);
	me->prev_dim = me->an_grid;
	me->an_grid.objid = NULL_OBJID;

	me->loc_event = me->data_event;
	if( me->an_type != FEATURE_CONTROL_FRAME &&
	    me->an_type != DATUM_FRAME)
	{
		status =
		om$send(msg = message COanplace.create_arrow(),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	
		status =
		om$send(msg = message COanplace.place_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		me->leader = TRUE;
		status =
		om$send(msg = message COanplace.init_type(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		me->state = STATE_P_LOC_ARROW_ELT;
	}

	return(OM_S_SUCCESS);
}
method dealloc()
{
	IGRint status;

	me->dyn_info.info.text_string = (unsigned char *) om$realloc( ptr = 
		(char *)me->dyn_info.info.text_string, size = 1024);
	me->dyn_info.info.text_string[0] = 0;
	me->dyn_info.info.text_length = 0;
	me->dyn_info.info.text_buff_size = 1024;

	if(me->an_type == FEATURE_CONTROL_FRAME)
	{
		status = FIg_enable(me->form,TOL_SYMB_DUAL_LINE);
		if(status != FI_SUCCESS )
		{
			printf("FIg_enable fails:%d\n",status);
			return(FALSE);
		}
		status = FIg_set_state(me->form,TOL_SYMB_DUAL_LINE,0);
		if(status != FI_SUCCESS )
		{
			return(FALSE);
		}
	}

	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status, i;
	IGRint map[5];
	IGRdouble val[5];
	IGRchar *ter_type, *an_posn;
	IGRchar string[80];

	if(me->an_type == FEATURE_CONTROL_FRAME)
	{
		status=
		om$send(msg = message COanplace.get_gt_symbol(form_label,
								label,
								value,
								form),
				targetid = my_id);
		dm$status( action = RET_STATUS);
	}
	else if(me->an_type == TEXT_WITH_BALLOON)
	{
		status =
		om$send(msg = message COanplace.process_bln_form(
							FALSE,
							label,
							value,
							form),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else if(me->an_type == LEADER_LINE)
	{
		status = FIf_erase(form);
		if(status != FI_SUCCESS)
		{
			/*|FIf_erase fails */
			return(OM_E_ABORT);
		}

		me->form_display = FALSE;

		switch(label)
		{
			case GAD_HOLLOW_ARROW:
			ter_type = "Hollow"; break;
				
			case GAD_FILLED_ARROW:
			ter_type = "Filled"; break;

			case GAD_OPEN_ARROW:
			ter_type = "Open"; break;

			case GAD_SLASH:
			ter_type = "Slash"; break;
				
			case GAD_BACK_SLASH:
			ter_type = "Back_slash"; break;

			case GAD_BLANK:
			ter_type = "Blank"; break;

			case GAD_DOT:
			ter_type = "Dot"; break;

			case GAD_CIRCLE:
			ter_type = "Circle"; break;

			default:
			printf("COanplace - C_SubTerm bad label\n");
			return(OM_E_ABORT);
		}

		sprintf((char *)string, "terminator type=%s", ter_type);
		status=
		om$send( msg = message COanplace.get_keybrd_input((char *)string),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else if (me->an_type == TEXT_WITH_LEADER)
	{
		map[ANNOT_JUST_ABOVE] = GAD_TL_TOP;
		map[ANNOT_JUST_CENTER] = GAD_TL_CENTER;
		map[ANNOT_JUST_BOTTOM] = GAD_TL_BOTTOM;
		map[ANNOT_JUST_UNDER] = GAD_TL_UNDER;

		for(i=0; i<5; i++)
		    val[i] = 0.0;

		switch(label)
		{
			case GAD_TL_TOP:

			an_posn = "Above";
			val[ANNOT_JUST_ABOVE] = 1.0;
			break;

			case GAD_TL_CENTER:

			an_posn = "Center";
			val[ANNOT_JUST_CENTER] = 1.0;
			break;

			case GAD_TL_BOTTOM:

			an_posn = "Bottom";
			val[ANNOT_JUST_BOTTOM] = 1.0;
			break;
			
			case GAD_TL_UNDER:

			an_posn = "Underline";
			val[ANNOT_JUST_UNDER] = 1.0;
			break;

			case GAD_CHECK:

			status = FIf_erase(form);
			if(status != FI_SUCCESS)
			{
				/*|FIf_erase fails */
				return(OM_E_ABORT);
			}

			status =
			FIg_set_value(
				form,
				GAD_CHECK,
				0.0);
			if (status != FI_SUCCESS)
			{
				/*|FIg_set_value fails*/
				return(OM_E_ABORT);
			}
			me->form_display = FALSE;
			return(OM_S_SUCCESS);

			default:
			return(OM_S_SUCCESS);
		}

		for(i=0; i<4; i++)
		{
			status =
			FIg_set_value(
				form,
				map[i],
				val[i]);
			if (status != FI_SUCCESS)
			{
				/*|FIg_set_value fails*/
				return(OM_E_ABORT);
			}
		}

		sprintf((char *)string, "annotation position=%s", an_posn);
		status=
		om$send( msg = message COanplace.get_keybrd_input((char *)string),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}
method delete(int f_defer_flag)
{
	IGRint status;
	/*| delete */
	struct DMsenv_param par_senv;


	dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);

	if(me->dyn_info.info.text_string != NULL)
	{
		/*| free text string*/
		free(me->dyn_info.info.text_string);
	}
	if (me->an_grid.objid != NULL_OBJID)
	{
		/*| delete dimension */
		status =
		om$send(msg = message COanplace.delete_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if(me->an_type == LEADER_LINE)
	{
	/*
		sprintf((char *)string, "terminator type=Filled");
	
		status=
		om$send( msg = message COanplace.get_keybrd_input((char *)string),
		        targetid = my_id);
		dm$status(action = RET_STATUS);
                ex$message(msgnumb = GR_I_Clear);
	*/

		if ( VD_test_MODEL_version() )
		{
		  extern IGRchar my_term_type;

		  par_senv.ter_type = my_term_type;
		}
		else
		{
		  extern IGRchar term_type;

		  par_senv.ter_type = term_type;
		}

		dm$put_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);
	}


	if(me->an_type != DATUM_FRAME)
	{
		/*"delete form : me->an_type=%d\n", me->an_type*/

		status = FIf_delete(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_delete fails*/
			return(OM_E_ABORT);
		}
	}

	/*| delete wrt COdim*/

	status =
	om$send(msg = message COdim.delete(f_defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint i, status,  map[8];
	IGRdouble value[8];
	struct DMsenv_param par_senv;


	if(me->an_type == TEXT_WITH_BALLOON)
	{
		status =
		om$send(msg = message COanplace.process_bln_form(
							TRUE,
							-1,
							value[0],
							me->form),
				targetid = my_id);
		dm$status(action = RET_STATUS);

		/* the argument label for process_bln_form()
		gets initialised in that method whenever display
		is set to TRUE */
	}
	else if(me->an_type == LEADER_LINE)
	{
		map[TER_TYPE_HOLLOW_ARROW] = GAD_HOLLOW_ARROW;
		map[TER_TYPE_FILLED_ARROW] = GAD_FILLED_ARROW;
		map[TER_TYPE_OPEN_ARROW] = GAD_OPEN_ARROW;
		map[TER_TYPE_SLASH] = GAD_SLASH;
		map[TER_TYPE_BACK_SLASH] = GAD_BACK_SLASH;
		map[TER_TYPE_BLANK] = GAD_BLANK;
		map[TER_TYPE_DOT] = GAD_DOT;
		map[TER_TYPE_CIRCLE] = GAD_CIRCLE;

		for(i = 0; i < 8; i++)
		   value[i] = 0.0;

		for(i = 0; i < 8; i++)
		{
	 		status =
			FIg_set_value(me->form, map[i], value[i]);
			if(status != FI_SUCCESS)
			{
				/*|FIg_set_value fails*/
				return(OM_E_ABORT);
			}
		}

		status = FIf_set_location(me->form, 0, 105);
		fi$status(sts = status, comment = "FIf_set_location");
	}
	else if(me->an_type == TEXT_WITH_LEADER)
	{
		int label;

		/*| - Text with leader Form display */

		dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);

		if (par_senv.an_posn == ANNOT_JUST_ABOVE)
			label = GAD_TL_TOP;
		else if (par_senv.an_posn == ANNOT_JUST_CENTER)
			label = GAD_TL_CENTER;
		else if (par_senv.an_posn == ANNOT_JUST_BOTTOM)
			label = GAD_TL_BOTTOM;
		else    label = GAD_TL_UNDER;

		status =
		om$send(msg = message COdim.notify_form(0, label, 0, me->form),
			targetid = my_id);
		dm$status(action= RET_STATUS);
	}
  	else if( me->an_type == FEATURE_CONTROL_FRAME)
  	{
		int symbol_num;

		ANget_tol_symbol(
			me->tol_sym,
			&symbol_num,
			&me->dyn_info.info.gtattr,
			me->subform);

		FIg_set_symbol_index(
			me->form,
			TOL_SYMB_BUTTON,
			symbol_num);
  	}
	else
	{
		return(OM_S_SUCCESS);
	}

	if(!me->form_display)
	{
		status = FIf_display(me->form);
		if(status != FI_SUCCESS)
		{
			/*|FIf_display fails*/
			return(OM_E_ABORT);
		}
	}

	me->form_display = TRUE;

	return(OM_S_SUCCESS);
}

method process_bln_form(
	IGRboolean display;
	IGRint label;
	IGRdouble value;
	Form form)
{
	IGRint status;
	IGRdouble double_sides, bln_size,bln_spacing;
	IGRdouble toggle_state;
	struct DMsenv_param par_senv;
	IGRchar string[80], errtxt[80];

    IGRint control, msgkey;

	/** fields added to incoprate the new features 
		Keyboeard input is now bypassed and the global dim_params are 
		updated directly **/
	
	status = FIg_erase(form, GAD_BL_ERRTXT);
	if(status != FI_SUCCESS)
	{
		/*|FIg_erase Fails */
		return(OM_E_ABORT);
	}


	if (!display)
	{
		dm$get_dim_param(type = DM_SENV_PARAM,
                p_data = (char *)&par_senv);


		switch(label)
		{
			case GAD_BL_SIZE:

			status =
			FIg_get_value(form, GAD_BL_SIZE, &bln_size);
			if(status != FI_SUCCESS)
			{
				/*| - FIg_get_value Fails */
				return(OM_E_ABORT);
			}

			if(bln_size < 1.5)
			{
				/*| Balloon Size less than 1.5 */

				ex$message( msgnumb = DM_I_BlnSzRt,
                                buff    = errtxt );


				status =
				FIg_set_text(form, GAD_BL_ERRTXT, errtxt);
				if(status != FI_SUCCESS)
				{
					/*|- FIg_set_text Fails*/
					return(OM_E_ABORT);
				}

				status =
				FIg_display(form, GAD_BL_ERRTXT);
				if(status != FI_SUCCESS)
				{
					/*|FIg_display Fails */
					return(OM_E_ABORT);
				}

				status =
				FIg_set_value(form,label,(double )par_senv.bln_size);
				if (status != FI_SUCCESS)
				{
					/*|FIg_set_value fails*/
					return(OM_E_ABORT);
				}
			}
			else
				par_senv.bln_size = bln_size;

			sprintf((char *)string, "balloon size=%lf", par_senv.bln_size);

			if (par_senv.stk_spacing < (par_senv.bln_size +1))
			{
				par_senv.stk_spacing = par_senv.bln_size + 1;
                status =
                FIg_set_value(form,GAD_BL_STACK_SPACING,(double )par_senv.stk_spacing);
                if (status != FI_SUCCESS)
                {
                    /*|FIg_set_value fails*/
                    return(OM_E_ABORT);
                }

		status =
                FIg_display(form, GAD_BL_STACK_SPACING);
                if(status != FI_SUCCESS)
                {
                    /*|FIg_display Fails */
                    return(OM_E_ABORT);
                }
			}
			break;

			case GAD_BL_STACK_SPACING:

			status =
			FIg_get_value(form, GAD_BL_STACK_SPACING, &bln_spacing);
			if(status != FI_SUCCESS)
			{
				/*	| - FIg_get_value Fails */
				return(OM_E_ABORT);
			}

			if(bln_spacing < (par_senv.bln_size + 1))
			{
				/*| Balloon Spacing less than diameter of the balloon */
	
				par_senv.stk_spacing = par_senv.bln_size + 1;
				status =
				FIg_set_value(form,label,(double )par_senv.stk_spacing);
				if (status != FI_SUCCESS)
				{
					/*|FIg_set_value fails*/
					return(OM_E_ABORT);
				}
			}
			else
				par_senv.stk_spacing = bln_spacing;

			sprintf((char *)string,"balloon spacing=%lf", par_senv.stk_spacing);
			break;
	
			case GAD_BL_LEADER_TOGGLE:

			FIg_get_value(form,GAD_BL_LEADER_TOGGLE,&toggle_state);
		
			if (toggle_state == 0) 
			{
				me->leader = TRUE;
			}
			else
			{
				me->leader = FALSE;
			}

			break;
			 
			case GAD_BL_ATTACHMENT_TOGGLE:

			FIg_get_value(form,GAD_BL_ATTACHMENT_TOGGLE,&toggle_state);
		
			if (toggle_state == 0) 
			{
				par_senv.attach_pt = ON_EDGE;	
			}
			else
			{
				par_senv.attach_pt = INSIDE_OBJECT;	
			}

			break;

			case GAD_BL_STACK_ORIEN_TOGGLE:

			FIg_get_value(form,GAD_BL_STACK_ORIEN_TOGGLE,&toggle_state);
		
			if (toggle_state == 0) 
			{
				par_senv.stk_orie = HORIZ_STK;
			}
			else
			{
				par_senv.stk_orie = VERT_STK;
			}

			break;

			case GAD_BL_STACK_DIR_TOGGLE:

			FIg_get_value(form,GAD_BL_STACK_DIR_TOGGLE,&toggle_state);
		
			if (toggle_state == 0) 
			{
				par_senv.stk_dir = DEFAULT_DIR;
			}
			else
			{
				par_senv.stk_dir = REVERSE_DIR;
			}

			break;

			case GAD_BL_CIRCLE:
			par_senv.bln_type = BLN_TYPE_CIRCLE;
			strcpy(string, "balloon type=Circle");

			break;

			case GAD_BL_TRIANGLE:
			par_senv.bln_type = BLN_TYPE_TRIANGLE;
			strcpy(string, "balloon type=Triangle");

			break;

			case GAD_BL_SQUARE:
			par_senv.bln_type = BLN_TYPE_SQUARE;
			strcpy(string, "balloon type=Square");

			break;

			case GAD_BL_POLYGON:
			par_senv.bln_type = BLN_TYPE_POLYGON;
			strcpy(string, "balloon type=Polygon");

			status = FIg_display(form, GAD_BL_SIDES);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}

			status = FIg_display(form, GAD_BL_TEXT);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}

			break;

			case GAD_BL_ELLIPSE:
			par_senv.bln_type = BLN_TYPE_ELLIPSE;
			strcpy(string, "balloon type=Ellipse");

			break;

			case GAD_BL_INV_TRIANGLE:
			par_senv.bln_type = BLN_TYPE_INV_TRIANGLE;
			strcpy(string, "balloon type=Inv_triangle");

			break;

			case GAD_BL_RECTANGLE:
			par_senv.bln_type = BLN_TYPE_RECTANGLE;
			strcpy(string, "balloon type=Rectangle");

			break;

			case GAD_BL_ONE_LINE_TEXT:
			par_senv.bln_type = BLN_TYPE_ONE_LINE_TEXT;
			strcpy(string, "balloon type=One_line_text");

			break;

			case GAD_BL_SPLIT_CIRCLE:
			par_senv.bln_type = BLN_TYPE_SPLIT_CIRCLE;
			strcpy(string, "balloon type=Split_circle");

			break;

			case GAD_BL_SPLIT_TRIANGLE:
			par_senv.bln_type = BLN_TYPE_SPLIT_TRIANGLE;
			strcpy(string, "balloon type=Split_triangle");

			break;

			case GAD_BL_SPLIT_SQUARE:
			par_senv.bln_type = BLN_TYPE_SPLIT_SQUARE;
			strcpy(string, "balloon type=Split_square");

			break;

			case GAD_BL_SPLIT_POLYGON:
			par_senv.bln_type = BLN_TYPE_SPLIT_POLYGON;
			strcpy(string, "balloon type=Split_polygon");

			status = FIg_display(form, GAD_BL_SIDES);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}

			status = FIg_display(form, GAD_BL_TEXT);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}
			break;

			case GAD_BL_SPLIT_ELLIPSE:
			par_senv.bln_type = BLN_TYPE_SPLIT_ELLIPSE;
			strcpy(string, "balloon type=Split_ellipse");

			break;

			case GAD_BL_SPLIT_INV_TRIANGLE:
			par_senv.bln_type = BLN_TYPE_SPLIT_INV_TRIANGLE;
			strcpy(string, "balloon type=Split_inv_triangle");

			break;

			case GAD_BL_SPLIT_RECTANGLE:
			par_senv.bln_type = BLN_TYPE_SPLIT_RECTANGLE;
			strcpy(string, "balloon type=Split_rectangle");

			break;

			case GAD_BL_TWO_LINES_TEXT:
			par_senv.bln_type = BLN_TYPE_TWO_LINES_TEXT;
			strcpy(string, "balloon type=Two_lines_text");

			break;

			case GAD_BL_SIDES:

			status =
			FIg_get_value(form, GAD_BL_SIDES, &double_sides);
			if(status != FI_SUCCESS)
			{
				/*| - FIg_get_value Fails */
				return(OM_E_ABORT);
			}

			if (double_sides < 4)
			{
				status =
				FIg_set_value(form,label,(double )par_senv.num_sides);
				if (status != FI_SUCCESS)
				{
					/*|FIg_set_value fails*/
					return(OM_E_ABORT);
				}
			}
			else
			{
				par_senv.num_sides = double_sides;
			}
			
			sprintf((char *)string, "num sides=%d", par_senv.num_sides);
			break;

			case GAD_CHECK:

			status = FIf_erase(form);
			if(status != FI_SUCCESS)
			{
				/*|FIf_erase fails */
				return(OM_E_ABORT);
			}

			status =
			FIg_set_value(
				form,
				GAD_CHECK,
				0.0);
			if (status != FI_SUCCESS)
			{
				/*|FIg_set_value fails*/
				return(OM_E_ABORT);
			}
			me->form_display = FALSE;
/*
			return(OM_S_SUCCESS);
*/
                        break;
				
			case GAD_RESTORE:
			return(OM_S_SUCCESS);

			case GAD_BLN_ATTR:
			return(OM_S_SUCCESS);

			default:
			printf("COanplace - DimTxBln bad label\n");
			return(OM_E_ABORT);
		}

		if (par_senv.bln_type != BLN_TYPE_POLYGON 
		    && par_senv.bln_type != BLN_TYPE_SPLIT_POLYGON 
		    && label != GAD_BL_SIZE)
		{
			status = FIg_erase(form, GAD_BL_SIDES);
			if(status != FI_SUCCESS)
			{
				/*|FIg_erase Fails */
				return(OM_E_ABORT);
			}

			status = FIg_erase(form, GAD_BL_TEXT);
			if(status != FI_SUCCESS)
			{
				/*|FIg_erase Fails */
				return(OM_E_ABORT);
			}
		}

/*
		status=
		om$send( msg = message COanplace.get_keybrd_input((char *)string),
				targetid = my_id);
*/
		dm$put_dim_param(type = DM_SENV_PARAM, 
                                 p_data = (char *)&par_senv);
		dm$status(action = RET_STATUS);

        	status =
		om$send(msg = message COanplace.set_dim_state(
                                        DIM_NEEDS_UPDATE),
                         targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);

 		status =
		FIg_set_value(form, GAD_BL_SIZE, par_senv.bln_size);
		if(status != FI_SUCCESS)
		{
			/*|FIg_set_value fails*/
			return(OM_E_ABORT);
		}

		if (par_senv.stk_spacing < par_senv.bln_size) 
			par_senv.stk_spacing = par_senv.bln_size + 1;

 		status =
		FIg_set_value(form, GAD_BL_STACK_SPACING, par_senv.stk_spacing);
		if(status != FI_SUCCESS)
		{
			/*|FIg_set_value fails*/
			return(OM_E_ABORT);
		}

		{
			/** set the toggles according to the Par_senv values...**/
			if (par_senv.stk_orie == HORIZ_STK)
			{
				FIg_set_state_off(form,GAD_BL_STACK_ORIEN_TOGGLE);
			}
			else
			{
				FIg_set_state_on(form,GAD_BL_STACK_ORIEN_TOGGLE);
			}

			if (par_senv.stk_dir == DEFAULT_DIR)
			{
				FIg_set_state_off(form,GAD_BL_STACK_DIR_TOGGLE);
			}
			else
			{
				FIg_set_state_on(form,GAD_BL_STACK_DIR_TOGGLE);
			}

			if (par_senv.attach_pt == ON_EDGE)
			{
				FIg_set_state_off(form,GAD_BL_ATTACHMENT_TOGGLE);
			}
			else
			{
				FIg_set_state_on(form,GAD_BL_ATTACHMENT_TOGGLE);
			}

			if (me->leader == TRUE)
			{
				FIg_set_state_off(form,GAD_BL_LEADER_TOGGLE);
			}
			else
			{
				FIg_set_state_on(form,GAD_BL_LEADER_TOGGLE);
			}
		}	

 		status =
		FIg_set_value(form, GAD_BL_STACK_SPACING, par_senv.stk_spacing);
		if(status != FI_SUCCESS)
		{
			/*|FIg_set_value fails*/
			return(OM_E_ABORT);
		}

		switch(par_senv.bln_type)
		{
			case BLN_TYPE_CIRCLE:
				label = GAD_BL_CIRCLE;
				break;
			case BLN_TYPE_TRIANGLE:
				label = GAD_BL_TRIANGLE;
				break;
			case BLN_TYPE_SQUARE:
				label = GAD_BL_SQUARE;
				break;
			case BLN_TYPE_POLYGON:
				label = GAD_BL_POLYGON;
				break;
			case BLN_TYPE_ELLIPSE:
				label = GAD_BL_ELLIPSE;
				break;
			case BLN_TYPE_INV_TRIANGLE:
				label = GAD_BL_INV_TRIANGLE;
				break;
			case BLN_TYPE_RECTANGLE:
				label = GAD_BL_RECTANGLE;
				break;
			case BLN_TYPE_ONE_LINE_TEXT:
				label = GAD_BL_ONE_LINE_TEXT;
				break;
			case BLN_TYPE_SPLIT_CIRCLE:
				label = GAD_BL_SPLIT_CIRCLE;
				break;
			case BLN_TYPE_SPLIT_TRIANGLE:
				label = GAD_BL_SPLIT_TRIANGLE;
				break;
			case BLN_TYPE_SPLIT_SQUARE:
				label = GAD_BL_SPLIT_SQUARE;
				break;
			case BLN_TYPE_SPLIT_POLYGON:
				label = GAD_BL_SPLIT_POLYGON;
				break;
			case BLN_TYPE_SPLIT_ELLIPSE:
				label = GAD_BL_SPLIT_ELLIPSE;
				break;
			case BLN_TYPE_SPLIT_INV_TRIANGLE:
				label = GAD_BL_SPLIT_INV_TRIANGLE;
				break;
			case BLN_TYPE_SPLIT_RECTANGLE:
				label = GAD_BL_SPLIT_RECTANGLE;
				break;
			case BLN_TYPE_TWO_LINES_TEXT:
				label = GAD_BL_TWO_LINES_TEXT;
				break;
			default:
				label = GAD_BL_CIRCLE;
		}

		status = FIg_set_state( form,label,1);
		if (status != FI_SUCCESS)
		{
			/*|FIg_set_state  fails*/
			return(OM_E_ABORT);
		}

 		status =
		FIg_set_value(form, GAD_BL_SIDES, (double )par_senv.num_sides);
		if(status != FI_SUCCESS)
		{
			/*|FIg_set_value fails*/
			return(OM_E_ABORT);
		}

		if (par_senv.bln_type == BLN_TYPE_POLYGON 
		    || par_senv.bln_type == BLN_TYPE_SPLIT_POLYGON )
		{
			status = FIg_display(form, GAD_BL_SIDES);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}

			status = FIg_display(form, GAD_BL_TEXT);
			if(status != FI_SUCCESS)
			{
				/*|FIg_display Fails */
				return(OM_E_ABORT);
			}
		}
		else
		{
			status = FIg_erase(form, GAD_BL_SIDES);
			if(status != FI_SUCCESS)
			{
				/*|FIg_erase Fails */
				return(OM_E_ABORT);
			}

			status = FIg_erase(form, GAD_BL_TEXT);
			if(status != FI_SUCCESS)
			{
				/*|FIg_erase Fails */
				return(OM_E_ABORT);
			}
		}

 		status =
		FIg_set_value(form, GAD_CHECK, 0.0);
		if(status != FI_SUCCESS)
		{
			/*|FIg_set_value fails*/
			return(OM_E_ABORT);
		}

                /* Special processing for Assemblies */
		if( me->an_type == TEXT_WITH_BALLOON )
		{
		IGRlong long_rc;
		struct GRid partid;

			/* If the file is a part, show the attr gadget */
			partid.objid = NULL_OBJID;
			status = 
			EMget_file_part( &long_rc, &me->dyn_env, &partid );

			dm$status( action = RET_STATUS );
			
			if( partid.objid != NULL_OBJID )
			{
				FIg_display( form, BLN_ATTR_TXT );
				FIg_display( form, GAD_BLN_ATTR );
			}
		}

	}

	return(OM_S_SUCCESS);
}

method add_text_to_object(IGRint *response)
{
	IGRint status;
	IGRboolean char_flag;
	IGRboolean pnt_flag;

	pnt_flag = FALSE;
	char_flag = TRUE;

	status =
	dm$get_plan_info(
		dim_objid = me->an_grid.objid,
		osnum = me->an_grid.osnum,
		md_env = &me->md_env,
		plan_info = &me->dyn_info.plan_info);
	dm$status(action = RET_STATUS);

	me->dyn_info.control = FILL_INFO;

	me->dyn_info.dim_grid = me->an_grid;
	me->dyn_info.md_env  = &me->dyn_env;
	if(me->leader)
		me->dyn_info.control |= MOVE_BREAK_PT;

	status = 
	DMannotdyn(&me->dyn_info,
		&(me->data_event.event.button),
		&pnt_flag,
		me->event1.event.keyin,
		me->event1.nbytes,
		&char_flag,
		me->md_env.md_env.matrix,
		NULL,	/* objects */
		NULL,	/* num_objects */
		NULL,	/* buffer */
		NULL,	/* num_buffers */
		NULL,	/* outflags */
		NULL);	/* viewind */
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method update_text_string()
{
	IGRint status,rc;

	/* - call the function to update the last seperator */
	if( me->an_type == FEATURE_CONTROL_FRAME || 
	    me->an_type == DATUM_FRAME ||
	    me->an_type == TEXT_WITH_LEADER)
	{
		DMinquire_add_seperator( me->dyn_info.info.text_string,
				 &me->dyn_info.info.text_length,
				 &me->dyn_info.info.gtattr,
				 &me->dyn_info.info.text_buff_size,
				 me->an_type);
	}
	
	status=
	om$send( msg = message DMroot.replace_text(
					&rc,
					DIM_TEXT,
					(struct GRid *) NULL,
					&me->dyn_env,
					me->dyn_info.info.text_length,
					me->dyn_info.info.text_string),
		targetid = me->an_grid.objid,
		targetos = me->an_grid.osnum);
	dm$status(action = RET_STATUS);
	return(OM_S_SUCCESS);
}
method get_keybrd_input(char *string)
{
	IGRint  status, rc;
	struct DMkeyboard dm_keyboard;
	struct DMkeyboard *p_dm_keyboard;
	OM_S_OBJID objid;
	OMuword osnum;
	CIpushlist argv[1];

	/*"string=%s\n", string*/

	strncpy(dm_keyboard.response, string, 80);
	dm_keyboard.response[79] = '\0';
	dm_keyboard.status[0] = '\0';

	status =
	om$os_name_to_number(osname = "OM_TransOS_0",
		p_osnum = &osnum);
	dm$status(action =  RET_STATUS);

	/*"osnum=%d\n", osnum*/

	status =
	ci$load(file_name = "dim_forms",
		sender_id = NULL_OBJID,
		load =  LOAD,
		file_id = &objid);
	dm$status(action =  RET_STATUS);

	/*"objid=%d, osnum=%d\n", objid, osnum*/

	p_dm_keyboard = &dm_keyboard;
	argv[0].addr = &p_dm_keyboard;
	argv[0].size = sizeof(struct DMkeyboard *);

	ci$push(argc = 1, argv = argv);

	status =
	om$send(msg = message ci.exec_fun(
				&rc,
				"keyboard_input",
				NULL,
				NULL,
				0,
				NULL,
				0),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_prev_dim_data()
{
	IGRint status,rc;
	IGRlong long_rc;
	unsigned char *text_string;
	struct GRid text_grid;
	struct annot_attr attr;

	me->an_grid.objid = me->prev_dim.objid;

	status =
	om$send(msg = message COanplace.display_dimension(
						ROOT,
						ERASE|REMWRNG),
		targetid = my_id);
	dm$status(action = RET_STATUS);
	
	status =
	om$send(msg = message DMannot.get_edit_attr(0, &attr),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
	dm$status(action = RET_STATUS);

	me->leader = attr.leader;

	if( me->an_type != LEADER_LINE)
	{
		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_TEXT,
						FALSE,
						DM_TEXT,
						&me->md_env,
						&text_grid),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
		dm$status(action = RET_STATUS);

		status = 
		om$send(msg = message GRtext.GRgettxattr(
						&long_rc,
						NULL,
						&me->dyn_info.info.text_length,
						&text_string),
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);
		

		memcpy(me->dyn_info.info.text_string,
		       text_string,
		       me->dyn_info.info.text_length);
		if(text_string) free(text_string);

		if( me->mytype == FEATURE_CONTROL_FRAME ||
		    me->mytype == DATUM_FRAME)
		{
			status =
			om$send(msg = message DMframe.get_profile_type(
								(char *)&me->tol_sym),
				targetid = me->an_grid.objid,
				targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);

			DMupdt_disp_chars(me->dyn_info.info.text_string,
				&me->dyn_info.info.text_length,
				&me->dyn_info.info.gtattr,
				me->dual_mode,
				me->an_type);
		}

	}
	return(OM_S_SUCCESS);
}
end implementation COanplace;


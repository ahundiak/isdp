class implementation ECfepattern;

#include "OMerrordef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "grmessage.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "ECpattern.h"
#include "EMSaction.h"
#include "lcdef.h"
#include "lc.h"

#include "gr.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "EMSasmacros.h"
#include "EMSprop.h"
#include "dimsrc.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "SSmacros.h"
#ifndef SUNOS
#include "ctype.h"
#endif

#define MATRIX       16
#define POLAR        18
#define SEG_LENGTH 1.5
#define fe_projpt(vc,s,vr,V) \
{ \
        V[0] = vc[0] + s*vr[0];\
        V[1] = vc[1] + s*vr[1];\
        V[2] = vc[2] + s*vr[2];\
}

extern IGRdouble atof(), BSdotp();
from NDnode import NDget_objects,NDs_compute_node,NDgive_structure;
from EMSpatfea import NDplace;
from GRgraphics import GRdisplay, GRgetobjinfo;
from EMSdatpln import EMget_pln_info;
from dim_plan import select_axis;
from EMSdpr import EMget_dpr_props;
from EMSsurface import EMgetactiveid;
/* state  LocKey  */
%safe
static int promptkey[] = { 0,
			   EMS_P_IdRefPlane,
                           EMS_P_IdElPttrn,
			   EMS_P_AcNxHlFe,
			   EMS_P_IdRefPt,
			   EMS_P_AcFtPtDr,
			   EMS_P_NumOccDiDir,
			   EMS_P_DisOccDiDir,
			   EMS_P_SelSecPatDir,
			   EMS_P_NumOccDiDir,
			   EMS_P_DisOccDiDir,
			   EMS_P_IdCenPtAx,
			   EMS_P_AcPtDir,
			   EMS_P_NumOccDiDir,
			   EMS_P_EnAngOcc,
			   EMS_P_AcProPttrn
			  };
%endsafe

extern GRclassid OPP_EMSdatpln_class_id,
       OPP_EMSsubbs_class_id,
       OPP_EMSdpr_class_id,
       OPP_EMSparampt_class_id,
       OPP_EMSpointer_class_id,
       OPP_GRpoint_class_id,
       OPP_EMSslboolean_class_id,
       OPP_EMSsfrndbool_class_id,
       OPP_EMSslboolfea_class_id,
       OPP_EMSslslotfea_class_id,
       OPP_EMSslfeature_class_id,
       OPP_SKptvar_class_id;


method init(int type; char *string_ptr)
{
  IGRint status, rc, i;
  IGRint sizbuf,nret;
  IGRshort num_defaults = 1, flag = 0;
  IGRchar units[52];
  extern IGRint EMfeature_pattern_notification();
  IGRboolean aflag;

  status =
  om$send(msg = message super_cmd.init(type, string_ptr),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  fe$status(action = RET_STATUS);
  aflag = pwIsActivationOn();
  if(aflag)
   pwGetActiveModuleEnv(&me->md_env);
  else
  {
  sizbuf = sizeof(struct GRmd_env);
  gr$get_module_env(
	  msg = &rc,
	  sizbuf = &sizbuf,
          buffer = &me->md_env,
          nret = &nret);
  fe$status(sts = rc, action = RET_STATUS);
  }
  me->display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                 NO_PROJ_ACCEPT_POINT | LC_ERASE_LOC_ELEMENT;

  strcpy(me->attr.classes, "EMSsurface");
  me->attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

  me->attr.owner_action =  LC_RIGID_COMP     | LC_FLEX_COMP |
                           LC_RIGID_OWNER    | 
                           LC_INTERMIDIATE   |
                           LC_BOTTOM_UP      |
                           LC_NO_REF_HEADER  |
                           LC_REF_OBJECTS    |
                           LC_ASSOCIATIVE    |
                           LC_EXTERN_CONSTRAINED;

  me->eventmask1 = GRm_VALUE|GRm_STRING|GRm_DATA|GRm_RJT_MOVEON|GRm_BACK_UP;
  me->eventmask2 = GRm_DATA|GRm_RJT_MOVEON|GRm_BACK_UP;

  me->pattern_id.objid = NULL_OBJID;
  me->state = LOC_REF_PLANE;
  me->pattern.type = GR_ASCOPY_RECTANGULAR;
  me->fea_props = 0;
  me->ref_props = 0;

  for( i = 0 ; i< MAX_FEATURE_PARENTS; i++)
    me->list[i].objid = NULL_OBJID;

  GRstatus_display_button(1);

  status =
  FIf_new(1,"EMPattern",EMfeature_pattern_notification,&me->form);
  if(  status != FI_SUCCESS)
    return(OM_E_ABORT);

  status =
  FIf_set_cmd_oid_os(me->form,my_id,OM_Gw_current_OS);
  if(  status != FI_SUCCESS)
    return(OM_E_ABORT);

  status = co$get_default_units(msg = &rc,
				table_name = GRIO_DISTANCE,
				osnum = 2,
				flag = &flag,
				num_defaults = &num_defaults,
				default_units = units);
  fe$status(action = RET_STATUS);

  me->pattern.var.matrix.rows = 4;
  me->pattern.var.matrix.cols = 4;
  if(!strncmp(units,"mm",2))
    {
      me->pattern.var.matrix.Xdelta = 25.0;
      me->pattern.var.matrix.Ydelta = 25.0;
    }
  else
    {
      me->pattern.var.matrix.Xdelta = 1.0;
      me->pattern.var.matrix.Ydelta = 1.0;
    }
  return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
  IGRint status;

  ex$message(msgnumb = EM_M_CrPattern);
  status = om$send( mode = OM_e_wrt_message,
		   msg = message super_cmd.wakeup(pos),
		   targetid = my_id);

  if(me->form_displayed)
    FIf_display(me->form);

  if( me->state  > LOC_DEP_FEATURE )
    GRstatus_display_button(0);
  else
    GRstatus_display_button(1);
    
  return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
  IGRint msg;

  if(me->form_displayed)
    FIf_erase(me->form);
  ex$message(msgnumb = GR_P_Clear);
  ex$message(msgnumb = GRC_M_Clear);

  GRstatus_display_button(0);
  dp$erase_hilite(msg = &msg);

  return(OM_S_SUCCESS);
}

method execute( int *response ; char *response_data; int pos)
{
  BSrc bsrc;
  IGRint status,rc ,putacc, i;
  IGRlong long_rc;
  IGRint nbytes , acc_key,options,bool_dir;
  struct GRid ref_id,context, win_grid ,go_grid;
  struct EX_cmd cmdstr;
  struct ret_struct info_struct;
  enum GRdpmode  mode = GRhd;
  IGRdouble attr[3],origin[3], dist, newvec[3],newvec2[3],newpt[3];

  OM_S_CHANSELECT to_geometry;
  IGRint eventmask3 = GRm_STRING|GRm_DATA|GRm_RJT_MOVEON|GRm_BACK_UP;

  while( TRUE)
  {
    if( me->state  > LOC_DEP_FEATURE )
      GRstatus_display_button(0);

    switch(me->state) {

    case LOC_REF_PLANE:
      ex$message(msgnumb = EMS_I_PatternOps);
      ems$get_active_datum_plane( msg = &rc,
				 datpln = &me->plane_id);
      if(me->plane_id.objid != NULL_OBJID)
	{
          IGRboolean aflag = 0;
          struct GRmd_env display_env;

          aflag = pwIsActivationOn();
          gr$get_module_env(buffer = &display_env);

          status = 
          om$send(msg = message GRgraphics.GRdisplay(&long_rc,
                                 aflag?&display_env.md_env.matrix_type:
                                       &me->md_env.md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       me->md_env.md_env.matrix,
                                 &mode,
                                 aflag?&display_env.md_id:
                                       &me->md_env.md_id),
		                 targetid = me->plane_id.objid,
		                 targetos = me->plane_id.osnum);
       	  fe$status(action = RET_STATUS);
	}
      status = 
      om$send( msg = message ECfepattern.locate_element(
					  response,
					  response_data,
					  TRUE,
					  EMS_P_IdRefPlane,
					  EMS_P_AcElPttrn,
					  EMS_P_ElementNotFound),
	      targetid = my_id);
      fe$status(action = RET_STATUS);

      if( me->locate_rc == LC_OBJ_LOCATED)
      {
	me->plane_id = me->locate_event.located_object[0].located_obj;
	me->list[FEATURE_PAR_REF_PLANE] = me->plane_id;
	me->state = LOC_PAT_FEATURE;
      }
      else if( *response == EX_RJT_MOVEON)
      {
	/* Use active reference plane */
	
	if(me->plane_id.objid == NULL_OBJID)
	  {
	    ex$message(msgnumb = EMS_I_RefPlnNFd);
	  }
	else 
	  {
	    me->list[FEATURE_PAR_REF_PLANE] = me->plane_id;
	    me->state = LOC_PAT_FEATURE;
	  }
      }
      break;

    case LOC_PAT_FEATURE:

	if(me->plane_id.objid == NULL_OBJID)
	  return(OM_E_ABORT);

      me->plane[12] = me->plane[13] = me->plane[14] = 0.0;
      me->plane[12] = 1.0;

      status =
      om$send(msg = message EMSdatpln.EMget_pln_info(
		        &long_rc,
		        options,
		        &me->md_env,
			me->plane,
			&me->plane[4],
			&me->plane[8],
			origin,
			NULL),
		targetid = me->plane_id.objid,
		targetos = me->plane_id.osnum);
      fe$status(action = RET_STATUS);

      me->plane[3] = origin[0];
      me->plane[7] = origin[1];
      me->plane[11] = origin[2];

      status = 
      om$send( msg = message ECfepattern.locate_element(
					    response,
					    response_data,
					    FALSE,
					    EMS_P_IdElPttrn,
					    EMS_P_AcceptReject,
					    EMS_P_ElementNotFound),
		       targetid = my_id);
      fe$status(action = RET_STATUS);

      if(me->locate_rc == LC_OBJ_LOCATED)
	{
	  IGRboolean axis_normal;
	  IGRint param_type, next_until;
	  struct GRid par_roots[MAX_FEATURE_PARENTS],cxt[2];
	  IGRint count;
	  IGRushort umask;
	  me->feature[0]=
	    me->locate_event.located_object[0].located_obj;
	  me->fea_count = 1;


 /*	  status = EFget_reference_point_from_feature(
					 &long_rc,
				         me->feature[0],
			         	 &ref_id);
	  if((status & 1) &&  ref_id.objid != NULL_OBJID )
  */
	
	if(!(me->fea_props & NOT_A_FEATURE))
	{
	  status = om$send ( msg = message EMSdpr.EMget_dpr_props( &long_rc,
						  &umask),
			    targetid= me->feature[0].objid,
			    targetos= me->feature[0].osnum);
	  fe$status(action = RET_STATUS);

	  if(umask & EMS_PATTERN_FEATURE)
	    {
	      /* This feature cannot be selected for patterning */
	      me->state = LOC_PAT_FEATURE;
	      break;
	    }

	}
	else 
        {
	  me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
		     LOC_REF_POINT:LOC_RADIAL_CENPT);
	  break;
	}

	  status = EFget_pattern_feature_defn( &long_rc,
					      &me->feature[0],
					      &axis_normal,
					      &param_type,
					      &next_until,
					      par_roots,
					      &count);
	  if( long_rc < 0 || long_rc == MSFAIL)
	    {
	      me->fea_count = 0;
	      me->state = LOC_PAT_FEATURE;
	      break;
	    }
	  else 
	    {
	      if( param_type == PT_POINT_TYPE)
		me->list[FEATURE_PAR_REF_POINT] = 
		  ref_id = par_roots[0];
	      else if( param_type == PT_CLOSED_CURVE)
		{
		  attr[0] = me->locate_event.event.button.x;
		  attr[1] = me->locate_event.event.button.y;
		  attr[2] = me->locate_event.event.button.z;

		  par_roots[1] = me->list[FEATURE_PAR_REF_PLANE];

		  cxt[0].objid = NULL_OBJID;
		  cxt[1].objid = NULL_OBJID;
		  status = 
		  dm$create_root(type = DMkeypt,
				 count = 1,
				 list = par_roots,
				 context = cxt,
				 attr = attr,
				 md_env = &me->md_env,
				 p_root = &me->list[FEATURE_PAR_REF_POINT]);
		  fe$status(action = RET_STATUS);
		}
	      else me->list[FEATURE_PAR_REF_POINT].objid = NULL_OBJID;
	    }

	  if( me->list[FEATURE_PAR_REF_POINT].objid != NULL_OBJID)
	    {
	      status = 
	      om$send(msg = message NDnode.NDgive_structure(
                                         &long_rc,
                                         &info_struct,
                                         &me->md_env),
		      targetid = me->list[FEATURE_PAR_REF_POINT].objid,
		      targetos = me->list[FEATURE_PAR_REF_POINT].osnum);
	      fe$status(action = RET_STATUS);

	      if(!(info_struct.type & point_generic))
		{
#ifdef DEBUG
		  printf(" Element is not point generic \n");
#endif
		  return(OM_E_ABORT);
		}
	      me->ref_point[0] = info_struct.var.point_st.pt[0];
	      me->ref_point[1] = info_struct.var.point_st.pt[1];
	      me->ref_point[2] = info_struct.var.point_st.pt[2];
	    }

	  if( me->list[FEATURE_PAR_REF_POINT].objid != NULL_OBJID )
	    {
	      me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
			 SEL_MAT_DIR_X:LOC_RADIAL_CENPT);
	    }
	  else
	    {
	      me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
			 LOC_REF_POINT:LOC_RADIAL_CENPT);
	    }
	}
      else if( *response == EX_BACK_UP)
	me->state--;
      dp$erase_hilite(msg = &long_rc);
      break;
      
    case LOC_DEP_FEATURE:

      dp$erase_hilite(msg = &long_rc);
      if(me->fea_count == 1)
	{
	  status = EFget_reference_point_from_feature(
					 &long_rc,
				         me->feature[0],
			         	 &ref_id);
	  if((status & 1) &&  ref_id.objid != NULL_OBJID )
	    {
	      me->list[FEATURE_PAR_REF_POINT] = ref_id;

	      status = 
	      om$send(msg = message NDnode.NDgive_structure(
                                         &long_rc,
                                         &info_struct,
                                         &me->md_env),
		      targetid = ref_id.objid,
		      targetos = ref_id.osnum);
	      fe$status(action = RET_STATUS);

	      if(!(info_struct.type & point_generic))
		{
#ifdef DEBUG
		  printf(" Element is not point generic \n");
#endif
		  return(OM_E_ABORT);
		}
	      me->ref_point[0] = info_struct.var.point_st.pt[0];
	      me->ref_point[1] = info_struct.var.point_st.pt[1];
	      me->ref_point[2] = info_struct.var.point_st.pt[2];
	    }
	}

      status = 
      om$send(msg = message ECfepattern.display_next( &long_rc),
	      targetid = my_id);
      fe$status(action = RET_STATUS);

      if( me->list[FEATURE_PAR_REF_POINT].objid != NULL_OBJID )
	{
	  me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
		     SEL_MAT_DIR_X:LOC_RADIAL_CENPT);
	}
      else
	{
	  me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
		     LOC_REF_POINT:LOC_RADIAL_CENPT);
	}

      if(!(long_rc &1))
	{
	  ex$message(msgnumb = EMS_I_NoNxtFe);
	  break;
	}
      status = 
      co$getevent(msg = &rc,
		  event_mask = me->eventmask1,
		  msgnum = EMS_P_AcNxHlFe,
		  nbytes = &nbytes,
		  response = response,
		  response_data = response_data,
		  event = &me->event1);
      fe$status(action = RET_STATUS);

      if(me->event1.response == EX_DATA && 
	 me->next_grid.objid != NULL_OBJID)
	{
	  me->feature[me->fea_count++] = me->next_grid;
	  me->state = LOC_DEP_FEATURE;
	}
      else if(me->event1.response == EX_BACK_UP)
	{
	  me->fea_count--;
	  if(me->fea_count < 1)
	    me->state = LOC_PAT_FEATURE;
	}
      break;

    case LOC_REF_POINT:

      dp$erase_hilite(msg = &long_rc);
      ex$message(msgnumb = EMS_I_PtDefOr);
      
      status = 
      om$send( msg = message ECfepattern.locate_element(
					  response,
					  response_data,
					  FALSE,
					  EMS_P_IdRefPt,
					  EMS_P_AcceptReject,
	         			  EMS_I_RefPtNtFd),
	      targetid = my_id);
      fe$status(action = RET_STATUS);
      if(me->locate_rc == LC_OBJ_LOCATED)
	{
	  me->ref_point[0] = attr[0] = me->locate_event.event.button.x;
	  me->ref_point[1] = attr[1] = me->locate_event.event.button.y;
	  me->ref_point[2] = attr[2] = me->locate_event.event.button.z;


	  context.objid = NULL_OBJID; /* Do not locate ref file  elements */

	  if(EFisAncestryValid(&long_rc,
		       me->locate_event.located_object[0].located_obj.objid,
		       me->locate_event.located_object[0].located_obj.osnum,
		       OPP_SKptvar_class_id,FALSE))
	    {
	      status = om$make_chanselect(channame = "to_geometries",
					 p_chanselect = &to_geometry);

	      status = om$get_objid_at_index(objid = 
		       me->locate_event.located_object[0].located_obj.objid,
					     osnum = 
		       me->locate_event.located_object[0].located_obj.osnum,
					     p_chanselect = &to_geometry,
					     index = 0,
					     objidaddr = &go_grid.objid,
					     osnumaddr = &go_grid.osnum);
	      fe$status(action = RET_STATUS);
	    }
	  else go_grid = me->locate_event.located_object[0].located_obj;
	     
/*	  status =
	  as$make_source(
			 go_grid =
			 me->locate_event.located_object[0].located_obj,
			 context_grid = context,
			 as_os = me->md_env.md_id.osnum,
			 as_grid = &me->list[FEATURE_PAR_REF_POINT]);
	  if(!(status &1))
	    {
	      printf(" Cannot create ref point \n");
	    }
	  else
*/
	  status = dm$create_root( type =DMkeypt,
				  count =1,
				  list = &go_grid,
				  context = &context,
				  attr = attr,
				  md_env = &me->md_env,
				  p_root = &me->list[FEATURE_PAR_REF_POINT]);
	  if(status &1)
	    {
	      if(me->pattern.type == GR_ASCOPY_POLAR)
	      {
              if( me->list[POLAR_PAR_CENTER].objid != NULL_OBJID)
                {
	            status = 
	            om$send(msg = message NDnode.NDgive_structure(
					 &long_rc,
                                         &info_struct,
                                         &me->md_env),
		     targetid = me->list[FEATURE_PAR_REF_POINT].objid,
		     targetos  = me->list[FEATURE_PAR_REF_POINT].osnum);
	            fe$status(action = RET_STATUS);

	            me->ref_point[0] = info_struct.var.point_st.pt[0];
	            me->ref_point[1] = info_struct.var.point_st.pt[1];
	            me->ref_point[2] = info_struct.var.point_st.pt[2];

                  if( BSdistptpts(&bsrc,me->center,me->ref_point) > 1e-4)
                    me->state = GET_RADIAL_DIR;
                  else
                   ex$message(msgnumb = EMS_S_CenRefptDiff);
                }
	      }
	      else 
	      me->state = SEL_MAT_DIR_X ;
	    }
	}
      else if( *response == EX_BACK_UP)
	{
	  if(me->pattern.type == GR_ASCOPY_RECTANGULAR)
	    {
	      me->fea_count = 0;
	      me->state = LOC_PAT_FEATURE;
	    }
	  else 
	    me->state = LOC_RADIAL_CENPT;
	}
	
      break;

    case SEL_MAT_DIR_X:
    case GET_RADIAL_DIR:
      me->fea_props &= ~REF_DIR_X_NEG;
    case SEL_MAT_DIR_Y:
      me->fea_props &= ~REF_DIR_Y_NEG;

      dp$erase_hilite(msg = &long_rc);
	
      ex$message(msgnumb = promptkey[me->state]);
      status = 
      om$send(msg = message ECfepattern.select_axis( &long_rc,
						    response,
						    response_data),
	      targetid = my_id);
      fe$status(action = RET_STATUS);

      dp$erase_hilite(msg = &long_rc);

      if( me->state == SEL_MAT_DIR_X && me->event1.response == EX_RJT_MOVEON)
	{
	  me->pattern.var.matrix.rows = 1;
	  me->state = SEL_MAT_DIR_Y;
	  break;
	}
      else if( me->state == SEL_MAT_DIR_Y && 
	      me->event1.response == EX_RJT_MOVEON)
	{
	  if( me->pattern.var.matrix.rows != 1)
	    {
	      me->pattern.var.matrix.cols= 1;
	      me->state = CONSTRUCT_PATTERN;
	    }
	  else
	    {
	      me->state = SEL_MAT_DIR_X;
	      ex$message(msgnumb = EMS_I_RowColGtOne);
	    }
	  break;
	}
      else if( me->state == GET_RADIAL_DIR && 
	      me->event1.response == EX_RJT_MOVEON)
	{
	  win_grid.objid = me->locate_event.event.button.objid;
	  win_grid.osnum = me->locate_event.event.button.osnum;

	  BSmkvec(&long_rc,newvec,me->center,me->ref_point);
	  BScrossp(&long_rc, newvec,&me->plane[8],newvec2);
	  BSnorvec(&long_rc,newvec2);
	  dist = BSdistptpt(&long_rc,me->ref_point,me->center);
	  newpt[0] = me->ref_point[0];
	  newpt[1] = me->ref_point[1];
	  newpt[2] = me->ref_point[2];

	  if(me->fea_props & REF_DIR_X_NEG)
	    bool_dir = 1;
	  else
	    bool_dir = -1;

	  me->event1.event.button.x = newpt[0] + bool_dir*newvec2[0]*dist;
	  me->event1.event.button.y = newpt[1] + bool_dir*newvec2[1]*dist;
	  me->event1.event.button.z = newpt[2] + bool_dir*newvec2[2]*dist;

	  EFshow_dynamic_arrow(&long_rc,&win_grid,me->ref_point,me->center,
			       me->plane,attr,me->state,
			       &me->event1.event.button,
			       FALSE);
	    me->state = NUM_RADIAL_OBJ;
	}
      else if(me->event1.response == EX_DATA)
	{
	  /* Accept the entered direction */
	  win_grid.objid = me->event1.event.button.objid;
	  win_grid.osnum = me->event1.event.button.osnum;
      
	  EFshow_dynamic_arrow(&long_rc,&win_grid,me->ref_point,me->center,
			       me->plane,attr,me->state,
			       &me->event1.event.button,
			       FALSE);
	  if(me->state == SEL_MAT_DIR_X)
	    me->state = NUM_MAT_XOBJ;
	  else if(me->state == SEL_MAT_DIR_Y)
	    me->state = NUM_MAT_YOBJ;
	  else
	    me->state = NUM_RADIAL_OBJ;
	}
      else if(*response == EX_BACK_UP)
	      me->state = (me->pattern.type == GR_ASCOPY_RECTANGULAR ?
			 --me->state:LOC_REF_POINT);
      
      break;

    case NUM_MAT_XOBJ:
    case NUM_MAT_YOBJ:
    case DIST_MAT_XDELTA:
    case DIST_MAT_YDELTA:

      if(me->state == NUM_MAT_XOBJ)
	{
	  ex$message(msgnumb = EMS_I_NmIncSelEl);
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%d",
		     var = me->pattern.var.matrix.rows);
	}
      else if(me->state == NUM_MAT_YOBJ)
	{
	  ex$message(msgnumb = EMS_I_NmIncSelEl);
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%d",
		     var = me->pattern.var.matrix.cols);
	}
      else if(me->state == DIST_MAT_XDELTA)
	{
	  ex$message(msgnumb = EMS_I_ValPositive);
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%3.2lf",
		     var = me->pattern.var.matrix.Xdelta);
	}
      else if(me->state == DIST_MAT_YDELTA)
	{
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%3.2lf",
		     var = me->pattern.var.matrix.Ydelta);
	  ex$message(msgnumb = EMS_I_ValPositive);
	}

      status =
      ems$getevent( msg = &long_rc,
		   value_type = GRIO_DISTANCE,
		  event_mask = eventmask3,
		  response = (long *)response,
		  response_data = response_data,
		  event = &me->event1);
      fe$status(action = RET_STATUS);

      if( *response == CMD_STRING)
	me->ref_props = 0;
      else me->ref_props = 1;

      if( *response == EX_BACK_UP)
	{
	  me->state--;
	  break;
	}
      else if( *response != STRING && *response != EX_RJT_MOVEON)
        break;
      switch(me->state)
	{
	case NUM_MAT_XOBJ:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_integer(me->event1.event.keyin))
		me->pattern.var.matrix.rows = atoi(me->event1.event.keyin);
	      else break;
	      if(me->pattern.var.matrix.rows == 1)
		me->state = SEL_MAT_DIR_Y;
	      else if(me->pattern.var.matrix.rows >1)	    
		me->state = DIST_MAT_XDELTA;
	    }
	  else if( me->pattern.var.matrix.rows >1)
	    me->state = DIST_MAT_XDELTA;
	  break;

	case NUM_MAT_YOBJ:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_integer(me->event1.event.keyin))
		me->pattern.var.matrix.cols = atoi(me->event1.event.keyin);
	      else break;
		
	      if(me->pattern.var.matrix.cols == 1)
		if(me->pattern.var.matrix.rows ==1)
		  {
		    ex$message(msgnumb = EMS_I_RowColGtOne);
		    me->state = NUM_MAT_XOBJ;
		  }
		else
		  me->state = CONSTRUCT_PATTERN;
	      else me->state = DIST_MAT_YDELTA;
	    }
	  else if(me->pattern.var.matrix.cols > 1)
	    me->state = DIST_MAT_YDELTA;
	  break;

	case DIST_MAT_XDELTA:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_double(me->event1.event.keyin))
		{
		  me->pattern.var.matrix.Xdelta = 
		    atof(me->event1.event.keyin);
		  me->state = SEL_MAT_DIR_Y;
		}
	    }
	  else me->state = SEL_MAT_DIR_Y;
	  break;

	case DIST_MAT_YDELTA:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_double(me->event1.event.keyin))
		{
		  me->pattern.var.matrix.Ydelta = 
		    atof(me->event1.event.keyin);
		  me->state = CONSTRUCT_PATTERN;
		}
	    }
	  else  me->state = CONSTRUCT_PATTERN;
	  break;

	default:
	  printf(" Unknown Matrix State:%d\n",me->state);
	}
      break;

    case LOC_RADIAL_CENPT:
      dp$erase_hilite(msg = &long_rc);
      if(me->list[FEATURE_PAR_REF_POINT].objid != NULL_OBJID)
	{
	  acc_key = EMS_P_AcceptReject;
	  putacc = FALSE;
	}
      else 
	{
	  acc_key = EMS_P_AcRefPt;
	  putacc = TRUE;
	}
      status = om$send( msg = message ECfepattern.locate_element(
						  response,
						  response_data,
						  putacc,
						  promptkey[me->state],
						  acc_key,
						  EMS_I_PtLnElNtFd),
		       targetid = my_id);
      fe$status(action = RET_STATUS);
      if(me->locate_rc == LC_OBJ_LOCATED)
	{
	  context.objid = NULL_OBJID; /* Do not locate ref file  elements */
	  me->center[0] = attr[0] = me->event1.event.button.x;
	  me->center[1] = attr[1] = me->event1.event.button.y;
	  me->center[2] = attr[2] = me->event1.event.button.z;

	  status = dm$create_root( type =DMkeypt,
				  count =1,
				  list = &me->locate_event.located_object[0].located_obj,
				  context = &context,
				  attr = attr,
				  md_env = &me->md_env,
				  p_root = &me->list[POLAR_PAR_CENTER]);


	  if(!(status &1))
	    {
#ifdef DEBUG
	      printf(" Cannot create ref point \n");
#endif
	    }
	  else
	    {
	      status = 
	      om$send(msg = message NDnode.NDgive_structure(
					 &long_rc,
                                         &info_struct,
                                         &me->md_env),
			targetid = me->list[POLAR_PAR_CENTER].objid,
			targetos = me->list[POLAR_PAR_CENTER].osnum);
	      fe$status(action = RET_STATUS);

	      me->center[0] = info_struct.var.point_st.pt[0];
	      me->center[1] = info_struct.var.point_st.pt[1];
	      me->center[2] = info_struct.var.point_st.pt[2];

	      if(me->list[FEATURE_PAR_REF_POINT].objid != NULL_OBJID)
		{
		  if( BSdistptpts(&bsrc,me->center,me->ref_point) > 1e-4)
		    me->state = GET_RADIAL_DIR;
                  else
                   ex$message(msgnumb = EMS_S_CenRefptDiff);
		}
	      else
		me->state = LOC_REF_POINT;
	    }
	}
      else if( *response == EX_BACK_UP)
	me->state = LOC_PAT_FEATURE;
      break;

    case NUM_RADIAL_OBJ:
    case GET_RADIAL_ANGLE:

      if(me->state == NUM_RADIAL_OBJ)
	{
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%ld",
		     var = me->pattern.var.polar.num_copies);
	}
      else
	{
	  me->pattern.var.polar.sweep_angle = 
	    360.0/(double)me->pattern.var.polar.num_copies;
	  ex$message(msgnumb = promptkey[me->state],
		     type = "%4.2lf",
		     var = me->pattern.var.polar.sweep_angle);
	}

      status =
      ems$getevent(msg = &long_rc,
		   value_type = GRIO_ANGLE,
		   event_mask = eventmask3,
		   response = (long *)response,
		   response_data = response_data,
		   event = &me->event1);
      fe$status(action = RET_STATUS);

      if(*response == CMD_STRING)
	me->ref_props = 0;
      else me->ref_props = 1;
      if( *response == EX_BACK_UP) 
	{
	  me->state --;
	  break;
	}
      if(me->event1.response != STRING && *response != EX_RJT_MOVEON)
	break;

      switch(me->state)
	{
	case NUM_RADIAL_OBJ:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_integer(me->event1.event.keyin))
		{
		  me->pattern.var.polar.num_copies =
		    atoi(me->event1.event.keyin);
		  me->state = GET_RADIAL_ANGLE;
		}
	    }
	  else me->state = GET_RADIAL_ANGLE;
	  
	  break;

	case GET_RADIAL_ANGLE:
	  if( long_rc != GRw_no_value && *response != EX_RJT_MOVEON)
	    {
	      if(EMinput_is_a_positive_double(me->event1.event.keyin))
		{
		  me->pattern.var.polar.sweep_angle =
		    atof(me->event1.event.keyin);
		  /* Initialize unused fields and process_pattern */
		  me->state = CONSTRUCT_PATTERN;
		}
	    }
	  else me->state = CONSTRUCT_PATTERN;
	  me->pattern.var.polar.num_sweeps = 1;
	  me->pattern.var.polar.start_angle = 0.0;
	  break;

	default:
	  printf(" Unknown Radial type:%d\n",me->state);
	  break;
	}
      break;

    case CONSTRUCT_PATTERN:

      dp$erase_hilite(msg = &long_rc);
      win_grid.objid = me->locate_event.event.button.objid;
      win_grid.osnum = me->locate_event.event.button.osnum;

      ECdisplay_pattern_by_cross(&rc,&win_grid,me->plane,&me->pattern,
				 me->fea_props,me->ref_point,me->center);

      ex$message(msgnumb = promptkey[me->state]);

      status =
      ems$getevent(msg = &long_rc,
		   value_type = GRIO_DISTANCE,
		   event_mask = me->eventmask2,
		   response = (long *)response,
		   response_data = response_data,
		   event = &me->event1);
      fe$status(action = RET_STATUS);
      
      if( *response == DATA)
	{
	  status = 
	  om$send(msg = message ECfepattern.construct_pattern(&long_rc ),
		  targetid = my_id);
	  fe$status(action = RET_STATUS);
	  me->state = LOC_REF_PLANE;
	}
      else if( *response == EX_BACK_UP)
	{
	  if( me->pattern.type == GR_ASCOPY_RECTANGULAR)
	    {
	      if(me->pattern.var.matrix.cols >1)
		me->state = DIST_MAT_YDELTA;
	      else 
		me->state = DIST_MAT_XDELTA;
	    }
	  else
	    me->state = GET_RADIAL_ANGLE;
	}
      dp$erase_hilite(msg = &long_rc);
      break;

    default:
      printf("ECfepattern: Unknown super cmd state:%d\n",me->state);
      break;
    }

    switch( *response)
      {
      case EX_DATA:
      case EX_RJT_MOVEON:
      case EX_BACK_UP:
	break;
      case STRING:
      case CMD_STRING:
       if(me->ref_props
          ||  me->state ==  NUM_MAT_XOBJ
          ||  me->state ==  NUM_MAT_YOBJ
          ||  me->state ==  DIST_MAT_XDELTA
          ||  me->state ==  DIST_MAT_YDELTA
          ||  me->state ==  NUM_RADIAL_OBJ
          ||  me->state ==  GET_RADIAL_ANGLE)
	  {
	    me->ref_props = 0;
	    break;
	  }
	return(OM_S_SUCCESS);
      case EX_CMD_KEY:
	status =
	ex$get_cmd_info(string = response_data,
			mode = (*response == EX_CMD_KEY)?
			       EX_CMD_KEY:EX_STRING,
			cmdstr = &cmdstr);
	return(OM_S_SUCCESS);
      case STATUS_DISP:
	if(me->state < LOC_REF_POINT)
	  {
	    FIf_display(me->form);
	    me->form_displayed = TRUE;
	    return(OM_S_SUCCESS);
	  }
	break;	
      default:
	return(OM_S_SUCCESS);
      }
  }
}

method delete( int f_defer_flag)
{
  IGRint status;

  FIf_delete(me->form);

  status =
  om$send(msg = message super_cmd.delete(f_defer_flag),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  fe$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}

method locate_element( IGRint *response;
		       char *response_data;
		       IGRint putque_acc;
		       IGRint LocKey, AccKey, RelocKey)
{

  IGRint status;
  IGRlong long_rc,event_size,save_locate;
  OM_S_CLASSLIST rtree_classes,elig_classes;

  OMuword r_classes[2],e_classes[4];
  IGRchar locate_prompt[MAX_PROMPT_SIZE],
          acc_prompt[MAX_PROMPT_SIZE],
          relocate_prompt[MAX_PROMPT_SIZE];
  struct EMSaction_handler already_located;
  extern IGRlong EFlocate_action_handler();
  char *fun_args,*act_args;
  struct GRevent locevent;
  struct GRid my_grid ,active_GRid;
  struct GRlc_dynamics lcdyn,*dyn_fun;
  IGRint ECpattern_locate_dynamics();
  IGRint EFpattern_action_handler();
  IGRint display_flag;
  struct GRlc_locate attributes;
  IGRint (*fptr)();
  int owner_action;
  IGRboolean aflag = 0;

  extern unsigned char EMS_locate_features;
  extern GRclassid OPP_EMSsurface_class_id,
                   OPP_GRdrawview_class_id,
                   OPP_GRreffile_class_id,
                   OPP_GRbspline_class_id;
  event_size = sizeof(struct GRevent);
  rtree_classes.w_count = 0;
  elig_classes.w_count = 1;
  rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
  save_locate = EMS_locate_features;
  
  rtree_classes.p_classes = r_classes;
  elig_classes.p_classes = e_classes;

  ex$message(msgnumb = LocKey, buff = locate_prompt);
  ex$message(msgnumb = AccKey,    buff = acc_prompt);
  ex$message(msgnumb = RelocKey,  buff = relocate_prompt);

  owner_action = me->attr.owner_action;
  fun_args = NULL;
  dyn_fun = NULL;
  fptr = NULL;
  act_args = NULL;

  switch(me->state)
  {
  case LOC_REF_PLANE:
    e_classes[0] = OPP_EMSdatpln_class_id;
    owner_action |= LC_HANDLES;
    break;

  case  LOC_PAT_FEATURE:
    rtree_classes.w_count = 1;
    e_classes[0] = OPP_EMSdpr_class_id;
    r_classes[0] = OPP_EMSsubbs_class_id;
    EMS_locate_features = TRUE;
    already_located.type =1;
    already_located.next = NULL;
    already_located.option = 0;
    already_located.num_objects = 0;
    already_located.objects.id = NULL;
    me->display_flag |= DO_NOT_RELOCATE;
    fptr = EFpattern_action_handler;
    act_args = (char *)&me->stack;
    break;

  case LOC_REF_POINT:
  case LOC_RADIAL_CENPT:
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    rtree_classes.w_count = 1;
    r_classes[0] = OPP_GRbspline_class_id;
    elig_classes.w_count = 3;    
    e_classes[0] = OPP_GRbspline_class_id;
    e_classes[1] = OPP_EMSparampt_class_id;
    e_classes[2] = OPP_SKptvar_class_id;

    aflag = pwIsActivationOn();

    if(aflag)
    {
     owner_action =  LC_RIGID_COMP| LC_FLEX_COMP |
                     LC_RIGID_OWNER    | 
                     LC_NO_REF_HEADER  |
                     LC_REF_OBJECTS    |
                     LC_ASSOCIATIVE    |
                     LC_EXTERN_CONSTRAINED;
    }
    else
    {
     owner_action =  LC_RIGID_COMP| LC_FLEX_COMP |
                     LC_RIGID_OWNER    | 
                     LC_NO_REF_HEADER  |
                     LC_NO_REF_OBJECTS    |
                     LC_ASSOCIATIVE    |
                     LC_EXTERN_CONSTRAINED;
    }
    lcdyn.GRlc_dyn= ECpattern_locate_dynamics;
    lcdyn.add_info = (IGRchar *)&my_grid;
    break;
  }

  me->attr.owner_action = owner_action ;   
  me->stack.num_entries = 0;
  status =
  lc$locate(
	rc = &me->locate_rc,
	event1 = &me->event1,
	event2 = &me->event2,
	event3 = &locevent,
	mask1 = me->eventmask1,
	mask2 = me->eventmask2,
	display_flag = me->display_flag,
	response = response,
	response_data = response_data,
	locate_prompt = locate_prompt,
	acc_prompt = acc_prompt,
	relocate_prompt = relocate_prompt,
	attributes = &me->attr,
	stack = &me->stack,
	dyn = dyn_fun,
	act_handler = fptr,
	act_args = act_args,
	rtree_classes =&rtree_classes,
	eligible_classes = &elig_classes);
  fe$status(action = RET_STATUS);

  me->attr.owner_action &= ~LC_HANDLES;
    EMS_locate_features = save_locate;

  if(me->locate_rc ==  LC_OBJ_LOCATED )
  {
    if(putque_acc && me->event1.response == EX_DATA 
       && me->event1.subtype == GRst_REGULAR)
      {
	status = ex$putque(msg = &long_rc,
			   response = &me->event2.response,
			   byte = &event_size,
			   buffer = (IGRchar *) &me->event2.event);
      }
    me->locate_event = me->event1;
    me->locate_event.num_id = locevent.num_id;
    me->locate_event.located_object[0] = locevent.located_object[0];

    if(me->state == LOC_PAT_FEATURE && me->locate_rc ==  LC_OBJ_LOCATED &&
       !EFcheck_pattern_feature(&long_rc,&locevent.located_object[0],
				EMS_PAT_LOC_FEATURE))
      {
	me->locate_rc = LC_NO_OBJ_LOCATED;
	/* We need to send a hilighted display to the object */
      }
  }
  else if( me->locate_rc == LC_NO_OBJ_LOCATED && 
	   me->event1.response == EX_DATA   &&
	   me->state == LOC_PAT_FEATURE )
    {

	status = ex$putque(msg = &long_rc,
			   response = &me->event1.response,
			   byte = &event_size,
			   buffer = (IGRchar *) &me->event1.event);
      display_flag = 
	ELEM_HILIGHT                |  /* Hilite the whole element */
	NO_PROJ_ACCEPT_POINT        |  /* Don't project the accept point */
        ACC_REJ_CYCLE               |  /* Run through accept reject cycle */
	LC_REGULAR_HIGHLIGHT        |  /* Use regular hilite not 1/2 */
	LC_ERASE_ALL;                  /* Erase the hilite plane */
      /* DO_NOT_RELOCATE             |  Relocate if none found */
 
      attributes.properties = 
         LC_LC_ONLY                |  /* Locate locatable objects */
         LC_DP_ONLY                |  /* Locate displayable objects */
         IGN_MOD_BIT               |  /* Ignore modified and new props */
         LC_PLANAR_NON_PLANAR      |  /* Planarity doesn't matter */
	 LC_RW;

      attributes.owner_action =   LC_FLEX_COMP | 
	                        LC_RIGID_OWNER |
                                 LC_RIGID_COMP |
                               (LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED);

      rtree_classes.w_count = 1;
      elig_classes.w_count = 3;
      r_classes[0] = OPP_GRvg_class_id;
      e_classes[0] = OPP_EMSsurface_class_id;
      e_classes[1] = OPP_GRdrawview_class_id;
      e_classes[2] = OPP_GRreffile_class_id;
      ex$message(msgnumb = EMS_I_SlSfFeaNFd,  buff = relocate_prompt);

      status =
      lc$locate(
        rc = &me->locate_rc,
	event1 = &me->event1,
	event2 = &me->event2,
	event3 = &locevent,
	mask1 = me->eventmask1,
	mask2 = me->eventmask2,
	display_flag = display_flag,
	response = response,
	response_data = response_data,
	locate_prompt = locate_prompt,
	acc_prompt = acc_prompt,
	relocate_prompt = relocate_prompt,
	attributes = &attributes,
	stack = &me->stack,
	dyn = dyn_fun,
	rtree_classes =&rtree_classes,
	eligible_classes = &elig_classes);
      fe$status(action = RET_STATUS);
      
      if(me->locate_rc ==  LC_OBJ_LOCATED &&
	 EFisAncestryValid(&long_rc, 
			   locevent.located_object[0].located_obj.objid,
			   locevent.located_object[0].located_obj.osnum,
			   OPP_EMSsurface_class_id, FALSE))
	{
	  status =
	  om$send( msg = message EMSsurface.EMgetactiveid(
				    &long_rc,
				    &active_GRid,
				    NULL),
	      targetid = locevent.located_object[0].located_obj.objid,
	      targetos = locevent.located_object[0].located_obj.osnum);
	  if(!(status &1))
	    {
	      me->locate_rc = LC_NO_OBJ_LOCATED;
	      return(OM_S_SUCCESS);
	    }

	  if( locevent.located_object[0].located_obj.objid != 
	      active_GRid.objid)
	    {
	      me->locate_rc = LC_NO_OBJ_LOCATED;
	      return(OM_S_SUCCESS);
	    }
	}
	me->locate_event.num_id = locevent.num_id;
	me->locate_event.located_object[0] = locevent.located_object[0];
	me->fea_props|= NOT_A_FEATURE;
    }
  else if( (*response == STRING || *response == CMD_STRING) && 
	  me->state < LOC_DEP_FEATURE )
    {
      if(strlen(response_data) == 1 && 
	 (toupper(response_data[0]) == 'R' ||
	   toupper(response_data[0]) == 'M'))
	{
	  int label;
	  me->ref_props  = 1;
	  label = (toupper(me->event1.event.keyin[0]) == 'R' ? POLAR:MATRIX);
	  status = 
	  om$send( msg = message ECfepattern.notify_form(1,label,1.0,me->form),
		  targetid = my_id);
	  fe$status(action = RET_STATUS);
	}
    }

  return(OM_S_SUCCESS);
}

method select_axis( IGRlong *msg;
		   IGRint *response;
		   IGRchar *response_data)
{
  IGRint status,rc,nbytes;
  IGRdouble vec[3],newvec[3],newvec2[3],dotp;
  IGRlong long_rc;
  struct GRid win_grid;

  win_grid.objid = me->locate_event.event.button.objid;
  win_grid.osnum = me->locate_event.event.button.osnum;


  EFshow_dynamic_arrow(msg,&win_grid,me->ref_point,
		       me->center,me->plane,vec,me->state,NULL,TRUE);

  status =
  co$getevent(
	      msg = &rc,
	      event_mask = me->eventmask2,
	      msgnum = promptkey[me->state],
	      nbytes = &nbytes,
	      response = response,
	      response_data = response_data,
	      event = &me->event1);
  fe$status(action = RET_STATUS);

  if(*response == EX_DATA )
    {
      EFshow_dynamic_arrow(msg,&win_grid,me->ref_point,
		       me->center,me->plane,vec,me->state,
			   &me->event1.event.button,FALSE);
    }

  if(me->state == SEL_MAT_DIR_X)
    {
      dotp = BSdotp(&long_rc,vec,me->plane);
      if(dotp < 0)
	me->fea_props |= REF_DIR_X_NEG;
    }
  else if( me->state == SEL_MAT_DIR_Y)
    {
      dotp = BSdotp(&long_rc,vec,&me->plane[4]);
      if(dotp < 0)
	{
	  me->fea_props |= REF_DIR_Y_NEG;
	}
    }  
  else 
    {
      BSmkvec(&long_rc,newvec,me->center,me->ref_point);
      BScrossp(&long_rc, newvec,&me->plane[8],newvec2);
      dotp = BSdotp(&long_rc,vec,newvec2);
      if(dotp > 0.0)
	me->fea_props |= REF_DIR_X_NEG;
      if(*response == RESET)
	{
	  if(me->fea_props & REF_DIR_X_NEG)
	    me->fea_props &=(~REF_DIR_X_NEG);
	  else  me->fea_props |=REF_DIR_X_NEG;
	}
    }
  return(OM_S_SUCCESS);
}
method set_ref_props( IGRlong *msg; IGRint inq0_set1; IGRint *ref_props)
{
  if(inq0_set1)
    me->ref_props = *ref_props;
  else
    *ref_props = me->ref_props;
  return(OM_S_SUCCESS);
}

method display_next(IGRlong *msg)
{
  IGRint status,num_parents;
  struct GRid parents[MAX_FEATURE_PARENTS],ngrid;
  enum GRdpmode mode;
  extern unsigned char EMS_locate_features;
  unsigned char loc_feature;
  struct GRobj_info info;

  *msg = TRUE;
  me->next_grid.objid = NULL_OBJID;

  status = om$get_objid_at_index(
	   objid = me->feature[me->fea_count -1].objid,
	   osnum = me->feature[me->fea_count -1].osnum,
	   p_chanselect = &AS_to_owner,
	   index = 0,
	   objidaddr = &me->next_grid.objid,
	   osnumaddr = &me->next_grid.osnum);

  if(!(status & 1) || (!EFcheck_pattern_feature(msg,&me->next_grid,0)))
    {
      *msg = FALSE;
      return(OM_S_SUCCESS);
    }
    
  status = 
  om$send(msg = message NDnode.NDget_objects(
				     ND_ROOT,
				     parents,
				     MAX_FS_PARENTS,
				     NULL,
				     0,
				     MAX_FS_PARENTS - 1,
				     &num_parents),
		   targetid = me->next_grid.objid,
		   targetos = me->next_grid.osnum);

  if( status == OM_W_UNKNOWN_MSG)
    {
      *msg = FALSE;
      return(OM_S_SUCCESS);
    }

  if(EFisAncestryValid(msg,parents[num_parents - 2].objid,
      parents[num_parents - 2].osnum,OPP_EMSpointer_class_id,FALSE))
    {
      status = om$get_objid_at_index(
	   objid = parents[num_parents - 2].objid,
	   osnum = parents[num_parents - 2].osnum,
	   p_chanselect = &ND_father,
	   index = 0,
	   objidaddr = &ngrid.objid,
	   osnumaddr = &ngrid.osnum);
	fe$status(action = RET_STATUS);

      if( ngrid.objid != me->feature[me->fea_count -1].objid)
	me->next_grid.objid = NULL_OBJID;
    }
  else if( parents[num_parents - 1].objid != 
	   me->feature[me->fea_count -1].objid)
     me->next_grid.objid = NULL_OBJID;
    
  mode = GRhd;

  if(me->next_grid.objid == NULL_OBJID)
    {
      *msg =FALSE;
      return(OM_S_SUCCESS);
    }

  loc_feature = EMS_locate_features;
  EMS_locate_features = TRUE;
  status =
  om$send(msg = message GRgraphics.GRdisplay(
				 msg,
				 &me->md_env.md_env.matrix_type,
				 me->md_env.md_env.matrix,
				 &mode,
				 &me->md_env.md_id),
	    targetid = me->next_grid.objid,
	    targetos = me->next_grid.osnum);

  EMS_locate_features = loc_feature;
  fe$status(action = RET_STATUS);

  status = 
  om$send(msg = message GRgraphics.GRgetobjinfo(msg,&info),
	  targetid = me->next_grid.objid,
	  targetos = me->next_grid.osnum);
  fe$status(action = RET_STATUS);

  ex$message(in_buff = info.type, field = ERROR_FIELD);
  return(OM_S_SUCCESS);
}

method construct_pattern(IGRlong *msg)
{

  IGRint status, i;
  IGRlong long_rc;
  struct EMpat_attr pat_attr;
  int num_parents,info;
  struct GRid null_grid;
  struct GRas assoc_list;

  if(me->pattern_id.objid != NULL_OBJID)
    return(OM_S_SUCCESS);

  num_parents = (me->pattern.type == GR_ASCOPY_RECTANGULAR ? 6:5 );

  for( i = 0; i < me->fea_count; i++)
    me->list[num_parents++] = me->feature[i];

  pat_attr.pattern = me->pattern;
  pat_attr.fea_props = me->fea_props;

  null_grid.objid = NULL_OBJID;
  assoc_list.num_parents  = num_parents;
  assoc_list.parents      = me->list;
  assoc_list.context      = &null_grid;
  assoc_list.as_attr      = (char *)&pat_attr;

  me->pattern_id.osnum = me->md_env.md_id.osnum;

  status = 
  om$construct(classid = OPP_EMSpatfea_class_id,
	       p_objid = &me->pattern_id.objid,
	       msg = message EMSpatfea.NDplace(
				 &assoc_list,
				 &me->md_env,
				 NULL),
	       osnum =  me->pattern_id.osnum);
  if( !(status &1))
    {
      fe$status(action=RET_STATUS);
    }
/* 
  Compute the pattern, if delay mode is on 
*/

  status =
  om$send(msg = message NDnode.NDs_compute_node(&long_rc, ND_COMP,
						&me->md_env),
	    targetid = me->pattern_id.objid,
	    targetos = me->pattern_id.osnum);
  fe$status(action = RET_STATUS);
  
  info = ND_COMP;
  nd$wait_batch(
		type = GR_GEOM_POSTED,
		l_object = &me->pattern_id,
		l_obj_info = &info,
		nb_obj   = 1);

  nd$exec_batch();
  for( i = 0 ; i< MAX_FEATURE_PARENTS; i++)
    me->list[i].objid = NULL_OBJID;
  me->pattern_id.objid = NULL_OBJID;
  return(OM_S_SUCCESS);
}

EMfeature_pattern_notification ( f_label, g_label, value, fp )
     int     f_label;       /* The label of the form   */
     int     g_label;       /* The label of the gadget */
     IGRdouble  value;         /* The value of the gadget */
     Form    fp;            /* Pointer to the form     */
{

  int status;
  OM_S_OBJID objid;
  OMuword osnum;

  status =
  FIf_get_cmd_oid_os(fp, &objid, &osnum);
  if (status != FI_SUCCESS)
    {
      return(FALSE);
    }

  status =
  om$send(msg = message ECfepattern.notify_form(f_label,
					  g_label,
					  value,
					  fp),
	  senderid = NULL_OBJID,
	  targetid = objid,
	  targetos = osnum);
  fe$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}

method notify_form( 
     int     f_label;
     int     g_label;
     double  value;
     Form    fp)
  {

  switch ( g_label )
    {
    case FI_CANCEL:
      FIg_set_value(fp,FI_CANCEL,0.0);
      FIf_erase ( fp );
      me->form_displayed = FALSE;
      break;

    case FI_ACCEPT:
      FIg_set_value(fp,FI_ACCEPT,0.0);
      /* Erase the displayed form */

      me->form_displayed = FALSE;
      FIf_erase ( fp );

      break;

    case MATRIX:

      me->pattern.type = GR_ASCOPY_RECTANGULAR;
      FIg_set_value(fp,POLAR,0.0);
      FIg_set_value(fp,MATRIX,1.0);
      me->pattern.var.matrix.rows = 4;
      me->pattern.var.matrix.cols = 4;

      break;

    case POLAR:

      me->pattern.type = GR_ASCOPY_POLAR;
      FIg_set_value(fp,POLAR,1.0);
      FIg_set_value(fp,MATRIX,0.0);
      me->pattern.var.polar.num_copies = 4;
      break;
    default:
#ifdef DEBUG
      printf(" Unknown pattern gadget no:%d\n",g_label);
#endif
      break;
  }

  return(OM_S_SUCCESS);
}

method show_axis( IGRlong *msg;
		 struct GRevent *event)
{
  IGRint status,options,state;
  IGRdouble origin[3],vec[3],newvec[3],dotp;
  IGRlong long_rc;
  struct GRid win_grid;

  win_grid.objid = event->event.button.objid;
  win_grid.osnum = event->event.button.osnum;

  if( me->state == LOC_RADIAL_CENPT)
    {
      if(me->list[FEATURE_PAR_REF_POINT].objid == NULL_OBJID)
	return(OM_S_SUCCESS);
      me->center[0] = event->event.button.x;
      me->center[1] = event->event.button.y;
      me->center[2] = event->event.button.z;
    }
  else
    {
      me->ref_point[0] = event->event.button.x;
      me->ref_point[1] = event->event.button.y;
      me->ref_point[2] = event->event.button.z;
    }

  state = me->state + 1;
  EFshow_dynamic_arrow(msg,&win_grid,me->ref_point,
		       me->center,me->plane,vec,state,NULL,TRUE);

  if(state == SEL_MAT_DIR_X)
    {
      dotp = BSdotp(&long_rc,vec,me->plane);
      if(dotp < 0)
	me->fea_props |= REF_DIR_X_NEG;
    }
  else if (state == SEL_MAT_DIR_Y)
    {
      dotp = BSdotp(&long_rc,vec,&me->plane[4]);
      if(dotp < 0)
	me->fea_props |= REF_DIR_Y_NEG;
    } 
  else 
    {
      BSmkvec(&long_rc,newvec,me->center,me->ref_point);
      
      dotp = BSdotp(&long_rc,vec,newvec);
      if(dotp < 0)
	me->fea_props |= REF_DIR_X_NEG;
    }

  return(OM_S_SUCCESS);
}
ECdisplay_pattern_by_cross(rc,win_grid,plane,pattern,
			   fea_props,ref_point,center)
     IGRint *rc;
     struct GRid *win_grid;
     struct GRas_pattern *pattern;
     IGRint fea_props;
     IGRdouble *ref_point,*center,*plane;
{
  IGRlong long_rc,one = 1;
  struct IGRdisplay display;
  struct DPele_header buffer[2];
  struct IGRpolyline line1,line2;
  IGRdouble pt_buffer[12],angle;
  IGRint xflag,yflag;
  IGRint i,j;
  struct GRptrn_matrix *matrix;
  struct GRptrn_polar  *polar;
  IGRdouble xdir[3],ydir[3],mark_pt[3];
  IGRdouble dittol;
  IGRmatrix rot_matrix;
  void ECdisplay_pattern_position();

  ECget_window_dittol (win_grid, &dittol);

  display.color  = 0;
  display.weight = 1;
  display.style  = 0;

  line1.num_points	= 2;
  line1.points		= &pt_buffer[0];

  line2.num_points	= 2;
  line2.points		= &pt_buffer[6];

  dp$build_dis_buffer(
	 buffer = &buffer[0],
	 type = IGRPY,
	 display_att = &display,
	 geometry = &line1);


  dp$build_dis_buffer(
          buffer = &buffer[1],
          type = IGRPY,
          display_att = &display,
          geometry = &line2);

  for( i = 0; i< 3; i++)
    {
      xdir[i] = plane[i];
      ydir[i] = plane[4+i];
    }
      
  if( pattern->type == GR_ASCOPY_RECTANGULAR)
    {
      matrix = &pattern->var.matrix;
      xflag = (fea_props & REF_DIR_X_NEG ? -1:1);
      yflag = (fea_props & REF_DIR_Y_NEG ? -1:1);

      for( i = 0; i< 3; i++)
	{
	  xdir[i] = xflag * plane[i];
	  ydir[i] = yflag * plane[4+i];
	}
      
      for( i = 0; i < matrix->rows; i++)
	{
	  for( j = 0; j < matrix->cols; j++)
	    {
	      if( i ==0 && j== 0 ) continue;
      
	      fe_projpt(ref_point,i*matrix->Xdelta,xdir,mark_pt);
	      fe_projpt(mark_pt,j*matrix->Ydelta,ydir,mark_pt);
	      ECdisplay_pattern_position(&rc,xdir,ydir,mark_pt,dittol,buffer);
	    }
	}      
    }
  else /* pattern type is radial */
    {
      MAidmx(&long_rc,rot_matrix);
      /* Project centerpoint on to ref plane */
      polar = &pattern->var.polar;
      xflag = (fea_props & REF_DIR_X_NEG ?-1:1);
      BSproj1(&long_rc,center,&plane[8],ref_point,center);
  
      for( i = 1; i< polar->num_copies; i++)
	{
	  angle = xflag*i*polar->sweep_angle * 1.74532925199432958e-2;
	  MAgrotmx(&long_rc,&plane[8],center,&angle,rot_matrix);
	  MAptsxform(&long_rc,&one,rot_matrix,ref_point,mark_pt);
	  ECdisplay_pattern_position(&rc,xdir,ydir,mark_pt,dittol,buffer);
	} 
    }
  return(TRUE);
}

void ECdisplay_pattern_position(rc,xdir,ydir,mark_pt,dittol,buffer)
     IGRint *rc;
     IGRdouble *xdir,*ydir,*mark_pt,dittol;
     struct DPele_header *buffer;
{
  IGRdouble *line1,*line2;
  IGRint i;

  line1 = buffer[0].geometry.polyline->points;
  line2 = buffer[1].geometry.polyline->points;

  for( i = 0; i< 3; i++)
    {
      line1[i]   = mark_pt[i] - SEG_LENGTH*dittol*xdir[i];
      line1[3+i] = mark_pt[i] + SEG_LENGTH*dittol*xdir[i];
      line2[i]   = mark_pt[i] - SEG_LENGTH*dittol*ydir[i];
      line2[3+i] = mark_pt[i] + SEG_LENGTH*dittol*ydir[i];
    }
  
  dp$display(msg = rc,mode = GRhd,num_elem = 2, buffer = buffer);
}

EFcheck_pattern_feature(EMmsg,fea_id,options)
IGRlong *EMmsg;
struct GRid *fea_id;
IGRint options;
{
  IGRint status;
  IGRushort dpr_props;
  IGRint valid_fea = FALSE;

  status = 
  om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg, &dpr_props),
                    senderid = NULL_OBJID,
                    targetid = fea_id->objid,
                    targetos = fea_id->osnum);  
  fe$status(action = RET_STATUS);
  
  if ( EFisAncestryValid(EMmsg, fea_id->objid, fea_id->osnum, 
			OPP_EMSslboolfea_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id->objid, fea_id->osnum,
			OPP_EMSslslotfea_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id->objid, fea_id->osnum,
			OPP_EMSslfeature_class_id, FALSE))
    {
      if(!(dpr_props &EMS_MACRO_STATE))
	valid_fea = TRUE;
    }

  return(valid_fea);
}

EMinput_is_a_positive_integer(s)
     char *s;
{
  char *p;

  p = s;
  while(*p)
   if( *p == '-' || *p == '+' ||(*p >= '0' && *p <='9'))
     p++;
   else if( *p == '.')
     {
       ex$message(msgnumb = EMS_I_NumInteger);
       return(FALSE);
     }
   else
     {
       ex$message(msgnumb = EMS_I_KeyinNumeric);
       return(FALSE);
     }
  if( atoi(s) <= 0)
    {
      ex$message( msgnumb = EMS_I_NumPositive);
      return(FALSE);
    }
  else return(TRUE);
}
EMinput_is_a_positive_double(s)
char *s;
{
  char *p;

  p = s;
  while(*p)
   if( *p == '-' || *p == '+' || *p == '.' || (*p >= '0' && *p <='9'))
     p++;
   else
     {
       ex$message(msgnumb = EMS_I_KeyinNumeric);
       return(FALSE);
     }
  if( atof(s) <= 0.0)
    {
      ex$message( msgnumb = EMS_I_ValPositive);
      return(FALSE);
    }
  else return(TRUE);
}

IGRint EFpattern_action_handler (my_stack,
			 new_entry,
			 locate_args,
			 action)
struct GRlc_stack       *my_stack;
struct GRlc_info 	*new_entry;
struct LC_action_args   *locate_args;
IGRchar 		*action;

{
	IGRint status, loc_status, rc;
	IGRlong long_rc;

	if(*action == start_transition || *action == end_transition)
	{
		/*| - Begin or End Transition - */

		loc_status =
		LCptlocact(
			my_stack,
			new_entry,
			locate_args,
			action);
		return(loc_status);
	}

	/*^ print_grid("located_obj", &new_entry->located_obj) */

    if(!EFcheck_pattern_feature(&long_rc,&new_entry->located_obj,
                              EMS_PAT_LOC_FEATURE))
      return(LC_RELOCATE);

	loc_status =
	LCptlocact(
		my_stack,
		new_entry,
		locate_args,
		action);

	/*"action=%d, loc_status=%d\n", *action, loc_status*/

	return(loc_status);
}
end implementation ECfepattern;

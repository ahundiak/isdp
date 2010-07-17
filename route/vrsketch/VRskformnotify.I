/* $Id: VRskformnotify.I,v 1.3 2001/02/20 01:17:08 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch/VRskformnotify.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskformnotify.I,v $
 *	Revision 1.3  2001/02/20 01:17:08  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:32  anand
 *	SP merge
 *	
# Revision 1.4  2000/12/14  16:50:10  pinnacle
# Replaced: route/vrsketch/VRskformnotify.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/05/10  14:50:32  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.1  2000/04/28  00:24:54  pinnacle
# Created: route/vrsketch/VRskformnotify.I by lawaddel for Service Pack
#
# Revision 1.4  2000/04/04  21:15:40  pinnacle
# Replaced: vrsketch/VRskformnotify.I for:  by aharihar for route
#
# Revision 1.3  2000/03/31  19:34:16  pinnacle
# Replaced: vrsketch/VRskformnotify.I for:  by aharihar for route
#
# Revision 1.2  2000/03/27  01:25:40  pinnacle
# Replaced: vrsketch/VRskformnotify.I for: CR179801143 by aharihar for route
#
# Revision 1.1  2000/03/20  06:34:52  pinnacle
# Created: vrsketch/VRskformnotify.I by aharihar for route
#
 *
 * History:
 *	DD MMM YY	AUTHOR		DESCRIPTION
 *
 *	Feb 2000	Anand		Created from VRsketchi.I to reduce bulk
 *	31 Mar 2k	Anand		TR 179901277 - shape transition comp
 *	04 Mar 2k	Anand		Checked & Freed Comp Number returned by
 *					Live look up process.
 *      26 Apr 2k       law             tr179901408 update spec
 *      26 Apr 2k       law             tr179901470 transition depth updating
 *      23 May 00       law             tr179901548-extend comp number field.
 *      14 Dec 00       law             TR-MP4140-extended optcode descriptor
 *					to 80 characters
 *
 ***************************************************************************/

class implementation VRsketch;

#include "dpdef.h"
#include "dpmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"

#include "VRdef.h"
#include "VRact_params.h"
#include "VRattr_index.h"
#include "VRparamdef.h"
#include "VRco.h"
#include "FI.h"
#include "VRsketchdef.h"
#include "VRchgattrdef.h"
#include "ACattrib.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRPid.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "VRDbStruct.h"
#include "VRMcForm.h"
#include "VDDfEntCode.h"
#include "VDSutil.h"
#include "AS_status.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"
#include "vrpdu_pto.h"
#include "vrsketch_pto.h"

#include "VDDbDef.h"
#include "VRRDBmac.h"
#include "VRlivlkup.h"
#include "vrdbgmacros.h"
#include "VDmem.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	SMALL_RW_DEPTH_TXT	35  
#define _LOC_CMP		8
#define VR_OPTCODE_LIST_NUM	400


from	ACncpx	import	ACgive_structure;

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

  /* Below modified for CR179309874 - new RW shapes */  
  IGRint       row = 0, col = 0, sel_flag, r_pos, NbAttr, NBcnt;
  IGRlong      retcode;
  IGRdouble    value, w_value;
  IGRchar      text[30];

  struct  GRid       ParamId;
  struct  ACrg_coll  NewListAttr[VR_MAX_ATTR]; /* CR179801144 */
  extern int VRPlvlkup(); /* CR179308634 - Livelookup processor */
  IGRboolean  bNewPocket;
  char text_string[20];
  /* added for CR179801061 */
  IGRdouble max_depth;
  IGRdouble diameter;
  IGRdouble radius;
  IGRint shape_code, NbCpts, shpid;
  struct ret_struct ParamAttr;
  IGRint FootIndex = -1, retstatus;

  IGRchar spec_name[120];
  IGRlong longmsg;
  struct GRid my_grid; /* CR179801144 */

  SetProc( Sketch form notification ); Begin
  /*"shape_gadget = %d \n",me->shape_gadget*/
  /* my_grid added for tier processing-CR179801144 */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if( me->SketchMode == VR_AUTOMATIQUE ) me->my_ret = MSSUCC;

  /* Added for CR179308634 - Livelookup of parts in database */
  if( me->Product == VR_PIPING  &&  me->proc_livelook )
  {
      if(gadget_label == FI_CANCEL)
      {
	 FIg_set_state_off( me->status_display_form_ptr, FI_CANCEL );
	 FIf_erase(me->status_display_form_ptr );
	 FIf_display(me->form_ptr);

	 status = VRPlvlkup( 1, &gadget_label, me->status_display_form_ptr,
							     &(me->OB.piping));

	 me->proc_livelook = FALSE;
	 me->form_requested = 0;
	 me->my_ret = VR_DEFAULT_VALUE;
	 _put_response( resp = EX_BACK_UP );
	 End
	 return OM_S_SUCCESS;
      }
      else if(gadget_label == FI_ACCEPT)
      {
	FIg_set_state_off( me->status_display_form_ptr, FI_ACCEPT );

	me->proc_livelook = FALSE;

	VR$active_params( operation       = VR_RETRIEVE,
		       VRproduct          = me->Product,
		       act_param_id       = &me->ActParamId,
			     status       = status );

	me->bTagNumUsed = TRUE;

	me->bI_Need_Pick = TRUE;

	strcpy(me->CmpAABBCCcode,me->OB.piping.loc_cmp_code);

	me->CmpOption = (int)atoi(me->OB.piping.opt_code_num);

	strcpy( me->CmpNumber,me->OB.piping.comp_num_fld);
	status = FIg_set_text ( me->form_ptr,PP_CMP_NB,
						  me->OB.piping.comp_num_fld );
	NbAttr = 0;
	/* -- Set Green Diameter -- */
	/* Get PP_DIAM */
	strcpy( NewListAttr[NbAttr].name, VR_N_GDIAMETER_DB );
		NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
		NewListAttr[NbAttr].desc.value.att_exp = me->OB.piping.default_Gdia;
	sprintf(text_string,"%lf",me->OB.piping.default_Gdia);
	status = FIg_set_text ( me->form_ptr,PP_DIAM, text_string );
	NbAttr ++;

	/* -- Set Red Diameter -- */
	strcpy( NewListAttr[NbAttr].name, VR_N_RDIAMETER_DB );
		NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
		NewListAttr[NbAttr].desc.value.att_exp = me->OB.piping.default_Rdia ;
	sprintf(text_string,"%lf",me->OB.piping.default_Rdia);
	status = FIg_set_text ( me->form_ptr,SMALL_DIAMETER, text_string );

	NbAttr ++;

	strcpy( NewListAttr[NbAttr].name, VR_N_CLASS_AN);
		NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
	strcpy(NewListAttr[NbAttr].desc.value.att_txt,me->OB.piping.spec_nam_txt);
	NbAttr ++;

	{
          /*** TR-MP4140 extend option code to 80 characters ****/
	  IGRchar optcode_text[81];
	  IGRchar pathname[OM_K_MAXOSNAME_LEN];
	  struct GRid ExpressionId;
     
	   /* Get the Current Working Directory */
	   status = di$pwd( dirname = pathname );
     
	   /* Change to the HOME directory */
	   status = di$cd( dirname = DIR_G_home_name );
     
	   /* Get the ExpressionId if it is already created
	   in the Directory Subsystem */
	   status = di$translate(
				 objname = "piping_option_code",
				 p_objid = &ExpressionId.objid,
				 p_osnum = &ExpressionId.osnum );
     
	   status = FIg_set_text ( me->form_ptr,PIPING_OPTION,me->OB.piping.opt_code_num );
	   if( status != DIR_S_SUCCESS )
	   {
	       ExpressionId.osnum = me->ModuleEnv.md_id.osnum;
	       status = exp$create (
			exp_name   = "piping_option_code",
			exp_syntax = me->OB.piping.opt_code_num,
			osnum      = ExpressionId.osnum,
			p_exp_id   = &ExpressionId.objid,
			p_osnum    = &ExpressionId.osnum,
			type_rq    = EXP_TEXT );
	   }
	   else
	   {
	       status = exp$modify ( exp_id = ExpressionId.objid,
				     osnum  = ExpressionId.osnum,
				 exp_syntax = me->OB.piping.opt_code_num );
	   }
     
	   /* Re-Setting it to the PWD directory  */
	   status = di$cd( dirname = pathname );
	   UI_status( "Processing status disp..." );

	} 

	ParamId.objid = NULL_OBJID;
	ParamId.osnum = me->ModuleInfo.md_id.osnum;

	status = VR$ModifyCollection( p_msg		   = &retcode,
				      p_InputCollectionId  = &me->ActParamId,
				      p_OutputCollectionId = &ParamId );
	as$status();
	as$status( sts = retcode );

	status = VR$ModifyCollection( p_msg		   = &retcode,
				      Operation            = VR_UPDATE_COLL,
				      p_ParamsListToModify = NewListAttr,
				      NbParamsToModify     = NbAttr,
				      p_OutputCollectionId = &ParamId );
	as$status();
	as$status( sts = retcode );


	me->ListIds[0] = ParamId;

	FIf_erase(me->status_display_form_ptr );

	status = VRPlvlkup(1,&gadget_label, me->status_display_form_ptr,
	    					    &(me->OB.piping) );

	me->form_requested = 0;
	FIf_display( me->form_ptr );
	_put_response( resp = EX_FORM_FINISHED );
	goto quit;
      }
      else
      {
	  status = VRPlvlkup( me->first_entry, &gadget_label, form_ptr,
							    &(me->OB.piping) );
	  goto quit;
      }
  }
  else if( form_ptr == me->form_ptr )
  {
    __DBGpr_com("form_ptr is standard form ");
    /* Get equiv-diam for computing width/depth for CR179801061 */
    status = 
    VR$active_params( operation       = VR_RETRIEVE,
	              VRproduct       = me->Product,
	              act_param_id    = &me->ActParamId,
                      status          = status );

    status = 
        om$send( msg      = message ACncpx.ACgive_structure
                 ( &retstatus, 
                   &FootIndex, 
                   VR_N_MAX_DEPTH_DB,
                   &ParamAttr, 
                   &me->ModuleInfo),
        targetid = me->ActParamId.objid,
        targetos = me->ActParamId.osnum );
    max_depth = ParamAttr.var.root_pm_st.value;

    status = 
        om$send( msg      = message ACncpx.ACgive_structure
                 ( &retstatus, 
                   &FootIndex, 
                   VR_N_EQUIV_DIA_DB,
                   &ParamAttr, 
                   &me->ModuleInfo),
        targetid = me->ActParamId.objid,
        targetos = me->ActParamId.osnum );

    diameter = ParamAttr.var.root_pm_st.value;

    status = 
        om$send( msg      = message ACncpx.ACgive_structure
                 ( &retstatus, 
                   &FootIndex, 
                   VR_N_CORN_RAD_DB,
                   &ParamAttr, 
                   &me->ModuleInfo),
        targetid = me->ActParamId.objid,
        targetos = me->ActParamId.osnum );

    radius = ParamAttr.var.root_pm_st.value;
    __DBGpr_dbl(" corner radius", radius);

    __DBGpr_int("processing gadget",gadget_label);
    switch( gadget_label )
    {
      case PP_SKEWED:
        if ( me->FirstType == IS_ELBOW           ||
             me->FirstType == IS_COMP_TO_CONNECT ||
             me->FirstType == IS_CONC_COMP       ||
             me->FirstType == IS_NOZZLE )
        {
          me->orthogonal_sketch = TRUE;
          FIg_set_state_off( me->form_ptr, PP_SKEWED );
          FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
	  FIg_erase( me->form_ptr, MAINTAIN_SKEW );
          ex$message( field   = ERROR_FIELD,
                      in_buff = "direction should be orthogonal !" );
	  End
          return OM_S_SUCCESS;
        }

        if( me->orthogonal_sketch )
	{
	   me->orthogonal_sketch = FALSE;
	   FIg_display( me->form_ptr, MAINTAIN_SKEW );
        }
        else
        {
          me->orthogonal_sketch = TRUE;
          FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
	  FIg_erase( me->form_ptr, MAINTAIN_SKEW );
          FIg_set_state_off( me->form_ptr, PP_SKEWED );
        }

        me->my_ret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        /*"ortho_sketch = %d\n", me->orthogonal_sketch */
        break;

      case MAINTAIN_SKEW:
        if( ! me->AngleFlag )
        {
           me->AngleFlag = TRUE;
           me->Angle = 0.0;
        }
        else
           me->AngleFlag = FALSE;
 
        me->my_ret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        break;

      case PP_LOCATE:
        /*  see if we can allow a locate here   */
        /* VRHvskupdwd added for CR179801061 */
        /* Regardless of acceptability, cancel auto sizing */
        /* Note that no change of values, but VRHvskupdwd resets data fields */
        if( me->Product == VR_HVAC )
        {
            char temp_text[28];
            FIfld_get_list_text(form_ptr, SIZE_COMP_METHOD, 2, 0, 27, 
                          (unsigned char *) temp_text,
                          &sel_flag);
            FIfld_set_text( me->form_ptr, SIZE_COMP_METHOD,
                          row, col, temp_text, sel_flag );
            status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);
        }

        /*  TR # 179600603, corrupted correction after destination
            locate immediately following placement/locate of another
            component                                                  */
        if (me->bI_Need_Pick)
        {
          FIg_set_state_off( me->form_ptr, gadget_label);
          me->my_ret = VR_BLOCK_LOCATE; 
          _put_response( resp = EX_FORM_FINISHED );
          break;
        }

        if ( me->state != _LOC_CMP ) me->my_state = me->state;
        if( !me->LocateMode )
        {
          me->LocateMode = TRUE;
          me->next_pt_free = TRUE;
          me->first_pt_free = TRUE;
        }
        else
        {
          me->LocateMode = FALSE;
          FIg_set_state_off( me->form_ptr, gadget_label);
        }
        me->my_ret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        break;

      case PP_FITOFIT:
        me->first_pt_free = me->first_pt_free ? FALSE : TRUE;
        if( ! me->first_pt_free )
	    FIg_set_state_off( me->form_ptr, PP_FITOFIT);
        else
	    FIg_set_state_on( me->form_ptr, PP_FITOFIT);

        /*"fit to fit = %d\n", me->first_pt_free */
        me->my_ret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        break;

      case LINE_SEQ_NUM:

#ifdef  MANAGE_IDS
    if ( bVR_IS_PID_ACTIVE)
    {   
      /*A Verify unicity of LSN */
      IGRdouble    dValue;
      IGRchar      *sEnd=NULL;

      FIfld_get_text( me->form_ptr, LINE_SEQ_NUM,  row, col,
                             15, (unsigned char *) text, 
			     &sel_flag, &r_pos );

      /*C Verify that LNS is a value */
      dValue = strtod (text, &sEnd);
      if ( !text[0] || strlen (sEnd) )
      {
        ex$message( field   = ERROR_FIELD,
            in_buff = "Invalid LSN for UNICITY CHECK" );
      }
      else
      {
        /*C Get system name */
        status = 
        om$send( msg      = message ACncpx.ACgive_structure
                 ( &retstatus, 
                   &FootIndex, 
                          VR_N_SYST_NAME_AN,
                               &ParamAttr, 
                   &me->ModuleInfo),
        targetid = me->ActParamId.objid,
        targetos = me->ActParamId.osnum );

        status =
        VDVerifyIfIDisUsed( ParamAttr.var.text_st.text_string,
          (int)VD_C_PIPES, (IGRint) dValue );
        if ( status == VDS_ID_IS_USED )
        {
          ex$message( field   = ERROR_FIELD,
              in_buff = "LSN ALREADY USED !!!" );
        }
        else
        {
          VDLockSelectedID ( ParamAttr.var.text_st.text_string,
          (int)VD_C_PIPES, (IGRint) dValue   );
          me->PrevLineNum = (int) dValue;
          me->bLineNumUsed = FALSE;
        }
      }

    }/* end verify unicity */
#endif
    break;

  case PP_CMP_NB :
  case HV_CMP_NB :
    /* TR179900985 - Small width hvac coming here */
    if(me->Product == VR_HVAC && me->SketchMode == VR_MANUAL)
    {
       IGRdouble tmp_width;
       if(me->shape_gadget == HV_C_SHAPE)
       {
         /* SETTING DEPTH TO WIDTH */
         FIg_get_value( me->form_ptr, SMALL_HV_WIDTH, &tmp_width );
         FIg_set_value( me->form_ptr, SMALL_HV_DEPTH, tmp_width );
       }
    }


#ifdef  MANAGE_IDS
    if ( (me->Product == VR_PIPING || me->Product == VR_HVAC ) &&
      bVR_IS_PID_ACTIVE && me->CmpBehavior == VR_MANAGE_TAG )
    {
      /*A Verify unicity of LSN */
      IGRdouble    dValue;
      IGRchar      *sEnd=NULL;
      FIg_get_text( me->form_ptr, gadget_label,  text );

      /*C Verify that LNS is a value */
      dValue = strtod (text, &sEnd);
      if ( ! text[0] || strlen (sEnd) )
      {
                 ex$message( field   = ERROR_FIELD,
            in_buff = "Invalid NUMBER for UNICITY CHECK" );
      }
      else
      {
        /*C Get system name */
        status = 
        om$send( msg      = message ACncpx.ACgive_structure
                 ( &retstatus, 
                   &FootIndex, 
                          VR_N_SYST_NAME_AN,
                               &ParamAttr, 
                   &me->ModuleInfo),
        targetid = me->ActParamId.objid,
        targetos = me->ActParamId.osnum );

        status =
        VDVerifyIfIDisUsed( ParamAttr.var.text_st.text_string,
          me->CmpCat, (IGRint) dValue );
        if ( status == VDS_ID_IS_USED )
        {
          ex$message( field   = ERROR_FIELD,
              in_buff = "Comp Num is ALREADY USED !!!" );
        }
        else
        {
          VDLockSelectedID ( ParamAttr.var.text_st.text_string,
          me->CmpCat, (IGRint) dValue   );
          me->PrevTagNum = (int) dValue;
          me->bTagNumUsed = FALSE;
        }
      }
    }/* end verify unicity */
#endif
    break;

      case HV_TWIST :
        if( me->FirstType == IS_PIPE || me->FirstType == IS_ELBOW )
        {
          status = VR$ModifyHvacSection(  p_retmsg  = &retcode,
          Operation  = VR_SWITCH_SECTION,
          p_InPutSection  = me->section_matrix,
          p_OutPutSection  = me->section_matrix );
          as$status( action = RET_STATUS );
          as$status( sts = retcode, action = RET_STATUS );
        }
        else
        {
          /*"twist befor changement : %d\n", me->twist_orient */
          me->twist_orient = me->twist_orient ? FALSE : TRUE;
          /*"twist after changement : %d\n", me->twist_orient */
        }
        me->my_ret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        break;
  /* VRHvskupdwd and SIZE_COMP_METHOD added for CR179801061 */

  case SIZE_COMP_METHOD :  
        status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);

        break;

  case HV_WIDTH :  
    if( me->Product == VR_HVAC )
    {

        status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);
    }
        break;

  case HV_DEPTH :  
    if( me->Product == VR_HVAC )
    {
        status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);
    }
        break;

        case HV_O_SHAPE     :
    /****  case SMALL_RW_WIDTH **** dynamic depth *****/
    if( me->Product == VR_HVAC )
    {
      /* HVAC */
      FIfld_set_mode(form_ptr, HV_DEPTH, 0, FI_REVIEW);
      FIg_display( form_ptr, HV_DEPTH );
      FIg_erase( me->form_ptr, HV_R_SHAPE );
      FIg_erase( me->form_ptr, HV_RS_SHAPE );
      FIg_erase( me->form_ptr, HV_O_SHAPE );
      FIg_display( me->form_ptr, HV_C_SHAPE );
      /* Modified for CR179801061 */
      FIfld_get_value( me->form_ptr , HV_WIDTH, row, col,
                                         &me->width_sav, &sel_flag, &r_pos );
      FIfld_get_value( me->form_ptr , HV_DEPTH, row, col,
                                         &me->depth_sav, &sel_flag, &r_pos );
      me->shape_gadget =  HV_C_SHAPE;

      /* VRHvskupdwd added for CR179801061 */
      status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);

    }
    break;

    /* Below modified for CR179309874 - new RW shapes */  
    /* Below modified for CR179900491 - dynamic depth */  
    case RW_O_SHAPE     :
      /* RWAY Oval */
      FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_REVIEW);
      FIg_erase( form_ptr, RW_DEPTH ); //Reddy-no depth for circular shape
      FIg_erase( form_ptr, RW_D_TXT ); //Reddy-no depth label for circular shape
      FIg_erase( me->form_ptr, RW_R_SHAPE );
      FIg_erase( me->form_ptr, RW_O_SHAPE );
      FIg_erase( me->form_ptr, RW_RS_SHAPE );
      FIg_erase( me->form_ptr, RW_E_SHAPE );
      FIg_erase(me->form_ptr,FRM_TIER_SP_1);
      FIg_erase(me->form_ptr,FRM_TIER_SP_2);
      FIg_erase(me->form_ptr,FRM_NO_TIER_1);
      FIg_erase(me->form_ptr,FRM_NO_TIER_2);
      FIg_set_value(  form_ptr, FRM_DEPTH_1, me->RWcptdata[0].width);
      me->depth_sav = me->RWcptdata[0].depth;
      if( me->SketchMode == VR_MANUAL )
      {
        FIg_set_value(  form_ptr, FRM_DEPTH_2,
                                me->RWcptdata[me->active_cpt-1].width);
	FIg_erase( me->form_ptr, RW_R_SHAPE );

	// Added by Reddy - Removing small depth gadgets for circular shape 
	FIg_erase( me->form_ptr,SMALL_RW_DEPTH );
	FIg_erase( me->form_ptr,SMALL_RW_DEPTH_TXT );
      } 
      FIg_display( me->form_ptr, RW_C_SHAPE );
      me->shape_gadget =  RW_C_SHAPE;

// Reddy - Shape coordination
      FIg_erase( form_ptr, ACTIVE_CPT_INDEX_TEXT );
      FIg_erase( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
      FIg_erase( form_ptr, ACTIVE_CPT_INDEX );
      FIg_erase( form_ptr, INCREASE_ACTIVE_CPT_INDEX );

    break;

  case HV_R_SHAPE: /* RW_R_SHAPE */
/*  case PP_DIAM:   same gadget number not allowed */
  case SMALL_DIAMETER:
    if( me->Product == VR_PIPING )
    {
      FIfld_get_value( me->form_ptr , PP_DIAM, row, col,
                                         &value, &sel_flag, &r_pos );
    
      FIfld_get_value( me->form_ptr , SMALL_DIAMETER, row, col,
                                             &w_value, &sel_flag, &r_pos );

      if( w_value > value )
      {
        FIfld_set_value( me->form_ptr , SMALL_DIAMETER,
             row, col, value, FALSE);

                 ex$message( field   = ERROR_FIELD,
              in_buff = "Second diameter should be greater than red !" );
      }
    }

    else if ( me->Product == VR_HVAC )
    {
      FIg_erase( me->form_ptr, HV_RS_SHAPE );
             FIg_erase( me->form_ptr, HV_C_SHAPE );
             FIg_erase( me->form_ptr, HV_R_SHAPE );
             FIg_display( me->form_ptr, HV_O_SHAPE );
	    me->shape_gadget =  HV_O_SHAPE;
      /* VRHvskupdwd added for CR179801061 */
      status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);
    }
    else if ( me->Product == VR_RWAY )
    {
      /* Below modified for CR179900491 - dynamic depth */  
      /* Below modified for CR179309874 - new RW shapes */  
      /* Added for CR179801144 */
      FIg_erase( form_ptr, N_TIER_SK1 );
      FIg_erase( form_ptr, SP_TIER_SK1 );
      FIg_erase( form_ptr, N_TIER_SK2 );
      FIg_erase( form_ptr, SP_TIER_SK2 );
      FIg_erase( form_ptr, N_TIER_SK1_TEXT );
      FIg_erase( form_ptr, SP_TIER_SK1_TEXT );
      FIg_erase( form_ptr, N_TIER_SK2_TEXT );
      FIg_erase( form_ptr, SP_TIER_SK2_TEXT );

      /* Below modified for CR179801144 */
      FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_INSERT);
      FIg_display( form_ptr, RW_DEPTH );
      FIg_display( form_ptr, RW_D_TXT );
      /* below modified for CR179801144 */
      FIfld_set_mode(form_ptr, SMALL_RW_DEPTH, 0, FI_INSERT);
      if( me->SketchMode == VR_MANUAL )
      {
         FIg_display( form_ptr, SMALL_RW_DEPTH );

         // Added by Reddy - Dispalying small depth gadgets for circular shape
	 FIg_display( me->form_ptr,SMALL_RW_DEPTH );
	 FIg_display( me->form_ptr,SMALL_RW_DEPTH_TXT );
         FIfld_set_mode(form_ptr, SMALL_RW_DEPTH, 0, FI_INSERT);

      }
      FIg_erase(me->form_ptr,FRM_TIER_SP_1);
      FIg_erase(me->form_ptr,FRM_TIER_SP_2);
      FIg_erase(me->form_ptr,FRM_NO_TIER_1);
      FIg_erase(me->form_ptr,FRM_NO_TIER_2);

      FIg_erase( me->form_ptr, RW_R_SHAPE );
      FIg_erase( me->form_ptr, RW_C_SHAPE );
      FIg_erase( me->form_ptr, RW_RS_SHAPE );
      FIg_erase( me->form_ptr, RW_E_SHAPE );
      FIg_display( me->form_ptr, RW_O_SHAPE );
      me->shape_gadget =  RW_O_SHAPE;

      //Reddy - Shape coordination
      FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX_TEXT );
      FIg_erase( me->form_ptr, DECREASE_ACTIVE_CPT_INDEX );
      FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX );
      FIg_erase( me->form_ptr, INCREASE_ACTIVE_CPT_INDEX );
    }
    break;

  case HV_C_SHAPE: // NOTE: RW_C_SHAPE=HV_C_SHAPE=16

	/* Below lines added by Anand for CR 179900060 and CR 179900837 */
		__DBGpr_com(" Setting up corner radius display");
		FIg_display( me->form_ptr, CORN_RAD );
		FIg_display( me->form_ptr, CORN_RAD_TXT );
		FIg_set_value( me->form_ptr, CORN_RAD, radius );
	/* Above lines added by Anand for CR 179900060 and CR 179900837 */

                /* Below modified for CR179309874 - new RW shapes */  
                if( me->Product == VR_HVAC )
                {
                   FIfld_set_mode(form_ptr, HV_DEPTH, 0, FI_INSERT);
                   FIg_display( form_ptr, HV_DEPTH );
                   FIg_erase( me->form_ptr, HV_O_SHAPE );
                   FIg_erase( me->form_ptr, HV_R_SHAPE );
                   FIg_erase( me->form_ptr, HV_C_SHAPE );
                   FIg_display( me->form_ptr, HV_RS_SHAPE );
                   me->shape_gadget =  HV_RS_SHAPE;

                   /* VRHvskupdwd added for CR179801061 */
                   if((me->width_sav > 0.0) && (me->depth_sav > 0.0))
                   {
                      FIfld_set_value( form_ptr, HV_WIDTH , row, col,
                                                 me->width_sav,sel_flag );
                      FIfld_set_value( form_ptr, HV_DEPTH , row, col,
                                                 me->depth_sav,sel_flag );
                   }

        status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);

                }
                /* Below modified for CR179309874 - new RW shapes */  
                /* Below modified for CR179900491 - Dynamic depth */
                else if ( me->Product == VR_RWAY )
                {
                   FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_INSERT);
                   FIg_display( form_ptr, RW_DEPTH );//Reddy -display Depth
		   FIg_display( form_ptr, RW_D_TXT );//Display depth label 
                   FIg_set_value(  form_ptr, FRM_DEPTH_1, me->depth_sav);
                   me->RWcptdata[0].depth = me->depth_sav;
                   if( me->SketchMode == VR_MANUAL )
                   {
                     FIg_set_value(  form_ptr, FRM_DEPTH_2, me->depth_sav);
                     me->RWcptdata[me->active_cpt].depth = me->depth_sav;

		      // Added by Reddy - Dispalying small depth gadgets 
		       FIg_display( me->form_ptr,SMALL_RW_DEPTH );
		       FIg_display( me->form_ptr,SMALL_RW_DEPTH_TXT );
                       FIfld_set_mode(form_ptr, SMALL_RW_DEPTH, 0, FI_INSERT);

                   } 
/* Redundant code deleted for tr179900780 ************
                   FIg_display( me->form_ptr, RW_C_SHAPE );
                   me->shape_gadget =  RW_C_SHAPE;
***************/
                   FIg_erase( me->form_ptr, RW_R_SHAPE );
                   FIg_erase( me->form_ptr, RW_O_SHAPE );
                   FIg_erase( me->form_ptr, RW_C_SHAPE );
                   FIg_erase( me->form_ptr, RW_E_SHAPE );
                   FIg_display( me->form_ptr, RW_RS_SHAPE );
                   me->shape_gadget =  RW_RS_SHAPE;
                   FIg_erase(me->form_ptr,FRM_TIER_SP_1);
                   FIg_erase(me->form_ptr,FRM_TIER_SP_2);
                   FIg_erase(me->form_ptr,FRM_NO_TIER_1);
                   FIg_erase(me->form_ptr,FRM_NO_TIER_2);

 
		}
    break;

  case CORN_RAD:
    {
	IGRdouble	tmp_rad=0.0;

	FIg_get_value( me->form_ptr, CORN_RAD, &tmp_rad );
/*
	__DBGpr_dbl(" Width",me->width_sav);
	__DBGpr_dbl(" Depth",me->depth_sav);
	if( (2*tmp_rad) > me->depth_sav || (2*tmp_rad) > me->width_sav )
	{
	    UI_status(" Corner radius value too big. Reset to old value");
	    FIg_set_value( me->form_ptr, CORN_RAD, radius );
	}
	else
*/
	if( me->Product == VR_HVAC )
	    status = VRHvskupdwd( me->form_ptr, me->shape_gadget, max_depth,
				  diameter, tmp_rad );
    }
    break;


  case HV_RS_SHAPE:  /* N_TIER_SK1 for VR_RWAY - CR179801144 */
    if ( me->Product == VR_HVAC )
    {
      FIg_erase( me->form_ptr, HV_RS_SHAPE );
             FIg_erase( me->form_ptr, HV_C_SHAPE );
             FIg_erase( me->form_ptr, HV_O_SHAPE );
             FIg_display( me->form_ptr, HV_R_SHAPE );
      me->shape_gadget =  HV_R_SHAPE;

      /* VRHvskupdwd added for CR179801061 */
      if((me->width_sav > 0.0) && (me->depth_sav > 0.0))
      {
             FIfld_set_value( form_ptr, HV_WIDTH , row, col,
                                                 me->width_sav,sel_flag );
             FIfld_set_value( form_ptr, HV_DEPTH , row, col,
                                                 me->depth_sav,sel_flag );
      }
      status = VRHvskupdwd(me->form_ptr,me->shape_gadget,max_depth,
                                                         diameter,radius);
    }
    /* For rectangular raceway, depth computed at execute */
    break;

  /* Below added for CR179309874 - new RW shapes */  
  /* Below modified for CR179900491 - Dynamic depth */
  case RW_RS_SHAPE:
      FIg_erase( me->form_ptr, RW_R_SHAPE );
      FIg_erase( me->form_ptr, RW_O_SHAPE );
      FIg_erase( me->form_ptr, RW_C_SHAPE );
      FIg_erase( me->form_ptr, RW_RS_SHAPE );
      FIg_erase(me->form_ptr,FRM_TIER_SP_1);
      FIg_erase(me->form_ptr,FRM_TIER_SP_2);
      FIg_erase(me->form_ptr,FRM_NO_TIER_1);
      FIg_erase(me->form_ptr,FRM_NO_TIER_2);

  case RW_E_SHAPE:
      FIg_erase( me->form_ptr, RW_O_SHAPE );
      FIg_erase( me->form_ptr, RW_C_SHAPE );
      FIg_erase( me->form_ptr, RW_RS_SHAPE );
      FIg_erase( me->form_ptr, RW_E_SHAPE );
      FIg_display( me->form_ptr, RW_R_SHAPE );
      /* Added for CR179801144 */
      /* Below modified for CR179900491 - Dynamic depth */
      __DBGpr_com("prepare for RW_R_SHAPE");
      FIg_display( form_ptr, FRM_TIER_SP_1 );
      FIg_display( form_ptr, FRM_NO_TIER_1 );
      FIg_display( form_ptr, N_TIER_SK1_TEXT );
      FIg_display( form_ptr, SP_TIER_SK1_TEXT );
      FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_REVIEW);

      if( me->SketchMode == VR_MANUAL )
      {
         FIg_display( form_ptr, FRM_TIER_SP_2 );
         FIg_display( form_ptr, FRM_NO_TIER_2 );
         FIg_display( form_ptr, N_TIER_SK2_TEXT );
         FIg_display( form_ptr, SP_TIER_SK2_TEXT );
         FIfld_set_mode(form_ptr, SMALL_RW_DEPTH, 0, FI_REVIEW);
         FIg_display( form_ptr, SMALL_RW_DEPTH );
         FIg_display( form_ptr, SMALL_RW_DEPTH_TXT );

         // Reddy - Shape coordination
         FIg_display( form_ptr, ACTIVE_CPT_INDEX_TEXT );
         FIg_display( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
         FIg_display( form_ptr, ACTIVE_CPT_INDEX );
         FIg_display( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
      }
      FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_REVIEW);
      FIg_display( form_ptr, RW_DEPTH ); /* CR179801144 */
      FIg_display( form_ptr, RW_D_TXT ); //Reddy - Display Depth label

      me->shape_gadget =  RW_R_SHAPE;
    break;

  case HV_THROAT_RADIUS:  /* gadget label = 51 */
  
       FIg_get_value(  me->form_ptr, gadget_label, &value );
       ex$message( field=ERROR_FIELD, in_buff= " " );
  
       if ( value <= 0 )
       {
           ex$message( field=ERROR_FIELD, in_buff= " Throat Radius Should be Greater than 0 " );
  
           /* Set the value to the default, from active parameters */
           status =
           om$send( msg = message ACncpx.ACgive_structure
                  ( &retstatus, &FootIndex, VR_N_THROAT_DB,
                    &ParamAttr, &me->ModuleInfo),
           targetid = me->ActParamId.objid,
           targetos = me->ActParamId.osnum );
  
           FIfld_set_value( form_ptr, gadget_label, row, col,
                          ParamAttr.var.root_pm_st.value,
                          sel_flag );
       }
     break;
  
   case HV_TRAN_LENGTH: /* gadget label = 53 */
  
       FIg_get_value(  me->form_ptr, gadget_label, &value );
       ex$message( field=ERROR_FIELD, in_buff= " " );
  
       if ( value <= 0 )
       {
           ex$message( field=ERROR_FIELD, in_buff= " Transition Length Should be Greater than 0 " );
  
           /* Set the value to the default, from active parameters */
  
           status =
           om$send( msg = message ACncpx.ACgive_structure
                  ( &retstatus, &FootIndex, VR_N_TRANS_L_DB,
                    &ParamAttr, &me->ModuleInfo),
           targetid = me->ActParamId.objid,
           targetos = me->ActParamId.osnum );
  
           FIfld_set_value( form_ptr, gadget_label, row, col,
                          ParamAttr.var.root_pm_st.value,
                          sel_flag );
        }
     break;

/* Removed T_SHAPE -law- CR179309874 */

  case FI_EXECUTE :

     FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
     status = VR$active_params( operation       = VR_RETRIEVE,
				VRproduct       = me->Product,
				act_param_id    = &me->ActParamId,
				status          = status );

     ParamId.osnum = me->ModuleInfo.md_id.osnum;

     NbAttr = 0;
     NBcnt = 0;
     if ( me->Product == VR_PIPING )
     {
	 /* -- Set Green Diameter -- */
	 FIfld_get_value( me->form_ptr , PP_DIAM, row, col,
						  &value,  &sel_flag, &r_pos );

	 strcpy( NewListAttr[NbAttr].name, VR_N_GDIAMETER_DB );
	 NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	 NewListAttr[NbAttr].desc.value.att_exp = value ;
	 NbAttr ++;

	 __DBGpr_int(" SketchMode ", me->SketchMode );

	 if( me->SketchMode == VR_MANUAL )
	 {		
	     FIfld_get_value( me->form_ptr , SMALL_DIAMETER, row, col,
						  &value,  &sel_flag, &r_pos );
	     /*A set this flag to true */
	     me->bTagNumUsed = TRUE;
	 }
	 else
	     me->bLineNumUsed = TRUE;

	 /* -- Set Red Diameter -- */
	 strcpy( NewListAttr[NbAttr].name, VR_N_RDIAMETER_DB );
	 NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	 NewListAttr[NbAttr].desc.value.att_exp = value ;
	 NbAttr ++;

	 /* -- Set Line Sequence Number -- */
	 FIfld_get_text( me->form_ptr, LINE_SEQ_NUM,  row, col,
			 15, (unsigned char *) text, &sel_flag, &r_pos );

	 strcpy( NewListAttr[NbAttr].name, VR_N_SEQ_NUMBER_AN);
	 NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
	 strcpy(NewListAttr[NbAttr].desc.value.att_txt,text);
	 NbAttr ++;

	 /* -- Set Pid Scale Factor -- */
	 FIfld_get_value( me->form_ptr , SK_PID_SCALE, row, col, &value,
							   &sel_flag, &r_pos );

	 strcpy( NewListAttr[NbAttr].name, VR_N_PID_SCALE_DB );
	 NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	 NewListAttr[NbAttr].desc.value.att_exp = value ;
	 NbAttr ++;

	 /* added by Alwin for CR179300978*/
	 /* Place the Piping Option Code Text, in the directory structure.
	  * This may help us in retreiving the value and constructing
	  * the Pipe easily. */
	 {
             /***** TR-MP4140 extend option code to 80 characters *********/
	     IGRchar optcode_text[81];
	     IGRchar pathname[OM_K_MAXOSNAME_LEN];
	     struct GRid ExpressionId;

             /***** TR-MP4140 80 characters option code *********/
	     FIfld_get_text( me->form_ptr, PIPING_OPTION, 0, 0,
		     80, (unsigned char *) optcode_text,
		     &sel_flag, &r_pos );

	     /* Get the Current Working Directory */
	     status = di$pwd( dirname = pathname );

	     /* Change to the HOME directory */
	     status = di$cd( dirname = DIR_G_home_name );

	     /* Get the ExpressionId if it is already created
		in the Directory Subsystem */
	     status = di$translate(
		     objname = "piping_option_code",
		     p_objid = &ExpressionId.objid,
		     p_osnum = &ExpressionId.osnum );

	     if( status != DIR_S_SUCCESS )
	     {
		 ExpressionId.osnum = me->ModuleEnv.md_id.osnum;
		 status = exp$create (
			 exp_name   = "piping_option_code",
			 exp_syntax = optcode_text,
			 osnum      = ExpressionId.osnum,
			 p_exp_id   = &ExpressionId.objid,
			 p_osnum    = &ExpressionId.osnum,
			 type_rq    = EXP_TEXT );
	     }
	     else
	     {
		 status = exp$modify (  exp_id = ExpressionId.objid,
					osnum  = ExpressionId.osnum,
					exp_syntax = optcode_text );
	     }

	     /* Re-Setting it to the PWD directory  */
	     status = di$cd( dirname = pathname );
	     UI_status( "Processing ..." );

	 }
	 /* END - added by Alwin for CR179300978*/
     }

     if( ( me->Product == VR_HVAC ) || ( me->Product == VR_RWAY ) )
     {
	 NBcnt = 0;
	 /* VRHvskupdwd added for CR179801061 */
	 /*** Major changes in loading NewListAttr for tr179900932 ***/
	 if ( me->Product == VR_HVAC )
	 {
	     NbAttr = 10;
	     /* TR179900985 - skip VRHvskupdwd in manual mode */
	     if( me->SketchMode != VR_MANUAL )
	     {
		 status = VRHvskupdwd( me->form_ptr, me->shape_gadget,
						  max_depth, diameter, radius);
	     }
	     /* Below modified for CR179309874 - new RW shapes */  
	 }
	 else
	     NbAttr = 13; /* CR179801144 - added tiers */

	 if ( me->Product == VR_HVAC )
	 {
	     FIfld_get_value( me->form_ptr , HV_WIDTH, row, col,
						  &value,  &sel_flag, &r_pos );
	     strcpy( NewListAttr[NBcnt].name, VR_N_WIDTH1_DB);
	     NewListAttr[NBcnt].desc.type          = AC_ATTRIB_DOUBLE;
	     NewListAttr[NBcnt].desc.value.att_exp = value ;
	     NBcnt++;
	     /* Modified for CR179900491 */
	     if( me->SketchMode == VR_MANUAL )
	     {
		 /*| manual mode */
		 FIfld_get_value( me->form_ptr, SMALL_HV_WIDTH, row, col,
						    &value, &sel_flag, &r_pos);
	     }

	     strcpy( NewListAttr[NBcnt].name, VR_N_WIDTH2_DB);
	     NewListAttr[NBcnt].desc.type          = AC_ATTRIB_DOUBLE;
	     NewListAttr[NBcnt].desc.value.att_exp = value ;
	     NBcnt++;

	     FIfld_get_value( me->form_ptr , HV_DEPTH, row, col,
		     &value,  &sel_flag, &r_pos );
	     /* CR179801144-rway depth moved to tier processing */ 

	     strcpy( NewListAttr[NBcnt].name, VR_N_DEPTH1_DB);
	     NewListAttr[NBcnt].desc.type          = AC_ATTRIB_DOUBLE;
	     NewListAttr[NBcnt].desc.value.att_exp = value ;
	     NBcnt++;

	     if( me->SketchMode == VR_MANUAL )
	     {
		 /*| manual mode */
		 if( me->Product == VR_HVAC )
		     FIfld_get_value( me->form_ptr , SMALL_HV_DEPTH, row, col,
						   &value,  &sel_flag, &r_pos);
		 /* CR179801144-rway depth moved to tier processing */ 
	     }

	     strcpy( NewListAttr[NBcnt].name, VR_N_DEPTH2_DB);
	     NewListAttr[NBcnt].desc.type          = AC_ATTRIB_DOUBLE;
	     NewListAttr[NBcnt].desc.value.att_exp = value ;
	     NBcnt++;

	 }		
	 shpid = NBcnt;
	 strcpy( NewListAttr[NBcnt].name, VR_N_SHAPE_IN);
	 NewListAttr[NBcnt].desc.type = AC_ATTRIB_DOUBLE;

	 if( me->shape_gadget == HV_O_SHAPE )
	     NewListAttr[NBcnt].desc.value.att_exp = VR_OVAL;

	 /* Below modified for CR179309874 - new RW shapes */  

	 if( me->shape_gadget == RW_O_SHAPE )
	     NewListAttr[NBcnt].desc.value.att_exp = VR_OVAL;

	 if( me->shape_gadget == HV_R_SHAPE ) /* RW_R_SHAPE */
	     NewListAttr[NBcnt].desc.value.att_exp = VR_RECT;

	 /* Below modified for CR179309874 - new RW shapes */  
	 if( me->shape_gadget == HV_C_SHAPE ) /* RW_C_SHAPE */
	     NewListAttr[NBcnt].desc.value.att_exp = VR_CIRC;

	 if( me->shape_gadget == HV_RS_SHAPE )
	     NewListAttr[NBcnt].desc.value.att_exp = VR_CORNER;

	 /* Below modified for CR179309874 - new RW shapes */  
	 if( me->shape_gadget == RW_RS_SHAPE )
	     NewListAttr[NBcnt].desc.value.att_exp = VR_CORNER;

	 /* Below modified for CR179309874 - new RW shapes */  
	 if( me->shape_gadget == RW_E_SHAPE )
	     NewListAttr[NBcnt].desc.value.att_exp = VR_ELLIPSE;
	 NBcnt++;

	 /* -- Set Symb Scale Factor -- */
	 if ( me->Product == VR_HVAC )
	 {
	     FIg_get_value( me->form_ptr, HV_SYMB_SCALE, &value );

	     strcpy( NewListAttr[NBcnt].name, VR_N_PID_SCALE_DB );
	     NewListAttr[NBcnt].desc.type	   = AC_ATTRIB_DOUBLE;
	     NewListAttr[NBcnt].desc.value.att_exp = value ;
	     NBcnt++;
	 } /* end of set symb scale */

	 /*C get the line seq number */
	 FIfld_get_text( me->form_ptr, LINE_SEQ_NUM, row, col, 15,
				   (unsigned char *) text, &sel_flag, &r_pos );

	 strcpy( NewListAttr[NBcnt].name, VR_N_SEQ_NUMBER_AN);
	 NewListAttr[NBcnt].desc.type = AC_ATTRIB_TEXT;
	 strcpy(NewListAttr[NBcnt].desc.value.att_txt,text);
	 NBcnt++;

	 /*C get the Throat Radius */
	 FIg_get_value( me->form_ptr, HV_THROAT_RADIUS, &value);
	 /* Below modified for CR179701945 - Throat radius */  
	 strcpy( NewListAttr[NBcnt].name, VR_N_THROAT_DB);
	 NewListAttr[NBcnt].desc.type = AC_ATTRIB_DOUBLE;
	 NewListAttr[NBcnt].desc.value.att_exp = value;
	 NBcnt++;

	 /*C get the Transition Length */
	 FIg_get_value( me->form_ptr, HV_TRAN_LENGTH, &value );

	 strcpy( NewListAttr[NBcnt].name, VR_N_TRANS_L_DB);
	 NewListAttr[NBcnt].desc.type = AC_ATTRIB_DOUBLE;
	 NewListAttr[NBcnt].desc.value.att_exp = value;
	 NBcnt++;

	 /* Tier processing added - CR179801144 */
	 if ( me->Product == VR_RWAY )
	 {
         /******* ETL2174 update spec - tr179901408 **********/
         strcpy( NewListAttr[NBcnt].name, VR_N_CLASS_AN);
         NewListAttr[NBcnt].desc.type = AC_ATTRIB_TEXT;
         VR$RDB_SNAM( p_nam = NewListAttr[NBcnt].desc.value.att_txt,
                           num = me->OB.rway.VendorNo );
         __DBGpr_str(" Spec string in params",
                                     NewListAttr[NBcnt].desc.value.att_txt );
         NBcnt++;
	     /* Modified for CR179900491 */
	     FIfld_set_mode(form_ptr, RW_DEPTH, 0, FI_REVIEW);
	     FIg_display( form_ptr, RW_DEPTH );
	     if( me->SketchMode == VR_MANUAL )
	     {
		 FIfld_set_mode(form_ptr, SMALL_RW_DEPTH, 0, FI_REVIEW);
		 FIg_display( form_ptr, SMALL_RW_DEPTH );

		 /* Below added by Anand for TR 179900778 */
		 if( me->bIsShapeTransition )
		 {
		     NewListAttr[shpid].desc.type = AC_ATTRIB_DOUBLE;
		     NewListAttr[shpid].desc.value.att_exp = me->nShapeCode;
		 }
		 /* Above added by Anand for TR 179900778 */
	     }
	 }
	 /******* TR179900780 *****/

	 /* Below added by Anand for CR 179900060 and CR 179900837 */
	 strcpy(NewListAttr[NBcnt].name, VR_N_CORN_RAD_DB);
	 NewListAttr[NBcnt].desc.type = AC_ATTRIB_DOUBLE;
	 FIg_get_value( me->form_ptr, CORN_RAD, &radius );
	 NewListAttr[NBcnt].desc.value.att_exp = radius;
	 ++NBcnt;
	 /* Above added by Anand for CR 179900060 and CR 179900837 */

	 /*moved to avoid conflict with piping-delivered with tr179900934 ***/
	 NbAttr = NBcnt;
     }

     /* Below modified for TR179900780 & tr179900932 cleanup ***/
     ParamId.objid = NULL_OBJID;
     ParamId.osnum = me->ModuleInfo.md_id.osnum;
     status = VR$ModifyCollection( p_msg		= &retcode,
				   p_InputCollectionId	= &me->ActParamId,
				   p_OutputCollectionId = &ParamId );
     as$status();
     as$status( sts = retcode );

     status = VR$ModifyCollection( p_msg		= &retcode,
				   Operation		= VR_MERGE_COLL,
				   p_ParamsListToModify	= NewListAttr,
				   NbParamsToModify	= NbAttr,
				   p_OutputCollectionId	= &ParamId );
     as$status();
     as$status( sts = retcode );
     /* Not sure is needed for tr179901408 */
        VR$active_params( operation    = VR_REPLACE,
                          VRproduct    = me->Product,
                          update_flag  = VR_UPDATE,
                          act_param_id = &ParamId,
                          status       = retcode );

     /* Below modified for CR179900491 - Dynamic depth */
     if( me->SketchMode == VR_AUTOMATIQUE )
     {
	 if ( me->Product == VR_RWAY )
	 {
	     /** Modified for CR179900491 **/
	     if( me->shape_gadget == RW_O_SHAPE )
		 shape_code = VR_OVAL;
	     else if( me->shape_gadget == HV_C_SHAPE )
		 shape_code = VR_CIRC;
	     else if( me->shape_gadget == RW_RS_SHAPE )
		 shape_code = VR_CORNER;
	     else if( me->shape_gadget == RW_E_SHAPE )
		 shape_code = VR_ELLIPSE;
	     else
		 shape_code = VR_RECT;

	     /* Reddy - Shape coordination */
	     if(me->shape_gadget == RW_C_SHAPE)
	     {
		 FIg_erase( me->form_ptr , RW_DEPTH) ;
		 FIg_erase( me->form_ptr , RW_D_TXT) ;
	     }

	     __DBGpr_int(" Shape code", shape_code );
	     __DBGpr_dbl(" Depth 1", me->RWcptdata[0].depth);
	     __DBGpr_dbl(" Depth 2", me->RWcptdata[1].depth);

	     /*** TR179801414 - labeled as a KLUDGE in test src ***/
	     __DBGpr_com("setting cpt0&1 equal to each other");
	     me->RWcptdata[1] = me->RWcptdata[0];

	     status = VRRwayTraySelector( me->form_ptr, gadget_label,
					  me->SketchMode, &ParamId );

	     NbCpts = 2;
	     __DBGpr_int("no. of cpts to store",NbCpts);
	     status = VRRw_dimen_fields( NULL,NULL,&my_grid, &me->ModuleInfo,
	     				 NbCpts, NULL, 2, shape_code,
					 me->RWcptdata, &ParamId);
	 }

	 /*| sketch mode is AUTOMATIQUE */
	 me->ActParamId = ParamId;
	 status = 
	 VR$active_params( operation    = VR_REPLACE,
			   update_flag  = VR_UPDATE,
			   VRproduct    = me->Product,
			   act_param_id = &me->ActParamId,
			   status       = status );

	 /* Modified for CR179900491 */
	 status=VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget,
	 			&ParamId, me->CmpAABBCCcode, &me->active_cpt,
				me->RWcptdata, &me->ModuleInfo, VR_AUTOMATIQUE);
	 __DBGpr_com("Back from VRSkUpdateForm");
	 as$status();
     }
     /* Below modified for CR179900491 - Dynamic depth */
     else /* sketch mode is manual */
     {
	 __DBGpr_com(" Manual sketchmode in FI_EXECUTE");
	 if ( me->Product == VR_RWAY )
	 {
	     /* Modified for CR179900491 */
             /* Modified for tr179901470 */
	     if( me->shape_gadget == RW_O_SHAPE )
		 shape_code = VR_OVAL;
	     else if( me->shape_gadget == HV_C_SHAPE )
		 shape_code = VR_CIRC;
	     else if( me->shape_gadget == RW_RS_SHAPE )
		 shape_code = VR_CORNER;
	     else if( me->shape_gadget == RW_E_SHAPE )
		 shape_code = VR_ELLIPSE;
	     else
		 shape_code = VR_RECT;

	     if( me->proc_livelook )
		 NbCpts = me->OB.rway.NbCpts;
	     else
	     {
                 /*** Modified for ETL2174 - tr179901408 ****/
                 VR$RDB_SNAM( p_nam = spec_name,
                                num = me->OB.rway.VendorNo );

		 /* added by alwin to send proper shape_code value for
		    finding out "nb_cpts" */

		 if( me->bIsShapeTransition )
		     shape_code = me->nShapeCode;

		 /*** Get the number of cpts to store */
		 status = VRGetComp_NbCpt( &longmsg, (IGRshort) me->Product,
		 			   shape_code, spec_name,
					   me->CmpAABBCCcode, &NbCpts);

		 /* NbCpts = some magic number */
		 if(NbCpts < 1 || NbCpts > 10)
		     NbCpts = 2;
	     }

	     /*****************************************************/ 
	     /*** REALLY BAD KLUDGE for COTRAN for TR179900976  ***/
	     /*** The new macro is reversed, but swaps the ends ***/
	     /*** in manual mode, so we swap the ends before    ***/
	     /*****************************************************/ 
	     if(shape_code == VR_OVAL_CIRC )
	     {
		 struct VRRwCptDetails tmpcptdata;
		 tmpcptdata = me->RWcptdata[0];
		 me->RWcptdata[0] = me->RWcptdata[1];
		 me->RWcptdata[1] = tmpcptdata;
	     }
	     __DBGpr_com("call3 of VRRw_dimen_fields");
	     status = VRRw_dimen_fields( NULL, NULL, &my_grid, &me->ModuleInfo,
	     NbCpts, NULL, 2, shape_code, me->RWcptdata, &ParamId);
	     __DBGpr_int("NbCpts",NbCpts);

	     /**** tr179900932 cleanup ****/
	     strcpy(NewListAttr[0].name, VR_N_CORN_RAD_DB);
	     NewListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
	     FIg_get_value( me->form_ptr, CORN_RAD, &radius );
	     NewListAttr[0].desc.value.att_exp = radius;

 /**** Trying to update collection for corner radius-may not be successful ***/
	     status = VR$ModifyCollection( p_msg		= &retcode,
					   Operation            = VR_MERGE_COLL,
					   p_ParamsListToModify	= NewListAttr,
					   NbParamsToModify     = 1,
					   p_OutputCollectionId = &ParamId );
	     /*me->ActParamId = ParamId; Original did not have this -tr179900932 cleanup */
	     /*** Added for tr179900780 ***/
	     /*****************************/
	     if( ! me->bIsShapeTransition )
	     {
		 me->RWcptdata[0] = me->RWcptdata[1];
/*** If needed 
             status = VRRw_dimen_fields( NULL, NULL, &my_grid, &me->ModuleInfo,
             NbCpts, NULL, 2, shape_code, me->RWcptdata, &ParamId);
**********/
	     }

	 }
	 me->ListIds[0] = ParamId;
	 /*^ VRprint_user_attr( &me->ListIds[0] ); */
	 switch( me->Product )
	 {
	   case VR_PIPING:
	       /* -- get the code corresponding the text -- */
	       {
		   IGRlong	msg;
		   IGRint	o_code;
		   IGRchar	p_error[30];

                   /**** 80 characters option code *********/
		   FIfld_get_text( me->form_ptr, OPTION, row, col, 80, 
				   (unsigned char *) text, &sel_flag, &r_pos );

		   status = vd$get_alias ( p_msg	= &msg,
					   product	= PIPING,
					   type		= VR_OPTCODE_LIST_NUM,
					   i_lname	= text,
					   o_code	= &o_code,
					   p_error	= p_error	);

		   if ( status != OM_S_SUCCESS )
		       me->CmpOption = (int)atoi(text);
		   else
		       me->CmpOption = o_code;
	       }
               /*** TR179901548 ***/
               /* Note that the customer asked for 14, but some instance ***/
               /* structures use 13. Update later if more is needed.     ***/
	       FIfld_get_text( me->form_ptr, PP_CMP_NB, row, col, 13, 
			       (unsigned char *) text, &sel_flag, &r_pos );
	       strcpy( me->CmpNumber, text );
	       break;
	   case VR_HVAC:
	       FIfld_get_text( me->form_ptr, HV_CMP_NB, row, col, 10, 
			       (unsigned char *) text, &sel_flag, &r_pos );
	       strcpy( me->CmpNumber, text );
	       break;
	   case VR_RWAY:
	       FIfld_get_text( me->form_ptr, RW_CMP_NB, row, col, 10, 
			       (unsigned char *) text, &sel_flag, &r_pos );
	       strcpy( me->CmpNumber, text );
	       break;
	   default:break;
	 }

     }
     _put_response( resp = EX_FORM_FINISHED );

     break;

	case FI_RESET:
		/* redisplay gadget */
		FIbtn_set_auto_pop_up_on( me->form_ptr, FI_RESET );
  		status = om$send( msg      = message VRsketch.VRSwapSketchForm
							    ( me->SketchMode ),
	            		  targetid = my_id );
  		as$status();
/*** Trying to stop crashes on reset tr179900780 ****/
me->active_cpt = 1;
                     status =
                        om$send( msg      = message ACncpx.ACgive_structure
                                 ( &retstatus,
                                   &FootIndex,
                                   VR_N_SHAPE_IN,
                                   &ParamAttr,
                                   &me->ModuleInfo),
                        targetid = me->ActParamId.objid,
                        targetos = me->ActParamId.osnum );

    shape_code = (IGRint) ParamAttr.var.root_pm_st.value;
    if(me->Product == VR_RWAY)  /** tr179900932 cleanup */
    {
             status = VRRw_dimen_fields(NULL, NULL, NULL, &me->ModuleInfo, 2,
					&me->active_cpt, 0, shape_code,
					me->RWcptdata, &me->ActParamId);
             __DBGpr_com("back from VRRw_dimen_fields");
    }

/*** end of crash prevention ****/
		break;
        /* Added for TR179900985 HVAC transition processing */
        case SMALL_HV_DEPTH:
           break;
        default:
           /* Modified for CR179900491 */
           __DBGpr_com("trapped to unknown gadget");
           if( me->shape_gadget == RW_O_SHAPE )
              shape_code = VR_OVAL;
           else if( me->shape_gadget == HV_C_SHAPE )
              shape_code = VR_CIRC;
           else if( me->shape_gadget == RW_RS_SHAPE )
              shape_code = VR_CORNER;
           else if( me->shape_gadget == RW_E_SHAPE )
              shape_code = VR_ELLIPSE;
           else
              shape_code = VR_RECT;

           if(me->SketchMode == VR_MANUAL)
           {
		     /* get the spec name */
             status = 
                 om$send( msg      = message ACncpx.ACgive_structure
                          ( &retstatus, 
                            &FootIndex, 
                            VR_N_CLASS_AN,
                            &ParamAttr, 
                            &me->ModuleInfo),
                 targetid = me->ActParamId.objid,
                 targetos = me->ActParamId.osnum );
	     strcpy (spec_name,ParamAttr.var.text_st.text_string);

             /* added by alwin to send proper shape_code value for
             finding out "nb_cpts" */

             if( me->bIsShapeTransition )
               shape_code = me->nShapeCode;

	     /*** Get the number of cpts to store */
             status = VRGetComp_NbCpt(
			&longmsg,(IGRshort) me->Product,shape_code,spec_name,
						 me->CmpAABBCCcode, &NbCpts);
             __DBGpr_int("NbCpts ",NbCpts);
             __DBGpr_com("Call8 for VRRw_dimen_fields");
             if(NbCpts < 1 || NbCpts > 10)
                  NbCpts = 10;
           }
           else
             NbCpts = 2;

	    if(me->Product == VR_RWAY) /* tr179900932 cleanup */
	    {
		__DBGpr_obj(" Paramer ID",ParamId);
		 status = VRRwayTraySelector( me->form_ptr, gadget_label,
					      me->SketchMode,
					      &(me->ActParamId) );
		 __DBGpr_int("NbCpts is a magic number here",NbCpts);
		 status = VRRw_dimen_fields(me->form_ptr, gadget_label, NULL,
					    &me->ModuleInfo, NbCpts,
					    &me->active_cpt, 1, shape_code,
					    me->RWcptdata, &ParamId);
		 __DBGpr_com("back from VRRw_dimen_fields");
	    }

            /* Reddy - Shape coordination */
            if(shape_code == VR_CIRC) {
              FIg_erase( me->form_ptr , RW_DEPTH) ;
              FIg_erase( me->form_ptr , RW_D_TXT) ;
            }
            if(me->SketchMode != VR_MANUAL){
                FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX_TEXT );
                FIg_erase( me->form_ptr, DECREASE_ACTIVE_CPT_INDEX );
                FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX );
                FIg_erase( me->form_ptr, INCREASE_ACTIVE_CPT_INDEX );
            }

            /*| Unknown Gadget */
	    break;
   	}
  } /* end of if */
  else if( form_ptr == me->forms[0].form_ptr )
  {
    IGRint	sel_flag, r_pos, row = 0, i, num_rows, length;
    IGRchar	VRbuffer_user_values[VR_MAX_CHAR*VR_MAX_ATTR];
    IGRchar	VRbuffer_user_names[VR_MAX_CHAR*VR_MAX_ATTR];
    IGRchar	*VRuser_names[VR_MAX_ATTR], *VRuser_values[VR_MAX_ATTR];

    for( i=0; i<VR_MAX_ATTR; i++ )
    {
	VRuser_names[i]  = &VRbuffer_user_names [ VR_MAX_CHAR * i];
	VRuser_values[i] = &VRbuffer_user_values[ VR_MAX_CHAR * i];
    }

    switch ( gadget_label )
    {
      	case USER_ATTR_FLD:
        	break;

      	case FI_EXECUTE:
		FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

       		FIfld_get_max_num_rows( form_ptr, USER_ATTR_FLD, &num_rows );
       		for ( row=0, length=0; row<num_rows; row++ )
       		{
        		FIfld_get_text_length( form_ptr, USER_ATTR_FLD, row, 0, &length );

          		if( length >1 )
          		{
            			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, 0,
					    length,
 				            (unsigned char *)VRuser_names[row],
					     &sel_flag, &r_pos
					      );
			    	/*"parameter %d name = %s\n", row, VRuser_names[row] */
			    
            		    	FIfld_get_text_length( form_ptr, USER_ATTR_FLD, row, 1, &length );

            		    	if( length < 2 ) length = 10;
            		    	FIfld_get_text( form_ptr, USER_ATTR_FLD, row, 1,
					length, 
					(unsigned char *)VRuser_values[row], 
					&sel_flag, &r_pos
					       );
			    	/*"parameter %d value = %s\n", row, VRuser_values[row] */
          		}
          		else
          	 	{
        			status = VRchg_attributes
                 	   	         ( VR_ADD_OR_MOD_PARAM, me->MissParamId, row, VRuser_names, VRuser_values );
        		    	as$status( action = RET_STATUS );

    				_put_response( resp = EX_FORM_FINISHED );
				End
				return OM_S_SUCCESS;
          		}
        	}
        	break;
    }
  }
  else if( form_ptr == me->status_display_form_ptr )
  {
    bNewPocket=TRUE;
    /* Below lines added for CR 179801143 by Anand */
    if( me->proc_livelook && me->Product==VR_RWAY )
    {
	status=VRRacewayLiveLookUp( &retcode, form_ptr, gadget_label,
				    &(me->OB.rway), &(me->proc_livelook),
				    &(me->new_live), NULL );
	if(gadget_label == FI_CANCEL)
	{
            /* Restore the active params version of vendor name */
            /** ETL2174 - TR179901408 **/
            status =
                 om$send( msg     = message ACncpx.ACgive_structure
                                                          ( &retstatus,
                                                            &FootIndex,
                                                            VR_N_CLASS_AN,
                                                            &ParamAttr,
                                                            &me->ModuleInfo),
                         targetid = me->ActParamId.objid,
                         targetos = me->ActParamId.osnum );

            VR$RDB_SNUM (p_nam = ParamAttr.var.text_st.text_string,
                         p_num = &me->OB.rway.VendorNo );

	    FIf_display(me->form_ptr);
	    me->form_requested = 0;
	    me->my_ret = VR_DEFAULT_VALUE;
	    _put_response( resp = EX_BACK_UP );
	    End
	    return OM_S_SUCCESS;
	}
           if( me->shape_gadget == RW_O_SHAPE )
              shape_code = VR_OVAL;
           else if( me->shape_gadget == HV_C_SHAPE )
              shape_code = VR_CIRC;
           else if( me->shape_gadget == RW_RS_SHAPE )
              shape_code = VR_CORNER;
           else if( me->shape_gadget == RW_E_SHAPE )
              shape_code = VR_ELLIPSE;
           else
              shape_code = VR_RECT;

	if(gadget_label == FI_ACCEPT)
	{
	    me->nShapeCode = me->OB.rway.ShapeCode;

	    /* Below two lines added as a fix for TR 179901277 - a
	    /* Rationale given by Rod - Shape transitions have shape codes
	     * greater than 10. */
            /* Updated for tr179901470-swap to new shape */
	    if( me->nShapeCode > 10 )
            {
		me->bIsShapeTransition = TRUE;
                FIg_erase(me->form_ptr,RW_R_SHAPE);
                FIg_erase(me->form_ptr,RW_RS_SHAPE);
                FIg_erase(me->form_ptr,RW_O_SHAPE);
                FIg_erase(me->form_ptr,RW_C_SHAPE);
                FIg_erase(me->form_ptr,RW_E_SHAPE);
                if(me->nShapeCode == VR_RECT_OVAL)
                {
                   if(me->shape_gadget == RW_R_SHAPE)
                      me->shape_gadget = RW_O_SHAPE;
                   else
                      me->shape_gadget = RW_R_SHAPE;
                }
                else if(me->nShapeCode == VR_RECT_CIRC)
                {
                   if(me->shape_gadget == RW_R_SHAPE)
                      me->shape_gadget = RW_C_SHAPE;
                   else
                      me->shape_gadget = RW_R_SHAPE;
                }
                else if(me->nShapeCode == VR_RECT_CORN)
                {
                   if(me->shape_gadget == RW_R_SHAPE)
                      me->shape_gadget = RW_RS_SHAPE;
                   else
                      me->shape_gadget = RW_R_SHAPE;
                }
                else if(me->nShapeCode == VR_RECT_ELLP)
                {
                   if(me->shape_gadget == RW_R_SHAPE)
                      me->shape_gadget = RW_E_SHAPE;
                   else
                      me->shape_gadget = RW_R_SHAPE;
                }
                else if(me->nShapeCode == VR_OVAL_CIRC)
                {
                   if(me->shape_gadget == RW_O_SHAPE)
                     me->shape_gadget = RW_C_SHAPE;
                   else
                     me->shape_gadget = RW_O_SHAPE;
                }
                else if(me->nShapeCode == VR_OVAL_CORN)
                {
                   if(me->shape_gadget == RW_O_SHAPE)
                     me->shape_gadget = RW_RS_SHAPE;
                   else
                     me->shape_gadget = RW_O_SHAPE;
                }
                else if(me->nShapeCode == VR_OVAL_ELLP)
                {
                   if(me->shape_gadget == RW_O_SHAPE)
                      me->shape_gadget = RW_E_SHAPE;
                   else
                      me->shape_gadget = RW_O_SHAPE;
                }
                else if(me->nShapeCode == VR_CIRC_CORN)
                {
                   if(me->shape_gadget == RW_C_SHAPE)
                      me->shape_gadget = RW_RS_SHAPE;
                   else
                      me->shape_gadget = RW_C_SHAPE;
                }
                else if(me->nShapeCode == VR_ELLP_CORN)
                {
                   if(me->shape_gadget == RW_E_SHAPE)
                     me->shape_gadget = RW_RS_SHAPE;
                   else
                     me->shape_gadget = RW_E_SHAPE;
                }
                else if(me->nShapeCode == VR_CIRC_ELLP)
                {
                   if(me->shape_gadget == RW_E_SHAPE)
                     me->shape_gadget = RW_C_SHAPE;
                   else
                     me->shape_gadget = RW_E_SHAPE;
                }
                FIg_display(me->form_ptr, me->shape_gadget);
            }
	    strcpy(me->CmpAABBCCcode,me->OB.rway.CompCode);

	    if( me->OB.rway.CompNumb )
	    {
		// Using strncpy below with 13 bytes. May need revision??
		strncpy( me->CmpNumber, me->OB.rway.CompNumb, 13);
		_FREE(me->OB.rway.CompNumb);
	    }

	    NbCpts = me->OB.rway.NbCpts;

	    me->bTagNumUsed = TRUE;

	    me->bI_Need_Pick = TRUE;

	    NbAttr = 0;

	    strcpy( NewListAttr[NbAttr].name, VR_N_WIDTH1_DB );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	    NewListAttr[NbAttr].desc.value.att_exp = me->OB.rway.InlWidth;
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_DEPTH1_DB );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	    NewListAttr[NbAttr].desc.value.att_exp = me->OB.rway.InlDepth ;
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_WIDTH2_DB );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	    NewListAttr[NbAttr].desc.value.att_exp = me->OB.rway.OutWidth;
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_DEPTH2_DB );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	    NewListAttr[NbAttr].desc.value.att_exp = me->OB.rway.OutDepth;
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_SHAPE_IN );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
	    NewListAttr[NbAttr].desc.value.att_exp = me->OB.rway.ShapeCode;
	    __DBGpr_int(" Shape code in params",
				     NewListAttr[NbAttr].desc.value.att_exp );
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_CLASS_AN);
	    NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
	    VR$RDB_SNAM( p_nam = NewListAttr[NbAttr].desc.value.att_txt,
		           num = me->OB.rway.VendorNo );
	    __DBGpr_str(" Spec string in params",
				     NewListAttr[NbAttr].desc.value.att_txt );
	    NbAttr ++;

	    strcpy( NewListAttr[NbAttr].name, VR_N_COMP_CODE_AN );
	    NewListAttr[NbAttr].desc.type          = AC_ATTRIB_TEXT;
	    strcpy( NewListAttr[NbAttr].desc.value.att_txt,
							me->OB.rway.CompCode );
	    NbAttr ++;

	    VR$active_params( operation    = VR_RETRIEVE,
			      VRproduct    = me->Product,
			      act_param_id = &me->ActParamId,
			      status       = status );
	    as$status();

	    ParamId.objid = NULL_OBJID;
	    ParamId.osnum = me->ModuleInfo.md_id.osnum;

	    status=VR$ModifyCollection( p_msg		     = &retcode,
					p_InputCollectionId  = &me->ActParamId,
					p_OutputCollectionId = &ParamId );
	    as$status();
	    as$status( sts = retcode );

	    status = VR$ModifyCollection( p_msg		       = &retcode,
					  Operation            = VR_UPDATE_COLL,
					  p_ParamsListToModify = NewListAttr,
					  NbParamsToModify     = NbAttr,
					  p_OutputCollectionId = &ParamId );
	    as$status();
	    as$status( sts = retcode );

	    me->ListIds[0] = ParamId;

	    me->form_requested = 0;
	    me->SketchMode = VR_MANUAL;
	    FIf_display(me->form_ptr);

	    __DBGpr_int(" Number of Cpts",NbCpts );
	    status = VRRw_dimen_fields( me->form_ptr, 0, NULL,
					&me->ModuleInfo, NbCpts,
					&me->active_cpt, 0, me->nShapeCode,
					me->RWcptdata, &ParamId );
	    status = VRRw_dimen_fields( me->form_ptr, 0, NULL,
					&me->ModuleInfo, NbCpts,
					&me->active_cpt, 1, me->nShapeCode,
					me->RWcptdata, &ParamId );

	    FIfld_set_text(me->form_ptr,RW_CMP_NB,0,0,me->CmpNumber,FALSE);
	}
	goto quit;
    }
    /* Above lines added for CR 179801143 by Anand */
    else if( ( me->prev_seg_id.objid == NULL_OBJID || !me->SketchMode ) &&
            gadget_label != FI_CANCEL )
    {
      ex$message( field   = ERROR_FIELD,
                  in_buff = "Cannot place component !" );

      status =
      om$send( msg = message VRsketch.VRSkPopupStatusField( &retcode ),
          targetid = my_id );

      End
      return OM_S_SUCCESS;    
    }

    me->SketchMode = VR_MANUAL;
    __DBGpr_com("sketchmode set to VR_MANUAL");

    /* This form sets and activates specific pocket menus */

    switch( me->Product )
    {
      case VR_PIPING:
            switch( gadget_label )
        {
          case FI_CANCEL:
            FIf_erase( form_ptr );
            me->form_requested = 0;
            me->my_ret = VR_DEFAULT_VALUE;
	    End
            return OM_S_SUCCESS;

          case P_REDUCER_BUTTON :
            me->PocketMenuName = PREDUCERPKTMNU;
            me->CmpFunction = IS_REDUCER;
            break;

          case VALVE_BUTTON :
            me->PocketMenuName = PVALVEPKTMNU;
            me->CmpFunction = IS_VALVE;
            break;

          case ENDPIPE_BUTTON :
            me->PocketMenuName = PPIPEENDSPKTMNU;
            me->CmpFunction = IS_ENDPIPE;
            break;

          case P_ELBOW_BUTTON :
            me->PocketMenuName = PELBOWPKTMNU;
            me->CmpFunction = IS_ELBOW;
            break;

          case P_TEE_BUTTON :
            me->PocketMenuName = PTEEPKTMNU;
            me->CmpFunction = IS_TEE;
            break;

          case FLANGE_BUTTON :
            me->PocketMenuName = PFLANGEPKTMNU;
            me->CmpFunction = IS_FLANGE;
            break;

          case SPECIALITY:
            me->PocketMenuName = PSPECIALPKTMNU;
            me->CmpFunction = IS_SPECIALITY;
            break;

          case INSTRUMENT:
            me->PocketMenuName = PINSTRUPKTMNU;
            me->CmpFunction = IS_INSTRUMENT;
            break;

          case CONNECTOR:
            me->PocketMenuName = PCONNECPKTMNU;
            me->CmpFunction = IS_CONNECTOR;
            break;

          case P_USER :
            bNewPocket = FALSE;
            FIbtn_set_auto_pop_up_off( form_ptr, gadget_label );
            break;
        }
        break;
    case VR_HVAC:

          switch( gadget_label )
          {
              case FI_CANCEL:
          FIf_erase( form_ptr );
           me->form_requested = 0;
               me->my_ret = VR_DEFAULT_VALUE;
	       End
           return OM_S_SUCCESS;

        case H_ELBOW_BUTTON :
          me->PocketMenuName = HELBOWPKTMNU;
          me->CmpFunction = IS_ELBOW;
           break;

        case H_TEE_BUTTON :
          me->PocketMenuName = HTEEPKTMNU;
          me->CmpFunction = IS_TEE;
           break;

        case H_OFFSET_BUTTON:
          me->PocketMenuName = HOFFSETPKTMNU;
          me->CmpFunction = IS_OFFSET;
           break;


        case ENDDUCT_BUTTON:
          me->PocketMenuName = HDUCTENDSPKTMNU;
          me->CmpFunction = IS_ENDDUCT;
           break;

        case H_REDUCER_BUTTON:
          me->PocketMenuName = HREDUCERPKTMNU;
          me->CmpFunction = IS_REDUCER;
           break;

        case DEVICE_BUTTON:
          me->PocketMenuName = HTDEVICEPKTMNU;
          me->CmpFunction = IS_DEVICE;
          break;

        case TERMINATION:
          me->PocketMenuName = HTDEVICEPKTMNU;
          me->CmpFunction = IS_TERMINATION_DEVICE;
           break;

        case H_USER :
          bNewPocket = FALSE;
          FIbtn_set_auto_pop_up_off( form_ptr, gadget_label );
          break;

  /* Not yet implemented because we are unable to know wich shape is chosen */
        case TRANSITION_BUTTON :
          me->PocketMenuName = HTRANSITPKTMNU;
          me->CmpFunction = IS_TRANSITION;
           break;
            }
      break;

    case VR_RWAY:
      switch( gadget_label )
          {
        case FI_CANCEL:
          FIf_erase( form_ptr );
           me->form_requested = 0;
               me->my_ret = VR_DEFAULT_VALUE;
	       End
          return OM_S_SUCCESS;

        case R_REDUCER_BUTTON:
          me->PocketMenuName = HREDUCERPKTMNU;
          me->CmpFunction = IS_REDUCER;
           break;

        case R_ELBOW_BUTTON :
          me->PocketMenuName = HELBOWPKTMNU;
          me->CmpFunction = IS_ELBOW;
           break;

        case R_TEE_BUTTON :
          me->PocketMenuName = HTEEPKTMNU;
          me->CmpFunction = IS_TEE;
           break;

        case R_OFFSET_BUTTON:
          me->PocketMenuName = HOFFSETPKTMNU;
          me->CmpFunction = IS_OFFSET;
           break;

        case R_USER :
          bNewPocket = FALSE;
          FIbtn_set_auto_pop_up_off( form_ptr, gadget_label );
          break;

      }
      break;

    default : bNewPocket = FALSE; break;
    }/* end switch on products */
  if (bNewPocket)
  {
    VRChangePocketMenu( me->PocketMenuName );
    me->ChangePocket= TRUE;
  }
  if(!me->proc_livelook) /* CR179308634 - Livelookup */
  {
     _put_response( resp = EX_POCKET );
  }
  }/* end status display form */
quit:
  End
  return OM_S_SUCCESS;
}

end implementation VRsketch;


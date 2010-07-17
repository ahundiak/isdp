/****************************************************************************

	Filename:	SFCoConvBm.sl
	Author:		Raju M S B
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SFCoConvBm.sl
	Output:		SFCoConvBm.S   and  SFCoConvBmi.I
	makemake file	strfem.m -> makefile -> strfem.o

	Description:

	History:
	Raju 	05-25-1994	Creation date


/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	SFC_M_ConvBeam, 0, SFConvBm
class		SFCoConvBm
super_class	CEO_LOCATE
product_name	"$STRFEM"
command_table	"sf.cmd"

/* form used */
form		"SFConvBeam",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#include "growner.h"

#define  SF_INIT_BEAMS   2
#define  FP_BEAM	 me^^CEO.forms[0].form_ptr

instance
{
 int			     BeamCount;
			     /* no. of beams selected for conversion */

 variable struct  GRobj_env  VSbeamList[SF_INIT_BEAMS];
			     /* struct beam ids and envs */

 variable struct  GRid	     FEbeamAxisList[SF_INIT_BEAMS];
			     /* struct beam centroidal axis list  */

 variable char		     MatCreateFlag[SF_INIT_BEAMS];
			     /* TRUE : material has been created for that beam
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     PrpCreateFlag[SF_INIT_BEAMS];
			     /* same as materials */

 struct  GRmd_env	     MyEnv;
			     /* this is same as ModuleInfo except that
				MyEnv.md_id.objid = NULL_OBJID. All the
				manipulations are done outside range tree.
				FEbeamAxisList is added to range tree when the
				form is accepted */
}


/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "asmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griomacros.h"

#include "coparamac.h"
#include "grdpbmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"

#include "AS_status.h"
#include "acrepdef.h"
#include "vsdef.h"
#include "vsplatedef.h"

#include "APdef.h"
#include "APunitdef.h"
#include "FElimits.h"

#include "SFconvDef.h"
#include "SFconvBmDef.h"
#include "SFmsg.h"

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

from   GRgraphics 	import GRdisplay;
from   NDmacro    	import ACreturn_foot;
from   NDmacro    	import ACgive_structure;
from   GRgraphics	import GRcopy;
from   GRvg		import GRputsymb;


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "SFmsg.h"

state start
	execute verifyLogin( &me->ret )
	on SUCCESS state realStart

	status_key SF_E_NoDbLogin
	on ELSE	   state terminate

state realStart
  message_key	      SF_M_ConvBeam
  prompt_key	      SF_P_LcBm
  relocate_key	      SF_I_BmNtFnd
  display_form	      0
  disconnect_located  0
  locate_owner        "LC_RIGID_COMP | LC_RIGID_OWNER |
                       LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  locate_eligible     "+VSbeam"
  mask                "GRm_DATA | GRm_OBJID |
		       GRm_STRING | GRm_RESET "
  filter	      locate
     on EX_DATA or EX_STRING or EX_OBJID
		do AddToList  state .
     on GR_UNKNOWN_TYPE.EX_FORM_FINISHED            state terminate
     on EX_RJT_MOVEON         do GetBeamsData
					on RETURN_CODE = "MSFAIL"  state .
								   state form_operations
state form_operations
  prompt_key		SF_P_EnterPar
  status		""
  filter		get_event
  on EX_FORM_FINISHED   state terminate

at init     do  init_all
	    do  set_form
at sleep    do  erase_hilite
at wakeup   do  hilite_selected
at delete   do  save_form_pos

action  form_notification			extern
action  PerformAcceptOp( long *msg )		extern
action  PerformDeleteOp()			extern


/****************************************************************************/
/*  action :  AddToList 						*****/
/****************************************************************************/

action  AddToList
{
struct  GRid		locobj;
int			ii, jj, itmp, count;
struct  GRobj_env	*ObjList;
int			response;
char			response_data[1024];
char			found;
enum	GRdpmode	dpmode;
long			msg;
long			BeamListSize;
char			RefFileName[15],
			reffile_writable;

#ifdef  SF_BEAM_DBG
  printf("Entered SFCoConvBm.AddToList\n");
  printf("\tLocated obj : [%d,%d]\n",
		me->event1.located_object[0].located_obj.objid,
		me->event1.located_object[0].located_obj.osnum );
#endif

  locobj.objid = me->event1.located_object[0].located_obj.objid;
  locobj.osnum = me->event1.located_object[0].located_obj.osnum;

  as$start_fence( set           = &locobj,
		  set_env       = &me->event1.located_object[0].module_info,
		  nb_obj        = &count,
		  p_obj_env     = &ObjList,
		  response      = &response,
		  response_data = response_data );

#ifdef  SF_BEAM_DBG
  printf( "\tno. of objects : [%d]\n", count );
  for ( ii=0;  ii<count; ii++ )
	printf( "\tobject id : [%d,%d]\n", ObjList[ii].obj_id.objid,
					   ObjList[ii].obj_id.osnum );
#endif

  /*  see if sufficient memory exists. If not, allocate memory */

  BeamListSize = om$dimension_of ( varray = me->VSbeamList );

  if ( me->BeamCount + count > BeamListSize )
  {
      status = om$vla_set_dimension (
			varray =  me->VSbeamList,
			size   =  me->BeamCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->FEbeamAxisList,
			size   =  me->BeamCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->MatCreateFlag,
			size   =  me->BeamCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->PrpCreateFlag,
			size   =  me->BeamCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	 printf("Can not allocate memory\n");
	 *sts = OM_E_ABORT;
	 goto quit;
      }

      for ( ii= BeamListSize; ii< me->BeamCount + count + 10; ii++)
      {
	me->FEbeamAxisList[ii].objid = NULL_OBJID;
	me->FEbeamAxisList[ii].osnum = EX_active_OS_num;
	me->PrpCreateFlag[ii] = FALSE;
	me->MatCreateFlag[ii] = FALSE;
      }
  }


  /* process ObjList */
  for ( ii=0;  ii<count; ii++ )
  {
     /* check if located object has already been located before */
     found = 0;
     for ( jj=0; jj < me->BeamCount; jj++ )
     {  if ( ObjList[ii].obj_id.objid == me->VSbeamList[jj].obj_id.objid  &&
	     ObjList[ii].obj_id.osnum == me->VSbeamList[jj].obj_id.osnum )
	{
	   found = 1;
	   break;
	}
     }


     if ( !found )
     {
        /*  make sure  located object is in reference OS  */
	if ( ObjList[ii].obj_id.osnum == me->ModuleInfo.md_id.osnum )
	{
	   ex$message(	field		= ERROR_FIELD,
			msgnumb		= SF_E_BmNtInRef,
			justification	= CENTER_JUS );
	   dpmode = GRbdhe;
	   status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&ObjList[ii].mod_env.md_env.matrix_type,
			ObjList[ii].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = ObjList[ii].obj_id.objid,
		     targetos = ObjList[ii].obj_id.osnum );
	   continue;
	}

	/* make sure reference OS is writable */
	status = SFis_reffile_writable( &msg,
					ObjList[ii].obj_id.osnum,
					RefFileName,
					&reffile_writable );

	if ( ! ( status & msg & 1 ) )
	{
	   printf("Error in SFis_reffile_writable\n");
	   continue;
	}
	if ( !reffile_writable )
	{
	   ex$message(	field		= ERROR_FIELD,
			msgnumb		= SF_E_RefFileNtUpd,
			justification	= CENTER_JUS,
			type		= "%s",
			var		= `RefFileName` );
	   dpmode = GRbdhe;
	   status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&ObjList[ii].mod_env.md_env.matrix_type,
			ObjList[ii].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = ObjList[ii].obj_id.objid,
		     targetos = ObjList[ii].obj_id.osnum );
	   continue;
	}

        /* object is in reference file which is writable. Add to the
	   VSbeamList */
	me->VSbeamList[me->BeamCount] = ObjList[ii];
	me->BeamCount++;

	/* display located beam in half highlight mode */
	itmp = me->BeamCount - 1;
	dpmode = GRhhd;
	status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->VSbeamList[itmp].mod_env.md_env.matrix_type,
			me->VSbeamList[itmp].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->VSbeamList[itmp].obj_id.objid,
		     targetos = me->VSbeamList[itmp].obj_id.osnum );
     }
     else   /* already in VSbeamList.  display it in half highlight mode */
     {
	dpmode = GRhhd;
	status = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&me->VSbeamList[jj].mod_env.md_env.matrix_type,
				me->VSbeamList[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			   targetid = me->VSbeamList[jj].obj_id.objid,
			   targetos = me->VSbeamList[jj].obj_id.osnum );
     }
  }
  ASend_fence();

  if ( me->BeamCount > 0 )
	ex$message (	field   = ERROR_FIELD,
			msgnumb = SF_I_BmSel,
			justification = CENTER_JUS,
			type	= "%d",
			var	= `me->BeamCount` );

  *sts = MSSUCC;

}

/* ==========================================================================
   action : GetBeamsData

   This action gets the centroidal axes of VSbeams and displays them.
   This also gets material type and grade for each VSbeam and  gets
   corresponding FEM material name ( If FEM material does not exist, it
   creates a material ).
   This also gets section properties of VSbeams and gets corresponding
   FEM property name ( if FEM property does not exist, it creates a property).
   Finally it displays VSbeam name, FEM material name and FEM property name
   on the form.

=========================================================================== */

action  GetBeamsData
{
  int			ii, msg1;
  enum	 GRdpmode	dpmode;
  long			msg;
  int			index = -1; /* unused ASSOC flag */
  struct ret_struct	rs;
  struct GRsymbology    ActSymb;
  char			MatType[80],
			MatGrade[80],
			MatName[FE_MAX_MPNAME_SIZE],
			PrpName[FE_MAX_MPNAME_SIZE];
  char			MatCreateFlag,
			PrpCreateFlag;
  char			BmExtractOpt[ATTR_TXT];
  int			NbFemElem;



  if ( me->BeamCount == 0 )
  {	_put_response ( resp = TERMINATE );
	goto quit;
  }

#ifdef SF_BEAM_DBG
  printf("Entered SFCoConvBm.GetBeamsData\n");
  for( ii=0; ii<me->BeamCount; ii++)
      printf("\tVSbeamList[%d] : [%d,%d]\n", ii,
		me->VSbeamList[ii].obj_id.objid,
		me->VSbeamList[ii].obj_id.osnum );
#endif

  /* unhighlight half highlight display  */
  dp$erase_hilite ( msg = &msg );

  /*
   *  get the conversion options
   */
  status = SFgetConvOpt(sts,
			NULL,
			NULL,
			NULL,
			NULL,
			&NbFemElem,
			NULL );
  VDS_ERR_HNDLR("Getting conversion options", status, *sts, VD_VERBOSE, quit);

  /*
   * One could change the beam extraction option after the form is displayed
   */

  FIg_get_text ( FP_BEAM, SF_BM_EXTRACT_FLD, BmExtractOpt );
  if ( !strcmp ( BmExtractOpt, SF_TXT_TRACE_CURVES ) )
	NbFemElem = SF_DEFAULT_MESH_SIZE;

  ActSymb.display_attr	 = me->ActiveDisplay;
  ActSymb.level		 = me->ActiveLevel;

  /* get the centriodal axes of the beams and display them in highlight mode */
  dpmode = GRhd;
  for( ii=0; ii < me->BeamCount; ii++ )
  {
      status = SFgetBeamCentroidalAxis ( &msg,
					 me->VSbeamList[ii].obj_id,
					 &me->VSbeamList[ii].mod_env,
					 &me->MyEnv,
					 &me->FEbeamAxisList[ii] );
      if ( !(status & msg & 1) )
      {
       printf("GetBeamsData: SFgetBeamCentroidalAxis failure for beam[%d,%d]\n",
			me->VSbeamList[ii].obj_id.objid,
			me->VSbeamList[ii].obj_id.osnum );
       continue;
      }

#ifdef SF_BEAM_DBG
      printf( "\tCentroidal axis : [%d,%d]\n", me->FEbeamAxisList[ii].objid,
					       me->FEbeamAxisList[ii].osnum );
#endif

      status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[ii].objid,
		     targetos = me->FEbeamAxisList[ii].osnum );

      /* get the materail type */
      status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMatTypAttr, &rs,
					&me->VSbeamList[ii].mod_env ),
			targetid = me->VSbeamList[ii].obj_id.objid,
			targetos = me->VSbeamList[ii].obj_id.osnum );
      if ( ! status & msg1 & 1 )
      {
	printf("GetBeamsData : NDmacro.ACgive_structure(mat type) failure\n");
	continue;
      }

      strcpy( MatType, rs.var.text_st.text_string );

#ifdef SF_BEAM_DBG
      printf ( "\tMat type : [%s]\n", MatType );
#endif

      /* get the material grade */
      status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMatGrdAttr, &rs,
					&me->VSbeamList[ii].mod_env ),
			targetid = me->VSbeamList[ii].obj_id.objid,
			targetos = me->VSbeamList[ii].obj_id.osnum );
      if ( ! status & msg1 & 1 )
      {
	printf("GetBeamsData : NDmacro.ACgive_structure(mat grade) failure\n");
	continue;
      }

      strcpy( MatGrade, rs.var.text_st.text_string );

#ifdef SF_BEAM_DBG
      printf ( "\tMat Grade : [%s]\n", rs.var.text_st.text_string );
#endif

      /*  check if a material already exists with the properties. If not
       *  generate a name and create a material with the name and properties.
       */

      status = SFgetMatName( &msg, MatType, MatGrade, MatName, &MatCreateFlag);
      if ( !(status & msg & 1 ) )
      {
	

/*	 printf("Can not get material name for MatType[%s] and MatGrade[%s]\n",
				MatType, MatGrade );
*/
	*sts = MSFAIL;
	goto quit;
      }

      if ( MatCreateFlag )  me->MatCreateFlag[ii] = TRUE;

      /*  check if a property already exists for the beam . If not
       *  generate a name and create a property for the beam.
       */

      status = SFgenBeamProperty ( &msg, me->VSbeamList[ii].obj_id, PrpName,
				   &PrpCreateFlag );
      if ( !(status & msg & 1 ) )
      {
	*sts = MSFAIL;
	goto quit;
      }

      if ( PrpCreateFlag ) me->PrpCreateFlag[ii] = TRUE;

      /*  get the name of the beam  */
      status = om$send( msg       = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMbrNamAttr, &rs,
					&me->VSbeamList[ii].mod_env ),
			targetid  = me->VSbeamList[ii].obj_id.objid,
			targetos  = me->VSbeamList[ii].obj_id.osnum );
      if ( ! status & msg1 & 1 )
      {
	printf("GetBeamsData : NDmacro.ACgive_structure(name) failure\n");
	continue;
      }

#ifdef SF_BEAM_DBG
      printf ( "\tBeam Name : [%s]\n", rs.var.text_st.text_string );
#endif

      /*  display name, material and element property names */
      FIfld_set_text ( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 0,
			rs.var.text_st.text_string, 0 );
      FIfld_set_text ( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 1, MatName, 0 );
      FIfld_set_text ( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 2, PrpName, 0 );
      FIfld_set_value ( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 3,
			(double) NbFemElem, 0 );
  }

  *sts = MSSUCC;

}

/****************************************************************************/
/*  action :  init_all							    */
/*  		Initializes the instance data				    */
/****************************************************************************/
action  init_all
{
   int    ii,
	  numberOfBytes,
	  BytesReceived;
   long   msg,
	  BeamListSize;

   status = OM_S_SUCCESS;

   me->BeamCount = 0;
   BeamListSize = om$dimension_of ( varray = me->VSbeamList );
   for ( ii=0; ii< BeamListSize; ii++)
   {
	me->FEbeamAxisList[ii].objid = NULL_OBJID;
	me->FEbeamAxisList[ii].osnum = EX_active_OS_num;
	me->MatCreateFlag[ii]     = FALSE;
	me->PrpCreateFlag[ii]	  = FALSE;
   }

   numberOfBytes = sizeof ( me->MyEnv );
   gr$get_module_env(   msg     = &msg,
			sizbuf  = &numberOfBytes,
			buffer  = &me->MyEnv,
			nret    = &BytesReceived );

   me->MyEnv.md_id.objid = NULL_OBJID;

   dp$erase_hilite ( msg = &msg );

   goto quit;
}

action  erase_hilite
{

long  msg;

   status = OM_S_SUCCESS;

   dp$erase_hilite ( msg = &msg );

   goto quit;
}

action  hilite_selected
{

 int			ii;
 char			febeam_axes_created;
 long			msg;
 enum   GRdpmode	dpmode;

   if ( me->BeamCount == 0 )  return OM_S_SUCCESS;

   febeam_axes_created = FALSE;
   for ( ii=0; ii<me->BeamCount; ii++ )
      if ( me->FEbeamAxisList[ii].objid != NULL_OBJID )
      {  febeam_axes_created = TRUE;
	 break;
      }

   if ( febeam_axes_created )
   {
      dpmode = GRhd;
      for ( ii=0; ii<me->BeamCount; ii++)
      {
	 status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[ii].objid,
		     targetos = me->FEbeamAxisList[ii].osnum );
      }
  }
  else
  {
      dpmode = GRhhd;
      for ( ii=0; ii<me->BeamCount; ii++)
      {
	status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->VSbeamList[ii].mod_env.md_env.matrix_type,
			me->VSbeamList[ii].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->VSbeamList[ii].obj_id.objid,
		     targetos = me->VSbeamList[ii].obj_id.osnum );
      }
  }

  goto quit;

}

action  set_form
{
char			BmExtractOpt[ATTR_TXT];
int			ElemType,
			ConvAllEl;

  /*
   *  get the conversion options
   */
  status = SFgetConvOpt(sts,
			NULL,
			NULL,
			BmExtractOpt,
			&ElemType,
			NULL,
			&ConvAllEl );
  VDS_ERR_HNDLR("Getting conversion options", status, *sts, VD_VERBOSE, quit);

  FIg_set_text ( FP_BEAM, SF_BM_EXTRACT_FLD, BmExtractOpt );
  if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
  {
     if ( ElemType == LINE2 )
	FIg_set_state ( FP_BEAM, SF_BM_ELTYPE_FLD, TRUE );
     else
	FIg_set_state ( FP_BEAM, SF_BM_ELTYPE_FLD, FALSE );
  }

  if ( ConvAllEl )
	FIg_set_state ( FP_BEAM, SF_BM_CHK_CONVERTED_FLD, FALSE);
  else
	FIg_set_state ( FP_BEAM, SF_BM_CHK_CONVERTED_FLD, TRUE);

  if(x_pos != -1 && y_pos != -1)
    FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

  goto quit;

}

action  save_form_pos
{

  status = OM_S_SUCCESS;

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

  goto quit;

}

/*----------------------------------------------------------------------------*/
action verifyLogin
{

	status = OM_S_SUCCESS;

	*sts = VSisLoggedIntoRDB() ? MSSUCC : MSFAIL ;

	goto quit;

} /* method verifyLogin */


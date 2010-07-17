/****************************************************************************

	Filename:	SFCoStfndPl.sl
	Author:		Raju M S B
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SFCoStfndPl.sl
	Output:		SFCoStfndPl.S   and  SFCoStfndPli.I
	makemake file	strfem.m -> makefile -> strfem.o

	Description:

	History:
	Raju 	06-14-1994	Creation date


/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	SFC_M_ConvStfndPl, 0, SFStfndPl
class		SFCoStfndPl
super_class	CEO_LOCATE
product_name	"$STRFEM"
command_table	"sf.cmd"

/* form used */
form		"SFStfndPl",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#include "growner.h"

#define  SF_INIT_PLATES  2
#define  SF_INIT_BEAMS	 2
#define  FP_STFND_PL	 me^^CEO.forms[0].form_ptr

instance
{
 int			     PlateCount;
			     /* no. of plates selected for conversion */

 variable struct  GRobj_env  VSplateList[SF_INIT_PLATES];
			     /* struct plate ids and envs */

 variable int		     BeamsOnPl[SF_INIT_PLATES];
			     /* No. of beams on each plate */

 variable struct GRid	     FEplateList[SF_INIT_PLATES];
			     /* fem plate ids */

 int			     BeamCount;
			     /* Total no. of beams  */

 variable struct  GRobj_env  VSbeamList[SF_INIT_BEAMS];
			     /* struct beam list  */

 variable struct  GRid	     FEbeamAxisList[SF_INIT_BEAMS];
			     /* fem beam axis list  */

 variable char		     PlMatCreateFlag[SF_INIT_PLATES];
			     /* TRUE : material has been created for that plate
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     PlPrpCreateFlag[SF_INIT_PLATES];
			     /* same as materials */

 variable char		     BmMatCreateFlag[SF_INIT_BEAMS];
			     /* TRUE : material has been created for that beam
				       which will be deleted if form is deleted.
				FALSE: material has not been created  */

 variable char		     BmPrpCreateFlag[SF_INIT_BEAMS];
			     /* same as materials */

 struct  GRmd_env	     MyEnv;
			     /* this is same as ModuleInfo except that
				MyEnv.md_id.objid = NULL_OBJID. All the
				manipulations are done outside range tree.
				Resulting objects are added to range tree when
				the form is accepted */
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
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griomacros.h"
#include "griodef.h"
#include "grio.h"


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
#include "vs.h"
#include "vsgeommacros.h"

#include "APdef.h"
#include "APunitdef.h"
#include "FElimits.h"

#include "SFconvDef.h"
#include "SFstfndPlDef.h"
#include "SFmsg.h"

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

from   GRgraphics 	import GRdisplay;
from   NDmacro    	import ACreturn_foot;
from   NDmacro    	import ACgive_structure;
from   GRgraphics	import GRcopy;
from   GRvg		import GRputsymb;
from   EMSsubbs		import EMproject_curve_along_surface_normals;
from   VSfeature	import VSgetSupportedElements;
from   VSfeature	import VSgetSupports;



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
  message_key	      SF_M_ConvStfndPl
  prompt_key	      SF_P_LcStfndPl
  relocate_key	      SF_I_PlNtFnd
  display_form	      0
  disconnect_located  0
  locate_owner        "LC_RIGID_COMP | LC_RIGID_OWNER |
                       LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  locate_eligible     "+VSplate"
  mask                "GRm_DATA | GRm_OBJID |
		       GRm_STRING | GRm_RESET "
  filter	      locate
     on EX_DATA or EX_STRING or EX_OBJID
		do AddToList  state .
     on GR_UNKNOWN_TYPE.EX_FORM_FINISHED            state terminate
     on EX_RJT_MOVEON         do GetPlatesData
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
action  PlacePlateAtBot()			extern
action  PlacePlateAtTop()			extern
action  PlacePlateAtMid()			extern
action  PlacePlateAtKeyin( double  offset ) 	extern
action  PerformAcceptOp( long  *msg )		extern
action  PerformDeleteOp()			extern

/****************************************************************************/
/*  action :  AddToList 						*****/
/****************************************************************************/

action  AddToList
{
struct  GRid		locobj,
			*StfnrList = NULL;
int			ii, jj, itmp, count, NbStfnr;
struct  GRobj_env	*ObjList;
int			response;
char			response_data[1024];
char			found;
enum	GRdpmode	dpmode;
long			msg;
long			PlateListSize,
			BeamListSize;
char			RefFileName[15],
			reffile_writable;



#ifdef  SF_PLATE_DBG
  printf("Entered SFCoStfndPl.AddToList\n");
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

#ifdef  SF_PLATE_DBG
  printf( "\tno. of objects : [%d]\n", count );
  for ( ii=0;  ii<count; ii++ )
	printf( "\tobject id : [%d,%d]\n", ObjList[ii].obj_id.objid,
					   ObjList[ii].obj_id.osnum );
#endif

  /*  see if sufficient memory exists. If not, allocate memory */

  PlateListSize = om$dimension_of ( varray = me->VSplateList );

  if ( me->PlateCount + count > PlateListSize )
  {
      status = om$vla_set_dimension (
			varray =  me->VSplateList,
			size   =  me->PlateCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->FEplateList,
			size   =  me->PlateCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->BeamsOnPl,
			size   =  me->PlateCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->PlMatCreateFlag,
			size   =  me->PlateCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	printf("Can not allocate memory\n");
	*sts = OM_E_ABORT;
	goto quit;
      }

      status = om$vla_set_dimension (
			varray =  me->PlPrpCreateFlag,
			size   =  me->PlateCount + count + 10 );
      if ( ! ( status & 1 ) )
      {
	 printf("Can not allocate memory\n");
	 *sts = OM_E_ABORT;
	 goto quit;
      }

      for ( ii= PlateListSize; ii< me->PlateCount + count + 10; ii++)
      {
	me->BeamsOnPl[ii]	= 0;
	me->PlPrpCreateFlag[ii] = FALSE;
	me->PlMatCreateFlag[ii] = FALSE;
      }
  }


  /* process ObjList */
  for ( ii=0;  ii<count; ii++ )
  {
     /* check if located object has already been located before */
     found = 0;
     for ( jj=0; jj < me->PlateCount; jj++ )
     {  if ( ObjList[ii].obj_id.objid == me->VSplateList[jj].obj_id.objid  &&
	     ObjList[ii].obj_id.osnum == me->VSplateList[jj].obj_id.osnum )
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
			msgnumb		= SF_E_PlNtInRef,
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
	   VSplateList */
	me->VSplateList[me->PlateCount] = ObjList[ii];
	me->PlateCount++;

	/* display located plate in half highlight mode */
	itmp = me->PlateCount - 1;
	dpmode = GRhhd;
	status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->VSplateList[itmp].mod_env.md_env.matrix_type,
			me->VSplateList[itmp].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->VSplateList[itmp].obj_id.objid,
		     targetos = me->VSplateList[itmp].obj_id.osnum );

	/* get no. of stiffeners attached to the plate */
	status = om$send ( msg = message VSfeature.VSgetSupportedElements (
			&msg,
			TRUE,
			&NbStfnr,
			NULL ),
		     targetid = me->VSplateList[itmp].obj_id.objid,
		     targetos = me->VSplateList[itmp].obj_id.osnum );

#ifdef SF_PLATE_DBG
     printf("\tNo. of stiffeners = [%d]\n", NbStfnr);
#endif

	BeamListSize = om$dimension_of ( varray = me->VSbeamList );

	if ( me->BeamCount + NbStfnr > BeamListSize )
	{
		status = om$vla_set_dimension (
			varray =  me->VSbeamList,
			size   =  me->BeamCount + NbStfnr + 10 );
		if ( ! ( status & 1 ) )
		{
		  printf("Can not allocate memory\n");
		  *sts = OM_E_ABORT;
		  goto quit;
		}

		status = om$vla_set_dimension (
			varray =  me->FEbeamAxisList,
			size   =  me->BeamCount + NbStfnr + 10 );
		if ( ! ( status & 1 ) )
		{
		  printf("Can not allocate memory\n");
		  *sts = OM_E_ABORT;
		  goto quit;
		}

		status = om$vla_set_dimension (
			varray =  me->BmMatCreateFlag,
			size   =  me->BeamCount + NbStfnr + 10 );
		if ( ! ( status & 1 ) )
		{
		  printf("Can not allocate memory\n");
		  *sts = OM_E_ABORT;
		  goto quit;
		}

		status = om$vla_set_dimension (
			varray =  me->BmPrpCreateFlag,
			size   =  me->BeamCount + NbStfnr + 10 );
		if ( ! ( status & 1 ) )
		{
		  printf("Can not allocate memory\n");
		  *sts = OM_E_ABORT;
		  goto quit;
		}

		for ( jj= BeamListSize; jj< me->BeamCount + NbStfnr + 10; jj++)
		{
		  me->BmPrpCreateFlag[jj] = FALSE;
		  me->BmMatCreateFlag[jj] = FALSE;
		}
	}

	/* get stiffeners attached to the plate */
	status = om$send ( msg = message VSfeature.VSgetSupportedElements (
			&msg,
			TRUE,
			&NbStfnr,
			&StfnrList ),
		     targetid = me->VSplateList[itmp].obj_id.objid,
		     targetos = me->VSplateList[itmp].obj_id.osnum );

	for ( jj=0; jj<NbStfnr; jj++ )
	{
	    me->VSbeamList[me->BeamCount+jj].obj_id = StfnrList[jj];
	    me->VSbeamList[me->BeamCount+jj].mod_env =
					me->VSplateList[itmp].mod_env;
	}
	me->BeamCount += NbStfnr;
	me->BeamsOnPl[me->PlateCount-1] = NbStfnr;

	if ( StfnrList )  { free ( StfnrList );  StfnrList = NULL; }

     }
     else   /* already in VSplateList.  display it in half highlight mode */
     {
	dpmode = GRhhd;
	status = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&me->VSplateList[jj].mod_env.md_env.matrix_type,
				me->VSplateList[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			   targetid = me->VSplateList[jj].obj_id.objid,
			   targetos = me->VSplateList[jj].obj_id.osnum );
     }
  }
  ASend_fence();

  if ( me->PlateCount > 0 )
	ex$message (	field   = ERROR_FIELD,
			msgnumb = SF_I_PlStfnrSel,
			justification = CENTER_JUS,
			type	= "%d%d",
			var	= `me->PlateCount, me->BeamCount` );

  *sts = MSSUCC;

}

/* ==========================================================================
   action : GetPlatesData

   This action gets the centroidal axes of VSbeams and displays them.
   This also gets material type and grade for each VSbeam and  gets
   corresponding FEM material name ( If FEM material does not exist, it
   creates a material ).
   This also gets section properties of VSbeams and gets corresponding
   FEM property name ( if FEM property does not exist, it creates a property).
   Finally it displays VSbeam name, FEM material name and FEM property name
   on the form.

=========================================================================== */

action  GetPlatesData
{
  int			ii, msg1, BeamNb, jj;
  enum	 GRdpmode	dpmode;
  long			msg;
  int			index = -1; /* unused ASSOC flag */
  struct ret_struct	rs;
  char			MatType[80],
			MatGrade[80],
			MatName[FE_MAX_MPNAME_SIZE],
			PrpName[FE_MAX_MPNAME_SIZE];
  char			MatCreateFlag,
			PrpCreateFlag;
  char			PlateSurfOpt[ATTR_TXT],
			BmExtractOpt[ATTR_TXT];
  double		offset_def,
			offset_db;
  int			NbFemElem;
/*
  int count;  long nb_proj;
  struct GRsymbology    ActSymb;
  VSsuppList		supports;
  struct GRlc_info	curve_info,
			side_info;
  struct GRvg_construct cst;
  OM_S_OBJID		*proj_obj = NULL;
  struct GRid		TmpObj;
  struct GRid		offSfId;
*/


  if ( me->PlateCount == 0 )
  {	_put_response ( resp = TERMINATE );
	goto quit;
  }

#ifdef SF_PLATE_DBG
  printf("Entered SFCoStfndPl.GetPlatesData\n");
  for( ii=0; ii<me->PlateCount; ii++)
      printf("\tVSplateList[%d] : [%d,%d]\n", ii,
		me->VSplateList[ii].obj_id.objid,
		me->VSplateList[ii].obj_id.osnum );
#endif

  /* unhighlight half highlight display  */
  dp$erase_hilite ( msg = &msg );
/*
  ActSymb.display_attr   = me->ActiveDisplay;
  ActSymb.level          = me->ActiveLevel;


  cst.msg	 = &msg;
  cst.env_info	 = &me->MyEnv;
  cst.level	 = me->ActiveLevel;
  cst.display	 = &me->ActiveDisplay;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.class_attr = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.name       = NULL;
*/
  /* get the top surfaces of the plates and display them in highlight mode */
/*
  dpmode = GRhd;
*/

  /*
   * get the required surfaces of the plates and display them
   * in highlight mode.
   */

  FIg_get_text ( FP_STFND_PL, SF_PLACE_AT_FLD, PlateSurfOpt );
  if ( !strcmp( PlateSurfOpt, SF_TXT_TOP_SURF ) )
	status = om$send ( msg = message SFCoStfndPl.PlacePlateAtTop(),
				    targetid = my_id );

  if ( !strcmp( PlateSurfOpt, SF_TXT_MID_SURF ) )
	status = om$send ( msg = message SFCoStfndPl.PlacePlateAtMid(),
				    targetid = my_id );

  if ( !strcmp( PlateSurfOpt, SF_TXT_BOT_SURF) )
	status = om$send ( msg = message SFCoStfndPl.PlacePlateAtBot(),
				    targetid = my_id );

  if ( !strcmp( PlateSurfOpt, SF_TXT_KEYIN ) )
  {
    FIg_get_value ( FP_STFND_PL, SF_OFFSET_FLD, &offset_def );
    offset_db = APu_default_to_dbase ( GRIO_DISTANCE, offset_def );

    __DBGpr_dbl("offset_db", offset_db );

    status = om$send ( msg = message SFCoStfndPl.PlacePlateAtKeyin( offset_db ),
				    targetid = my_id );
  }

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

  FIg_get_text ( FP_STFND_PL, SF_BM_EXTRACT_FLD, BmExtractOpt );
  if ( !strcmp ( BmExtractOpt, SF_TXT_TRACE_CURVES ) )
	NbFemElem = SF_DEFAULT_MESH_SIZE;

  BeamNb = -1;
  for( ii=0; ii < me->PlateCount; ii++ )
  {
      /* get the material type */
      status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMatTypAttr, &rs,
					&me->VSplateList[ii].mod_env ),
			targetid = me->VSplateList[ii].obj_id.objid,
			targetos = me->VSplateList[ii].obj_id.osnum );
      if(!(status & msg1 & 1))
      {
	printf("GetPlatesData : NDmacro.ACgive_Structure(mat type) failure\n");
	continue;
      }

      strcpy( MatType, rs.var.text_st.text_string );

#ifdef SF_PLATE_DBG
      printf ( "\tMat type : [%s]\n", MatType );
#endif

      /* get the material grade */
      status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMatGrdAttr, &rs,
					&me->VSplateList[ii].mod_env ),
			targetid = me->VSplateList[ii].obj_id.objid,
			targetos = me->VSplateList[ii].obj_id.osnum );
      if(!(status & msg1 & 1))
      {
	printf("GetPlatesData : NDmacro.ACgive_Structure(mat grade) failure\n");
	continue;
      }

      strcpy( MatGrade, rs.var.text_st.text_string );

#ifdef SF_PLATE_DBG
      printf ( "\tMat Grade : [%s]\n", rs.var.text_st.text_string );
#endif

      /*  check if a material already exists with the properties. If not
       *  generate a name and create a material with the name and properties.
       */

      status = SFgetMatName( &msg, MatType, MatGrade, MatName, &MatCreateFlag);
      if ( !(status & msg & 1 ) )
      {
	*sts = MSFAIL;
	goto quit;
/*	printf(
	 "GetPlatesData : Can not get material name for MatType[%s] and MatGrade[%s]\n",
				MatName, MatGrade );
	continue;
*/    }

      if ( MatCreateFlag )  me->PlMatCreateFlag[ii] = TRUE;


      /*  check if a property already exists with the thickness. If not
       *  generate a name and create a property with the name and thickness.
       */

      status = SFgenPlateProperty ( &msg, me->VSplateList[ii].obj_id,
				    &me->VSplateList[ii].mod_env,
				    PrpName, &PrpCreateFlag );
      if ( !( status & msg & 1 ) )
      {
	printf("GetPlatesData : SFgetPlateProperty failure\n");
	continue;
      }

      if ( PrpCreateFlag ) me->PlPrpCreateFlag[ii] = TRUE;

      /*  get the name of the plate  */
      status = om$send( msg       = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMbrNamAttr, &rs,
					&me->VSplateList[ii].mod_env ),
			targetid  = me->VSplateList[ii].obj_id.objid,
			targetos  = me->VSplateList[ii].obj_id.osnum );
      if(!(status & msg1 & 1))
      {
	printf("GetPlatesData : NDmacro.ACgive_Structure( name ) failure\n");
	continue;
      }

#ifdef SF_PLATE_DBG
      printf ( "\tPlate Name : [%s]\n", rs.var.text_st.text_string );
#endif

      /*  display name, material and element property names */
      FIfld_set_text ( FP_STFND_PL, SF_PLATE_LIST_FLD,
			ii, 0, rs.var.text_st.text_string, 0 );
      FIfld_set_text ( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 1, MatName, 0 );
      FIfld_set_text ( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 2, PrpName, 0 );

#ifdef SF_BEAM_DBG
  printf("Entered SFCoConvBm.GetBeamsData\n");
  for( jj=0; jj<me->BeamCount; jj++)
      printf("\tVSbeamList[%d] : [%d,%d]\n", jj,
		me->VSbeamList[jj].obj_id.objid,
		me->VSbeamList[jj].obj_id.osnum );
#endif


      dpmode = GRhd;
      for( jj=0; jj < me->BeamsOnPl[ii]; jj++ )
      {
	BeamNb++;

	status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[BeamNb].objid,
		     targetos = me->FEbeamAxisList[BeamNb].osnum );

	/* get the materail type */
	status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMatTypAttr, &rs,
					&me->VSbeamList[BeamNb].mod_env ),
			targetid = me->VSbeamList[BeamNb].obj_id.objid,
			targetos = me->VSbeamList[BeamNb].obj_id.osnum );
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
					&me->VSbeamList[BeamNb].mod_env ),
			targetid = me->VSbeamList[BeamNb].obj_id.objid,
			targetos = me->VSbeamList[BeamNb].obj_id.osnum );
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

	status=SFgetMatName( &msg, MatType, MatGrade, MatName, &MatCreateFlag);
	if ( !(status & msg & 1 ) )
	{
	  *sts = MSFAIL;
	  goto quit;
/*	 printf("Can not get material name for MatType[%s] and MatGrade[%s]\n",
				MatType, MatGrade );
	 continue;
*/	}

	if ( MatCreateFlag )  me->BmMatCreateFlag[BeamNb] = TRUE;

	/*  check if a property already exists for the beam . If not
	*  generate a name and create a property for the beam.
	*/

	status = SFgenBeamProperty ( &msg, me->VSbeamList[BeamNb].obj_id,
				     PrpName, &PrpCreateFlag );
	if ( !(status & msg & 1 ) )
	{
	  *sts = MSFAIL;
	  goto quit;
	}
	if ( PrpCreateFlag ) me->BmPrpCreateFlag[BeamNb] = TRUE;

	/*  get the name of the beam  */
	status = om$send( msg       = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_prMbrNamAttr, &rs,
					&me->VSbeamList[BeamNb].mod_env ),
			targetid  = me->VSbeamList[BeamNb].obj_id.objid,
			targetos  = me->VSbeamList[BeamNb].obj_id.osnum );
	if ( ! status & msg1 & 1 )
	{
	  printf("GetBeamsData : NDmacro.ACgive_structure(name) failure\n");
	  continue;
	}

#ifdef SF_BEAM_DBG
	printf ( "\tBeam Name : [%s]\n", rs.var.text_st.text_string );
#endif

	/*  display name, material and element property names */
	FIfld_set_text ( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 0,
			rs.var.text_st.text_string, 0 );
	FIfld_set_text ( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 1, MatName, 0 );
	FIfld_set_text ( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 2, PrpName, 0 );
	FIfld_set_value ( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 3,
			(double) NbFemElem, 0 );
      }
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
	  PlateListSize,
	  BeamListSize;

   status = OM_S_SUCCESS;

   me->PlateCount = 0;
   me->BeamCount = 0;
   PlateListSize = om$dimension_of ( varray = me->VSplateList );
   for ( ii=0; ii< PlateListSize; ii++)
   {
	me->FEplateList[ii].objid = NULL_OBJID;
	me->FEplateList[ii].osnum = EX_active_OS_num;
	me->BeamsOnPl[ii]	  = 0;
	me->PlMatCreateFlag[ii]	  = FALSE;
	me->PlPrpCreateFlag[ii]   = FALSE;
   }

   BeamListSize = om$dimension_of ( varray = me->VSbeamList );
   for ( ii=0; ii< BeamListSize; ii++)
   {
	me->FEbeamAxisList[ii].objid = NULL_OBJID;
	me->FEbeamAxisList[ii].osnum = EX_active_OS_num;
	me->BmMatCreateFlag[ii]      = FALSE;
	me->BmPrpCreateFlag[ii]	     = FALSE;
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
 char			feplates_created;
 long			msg;
 enum   GRdpmode	dpmode;

   if ( me->PlateCount == 0 )  return OM_S_SUCCESS;

   feplates_created = FALSE;
   for ( ii=0; ii<me->PlateCount; ii++ )
      if ( me->FEplateList[ii].objid != NULL_OBJID )
      {  feplates_created = TRUE;
	 break;
      }

   if ( feplates_created )
   {
      dpmode = GRhd;
      for ( ii=0; ii<me->PlateCount; ii++)
      {
	 status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEplateList[ii].objid,
		     targetos = me->FEplateList[ii].osnum );
      }

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
      for ( ii=0; ii<me->PlateCount; ii++)
      {
	status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->VSbeamList[ii].mod_env.md_env.matrix_type,
			me->VSbeamList[ii].mod_env.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->VSplateList[ii].obj_id.objid,
		     targetos = me->VSplateList[ii].obj_id.osnum );
      }
  }

  goto quit;

}

action  set_form
{
double			offset_db,
			offset_def;
char			PlateSurfOpt[ATTR_TXT],
			BmExtractOpt[ATTR_TXT];
int			ElemType,
			NbFemElem,
			ConvAllEl;
char			DefaultUnitName[GRIO_MAX_ALIAS_SIZE];

  /*
   *  get the conversion options
   */
  status = SFgetConvOpt(sts,
			PlateSurfOpt,
			&offset_db,
			BmExtractOpt,
			&ElemType,
			&NbFemElem,
			&ConvAllEl );
  VDS_ERR_HNDLR("Getting conversion options", status, *sts, VD_VERBOSE, quit);

  FIg_set_text ( FP_STFND_PL, SF_PLACE_AT_FLD, PlateSurfOpt );
  if ( !strcmp( PlateSurfOpt, SF_TXT_KEYIN ) )
  {
     SMVA_display ( FP_STFND_PL, 3, SF_OFFSET_TXT,
				 SF_OFFSET_FLD,
				 SF_OFFSET_UNIT_TXT );

     status = (long) APu_dbase_to_default_dbl ( GRIO_DISTANCE, offset_db,
						   &offset_def, NULL );
     FIg_set_value ( FP_STFND_PL, SF_OFFSET_FLD, offset_def );

     status = (long) APu_getTypeDefaultUnit ( GRIO_DISTANCE, DefaultUnitName );
     FIg_set_text ( FP_STFND_PL, SF_OFFSET_UNIT_TXT, DefaultUnitName);
  }

  if ( ConvAllEl )
	FIg_set_state ( FP_STFND_PL, SF_CHK_CONVERTED_FLD, FALSE);
  else
	FIg_set_state ( FP_STFND_PL, SF_CHK_CONVERTED_FLD, TRUE);

  FIg_set_text ( FP_STFND_PL, SF_BM_EXTRACT_FLD, BmExtractOpt );
  if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
  {
     if ( ElemType == LINE2 )
	FIg_set_state ( FP_STFND_PL, SF_ELTYPE_FLD, TRUE );
     else
	FIg_set_state ( FP_STFND_PL, SF_ELTYPE_FLD, FALSE );
  }

  if(x_pos != -1 && y_pos != -1)
    FIf_set_location ( FP_STFND_PL, x_pos, y_pos );

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


/****************************************************************************

	Filename:	SFCoSfCv.sl
	Author:		Raju M S B
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SFCoSfCv.sl
	Output:		SFCoSfCv.S   and  SFCoSfCvi.I
	makemake file	strfem.m -> makefile -> strfem.o

	Description:

	History:
	Raju 	06-14-1994	Creation date


/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	"Extend Elements To Surface", 0, SFextElSf
synonym		"Trim Elements To Surface", 1, SFtrimElSf
class		SFCoSfCv
super_class	CEO_LOCATE
product_name	"$STRFEM"
command_table	"sf.cmd"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

instance
{
 struct  GRid		surfid;
 struct  GRmd_env	surfenv;
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
#include "growner.h"

#include "coparamac.h"
#include "grdpbmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "ACrg_collect.h"

#include "vderrmacros.h"

extern  OMuword		OPP_EMSsurface_class_id,
			OPP_EMSsolid_class_id,
			OPP_GRcurve_class_id,
			OPP_GRpoint_class_id,
			OPP_GRgrset_class_id,
			OPP_GRsvset_class_id;

from  GRgraphics  import  GRdisplay;
from  GRgrset     import  GSget_object;


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

state start
on CMD_TYPE = 0  do message "Extend Elements to Surface"
					state loc_base_surface
on CMD_TYPE = 1  do message "Trim Elements to Surface"
					state loc_base_surface

state loc_base_surface
  prompt	      "Identify Base Surface"
  locate_owner        "LC_RIGID_COMP | LC_RIGID_OWNER |
                       LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  locate_eligible     "+EMSsurface"
  mask		      "GRm_DATA | GRm_OBJID | GRm_STRING"
  filter	      locate
     on EX_OBJID   state  .
     on EX_DATA or EX_STRING
		do StoreSurf
	           on ERROR    state .
		state print_prompt

state print_prompt
on CMD_TYPE = 0  do  prompt	"Identify Surface(s)/Curve(s) to be Extended"
					state get_elements
on CMD_TYPE = 1  do  prompt	"Identify Surface(s)/Curve(s) to be Trimmed"
					state get_elements

state get_elements
  status		""
  locate_owner		"LC_RIGID_OWNER | LC_FLEX_OWNER"
  locate_eligible	"+EMSsurface, GRcurve"
  mask			"GRm_DATA | GRm_OBJID | GRm_STRING | GRm_BACK_UP"
  filter		locate
     on EX_DATA or EX_STRING or EX_OBJID
		do ProcessElem   state terminate
     on EX_BACK_UP	state -

/****************************************************************************/
/*  action :  StoreSurf
/****************************************************************************/

action StoreSurf
{
struct GRid		obj_id;
OMuword			elem_classid;

   status = OM_S_SUCCESS;

   obj_id =  me->event1.located_object[0].located_obj;

   /* get classid of the object */
   om$get_classid (	objid = obj_id.objid,
			osnum = obj_id.osnum,
			p_classid = &elem_classid );

   if ( om$is_ancestry_valid (	subclassid = elem_classid,
				superclassid = OPP_EMSsolid_class_id )
	     == OM_S_SUCCESS )
   {
      ex$message (  in_buff = "Located object is not a surface",
		    field   = ERROR_FIELD,
		    justification = CENTER_JUS );
      *sts = MSFAIL;
      goto quit;
   }

   me->surfid 	= me->event1.located_object[0].located_obj;
   me->surfenv  = me->event1.located_object[0].module_info;

   *sts = MSSUCC;


}

/****************************************************************************/
/*  action :  ProcessElem
/****************************************************************************/

action  ProcessElem
{
struct  GRid		tmpobj;
int			ii, NbObj;
struct  GRobj_env	*ObjList = NULL;
long			msg;
OMuword			elem_classid;
enum	GRdpmode	dpmode;
int			response;
char			response_data[1024];


#ifdef  VDS_DBG
  printf("Entered SFCoExtSfCv.ProcessElem\n");
  printf("\tLocated obj : [%d,%d]\n",
		me->event1.located_object[0].located_obj.objid,
		me->event1.located_object[0].located_obj.osnum );
#endif

  tmpobj.objid = me->event1.located_object[0].located_obj.objid;
  tmpobj.osnum = me->event1.located_object[0].located_obj.osnum;

#if 0
   /* get classid of the object */
   om$get_classid (	objid = tmpobj.objid,
			osnum = tmpobj.osnum,
			p_classid = &elem_classid );

   if ( om$is_ancestry_valid (	subclassid = elem_classid,
				superclassid = OPP_GRgrset_class_id )
	     == OM_S_SUCCESS )
   {
	struct GRid   svset;
	int	      size, count;
	OM_S_CHANSELECT to_svsets;


	status = om$make_chanselect( channame = "GRgrset.to_sets",
					p_chanselect = &to_svsets );

	status = om$get_objid_at_index (  osnum = tmpobj.osnum,
					  objid = tmpobj.objid,
					  p_chanselect = &to_svsets,
					  index = 0,
					  objidaddr = &svset.objid,
					  osnumaddr = &svset.osnum  );

	/* get classid of the object */
	om$get_classid ( objid = svset.objid,
			 osnum = svset.osnum,
			 p_classid = &elem_classid );

	if ( om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_GRsvset_class_id )
	     == OM_S_SUCCESS )
	{
	   status = om$make_chanselect( channame = "GRcmpowner.to_components",
					p_chanselect = &to_components );

	   status = om$get_channel_count( osnum		= svset.osnum,
					objid   	= svset.objid,
					p_chanselect	= &to_components,
					count           = (OMuint *) &count ) ;

	   ObjList = (struct GRobj_env *) malloc ( sizeof( struct GRobj_env )
						   * count );

	   size = sizeof ( struct GRobj_env) * count ;
	   NbObj = 0;
           status = om$send ( msg = message GRgrset.GSget_object(
							&msg,
        						ObjList,
							size,
							&NbObj,
							0,
							OM_K_MAXINT ),
			      targetid = svset.objid,
			      targetos = svset.osnum );
	   VDS_ERR_HNDLR ( "GRgrset.GSget_object", status, msg, VD_VERBOSE,
			   wrapup );
        }
	else
	{
	   goto wrapup;
	}
  }
  else
  {
	ObjList = (struct GRobj_env *) malloc ( sizeof( struct GRobj_env ) );
	ObjList[0].obj_id  = me->event1.located_object[0].located_obj;
	ObjList[0].mod_env = me->event1.located_object[0].module_info;
	NbObj = 1;
  }
#endif

  as$start_fence( set           = &tmpobj,
		  set_env       = &me->event1.located_object[0].module_info,
		  nb_obj        = &NbObj,
		  p_obj_env     = &ObjList,
		  response      = &response,
		  response_data = response_data );

#ifdef  VDS_DBG
  printf( "\tno. of objects : [%d]\n", NbObj );
  for ( ii=0;  ii<NbObj; ii++ )
	printf( "\tobject id : [%d,%d]\n", ObjList[ii].obj_id.objid,
					   ObjList[ii].obj_id.osnum );
#endif

  if ( NbObj == 1 )
  {
	dpmode = GRbdhe;
	status = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(ObjList[0].mod_env.md_env.matrix_type),
				ObjList[0].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			targetid = ObjList[0].obj_id.objid,
			targetos = ObjList[0].obj_id.osnum  );
  }

  ex$message (  field = ERROR_FIELD,
		justification = CENTER_JUS,
		in_buff = "Processing .."   );

  /* process ObjList */
  for ( ii=0;  ii<NbObj; ii++ )
  {
     if ( ObjList[ii].obj_id.objid == me->surfid.objid  &&
	  ObjList[ii].obj_id.osnum == me->surfid.osnum     )
	continue;

     /* get classid of the object */
     om$get_classid (	objid = ObjList[ii].obj_id.objid,
			osnum = ObjList[ii].obj_id.osnum,
			p_classid = &elem_classid );

     if ( me->mytype == 0 )
     {
	if ( om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_EMSsurface_class_id )
		== OM_S_SUCCESS &&
	     om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_EMSsolid_class_id )
		!= OM_S_SUCCESS )
	{
	   status = SFextendSfToSf (	&msg,
					&ObjList[ii].obj_id,
					&ObjList[ii].mod_env,
					&me->surfid,
					&me->surfenv );
	   VDS_ERR_CONTINUE ( "SFextendSfToSf", status, msg, VD_VERBOSE );
	}
	else if ( om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_GRcurve_class_id )
		    == OM_S_SUCCESS &&
		  om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_GRpoint_class_id )
		    != OM_S_SUCCESS )
	{
	   status = SFextOrTrimCvToSf(	&msg,
					TRUE,
					&ObjList[ii].obj_id,
					&ObjList[ii].mod_env,
					&me->surfid,
					&me->surfenv );
	   VDS_ERR_CONTINUE ( "SFextOrTrimCvToSf", status, msg, VD_VERBOSE );
	}
     }
     else
     {
	if ( om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_EMSsurface_class_id )
		== OM_S_SUCCESS &&
	     om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_EMSsolid_class_id )
		!= OM_S_SUCCESS )
	{
	   status = SFtrimSfToSf (	&msg,
					&ObjList[ii].obj_id,
					&ObjList[ii].mod_env,
					&me->surfid,
					&me->surfenv );
	   VDS_ERR_CONTINUE ( "SFtrimSfToSf", status, msg, VD_VERBOSE );
	}
	else if ( om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_GRcurve_class_id )
		    == OM_S_SUCCESS &&
		  om$is_ancestry_valid ( subclassid = elem_classid,
				    superclassid = OPP_GRpoint_class_id )
		    != OM_S_SUCCESS )
	{
	   status = SFextOrTrimCvToSf(	&msg,
					FALSE,
					&ObjList[ii].obj_id,
					&ObjList[ii].mod_env,
					&me->surfid,
					&me->surfenv );
	   VDS_ERR_CONTINUE ( "SFextOrTrimCvToSf", status, msg, VD_VERBOSE );
	}
     }
  } /* for ( ii=0;  ii<NbObj; ii++ ) */

/*
wrapup:
*/
  ASend_fence();
  if ( ObjList ) free ( ObjList );
  *sts = MSSUCC;

  goto quit;

}

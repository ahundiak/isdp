/* $Id: VRlibfunk.I,v 1.5 2002/04/10 20:44:55 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRlibfunk.I
 *
 * Description:
 *	utility function used to generate HVAC sketch.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRlibfunk.I,v $
 *	Revision 1.5  2002/04/10 20:44:55  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.4  2001/03/08 23:43:02  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:18:14  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:31  anand
 *	SP merge
 *	
# Revision 1.11  2000/11/15  20:34:16  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.10  2000/11/09  21:35:06  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.9  2000/10/16  14:51:22  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by aharihar for Service Pack
#
# Revision 1.8  2000/09/06  23:18:50  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.7  2000/07/28  22:52:26  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.6  2000/07/21  13:43:40  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.5  2000/07/20  16:38:52  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.4  2000/07/13  22:48:30  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.3  2000/06/02  16:30:44  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.2  2000/05/12  22:25:30  pinnacle
# Replaced: route/vrtools/VRlibfunk.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/11  21:51:50  pinnacle
# Created: route/vrtools/VRlibfunk.I by apazhani for Service Pack
#
# Revision 1.5  2000/02/15  18:10:58  pinnacle
# Added a function to add UserAttribute
#
# Revision 1.4  2000/02/04  18:24:56  pinnacle
# (No comment)
#
# Revision 1.3  1999/10/06  09:42:50  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by svngidug for route
#
# Revision 1.2  1998/06/26  22:56:58  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/03/27  23:14:14  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by lawaddel for route
#
# Revision 1.2  1997/11/24  14:59:42  pinnacle
# Replaced: vrtools/VRlibfunk.I for: TR 179700360 by aharihar for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/05/03  16:39:32  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by ashankar for route240
#
# Revision 1.5  1996/04/01  18:05:34  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by msmanem for route240
#
# Revision 1.4  1996/01/18  23:29:42  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/18  23:07:48  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by r240_int for route240
#
# Revision 1.2  1996/01/18  00:33:06  pinnacle
# Replaced: vrtools/VRlibfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	6-12-1989  momo		Design date
 *	10-24-94   Lori		CR#179422038 Modify VRGetAttrFromDB
 *				   to incorporate product information.
 *				   Used to get spec info for HVAC.
 *	01/15/96   tlb		Add VX_FIproto.h, prototypes
 *	01/18/96   tlb		Change to ANSII style:
 *					VRSkUpdateParams , VRchg_attributes, 
 *					VRBuildCompPlanes
 *	01/17/96	tlb	Use VDfld_set_list_text
 *	04/01/96	msm	Added function VR_strip_space. This function is
 *				a copy of VRstrip_space from VDS. Kept both
 *				the functions for the time being. Later the
 *				function should be removed from VDS entirely.
 *	11/24/97	Anand	Increased precision for npd list being set in
 *				VRGetAttrFromDB (TR 179700360)
 *      03/27/98        law     The return buffer of VRget_code_list_set is
 *                              fixed length ascii strings.
 *      06/24/98        law     TR179801141-Add vendor to RWAY forms
 *	10/06/99	Satish	CR179900853 - Added code to the function
 *				VRGetAttrFromDB, for populating the 
 *				system class list box using database query.
 *	02/04/2000	Alwin	CR179900696 - Added code to the function 
 *				VRGetAttrFromDB for populating the Insulation 
 *				class Info 
 *	02/15/2000	Alwin	CR179900943 - Added function VRAddUserAttr, the
 *				function has to be callad using the macro. 
 *				Be safe.
 *	05/10/2000	Alwin	CR179901312 - Modified VRGetAttrFromDB to 
 *				populate the Acoustical Insulation information.
 *				And to differentiate between Thermal Insulation
 *				and Acoustical Insulation.
 *	05/12/2000	Alwin	CR179900995 - Added function VRCopyDuctParams
 *	06/02/2000	Alwin	No-TR - Corrected the Memory leak in the 
 *				funciton VRGetAttrFromDB.
 *	07/13/2000	Alwin	CR179901661 - Modified the 
 *				VRUpdate_ACST_User_Param function
 *	07/20/2000	Alwin	CR179901615 - Added fn VRPGetInsulThkFromType.
 *	07/28/2000	Alwin	CR179901774 - List the Tray Material. 
 *	09/06/2000	Alwin	CR179901852 - Added two functions.
 *				VRCopyPipeParams - to locate Component/Nozzle
 *				VRFillUpNozzleAttrForm - to fill up the nozzle
 *				pipe line attributes form.
 *	10/11/2000	Anand	ETL 3825 - Added function VRkeyFltrInCDLdbFlds.
 *      03/08/01    law         dbg prints
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation Root;


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ex.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "godef.h"
#include "grdpbdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "msdef.h"
#include "VRattr_def.h"
#include "VRparamdef.h"
#include "VRpriv_attr.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRco.h"
#include "VRcompdef.h"
#include "vrccompdef.h"
#include "VRcordef.h"
#include "nddef.h"
#include "VRformdef.h"

#include "ndmacros.h"
#include "asmacros.h"
#include "VRmacros.h"
#include "VRprivmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"

#include "VRMath.h"
#include "MS.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "parametric.h"
#include "VRcsdef.h"
#include "VRsketchdef.h"
#include "VRact_params.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRdbcodlst.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "VRplanedef.h"
#include "HV_param.h"
#include "AS_status.h"
#include "vrpdu_pto.h"
#include "vrtools_pto.h"
#include "bslenvec.h"
#include "VRchgattrdef.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "VRRwDimen.h"

#include "VDfrm.h" // contains prototype for VDfrm_fld_set_sub_list

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG
#define MAX_FIELD	25 /* define in HV_param.h too */
#define VR_MAX_LEN	MAX_FIELD

from	NDnode		import	NDcopy,
				NDplace,
				NDdisplay,
				NDget_objects;
from	ACncpx		import	ACgive_structure;
from	VRGeneric	import	VRChgParams,
				VRGetParams,
				VRGetStatus,
				VRGetCptGeom,
				VRGetOrigCoor,
				VRGetCompDesc;
from   	VRCnrlSeg	import	VRget_terminators;
from	ACrg_collect	import	AClist_attribute,
				ACadd_attribute,
				ACmod_attribute,
				ACshow_data,
				ACmod_list_attribute;

extern IGRshort		VRlocate_pattern ();

extern 	GRclassid	OPP_VRDepPlane_class_id;

/*************************************************************************/

/*                I/0  I    I    I    O   O                              */
IGRlong make_ref( msg, vx0, vy0, vz0, vy, vz )

IGRlong	  *msg;
IGRdouble *vx0;
IGRdouble *vy0;
IGRdouble *vz0;
IGRdouble *vy;
IGRdouble *vz;

/*.make_ref */
{
  BSrc		bsretcode;
  IGRdouble	length;

  *msg = MSSUCC;

  /*| Normalize X vector */
  length = BSlenvec( &bsretcode, vx0 );

  /*" X length = %f\n", length */

  if( length < VRGetTol(VR_LENGTH_TOL) )
  {
    *msg = MSFAIL;
    return OM_S_SUCCESS;
  }

  BSnorvec( &bsretcode, vx0 );
  /*"vx0 = %f %f %f\n", vx0[0], vx0[1], vx0[2] */

  /* calculate Y axis */
  BScrossp( &bsretcode, vz0, vx0, vy );

  /*| Normalize Y vector */
  length = BSlenvec( &bsretcode, vy );

  /*" Y length = %f\n", length */

  if( length < VRGetTol(VR_LENGTH_TOL) )
  {
    /*| X axis parallel to the Z0 axis ==> we try to calculate Z axis */
    /*| ( orthogonal to X and Z0 ) */

    BScrossp( &bsretcode, vx0, vy0, vz );

    /*| Normalize Z vector */
    length = BSlenvec( &bsretcode, vz );

    /*" Z length = %f\n", length */

    if( length < VRGetTol(VR_LENGTH_TOL) )
    {
      *msg = MSFAIL;
      return OM_S_SUCCESS;
    }

    BSnorvec( &bsretcode, vz );

    /*| calculate Y axis */

    BScrossp( &bsretcode, vz, vx0, vy );

    /*| Normalize Y vector */
    length = BSlenvec( &bsretcode, vy );

    /*" Y length = %f\n", length */

    if( length < VRGetTol(VR_LENGTH_TOL) )
    {
      *msg = MSFAIL;
      return OM_S_SUCCESS;
    }

    BSnorvec( &bsretcode, vy );
  }
  else
  {
    /* norm vy */
    BSnorvec( &bsretcode, vy );

    /*| calculate Z axis */
    BScrossp( &bsretcode, vx0, vy, vz );
 
    /*| Normalize Z vector */

    length = BSlenvec( &bsretcode, vz );

    /*" Z length = %f\n", length */

    if( length < VRGetTol(VR_LENGTH_TOL) )
    {
      *msg = MSFAIL;
      return OM_S_SUCCESS;
    }

    BSnorvec( &bsretcode, vz );
  }

  /*"vx = %f %f %f\n", vx0[0], vx0[1], vx0[2] */
  /*"vy = %f %f %f\n", vy[0] , vy[1] , vy[2]  */
  /*"vz = %f %f %f\n", vz[0] , vz[1] , vz[2]  */

  return(OM_S_SUCCESS);

}

/******************************************************************************

		   return active display and level 

******************************************************************************/

VRget_active_symb( level, display )

IGRshort 		*level;
struct 	IGRdisplay 	*display;
{
  IGRlong NumberOfBytes;
  IGRlong BytesReceived;
  IGRlong msg;
 
  /* get the default symbology data from the DPB */

  NumberOfBytes = sizeof( *level );

  gr$get_active_level( msg    = &msg,
                       sizbuf = &NumberOfBytes,
                       buffer = level,
                       nret   = &BytesReceived);
  as$status( sts = msg, action = RET_STATUS );

  /* get the default display symbology data from the DPB */

  NumberOfBytes = sizeof( *display );

  gr$get_active_display( msg    = &msg,
                         sizbuf = &NumberOfBytes,
                         buffer = display,
                         nret   = &BytesReceived);
  as$status( sts = msg, action = RET_STATUS );

  return( OM_S_SUCCESS );

}

/******************************************************************************/

VRGetConstructionList( p_retmsg, md_env, properties, Symbology, act_display, class_attr, cst )

IGRlong			*p_retmsg;
struct	GRmd_env	*md_env;
short 	unsigned	*properties;
struct	GRsymbology	*Symbology;
struct	IGRdisplay	*act_display;
IGRchar			*class_attr;
struct 	GRvg_construct	*cst;		/* Output */
{
  struct	IGRdisplay	*ActDisplay;   /* pointer to active display   */
  short unsigned		prop;	       /* default proporties          */
  IGRshort			ActiveLevel;   /* active level                */

  *p_retmsg = MSSUCC;

  if( !md_env ) return OM_E_INVARG;

  if( Symbology )
  {
  	ActDisplay  = &Symbology->display_attr;
    	ActiveLevel = Symbology->level;
  }
  else 	if( act_display )
  	{
		ActDisplay = act_display;
		VRget_active_symb( &ActiveLevel, ActDisplay );
  	}
  	else return OM_E_INVARG;

  if( properties ) prop = *properties;
  else             prop = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;

  cst->msg            = p_retmsg;
  cst->env_info       = md_env;
  cst->newflag        = FALSE;
  cst->properties     = prop;
  cst->name           = 0;
  cst->display        = ActDisplay;
  cst->level          = ActiveLevel;
  cst->geometry       = NULL;
  cst->class_attr     = class_attr;

  return OM_S_SUCCESS;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VRprint_user_attr function
 
 CHANGE HISTORY:  momo 25-10-1989 : Design date
                  momo 08-02-1991 : Rewrite Design date

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRprint_user_attr( user_attr_id )

struct GRid *user_attr_id;

/*.VRprint_user_attr */
{
#ifdef vdsDEBUG
  IGRlong status=OM_S_SUCCESS, retcode=MSFAIL;

  printf("user_attr_id = %d %d\n", user_attr_id->objid, user_attr_id->osnum );

  status = om$send( msg      = message ACrg_collect.ACshow_data( &retcode ),
                    senderid = NULL_OBJID,
                    targetid = user_attr_id->objid,
                    targetos = user_attr_id->osnum );
  as$status( action = RET_STATUS );
#endif
  return OM_S_SUCCESS;
}

/****************************************************************************/
VRGetAttrFromDB ( form_ptr, Product )
IGRchar		*form_ptr;
IGRint		Product;
{
  IGRlong		status;
  IGRlong		retmsg;
  IGRshort		listsize, *code_num;
  IGRchar 		*speclist, *codelist;
  IGRdouble		*npdlist;
  IGRchar 		Cnpdlist[VR_MAX_NPDLIST_SIZE][9];
  IGRint		i,j;

  SetProc( Fn VRGetAttrFromDb ); Begin

  status  = OM_S_SUCCESS;
 
 if ( Product == VR_PIPING )
 {
  /*| -- Get Spec Name List and initialize form -- */
  status = VRget_spec_list ( &retmsg, Product, &listsize , &speclist, NULL); 
  if ( status & 1 )
  {
        qsort( (void *)speclist, listsize,
				  VR_MAX_SPEC_NAME_LEN*sizeof(IGRchar),strcmp);
	FIfld_set_list_num_rows( form_ptr, PIPING_MAT_CLASS, 0, listsize );
	for(i = 0,j = 0;j < listsize;j++)
	{
	    if( speclist[i] )
	    {
		VDfld_set_list_text( form_ptr, PIPING_MAT_CLASS, j, 0, &speclist[i], FALSE);
		i = i + VR_MAX_SPEC_NAME_LEN;
	    }
	}
  }

  /*| -- Get Nominal Size List and initialize form -- */
  status = VRget_npd_list (&retmsg,  Product, "NOZZLE",  &listsize , &npdlist , NULL);
  if ( status & 1 )
  {
	for( i = 0; i<listsize; i++)	sprintf(Cnpdlist[i], "%g", npdlist[i]);
/* Essential for the format to be "%g" - precision NOT to be reduced - Anand */
  	FIfld_set_list_num_rows( form_ptr, NOM_PIPE_DIAM, 0,listsize );
  	for(i=0; i<listsize; i++)
  		VDfld_set_list_text( form_ptr, NOM_PIPE_DIAM, i, 0, Cnpdlist[i], FALSE);
  }

  /*| -- Get Insul Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, Product, VR_P_INSUL_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
/************** modified law 03/27/97 ****************************/
  if ( status & 1 )
  {
        qsort( (void *)codelist, listsize,
			       VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar), strcmp);
	FIfld_set_list_num_rows( form_ptr, INSULATION_TYPE, 0, listsize );

        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
        VDfld_set_list_text( form_ptr, INSULATION_TYPE, j, 0, &codelist[i], FALSE);
                        j++;
                }
        }
  }
/************************************************************/
  /*| -- Get Approval Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, Product, VR_P_APP_STS_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
/************** modified law 03/27/97 ****************************/
  if ( status & 1 )
  {
        qsort( (void *)codelist, listsize,
			       VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar), strcmp);
        FIfld_set_list_num_rows( form_ptr, APPROVAL_STATUS, 0, listsize );

        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
        VDfld_set_list_text( form_ptr, APPROVAL_STATUS, j, 0, &codelist[i], FALSE);
                        j++;
                }
        }
  }
/************************************************************/
  /*| -- Get Constrained Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, Product, VR_P_CONST_STS_LSTNUM,
				 &listsize , &codelist, &code_num, NULL);
/************** modified law 03/27/97 ****************************/
  if ( status & 1 )
  {
        qsort( (void *)codelist, listsize,
			       VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar), strcmp);
        FIfld_set_list_num_rows( form_ptr, CONSTRUC_STATUS, 0, listsize );

        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
        VDfld_set_list_text( form_ptr, CONSTRUC_STATUS, j, 0, &codelist[i], FALSE);
                        j++;
                }
        }
  }
/************************************************************/
  /*| -- Get Heat Tracing List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, Product, VR_P_TRACE_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
/************** modified law 03/27/97 ****************************/
  if ( status & 1 )
  {
        qsort( (void *)codelist, listsize,
			       VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar), strcmp);
        FIfld_set_list_num_rows( form_ptr, HEAT_TRACING, 0, listsize );

        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
        VDfld_set_list_text( form_ptr, HEAT_TRACING, j, 0, &codelist[i], FALSE);
                        j++;
                }
        }
  }
/************************************************************/
  /*| -- Get Fluid Code List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, Product, VR_P_FLUID_CODE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
/************** modified law 03/27/97 ****************************/
  if ( status & 1 )
  {
        qsort( (void *)codelist, listsize,
			       VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar), strcmp);
        FIfld_set_list_num_rows( form_ptr, FLUID_CODE, 0, listsize );

        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
        VDfld_set_list_text( form_ptr, FLUID_CODE, j, 0, &codelist[i], FALSE);
                        j++;
                }
        }
  }
/************************************************************/
 }
 else if (( Product == VR_HVAC )|| ( Product == VR_RWAY ) ) /* TR179801141 */

 {
    status = VRget_spec_list ( &retmsg, Product, &listsize , &speclist, NULL); 
  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( form_ptr, HVAC_MAT_CLASS, 0, listsize );
  	for(i= 0, j = 0;j<listsize;j++)
  	{
      		if (speclist[i])
       		{
         		VDfld_set_list_text( form_ptr,HVAC_MAT_CLASS, j, 0,
                                             &speclist[i], FALSE);
 			i = i + VR_MAX_SPEC_NAME_LEN;
       		}
  	}
  }

  // modified for CR179901312
  if ( Product == VR_HVAC )
  {
	IGRint		nbInsulationClass=0;
	IGRchar		**Insulation_class=NULL;
	IGRchar		insul_type[2];

	  /*
	   * for 'insul_type' --->>
	   * Send "T" to fetch the Thermal Insulation Class. 
	   * Send "A" to fetch the Acoustical Information.
	   * modified these calls while implementing CR179901312. Alwin
	   */

	/*
	 * 1. Call this function with "insul_type" set to "T" to fetch the Thermal
	 * Insulation Information. Allocate the memory to fetch the Thermal 
	 * Insulation list and then proceed further in getting the actual list and
	 * Display them in the respective field.
	 */
	strcpy( insul_type, "T" ); // Thermal Insulation is being fetched
	status = VRHGet_Material_Insulation_ClassInfo( &retmsg, insul_type, NULL,
									NULL, &nbInsulationClass, NULL );

	__DBGpr_int( "Nb. Thermal Insulation Classes ", nbInsulationClass );

	if ( status & retmsg && (nbInsulationClass != 0) )
	{
	  Insulation_class = _CALLOC( nbInsulationClass, IGRchar* );
	  if( !Insulation_class ) return OM_E_NODYNMEM;

	  for( i=0; i<nbInsulationClass; i++ )
	  {
		Insulation_class[i] = _CALLOC( 25, IGRchar );
	  	if( !Insulation_class[i] ) return OM_E_NODYNMEM;
	  }

      status = VRHGet_Material_Insulation_ClassInfo( &retmsg, insul_type, NULL,
                                  NULL, &nbInsulationClass, Insulation_class );

      FIfld_set_list_num_rows(form_ptr, INSULA_MATER, 0, nbInsulationClass);
      for( i=0; i<nbInsulationClass; i++ )
      {
         /** Set the information in the gadget INSULATION_MATER **/
        VDfld_set_list_text( form_ptr, INSULA_MATER, i, 0,
                             Insulation_class[i], FALSE );
      }

	  // Free the memory allocated
	  _LOOPFREE( Insulation_class, nbInsulationClass ); 
	}

    /*
     * 2. Call this function with "insul_type" set to "A" to fetch the Acoustic
     * Insulation Information. Allocate the memory to fetch the Acoustical
     * Insulation list and then proceed further in getting the actual list and
     * Display them in the respective field.
     */
	nbInsulationClass = 0;
	insul_type[0] = '\0';
    strcpy( insul_type, "A" ); // Thermal Insulation is being fetched
    status = VRHGet_Material_Insulation_ClassInfo( &retmsg, insul_type, NULL,
                                    NULL, &nbInsulationClass, NULL );

	__DBGpr_int( " Nb. of Acoustical Insulation Classes ", nbInsulationClass );

    if ( status & retmsg && (nbInsulationClass != 0) )
    {
      Insulation_class = _CALLOC( nbInsulationClass, IGRchar* );
      if( !Insulation_class ) return OM_E_NODYNMEM;

      for( i=0; i<nbInsulationClass; i++ )
      {
        Insulation_class[i] = _CALLOC( 25, IGRchar );
        if( !Insulation_class[i] ) return OM_E_NODYNMEM;
      }

	  status = VRHGet_Material_Insulation_ClassInfo( &retmsg, insul_type, NULL,
								  NULL, &nbInsulationClass, Insulation_class );

	  FIfld_set_list_num_rows( form_ptr, ACOUSTIC_MATERIAL, 
								0, nbInsulationClass );

	  for( i=0; i<nbInsulationClass; i++ )
	  {
		 /** Set the information in the gadget ACOUSTIC_MATERIAL **/
		__DBGpr_str( " Acst Insul Class ", Insulation_class[i] );
		VDfld_set_list_text( form_ptr, ACOUSTIC_MATERIAL, i, 0, 
							 Insulation_class[i], FALSE );
	  }

	  // Free the memory allocated
	  _LOOPFREE( Insulation_class, nbInsulationClass ); 
	}
  }

/* code added by satish for CR179900853 */
/****************************************************************************
* CR179900853 requires the system class field to be populated using
* database query rather than the user key-in. 
* This piece of code first finds out the number of entries in the database
* with the particular list number and then copies the corresponding 'short -
* text's into the system class list box.
* A new entry VR_R_SYSTEM_CLASS_LSTNUM is added to the VRdbcodlst.h file
****************************************************************************/
  if ( Product == VR_RWAY )
  {
	    IGRshort              p_num=0; 

            VR$RDB_CDL( p_msg = &retmsg,
                    nlist = VR_R_SYSTEM_CLASS_LSTNUM,
                    p_num = &p_num,
                    p_rec = NULL );

            if( p_num > 0)
            {
                struct VRRDB_cdl *rdbcdl=NULL;

                FIfld_set_list_num_rows( form_ptr, SYSTEM, 0, p_num );

                rdbcdl = _MALLOC( p_num, struct VRRDB_cdl );

                VR$RDB_CDL( p_msg = &retmsg,
                                nlist = VR_R_SYSTEM_CLASS_LSTNUM,
                                p_num = &p_num,
                                p_rec = rdbcdl );

                for( i=0; i<p_num; i++ )
                        VDfld_set_list_text( form_ptr,SYSTEM, i, 0,
                                             rdbcdl[i].stxt, FALSE);
		_FREE( rdbcdl );
            }

            // Populate the Tray Material list from CL145. CR179901774
            p_num = 0;
            VR$RDB_CDL( p_msg = &retmsg,
                    nlist = VR_R_MATERIAL_CLASS_LSTNUM,
                    p_num = &p_num,
                    p_rec = NULL );

            __DBGpr_int( " No. of Tray Materials", p_num );
            if( p_num > 0)
            {
                struct VRRDB_cdl *rdbcdl=NULL;

                FIfld_set_list_num_rows( form_ptr, DUCT_MATER, 0, p_num );

                rdbcdl = _MALLOC( p_num, struct VRRDB_cdl );

                VR$RDB_CDL( p_msg = &retmsg,
                                nlist = VR_R_MATERIAL_CLASS_LSTNUM,
                                p_num = &p_num,
                                p_rec = rdbcdl );

                for( i=0; i<p_num; i++ )
                {
                        __DBGpr_str( " Tray Material ", rdbcdl[i].ltxt );
                        VDfld_set_list_text( form_ptr,DUCT_MATER, i, 0,
                                             rdbcdl[i].ltxt, FALSE);
                }
                _FREE( rdbcdl );
            }
  }
 }
  End
  return OM_S_SUCCESS;

}

/***********************************************************************/

IGRint VRMissingPbId ( msg, CompId, PbId, MissingPbId, md_env )

IGRlong 		*msg;
struct 	GRid 		*CompId;
struct 	GRid 		*PbId;
struct 	GRid 		*MissingPbId;
struct	GRmd_env	*md_env;
{

	IGRlong			retmsg;
	IGRint			i, status;
	IGRint			FootIndex=-1, NbFailed, NbAttr;
  	struct ACrg_coll      	attributes[VR_MAX_ATTR], Missing[VR_MAX_ATTR];
	struct ret_struct	AttrRst;

	*msg = MSSUCC;

	if( PbId->objid == NULL_OBJID )
	{
		/*| ERROR : No Param Box given */
		*msg = MSFAIL;
		return ( OM_E_INVARG );
	}

	NbAttr = 0;

	/*| ------ List Collection attributes ----- */
  	status =
	om$send( msg      = message ACrg_collect.AClist_attribute
				( &retmsg, VR_MAX_ATTR, attributes, &NbAttr ),
		 senderid = PbId->objid,
                 targetid = PbId->objid,
                 targetos = PbId->osnum) ;
  	as$status( action = RET_STATUS ) ;
	
	NbAttr	     -= 1;
	NbFailed      = 0;

	/*| --- Get the values for each param and fill struct --- */
	for( i=0; i<NbAttr; i++ )
	{
		status = 
		om$send ( msg = message ACncpx.ACgive_structure
				        ( (IGRint *)&retmsg, &FootIndex, 
					   attributes[i].name, &AttrRst, md_env ),
			  senderid = NULL_OBJID,
		  	  targetid = CompId->objid,
			  targetos = CompId->osnum);
		as$status ( action = RET_STATUS );
		if ( !retmsg&1 )
		{
			strcpy( Missing[NbFailed].name ,attributes[i].name);

			if(  attributes[i].desc.type == AC_ATTRIB_TEXT )
			{
				Missing[NbFailed].desc.type = AC_ATTRIB_TEXT;
				strcpy( Missing[NbFailed].desc.value.att_txt," " );
			}
			else
			{
				Missing[NbFailed].desc.type = AC_ATTRIB_DOUBLE;
				Missing[NbFailed].desc.value.att_exp = 0.0;
			}
			NbFailed = NbFailed + 1;
		}
	}

	/*"NbFailed = %d \n",NbFailed*/

	if( NbFailed )
	{
		MissingPbId->objid = NULL_OBJID;
		MissingPbId->osnum = md_env->md_id.osnum;

		status = 
		VR$ModifyCollection( p_msg  		   = &retmsg,
                                     Operation             = VR_MERGE_COLL,
				     p_ParamsListToModify  = Missing,
         			     NbParamsToModify      = NbFailed,
                                     p_OutputCollectionId  = MissingPbId );
  		as$status();
 	}
	

  return OM_S_SUCCESS;

}/* end VRMissingPbId */

/****************************************************************************/

VRGetUserColl( form_ptr, gadget_label, UserId )

IGRchar		*form_ptr;
IGRint		gadget_label;
struct 	GRid	*UserId;
{
  IGRchar	*user_names[VR_MAX_ATTR];
  IGRchar	*user_values[VR_MAX_ATTR];
  IGRchar	names[VR_MAX_LEN * VR_MAX_ATTR];
  IGRchar	values[VR_MAX_LEN * VR_MAX_ATTR];
  IGRint	row, len, len1, sel_flag, r_pos, num_rows, num_param=0;
  IGRint	size, size_val, status;

  /*"gadget_label = %d\n", gadget_label */
  
  FIfld_get_max_num_rows( form_ptr, gadget_label, &num_rows );

  /*"num_rows = %d\n", num_rows */

  for( row=0, size=0, size_val=0; row<num_rows; row++ )
  {
    len = 0;
    FIfld_get_text_length( form_ptr, gadget_label, row, 0, &len );

    /*len = %d\n", len */
 
    if( len >1 )
    {
      num_param++;

      user_names[row] = &names[size];
    
      FIfld_get_text (form_ptr, gadget_label, row, 0, len, 
			(unsigned char *) user_names[row], &sel_flag, &r_pos
      );

      FIfld_get_text_length( form_ptr, gadget_label, row, 1, &len1 );

      /*len1 = %d\n", len1 */

      user_values[row] = &values[size_val];

      FIfld_get_text (form_ptr, gadget_label, row, 1, len1, 
			(unsigned char *) user_values[row], &sel_flag, &r_pos
      );

      size += len; size_val += len1;                           
    }
  }

  /*^
     IGRint i;

     printf("Root.VRGetUserColl ================================\n" );

     printf("number of param is %d\n", num_param );
     for( i=0; i<num_param; i++ )
     {
       printf("value of %s is %s\n", user_names[i], user_values[i] );
     }

     printf("Root.VRGetUserColl ================================\n" );
  */

  status =
  VRchg_attributes
           ( VR_ADD_OR_MOD_PARAM, *UserId, num_param, user_names, user_values );
  as$status( action = RET_STATUS ); 

  return OM_S_SUCCESS;
}

/***************************************************************************/

VRchg_attributes( 	IGRshort	chg_type,
			struct	GRid	attribute_id,
			IGRint		number,
			IGRchar		**attribute_names,
			IGRchar		**attribute_values)

/*.VRchg_attributes*/
{
  IGRint	i;
  IGRlong	status, retcode;


  if( attribute_names == NULL || attribute_values == NULL ) return OM_E_INVARG;

  status = OM_S_SUCCESS;

  /*" number to add is %d\n", number */

  for ( i=0; i<number; i++ ) 
  {
    switch( chg_type )
    {
      case VR_ADD_PARAM :
        /*"Adding %s with value %s \n", attribute_names[i], attribute_values[i]*/
        status = om$send( msg = message ACrg_collect.ACadd_attribute
                                        ( &retcode, attribute_names[i],
                                          attribute_values[i] ),
         	         senderid = NULL_OBJID,
		         targetid = attribute_id.objid,
		         targetos = attribute_id.osnum );
        as$status( action = RET_STATUS ); 
        break;

      case VR_MOD_PARAM :
        /*"mod %s with value %s \n", attribute_names[i], attribute_values[i] */
        status = om$send( msg = message ACrg_collect.ACmod_attribute
                                        ( &retcode, attribute_names[i],
                                          attribute_values[i] ),
         	         senderid = NULL_OBJID,
		         targetid = attribute_id.objid,
		         targetos = attribute_id.osnum );
        as$status( action = RET_STATUS ); 
        break;

      case VR_ADD_OR_MOD_PARAM :

        /*"Adding %s with value %s \n", attribute_names[i], attribute_values[i]*/
        status = om$send( msg = message ACrg_collect.ACadd_attribute
                                        ( &retcode, attribute_names[i],
                                          attribute_values[i] ),
         	         senderid = NULL_OBJID,
		         targetid = attribute_id.objid,
		         targetos = attribute_id.osnum );
        as$status( action = RET_STATUS ); 

        /*"Mod %s with value %s \n", attribute_names[i], attribute_values[i]*/
        status = om$send( msg = message ACrg_collect.ACmod_attribute
                                        ( &retcode, attribute_names[i],
                                          attribute_values[i] ),
         	         senderid = NULL_OBJID,
		         targetid = attribute_id.objid,
		         targetos = attribute_id.osnum );
        as$status( action = RET_STATUS ); 
        break;

      default : return OM_E_INVARG;
    }
  }

  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRSplitNetWork( msg, SegmentToSplitId, SplitPoint, md_env, CmpId, NewSegmentId )

IGRlong				*msg;              /* return code            */
struct		GRid		*SegmentToSplitId; /* Segment to split       */
IGRdouble			*SplitPoint;       /* the split point        */
struct		GRmd_env	*md_env;           /* the module env.        */
struct		GRid		*CmpId;            /* located cmp            */
struct		GRid		*NewSegmentId;     /* New segment            */


/*.VRSplitNetWork */
{
  IGRshort			CmpStatus, Product, Index;
  IGRlong			status, retcode;
  IGRdouble			CmpAngle = 0.0; /* component placement angle  */
  struct	GRid		CorId, SysParamId, UserParamId;
  struct 	IGRdisplay 	display;
  struct 	GRvg_construct	cst_list;  

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  status = VR$SplitSegment( p_retmsg		= &retcode,
			    SharePlanes 	= FALSE,
			    p_SegmentToSplitId	= SegmentToSplitId,
			    p_SplitPoint	= SplitPoint,
			    p_MdEnv		= md_env,
			    p_NewSegmentId	= NewSegmentId );
  as$status( action = RET_STATUS );

  /*| Get the construction list to place a dangling */
    
  status = 
  VRGetConstructionList( &retcode, md_env, (short unsigned *)NULL, (struct GRsymbology *)NULL,
			 &display, (IGRchar *)NULL, &cst_list );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*| Get needed infos to place dangling */

  /* get component class to get product */

  status = VRGetCmpClass( CmpId, &Product );
  as$status( action = RET_STATUS );

  /*"Product = %d\n", Product */

  /* see if component is a correction */

  status = om$send( msg      = message VRGeneric.VRGetStatus( &retcode, &CmpStatus ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );                  
  as$status( action = RET_STATUS );

  /* get attributes from component */
  status = VR$GetAttributes( 	p_retmsg	= &retcode,
				Product		= Product,
				CloneFlag	= ( CmpStatus & VR_CORRECTION ) ? TRUE : FALSE,
				p_ComponentId	= CmpId,
				p_SysParamId 	= &SysParamId,
				p_UserParamId	= &UserParamId,
				p_MdEnv		= md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*| place dangling on the old segment */

  Index = 1; /* Set index of the new dangling on th e segment */

  status = VR$PlaceCmpByItemName( 	p_retmsg          = &retcode,
		                        Product	  	  = Product,
                         		TopoParentsNum    = 1,
                         		p_TopoParentsList = SegmentToSplitId,
                         		p_CmpIndexOnTopo  = &Index,
                         		p_CmpAngle        = &CmpAngle,
                         		p_MdEnv       	  = md_env,
                         		p_ActParamId      = &SysParamId,
                         		p_UserParamId     = &UserParamId,
                         		p_CmpCstList      = &cst_list );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*| place dangling on the new segment */

  Index = 0; 

  status = VR$PlaceCmpByItemName( 	p_retmsg          = &retcode,
                         		Product	   	  = Product,
		                        TopoParentsNum    = 1,          
                		        p_TopoParentsList = NewSegmentId,
		                        p_CmpIndexOnTopo  = &Index,
                         		p_CmpAngle        = &CmpAngle,
                         		p_MdEnv       	  = md_env,
                         		p_ActParamId      = &SysParamId,
                         		p_UserParamId     = &UserParamId,
                         		p_CmpCstList      = &cst_list );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
					CorType		= VR_UNKNOWN,
 					p_SegmentId	= SegmentToSplitId,
 					p_MdEnv		= md_env,
					p_CorId		= &CorId );
  as$status();
  as$status( sts = retcode );

  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, md_env ),
		    senderid = NULL_OBJID,
		    targetid = CorId.objid,
		    targetos = CorId.osnum );
  as$status();

  status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
					CorType		= VR_UNKNOWN,
 					p_SegmentId	= NewSegmentId,
 					p_MdEnv		= md_env,
					p_CorId		= &CorId );
  as$status();
  as$status( sts = retcode );

  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, md_env ),
		    senderid = NULL_OBJID,
		    targetid = CorId.objid,
		    targetos = CorId.osnum );
  as$status();

  return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRChgCmpAttr( msg, NewAttr, CmpId, md_env )

IGRlong				*msg;
struct 		ACrg_coll	*NewAttr;
struct		GRid		*CmpId;
struct		GRmd_env	*md_env;

/*.VRChgCmpAttr */
{
  IGRint		status, i, NbChildren;
  IGRlong		retcode;
  struct	GRid	AttId[3], *p_Children;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;


/* -- Since this function is only called by the resizing and it only
	change one attribute on only one component at a time -> simplify -- */

	/* -- Find the collection to which the attribut belongs -- */
	status =
	om$send( msg      = message VRGeneric.VRGetParams( &retcode, 
					&AttId[0], &AttId[1], &AttId[2] ),
	senderid = NULL_OBJID,
	targetid = CmpId->objid,
	targetos = CmpId->osnum );

	for (i=0; i<3; i++)
	{
		IGRint			Index=-1;
		struct ret_struct	AttrSt;

		status =
		om$send( msg      = message ACncpx.ACgive_structure
				( (IGRint *)&retcode, &Index,
				   NewAttr->name, &AttrSt,md_env ),
			senderid = NULL_OBJID,
			targetid = AttId[i].objid,
			targetos = AttId[i].osnum );

		if ( (retcode&1) && (status&1) ) break;
	}

	if ( i==3 ) /* NOT FOUND */ return OM_E_ABORT;


	/* -- Change attribute -- */

	status =
	om$send( msg      = message NDnode.NDget_objects
		( ND_CHILDREN | ND_IN_BUF, NULL, 0, &p_Children, 0,
		  OM_K_MAXINT, &NbChildren ),
		senderid = NULL_OBJID,
		targetid = AttId[i].objid,
		targetos = AttId[i].osnum );
	as$status( action = RET_STATUS );

	/*| If the collection is shared with other components */

	if( NbChildren != 1 )
	{
		/*| Copy it */

		status =
		om$send( msg      = message NDnode.NDcopy
				( &retcode, 0, md_env, md_env, &AttId[i] ),
			senderid = NULL_OBJID,
			targetid = AttId[i].objid, 
			targetos = AttId[i].osnum  );
		as$status( action = RET_STATUS );

		status =
		om$send( msg      = message VRGeneric.VRChgParams
					(&retcode, &AttId[i], NULL,NULL),
			senderid = NULL_OBJID,
			targetid = CmpId->objid,
			targetos = CmpId->osnum );
		as$status( action = RET_STATUS );
	}


	status =
	om$send( msg      = message ACrg_collect.ACmod_list_attribute
				(&retcode,1,NewAttr),
		senderid = NULL_OBJID,
		targetid = AttId[i].objid,
		targetos = AttId[i].osnum );
	as$status( action = RET_STATUS );

	/*^ VRprint_user_attr( &NewSysId ); */

  return OM_S_SUCCESS;

}

/*****************************************************************************/

VRGetCmpClass( CmpId, Product )

struct	GRid	*CmpId;
IGRshort	*Product;
{
  IGRlong	status;
  GRclassid	obj_class;

  extern GRclassid OPP_VRPiping_class_id;
  extern GRclassid OPP_VRHvac_class_id;
  extern GRclassid OPP_VRRway_class_id;

  /*| Class of object */

  status = om$get_classid( osnum     = CmpId->osnum,
                           objid     = CmpId->objid,
                           p_classid = &obj_class );
  as$status();

  if( om$is_ancestry_valid
      ( subclassid   = obj_class,
        superclassid = OPP_VRPiping_class_id ) == OM_S_SUCCESS ) *Product = VR_PIPING;

  else if( om$is_ancestry_valid
         ( subclassid   = obj_class,
           superclassid = OPP_VRHvac_class_id ) == OM_S_SUCCESS ) *Product = VR_HVAC;

  else if( om$is_ancestry_valid
         ( subclassid   = obj_class,
           superclassid = OPP_VRRway_class_id ) == OM_S_SUCCESS ) *Product = VR_CABLING;

  else return(OM_E_ABORT);

  /*"Product = %d\n", *Product */

  return OM_S_SUCCESS;

}
/****************************************************************************/

VRDeleteObjects( NbObjects, p_ObjectsList, p_MdEnv )

IGRint			NbObjects;
struct	GRid		*p_ObjectsList;
struct 	GRmd_env 	*p_MdEnv;

/*. VRDeleteObjects */

{
  IGRlong 	status=OM_S_SUCCESS;
  IGRint	i;
  IGRboolean 	bBr_save;

  extern  IGRboolean      ASbroadcast_in_progress;

  /*| save Broadcast flag */
  bBr_save = ASbroadcast_in_progress;

  /*| force it to TRUE */
  ASbroadcast_in_progress = TRUE;

  for( i=0; i<NbObjects; i++ )
  {
	status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, p_MdEnv ),
			  senderid = NULL_OBJID,
			  targetid = p_ObjectsList[i].objid,
			  targetos = p_ObjectsList[i].osnum );
	as$status();
  }

  /*| reset Broadcast fl */
  ASbroadcast_in_progress = bBr_save;

  nd$wait_batch( type       = GR_DELETED,
                 l_object   = p_ObjectsList,
                 nb_obj     = NbObjects );

  return OM_S_SUCCESS;

}

/*********************************************************************************************/

VRCheckCompTopo( p_CompTopo, p_CompId, p_MdEnv )

IGRint				*p_CompTopo;
struct		GRid		*p_CompId;
struct		GRmd_env	*p_MdEnv;

/*. VRCheckCompTopo */
{
  IGRlong			status, retmsg;
  struct	ACrg_coll 	Topo;

  strcpy ( Topo.name, VR_N_COMP_TOPO_IN );

  status= om$send( msg 	  = message VRGeneric.VRGetCompDesc( &retmsg, &Topo, p_MdEnv ),
  		   senderid = NULL_OBJID,
		   targetid = p_CompId->objid,
		   targetos = p_CompId->osnum );
  as$status ( action = RET_STATUS );

  /*" CompTopo = %f\n", Topo.desc.value.att_exp */

  *p_CompTopo = 0;

  if( Topo.desc.value.att_exp == VRP_V_UNDEFINED_TOPO ||
      Topo.desc.value.att_exp == VRH_V_UNDEFINED_TOPO ||
      Topo.desc.value.att_exp == VRR_V_UNDEFINED_TOPO	)
  {
	/*| VR_UNDEFINED_TOPO */
      	*p_CompTopo = VR_UNDEFINED_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_CLOSURE_TOPO ||
      Topo.desc.value.att_exp == VRH_V_CLOSURE_TOPO ||
      Topo.desc.value.att_exp == VRR_V_CLOSURE_TOPO 	)
  {
	/*| VRP_V_CLOSURE_TOPO */
	*p_CompTopo = VR_CLOSURE_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_INLINE_TOPO ||
      Topo.desc.value.att_exp == VRH_V_INLINE_TOPO ||
      Topo.desc.value.att_exp == VRR_V_INLINE_TOPO 	)
  {
	/*| VRP_V_INLINE_TOPO */
	*p_CompTopo = VR_INLINE_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_2_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRH_V_2_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRR_V_2_WAYS_TOPO 	)
  {
	/*| VRP_V_2_WAYS_TOPO */
	*p_CompTopo = VR_2_WAYS_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_3_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRH_V_3_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRR_V_3_WAYS_TOPO 	)
  {
	/*| VRP_V_3_WAYS_TOPO */
	*p_CompTopo = VR_3_WAYS_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_OLET_TOPO ||
      Topo.desc.value.att_exp == VRH_V_OLET_TOPO ||
      Topo.desc.value.att_exp == VRR_V_OLET_TOPO 	)
  {
	/*| VRP_V_OLET_TOPO */
	*p_CompTopo = VR_OLET_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_4_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRH_V_4_WAYS_TOPO ||
      Topo.desc.value.att_exp == VRR_V_4_WAYS_TOPO 	)
  {
	/*| VRP_V_4_WAYS_TOPO */
	*p_CompTopo = VR_4_WAYS_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_ECCENTRIC_TOPO ||
      Topo.desc.value.att_exp == VRH_V_ECCENTRIC_TOPO ||
      Topo.desc.value.att_exp == VRR_V_ECCENTRIC_TOPO 	)
  {
	/*| VRP_V_ECCENTRIC_TOPO */
	*p_CompTopo = VR_ECCENTRIC_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_RETURN_TOPO ||
      Topo.desc.value.att_exp == VRH_V_RETURN_TOPO ||
      Topo.desc.value.att_exp == VRR_V_RETURN_TOPO 	)
  {
	/*| VRP_V_RETURN_TOPO */
	*p_CompTopo = VR_RETURN_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_OFFSET_TOPO ||
      Topo.desc.value.att_exp == VRH_V_OFFSET_TOPO ||
      Topo.desc.value.att_exp == VRR_V_OFFSET_TOPO 	)
  {
	/*| VRP_V_OFFSET_TOPO */
	*p_CompTopo = VR_OFFSET_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRP_V_HELIX_TOPO 	)
  {
	/*| VRP_V_HELIX_TOPO */
	*p_CompTopo = VR_HELIX_TOPO;
  }
			  
  else 
  if( Topo.desc.value.att_exp == VRH_V_SPLIT_TOPO ||
      Topo.desc.value.att_exp == VRR_V_SPLIT_TOPO 	)
  {
	/*| VRP_V_SPLIT_TOPO */
	*p_CompTopo = VR_SPLIT_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRH_V_SPLIT_TOPO 	)
  {
	/*| VRP_V_BEND_SPLIT_TOPO */
	*p_CompTopo = VR_BEND_SPLIT_TOPO;
  }

  else 
  if( Topo.desc.value.att_exp == VRH_V_Y_BRANCH_TOPO ||
      Topo.desc.value.att_exp == VRR_V_Y_BRANCH_TOPO 	)
  {
	/*| VRP_V_BRANCH_TOPO */
	*p_CompTopo = VR_Y_BRANCH_TOPO;
  }

  /*" CompTopo = %d\n", *p_CompTopo */

  return OM_S_SUCCESS;
}

/********************************************************************************************/

VRCreateDepPlanes
	( InPutFlag, NbTemp, p_TempId, p_TempMdEnv, p_MdEnv, NbDepPlanes, p_DepPlanesId )

IGRint		InPutFlag;		/* see VRDepPlane.S and VRplanedef.h         	*/
IGRint		NbTemp;			/* number of input template		     	*/
struct GRid	*p_TempId;		/* template list			     	*/
struct GRmd_env	*p_TempMdEnv;		/* template module info			     	*/
struct GRmd_env	*p_MdEnv;		/* current module info			     	*/
IGRint		NbDepPlanes;		/* number of dependant planes		     	*/
struct GRid	*p_DepPlanesId;		/* dependant planes			     	*/

/*.VRCreateDepPlanes */
{
  IGRint		i, CreateFlag, status=OM_S_SUCCESS, ValidDim=1;
  struct	GRas	assoc_list;
  SetProc( Fn VRCreateDepPlanes ); Begin

  if( !NbTemp || !p_TempId || !p_TempMdEnv || !p_MdEnv || !p_DepPlanesId ) 
  {
    End
    return OM_E_INVARG;
  }

  assoc_list.num_parents = 1;

  /*"InputFlag = %x\n", InPutFlag */

  if( InPutFlag & ( VR_DEP_REF | VR_DEP_CPT ) )
  {
	/*| plane depend on referential or component cpt */
        __DBGpr_com("plane depend on referential or component cpt");

	if( NbDepPlanes < ValidDim )
        {
          End
          return OM_E_INVARG;
        }

	/*"Given Temp id = <%d,%d>\n", p_TempId[0].objid, p_TempId[0].osnum */

	assoc_list.parents = &p_TempId[0];

	if( InPutFlag & VR_DEP_XY_REF )
	{
		CreateFlag = ( InPutFlag & ~VR_ALL_PLANES ) | VR_DEP_XY_REF;
       		/*"CreateFlag = %x\n", CreateFlag */

       		assoc_list.as_attr = ( IGRchar * ) &CreateFlag;
		p_DepPlanesId[ValidDim-1].osnum = p_MdEnv->md_id.osnum;
		status = om$construct( 	classid	= OPP_VRDepPlane_class_id,
			       		osnum	=  p_DepPlanesId[ValidDim-1].osnum,
			       		p_objid	= &p_DepPlanesId[ValidDim-1].objid,
			       		msg	= message NDnode.NDplace(&assoc_list, p_MdEnv, NULL));
		as$status();

		/*"New plane id = <%d,%d>\n", p_DepPlanesId[ValidDim-1].objid, p_DepPlanesId[ValidDim-1].osnum */

		ValidDim++; /* needed to test p_DepPlanesId list dimension */
	}

	if( InPutFlag & VR_DEP_XZ_REF )
	{
		if( NbDepPlanes < ValidDim ) return OM_E_INVARG;

		CreateFlag = ( InPutFlag & ~VR_ALL_PLANES ) | VR_DEP_XZ_REF;
       		/*"CreateFlag = %x\n", CreateFlag */

       		assoc_list.as_attr = ( IGRchar * ) &CreateFlag;
		p_DepPlanesId[ValidDim-1].osnum = p_MdEnv->md_id.osnum;
		status = om$construct( 	classid	= OPP_VRDepPlane_class_id,
			       		osnum	=  p_DepPlanesId[ValidDim-1].osnum,
			       		p_objid	= &p_DepPlanesId[ValidDim-1].objid,
			       		msg	= message NDnode.NDplace(&assoc_list, p_MdEnv, NULL));
		as$status();

		/*"New plane id = <%d,%d>\n", p_DepPlanesId[ValidDim-1].objid, p_DepPlanesId[ValidDim-1].osnum */

		ValidDim++; /* needed to test p_DepPlanesId list dimension */
	}

	if( InPutFlag & VR_DEP_YZ_REF )
	{
		if( NbDepPlanes < ValidDim ) return OM_E_INVARG;

		CreateFlag = ( InPutFlag & ~VR_ALL_PLANES ) | VR_DEP_YZ_REF;
       		/*"CreateFlag = %x\n", CreateFlag */

       		assoc_list.as_attr = ( IGRchar * ) &CreateFlag;
		p_DepPlanesId[ValidDim-1].osnum = p_MdEnv->md_id.osnum;
		status = om$construct( 	classid	= OPP_VRDepPlane_class_id,
			       		osnum	=  p_DepPlanesId[ValidDim-1].osnum,
			       		p_objid	= &p_DepPlanesId[ValidDim-1].objid,
			       		msg	= message NDnode.NDplace(&assoc_list, p_MdEnv, NULL));
		as$status();

		/*"New plane id = <%d,%d>\n", p_DepPlanesId[ValidDim-1].objid, p_DepPlanesId[ValidDim-1].osnum */
	}
  }
  else if( InPutFlag & VR_DEP_PLANE )
  {
	__DBGpr_com(" plane depend of given plane ");

	if( NbTemp > NbDepPlanes ) return OM_E_INVARG;

	for( i=0; i<NbTemp; i++ )
	{
		status = as$make_source(	go_grid		= p_TempId[i],
						mod_env		= p_TempMdEnv,
						as_os		= p_MdEnv->md_id.osnum,
						as_grid		= &p_TempId[i] );
		as$status();

		/*"DepPlane Temp = %d %d\n", p_TempId[i].objid, p_TempId[i].osnum */

		CreateFlag = VR_DEP_PLANE;
		/*"CreateFlag = %x\n", CreateFlag */

       		assoc_list.as_attr = ( IGRchar * ) &CreateFlag;
		assoc_list.parents = &p_TempId[i];
		p_DepPlanesId[i].osnum = p_MdEnv->md_id.osnum;
		status = om$construct( 	classid	= OPP_VRDepPlane_class_id,
			       		osnum	=  p_DepPlanesId[i].osnum,
			       		p_objid	= &p_DepPlanesId[i].objid,
			       		msg	= message NDnode.NDplace(&assoc_list, p_MdEnv, NULL));
		as$status();

		/*"New plane id = <%d,%d>\n", p_DepPlanesId[i].objid, p_DepPlanesId[i].osnum */
	}
  }
  End
  return OM_S_SUCCESS;

}

/********************************************************************************************/

VRChangePocketMenu ( szPocketMenuName )

IGRchar *szPocketMenuName;
/*.VRChangePocketMenu */
{
  IGRint	k;
  IGRchar 	szPocketFileName [200];
  IGRlong	PathStatus = TRUE;
  FILE 		*fp;

  if( strcmp( szPocketMenuName , DEFAULTPKTMNU ) == 0 ){
    /*
     * go back to the default pocket menu
     */
    /*"Swapping pocket with <%s>\n",szPocketFileName */
    vd$pkt_menu( );

    return OM_S_SUCCESS;
  }

  for( k=0; PathStatus == TRUE; k++ )
  {
    	if( ( PathStatus = ex$get_path(	index = k,
					path = szPocketFileName,
					len = sizeof( szPocketFileName ) ) ) )
	{
		strcat( szPocketFileName, POCKETPATH );
		strcat( szPocketFileName, szPocketMenuName );

		fp = ( FILE * ) fopen( szPocketFileName , "r" );

		if( fp == NULL ) continue;
		else
	    	{
	    		fclose( fp );
	    		break;
	    	}
	}
    	else
	{
		/*| Didn't manage to get path */
		return OM_S_SUCCESS;
	}
  }

  /*"Swapping pocket with <%s>\n",szPocketFileName */
  MS_swap_menu (POCKET_MENU, szPocketFileName );

  return	OM_S_SUCCESS;

} 


/********************************************************************************************/
/*
/* The event sent looks like AABBCC code , OptionFlag ( reducer, offset, split or shape )
/*
/**/

IGRint	VRGetAABBCC( msg, event, szAABBCC, bFlag )

IGRlong				*msg;
struct 		GRevent		*event;
IGRchar				*szAABBCC;
IGRboolean			*bFlag;

/*.VRGetAABBCC */
{
  IGRint	i, aabbccFlag=0, Shape;
  IGRchar	szFlag[10], *pFlag, *pShape, *pCode, EventCode[260], szUserKeyin[70];

  *msg = MSSUCC;

  /* BEGIN : INSERT FROM VRReadCodeFile */

  /* Check whether it's reducer like and so one */
  /* Check for reducer */
  /*" event->event.keyin :<%s>\n", event->event.keyin */

  if( strlen( event->event.keyin ) < 70 ) VRCopyWithOutSpace( event->event.keyin, EventCode );
  else
  {
    	*szAABBCC = 0;
    	*msg = MSFAIL;
    	return OM_S_SUCCESS;
  }
  /*" EventCode : <%s>\n", EventCode */

  if( VRlocate_pattern( REDUCERSTRING, EventCode ) != -1 )
  {
    	/*| Reducer flag set */
    	aabbccFlag |= REDUCERFLAG;
  }

  if( VRlocate_pattern( OFFSETSTRING, EventCode ) != -1 )
  {
    	/*| Offset flag set */
    	aabbccFlag |= OFFSETFLAG;
  }

  if( VRlocate_pattern( SPLITSTRING, EventCode ) != -1 )
  {
	    /*| Split flag set */
	    aabbccFlag |= SPLITFLAG;
  }

  if( VRlocate_pattern( SHAPESTRING, EventCode ) != -1 )
  {
    	/*| Shape flag set */

    	pShape = strtok (EventCode , "=");
    	pShape = strtok (NULL , "=");
    	Shape = atoi (pShape);
    	/*"Shape found %d\n", Shape */

    	aabbccFlag |= SHAPEFLAG;
    	aabbccFlag |= Shape;
  }

  /* copy the aabbcc code into a buffer */
  for( i=0;i<6 && EventCode[i] != '\n'; i++) szUserKeyin[i] = EventCode[i];
  szUserKeyin[6] = 0;

  aabbccFlag |= SUCCESSFLAG; /* set the bit ok */
  sprintf( szFlag, ",%d", aabbccFlag );
  strcat( szUserKeyin, szFlag );

  /*" SzUserKeyin: <%s>\n", szUserKeyin */

  /* END : INSERT FROM VRReadCodeFile */

  pCode = strtok (szUserKeyin, ",");
  pFlag = strtok (NULL, " ,");

  if( strlen( pCode ) > 6 )
  {
    	/*| Invalid AABBCC code value */
    	*msg = MSFAIL;
    	*szAABBCC = 0;
  } 
  else
  {
    	/* Make sure there is no more than six characters entered */
    	strcpy(szAABBCC,pCode);
    	*bFlag = atoi (pFlag);
  }

  /*"Code is <%s>\n", szAABBCC */
  /*"bFlag is <%d>\n", *bFlag */

  return OM_S_SUCCESS;

}

/********************************************************************************************/

VRCopyWithOutSpace( szStringIn, szStringOut )

IGRchar		*szStringIn;
IGRchar		*szStringOut;

/*.VRCopyWithOutSpace */
{
  IGRchar *pStringIn, *pStringOut;

  pStringIn = szStringIn;
  pStringOut = szStringOut;

  while( *pStringIn != 0 )
  {
    	if( *pStringIn != 0x20 && *pStringIn != '\t' ) *pStringOut++ = *pStringIn;
    	pStringIn++;
  }

  *pStringOut = 0;

  /*"szStringOut <%s>\n", szStringOut */

  return OM_S_SUCCESS;

} 

/****************************************************************************/

VRBuildCompPlanes ( 	IGRlong		*p_retmsg,
			struct GRid	*p_ComponentId,
			IGRshort	CptNum,
			struct GRmd_env	*p_CompMdEnv,
			struct GRid	*p_PlaneIds,
			struct GRmd_env	*p_PlanesMdEnv)

/*. VRBuildCompPlanes */
{
  IGRboolean			CompSimple;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  BSrc				bsretcode;
  GRclassid			CompClassId;
  IGRdouble 			dOrig[3],dConAxis[3],dOrieAxis[3], dZ[3];

  extern	GRclassid	OPP_VRComponent_class_id;


  *p_retmsg = MSSUCC;

  p_PlaneIds[0].objid = p_PlaneIds[1].objid = p_PlaneIds[2].objid = NULL_OBJID;


  /* we need to distinguish the nozzle case */
  status = om$get_classid( 	objid = p_ComponentId->objid,
				osnum = p_ComponentId->osnum,
				p_classid = &CompClassId
			 );
  as$status();

  CompSimple = om$is_ancestry_valid( subclassid 	= CompClassId,
		  		     superclassid 	= OPP_VRComponent_class_id );

  if( CompSimple == OM_S_SUCCESS )
  {
	  /*| -- Get origin point -- */
	  status = om$send( msg      = message VRGeneric.VRGetOrigCoor
					( &retcode, dOrig, p_CompMdEnv ),
			    senderid = NULL_OBJID,
			    targetid = p_ComponentId->objid,
			    targetos = p_ComponentId->osnum );
	  as$status( action = RET_STATUS );
	  as$status( sts = retcode, action = RET_STATUS );
  }
 
  /* -- Get axes from CPT -- */
  status = om$send( msg      = message VRGeneric.VRGetCptGeom
  				( &retcode, CptNum, 
				  ( CompSimple==OM_S_SUCCESS) ? NULL : dOrig,
				  dConAxis, dOrieAxis, p_CompMdEnv ),
		    senderid = NULL_OBJID,
		    targetid = p_ComponentId->objid,
		    targetos = p_ComponentId->osnum );
  as$status ( action = RET_STATUS );

  /*" Origin : %f, %f, %f\n", dOrig[0],dOrig[1],dOrig[2] */

  /* -- Create end plane -- */
  /*"End Plane normal : %f, %f, %f\n", dConAxis[0],dConAxis[1],dConAxis[2] */
  status = cre_plan( dOrig, dConAxis, p_PlanesMdEnv, &p_PlaneIds[2] );
  as$status ( action = RET_STATUS );

  BScrossp( &bsretcode, dConAxis, dOrieAxis, dZ );

  /* -- Create common plane -- */
  /*" Common Plane normal : %f, %f, %f\n", dZ[0],dZ[1],dZ[2] */
  status = cre_plan( dOrig, dZ, p_PlanesMdEnv, &p_PlaneIds[0] );
  as$status ( action = RET_STATUS );

  /* -- Create ortho plane -- */
  /*" Ortho Plane normal : %f, %f, %f\n", dOrieAxis[0],dOrieAxis[1],dOrieAxis[2] */
  status = cre_plan( dOrig, dOrieAxis, p_PlanesMdEnv, &p_PlaneIds[1] );
  as$status ( action = RET_STATUS );

  return OM_S_SUCCESS;

}

int VR_strip_space( in_string, out_string )
 char * in_string;
 char * out_string;
{
  int i,j;
  int length_in;

  i=0; j=0;
  length_in = strlen( in_string );
  while ( i < length_in || in_string[i] != '\0' )
  {
        if ( in_string[i] != ' ' ) {
             out_string[j] = in_string[i];
             j++;
        }
        i++;
  }

  out_string[j] = 0;

  return 1;
}

/* This function would add/update the given attribute value in the User
Attribute collections of the Component. If a separate user collector exist then
it would just add/update it. If the user collector is shared by many then
it would copy the collector and create a new instance and add the new attribute
in that. Alwin */

IGRint VRAddUserAttribute( 	IGRlong *msg, 			/* (O) */
							IGRchar *szAttrName, 	/* Attribute Name (I) */
							IGRint nType,			/* Attribute Type (I) */
							IGRchar *szAttrValue, /*Attr value sent as string */
							struct GRid ComponentId /* Component Id	(I) */
						 )
{
	IGRint				status, NbParams;
	IGRshort			nCmpStatus;
	struct ACrg_coll	attribute;
	struct GRid			UserCollectorId;

	NbParams = 1;

	strcpy( attribute.name, szAttrName );
	if(  nType == AC_ATTRIB_TEXT )
	{
		attribute.desc.type == AC_ATTRIB_TEXT;
		strcpy( attribute.desc.value.att_txt, szAttrValue );
	}
	else
	{
		attribute.desc.type = AC_ATTRIB_DOUBLE;
		attribute.desc.value.att_exp = atof(szAttrValue);
	}

	// Get the User Collector Id
	status = om$send( msg = message VRGeneric.VRGetParams( msg, NULL,
								&UserCollectorId, NULL ),
						targetid = ComponentId.objid,
						targetos = ComponentId.osnum,
						senderid = NULL_OBJID );

	{
		// Find out if anybody else is using the same user collector object. 
		// If some one is using it, then we can't modify that. Instead we 
		// should copy the collector and then add/update the attribute info

		IGRint		NbChildren=0;

		status = om$send( msg = message NDnode.NDget_objects( 
                                  ND_CHILDREN, NULL, 0,
                                  NULL, 0, OM_K_MAXINT, &NbChildren ),
						targetid = UserCollectorId.objid,
						targetos = UserCollectorId.osnum,
						senderid = NULL_OBJID );
		as$status( action = GOTO_VALUE, value = wrapup );

		// then collection is being shared, so create a copy and work on it
		if( NbChildren > 0 )
		{
			IGRint				size, ret_size;
			struct GRmd_env		MdEnv;
			struct GRid			NewId;

			size = sizeof(MdEnv);

			gr$get_module_env( msg    = msg,
							   sizbuf = &size,
							   buffer = &MdEnv,
							   nret   = &ret_size );

			// Copy the collector
			status =
			om$send( msg      = message NDnode.NDcopy
							( msg, 0, &MdEnv, &MdEnv, &NewId ),
						targetid = UserCollectorId.objid,
						targetos = UserCollectorId.osnum,
						senderid = NULL_OBJID );
			as$status( action = GOTO_VALUE, value = wrapup );

            // call change parameters, to change the Corrections parent 
            status =
			om$send( msg      = message VRGeneric.VRChgParams
                                  ( msg, NULL, &NewId, NULL ),
						targetid = ComponentId.objid,
						targetos = ComponentId.osnum,
						senderid = NULL_OBJID );
            as$status( action = GOTO_VALUE, value = wrapup );

			UserCollectorId = NewId;
		}
	}

	// Update/add the attribute to the collector
	status = 
	VR$ModifyCollection( p_msg  		   	   = msg,
						 Operation             = VR_MERGE_COLL,
						 p_ParamsListToModify  = &attribute,
						 NbParamsToModify      = NbParams,
						 p_OutputCollectionId  = &UserCollectorId );
	as$status();

wrapup:
	return status;
}

/* 
 * This function is being called from VRHvpara.sl file. In cases FI_EXECUTE
 * and FI_ACCEPT.
 *
 * This is update the "acst" value of the Active User Parameters collection.
 * Added by Alwin for CR179901312.
 *
 * For CR179901661, hide the "acst" attribute such a way that user won't be
 * able to modify this attribute. And delete the "acst" from the User Collector
 * this is done mainly for older version files.
 */
#include "vrparameters.h"
IGRlong VRUpdate_ACST_User_Param( 	IGRchar *form_ptr, 
					struct GRid *UserParamId,
					struct GRid *SysParamId )
{
       IGRint           NbAttr=0;
       IGRdouble        acoustic_insul_thk=0.0;
       IGRlong          retmsg, status=OM_S_SUCCESS;
       struct ACrg_coll ListAttr; 
       
       SetProc( Fn VRUpdate_ACST_User_Param ); Begin 

      /*
       * CR 179901312. User Parameter 'acst' is defined as the sum of the
       * Thermal and Acoustic Insulation thicknesses, when Acoustic Insulation
       * is non_zero.
       *
       * i.e.
       *    For acoustic_insul_thk > 0
       *        acst = thermal_insul_thk + acoustic_insul_thickness
       *
       *    For acoustic_insul_thk <= 0
       *        acst = 0.0
       */

      NbAttr = 1;
      strcpy(ListAttr.name, VR_N_ACST_DB );
      ListAttr.desc.type = AC_ATTRIB_DOUBLE;
      ListAttr.desc.value.att_exp = acoustic_insul_thk;

      FIg_get_value( form_ptr, ACOUSTIC_THICK, &acoustic_insul_thk );
      __DBGpr_dbl( " Acoustic Insulation Thickness ", acoustic_insul_thk );

      if( acoustic_insul_thk > 0.0 )
      {
         IGRdouble      thermal_insul_thk = 0.0;
         IGRdouble      acst = 0.0;

         FIg_get_value( form_ptr, INSULA_THICK, &thermal_insul_thk );
	 __DBGpr_dbl( " Thermal Insulation Thickness ", thermal_insul_thk );

         acst = thermal_insul_thk + acoustic_insul_thk;
         ListAttr.desc.value.att_exp = acst;
      }

      __DBGpr_dbl( " acst value ", ListAttr.desc.value.att_exp );

      status =
      VR$ModifyCollection(
                 p_msg                  = &retmsg,
                 Operation              = VR_MERGE_COLL,
                 p_ParamsListToModify   = &ListAttr,
                 NbParamsToModify       = NbAttr,
                 p_OutputCollectionId   = SysParamId );

      /* 
       * Delete the "acst" from the Active User Parameters collection.
       */
      status =
      VR$ModifyCollection(
                 p_msg                  = &retmsg,
                 Operation              = VR_SUBSTR_COLL,
                 p_ParamsListToModify   = &ListAttr,
                 NbParamsToModify       = NbAttr,
                 p_OutputCollectionId   = UserParamId );

      /* -- Store the active user parameters -- */
      VR$active_params( operation   = VR_REPLACE,
			mode	    = VR_USER_MODE, 
                        update_flag = VR_NOUPDATE,
                        VRproduct   = VR_HVAC,
                        act_param_id= UserParamId,
                        status      = status );
      as$status( action = RET_STATUS );

      End
      return status;
}

/*
 * This function is written.....mainly for the SPX. Later this would
 * disappear and the functionality would be integrated in the State Table.
 * CR179900995. Alwin
 *
 * It constructs a PPL object, which would enable the user to locate a DUCT
 * and so we can retrieve the object Id of the DUCT. The object Id is
 * returned as the output to the Calling funtion.
 */

#include "VDtypedef.h"
#include "VDppl1.h"

IGRlong VRCopyDuctParams( IGRlong *msg, struct GRid *DuctId )
{
    TGRid     pplID ;
    IGRint    pplRET ;
	IGRint	  objid, osnum;

    SetProc( Fn VRCopyDuctParams ); Begin

    *msg = MSFAIL ;

    /* Load ppl */

    __DBGpr_com( " PPL is going to be loaded ");
    vdppl$Load(name = "COz_LocDuct", pplID = &pplID);

    if (pplID.objid != NULL_OBJID)
	{
	  __DBGpr_com( " PPL is loaded ");
	  vdppl$Run( pplID = &pplID, name = "getDuctObject", ret = &pplRET );

	  if( !pplRET & MSSUCC ) return (*msg );

	  vdppl$GetData(
		  pplID = &pplID,
		  name  = "objid",
		  size  = sizeof(int),
		  data  = (IGRchar*) &objid );

	  vdppl$GetData(
		  pplID = &pplID,
		  name  = "osnum",
		  size  = sizeof(int),
		  data  = (IGRchar*) &osnum );

	  vdppl$Delete(pplID = &pplID);

	  *msg = MSSUCC;
	  DuctId->objid = objid;
	  DuctId->osnum = osnum;
	  __DBGpr_obj( " Located Object Id ", *DuctId );
	  objid = -1;
	  osnum = 0;
	}

	End
	return *msg;
}

#include "VRPDBdef.h"
#include "VRPDBmac.h"

/* 
 * This function is written to compare two double values. This is being
 * used by the qsort function to sort the list of double values.
 */
IGRint dblCompare( IGRdouble *i, IGRdouble *j )
{
   if( *i > *j ) return (1);

   if( *i < *j ) return (-1);

   return (0 );
}

/* 
 * Product = PIPING only
 * This function is written to update the insulation thickness based on the
 * selection of the insulation type. CR179901615 Alwin
 */

IGRlong VRPGetInsulThkFromType( Form form_ptr, 
				IGRint  gadget_label, 
				IGRchar  *insul_type )
{
   IGRint		i;
   IGRshort		NumCodeList=0;
   IGRlong		retmsg, status;
   IGRchar		szText[10];
   struct VRPDB_cdl    *CodeRec=NULL;

   SetProc( Fn VRPGetInsulThkFromType ); Begin 

    __DBGpr_str( " Selected insul_type ", insul_type );

   /*
    * Insulation type is defined in CL220. So fetch the CL220 db info
    * find out the corresponding "code_num" for the selected "insultype"
    *
    * Then use this "code_num" to fetch the list of "insul_thk" from CL221.
    * for CR179901615. Alwin
    */

    status = VR$PDB_CDL( p_msg = &retmsg,
			nlist = VR_P_INSUL_TYPE_LSTNUM,
			p_num = &NumCodeList );
    as$status( action=RET_STATUS );

    __DBGpr_int(" NumCodeList ->220", NumCodeList );

    if( NumCodeList > 0 )
    {
	IGRboolean	bFoundCodeNum=FALSE;
	IGRshort	nCodeNum;

	CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );
	__CheckPtr( CodeRec, "Memory Allocation error ", quit );

	status = VR$PDB_CDL(     p_msg = &retmsg ,
				 nlist = VR_P_INSUL_TYPE_LSTNUM,
				 p_num = &NumCodeList,
				 p_rec = CodeRec );

	if( !(status & OM_S_SUCCESS)|| (retmsg != MSSUCC) || 
				(CodeRec == NULL) )
	{
	       __DBGpr_com(" Failed cache access for codelist 220");
	       End
	       return (status);
	}

	for( i=0; i<NumCodeList && (!bFoundCodeNum); i++ )
	{
	   if( strcmp( insul_type, CodeRec[i].stxt ) == 0 )
	   {
	       nCodeNum = CodeRec[i].ncode;
	       bFoundCodeNum = TRUE;
	   }
	}
	_FREE( CodeRec );

	// Fetch the CL221 and populate the INSUL_THK gadget with the
	// thicknesses for the selected "insul_type"
	if( bFoundCodeNum )
	{
	   status = VR$PDB_CDL( p_msg = &retmsg,
			       nlist = VR_P_INSUL_THICK_LSTNUM,
			       ncode = nCodeNum,
			       p_num = &NumCodeList );

	   if( !(status & OM_S_SUCCESS)|| (retmsg != MSSUCC) ) 
	   {
	       UI_status( "Failed accessing CL221" );
	       __DBGpr_com(" Failed cache access for codelist 220");
	       End
	       return status;
	   }

	   if( NumCodeList > 0 )
	   {
	       IGRboolean	bExisting=FALSE;
	       IGRdouble	*dThickList=NULL;
	       IGRchar		szCurrentInsulation[10];

	       CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );
	       __CheckPtr( CodeRec, "Memory Allocation error ", quit );

	       status = VR$PDB_CDL(     p_msg = &retmsg ,
					nlist = VR_P_INSUL_THICK_LSTNUM,
					ncode = nCodeNum,
					p_num = &NumCodeList,
					p_rec = CodeRec );

	       if( !(status & OM_S_SUCCESS)|| (retmsg != MSSUCC) ||
				       (CodeRec == NULL) )
	       {
		  __DBGpr_com(" Failed cache access for codelist 221");
		  End
		  return (status);
	       }

	       FIfld_set_list_num_rows( form_ptr, gadget_label,0, NumCodeList );

	       //As per spec, the string thicknesses populated should be sorted
	       // size of each string is 8 characters.
	       if( NumCodeList )
	       {
		 dThickList = _CALLOC( NumCodeList, IGRdouble );
		 __CheckPtr( dThickList, "Memory Allocation Error", quit );

		 for( i=0; i<NumCodeList; i++ )
		    dThickList[i] = atof( CodeRec[i].stxt );

		 qsort( (char*) dThickList, NumCodeList,
				sizeof(IGRdouble), dblCompare );
	       }


	       FIg_get_text( form_ptr, gadget_label, szCurrentInsulation );
	       __DBGpr_str( " Current insulation ", szCurrentInsulation );

	       for( i=0; i<NumCodeList; i++ )
	       {
		   sprintf( szText, "%g", dThickList[i] );
		   __DBGpr_str( " Thickness ", szText );

		   FIfld_set_list_text( form_ptr, gadget_label,
			i, 0, (IGRuchar*) szText, FALSE );

		   if( !strcmp( szText, szCurrentInsulation) ) bExisting = TRUE;
	       }

	       if( !bExisting ) FIg_set_text( form_ptr, gadget_label, "" );

	       if( NumCodeList == 1 ) 
		   FIg_set_text( form_ptr, gadget_label, szText );

	       _FREE( CodeRec );
	       _FREE( dThickList );
	   }
	}
    }

    if( NumCodeList == 0 )
    {
	FIfld_set_list_num_rows( form_ptr, gadget_label, 0, 0 );
	FIg_set_text( form_ptr, gadget_label, "0.0" );
    }
    End
    return retmsg;

quit:
    _FREE( CodeRec );
    End
    return OM_E_NODYNMEM;
}

/*
 * This function is written.....mainly for the SPX. Later this would
 * disappear and the functionality would be integrated in the State Table.
 * CR179901852. Alwin
 *
 * It constructs a PPL object, which would enable the user to locate a PIPING
 * Component or PIPING Nozzle. The object Id is returned as the output to the 
 * Calling funtion.
 */

IGRlong VRCopyPipeParams( IGRlong *msg, struct GRid *PipeId )
{
    TGRid     pplID ;
    IGRint    pplRET ; 
    IGRint	  objid, osnum;

    SetProc( Fn VRCopyDuctParams ); Begin

    *msg = MSFAIL ;

    /* Load ppl */

    __DBGpr_com( " PPL is going to be loaded ");
    vdppl$Load(name = "COz_LocDuct", pplID = &pplID);

    if (pplID.objid != NULL_OBJID)
	{
	  __DBGpr_com( " PPL is loaded ");
	  vdppl$Run( pplID = &pplID, name = "getPipeObject", ret = &pplRET );

	  if( !pplRET & MSSUCC ) return (*msg );

	  vdppl$GetData(
		  pplID = &pplID,
		  name  = "objid",
		  size  = sizeof(int),
		  data  = (IGRchar*) &objid );

	  vdppl$GetData(
		  pplID = &pplID,
		  name  = "osnum",
		  size  = sizeof(int),
		  data  = (IGRchar*) &osnum );

	  vdppl$Delete(pplID = &pplID);

	  *msg = MSSUCC;
	  PipeId->objid = objid;
	  PipeId->osnum = osnum;
	  __DBGpr_obj( " Located Object Id ", *PipeId );
	  objid = -1;
	  osnum = 0;
	}

	End
	return *msg;
}

/*
 * This function is written.....mainly to display the information on to the
 * Pipe Line Params Form.  Given the System Collector, this would display all
 * the relevant attributes on the form.
 *
 * The function is written in a generic fashion, so that this can made use
 * by the other disciplines also.
 * CR179901852. Alwin
 */
#include "VRNozzleForm.h"
IGRlong VRFillUpNozzleAttrForm( Form form_ptr, IGRshort Product, 
				    struct GRid SysId )
{
    IGRlong	msg, status = OM_S_SUCCESS;
    IGRint	i;
    IGRint	nb_of_attributes, SelFlag, r_pos;
    IGRchar	txt[9], name[2],  Name[VR_MAX_CHAR];

    struct GRid		CollectId,TempCollectId;
    struct ACrg_coll	attributes[VR_MAX_ATTR];

    SetProc( Fn VRFillUpPipeLineParamsForm ); Begin 

    if( form_ptr == NULL ) { End; return OM_E_INVARG; }

    strcpy( name, " ");
    status = om$send( msg      = message ACrg_collect.AClist_attribute
		  ( &msg, VR_MAX_ATTR, attributes, &nb_of_attributes ),
		      senderid = NULL_OBJID,
		      targetid = SysId.objid,
		      targetos = SysId.osnum );
    as$status( action = RET_STATUS ) ;

    if( Product == VR_PIPING )
    {
	for( i=0; i<nb_of_attributes; i++ )
	{
	    if( !strcmp( attributes[i].name, VR_N_CLASS_AN ))
	      FIfld_set_text( form_ptr, SPEC_NAME, 0, 0,
			       attributes[i].desc.value.att_txt, FALSE);
	     
	    if( !strcmp( attributes[i].name, VR_N_SYST_NAME_AN))
		    FIfld_set_text( form_ptr, SYSTEM_NAME, 0, 0,
			    attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_SEQ_NUMBER_AN))
		    FIfld_set_text( form_ptr, SEQ_NUMBER, 0, 0,
			    attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_FLUID_CODE_AN ))
		    FIfld_set_text( form_ptr,FLUID, 0, 0,
				    attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_ZONE_AN ) )
		    FIfld_set_text( form_ptr, ZONE_NB, 0, 0,
			  attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_THICK_OVER_AN))
		     FIfld_set_text( form_ptr, SCHDL_THK_OVRD, 0, 0,
			   attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp(attributes[i].name, VR_N_INSUL_TYPE_AN) )
		FIfld_set_text( form_ptr, INSUL_TYPE, 0, 0,
			     attributes[i].desc.value.att_txt, FALSE);

	    // Need to convert to string before setting it on the form
	    if( !strcmp(attributes[i].name, VR_N_INSUL_THK_DB) )
	    {
		IGRchar szThicknessText[10];

		szThicknessText[0] = '\0';
		sprintf(szThicknessText,"%g",attributes[i].desc.value.att_exp );
		FIfld_set_text( form_ptr, INSUL_THIK, 0, 0, 
				szThicknessText, FALSE);
	    }

	    /***
	    if( !strcmp(attributes[i].name, VR_N_INSUL_THK_DB) )
		FIfld_set_value( form_ptr, INSUL_THIK, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);
	    ***/

	    if( !strcmp( attributes[i].name, VR_N_TRACING_CODE_AN ) )
		  FIfld_set_text( form_ptr, TRACING_TYPE, 0, 0,
				      attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_PAINT_CODE_AN ))
		    FIfld_set_text( form_ptr, PAINT_TYPE, 0, 0,
				    attributes[i].desc.value.att_txt, FALSE);

            if( !strcmp( attributes[i].name, VR_N_UNIT_AN ))
                     FIg_set_text( form_ptr, NOZ_UNIT_NUMBER,
                             attributes[i].desc.value.att_txt );

	    if( !strcmp( attributes[i].name, VR_N_OPER_TEMP_DB ) )
		    FIfld_set_value( form_ptr, OPER_TEMP, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_OPER_PRESS_DB ) )
		    FIfld_set_value( form_ptr, OPER_PRESSURE, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_DGN_TEMP_DB ) )
		    FIfld_set_value( form_ptr, DGN_TEMP, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_DGN_PRESS_DB ) )
		    FIfld_set_value( form_ptr, DGN_PRESS, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_SPEC_GRAV_DB))
		    FIfld_set_value( form_ptr, SPECIFIC_GRAV, 0, 0,
			    attributes[i].desc.value.att_exp, FALSE);

            if( !strcmp( attributes[i].name, VR_N_APPRV_STAT_AN))
                     FIfld_set_text( form_ptr, APPRO_STS, 0, 0,
                             attributes[i].desc.value.att_txt, FALSE);

            if( !strcmp( attributes[i].name, VR_N_CONSTR_STAT_AN))
                     FIfld_set_text( form_ptr, CONSTR_STS, 0, 0,
                             attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_WEIGHT_GRP_IN ))
		  FIfld_set_text( form_ptr, WEIGHT_GRP, 0, 0,
				     attributes[i].desc.value.att_txt, FALSE);

	    if( !strcmp( attributes[i].name, VR_N_CHG_REQ_NUM_IN))
		FIfld_set_text( form_ptr, CHANGE_NO, 0, 0,
			    attributes[i].desc.value.att_txt, FALSE);
	}
    }

    End
    return status;
}


/* Below function implements the key-in filter ("search capability") for fields
 * in forms whose associative lists have items from a product's codelist table.
 * Implemented by Anand for ETL 3825 (covers 6 CRs - e.g., CR 179902072-74) */


IGRint VRkeyFltrInCDLdbFlds( IGRshort Product, IGRshort ListNum, Form FormPtr,
			     IGRint GadgetLbl, IGRuchar FldTxt[] )
{
/* Do not initialise pointers CodeList and CodeNum to NULL! Do NOT free them! */
    IGRshort	ListSize=0, *CodeNum;
    IGRint	status, NewListCnt=0, SelIndex=-1, UniqueFlg=0;
    IGRlong	retmsg;
    IGRchar	*CodeList;
/* Do not initialise pointers CodeList and CodeNum to NULL! Do NOT free them! */

    SetProc( VRkeyFltrInCDLdbFlds ); Begin

    if( ! FldTxt )
    {
	__DBGpr_com(" FldTxt is NULL!!!!");
	End
	return OM_E_INVARG;
    }

    status = VRget_code_list_set( &retmsg, Product, ListNum, &ListSize,
				  &CodeList, &CodeNum, NULL);
    CheckRC( status, retmsg );
    as$status( action = RET_STATUS );
    as$status( action = RET_STATUS , sts = retmsg );
    __DBGpr_int(" Number of entries in codelist table", ListSize);

#ifdef vdsDEBUG
    {
	int i;
	printf(" list size %d\n",ListSize);
	for(i=0;i<ListSize;i++)
	printf("Codelist %d %d <%s>\n",
			   i+1,CodeNum[i],&CodeList[i*VR_SHORT_CODETEXT_SIZE]);
    }
#endif

    /* Make sure that the list is kept sorted */
    qsort( (void *)CodeList,
	    ListSize,
	    VR_SHORT_CODETEXT_SIZE*sizeof(IGRchar),
	    strcmp );

    /* Filter the DB ( Original ) Code list as needed for the user */
    status = VDfrm_fld_set_sub_list( FormPtr, GadgetLbl, MESSAGE, CodeList,
				     VR_SHORT_CODETEXT_SIZE, ListSize,
				     &NewListCnt, 0, &SelIndex, &UniqueFlg );

    __DBGpr_int(" Unique Flag ", UniqueFlg );
    __DBGpr_int(" Number of items in the new list ", NewListCnt );

    if( NewListCnt==1 || UniqueFlg )
	FIfld_get_text( FormPtr, GadgetLbl, 0, 0, MAX_FIELD, FldTxt,
							&SelIndex, &SelIndex );
    else
	FldTxt[0]='\0';
    __DBGpr_str(" Short text in field",FldTxt);

    End
    return status;
}

end implementation Root;


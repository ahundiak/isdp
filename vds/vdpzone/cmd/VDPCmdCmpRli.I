/* $Id */

/* ----------------------------------------------------------------------------
 * I/VDS
 * 
 * File :	vds/vdpzone/cmd/VDPCmdCmpRli.I
 *
 * Description:
 *	Implementation of the following methods.
 *		my_init
 *		locate_comp
 *		post_comp_reln
 *
 * Dependencies:
 *
 * History:
 *
 *	1/28/95		MSM		Creation
 *	09/18/96	msm		Command not executed if PME is not 
 *					enabled.
 *	10/03/96	msm		Command displays an error message if
 *					file is frozen or revised.
 *      10/09/96        msm             Post Compartment relation even if the
 *					compartment membership is empty.
 * 	10/11/96	msm		fix TR#179603235
 *      11/05/96	Ravi		Corrected the argument list for
 *					the call VDPmeCheckin().
 *
 * --------------------------------------------------------------------------*/

class implementation VDPCmdCmpRl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"
#include "execmsg.h"

#include "dpdef.h"
#include "dpmacros.h"

#include "vdrefmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vdsetmacros.h"		/* for vd$filter_objects */
#include "coparamac.h"			/* for as$start_dence */

#include "VDCmdDef.h"
#include "VDPdef.h"
#include "VDPdm2.h"
#include "VDPzone.h"

from NDmacro import	ACreturn_foot;
from SMmgr import	SMGetAttDbl;
/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  my_init ( long * sts )
{
    OMuword     curOs;
    IGRint      fileState=0;
    IGRlong     msg = MSSUCC, status = OM_S_SUCCESS;
    IGRchar     errmsg[256];

    SetProc( VDPCmdCmpRl.my_init ); Begin

    *sts = VD_SUCCESS;
    if( IsPmeEnabled() == FALSE )
    {
	UI_status("PME server connection required");
	*sts = VD_ERROR;
	me->state = _terminate;
	goto wrapup;
    }

    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetFileState( &msg, curOs, &fileState );
    if( !(status & 1))
    {
	*sts = VD_ERROR;
	me->state = _terminate;
	goto wrapup;
    }

    if( fileState == VDP_FILE_REVISED )
    {
        strcpy(errmsg,"The current design file is revised in PME. It should also be revised in PDU. ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
        *sts = VD_ERROR;
        me->state = _terminate;
    }
    else if( fileState == VDP_FILE_FROZEN )
    {
        strcpy(errmsg,"The current design file is frozen in PME. It should be revised before further executing PME commands ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
        *sts = VD_ERROR;
        me->state = _terminate;
    }

wrapup:
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message locate_comp

  Abstract
	This method locates a compartment

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/
method locate_comp( long	*sts )
{
    SetProc (VDPCmdCmpRl.locate_comp ); Begin

    *sts = VD_SUCCESS;

    me->comp_id = me->event1.located_object[0].located_obj;

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message post_comp_reln

  Abstract
	This method posts the compartment-item relations.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method post_comp_reln( long	*sts )
{
    IGRlong		msg = 1,
			status = OM_S_SUCCESS;
    struct GRid		Solid;
    IGRint		i=0,nbLocObjs=0, nb_os = 0;
    IGRdouble		val=0;
    IGRchar		filename[20];
    struct GRobj_env	*LocObjs=NULL;
    struct GRmd_env	md_env;
    GRspacenum          *os_list = NULL;
    struct GRmd_env     *env_list = NULL;
    IGRboolean          TrSav=FALSE;


    SetProc (VDPCmdCmpRl.post_comp_reln); Begin
    *sts = VD_SUCCESS;
    
    /* Verify if the compartment is PME enabled or not */

    status = _VD_SEND_OBJ ( me->comp_id, SMmgr.SMGetAttDbl 
					( &msg,
					  "pme_enabled",
					  &val,
					  (IGRshort *)NULL));
    __DBGpr_dbl( "PME enabled", val );

    if( val > 1.001 || val < 0.999 )
    {
	UI_status ( "Compartment not recognised by PME" );
	goto wrapup;
    }
    __CheckRC( status, msg, "SMmgr.SMGetAttDbl", wrapup );

    status = VDSget_filename( filename );

    status = ex$save_module( ftype = EX_visible, filename = &filename[1] );
    /*__CheckRC ( status, 1, "ex$save_module", wrapup ); */

    UI_status ( "Posting Objects to the PME database " );
    status = VDPmeCheckin( &msg, TrSav );

    if ( ! (status & 1) )
	UI_status ("Regular posting failed" );

    /*  regular posting failed but continue
	__CheckRC ( status, msg, "VDPmeCheckin", wrapup ); */


    /* get the solid foot of the compartment */

    status = _VD_SEND_OBJ ( me->comp_id, NDmacro.ACreturn_foot 
					( &msg,
					  "sol",
					  &Solid,
					  &md_env.md_env.matrix_type,
					  md_env.md_env.matrix ));
    __CheckRC( status, msg, "NDmacro.ACreturn_foot", wrapup );

    __DBGpr_obj ("Boolean Obj", Solid );

    /* Get the compartment's md_env; ACreturn_foot always returns an identity
     * matrix. It is incorrect. We can work arounf by getting reference file's
     * osnum.
     */

     status = vd$get_ref_os_list ( msg 		= &msg,
				   main_os 	= &me->ModuleInfo.md_id.osnum,
				   num_ref_os 	= &nb_os,
				   ref_os_list  = &os_list,
				   ref_env_list = &env_list );
    i = 0;
    if ( nb_os > 0 )
    {
       while ( i < nb_os && Solid.osnum != os_list[i] )
	   i++;
       __DBGpr_int ( "Osnum ", os_list[i] ); 
       __DBGpr_mat ("Mod Env Mat: ", env_list[i].md_env.matrix );
    }
    if ( i < nb_os )
	md_env = env_list[i]; 

    /* Get all the objects contained in the compartment */
    status = VDSelectElementsinVolume (	&msg,
					Solid,
					VDP_3D_ZONE,
					0.0,
					/*&me->window_id, */
					NULL,
					my_id,
					&me->located_chansel,
					md_env,
					&nbLocObjs,
					&LocObjs );

    __DBGpr_int( "Number of Elements in Compartment ", nbLocObjs );

    if ( ! (status & 1) )
	UI_status ("Failed getting elements in Volume" );
    __CheckRC( status, msg, "VDSelectElementsinVolume", wrapup );

    for ( i=0; i < nbLocObjs; i++ )
	__DBGpr_obj ( "Obj Id ", LocObjs[i].obj_id );

    /* Post the compartment-Item relationship */
	status = VDPpostSpatialRelnship (&msg,
					 VDPTCOMPARTMENT_CODE,
					 me->comp_id,
					 nbLocObjs,
					 LocObjs );
	if ( ! (status & 1) )
	    UI_status ("Posting Compartment relationship failed" );
	__CheckRC( status, msg, "VDPpostSpatialRelnship", wrapup );

    dp$erase_hilite( msg = &msg );

wrapup:
    if( !(status & msg & 1))
	*sts=VD_ERROR;
    _FREE ( LocObjs );
    if( os_list ) free( os_list );  /* I am using free because it is allocated 
				     * using malloc. Needs to be changed later
				     * to _FREE & _MALLOC .
				     */
    if( env_list ) free( env_list );
    End
    return OM_S_SUCCESS;
}

end implementation VDPCmdCmpRl;

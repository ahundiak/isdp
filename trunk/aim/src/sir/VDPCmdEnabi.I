/* $Id: VDPCmdEnabi.I,v 1.1.1.1 2001/06/01 20:06:27 tlstalli Exp $ */

/* ----------------------------------------------------------------------------
 * I/AIMSIR
 * 
 * File :	aim/src/sir/VDPCmdEnabi.I
 *
 * Description:
 *	Implementation of the following methods.
 *		my_init
 *		VDPEnableItems
 *		VDPLocateObjects
 *
 * Dependencies:
 *
 * History:
 *
 *	12/10/95	MSM		Creation
 *	09/19/96	MSM		Command not executed if PME is not 
 *					enabled
 *	10/03/96	msm		Command not executed if file is frozen
 *					or revised.
 *    Jan 09 1998	SSR		TR # 179702659 Added VDPLocate1Obj
 *    Apr 12 1998	SSR		TR # 179800701 addeed vd$filter_objects
 *    Aug 07 1998   SSR     Modified methods for SIR VDPlocate1Obj, VDPLocateObjects
 *                          my_init.
 *    Sep 24 1998   SSR     TR # 179801647 Disallowed enabling of Nozzles
 *                          CCB and Avondale requirements. Shaould be removed
 *                          When requested afterwards.
 * --------------------------------------------------------------------------*/

class implementation VDPCmdEnab;


/*#define vaimDEBUG
#define vaimerrDEBUG*/


#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "execmsg.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "vdsetmacros.h"		/* for vd$filter_objects */
#include "coparamac.h"			/* for as$start_dence */
#include "VDPdm2.h"

#include "VDCmdDef.h"

#include "VDPdef.h"

extern GRclassid	OPP_SMcomp_class_id;

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
    OMuword	curOs;
    IGRint	fileState=0;
    IGRlong	msg = MSSUCC, status = OM_S_SUCCESS;
    IGRchar	errmsg[256];
    char	ReqName[DI_PATH_MAX];
    char	DirName[DI_PATH_MAX];
    struct GRid	Buf;

    SetProc( VDPCmdEnab.my_init ); Begin

    *sts = VD_SUCCESS;
    if( IsPmeEnabled() == FALSE )
    {
        UI_status("AIM server connection required");
        *sts = VD_ERROR;
        me->state = _terminate;
	goto wrapup;
    }
    if( WhichAim( ) == PME ){
    ex$get_cur_mod( osnum = &curOs );

    status = VDPGetFileState( &msg, curOs, &fileState );
    __CheckRC( status, msg, "VDPGetFileState", wrapup );
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
    }


    if( WhichAim( ) == SIR )
    {
      ex$get_cur_mod( osnum = &curOs );

     /* get directory path name */
      status = di$give_pathname( osnum           = curOs,
	  pathname        = DirName );
      CheckRC( status, 1 ); 
      
      sprintf( ReqName,"%s%s%s", DirName,
	  SIR_GLOBAL_DIR, SIR_REQ_DATA );
      status = di$translate( objname = ReqName,
	  p_objid = &Buf.objid,
	  p_osnum = &Buf.osnum ); 
      
      if( status != DIR_S_SUCCESS )
      {
	UI_status ( " Default AIM Data not set." );
	*sts = VD_ERROR;
	me->state = _terminate;
      } 
    }
wrapup:
    if( !(status & msg & 1))
    {
	*sts = VD_ERROR;
	me->state = _terminate;
    }
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPLocateObjects

  Abstract
	This method locates all the eligible objects

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/
method VDPLocateObjects( long	*sts )
{
    IGRint		i,j,
			nbObjs = 0;
    IGRlong		msg = 1,
			status = OM_S_SUCCESS;

    struct GRid		setId;
    struct GRmd_env	setEnv;
    struct GRobj_env	*listObjs = NULL;
    GRclassid		obj_class;
    char		class_name[80];

    SetProc (VDPCmdEnab.VDPLocateObjects); Begin
    *sts = VD_SUCCESS;

    /* make graphic set, if necessary */

    status = 
    VD_MakeGRsetOfObject(       &msg,
				&me->ModuleInfo,
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				&setId,
				&setEnv,
				0 );

    __CheckRC( status, msg, "VD_MakeGRsetOfObject", wrapup );
    /* eliminate dangles, header, row, check for ownership of located objects */

    status =
    vd$filter_objects(  msg     = &msg,
			setId   = &setId );
    __CheckRC( status, msg, "vd$filter_objects", wrapup );

    status =
    as$start_fence(     set             = &setId,
                        set_env         = &setEnv,
                        nb_obj          = &nbObjs,
                        p_obj_env       = &listObjs,
                        response        = me->response,
                        response_data   = me->response_data );

    __DBGpr_int( "No of objects located", nbObjs );

    __CheckRC( status, 1, "as$start_fence", wrapup );

    if( !nbObjs )
    {
        *sts = VD_RESTART_CMD;
        goto wrapup;
    }

    /* Verify if a compartment is selected */

    for ( i =0; i < nbObjs; i++ )
    {
	status = om$get_classid( objid 	   = listObjs[i].obj_id.objid,
				 osnum     = listObjs[i].obj_id.osnum,
				 p_classid =  &obj_class );
	if (status&1)
	{
	    if( om$is_ancestry_valid ( subclassid = obj_class,
			superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS )
	    { 
		UI_status ( " Cannot AIM Enable Compartments ");
	        for ( j = i; j < nbObjs -1; j++ )
		    listObjs[j] = listObjs[j+1];
	  	nbObjs--;
	    }
	}
    }

    if( WhichAim( ) == SIR ){
    for( i = 0; i < nbObjs; i ++ )
    {
       __DBGpr_int("listObjs[i].obj_id.objid ", listObjs[i].obj_id.objid);
       status = om$get_classname(objid = listObjs[i].obj_id.objid,
				osnum = listObjs[i].obj_id.osnum,
				classname = class_name );

       if (status&1)
       {
	  __DBGpr_int("listObjs[i].obj_id.objid ", listObjs[i].obj_id.objid);
	  __DBGpr_str( " class_name ", class_name);

	  if(  class_name[1] == 'S'  )
          {
              UI_status ( " Cannot Enable Plates, Beams, Stiffners. ");
	        for ( j = i; j < nbObjs -1; j++ )
		    listObjs[j] = listObjs[j+1];
	  	nbObjs--;
		i = 0;
          }
        if(  !(strcmp(class_name, "VRPNozz") ) ) // Temporarily added Refer TR # 179801647
         {
           UI_status ( " Cannot Enable Nozzles. ");
           for ( j = i; j < nbObjs -1; j++ )
            listObjs[j] = listObjs[j+1];
           nbObjs--;
           i = 0;
         }

	  __DBGpr_int( " nbObjs ", nbObjs);

       }

    }
    }   // End SIR
    if ( nbObjs )
    {
	status = om$vla_set_dimension(  varray  = me->locObjs,
					size    = nbObjs );
	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    }

    for( i = 0; i < nbObjs; i++ )
	me->locObjs[i] = listObjs[i];

wrapup :
    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status ("Error encountered : command terminated" );
    }
    ASend_fence();

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPLocate1Obj

  Abstract
        This method locates one object at a time.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method VDPLocate1Obj( long   *sts )
{
    IGRlong             msg = 1,
                        status = OM_S_SUCCESS;
    struct GRobj_env    *listObjs = NULL ;
    struct GRobj_env    *olistObjs = NULL ;
    GRclassid           obj_class;
    int			outCount = 0;
    char		class_name[80];

    SetProc (VDPCmdEnab.VDPLocate1Obj ); Begin
    *sts = VD_SUCCESS;


        listObjs = _MALLOC(1, struct GRobj_env);
        listObjs->obj_id = me->event1.located_object[0].located_obj;
        listObjs->mod_env = me->event1.located_object[0].module_info;

        olistObjs = _MALLOC(1, struct GRobj_env);
        // SSR added filter_objects for TR # 179800701
    status =
    vd$filter_objects(  msg     = &msg,
			iCount  = 1,
			iList   = listObjs,
			oCount  = &outCount,
			oList   = &olistObjs);
    __CheckRC( status, msg, "vd$filter_objects", wrapup );

	  // Check whether compartment is selected
        // If selected don't allow to PME enable

        status = om$get_classid(objid = olistObjs[0].obj_id.objid,
                            osnum     = olistObjs[0].obj_id.osnum,
                            p_classid =  &obj_class );
        if (status&1)
        {
            if( om$is_ancestry_valid ( subclassid = obj_class,
                        superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS )
            {
                UI_status ( " Cannot PME Enable Compartments ");
                *sts = VD_ERROR;
	
			vd_$bulk_display(dpmode	= GRhe,
				  count	= 1,
				objenvs	= olistObjs );
                goto wrapup;
            }
        }

	if( WhichAim( ) == SIR )
	{
	  status = om$get_classname(objid = olistObjs[0].obj_id.objid,
				osnum = olistObjs[0].obj_id.osnum,
				classname = class_name );

        if (status&1)
	{
	  if(  class_name[1] == 'S'  )
          {
              UI_status ( " Cannot AIM Enable Plates, Beams, Stiffners ");
              *sts = VD_ERROR;
	
		vd_$bulk_display(dpmode	= GRhe,
				  count	= 1,
				objenvs	= olistObjs );
              goto wrapup;
          }
        
		if(  !strcmp(class_name,"VRPNozz")  ) // Temporarily added refer TR # 179801647
        {
          UI_status ( " Cannot AIM Enable Nozzles");
          *sts = VD_ERROR;

          vd_$bulk_display(dpmode	= GRhe,
                           count	= 1,
                           objenvs	= olistObjs );
          goto wrapup;
        } // end vrpnozz

	}

	}
	if( outCount )
        {
	   status = om$vla_set_dimension(  varray  = me->locObjs,
                                        size    = 1 );
           __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
           me->locObjs[0] = olistObjs[0];
	}
	
	else
        {
        UI_status ( " Cannot AIM Enable This Item " );
        }

wrapup:
    _FREE(listObjs);
    _FREE(olistObjs);
    if( !(status & msg & 1) )
        {
            *sts = VD_ERROR;
            UI_status ("Error encountered : command terminated" );
        }
    End
    return OM_S_SUCCESS;
}



/*+me
 ---------------------------------------------------------------------------
  Public Message VDPEnableItems

  Abstract
	This method enables all the located objects

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/
method VDPEnableItems( long	*sts )
{
    IGRlong		msg = 1,
			status = OM_S_SUCCESS;
    IGRint		i,
			size;

    SetProc (VDPCmdEnab.VDPLocateObjects); Begin
    *sts = VD_SUCCESS;

    /* find out if the Object can be enabled or not */

    /* Enable the item */
    size = om$dimension_of ( varray = me->locObjs );

    for ( i = 0; i < size; i++ )
	status = VDPPmeEnable( &msg, me->locObjs[i].obj_id, NULL);

    /* Add it to the transaction List */

    End
    return status;
}

end implementation VDPCmdEnab;

/* $Id: VDdrwSeti.I,v 1.6 2002/05/15 22:36:26 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/set / VDdrwSetOver.I
 *
 * Description:
 *	Implementation of methods
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/22/95	R. Manem	Added VDemptySet method
 *	09/18/95	R. Manem	Check for NULL footId, to return
 *					correct number of elements in set
 *	07/18/00	Ming		TR179901793
 *	08/24/00	Ming		TR179901284
 *	05/15/02	ylong		TR6353
 * -------------------------------------------------------------------------
 */

class implementation VDdrwSet;

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "EMSmsgdef.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "nddef.h"
#include "batch.h"

#include "asbox.h"
#include "asmacros.h"

extern struct ext_list NDdelete;

/*+me
 -------------------------------------------------------------------------
  Public Message VDinitSet

  Abstract
        This method does initialization : make myself non-locatable

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDinitSet(   IGRlong         *msg )
{
    IGRshort		action = 0,
			mask;
    IGRlong 		status = OM_S_SUCCESS;

    SetProc( VDdrwSet.VDinitSet ) ; Begin

    *msg = MSSUCC;

    mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

    status =
    _VD_SEND_MY( GRgraphics.GRchgprops(	msg, &action, &mask ) );

    CheckRC( status, *msg );

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetSetObjects

  Abstract
        This method returns the set objects.

  Arguments
        IGRlong                 *msg      O     Return code
        IGRint                  *nbObjs   O     Number of objects
        struct GRobj_env        *list     O     List of obj envs.

  Notes/Remarks
        NULL could be used to suppress output
        Memory for list must be allocated by caller.
        The GRids returned will be of the actual object, not the source object

  Status/Return Code
      status == OM_S_SUCCESS    if success;
		OM_E_NODYNMEM   if no memory
 ---------------------------------------------------------------------------
-me*/

method VDgetSetObjects( IGRlong                 *msg;
                        IGRint                  *nbObjs;
                        struct GRobj_env        *list )


{
    IGRint		i, j,
			count = 0;
    IGRshort		matType;
    IGRmatrix           mat;
    struct GRid		*buffer,
			footId;
    IGRlong 		status = OM_S_SUCCESS;
    OM_S_OBJID		mdId;

    SetProc( VDdrwSet.VDgetSetObjects ) ; Begin

    *msg = MSSUCC;

    if( !nbObjs && !list )
        goto wrapup;

    *nbObjs = 0 ;

    /* get the parents */

    status =
    _VD_SEND_MY( NDnode.NDget_objects( 	ND_ROOT | ND_IN_BUF,
					NULL,
					0,
					&buffer,
					0,
					OM_K_MAXINT,
					&count ) );
    __CheckRC( status, 1, "message NDnode.NDget_objects", wrapup );

    if( !list )
    {
	*nbObjs = count;
        goto wrapup;
    }
    else
	*nbObjs = 0;

    __DBGpr_com( "List of parents (source objects)");
    __DBGpr_objlist( "", count, buffer );

    /* 
     * for each object,
     *          do ACreturn_foot to get actual object 
     *          update the output list
     */

    /* get the current module id */

    status = ex$get_modid(	mod_osnum	= OM_Gw_current_OS,
				mod_id		= &mdId );
    CheckRC( status, *msg );

    for( i = 0 ; i < count ; i++ )
    {
        __DBGpr_int( "i", i);

	footId.objid = NULL_OBJID;

        status =
        _VD_SEND_OBJ( buffer[i], NDmacro.ACreturn_foot( msg,
							"",
							&footId,
							&matType,
							mat ) );
        CheckRC( status, *msg );
        __DBGpr_obj( "Foot Id", footId );


        if( !(status & *msg & 1) || footId.objid == NULL_OBJID )
	    continue;

	/* check if object is in delete batch or not */

	if( NDin_buffer( footId, &NDdelete ) != -1 )
	{
	    __DBGpr_com( "\tObject is in delete batch" );
	    continue;
	}

        list[*nbObjs]._grid = footId;
        list[*nbObjs]._md_os = footId.osnum;
        list[*nbObjs]._md_id = mdId;
        list[*nbObjs]._matrix_type = matType;

        for( j = 0 ; j < 16 ; j++ )
            list[*nbObjs]._matrix[j] = mat[j];

	(*nbObjs)++;
    }

    __DBGpr_int( "Actual number of objects", *nbObjs );

wrapup :

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddObjectsToSet

  Abstract
        This method adds objects, ie, connects the new objects as parents.
        Checks for duplication before adding

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          nbObjs    I     Number of objects to add to set
        struct GRid     *list     I     List of objects to add

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
		OM_E_NODYNMEM   if no memory
 ---------------------------------------------------------------------------
-me*/

method  VDaddObjectsToSet(      IGRlong         *msg;
                                IGRint          nbObjs;
                                struct GRid     *list )
{
    IGRint              i;
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         *roots = NULL,
			modObj,
                        ctxId;
    struct GRmd_env	modEnv;

    SetProc( VDdrwSet.VDaddObjectsToSet ) ; Begin

    __DBGpr_me();
    __DBGpr_int( "Number of objects ", nbObjs );

    *msg = MSSUCC;

    if( !nbObjs )
        goto wrapup;

    /* allocate space for roots */

    roots = _MALLOC( nbObjs, struct GRid );
    if( !roots )
        vd_$mem_fail( sts = status );

    for( i = 0 ; i < nbObjs ; i++ )
    {
        __DBGpr_int( "i", i );
        __DBGpr_obj( "list", list[i] );

        /* make source */

	if( list[i].osnum == OM_Gw_current_OS )
	{
              ctxId = NULL_GRID;
	}
        else
        {
              status = GRfindcontext(msg, NULL, NULL, &list[i].osnum, &ctxId );
              CheckRC( status, 1 );

            /* Modified by Ming for TR179901793 */
            if( !(status & *msg & 1) )
            {
                ctxId = NULL_GRID;
                status = OM_S_SUCCESS;
                *msg = MSSUCC;
            }
        }

        __DBGpr_obj( "Context grid ", ctxId );

        status =
        as$make_source (	go_grid         = list[i],
				context_grid    = ctxId,
				as_grid         = &roots[i] );

        __DBGpr_obj( "Source id ", roots[i] );
    }

    /* connect the objects as parents */

    __DBGpr_com( "Adding objects as parents" );

    status =
    _VD_SEND_MY( NDnode.NDconnect( nbObjs, roots, NULL_GRID, ND_ADD ));

    CheckRC( status, 1 );

wrapup:

    _FREE( roots );

    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDdeleteObjectsFromSet

  Abstract
        This method deletes objects, ie, disconnects them

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          nbObjs    I     Number of objects to delete from set
        struct GRid     *list     I     List of objects to delete

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
		OM_E_NODYNMEM   if no memory
 ---------------------------------------------------------------------------
-me*/

method  VDdeleteObjectsFromSet( IGRlong         *msg;
                                IGRint          nbObjs;
                                struct GRid     *list )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;
    struct GRid		*roots = NULL,
			modObj,
			ctxId;
    struct GRmd_env	modEnv;

    SetProc( VDdrwSet.VDdeleteObjectsFromSet ) ; Begin

    __DBGpr_me();
    __DBGpr_int( "Number of objects ", nbObjs );

    *msg = MSSUCC;

    if( !nbObjs )
        goto wrapup;

    /* allocate space for roots */

    roots = _MALLOC( nbObjs, struct GRid );
    if( !roots )
        vd_$mem_fail( sts = status );
    
    for( i = 0 ; i < nbObjs ; i++ )
    {
        __DBGpr_int( "i", i );

        /* make source */

	if( list[i].osnum == OM_Gw_current_OS )
	{
              ctxId = NULL_GRID;
	}
        else
        {
              status = GRfindcontext(msg, NULL, NULL, &list[i].osnum, &ctxId );
              CheckRC( status, 1 );

              /* Modified by Ming for TR179901793 */
              if( !(status & *msg & 1) )
              {
                ctxId = NULL_GRID;
                status = OM_S_SUCCESS;
                *msg = MSSUCC;
              }
        }

        __DBGpr_obj( "Context grid ", ctxId );

        status =
        as$make_source (	go_grid         = list[i],
				context_grid    = ctxId,
				as_grid         = &roots[i] );

        __DBGpr_obj( "Source id ", roots[i] );
    }

    /* disconnect all the objects */

    __DBGpr_com( "Disconnecting all objects" );

    status =
    _VD_SEND_MY( NDnode.NDdisconnect( nbObjs, roots ));

    CheckRC( status, 1 );
    
wrapup:

    _FREE( roots );

    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDdeleteSet

  Abstract
        This message deletes the set

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDdeleteSet( IGRlong    *msg )
{
    IGRint		size = sizeof( struct GRmd_env );
    struct GRmd_env	mod_env;
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwSet.VDdeleteSet ) ; Begin

    __DBGpr_me();

    *msg = MSSUCC;

    /* get current module environment */

    status =
    gr$get_module_env(	msg	= msg,
			sizbuf	= &size,
			buffer	= &mod_env );
    CheckRC( status, *msg );
    
    /* send GRdelete to myself */

    status =
    _VD_SEND_MY( VDdrwSet.GRdelete( msg, &mod_env ));
    CheckRC( status, *msg );

    End

    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDemptySet

  Abstract
        This message empties the set (without deleting itself)

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

method  VDemptySet( IGRlong    *msg )
{
    IGRint		i, 
			nbObjs;
    IGRlong		status = OM_S_SUCCESS;
    struct GRobj_env	*list = NULL;
    struct GRid		*pretend;

    SetProc( VDdrwSet.VDemptySet ); Begin

    *msg = MSSUCC;
    pretend = NULL;
    nbObjs = 0;

    /* get the parents */

    status =
    _VD_SEND_MY( NDnode.NDget_objects(  ND_ROOT | ND_IN_BUF,
                                        NULL,
                                        0,
                                        &pretend,
                                        0,
                                        OM_K_MAXINT,
                                        &nbObjs ) );
    __CheckRC( status, 1, "message NDnode.NDget_objects", wrapup );

    /* disconnect all the objects */

    __DBGpr_com( "Disconnecting all objects" );

    status =
    _VD_SEND_MY( NDnode.NDdisconnect( nbObjs, pretend ));

    CheckRC( status, 1 );

    /* commented by Ming for tr179901284
    * get number of objects in set *

    status =
    _VD_SEND_MY( VDdrwSet.VDgetSetObjects( msg, &nbObjs, NULL ) );
    __CheckRC( status, *msg, "VDdrwSet.VDgetSetObjects", wrapup );

    __DBGpr_int( "Number of objects in set", nbObjs );

    if( !nbObjs )
	goto wrapup;

    * allocate memory *

    list = _MALLOC( nbObjs, struct GRobj_env );
    if( !list )
	vd_$mem_fail( sts = status );

    * get the list of objects *

    status =
    _VD_SEND_MY( VDdrwSet.VDgetSetObjects( msg, &nbObjs, list ) );
    __CheckRC( status, *msg, "VDdrwSet.VDgetSetObjects", wrapup );

    * delete the set objects *

    for( i = 0 ; i < nbObjs ; i++ )
    {
	__DBGpr_obj( "Deleting set object", list[i].obj_id );

	status = _VD_SEND_MY( VDdrwSet.VDdeleteObjectsFromSet( 	msg, 1, 
							&list[i].obj_id ) );
    }
    */
	
wrapup :

    _FREE( list );
    End
    return status;
}

end implementation VDdrwSet;


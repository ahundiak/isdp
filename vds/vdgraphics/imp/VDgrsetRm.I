/* I/VDS
 *
 * File:         ~VDS/VDS--/.I
 *
 * Description:
 *      This file implements set functions used in I/VDS.
 *      its the implementation file for VDgrset.
 *
 * History:
 *      06/10/94        Chaya V. Rao
 *
 */
/*============================================================================*/

class implementation VDgrset;

#include <stdio.h>

#include "nddef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vdrefmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

extern struct GRid      VDsetmgr_grid;

from      NDnode     import     NDget_objects, ASreturn_go,
		  		NDdelete;

/*============================================================================*//* function VDset_count- This function returns the number of objects in a set.*//*============================================================================*/

int VDdel_setobjs(
struct GRid	  *set_grid,	/* i - GRid of set */
char		  *set_name,	/* i - name of set */
int		  numcomps,	/* i - number of objects to be removed from
					 set*/
struct GRobj_env  *set_objs	/* i - objects to be removed from set */
)
{
long			status, msg;
struct GRid		grid;
OM_S_CHANSELECT         GRcmpowner_to_connector_CS;
int                     val,
                        myind,
                        p, objcount;
OM_S_OBJECT_LINKAGE     *buffer = NULL;
IGRint                  size = sizeof( struct GRmd_env );
struct  GRmd_env        locEnv;
OMuint                  locomps;
IGRchar                 cname[100], prtname[100];
struct  GRid            *prtobjs = NULL, actobjs;
IGRshort                matrix_type;
IGRdouble               *matrix = NULL;
IGRboolean		found;
int			ii, nbObjRm;
struct GRobj_env	*rmList	= NULL ;
struct GRid		tmpobj;

	SetProc( VDdel_setobjs ); Begin

	val = 1;
	if ( numcomps == 0 ) goto wrapup;

	if ( !set_grid && !set_name ) { val = 0; goto wrapup; }
        if( !set_objs ) { val = 0; goto wrapup; }

        locomps = 0;
        grid.objid = NULL_OBJID;
	nbObjRm = 0 ;

	/*
	 * Allocate memory for internal list.
	 */
	rmList = (struct GRobj_env *) 
			malloc ( sizeof(struct GRobj_env) * (numcomps) );
	if ( !rmList ) { val = 0; goto wrapup; }

        status =
        gr$get_module_env(      msg     = & status,
                                sizbuf  = & size,
                                buffer  = & locEnv,
                                nret    = & size );
        
        status =
        om$make_chanselect( channame      = "GRcmpowner.to_components",
                            p_chanselect  = &GRcmpowner_to_connector_CS
                          );
        as$status();
/*
 * get the grid if it wasn't passed in
 */
	if ( !set_grid )
	{
	    status = om$send( msg = message VDgrset.VDName_to_id( &msg,
                                                                  set_name,
					                          &grid ),
			senderid = VDsetmgr_grid.objid,
			targetos = VDsetmgr_grid.osnum,
			p_chanselect = &GRcmpowner_to_connector_CS );
          }
          else{
             grid.objid = set_grid->objid;
             grid.osnum = set_grid->osnum;
          }

          if( grid.objid == NULL_OBJID ){ val = 0;  goto wrapup; }
/*
 * get the count
 */
	status = om$get_channel_count( objid = grid.objid,
	           		       osnum = grid.osnum,
				       p_chanselect = &GRcmpowner_to_connector_CS,
				       count = (OMuint *)&locomps );
	__DBGpr_int(" locomps ", locomps );

        if( locomps == 0 ) { val = 0 ; goto wrapup; }

        buffer = (OM_S_OBJECT_LINKAGE *) malloc
                 ( locomps * sizeof(OM_S_OBJECT_LINKAGE));
        if ( !buffer ) { val = 0; goto wrapup; }

        status =
        om$get_channel_objects (    osnum = grid.osnum,
                                    objid = grid.objid,
                                    p_chanselect = &GRcmpowner_to_connector_CS,
                                    list = buffer,
                                    size = locomps,
                                    count= (OMuint *)&locomps );
        as$status();

	__DBGpr_int("locomps ", locomps );

        for( myind = 0; myind < locomps; myind++ )
	{

	    status = om$get_classname(	osnum = buffer[myind].osnum,
					objid = buffer[myind].S_objid,
					classname =  prtname );

	    if ( om$is_ancestry_valid(	subclassname  = prtname,
					superclassname=  "VDpretendin")
                             != OM_S_SUCCESS )
		continue;

	     status =  om$send(msg = message NDnode.NDget_objects
                                           ( ND_ROOT | ND_IN_BUF,
                                             NULL,
                                             0,
                                             &prtobjs,
                                             0,
                                             OM_K_MAXINT,
                                             &objcount),
                                    senderid = NULL_OBJID,
                                    targetid = buffer[myind].S_objid,
                                    targetos = buffer[myind].osnum);

	     __DBGpr_int(" objCount ", objcount );

	     for( p = 0; p < objcount; p++ )
	     {
                 om$get_classname( osnum = prtobjs[p].osnum,
                                   objid = prtobjs[p].objid,
                                   classname = cname );

                 if ( om$is_ancestry_valid(subclassname  = cname,
                                           superclassname=  "ASsourcein")
                                == OM_S_SUCCESS
                      || om$is_ancestry_valid(subclassname  = cname,
                                              superclassname=  "ACpretendin")
                                == OM_S_SUCCESS  
                      || om$is_ancestry_valid(subclassname  = cname,
                                              superclassname=  "ACpretend")
                                == OM_S_SUCCESS  
                      || om$is_ancestry_valid(subclassname  = cname,
                                              superclassname=  "ASsource")
                                == OM_S_SUCCESS )
		    { 
                      status = om$send(msg = message NDnode.ASreturn_go(
                                                               &actobjs,
                                                               &matrix_type,
                                                               matrix),
                                     senderid= NULL_OBJID, 
                                     targetid= prtobjs[p].objid,
                                     targetos= prtobjs[p].osnum ) ;

		      tmpobj.objid = actobjs.objid;
		      tmpobj.osnum = actobjs.osnum;

		      /* check if the object in list to be removed.
		       * if yes remove form the list
		       */
		      found = FALSE;
		      for ( ii=0; ii<numcomps; ii++)
			  if (  set_objs[ii].obj_id.objid == tmpobj.objid &&
				set_objs[ii].obj_id.osnum == tmpobj.osnum   )
			  {
			    found = TRUE;
			    break;
			  }

		      if ( found )
		      {
			  rmList[nbObjRm].obj_id.objid = buffer[myind].S_objid;
			  rmList[nbObjRm].obj_id.osnum = buffer[myind].osnum;
			  rmList[nbObjRm].mod_env      = locEnv;
			  nbObjRm++;
		      }

                    } /* if sub class of ACsource etc */
	     }  /* for( p = 0; p < objcount; p++ ) */
        } /* for( myind = 0; myind < locomps; myind++ ) */

        if ( nbObjRm )
        {
		status =
		om$send(msg = message GRowner.GRremove_components(
                                                       &msg,
                                                       &locEnv,
                                                       &nbObjRm,
                                                       rmList ),
                    senderid = NULL_OBJID,
                    targetid = grid.objid,
                    targetos = grid.osnum );
		as$status();

		for( ii=0 ; ii<nbObjRm ; ii++ ){

		  __DBGpr_obj(" NDnode.NDdelete ", rmList[ii]._grid );

		  status =
		  om$send(msg = message NDnode.NDdelete( &rmList[ii].mod_env ),
			  senderid = rmList[ii]._objid,
			  targetid = rmList[ii]._objid,
			  targetos = rmList[ii]._osnum );

		}
	}

wrapup:

	if( buffer ) free( buffer );
	if ( rmList )  free ( rmList );

	End;
	return( val );
}

/*============================================================================*/

end implementation VDgrset;

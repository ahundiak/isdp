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
 *      05/01/95        R. Manem		Fixed TR 179525142
 *      02/29/96        Ravi                   Modified the function.
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
extern long  VDStrip_filename_from_setname();

from	NDnode		import	NDget_objects,
				ASreturn_go;

/*============================================================================*//* function VDset_count- This function returns the number of objects in a set.*//*============================================================================*/

int VDGive_setobjs( 
 struct GRid	*set_grid,	/* i - objid/osnum of created set */
 char		*set_name,	/* i - name of set to be constructed */
 struct GRmd_env *set_env,	/* i - set env. =NULL, active env is used */
 int		*numcomps,	/* o - number of objects to connect to the set*/
 struct GRid     *set_objs,     /* o - objects to connect to the set */
 struct GRobj_env *setobj_envs	/* o - objects and object environment */
)
{
long			status, msg,
                        rc;
struct GRid		grid;
OM_S_CHANSELECT         GRcmpowner_to_connector_CS;
int                     val, ii,
			fndInd ,
                        nbos, myind,
                        p, objcount;
OM_S_OBJECT_LINKAGE     *buffer = NULL;
GRspacenum              *oslist = NULL;
struct GRmd_env         *modenvlist = NULL;
OM_S_OBJID              super_id;
struct GRid             mgr_id;
IGRint                  size = sizeof( struct GRmd_env );
struct  GRmd_env        locEnv;
OMuint                  locomps;
IGRchar                 cname[100], prtname[100];
struct  GRid            *prtobjs = NULL, actobjs;
IGRshort                matrix_type;
IGRdouble               matrix[16];
char			set_text[50];
struct GRmd_env		set_env_loc;
int			four = 4;

	SetProc( VDGive_setobjs ); Begin

	if ( !set_grid && !set_name ) {
                 val = 0; 
                 goto wrapup;
        }

        nbos = 0;
        locomps = 0;
        grid.objid = NULL_OBJID;

        status =
        gr$get_module_env(      msg     = & status,
                                sizbuf  = & size,
                                buffer  = & locEnv,
                                nret    = & size );

	if ( set_env )  
	   set_env_loc = *set_env;
	else
	   set_env_loc = locEnv;


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
	  status =
	  om$send(msg = message VDgrset.VDName_to_id( &msg, set_name, &grid ),
		  senderid = VDsetmgr_grid.objid,
		  targetos = VDsetmgr_grid.osnum,
		  p_chanselect = &GRcmpowner_to_connector_CS );

	  if ( status != OM_I_STOP_SENDING ){
         
            msg  = vd$get_ref_os_list( msg           =  &rc,
                                       main_os       =  &locEnv.md_id.osnum,
                                       num_ref_os    =  &nbos,
                                       ref_os_list   =  &oslist,
                                       ref_env_list  =  &modenvlist );

            if( nbos  ==  0 ) {
               val = 0;
               goto wrapup;
            }

            for( ii = 0; ii < nbos; ii++ ){

              status = ex$get_objid_from_NOD (
                                                NODname   = "IGENOD",
                                                objname   = "VDsuperset",
                                                pobjid    = &super_id,
                                                mod_osnum = oslist[ii]  );
              as$status();

              mgr_id.objid = super_id; 
              mgr_id.osnum = oslist[ii];

              status =
              om$make_chanselect( channame      = "GRcmpowner.to_components",
                                  p_chanselect  = &GRcmpowner_to_connector_CS
                                );
              as$status();
	      status =  VDStrip_filename_from_setname( set_name, set_text,
								mgr_id.osnum );

              
              status =
              om$send(msg = message VDgrset.VDName_to_id(    &msg,
                                                             set_text,
                                                             &grid),
                      senderid = mgr_id.objid,
                      targetos = mgr_id.osnum,
                      p_chanselect = &GRcmpowner_to_connector_CS );
              as$status();
              
              if ( status == OM_I_STOP_SENDING ){
                   break;
              }
            }
          }
	}
        else{
             grid.objid = set_grid->objid;
             grid.osnum = set_grid->osnum;
        }

        if( grid.objid == NULL_OBJID ){
              val = 0;
              goto wrapup;
        }

/*
 * get the count
 */
	status =
	om$get_channel_count(objid = grid.objid,
	           	     osnum = grid.osnum,
			     p_chanselect = &GRcmpowner_to_connector_CS,
			     count = (OMuint *)&locomps );

	__DBGpr_int("locomps ", locomps );

        if( locomps == 0 ) {
            val = 0 ;
            goto wrapup;
        }
        else{
             val = 1;
        }

        if( numcomps ){
          *numcomps = locomps;
        }

        if( !set_objs && !setobj_envs ){
            goto wrapup;
        }
   
        buffer = (OM_S_OBJECT_LINKAGE *) malloc
        	         ( locomps * sizeof(OM_S_OBJECT_LINKAGE));
        if( ! buffer ){
		val = 0 ;
		goto wrapup ;
	}

        status =
        om$get_channel_objects(osnum = grid.osnum,
                               objid = grid.objid,
                               p_chanselect = &GRcmpowner_to_connector_CS,
                               list = buffer,
                               size = locomps,
                               count= (OMuint *)&locomps );
        as$status();

	__DBGpr_int("locomps ", locomps );

	fndInd = 0 ;

	for( myind = 0; myind < locomps; myind++ ){

          status =
          om$get_classname(osnum = buffer[myind].osnum,
                           objid = buffer[myind].S_objid,
                           classname =  prtname );

          if( om$is_ancestry_valid(subclassname  = prtname,
                             superclassname=  "VDpretendin") == OM_S_SUCCESS ){           
	    __DBGpr_com("VDpretendin obj");

            status =
            om$send(msg = message NDnode.NDget_objects
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

	    __DBGpr_int(" NDget_objects->objcount ", objcount );


            for( p = 0; p < objcount; p++ ){

              om$get_classname(osnum = prtobjs[p].osnum,
                                objid = prtobjs[p].objid,
                                classname = cname );

              if( om$is_ancestry_valid(
			subclassname = cname,
                      superclassname = "ASsourcein" ) == OM_S_SUCCESS  ||

		   om$is_ancestry_valid(
			subclassname = cname,
                      superclassname = "ACpretendin" ) == OM_S_SUCCESS ||

		   om$is_ancestry_valid(
			subclassname = cname,
                      superclassname = "ACpretend" ) == OM_S_SUCCESS   ||

		   om$is_ancestry_valid(
			subclassname = cname,
                      superclassname = "ASsource" ) == OM_S_SUCCESS ){ 

		actobjs.objid = NULL_OBJID ;

		status =
                om$send(msg = message NDnode.ASreturn_go( &actobjs,
                                                          &matrix_type,
                                                          matrix ),
                        senderid= NULL_OBJID, 
                        targetid= prtobjs[p].objid,
                        targetos= prtobjs[p].osnum ) ;

		if( actobjs.objid != NULL_OBJID ){

		  if( setobj_envs ){
		
	           /*	int ii;  */

			setobj_envs[fndInd]._grid = actobjs ;

			setobj_envs[fndInd]._md_os = actobjs.osnum;

			ex$get_modid(
				mod_osnum =  setobj_envs[fndInd]._md_os,
			        mod_id    = &setobj_envs[fndInd]._md_id);

			__DBGpr_obj(" GO_obj", setobj_envs[fndInd]._grid  );

			{
                         MAmulmx( &msg, &four, &four, &four,
					set_env_loc.md_env.matrix,
					matrix,setobj_envs[fndInd]._matrix );
                         MAtypemx(&msg,setobj_envs[fndInd]._matrix,
							&matrix_type);
			 setobj_envs[fndInd]._matrix_type = matrix_type;

			}
/*
			setobj_envs[fndInd]._matrix_type = matrix_type;

			for(ii=0; ii<16; ii++)
			   setobj_envs[fndInd]._matrix[ii] = matrix[ii];
*/
		  }
		  else{
			/*
			 * get only the GRid list.
			 */
			set_objs[fndInd] = actobjs ;

			__DBGpr_ith_obj(" GO_obj", fndInd, set_objs );
		  }

		  fndInd ++ ;
		}
	      } /* om$is_ancestry_valid */

	      /* 
	       * rmn - TR fix :  added following else branch to handle
	       * set objects in current space 
	       */

	      else
	      {
		  /* object is in current file */

		  if( setobj_envs )
		  {
			setobj_envs[fndInd].obj_id.objid = prtobjs[0].objid;
			setobj_envs[fndInd].obj_id.osnum = prtobjs[0].osnum;
			setobj_envs[fndInd].mod_env = locEnv;
		  }
		  else
		  {
			set_objs[fndInd].objid = prtobjs[0].objid;
			set_objs[fndInd].osnum = prtobjs[0].osnum;
		  }
		  fndInd++;
               }
	    } /* for( p = 0; p < objcount; p++ ) */
	  } /* om$is_ancestry_valid = VDpretendin */
	} /* myind < locomps */

	/*
	 * Return status.
	 */
	if( fndInd ) val = 1;

	__DBGpr_int("Total ", fndInd );

wrapup:

	_FREE( oslist );
	_FREE( modenvlist );
	_FREE( buffer );

	End ;
	return( val );
}

/*============================================================================*/

end implementation VDgrset;

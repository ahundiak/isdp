/* $Id: VDdumpGeom.I,v 1.4 2002/06/05 21:10:59 ramarao Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil/VDdumpGeom.I
 *
 * Description:
 *	Print the curve and surface geometries in a file.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/10/00        Rama Rao        File Creation
 *	03/29/00	Rama Rao	Got the Surface Boundaries
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>
#include "UNIXerrdef.h"
#include "EMSmsgdef.h"
#include "VDmem.h"
#include "v_geommacros.h"

from EMSsubbs		import	EMget_boundaries;

extern	OMuword	OPP_EMScomposite_class_id;

FILE *VDopenFile( msg, filename, mode )
long        *msg ;
const char  *filename ;
const char  *mode  ; {

    struct stat fstat ;
    FILE        *fp ;
    long        rc ;
    /*
     * Opens a file in "r"(ead), "w"(rite) or "a"(ppend) mode, returning
     * an ad hoc error message in case of error.
     */
    fp = NULL ;

    if( stat( filename, &fstat ) == -1 ) {

        switch( errno ) {

        case ENOENT :
            switch( *mode ) {
                case 'r' :
                    rc = UNIX_E_ENOENT  ; break ;
                case 'a' :
                case 'w' :
                    if( fp = fopen( filename, "w" ) ) {
                        rc = MSSUCC ;
                    } else {
                        rc = UNIX_E_ENOTDIR ;
                    }
                    break ;
                default :
                    rc = EMS_E_InvalidArg ; break ;
            }
            break ;

        case ENOTDIR    : rc = UNIX_E_ENOTDIR   ; break ;
        case EPERM  : rc = UNIX_E_EPERM ; break ;
        case EACCES : rc = UNIX_E_EACCES    ; break ;
        default     : rc = MSFAIL       ; break ;

        }
    } else {
        switch( *mode ) {
            case 'r' : mode = "r" ; break ;
            case 'a' : mode = "a" ; break ;
            case 'w' : mode = "w" ; break ;
            default  : rc = EMS_E_InvalidArg ; goto wrapup ;
        }
         if( fp = fopen( filename, mode ) ) {
            rc = MSSUCC ;
        } else {
            rc = UNIX_E_EPERM ;
        }
    }
    wrapup :
        *msg = rc ;
        return fp ;

} /* VDopenFile */


long	VDdumpCurve( curve_obj, curve_data, filename )
const struct GRobj_env      *curve_obj;
const struct IGRbsp_curve   *curve_data;
const IGRchar		    *filename;
{
  long msg=MSSUCC;
  FILE *fp=NULL;

  if( !filename || ( !curve_obj && !curve_data ) )  return EMS_E_InvalidArg ;

  fp = VDopenFile( &msg, filename, "w" );
  if( msg != MSSUCC ) return msg;

  if( curve_obj )
  {
     struct IGRbsp_curve *crv_geom=NULL;
     vd_$get_geometry( 	msg      = &msg,
			grobjId  = &curve_obj->obj_id,
			grobjEnv = &curve_obj->mod_env,	
			geometry = (char *) &crv_geom   );
     if( msg&1 ) BSprintbspc( fp, NULL, crv_geom, FALSE );
     _FREE( crv_geom );
  }
  else if( curve_data ) BSprintbspc( fp, NULL, curve_data, FALSE );

  fclose( fp );
  fp = NULL;
  return msg;
}

long    VDdumpSurface( surf_obj, surf_data, filename )
const struct GRobj_env      *surf_obj;
const struct IGRbsp_surface *surf_data;
const IGRchar               *filename;
{
  int  i;
  long msg=MSSUCC;
  FILE *fp=NULL;
  OMuword	obj_cls ;

  if( !filename || ( !surf_obj && !surf_data ) )  return EMS_E_InvalidArg ;

  /*
   * Check if the object is a composite. If so, leave before a crash.
   */
  if(surf_obj)
  {
      om$get_classid( objid     =  surf_obj->obj_id.objid,
		      osnum     =  surf_obj->obj_id.osnum,
		      p_classid = &obj_cls);
      if( om$is_ancestry_valid( superclassid = OPP_EMScomposite_class_id,
				subclassid   = obj_cls ) == OM_S_SUCCESS ){
	  return 1 ;	
      }
  }
  fp = VDopenFile( &msg, filename, "w" );
  if( msg != MSSUCC ) return msg;

  if( surf_obj )
  {
     struct IGRbsp_surface *srf_geom=NULL;
     vd_$get_geometry(  msg      = &msg,
                        grobjId  = &surf_obj->obj_id,
                        grobjEnv = &surf_obj->mod_env,
                        geometry = (char *) &srf_geom   );
     if( msg&1 )
     {
         om$send ( msg = message EMSsubbs.EMget_boundaries (
                            &msg,
                            &surf_obj->mod_env.md_env.matrix_type,
                            surf_obj->mod_env.md_env.matrix,
                            &srf_geom->on_off,
                            &srf_geom->num_boundaries,
                            &srf_geom->bdrys ),
                      senderid = NULL_OBJID,
                      targetid = surf_obj->obj_id.objid,
                      targetos = surf_obj->obj_id.osnum );
     }
     if( msg&1 ) BSprintbsps( fp, NULL, srf_geom, FALSE );
     for( i=0; i<srf_geom->num_boundaries; ++i ) 
	 _FREE( srf_geom->bdrys[i].points );
     _FREE( srf_geom->bdrys );
     _FREE( srf_geom );
  }
  else if( surf_data ) BSprintbsps( fp, NULL, surf_data, FALSE );

  fclose( fp );
  fp = NULL;
  return msg;
}

end implementation Root;

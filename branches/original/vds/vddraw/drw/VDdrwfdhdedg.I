/* $Id: VDdrwfdhdedg.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwfdhdedg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwfdhdedg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  21:24:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/11/21  00:57:06  pinnacle
# Replaced: ./vddraw/drw/VDdrwfdhdedg.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/23  20:05:24  pinnacle
# Replaced: vddraw/drw/VDdrwfdhdedg.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/05/09  11:39:44  pinnacle
# Replace: vddraw/drw/VDdrwfdhdedg.I by azuurhou for OPE
#
# Revision 1.2  1995/04/07  17:37:04  pinnacle
# Replaced: vddraw/drw/VDdrwfdhdedg.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/01/95	adz		creation date
 *	10/30/97	ah		warning messages
 ***************************************************************************/

class implementation VDSroot ;
#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "vd_ve.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_vedef.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_fndslsinmc.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"
#include "v_visedproto.h"

extern void		VD_setGRids() ;
extern	int		VDref_elem_ve_process();

/*
 * Combine the needed edges of the object and project them.
 * After projection delete all the Covered Curves of the object.
 */

#argsused // Warning messages

/*----------------------------------------------------------------------------*/
long VD_drwFindHiddenEdgesOfObject(	msg,		/* return code        */
					inp,		/* Input information  */
					xData,		/* Data information   */
					rfCount,	/* reference count    */
					rfList,		/* reference surfaces */
					edgList,	/* input edges        */
					vList,		/* List of visible ed */
					hList)		/* List of hidden edh */

long			*msg ;
VD_drwInputData         *inp ;
VD_drwExecData		*xData ;
int			rfCount ;
struct	GRobj_env	*rfList ;
struct VDve_elem_buf	*edgList,
			*vList,
			*hList ;
{
	long			sts ;	    /* OM completion code.	      */
	int			i, j ,	    /* Loop index.		      */
				enterLoop,  /* Loop checking.		      */
				rfIndex ;
	IGRdouble		VDwld_to_viewport[16],
				VDviewport_to_wld[16],
				VDwld_to_view[16],
				VDrotation[16];

#ifdef	vdsDEBUG
	enum	GRdpmode	dpmode ;
#endif

	struct	VDve_elem_buf	v, h, buf ;

	SetProc( VD_drwFindHiddenEdgesOfObject ); Begin

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	/*
	 * initialization of local & output buffers.
	 */
	VD_veInitElemBuf( vList );
	VD_veInitElemBuf( hList );
	VD_veInitElemBuf( &v );
	VD_veInitElemBuf( &h );
	VD_veInitElemBuf( &buf );

	/*
	 * fill in the buffer.
	 */
	if ( ! edgList->count || ! rfCount ) goto wrapup ;

	/*
	 * get matrix information.
	 */
	MAidmx( msg, VDwld_to_viewport );
	MAidmx( msg, VDviewport_to_wld );
	MAidmx( msg, VDwld_to_view );
	MAidmx( msg, VDrotation );

	/*
	 * setup for loop processing.
	 */
	v.count		= edgList->count ;
	v.buf_siz	= edgList->count ;
	if( ! ( v.obj_info_p	= _MALLOC( v.count, struct GRobj_env )))
		vd_$mem_fail();
	for( i=0 ; i<v.count ; i++ ) v.obj_info_p[i] = edgList->obj_info_p[i] ;

#ifdef	vdsDEBUG
	for( i=0 ; i<rfCount ; i++ )
		VD_ShowObj( & rfList[i]._grid );
#endif

	enterLoop = FALSE ;
	rfIndex = 0 ;
	sts =
	VD_drwGetIndexFromElemList(	msg,
					inp->drwInfo.viewVector,
					&v,
					rfCount, rfList,
					&rfIndex );
	__CheckRC( sts, *msg, "VD_drwGetIndexFromElemList", wrapup );

	__DBGpr_int(" First Index ", rfIndex );

	/*
	 * Go on till all surfaces are tested.
	 */
	while( rfIndex < rfCount ){

		enterLoop = TRUE ;

		/*
		 * Create internal list.
		 */
		if( buf.count +1 >= buf.buf_siz ){
		  buf.count		= v.count + 1 ;
		  buf.buf_siz		= buf.count ;
		  buf.obj_info_p	= v.obj_info_p ;
		  if( ! ( buf.obj_info_p = _REALLOC(	buf.obj_info_p,
							buf.count,
							struct GRobj_env )))
			vd_$mem_fail();
		}
		else{
		  buf.count		= v.count + 1 ;
		}

		/*
		 * add as latest object the surface.
		 */
		buf.obj_info_p[v.count]._grid   = rfList[rfIndex]._grid ;
		buf.obj_info_p[v.count].mod_env = rfList[rfIndex].mod_env; 

#ifdef	vdsDEBUG
		VD_ShowObj( & rfList[rfIndex]._grid );
#endif

		/*
		 * Reset the output buffer.
		 */
		VD_veInitElemBuf( &v );

		/*
		 * Check the result.
		 */
		sts =
		VDref_elem_ve_process(	msg,	&buf, &v, &h,
					VDwld_to_viewport, VDviewport_to_wld,
					VDrotation, VDwld_to_view );
		__CheckRC( sts, *msg, "VDref_elem_ve_process", wrapup );

#ifdef	vdsDEBUG
		__DBGpr_int(" vis_buf ", v.count );
		for( j=0 ; j<v.count ; j++ ){
		  __DBGpr_obj("vis ", v.obj_info_p[j].obj_id );
		}

		__DBGpr_int(" hid_buf ", h.count );
		for( j=0 ; j<h.count ; j++ ){
		  __DBGpr_obj("vis ", h.obj_info_p[j].obj_id );
		}

		if( v.count ){
			dpmode = GRbd ;
			vd_$bulk_display(	dpmode	= dpmode,
						count	= v.count,
						objenvs	= v.obj_info_p );	
		}
		else{ printf(" No VISIBLE objects selected\n"); }

		if( h.count ){
			dpmode = GRbd ;
			vd_$bulk_display(	dpmode	= dpmode,
						count	= h.count,
						objenvs	= h.obj_info_p );	
		}
		else{ printf(" No HIDDEN objects selected\n"); }
#endif

		/*
		 * Save the information of the hidden list.
		 */
		if( h.count ){
		  if( hList->count ){
		    if( !( hList->obj_info_p = _REALLOC(hList->obj_info_p,
							hList->count + h.count,
							struct GRobj_env )))
			vd_$mem_fail();
		  }
		  else{
		    if( !( hList->obj_info_p = _MALLOC(	h.count,
							struct GRobj_env )))
			vd_$mem_fail();
		  }

		  /*
		   * Copy the found hidden edges.
		   */
		  for( j=0 ; j<h.count ; j++ )
			hList->obj_info_p[hList->count+j] = h.obj_info_p[j] ;
		  hList->count += h.count ;
		}

		/*
		 * Remove the temporary buffer.
		 */
		VD_veFreeElemBuf( &h );

		/*
		 * delete the old visible edges and buffer.
		 */
		vd_$bulk_delete(	count	= buf.count-1,
					objenvs	= buf.obj_info_p );
		VD_veFreeElemBuf( &buf );

		if( ! v.count ) break ;

		/*
		 * The list of found visible edges will be reprocessed with
		 * a new list of output. The reference list needs to be 
		 * recalculated to determine the reference list.
		 */
		rfIndex ++ ;

		sts =
		VD_drwGetIndexFromElemList(	msg,
						inp->drwInfo.viewVector,
						&v,
						rfCount, rfList,
						&rfIndex );
		__CheckRC( sts, *msg, "VD_drwGetIndexFromElemList", wrapup );

		__DBGpr_int(" Next Index ", rfIndex );

	} /* while rfIndex< rfCount */

	/*
	 * We have threated all the reference objects.
	 */
	if( v.count ){
		vList->count		= v.count ;
		vList->obj_info_p	= v.obj_info_p ;
		VD_veInitElemBuf( &v );
	}

	if( ! enterLoop ){
		/*
		 * Free the input list structure. The objects are
		 * copied into the vList (from v) and the caller function will
		 * delete the input list.
		 */
		VD_veFreeElemBuf( edgList );
	}
		
	__DBGpr_int(" VISIBLE edges ", vList->count );
	__DBGpr_int(" HIDDEN  edges ", hList->count );

	wrapup:
		VD_veFreeElemBuf( &buf );

		if( ! (sts & *msg & 1 )){
			VD_veFreeElemBuf( vList );
			VD_veFreeElemBuf( hList );
			/*
			 * For process output we copy the total list of visible
			 * edges for output.
			 */

			__DBGpr_com("\tINVALID RESULT FOUND");
			if( edgList->count ){
			  vList->count		= edgList->count ;
			  vList->obj_info_p	= edgList->obj_info_p ;
			}

			VD_veFreeElemBuf( edgList );
			*msg = MSSUCC ;
			sts  = OM_S_SUCCESS ;
		}

		End
		return sts ;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

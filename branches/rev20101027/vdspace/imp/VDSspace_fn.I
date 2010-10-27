/* $Id: VDSspace_fn.I,v 1.1.1.1 2001/01/04 21:09:15 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDSspace_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSspace_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:15  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

 /*
	
     PL       22 NOV 1991  : Design date

ABSTRACT : 

	Implements Functions used for the space management product.
	- VDget_tangent_plane.
	
*/

class implementation Root;

#include <stdio.h>

#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "EMSssprops.h"
#include "EMSconstruct.h"

#include "VDSutil_def.h"

#include "AS_status.h"


#define   AS_DEBUG 	1

from GRvg       import GRdetplane, GRprojpt,GRptproject; 
from EMSsubbs  	import EMtangent_normal, EMget_props;




/* ==================================================================

	function that return the plane tangent to the given surface
	at a given point. The normal of the returned plane is oriented
	in the sens of the input surface.
	
	Arguments:

(I)	int		       type        1 = plane, else surface or comsf .	
(I)	struct 	  GRid	       IN_SURF     input surface object. 
(I)	struct 	  IGRplane     in_plane    if input is plane, and geom known. 
(I)	struct 	  GRmd_env     md_env	   md_env of the surface .
(I)	IGRdouble 	       point[3]    point where plane must be defined.
(O)	struct 	  IGRplane     out_plane   projected point on surf and normal
					   of the input surface at this point.
	
	
===================================================================== */

int VDget_tangent_plane(type,IN_SURF,in_plane,md_env,point,out_plane)

int		       type ;		
struct 	  GRid	       *IN_SURF;
struct 	  IGRplane     *in_plane;
struct 	  GRmd_env     *md_env;
IGRdouble 	       point[3];
struct 	  IGRplane     *out_plane;
/*.VDget_tangent_plane*/
{
struct	GRid		prop_obj;
long			msg, status;
IGRboolean		err_flag;
IGRdouble 	       	base[3],parms[2], dis_fact,vect_TN[4][3];
struct GRparms		proj_parms;
unsigned char		props;

err_flag = FALSE;

if(IN_SURF == NULL || md_env == NULL || out_plane == NULL){
	UI_status("ERROR VDget_tangent_plane, invalid argument");
	err_flag = TRUE;
	goto wrapup;
}
/*^
 printf("type: %d\n",type);
 printf("IN_SURF: %d, %d\n",IN_SURF->objid,IN_SURF->osnum);
 printf("point: %lf, %lf, %lf\n",point[0],point[1],point[2]);
*/
if(type == 1) {
	/*|support plan ......*/

	if(in_plane != NULL){
		/*|take in_plane normal */
		out_plane->normal[0] = 	in_plane->normal[0];
		out_plane->normal[1] = 	in_plane->normal[1];
		out_plane->normal[2] = 	in_plane->normal[2];
		out_plane->point[0]  =	point[0];
		out_plane->point[1]  =	point[1];
		out_plane->point[2]  =	point[2];
		prop_obj = *IN_SURF;
	}
	else{
		/*|take geom of plane */
   		status = om$send (msg = message GRvg.GRdetplane(&msg, 
   						&md_env->md_env.matrix_type, 
   						md_env->md_env.matrix, 
   						out_plane),
		    	 senderid = NULL_OBJID,
			 targetid = IN_SURF->objid,
			 targetos = IN_SURF->osnum );
        
   		if(!(msg&status &1)){
			om$report_error(sts=status); 
			err_flag = TRUE;
			goto wrapup;
    		}
		out_plane->point[0]  =	point[0];
		out_plane->point[1]  =	point[1];
		out_plane->point[2]  =	point[2];
   			
	}  
		
}
else {
	/*|support surface or composite ......*/

  /* Jean Jasinczuk 12 feb 93 : Replace GRpropt by GRptproj */
  /* because local_param in GRprojpt should not be NULL     */
#if 0 
	status = om$send(msg = message GRvg.GRprojpt(&msg, 
    						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						NULL,
						point,
						base,
						&proj_parms),
		    senderid = NULL_OBJID,
	  	    targetid = IN_SURF->objid,
	  	    targetos = IN_SURF->osnum );
#endif
	status = om$send(msg = message GRvg.GRptproject
			 (&msg, 
			  &md_env->md_env.matrix_type,
			  md_env->md_env.matrix,
			  point,
			  base,
			  &proj_parms),
			 senderid = NULL_OBJID,
			 targetid = IN_SURF->objid,
			 targetos = IN_SURF->osnum );
	
    	if (!(msg&status&1)){ 
		om$report_error(sts=status); 
		err_flag = TRUE;
		goto wrapup;
    	}
/*^	printf("proj_parms u: %lf, v: %lf, leaf_id: %d, %d\n",
				proj_parms.u,proj_parms.v,
				proj_parms.leaf_id.objid,
				proj_parms.leaf_id.osnum);
		
*/
	dis_fact = 1.;
	parms[0] = proj_parms.u;
	parms[1] = proj_parms.v;

	/* normal in vect_TN[3]*/

    	status = om$send(msg = message EMSsubbs.EMtangent_normal(&msg, 
    								md_env,
    								parms,
    								dis_fact,
    								vect_TN),
		    senderid = NULL_OBJID,
	  	    targetid = proj_parms.leaf_id.objid,
	  	    targetos = proj_parms.leaf_id.osnum );
    	if (!(msg&status&1)){ 
		om$report_error(sts=status); 
		err_flag = TRUE;
		goto wrapup;
    	}
/*^
	printf("vect_TN[3]: %lf, %lf, %lf\n",	vect_TN[3][0],
							vect_TN[3][1],
							vect_TN[3][2]);
*/
	out_plane->normal[0] = vect_TN[3][0]	;
	out_plane->normal[1] = vect_TN[3][1]	;
	out_plane->normal[2] = vect_TN[3][2]	;
	out_plane->point[0] = base[0];
	out_plane->point[1] = base[1];
	out_plane->point[2] = base[2];
	prop_obj = proj_parms.leaf_id;

}

/*| get properties */

status = om$send(msg = message EMSsubbs.EMget_props(&msg,&props),
		 senderid = NULL_OBJID,
	  	 targetid = prop_obj.objid,
	  	 targetos = prop_obj.osnum );
if (!(msg&status&1)){ 
	om$report_error(sts=status); 
	err_flag = TRUE;
	goto wrapup;
}

if(props & EMSIS_NRML_REVERSED) {

	/*|reverse normal */

	out_plane->normal[0] = -out_plane->normal[0];
	out_plane->normal[1] = -out_plane->normal[1];
	out_plane->normal[2] = -out_plane->normal[2];
}

/*^
 printf("out_plane->point: %lf, %lf,%lf\n",out_plane->point[0], out_plane->point[1], out_plane->point[2]);
 printf("out_plane->normal: %lf, %lf,%lf\n",out_plane->normal[0], out_plane->normal[1], out_plane->normal[2]);
*/

wrapup:



if(err_flag == TRUE) return(0);
else return (1);

}




end implementation Root;


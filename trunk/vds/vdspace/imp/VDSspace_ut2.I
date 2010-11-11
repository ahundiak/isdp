/* $Id: VDSspace_ut2.I,v 1.1.1.1 2001/01/04 21:09:15 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDSspace_ut2.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSspace_ut2.I,v $
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
ABSTRACT : 

	Function used for the spcae managment product.

CHANGE HISTORY
	
     Ch       15 Feb 1991  : Design date

*/

class implementation Root;

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "VDSutil_def.h"
#include "AS_status.h"

#define  AS_DEBUG 


extern GRclassid	OPP_EMSplane_class_id, OPP_EMSsurface_class_id, 
			OPP_GRcurve_class_id,OPP_EMScompsurf_class_id,
			OPP_EMSsfimpbnd_class_id;

from GRvg      import GRdetplane, GRgetsize, GRgetgeom;
from GRvg      import GRgenabsg;
from EMSsubbs  import EMget_props;

/* 
/*    	This function computes the intersection of two surfaces or planes
/*      and returns a set of intersections. 
/*
/*      If the intersection is betwen two infinite planes, two points 
/*	are returned defining and infinite line.
/*
/*      The entries surfaces are surfaces or planes. if the plane definition
/*  	is used there are taken are infinite.
/*
/*	Type1 and type2 are the type of the surface (PLAN, SURF, COMP). The
/*      intersection of composite surfaces are solved to.
/*
/*  	nb_pts and pts are allocated by the function and must deallocated
/*	by the user. pts is and pointeur on a bidimensionned array
/*
/* */



VDintersect(type1, bsp_sf1, plane1, nb_sf1, type2, bsp_sf2, plane2, nb_sf2,
            nb_int, nb_pts, pts)
int			type1;		/* surf1 type			*/
struct IGRbsp_surface   *bsp_sf1;	/* geom of surf1 (NULL if not)  */
struct IGRplane		*plane1;	/* plane def of surf1 (NULL if not) */
int			nb_sf1;		/* number of surf1 (if composite)   */
int			type2;		/* surf2 type			*/
struct IGRbsp_surface   *bsp_sf2;	/* geom of surf2 (NULL if not)  */
struct IGRplane		*plane2;	/* plane def of surf2 (NULL if not) */
int			nb_sf2;		/* number of surf2 (if composite)   */
int			*nb_int;	/* number of intersections	*/
int			**nb_pts;	/* number of intersection points*/
IGRdouble			***pts;		/* pointeur on array[][] of points  */
{
 printf("VDintersect is no longer defined\n");

 return 0;
}

SMelem_type(element, mat_type, matrix, type, plane, bsp_sf, nb_sf)

struct 	GRid	 	*element;  /* I  element id			*/
short			 mat_type; /* I  matrix type 			*/
IGRdouble			*matrix;   /* I  matrix of the element		*/
int		 	*type;	   /* O  type of element (PLAN, ..)	*/
struct	IGRplane 	*plane;	   /* O  */
struct 	IGRbsp_surface	***bsp_sf; /* O  */
int  			*nb_sf;    /* O  */

{
 long 		msg, status;
 GRclassid	obj_classid;
 long		size;

 *nb_sf   = 0;
 *type    = E_ERROR;

 /*" obj: %d, %d\n", element->objid,element->osnum */
 status = om$get_classid(osnum     = element->osnum, 
			 objid     = element->objid, 
			 p_classid = &obj_classid);

 if( om$is_ancestry_valid(subclassid   = obj_classid,
			  superclassid = OPP_EMSplane_class_id )
			   == OM_S_SUCCESS )
  {         	
   /*| This is a plane */
   *type = PLAN;

   if(plane == NULL) return 1;

   status = om$send (msg = message GRvg.GRdetplane(&msg, &mat_type, matrix, plane),
			 senderid = NULL_OBJID,
			 targetid = element->objid,
			 targetos = element->osnum );
        
   as$status(action = RET_STATUS);   
   *nb_sf = 1;

   /*"element is a plane \n" */
           		
  }
 else if( om$is_ancestry_valid(subclassid   = obj_classid,
				superclassid = OPP_EMSsurface_class_id )
				== OM_S_SUCCESS )
  { 
   *type = SURF;

   if(bsp_sf == NULL) return 1;

   status = om$send(msg = message GRvg.GRgetsize(&msg, &mat_type, matrix, &size ),
		   senderid = NULL_OBJID,
	  	   targetid = element->objid,
	  	   targetos = element->osnum );
   as$status(action = RET_STATUS);   

   /*| First we have to allocate the structure */
   *bsp_sf = (struct IGRbsp_surface **) malloc(sizeof (struct IGRbsp_surface *));

   if(*bsp_sf == NULL) 
    {
     printf("dhjfgj, Bad memory allocation\n");
     return 0;
    }

   /*| Alloc of the bsp_suf */
   (*bsp_sf)[0] = (struct IGRbsp_surface *) malloc(size);

   if((*bsp_sf)[0] == NULL) 
    {
     printf("hello guy, Bad memory allocation\n");
     return 0;
    }

   status = om$send(msg = message GRvg.GRgetgeom(&msg, &mat_type, 
                                  matrix, (char *) (*bsp_sf)[0]),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS);   
   *nb_sf = 1;
  }
 else if( om$is_ancestry_valid(subclassid   = obj_classid,
			       superclassid = OPP_EMScompsurf_class_id)
			        == OM_S_SUCCESS )
  {         	
   *type = COMP_SF;
   if(bsp_sf == NULL) return 1;
   printf("COMP_SF not implemented \n");
   return 0;
  }
 else
  {
   *type = E_ERROR;
   printf ( "** neither plane, surfaces or composite \n");
   return 0;
  }
 return (1);
}

end implementation Root;

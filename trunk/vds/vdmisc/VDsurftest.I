/* $Id: VDsurftest.I,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* I/VDS
 *
 * File:        vdmisc/VDsurftest.I
 *
 * Description:
 *      This file contains functions to assess the quality of surfaces.
 *
 * Dependencies:
 *
 * Reference
 *      $Log: VDsurftest.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/11/19  18:17:26  pinnacle
# Replaced: vdmisc/VDsurftest.I for:  by kddinov for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/06/12  14:40:22  pinnacle
# Replaced: vdmisc/VDsurftest.I for:  by kddinov for vds.240
#
# Revision 1.1  1996/05/31  23:26:46  pinnacle
# Created: vdmisc/VDsurftest.I by kddinov for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/31/96	KDD		VDSurfTest
 *					VDSurfTest_delete_objects
 *	05/31/96 	SS + Ad + KDD 	VDGetMinDistAdjPoles 
 *	20/11/96	KDD		changed BSTOLCHRDHT --> BSBASISVAL
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>
#include <time.h>

// VDSurfTest    needs  
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "OMparameters.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "exdef.h"
#include        "ex.h"
#include        "igrdp.h"
#include        "gr.h"
#include        "growner.h"
#include        "go.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "exmacros.h"
#include        "grmacros.h"
#include        "AS_status.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "v_miscmacros.h"
#include        "v_dbgmacros.h"

#include        "vdpktapis.h"
#include        "v_geommacros.h"

//      VDGetMinDistAdjPoles 
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

// #include "PWapi/sfgmqtys.h"     not available 
#include "PWapi/sfgeom.h"
#include "PWapi/mdstptgm.h"

//	Display_Highlight needs 
#include "dp.h"
#include "grwireframe.h"

#include "bsxtractpar.h"


extern  void    UI_message(char *symstr);
extern  void    UI_status(char *symstr);
extern  char    *malloc();
extern  void	free(void *);

#define	x 0
#define y 1
#define z 2
#define stack_size  100 

static struct GRid	*VDsurftest_objects; 	// line ids
static int		VDnum_objects;		// number of lines created
static struct GRid	VDsurf_group; 		// group id for all lines

/*****************************************************************************
* 	VDGetMinDistAdjPoles
*
*  The following function looks at the B-spline definition of the given
*  simple surface object and computes the minimum distance that occurs between
*  any two poles. 
*
*----------------------------------------------------------------------------
*	PARAMETERS
*
* (I) 	*obj		= object id and osnum of the surface.
* (I) 	*mod_env	= Module environment.
* (I/O)	*dist		= (O) if flag =0, (I) otherwise. 
* (I)	flag		= 0 finds the minimum distance,
*			  1 finds pairs of poles with dist <= min_dist. 
* (I)	size		= size of the array points = (2*3*size). 
* (O)   *num_pairs	= the  number of output pairs.
* (O)	*points		= pairs of 3D points, second pair is 3&4. 
*
*----------------------------------------------------------------------------
*	RETURN STATUS, passed along from vd$get_geometry. 
*
*----------------------------------------------------------------------------
*	HISTORY
*
*  SS  :  05/23/96   :  Creation
*  KDD :  05/  /96   :  Checks all poles, not only adjacent U or V direction
*
*****************************************************************************/
int VDGetMinDistAdjPoles( struct GRid 	    *obj, 
		      	  struct GRmd_env   *mod_env,
			  double 	    *dist,
			  int		    flag, 
			  int		    size, 
			  int 		    *num_pairs,
			  double  	    *points  )
{
  double 	curr_mindistsq, 
		mindistsq = MAXDOUBLE, 
  		min_dist  = MAXDOUBLE,
		*poles, *pt1, *pt2;

  struct 	IGRbsp_surface *sf=NULL;
  long 		msg = 1; 
  int		i,j, shift, 
		num_poles,
   		u_num_poles, v_num_poles;

  *num_pairs = 0; 

  if ( flag & 1 ) { 
     min_dist  = *dist;
     mindistsq = min_dist * min_dist;
  }

  vd_$get_geometry (  msg 	= &msg, 
		      grobjId	= obj, 
		      grobjEnv  = mod_env, 
		      geometry	= &sf);

  if ( sf == NULL ) msg = 0;
  if ( ! (msg&1) )  goto wrapup;  

  u_num_poles = sf->u_num_poles;
  v_num_poles = sf->v_num_poles;
  poles       = sf->poles;
  num_poles   = u_num_poles * v_num_poles;

/************
*
*	Get the distance between any two poles
*	Do not recalculate the min_dist if pt2 is outside cube
*	with origin pt1 and side = 2*min_dist. 
*
************/

  for ( i = 0; i < num_poles - 1; i++ ) {

     pt1 = &poles[i*3]; 

     for (j = i+1; j < num_poles; j++) 
     {
	 pt2 = &poles[j*3]; 

	 if ( (fabs(*pt1     - *pt2)     > min_dist) ||
	      (fabs(*(pt1+y) - *(pt2+y)) > min_dist) ||
	      (fabs(*(pt1+z) - *(pt2+z)) > min_dist) ) { continue; }

	 if ( (curr_mindistsq = pwDistSqPtPt (pt1, pt2)) <= mindistsq ) {

/************
*   Change min_dist only if searches for minimum pair distance.
*************/

	    if ( flag == 0 ) {
		*num_pairs = 1;
		mindistsq = curr_mindistsq; 
	        min_dist = sqrt(mindistsq); 
	    }
	    else {
		*num_pairs = *num_pairs + 1;
		if (*num_pairs > size) break;
	    }

	    shift = (*num_pairs - 1) * 6; 

	    *(points + shift + x)     = *(pt1 + x);
	    *(points + shift + y)     = *(pt1 + y);
	    *(points + shift + z)     = *(pt1 + z);
	    *(points + shift + x + 3) = *(pt2 + x);
	    *(points + shift + y + 3) = *(pt2 + y);
	    *(points + shift + z + 3) = *(pt2 + z);
	}
     }
  }

  *dist = min_dist; 

wrapup:

  _FREE ( sf ); 

  return ( (int) msg);
}

/*****************************************************************************
*       VDSurfTest
*
*  Driver and user interface to call VDGetMinDistAdjPoles.
*  This driver is called from VDGetMinDist.u. 
*
*  NOTE: This function ALLOCATES MEMORY !
*        Make sure you call VDSurfTest_delete_objects(), before exit.
*	 We let the line segments be highlighted until the command is closed.
*----------------------------------------------------------------------------
*
*	PARAMETERS
*
* (I)	*obj		= object id and osnum of the surface. 
* (I) 	*mod_env	= module environment (transformation matrix).
* (I/O)	*min_dist	= (I) flag = 1, All pair of poles with dist <= min_dist.
*			      will be highlighted. 
*			  (O) flag = 0, Finds the minimum distance among poles.
* (I)	flag		= 0 finds the min distance for pair of poles.
*			  1 displays all pairs with dist <= min_dist. 
*
*----------------------------------------------------------------------------
*	CONSTANTS
*
* stack_size 		= number of pairs with distance < min_dist. 
*
*----------------------------------------------------------------------------
*	RETURN STATUS
*
*  1	= OK
*  0	= Failed
*
*----------------------------------------------------------------------------
*	VARIABLES
*
*  *points	= pair of 3D points to display. First pair is 1&2, second 3&4.
*
*----------------------------------------------------------------------------
*	HISTORY
*
*  KDD	05-31-96	creation.
*
*****************************************************************************/
int VDSurfTest( struct 	GRid *obj, 
		struct 	GRmd_env *mod_env,
		double 	*min_dist,
		int	flag )
{
	char			out_message[80] = "";
	int			status = 1; 
	int			msg, i;
  	int 			num_pairs  = 0;
	double			points[2*3*stack_size];
     	struct GRid    		line;
     	struct GRsymbology 	symbology;
	long			sts; 
	double			eps;


  VDnum_objects = 0;		// counts the number of object ids 

  UI_status("");

//********  Get the virtual zero if min_dist is too small.
  BSxtractpar( &sts, BSBASISVAL, &eps);
  if ( fabs(*min_dist) < eps ) { *min_dist = eps; }


  status = VDGetMinDistAdjPoles (  	obj, 
					mod_env,
					min_dist,
					flag, 
					stack_size, 
					&num_pairs,
					points); 

  if ( ! (status&1)) { 
     sprintf(out_message,"Error: fails to get geometry");
     goto wrapup; 
  }

  sprintf(out_message,"Surface [%d,%d]: %d elmnt(s), dist <= %.4f, tol = %.4f", 
			obj->osnum, obj->objid, num_pairs, *min_dist, eps);

  if ( num_pairs > stack_size) num_pairs = stack_size;

/***********
*
*	Display the minimum distance as hilighted line segments
*	The last loaded element is at the top (num_pairs - 1) of the stack. 
*	Therefore the pairs are loaded backwards. 
*
***********/

   VDsurftest_objects=(struct GRid *) malloc (sizeof (struct GRid) * num_pairs);
   if ( VDsurftest_objects == NULL ) { goto wrapup; }

   for (i = 1; i <= num_pairs; i++) {

       gr$place_linear_object(  msg 	     = &msg,
                   		num_points   = 2,
                  		points       = &points[(i-1)*6],
                   		object_id    = &line,
		    	        display_flag = 0 );       // don't display 
       if ( ! (msg&1) )  continue; 

       *(VDsurftest_objects + VDnum_objects) = line;
       VDnum_objects++;

       gr$get_symbology( object_id = &line, symb = &symbology );

       symbology.display_attr.weight += 3;	                // more visible

       gr$put_symbology( object_id = &line, symb = &symbology );

       gr$display_object(  object_id = &line,
                           mode      = GRhdo);              // display override
   }

/*************
*
*	Create a graphics group from the line objects
*
*************/

   gr$create_graphic_group( msg 	= &msg,
                     	    object_ids 	= VDsurftest_objects,
                       	    num_objects = VDnum_objects,
                            gg_id 	= &VDsurf_group);

wrapup:

  UI_status(out_message); 

  return (status);
}

/*****************************************************************************
*       VDSurfTest_delete_objects
*
*  Deletes objects created by VDSurfTest.
*  Free the memory of VDsurftest_objects.  
*
*----------------------------------------------------------------------------
*       RETURN STATUS
*
*  1    = OK. Always
*
*----------------------------------------------------------------------------
*       HISTORY
*
*  KDD  05-31-96        creation.
*
*****************************************************************************/
int VDSurfTest_delete_objects( struct  GRmd_env *mod_env)
{
  int 	msg;

  if (VDsurftest_objects) { 

     gr$delete_object(  msg       = &msg,
			md_env    = mod_env, 
			object_id = &VDsurf_group);

     free(VDsurftest_objects); 
     VDsurftest_objects = NULL; 

  }

  return (1);
}





end implementation Root;












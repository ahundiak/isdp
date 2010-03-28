/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2bcisectutil
 
     Abstract: This routine takes two B-spline geometries and prepares
	      them for intersection if at least one of them is linear.
	      This preparation entails clipping the indicated segment
	      of each linear geometry against the design cube.
-----
%SC%

     VALUE = GR2bcisectutil(msg,bc1,bc2,parms1,parms2,props1,props2,bc_ln1,
			    bc_ln2)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc1	  IGRbsp_curve	 pointer to B-spline curve pointer
     bc2	  IGRbsp_curve	 pointer to B-spline curve pointer
     parms1	  GRparms	 geometric parameters for bc1
     parms2	  GRparms	 geometric parameters for bc2
     props1	  GRprops	 geometric properties for bc1
     props2	  GRprops	 geometric properties for bc2

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred

     bc_ln1	  IGRbsp_curve	 clipped line from bc1
     bc_ln2	  IGRbsp_curve	 clipped line from bc2

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - successful
                        FALSE- failure

-----
%MD%

     MODULES INVOKED:
		MAutoparms
		MAcubepy
                BSxtlntcvbx
-----
%NB%

     NOTES:
            The two lines, bc_ln1 and bc_ln2, must contain enough
	   storage for 4 poles and 6 knots each.

            If either curve is linear and the clipping takes place, 
	   the input curve(s) which is(are) clipped have thier
	   pointers reassigned to bc_ln1 or bc_ln2 resp.
-----

%CH%
     CHANGE HISTORY:
	
	RDH  08/12/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine checks to see if bc1 is of the linear class and if so
uses the parameters to find the segment we are operating on. Then
this segment is extended and clipped against the design cube. The 
same scenario will take place for bc2. Then if any clipping takes 
place, the B-spline curve pointers are reassigned to the ouput line
pointers.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean  GR2bcisectutil(msg,bc1,bc2,parms1,parms2,props1,props2,bc_ln1,
			   bc_ln2)

	IGRlong			*msg;		/* return code		     */
	struct IGRbsp_curve	**bc1;		/* B-spline curve	     */
	struct IGRbsp_curve	**bc2;		/* B-spline curve	     */
	struct GRparms		*parms1;	/* geometric parameters, bc1 */
	struct GRparms		*parms2;	/* geometric parameters, bc2 */
	struct GRprops		*props1;	/* geometric properties, bc1 */
	struct GRprops		*props2;	/* geometric properties, bc2 */
	struct IGRbsp_curve	*bc_ln1;	/* clipped bc1		     */
	struct IGRbsp_curve	*bc_ln2;	/* clipped bc2		     */

{
  struct IGRline ln;
  struct IGRbsp_curve tmp_bc,*cv_ptr[1];
  struct IGRbsp_surface *bs;
      
  IGRdouble t;					/* t parameter		     */

  IGRlong segnum;				/* segment number	     */
  IGRlong bsrc;

  IGRint num = 1;
    
  extern void BSxtlntcvbx();
  

  *msg = MSSUCC;
  
  if( props1->type == GRCURVE  &&  props1->subtype == GRLN  &&
      parms1->polygon_inx != 4 )
  {
    MAutoparms(msg,*bc1,&parms1->u,&segnum,&t);

    ln.point1 = &(*bc1)->poles[(segnum - 1) * 3];
    ln.point2 = &(*bc1)->poles[segnum * 3];

    cv_ptr[0] = bc2[0];

#ifndef IDRAW

    if( props2->type == GRSURFACE )
    {
      bs = (struct IGRbsp_surface *)bc2[0];
      tmp_bc.num_poles = bs->u_num_poles * bs->v_num_poles;
      tmp_bc.poles = bs->poles;
      tmp_bc.weights = bs->weights;
      tmp_bc.rational = bs->rational;
      cv_ptr[0] = &tmp_bc;
    }
#endif

    BSxtlntcvbx(&ln,num,cv_ptr,bc_ln1,&bsrc);

    if( bsrc != BSSUCC )
    {
      *msg = MSSUCC;
    }
            
    *bc1 = bc_ln1;
  }

  if( (1 & *msg)  &&  props2->type == GRCURVE  &&  props2->subtype == GRLN  &&
      parms2->polygon_inx != 4 )
  {
    MAutoparms(msg,*bc2,&parms2->u,&segnum,&t);

    ln.point1 = &(*bc2)->poles[(segnum-1) * 3];
    ln.point2 = &(*bc2)->poles[segnum * 3];

    cv_ptr[0] = bc1[0];

#ifndef IDRAW

    if( props1->type == GRSURFACE )
    {
      bs = (struct IGRbsp_surface *)bc1[0];
      tmp_bc.num_poles = bs->u_num_poles * bs->v_num_poles;
      tmp_bc.poles = bs->poles;
      tmp_bc.weights = bs->weights;
      tmp_bc.rational = bs->rational;
      cv_ptr[0] = &tmp_bc;
    }
#endif

    BSxtlntcvbx(&ln,num,cv_ptr,bc_ln2,&bsrc);

    if( bsrc != BSSUCC )
    {
      *msg = MSFAIL;
    }
      
    *bc2 = bc_ln2;
  }

  if( *msg == MAIDGENRAT )
  {
    *msg = MSSUCC;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */

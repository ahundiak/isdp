/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRkeypoint

     Abstract: This method returns the closest keypoint of a B-spline
	       object to the input line.

-----
%SC%    

     GRkeypoint(msg,mat_type,matrix,line,keypoint,key_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix
     *line	  IGRline	 boreline
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred

     keypoint	  IGRpoint	 nearest keypoint to input line
     *key_parms   struct GRparms parameter structure defining keypoint
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAbcueval
	     MAptln2dis

     Methods:
	     GRgenabsg
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/14/86 : Design date.
	JSD     09/06/91 : Detection of symbology overrides.
	JSD     12/13/91 : Added orig_ele_attr to DEget.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract geometry for the linear object and
evaluates the curve at the knots one at a time keeping track of the
closest point to the input line. The closest point will be returned
as the keypoint.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "exmacros.h"
#include <tools.h>
#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern    IGRboolean    MAbcueval();
extern    IGRboolean    MAptln2dis();

from DEso import DEget;

method GRkeypoint ( IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		    struct IGRline *line; IGRpoint keypoint;
		    struct GRparms *key_parms )
{
  struct IGRbsp_curve *bc;    /* abstract geom pointer      */

  IGRchar *ptr;        /* abstract geom pointer      */

  IGRpoint pt;        /* current curve point        */

  IGRdouble min_dis,dis;    /* min and current dis squared*/
  IGRdouble h;        /* homogeneous factor(ignored)*/

  IGRlong i,j;        /* indexes          */
  IGRlong OMmsg;      /* OM return code        */

  IGRshort option;      /* bc eval option        */
  IGRlong  mess;      /* local message            */


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  if (1 & *msg)
  {
    bc = (struct IGRbsp_curve *)ptr;

    option = 0;

    if (MAbcueval(&mess,bc,&option,&bc->knots[bc->order - 1],keypoint,&h))
    {
      MAptln2dis(&mess,keypoint,line,&min_dis);
      /* set up the parameter information*/
      key_parms->u = bc->knots[bc->order - 1];
      key_parms->v = 0.0;
      key_parms->leaf_id.objid = my_id;
      key_parms->leaf_id.osnum = OM_Gw_current_OS;
      key_parms->polygon_inx = 0;

      for(i = bc->order; i <= bc->num_poles; ++i)
      {
        MAbcueval(&mess,bc,&option,&bc->knots[i],pt,&h);

        MAptln2dis(&mess,pt,line,&dis);

        if( dis < min_dis )
        {
          MAcopy(keypoint,pt,1,j);
          key_parms->u = bc->knots[i];
          min_dis = dis;
        }
      }

      /* if we have an override, we may have another keypoint */
      if (me->properties & DEHAS_OVERRIDE)
      {
        /* if the object has a so, get it */
        struct GRid        so;
        struct IGRdisplay  *attr;
        struct IGRdisplay  orig_ele_attr;
        double             *parms;
        int                count;
        extern struct GRid GRkeypoint_window_grid;

        /* get the so for that object */
        ex$get_cur_mod ( osnum = &so.osnum );
        de$create_soo ( msg = msg,
                        osnum = OM_Gw_current_OS,
                        p_objid = &so.objid );

        mess = gr$get_active_display( buffer = &orig_ele_attr );

        /* get the boundaries */
        OMmsg = om$send( msg = message DEso.DEget( msg, NULL, &parms, &count,
                                                  &attr, &orig_ele_attr, my_id,
						   GRkeypoint_window_grid.objid,
                                                   mat_type, matrix,
						   NULL, NULL ),
                          targetid = so.objid,
                          targetos = so.osnum );
        if ( *msg == MSSUCC )
          for (i = 0; i < count * 2; i++)
          {
            MAbcueval ( &mess, bc, &option, &parms [i], pt, &h );
            MAptln2dis ( &mess, pt, line, &dis );
            if (dis < min_dis)
            {
              MAcopy ( keypoint, pt, 1, j );
              key_parms->u = parms [i];
              min_dis = dis;
            }
          }
        else
          *msg = MSSUCC;
      }
    }
    else
      *msg = MSFAIL;
  }

  return OMmsg;
}/* This has been an R.D.H. production!!! */

end implementation GRbspline;

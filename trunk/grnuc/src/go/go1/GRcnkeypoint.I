/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRkeypoint

     Abstract: This routine finds the closest keypoint of a conic
               object to the input line.

-----
%SC%    

     GRkeypoint(msg,mat_type,matrix,line,keypoint,key_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type    IGRshort       matrix type
      matrix	  IGRmatrix      environment matrix
     *line        IGRline        line used to select desired keypoint

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				    - GR_PARMS_NOT_VALID (information)
					parameters sent back are
					meaningless.

      keypoint    IGRpoint       nearest keypoint to input line
     *key_parms   struct GRparms parameter information for keypoint

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
              MAcopypts
              MAabsolute
              MAarendpts
              MAmaximum
	      MAlnpsproj
              BScvarreval
              BSprptoncv
     Methods:
	      GRgetarc
	      DEget

-----
%RL%

     RELATIONS REFERENCED:  none.

-----
%NB%

     NOTES:

       This routine builds a point set containing all the points on
       a conic that are possible choices for the resulting keypoint.

         all      - origin, enpoints of any symbology overrides

	 arcs     - endpoints of arc
	 ellipses - endpoints of both axes

-----
%CH%

     CHANGE HISTORY:
	
	RDH     02/06/86 : Creation date.
	JSD     09/06/91 : Detection of symbology overrides.
	JSD     12/13/91 : Added orig_ele_attr to DEget.
        dhm     03/25/93 : continue processing on error from DEget.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract data for the object and calls a
math routine to return an IGRarc data structure. Then the arc 
endpoints are found as well as any of the axis endpoints on the arc.
These points are placed in a point set.  Also in the point set are the
endpoints of any symbology overrides that are on the element.  Then the
line is projected onto the point set to find the closest keypoint.

----*/
/*EH*/

class implementation GRconic;

#include <alloca.h>
#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "mapriv.h"
#include "bserr.h"
#include "godef.h"
#include "gocmacros.h"
#include "exmacros.h"
#include <tools.h>
#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern    IGRboolean    MAlnpsproj();
extern    IGRboolean    BSprptoncv();

from DEso import DEget;

method GRkeypoint(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		  struct IGRline *line; IGRpoint keypoint;
		  struct GRparms *key_parms)

{
  struct IGRarc arc;			       /* arc for conic object       */
  struct IGRpointset ps;                       /* candidate keypoints        */

  IGRpoint ln_pt;                              /* project point              */

  IGRchar *ptr;                                /* abstract data pointer      */

  IGRdouble *points;                           /* storage for ps             */
  IGRdouble t;                                 /* t parameter of ln_pt       */

  IGRint  index;                               /* index into the point set   */

  IGRlong num;                                 /* pt number of pjpt          */
  IGRlong i;                                   /* variable for macro         */
  IGRlong OMmsg;                               /* return code                */
  IGRlong mess;				       /* return code		     */

  IGRboolean on_curve;			       /* for BS routine	     */


  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;

  ps.num_points = 0;
  ps.points = NULL;

  /* get abstract geometry */
  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  /* get conic structure */
  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRconic.GRgetarc(msg,mat_type,matrix,&arc),
                  senderid = my_id,
                  targetid = my_id);

  if( 1 & OMmsg & *msg )
  {
    ps.num_points = 0;

    if (me->properties & DEHAS_OVERRIDE)
    {
      /* if the object has a SO, get it */
      struct GRid         so;
      struct IGRdisplay  *attr;
      struct IGRdisplay   orig_ele_attr;
      double             *parms;
      int                 count;
      extern struct GRid  GRkeypoint_window_grid;

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
                                                 mat_type, matrix, NULL, NULL),
                       targetid = so.objid,
                       targetos = so.osnum );
      /* TR 119302385.
       * Continue processing on a fail.  MSFAIL means that there were no
       * symbology overrides.  This may be a reference file with the SO's
       * in the master file.   Doree.
       */

      if (! ( 1 & *msg ) )
      {
        count = 0;
      }

      if ( (count == 1) && (parms[0] == 0.0) && (parms[1] == 1.0) )
      { /* total SO, don't put it in point set */
	  count = 0;
      }
      else
      {
          /* there are 2 endpoints for every SO */
          count = count * 2;
      }

      /* memory for SO points, conic origin, and conic axes */
      points = (double *) alloca ( (count + 5) * (3 * sizeof (double)) );

      /* make point set point to the memory */
      ps.points = points;

      if ( count )
      {
          /* evaluate SO parms to SO points */
          BScvarreval(&mess,ptr,parms,count,0,points);

          /* increment number of points in point set */
          ps.num_points += count;
      }

    }
    else
    {
      /* memory for conic origin and conic axes */
      points = (double *) alloca ( 15 * (3 * sizeof (double)) );

      /* make point set point to the memory */
      ps.points = points;
      ps.num_points = 0;
    }

    /* load origin into point set */
    MAcopypts(arc.origin,&points[ps.num_points*3],1,i);

    ps.num_points += 1;

    if( MAabsolute(arc.sweep_angle) != 2.0 * PI )
    {
      /* if arc, then load arc endpoints into point set */
      MAarendpts(&mess,&arc,&points[ps.num_points*3]);

      ps.num_points += 2;
    }
    else
    {
      if( MAabsolute(arc.prim_axis - arc.sec_axis) > 
          (MAETA * MAmaximum(arc.prim_axis,arc.sec_axis)) )
      {
	/* if ellipse, then load axes into point set */
        index = ps.num_points * 3;

        points[index]   = arc.prim_axis * arc.rot_matrix[0] + arc.origin[0];
        points[index+1] = arc.prim_axis * arc.rot_matrix[4] + arc.origin[1];
        points[index+2] = arc.prim_axis * arc.rot_matrix[8] + arc.origin[2];

        ps.num_points += 1;
        index = ps.num_points * 3;

        points[index]   = arc.sec_axis * arc.rot_matrix[1] + arc.origin[0];
        points[index+1] = arc.sec_axis * arc.rot_matrix[5] + arc.origin[1];
        points[index+2] = arc.sec_axis * arc.rot_matrix[9] + arc.origin[2];

        ps.num_points += 1;
        index = ps.num_points * 3;

        points[index]   = -arc.prim_axis * arc.rot_matrix[0] + arc.origin[0];
        points[index+1] = -arc.prim_axis * arc.rot_matrix[4] + arc.origin[1];
        points[index+2] = -arc.prim_axis * arc.rot_matrix[8] + arc.origin[2];

        ps.num_points += 1;
        index = ps.num_points * 3;

        points[index]   = -arc.sec_axis * arc.rot_matrix[1] + arc.origin[0];
        points[index+1] = -arc.sec_axis * arc.rot_matrix[5] + arc.origin[1];
        points[index+2] = -arc.sec_axis * arc.rot_matrix[9] + arc.origin[2];

        ps.num_points += 1;
      }
    }

    /* project the given line onto the point set */
    MAlnpsproj(msg,line,&ps,ln_pt,keypoint,&t,&num);

    key_parms->leaf_id.objid = my_id;
    key_parms->leaf_id.osnum = OM_Gw_current_OS;

    if (num != 1)
    {
      BSprptoncv(&mess,ptr,keypoint,&(key_parms->u),&on_curve);

      if (mess != BSSUCC)
      {
        *msg = MSFAIL;
      }

      key_parms->v = 0.0;
      key_parms->polygon_inx = 0;
    }
    else
    {
      *msg = GR_PARM_NOT_VALID;
      key_parms->u = 0.0;
      key_parms->v = 0.0;
      key_parms->polygon_inx = 2;
    }
  }
  else
  {
    if( !( 1 & *msg ) )
    {
      OMmsg = OM_E_ABORT;               /* we failed to get geom.   */
    }
  }

  return( OMmsg );

} /* This has been an R.D.H. production!!! */

end implementation GRconic;

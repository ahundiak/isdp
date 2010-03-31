/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "OMmacros.h"
# include "gocmacros.h"
# include "bsparameters.h"
# include "bserr.h"
# include "EMSmsgdef.h"
# include "emserr.h"
# include "bsgeom_cvsf.h"

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

# define U 0
# define V 1

#define WBC_USE_NEW_MATH 1

method EMpratmpt (IGRlong *EMmsg;
                  IGRshort *mat_type;
                  IGRmatrix matrix;
                  IGRint numpts;
                  IGRdouble *xyzpts;
                  IGRdouble *uvpts;
                  IGRdouble *dists;
                  IGRdouble *mindistpts)

/*****************************************************************

Description

    This method gets the minimum distance points of the xyz points
    supplied on the surface and returns the u,v parameters of each
    of the minimum distance points.

    Input
      mat_type     -    pointer to the matrix type
      matrix       -    transformation matrix
      numpts	   -    number of points whose minimum distance point needs
                        to be determined
      xyzpts       -    points whose minimum distance point needs
                        to be determined
      

    Output
      EMmsg        -    pointer to the completion code
      uvpts        -    array of u and v parameters of the minimum distance
                        point. Space to be allocated by the user. Returned
                        as [u1, v1, u2, v2, ...]. If NULL on input, then
                        ignored.
      dists        -    array to the distances between xyz points and
                        the min-dist points. If NULL on input, then ignored.
      mindistpts   -    the minimum distance points. If NULL on input,
                        then ignored.

Notes:
  
    Upon exit the completion code will be one of the following
      EMS_S_Success       -  if successful
      EMS_I_OutOfBounds	  -  if the xyz points were off the surface by
			     more than the current chord-height tolerance.
      EMS_E_BSerror       -  indicating failure in the BS-math call
      EMS_E_Fail	  -  All other failures.
   
Algorithm
    
   1.   Get the abstract geometry of the surface.
   2.   Get the minimum distance point on the surface.

History
    WBC        :    01/13/93        Replaced the call to BSmdistptsf with a
                                    call to BSprptarrsf.
    NP         :    08/25/92        Modified for ANSI compliance. Added typecast in
				    GRgetabsg.
    SS         :    05/26/88        Changed the argument to accept
                                    more than one point for processing
    PP         :    01/20/87        Design date


***************************************************************/

{
  IGRint              num, i, j;
  IGRlong 	      status, rc, msg_loc;
  IGRdouble           chktol;
  struct              IGRbsp_surface *surface;
  struct BSgeom_bsp_surf  geom_surface;
  extern   IGRboolean BSmdistptsf();
  extern   IGRboolean BSfreecv();
  extern   void       BSprptarrsf(),
                      EFinit_geom_surface();

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chktol);
  geom_surface.sfgen_cv = NULL;

  GRgetabsg (&msg_loc, mat_type, matrix, (IGRchar **)&surface, num);
  EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

#if WBC_USE_NEW_MATH
  if (uvpts || mindistpts)
  {
    extern IGRdouble    BSdistptpt();
    IGRboolean	        onsrf;
    IGRshort            pts_code;

    EFinit_geom_surface(&msg_loc, surface, my_id, OM_Gw_current_OS,
                        &geom_surface);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if (uvpts && mindistpts)
      pts_code = 2;
    else if (uvpts)
      pts_code = 0;
    else
      pts_code = 1;

    BSprptarrsf(&geom_surface, chktol, pts_code, 0, &numpts, xyzpts, uvpts,
                mindistpts, &onsrf, NULL, &rc);
    EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    if (!onsrf)
      *EMmsg = EMS_I_OutOfBounds;

    if (dists)
    {
      numpts *= 3;

      for (i=0, j=0; i<numpts; i+=3, j++)
      {
        dists[j] = BSdistptpt(&rc, &xyzpts[i], &mindistpts[i]);
        EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }
    }
  }
#else
  {
    IGRdouble       mindist, uvpt[2], xyzpt[3];
    IGRint          j, k;
    IGRboolean	    bssts;

    for (i=0, j=0, k=0; i<numpts; i++, j+=2, k+=3)
      {
      bssts = BSmdistptsf (&rc, surface, &xyzpts[k], &uvpt[U], &uvpt[V],
               xyzpt, &mindist);
      EMerr_hndlr (!bssts || rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (mindist > chktol)
        *EMmsg = EMS_I_OutOfBounds;
      if (uvpts)
        OM_BLOCK_MOVE (uvpt, &uvpts[j], 2 * sizeof (IGRdouble));
      if (mindistpts)
        OM_BLOCK_MOVE (xyzpt, &mindistpts[k], 3 * sizeof (IGRdouble));
      if (dists)
        dists[i] = mindist;
      }
  }
#endif

wrapup:
  EMWRAPUP (*EMmsg, status, "EMSsubbs.EMpratmpt");

 if (geom_surface.sfgen_cv)
    BSfreecv(&rc, geom_surface.sfgen_cv);

  return (status);
}

end implementation EMSsubbs;

/* *****************************************************************************
 * I/VDS
 *
 * File:   vds/vdintersect/VDptsGetSfFr.I
 *
 * Description:
 *
 *      This file contains functions VDptsIntersection and VDptsProcess which
 *      intersect a surface with two frame systems. It is called by PPL file,
 *	VDptsGetSfFr.u, which supplies the inputs. The PPL file presents a
 *	form to control the processing through four toggles. See "Inputs"
 *	for detail.
 *
 * Inputs:
 *      o surface object/environment
 *      o frame system 1 object/environment
 *      o frame system 2 object/environment
 *	o 4 toggle states for,
 *	  1. processing sequence, either, surface/frame frame, or, frm/frm surf
 *	  2. display of intersection curves
 *	  3. display of intersection points
 *	  4. writing intersection points to the ascii file, ./IntPoints
 *
 * Note:
 *	The "reinforce string" is an array of frame numbers to select from
 *	a frame system to intersect with a surface. It is not used here.
 *
 * Note:
 *	Some intersecting elements may not intersect at one point, but, may
 *	intersect along a line. In this case, GRgetpolyline will fail and
 *	vd_$get_geometry is used to get the first pole of the line (bspline)
 *	as the intersection point.
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      09/09/97   ejm          CR 179701424: Get a list of points
 *                              resulting from surface/frame intersections,
 *                              using the vd$int2elem macro.
 *
 *      07/24/2001 HF           Inconsistent use of _MALLOC/_FREE
 **************************************************************************** */


class implementation  Root;

#include "stdio.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"   /* gr$get_module_env,  struct GRmd_env            */

#include "igetypedef.h"    /* typedef OM_S_OBJID GRobjid,                    */
			   /*      depends on OMminimum.h                    */
#include "igrtypedef.h"    /* IGRchar, IGRlong, etc                          */
#include "gr.h"            /* struct GRid, depends on igetypedef, igrtypedef */
#include "igr.h"           /* struct IGRbsp_curve                            */
#include "dp.h"            /* GRbd, display mode                             */
#include "growner.h"       /* struct GRobj_env                               */

#include "smAPImacros.h"   /* vds/include, sm$get_frs_from_frsys             */
			   /* sm = Surface Manager                           */

#include "vdAPImacros.h"   /* vd$int2elem                                    */
#include "v_geommacros.h"  /* vd_$get_geometry                               */
#include "v_miscmacros.h"  /* vd_$bulk_display                               */
#include "v_dbgmacros.h"   /* __DBGpr_obj                                    */

from  GRlinear    import  GRgetpolyline;

extern	UI_status();




IGRlong	VDptsIntersection (
  struct GRobj_env  surface_info,
  struct GRobj_env  frame1_info,
  struct GRobj_env  frame2_info,
  int seq_toggle, int crv_toggle, int pts_toggle, int out_toggle )
{
  int		m, n, num, lntotal, pttotal;
  IGRint	sts, msg;
  IGRint	intNum, intNum2;       /* Number of intersections            */
  IGRint	buffsize, buffbytes;   /* Size and bytes of module env       */
  IGRlong	n_frames1, n_frames2;
  IGRchar	reinforce[200],
		status_msg[200];

  struct GRid	*frames1,              /* List of frame id's                 */
		*frames2,
		*initialListId,        /* List of initial line inters id's   */
		*finalListId;          /* List of final point inters id's    */

  struct GRobj_env  frame_from_sys1,   /* Frame system1 object               */
		    frame_from_sys2,
		    first_int_lines;

  struct GRmd_env   md_env;            /* Current enviroment for line object */

  FILE		*filePtr;




  SetProc( VDptsIntersection ); Begin



  __DBGpr_obj("surface object", surface_info.obj_id);
  __DBGpr_obj("Frame system1 object", frame1_info.obj_id);
  __DBGpr_obj("Frame system2 object", frame2_info.obj_id);


  /* Initialization Block      */

  filePtr	= NULL;
  n_frames1	= 0;
  n_frames2 	= 0;
  frames1	= NULL;
  frames2	= NULL;
  reinforce[0]	= '\0' ;       /* No select frame list */
  initialListId = NULL;
  finalListId	= NULL;
  intNum	= 0;
  intNum2	= 0;
  lntotal	= 0;
  pttotal	= 0;
  sts		= OM_S_SUCCESS;



  if( out_toggle )
  {
    filePtr = fopen("IntPoints", "w");
    if( filePtr == NULL ){
      printf("\n\n  Can't open file, IntPoints; will process without writing points\n\n");
    }
  }

  /* Retrieve Frame Ids */

  sts=sm$get_frs_from_frsys( num_elm = &n_frames1,
                             fr_obj  = frame1_info.obj_id,
                             inforce = reinforce,
                             frames  = &frames1);
  if ( !(sts&1) ){
          printf ("Error in sm$get_frs_from_frsys1\n");
          goto wrapup;
  }

  sprintf(status_msg, "First Frame-System has %d frames", n_frames1 );
  UI_status( status_msg );


  reinforce[0] = '\0' ;
  sts=sm$get_frs_from_frsys( num_elm = &n_frames2,
                             fr_obj  = frame2_info.obj_id,
                             inforce = reinforce,
                             frames  = &frames2);
  if ( !(sts&1) ){
          printf ("Error in sm$get_frs_from_frsys2\n");
          goto wrapup;
  }

  sprintf(status_msg, "Second Frame-System has %d frames", n_frames2 );
  UI_status( status_msg );

  frame_from_sys1.mod_env = frame1_info.mod_env;
  frame_from_sys2.mod_env = frame2_info.mod_env;


  /* Get Environment for Display */

  buffsize = sizeof( md_env );
  sts = gr$get_module_env( msg     = &msg,
	                   sizbuf  = &buffsize,
			   buffer  = &md_env,
			   nret    = &buffbytes);

  first_int_lines.mod_env  = md_env;



if( seq_toggle == 0 )  /* XXXXXXXXXXXXXX Surf/Frm Frm Sequence XXXXXXXXXXXXXX */
{
  for( m=0; m < n_frames1; m++ )
  {
    __DBGpr_int("sys1_frame", m);

    frame_from_sys1.obj_id  = frames1[m];

    sts = vd$int2elem( elem1 = &surface_info,
                       elem2 = &frame_from_sys1,
                       trim1req = 2, /* natural boundaries      */
                       trim2req = 0, /* infinite graphic object */
                       NumbInt  = &intNum,
                       GRidInt  = &initialListId
                      );

    if (intNum == 0)  continue;

    lntotal += intNum;

    __DBGpr_objlist("    resulting line", intNum, initialListId);

    for(num=0; num<intNum; num++)
    {
      if( crv_toggle ){
	vd_$bulk_display( dpmode    = GRbd,  /* GRbd = background draw */
			  count     = 1,
			  grids     = &initialListId[num],
			  theEnv    = &md_env );
      }

      first_int_lines.obj_id = initialListId[num];

      /*
       * Intersect line with each frame of frame system 2
       */

      for( n=0; n < n_frames2; n++ )
      {
        __DBGpr_int("  sys2_frame", n);

        frame_from_sys2.obj_id  = frames2[n];

	sts = vd$int2elem( elem1 = &first_int_lines,
                           elem2 = &frame_from_sys2,
                           trim1req = 2,
                           trim2req = 0,
                           NumbInt  = &intNum2,
                           GRidInt  = &finalListId
                          );

	if (intNum2 == 0)  continue;

	pttotal += intNum2;

	__DBGpr_objlist("    intersection point", intNum2, finalListId);

	/*
	 * Process each intersection point
	 */

	if( !(crv_toggle) && !(pts_toggle) )
	{
          sprintf(status_msg, " Processing Frame %d (%d) / %d(%d)",
                                m, n_frames1, n, n_frames2 );
          UI_status( status_msg );
	}


	sts = VDptsProcess ( intNum2,
                             md_env,
                             finalListId,
                             pts_toggle,
                             out_toggle,
			     filePtr  );

	/* if( sts != 1 )  continue processing remaining intersections */

      } /* for n < n_frames2 */

    } /* for num < intNum */

    if( initialListId != NULL )  _FREE(initialListId);

  } /* for m < n_frames1 */

  __DBGpr_int("Total lines", lntotal);

  __DBGpr_int("Total points", pttotal);

} /* if seq_toggle = 0, Surf/Frm Frm */


else  /* XXXXXXXXXXXXXXXXXXXX Frm/Frm Surf Sequence XXXXXXXXXXXXXXXXXXXXXXXXX */
{
  for( m=0; m < n_frames1; m++ )
  {
    __DBGpr_int("sys1_frame", m);

    frame_from_sys1.obj_id  = frames1[m];

    for( n=0; n < n_frames2; n++ )
    {
      __DBGpr_int("  sys2_frame", n);

      frame_from_sys2.obj_id  = frames2[n];

      sts = vd$int2elem( elem1 = &frame_from_sys1,
                         elem2 = &frame_from_sys2,
                         trim1req = 0,
                         trim2req = 0,
                         NumbInt  = &intNum,
                         GRidInt  = &initialListId
                        );

      if (intNum == 0)  continue;

      lntotal += intNum;

      __DBGpr_objlist("    resulting line", intNum, initialListId);

      /*
       * Intersect line with surface
       */

      for(num=0; num<intNum; num++)
      {
	if( crv_toggle ){
	  vd_$bulk_display( dpmode    = GRbd,
			    count     = 1,
			    grids     = &initialListId[num],
			    theEnv    = &md_env );
        }

	first_int_lines.obj_id = initialListId[num];

	sts = vd$int2elem( elem1 = &first_int_lines,
                           elem2 = &surface_info,
                           trim1req = 0,
                           trim2req = 2,
                           NumbInt  = &intNum2,
                           GRidInt  = &finalListId
                          );

	if (intNum2 == 0)  continue;

	pttotal += intNum2;

	__DBGpr_objlist("    intersection point", intNum2, finalListId);

	/*
	 * Process each intersection point
	 */

	if( !(crv_toggle) && !(pts_toggle) )
	{
          sprintf(status_msg, " Processing Frame %d (%d) / %d(%d)",
                                m, n_frames1, n, n_frames2 );
          UI_status( status_msg );
	}

	sts = VDptsProcess ( intNum2,
                             md_env,
                             finalListId,
                             pts_toggle,
                             out_toggle,
			     filePtr  );

	/* if( sts != 1 )  continue processing remaining intersections */

      } /* for num < intNum */

      if( initialListId != NULL )  _FREE(initialListId);

    } /* for n < n_frames2 */

  } /* for m < n_frames1 */

  __DBGpr_int("Total lines", lntotal);

  __DBGpr_int("Total points", pttotal);

} /* else seq_toggle = 1, Frm/Frm Surf */




wrapup:

  if( out_toggle ){
    if( filePtr != NULL )  fclose(filePtr);
    filePtr = NULL;
  }

  if( frames1 != NULL )  free(frames1);
  if( frames2 != NULL )  free(frames2);

  if( initialListId != NULL )  _FREE(initialListId);

  End

  return sts;

} /* VDptsIntersection */


IGRint 	VDptsProcess ( int intNum2,
		       struct GRmd_env md_env,
		       struct GRid *finalListId,
		       int pts_toggle,
		       int out_toggle,
		       FILE *filePtr )
{
  int			i, num2;
  IGRint		action;        /* 0, get num_points, 1, get polyline */
  IGRint		sts;
  IGRlong		l_msg;
  IGRdouble		pt[3], points[3];
  struct IGRpolyline	polyline;
  struct IGRbsp_curve	*bspcurve;



  SetProc( VDptsProcess ); Begin


  sts      = OM_S_SUCCESS;
  l_msg    = OM_S_SUCCESS;
  num2     = 0;
  bspcurve = NULL;


  for(num2=0; num2<intNum2; num2++)
  {
    if( pts_toggle ){
      vd_$bulk_display( dpmode    = GRbd,
		        count     = 1,
		        grids     = &finalListId[num2],
		        theEnv    = &md_env );
    }

    action = 0; /* Check num_points first to determine what processing  */
	        /* comes next                                           */
    sts =
      om$send(msg=message GRlinear.GRgetpolyline( &l_msg,
		  &md_env.md_env.matrix_type,
		  md_env.md_env.matrix,
		  &action,
		  &polyline),
              senderid = NULL_OBJID,
              targetid = finalListId[num2].objid,
              targetos = finalListId[num2].osnum
      );

    if( !(sts&l_msg&1) ){
      printf("\n 1st GRgetpolyline failed, will get geometry to determine");
      printf(" intersection\n");

      /* Intersection not a point, see if it's a line (curve) */
      sts = vd_$get_geometry( msg      = &l_msg,
			      grobjId  = &finalListId[num2],
			      grobjEnv = &md_env,
			      geometry = &bspcurve );

      if( !(sts&l_msg&1) ){
        printf("\n  vd_$get_geometry failed, can't determine intersection");
        printf("\n");
        goto wrapup;
      }
      else{
        if( bspcurve->num_poles == 0 ){
          printf("\n  num_poles = 0, can't determine intersection\n");
          goto wrapup;
        }
        else{
          if( out_toggle ){
              fprintf( filePtr, "%lf  %lf  %lf\n", bspcurve->poles[0],
	 	       bspcurve->poles[1], bspcurve->poles[2]);
          }
          continue;
        }
      } /* if 1st GRgetpolyline sts = 1 */
    } /* if 1st GRgetpolyline failed */

    if( polyline.num_points == 0 ){
      printf("\n  No points found for point id %d\n", finalListId[num2]);
      goto wrapup;
    }
    if( polyline.num_points > 1 ){
      printf("\n  More than one point found for point id %d\n",
		  finalListId[num2]);
      goto wrapup;
    }

    action = 1; /* Now try to get polyline */

    polyline.points = pt;
    sts =
      om$send(msg=message GRlinear.GRgetpolyline( &l_msg,
		  &md_env.md_env.matrix_type,
		  md_env.md_env.matrix,
		  &action,
		  &polyline),
              senderid = NULL_OBJID,
              targetid = finalListId[num2].objid,
              targetos = finalListId[num2].osnum
      );
    if( !(sts&l_msg&1) ){
      printf("\n  2nd GRgetpolyline failed");
      printf("\n  no intersection point obtained for point id %d\n",
	          finalListId[num2].objid);
      goto wrapup;
    }

    for(i=0;i<3;i++)
    {
      points[i] = polyline.points[i];
    }

    if( out_toggle )
       fprintf( filePtr, "%lf  %lf  %lf\n", points[0], points[1], points[2]);

  } /* for intNum2 (each intersection point) */

wrapup:


  if( finalListId   != NULL )  _FREE(finalListId);

  if( bspcurve      != NULL )  _FREE(bspcurve);

End

return sts;

} /* VDptsProcess */

end implementation  Root;

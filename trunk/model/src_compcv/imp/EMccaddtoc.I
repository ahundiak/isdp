class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "grerr.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "emserr.h"
#include "emsdig.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsdistptpts.h"
#include "bsparameters.h"

method EMaddtocomp(IGRlong		*msg;
		   struct GRid		 add_obj;
		   struct GRmd_env	*objModuleInfo;
		   struct GRmd_env	*myModuleInfo;
		   IGRboolean		 inter_allowed;
		   IGRdouble		 search_tol;
		   IGRdouble		 connect_tol;
		   IGRboolean		 valid_end_pnt;
		   IGRpoint		 comp_start;
		   IGRpoint		 comp_stop;
		   IGRlong		*comp_so_far)
/*
Abstract
	This method adds a valid curve object to an already existing
	composite curve. Now we can add composite curve objects
	to composites.

     NOTES:
	1.	  If the argument valid_end_pnt is TRUE, my end points
	 	end points are not generated.

	2.	  If *comp_so_far is > 0, this method assumes the incoming
		value to be the number of components.

	3.	  If the incoming object is a composite curve,
		the following should happen:
			. transfer the ownership of the components to
			  'me'.
			. delete the incoming composite object.

History
	gk	01/16/87	creation date
	gk	02/03/87	incoming composite curve is invalid;
				due to consistency considerations. No longer true--dhm
	rlw	05/08/87	Remove continuity stuff and added post
    DLB 10/28/87    mod for version 1.1.0
	gk  11/??/87	modified to allow composites to be added
	dhm 12/07/87	added code to extend to intersection
    dhm 02/19/88    fixed to perform the correct link case no matter
                    how large the search tol is.
        rlw	07/20/88	Modified such that linking the stop point of
				the existing element to the start point of the
				adding element is given maximum priority.
	Sudha	06/21/93	modified for BSprototype ansification
*/

#define	IS	==
#define AND	&&
#define OR	||
#define NOT	!

{
  IGRchar 		errmsg[EMMAXERRMSG_LEN];
 extern  IGRlong  EMextend_to_int();
  IGRlong 		status = OM_S_SUCCESS, numb_children, i,
			    loc_msg, chan_index, link_case;
  IGRdouble		ele_start[3], ele_stop[3],
                distance_tol, connect_tol_sq, end_dist, dist[4];
  OM_S_CHANSELECT	to_components;
  IGRboolean		reverse_parametrization;
  extern OMuword 	OPP_GRcompcurve_class_id;
  OMuword		add_obj_class_id;
  IGRpoint      ext_pnt, endpnt2_to_ext, endpnt1_to_ext, spnt, epnt;
  struct GRid   obj1, obj2, my_GRid;
  struct GRparms	parm1, parm2;

/* Initialize */

  *msg = MSSUCC;
  strcpy(errmsg, "GRcompcurve.EMccaddtoc");
  connect_tol_sq = connect_tol * connect_tol;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

/* Set up the channel select */

  status = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMomerr_hndlr(status, wrapup, errmsg);


/* Get my end points. No point continuing further if I am closed */

  if( ! valid_end_pnt )
  {
     status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
		   		    &myModuleInfo->md_env.matrix_type,
		    		     myModuleInfo->md_env.matrix,
				     comp_start, comp_stop),
	  	      targetid = my_id);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);
  }

  if( BSdistptpts(&loc_msg, comp_start, comp_stop ) < connect_tol_sq )
  {
     *msg = GRILLDEFINITION;
     return(status);
  }


/* If the incoming object is closed one, no point continuing further */

  status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
				 &objModuleInfo->md_env.matrix_type,
				  objModuleInfo->md_env.matrix,
				  ele_start, ele_stop),
		   targetid = add_obj.objid,
		   targetos = add_obj.osnum);
  EMomerr_hndlr(status, wrapup, errmsg);
  EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

  if( BSdistptpts(&loc_msg, ele_start, ele_stop ) < connect_tol_sq )
  {
     *msg = MSFAIL;
     return(status);
  }


  /*
   * Check the distances between the composite start
   * and stop points and the element's start and stop
   * points.  Add the element to the begin or end of
   * the composite, reversing where necessary, depending
   * and which distance is smallest.  dhm 2/19/88
   */

  distance_tol = ( inter_allowed ) ? (search_tol*search_tol) :
                                      connect_tol_sq;

  dist[0] = BSdistptpts(&loc_msg, comp_stop, ele_start);
  dist[1] = BSdistptpts(&loc_msg, comp_stop, ele_stop);
  dist[2] = BSdistptpts(&loc_msg, comp_start, ele_stop);
  dist[3] = BSdistptpts(&loc_msg, comp_start, ele_start);

  end_dist = distance_tol;
  for (i = 0; i < 4; i++)
  {
    if (dist[i] < end_dist)
    {
      end_dist = dist[i];
      link_case = i + 1;
      if (end_dist < connect_tol_sq) break;    /* rlw - 07/21/88 */
    }

  }

  if (end_dist >= distance_tol)   /* end points not close enough */
  {
    /* dont let this fail so easily, get this baby moving, so add one more check TR-179800681 */
    IGRdouble 	offsetVal;
    status  = BSEXTRACTPAR( &loc_msg, BSTOLOFFSET, offsetVal );
    if( end_dist >= offsetVal )
    {
      *msg = MSFAIL;
      return(status);
    }
  }



/*
   We have finished all the processing. Need to connect the object to
   the composite and update composite curve end points.
*/

  if(link_case IS 1)
  {
     chan_index = GRDGNLIMITS_MAX_I;
     reverse_parametrization = FALSE;
     comp_stop[0] = ele_stop[0];
     comp_stop[1] = ele_stop[1];
     comp_stop[2] = ele_stop[2];
  }
  else if(link_case IS 2)
  {
     chan_index = GRDGNLIMITS_MAX_I;
     reverse_parametrization = TRUE;
     comp_stop[0] = ele_start[0];
     comp_stop[1] = ele_start[1];
     comp_stop[2] = ele_start[2];
  }
  else if(link_case IS 3)
  {
     chan_index = 0;
     reverse_parametrization = FALSE;
     comp_start[0] = ele_start[0];
     comp_start[1] = ele_start[1];
     comp_start[2] = ele_start[2];
  }
  else if(link_case IS 4)
  {
     chan_index = 0;
     reverse_parametrization = TRUE;
     comp_start[0] = ele_stop[0];
     comp_start[1] = ele_stop[1];
     comp_start[2] = ele_stop[2];
  }

/* How many components do I have so far? */

  if( *comp_so_far <= 0 )
  {
     status = om$send(msg = message GRowner.GRget_number_components(
                            &loc_msg, (int *) comp_so_far),
                      targetid = my_id);       /* must have >= 1 */
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);
  }

/* Do we need to reverse parametrization of the element ? */

  if( reverse_parametrization )
  {
     status = om$send(msg = message GRcurve.GRrevparm(&loc_msg,
                            objModuleInfo),
		      targetid = add_obj.objid,
		      targetos = add_obj.osnum);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);
  }

  /*
   * Get the classid of the add_obj for future use.
   */

  status = om$get_classid(osnum = add_obj.osnum,
                          objid = add_obj.objid,
                          p_classid = &add_obj_class_id);
  EMomerr_hndlr(status, wrapup, errmsg);

/*  dhm  12/07/87
   if intersection is allowed, compare the end_dist with connect_tol_sq.
  	 if end_dist < connect_tol_sq no need for further processing
	 otherwise, intersect the appropriate objects, modify their
	 end points and post them  -- done in EMextend_to_int()
*/

  if (inter_allowed AND (end_dist > connect_tol_sq))
  {
     status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                            &myModuleInfo->md_env.matrix_type,
                            myModuleInfo->md_env.matrix,
                            spnt, epnt),
                      targetid = my_id);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

     if ((link_case == 1) || (link_case == 2))
     {
        status = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_components,
                                       index = ((*comp_so_far) - 1),
                                       objidaddr = &obj1.objid,
                                       osnumaddr = &obj1.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);

        parm1.u = 1.0;

        if (add_obj_class_id == OPP_GRcompcurve_class_id)
        {
           status = om$get_objid_at_index(osnum = add_obj.osnum,
                                          objid = add_obj.objid,
                                          p_chanselect = &to_components,
                                          index = 0,
                                          objidaddr = &obj2.objid,
                                          osnumaddr = &obj2.osnum);
           EMomerr_hndlr(status, wrapup, errmsg);
        }
        else
        {
           obj2.objid = add_obj.objid;
           obj2.osnum = add_obj.osnum;
        }

        parm2.u = 0.0;

        endpnt1_to_ext[0] = epnt[0];
        endpnt1_to_ext[1] = epnt[1];
        endpnt1_to_ext[2] = epnt[2];

        status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                               &objModuleInfo->md_env.matrix_type,
                               objModuleInfo->md_env.matrix,
                               spnt, epnt),
                        targetid = obj2.objid,
                        targetos = obj2.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);
        EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

        endpnt2_to_ext[0] = spnt[0];
        endpnt2_to_ext[1] = spnt[1];
        endpnt2_to_ext[2] = spnt[2];
     }
     else  /* it's 3 or 4 */
     {
        status = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_components,
                                       index = 0,
                                       objidaddr = &obj1.objid,
                                       osnumaddr = &obj1.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);

        parm1.u = 0.0;

        if (add_obj_class_id == OPP_GRcompcurve_class_id)
        {
           status = om$send(msg = message GRowner.GRget_number_components(
                                  &loc_msg, (int *) &numb_children),
                            targetid = add_obj.objid,
                            targetos = add_obj.osnum);
           EMomerr_hndlr(status, wrapup, errmsg);
           EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

           status = om$get_objid_at_index(osnum = add_obj.osnum,
                                          objid = add_obj.objid,
                                          p_chanselect = &to_components,
                                          index = (numb_children - 1),
                                          objidaddr = &obj2.objid,
                                          osnumaddr = &obj2.osnum);
           EMomerr_hndlr(status, wrapup, errmsg);
        }
        else
        {
           obj2.objid = add_obj.objid;
           obj2.osnum = add_obj.osnum;
        }

        parm2.u = 1.0;

        endpnt1_to_ext[0] = spnt[0];
        endpnt1_to_ext[1] = spnt[1];
        endpnt1_to_ext[2] = spnt[2];

        status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                               &objModuleInfo->md_env.matrix_type,
                               objModuleInfo->md_env.matrix,
                               spnt, epnt),
                        targetid = obj2.objid,
                        targetos = obj2.osnum);
        EMomerr_hndlr(status, wrapup, errmsg);
        EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

        endpnt2_to_ext[0] = epnt[0];
        endpnt2_to_ext[1] = epnt[1];
        endpnt2_to_ext[2] = epnt[2];
     }

     status = EMextend_to_int(&loc_msg, myModuleInfo, &obj1, &obj2,
                              &parm1, &parm2, distance_tol, TRUE, TRUE,
                              endpnt1_to_ext, endpnt2_to_ext, ext_pnt);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr( (loc_msg != MSSUCC), *msg, loc_msg, wrapup);

  }  /* end if int_allowed */


  /*
   * If the incoming object is composite,
   * then get its component ids.
   */

  if (add_obj_class_id IS OPP_GRcompcurve_class_id)
  {
     struct GRid	*ids_array;
     ids_array = NULL;

     status = om$send(msg = message GRowner.GRget_number_components(
                            &loc_msg, (int *) &numb_children),
                      targetid = add_obj.objid,
                      targetos = add_obj.osnum);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup1);

     ids_array = (struct GRid *)  om$malloc(size = numb_children *
                                            sizeof(struct GRid) );
     EMerr_hndlr(!ids_array, *msg, MSNOMEM, wrapup1);

     status = om$send(msg = message GRowner.GRget_components(&loc_msg,
                            objModuleInfo, ids_array, numb_children,
                            (int *) &i, 0, OM_K_MAXINT),
                      targetid = add_obj.objid,
                      targetos = add_obj.osnum);
     EMomerr_hndlr(status, wrapup1, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup1);

     status = om$send( msg = message GRowner.GRdrop(&loc_msg,
                             objModuleInfo),
		       targetid = add_obj.objid,
		       targetos = add_obj.osnum);
     EMomerr_hndlr(status, wrapup1, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup1);

     /*
      * If addition is at the start,
      * then need to reverse the adding order
      */

     if ( (link_case IS 1) OR (link_case IS 2) )
     {
        for (i = 0; i < numb_children; i++)
        {
            /******Added for version 1.1.0 -DLB*******************/

            status = om$send(msg = message GRconnector.GRrigidconn(
                                   &loc_msg, &my_GRid, &chan_index),
                             targetid = ids_array[i].objid,
                             targetos = ids_array[i].osnum);
            EMomerr_hndlr(status, wrapup1, errmsg);
            EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup1);
        }
     }
     else  /* add to start */
     {
        for (i = numb_children - 1; i > -1; i--)
	    {
            /******Added for version 1.1.0 -DLB*******************/

            status = om$send(msg = message GRconnector.GRrigidconn(
                                   &loc_msg, &my_GRid, &chan_index),
                             targetid = ids_array[i].objid,
                             targetos = ids_array[i].osnum);
            EMomerr_hndlr(status, wrapup1, errmsg);
            EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup1);
	    }
     }

wrapup1:
     if(ids_array)  om$dealloc(ptr = ids_array);
     EMomerr_hndlr(status, wrapup, " ");

  }   /* end if add_obj is GRcompcurve */
  else
  {
     /******Added for version 1.1.0 -DLB*******************/

     status = om$send(msg = message GRconnector.GRrigidconn(&loc_msg,
                            &my_GRid, &chan_index),
                      targetid = add_obj.objid,
                      targetos = add_obj.osnum);
     EMomerr_hndlr(status, wrapup, errmsg);
     EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

     numb_children = 1;
  }

/*
 * Post the abstract data
 */
 {
  IGRchar	*geometry;
  GRobjid	new_id;
  struct	GRpost_info info;

  geometry = NULL;
  info.construct_flag = FALSE;
  status = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRpostabsg(
                    msg,
                    myModuleInfo,
                    &info,
                    geometry,
                    &new_id),
                  senderid = my_id,
                  targetid = my_id);
  EMomerr_hndlr(status, wrapup, errmsg);
 }

  *comp_so_far + = numb_children;

wrapup:
  return(status);
}

end implementation GRcompcurve;

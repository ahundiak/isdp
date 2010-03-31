#ifndef mdmacros_include
#define mdmacros_include

/*
 * Name
 *    md$get_surf_tan_crv_ptloc
 *
 * Description
 *    Given a u,v parameter pair, this function returns the model space point,
 *    tangent vector, curvature as indicated by type_flag, and the point
 *    location information on a given surface.
 *
 * Arguments
 *    struct GRid   GRid_in     objid and osnum of the input surface.
 *    IGRdouble     parm_pnt[2] input u,v parameter pair on the surface.
 *    IGRpoint      outpoint    output model space point. NULL if not needed.
 *    IGRvector     tan[2]      output tangent vector at uparm and vparm.
 *                              tan[0] = tangent vector in u direction.
 *                              tan[1] = tangent vector in v direction.
 *                              NULL if not needed.
 *    unsigned int  crv_type    input type of curvature desired.
 *                              0 - radius of curvature (inverse of principal
 *                                  max curvature)
 *                              1 - Gaussian curvature
 *                              2 - Mean
 *                              3 - Principal max
 *                              4 - Principal min
 *                              5 - Absolute
 *    IGRdouble     *crv        output curvature value at uparm, vparm.
 *                              NULL if not needed.
 *    IGRint        *pt_location_flag   output flag to indicate if given point
 *                                      is in the "solid" or "hole" portion or
 *                                      on the boundary. NULL if not needed.
 *                                      Returned values are:
 *                                      EMS_L_ONEDGE
 *                                      EMS_L_ONVRTX   (defined in 
 *                                      EMS_L_INAREA    EMSbnddef.h)
 *                                      EMS_L_INHOLE
 *                                      EMS_L_UNKNWN
 *    IGRshort      *num_edges  output number of edges closest to the input
 *                              point on the surface.  NULL if not needed.
 *    GRobjid       *edge_id    output objid(s) of the nearest edge(s) to the
 *                              input point on the surface. NULL if not needed.
 *                              If specified, then num_edges must be specified.
 *                              Alloc memory as follows:
 *                                edge_id[MAX_LOCATED_EDGES] (defined in
 *                                                            EMSbnddef.h)
 *    IGRdouble     near_pt[][2] output u,v pair(s) of the projected point on 
 *                               the nearest edge(s).  NULL if not needed.
 *                               If specified, num_edges must be specified.
 *                               Alloc memory as follows:
 *                                 near_pt[MAX_LOCATED_EDGES]
 * History
 *    dhm    11/06/91    creation date.
 */

#omdef   md$get_surf_tan_crv_ptloc(GRid_in,
                                   parm_pnt,
                                   outpoint = NULL,
                                   tan = NULL,
                                   crv_type = 0,
                                   crv = NULL,
                                   pt_location_flag = NULL,
                                   num_edges = NULL,
                                   edge_id = NULL,
                                   near_pt = NULL)

#if (! (om$specified(GRid_in) || om$specified(parm_pnt)))
#   omerror "Must specify GRid_in and parm_pnt"
#else

#if ( om$specified(edge_id) && !om$specified(num_edges) )
#   omerror "If edge_id is specified, then num_edges must be specified"
#else

#if ( om$specified(near_pt) && !om$specified(num_edges) )
#   omerror "If near_pt is specified, then num_edges must be specified"

#else
    MDget_surf_tan_crv_ptloc(GRid_in, parm_pnt, outpoint, tan, crv_type,
                             crv, pt_location_flag, num_edges, edge_id,
                             near_pt);
#endif
#endif
#endif

#endomdef

#endif

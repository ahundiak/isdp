/*****************************************************************************

  Description :

              Macros for wireframe related functions in 'EMS'.

  Creation :

  Vadiraj M.R. -  long ago.

*****************************************************************************/


#ifndef EMSwire_func_macros
#define EMSwire_func_macros

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) ()
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef go_include
#include "go.h"
# endif
#ifndef exdef_include
#include "exdef.h"
# endif
#ifndef ex_include
#include "ex.h"
# endif
#ifndef emsinterdef_include
#include "emsinterdef.h"
# endif
#ifndef emsinter_include
#include "emsinter.h"
# endif
# ifndef emssfintdef_include
#include "emssfintdef.h"
# endif
# ifndef emsdef_include
#include "emsdef.h"
# endif
# ifndef griodef_include
#include "griodef.h"
# endif
#ifndef grio_include
#include "grio.h"
# endif
#ifndef godef_include
#include "godef.h"
# endif
#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
# endif
# ifndef emserr_include
#include "emserr.h"
# endif
#ifndef dp_include
#include "dp.h"
# endif
#ifndef emsmapdef_include
#include "emsmapdef.h"
# endif
#ifndef OM_D_MINIMUM
#include "OMminimum.h"
# endif
# ifndef emsbool_include
#include "emsbool.h"
# endif
# ifndef emssfcvs_include 
#include "emssfcvs.h"
# endif

extern IGRboolean EFplace_line_string __((OM_S_OBJID my_id,
                                   struct GRvg_construct *construct_list,
                                   IGRlong number_of_points,
                                   IGRpoint points[],
                                   OM_S_OBJID *objid,
                                   IGRlong *msg));

extern void EFstroke_line_string __((IGRlong *msg,
                              struct IGRbsp_surface *sf_geom,
                              IGRdouble par_tol, IGRlong *num_pts,
                              IGRdouble **xyzpts, IGRdouble **uvpts));

extern IGRint EMmake_surface_curves __((struct IGRbsp_curve *curve,
                                 struct EMScurveinfo *curve_info,
                                 struct EMSinvoker_info *invoker_info)); 
#if defined(__cplusplus)
}
#endif

#undef __

/**********************************************************************

    Description :

    This macro creates a linestring which passes through the input
    points.  Returns either TRUE or FALSE depending on whether a
    line string object was constructed successfully or not.

    IGRlong *msg        -  Output:
                           Message return code.
                           -MSSUCC,
                            if successful.
                           -MSFAIL,
                            in case a math routine fails or 
                            a failure to construct the object.

    OM_S_OBJID senderid -  Input:
                           The objectid, a method of which is
                           calling this macro to place a line
                           line string.
                           Can be NULL_OBJID.

    IGRlong number_of_points
                        -  Input:
                           A count of the number of points
                           passed in, a line string passing
                           through which is sought for.

    IGRpoint points[]   -  Input:
                           Points through which a line string
                           is to be passed.

    struct GRvg_construct *construction_args
                        -  Input:
                           Construction list for the object to
                           be constructed.

    OM_S_OBJID *objid   -  Output:
                           The objid of the line string object
                           constructed.          
**********************************************************************/
#omdef ems$place_line_string (msg,
                              senderid = NULL_OBJID,
                              number_of_points,
                              points,
                              construction_args,
                              objid)
EFplace_line_string ((senderid), (construction_args), (number_of_points),
                     (points),
                     (objid), (msg))
#endomdef

/***************************************************************************

        Description :

        This macro is used to stroke a given line string.
        It is assumed that the end points of the incoming
        linestring lie onto the surface.

        The uvlinstring's segments are evaluated at their mid points.
        If this mid point is away from the corresponding model space
        line segment by more than chord_height tolerance, a point is
        inserted at the middle of the model space line_segment. This
        process is repeated until each linsegment is within chord_height
        tolerance of its uv counterpart.

        ARGUMENTS :
       
        IGRlong *msg    -  Output:
                           Message return code.
                           -EMS_S_Success,
                            if stroking is successful.
                           -EMS_E_Fail,
                            if stroking fails.
                           -EMS_E_BSerror,
                            if a call to a math routine
                            fails.
        struct IGRbsp_surface *surface
                        -  Input:
                           The surface, w.r.t the UV-space of which the
                           given line string is stroked.

        IGRdouble partolbasis
                        -  Input:
                           Parametric basis tolerance for the given
                           surface.

        IGRlong *num_points
                        -  Input:
                           The number of xyz and uv points on the
                           incoming line string. May change after
                           stroking.  See the description above.

        IGRdouble **xyz_points
                        -  Input:
                           The points on the incoming line string
                           in the model space.

        IGRdouble **uv_points
                        -  Input:
                           The points on the incoming line string
                           in the parametric space.   
***************************************************************************/
#omdef ems$stroke_line_string (msg,
                               surface,
                               partolbasis,
                               num_points,
                               xyz_points,
                               uv_points)
EFstroke_line_string ((msg), (surface), (partolbasis), (num_points),
                      (xyz_points),
                      (uv_points))
#endomdef

/****************************************************************************

        Description :

        The following macro accepts a curve geometry, constructs a curve
  object (or uses the supplied shell objid) and applies the supplied
  message if any to that curve. If a new object is constructed it is returned
  via the supplied pointer. 

        ARGUMENTS :

        struct IGRbsp_curve *curve   -  Input:
                                        The curve geometry being input
                                        for which an object is to be 
                                        constructed.

        struct EMScurveinfo *curve_info
                                     -  Input:
                                        Contains information about
                                        the curve, needed in 
                                        constructing a curve object.
                                        Refer to the header file
                                        modelsrc/include/emssfcvs.h
                                        for info. on structure
                                        EMScurveinfo.

        struct EMSinvoker_info *invoker_info
                                     -  Input:
                                        Contains information on 
                                        the type of curve to be
                                        constructed.
                                        Refer to the header file
                                        modelsrc/include/emssfcvs.h
                                        for info. on structure
                                        EMSinvoker_info.

       NOTES :

       A curve object gets constructed only if it is a general curve.
       If the order of the incoming curve is 2, then the function
       EFplace_line_string is called to construct the object. 
   
****************************************************************************/
#omdef ems$make_surface_curves (curve,
                                curve_info,
                                invoker_info)
EMmake_surface_curves ((curve), (curve_info), (invoker_info))
#endomdef
#endif 

class specification EMSchatch (2:0) of EMSgradata;

/*
Abstract

    This class represents cross hatching as rule lines on a
    transformed cross sectional plane.  The actual plane is
    left unrotated and its boundaries are left in tact. This
    object stores the transformation information and performs
    the transformation whenever needed. For paramtric results,
    it works in the space of the untransformed plane, then
    transforms the results to the space of the transformed
    plane.

History

    RC, AIC     01/11/89    Modified instance data to allow 
                            material cross_hatch patterns. Also,
                            changed the implementations and the
                            arguments of some of the messages.
    AIC         02 Jan 1989 Removed override of Root.delete.
    RC          10/20/88    Added message EMgetdef.
    RC          12/04/87    Modified the instance data and
                            arguments to EMputdef and overrode EMdelete.

    15 October 87   AIC     Conversion to EMS 1.1

    AIC, RC     September 1, 1987   Creation Date
*/

# include "EMSchatch.h"

# define CROSS_HATCH_PLANE_BUFFER_SIZE      360
# define DBL_CROSS_HATCH_PLANE_BUFFER_SIZE   45

instance EMSchatch
{
  IGRdouble                         angle;
  IGRdouble                         origin[3];
  IGRshort                          num_u_sgrps;
  IGRshort                          num_v_sgrps;
  variable struct EMSxh_sgrp_info   sgrp_info[];
};

message EMputdef (IGRlong                 *EMmsg;
                  struct  EMSxh_info      xh_info);

/*
  Motivation:
        Put the cross hatching information in its 
        instance data
*/

message EMgetdef (IGRlong           *EMmsg;
                  struct EMSxh_info *xh_info);

/*
  Motivation:
        Get the cross hatching information in its 
        instance data
*/

override

    EMgetGraphics,
    /*
        Motivation
            Return the transformed surface geometry.
    */

    EMexecuteCurveFunction,
    /*
        Motivation:
            Use the transformed surface geometry.
    */

    EMget_class_info,
    /*
        Motivation:
            Return my_classis and EMputdef message.
    */

    EMupdate,
    /*
        Motivation:
            Get the rule lines from myself.
    */

    EMlocate,
    /*
        Motivation:
            Use transformed surface geometry
    */

    EMkeypoint,
    /*
        Motivation:
            Use transformed surface geometry
    */

    EMdisplay,
    /*
        Motivation:
            Use transformed surface geometry
    */

    EMclip;
    /*
        Motivation:
            Get the clip points in the parametric space of the
            transformed surface for the boundaries in the parametric
            space of the untransformed surface.
    */

end specification EMSchatch;

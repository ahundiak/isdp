/* ###################   APOGEE COMPILED   ################## */
class implementation GRgraphics;

# include "EMS.h"           /* for sharables */
# include "dperr.h"

# ifndef DRAFT112
# define DRAFT112 0
# endif

/*
DESCRPTION

This function displays a line string w/o creating an object.

ARGUMENTS
  
IGRlong     num_pnts;           How many points?
IGRpoint    pnts[];             The points
int         draw_background;    Draw in background?
  
Also used:
  
struct IGRdisplay   thisActiveDisplay
struct GRmd_env     thisModuleInfo
OM_S_OBJID          thisId
  
HISTORY

30 Jan 1990 SS  Return EMS_I_Interrupt if DPSTOPDRAW id returned from the
                call to dp$display
27 Jan 1989 jBk Moved inclusion of EMS.h to beginning of
                implementation.
29 Aug 1988 jBk Modified to use dp$build_dis_buffer and
                dp$display instead of directly assigning fields
                of element display headers and directly sending
                message IGEdisplay.DPdisbybuf.
                Changed from implementation of Root to
                implementation of GRgraphics.
03 Dec 1986 jBk Changed from making polyline to bspline curve.
15 Oct 1986 DLB 4.0 conversion.
?? Sep 1986 jBk Creation date.  This was largely borrowed from
                Richard L. Watson's LOCAL_DISPLAY macro.
*/

# include "OMerrordef.h"    /* OM error code defintions */

# include "dpdef.h"         /* dpmacros.h */
# include "dpmacros.h"      /* dp$display dp$build_dis_buffer */

# include "EMSlogic.h"      /* ISNT */
# include "EMSmsgdef.h"     /* EMS_E_InvalidArg */

# define PointCapacity 126
# define NumLocalKnots (PointCapacity + 2)

IGRlong ECdisplayPointSetByBuffer (
    msg, thisActiveDisplay, thisModuleInfo, thisId, num_pnts,
    pnts, draw_background
)
IGRlong             *msg;
IGRlong             num_pnts;
IGRpoint            pnts[];
IGRboolean          draw_background;
struct IGRdisplay   thisActiveDisplay;
struct GRmd_env     thisModuleInfo;
OM_S_OBJID          thisId;
{
    IGRlong ECdisplayPointSetByBuffer0 ();

    *msg = EMS_S_Success;
    if (!num_pnts) return(OM_S_SUCCESS);

    return ECdisplayPointSetByBuffer0
        (msg, thisActiveDisplay, thisModuleInfo, thisId,
        num_pnts, pnts, (draw_background ? GRbd : GRbe), IGRPY);
}

IGRlong ECdisplayPointSetByBuffer0 (
    msg, thisActiveDisplay, thisModuleInfo, thisId, numPnts,
    pnts, mode, type
)
IGRlong             *msg;
IGRlong             numPnts;
IGRpoint            pnts[];
struct IGRdisplay   thisActiveDisplay;
struct GRmd_env     thisModuleInfo;
OM_S_OBJID          thisId;
enum                GRdpmode mode;
IGRshort            type;
{
    int     ii ,number_of_elements;
    struct  DPele_header displayHeader;
    struct  IGRpointset point_set;
    struct  IGRbsp_curve curve;
    IGRdouble localKnots[NumLocalKnots];
    struct  IGResbc cvElementSpecific;
    IGRlong omrc = OM_S_SUCCESS;
    IGRshort localType;
    IGRlong localNumPoints;
    GRrange range;

    localNumPoints = numPnts;
    localType = type;

    *msg = EMS_S_Success;
    if (!localNumPoints) return(OM_S_SUCCESS);

    if (localNumPoints < 2) localType = IGRPS;
    /* the above is meant to be an assignment */

    if (localType IS IGRPY OR localType IS IGRBC)
    {
        curve.order = 2;
        curve.periodic = FALSE;
        curve.non_uniform = FALSE;

        curve.poles = pnts[0];
        curve.knots = localKnots;

        if (localNumPoints > PointCapacity)
        {
            omrc = ECdisplayPointSetByBuffer0 (
                msg,
                thisActiveDisplay,
                thisModuleInfo,
                thisId,
                localNumPoints - (PointCapacity - 1),
                (IGRpoint *)pnts[PointCapacity-1],
                mode,
                type
            );
            if (EMSerror (omrc))
                return omrc;
            if (EMSerror (*msg))
                return OM_E_ABORT;

            curve.num_knots = NumLocalKnots;
            curve.num_poles = PointCapacity;
            localNumPoints = PointCapacity;
        }
        else
        {
            curve.num_poles = localNumPoints;
            curve.num_knots = localNumPoints + 2;
        }

        /* set knots */
        {
            IGRlong ii;

            curve.knots[0] = 0;
            curve.knots[1] = 0;
            curve.knots[localNumPoints] = 1;
            curve.knots[localNumPoints+1] = 1;
            for (ii = 2; ii < localNumPoints; ii++)
            {
                curve.knots[ii] = (ii - 1);
                curve.knots[ii] /= (localNumPoints - 1);
            }
        }

        curve.rational = FALSE;
        curve.weights = NULL;
        curve.planar = FALSE;
        curve.phy_closed = FALSE;
        curve.num_boundaries = 0;
        curve.bdrys = NULL;

        cvElementSpecific.is_polydis = FALSE;
        cvElementSpecific.is_curvedis = TRUE;

/* find the range of the point set ****/

        for(ii=0;ii<3;ii++)
            range[ii]= pnts[0][ii];
        for(ii=3;ii<6;ii++)
            range[ii]= pnts[0][ii-3];

        for(ii=0;ii<localNumPoints;ii++)
           {
           if(range[0]> pnts[ii][0])
                range[0] = pnts[ii][0];
           if(range[1]> pnts[ii][1])
                range[1] = pnts[ii][1];
           if(range[2]> pnts[ii][2])
                range[2] = pnts[ii][2];
           }
           
        for(ii=0;ii<localNumPoints;ii++)
           {
           if(range[3]< pnts[ii][0])
                range[3] = pnts[ii][0];
           if(range[4]< pnts[ii][1])
                range[4] = pnts[ii][1];
           if(range[5]< pnts[ii][2])
                range[5] = pnts[ii][2];
           }
           
/* find the range of the point set ****/

        dp$build_dis_buffer (
            buffer = &displayHeader,
            range = range,
            type = IGRBC,
            display_att = &thisActiveDisplay,
            ele_spec_att = &cvElementSpecific,
            geometry = &curve
        );
    }
    else if (localType IS IGRPS)
    {
        if (thisActiveDisplay.weight < 3)
            thisActiveDisplay.weight = 3;

        point_set.points = pnts[0];
        point_set.num_points = numPnts;
        
        for(ii=0;ii<3;ii++)
           range[ii]=pnts[0][ii];
        for(ii=3;ii<6;ii++)
           range[ii]=pnts[0][ii-3];

        dp$build_dis_buffer (
            buffer = &displayHeader,
            range = range,
            type = IGRPS,
            display_att = &thisActiveDisplay,
            geometry = &point_set
        );
    }
    else
    {
        *msg = EMS_E_InvalidArg;
        return OM_E_ABORT;
    }

#   if NOT DRAFT112
    omrc =
#   endif

    dp$display (
        msg = msg,
        osnum = thisModuleInfo.md_id.osnum,
        objid = thisModuleInfo.md_id.objid,
        mode = mode,
        num_elem = 1,
        buffer = &displayHeader
    );
    if (*msg == DPSTOPDRAW)
      *msg = EMS_I_Interrupt;
    else if (EMSerror (*msg))
      *msg = EMS_E_Fail;
    else
      *msg = EMS_S_Success;

    return omrc;
}

void EMdisppts (num_pts, pts, disp_attr, is_py, dpmode, win_or_mod_id)
IGRint num_pts;
IGRdouble *pts;
struct IGRdisplay *disp_attr;
IGRboolean is_py;
enum GRdpmode dpmode;
struct GRid *win_or_mod_id;
{
  IGRlong msg_loc;
  struct IGRpolyline py;
  struct DPele_header dpbuff;
  struct IGRespy espy;

  py.num_points = num_pts;
  py.points = pts;

  espy.is_closed = FALSE;

  dp$build_dis_buffer (buffer = &dpbuff, type = is_py ? IGRPY : IGRPS,
   display_att = disp_attr, ele_spec_att = &espy, geometry = &py);

  dp$display (msg = &msg_loc,
   objid = win_or_mod_id->objid, osnum = win_or_mod_id->osnum,
   mode = dpmode, buffer = &dpbuff);

  return;
}

end implementation GRgraphics;

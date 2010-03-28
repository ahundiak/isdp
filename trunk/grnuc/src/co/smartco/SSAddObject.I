/*

Name
  SSAddObject.I

Description
  This file contains the SSAddObject() function for adding located objects 
  to the list of elements that Smart Sketch recognizes.

Notes
  First implemented for 2.4.0 release of GRNUC.  Based on prototype by
  Henri Bequet.  Further development by Shelley Heard in summer of 1993.

 */
class implementation Root;

#include <math.h>
#include <memory.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "godef.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "bserr.h"
#include "grmsg.h" /* for return code from EFsurface_edge_locate */
#include "DPvd.h"

/* prototypes */
#include "bsalloccv.h"
#include "bscveval.h"
#include "bscv_copy.h"
#include "bsrdcencrcv.h"
#include "malncbcli.h"
#include "maptalln.h"
#include "maptsxfor.h"
#include "ma2ptdis.h"

/* 
 * unwanted classes - when SS_IS_UNWANTED_CLASS returns TRUE, it means 
 * reject this class as a candidate for SmartSketch recognition.
 */
#define SS_IS_UNWANTED_CLASS(class_id)         \
  ( om$is_ancestry_valid (                     \
      subclassid = ClassId,                    \
      superclassname = "SKgmhndlpt" ) == OM_S_SUCCESS ) 


from GRvg       import GRptdis, GRgetsymb, GRgenabsg;
from GRgraphics import GRptproject, GRlnproject, GRgetprops;
from IGEgragad import DPinquire;
/*

Name
  SSAddObject

Abstract
  Adds a found object to the objects list.

Synopsis
  int SSAddObject ( msg, PGrid, info )

Description
  *msg     long         OUT  retrun message
  *PGrid   struct GRid  IN   The element to be added to the object list
  *info    char         IN   user info (point/tolerance)

Return Value
  OM_S_SUCCESS - element not found keep searching
  OM_E_ABORT   - geometric extraction failure
  OM_I_STOP_SENDING - stop rtree search / element added

Notes
  Instances of the following classes (and subclasses) may be added to the list:
    GR3dlineseg
    GR3dpoint
    GR3dcirarc
    GR3dcircle

  Also, model space counterparts of surfaces (EMSsubbs) which belong to one of 
  the above classes are also accepted.

  If a new element is found, it is added to the SSObjects [] array (global)
  and if the list is full, the first in is the first out.

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.
  08/20/93 : Shelley R. Heard : added support of Midpoints of Arcs and Bspline
                                curves.
  12/13/93 : G M K            : select the elements whose layer is turn on.
  				TR # 119313799
 */
int SSAddObject ( msg, PGrid, info )
long        *msg;
struct GRid *PGrid;
char        *info;
{
  SSUserInfo          *p_UserInfo = (SSUserInfo *)info;
  double              Distance;
  int                 status = OM_S_SUCCESS;
  int                 ndx;
  int                 sts = OM_S_SUCCESS;
  IGRboolean          b_sts;
  IGRshort            props = 0x0000;
  long                msg_loc;
  struct DPele_header ele_header;
  struct IGResbc      *p_ele_attr = NULL;
  struct IGRdisplay   *p_display_attr = NULL;
  char                *tmp_ptr;
  struct GRsymbology  symb;
  struct IGRbsp_curve *bc, *geometry;
  IGRpoint            first[1], last[1], middle[1];
  IGRpoint            center;
  BSrc                rc;
  OMuword             ClassId;
  struct GRid         msc_grid;
  int                 type;
  double              uparm = 0.0, Radius;
  IGRboolean          Boundary;
  struct GRparms      parms;
  struct GRmd_env     md_env;
  struct IGRline      ref_boreline;
  IGRpoint            ref_pt1, 
                      ref_pt2; 
  struct  var_list    v_list[2];
  IGRint  	      level_mask[32];
  IGRlong             bytes_returned;
  IGRint              which_error;
  struct DPvd_actwin  awin;
  struct GRsymbology  symbology;

  /* GRNUC based class id's (other applications must use class names) */
  extern OMuword      OPP_GR3dlineseg_class_id, 
                      OPP_GR3dpoint_class_id, 
                      OPP_GR3dcirarc_class_id, 
                      OPP_GR3dcircle_class_id;

  /*
   * get class id of element from Rtree
   */
  om$get_classid ( osnum     = PGrid->osnum, 
                   objid     = PGrid->objid,
                   p_classid = &ClassId );

  /*
   * Get the levels mask and check the object's level is turn on or not.
   * If the level is turn off, reject the object for smart sketch.
   * TR # 119313799    - GMK 12/13/93
   */
  gr$get_symbology( object_id = PGrid, symb = &symbology );

  /*
   * get active window
   */
  DPvd_get_active_window( &awin );
  
  v_list[0].var = LEVELS;
  v_list[0].var_ptr = (char *)level_mask;
  v_list[0].num_bytes = sizeof (level_mask);
  v_list[0].bytes_returned = &bytes_returned;

  v_list[1].var = END_PARAM;
  
  status = om$send(msg = message IGEgragad.DPinquire(msg,
					(IGRlong *)&which_error, v_list),
			 senderid = NULL_OBJID,
			 targetid = awin.grid.objid,
			 targetos = awin.grid.osnum);
  if (1 & status & *msg)
    if (!DPlevel_check( symbology.level, level_mask ))
    {
      *msg = MSSUCC;
      status = OM_S_SUCCESS;
      goto wrapup;
    }
  
  /*
   * This is a good place to reject any subclasses of the elligible classes 
   * that are not wanted (such as graphic handles of constraints that are
   * subclassed under GR3dpoint).  
   *
   *  Programmer Note:  To add another class to the "list of the unwanted",
   *  modify the C macro SS_IS_UNWANTED_CLASS (see #define above).
   */
  if ( SS_IS_UNWANTED_CLASS( ClassId ) )
  {
    *msg = MSSUCC;
    status = OM_S_SUCCESS;
    goto wrapup;
  }

  /*
   * In case of a surface/solid, we get the mscp
   */
  if (om$is_ancestry_valid ( subclassid = ClassId, 
                             superclassname = "EMSsubbs" ) == OM_S_SUCCESS)
  {
    struct IGRline *pBoreLine;
    extern int EFsurface_edge_locate();
    extern int SSCursorHasMoved();

    /*
     * Find the edges (msc) of the surface
     */
    status = gr$get_module_env( buffer = &md_env );

    if (SSRefLock) /* then we cannot rely upon p_UserInfo->PBoreLine */
    {
      short     direction = 1;
      double    basis_tolerance;
      IGRpoint  bl_pt1,
                bl_pt2;

      /*
       * normally we do a point locate when the the Reference Plane lock
       * is on; we need to build the boreline now from the current cursor
       * position
       */
      ref_boreline.point1 = ref_pt1;
      ref_boreline.point2 = ref_pt2;
      
      DPlocbrln ( &status, 
                   p_UserInfo->point, 
                   SSLastWindow.objid, 
                   SSLastWindow.osnum, 
                  &ref_boreline );

      /* 
       * For this locate to work like a point locate, we have to reduce
       * the length of the boreline to basis tolerance, maintaining its
       * midpoint on the reference plane 
       */
      status = gr$get_basis_tolerance(buffer = &basis_tolerance );
      
      b_sts = MAptalln( (IGRlong *) &status,
                        &ref_boreline,
                         p_UserInfo->point,
                        &direction,
                        &basis_tolerance,
                         bl_pt1 );

      direction = -direction;
      
      b_sts = MAptalln( (IGRlong *) &status,
                        &ref_boreline,
                         p_UserInfo->point,
                        &direction,
                        &basis_tolerance,
                         bl_pt2);

      memcpy ( ref_pt1, bl_pt1, sizeof ( IGRpoint ) );
      memcpy ( ref_pt2, bl_pt2, sizeof ( IGRpoint ) );
      pBoreLine = &ref_boreline;
    }
    else
    {
      pBoreLine = p_UserInfo->PBoreLine;
    }

    status = EFsurface_edge_locate( 
                PGrid, 
                pBoreLine,
                SSCursorHasMoved, /* stop search if cursor moves  */
               &md_env,
                p_UserInfo->tolerance, 
               &msc_grid );

    /* didn't find the MSC */
    if (!(status & 1) || (status == GR_I_EleNotFound) )
    {
      /* 
       *  Could not find an edge within tolerance - process the next object in 
       *  the Rtree; because of the way GRgraphics.GRfunction works, both the 
       *  completion code (*msg) and the return code (status) must be "success"
       *  (high order bit set) or the Rtree pass will stop sending. SRH 9/8/93
       */
      *msg = MSSUCC;
      status = OM_S_SUCCESS;
      goto wrapup;
    }
    else
    {
      /*
       * Get the class id of the MSC
       */
      om$get_classid ( osnum     = msc_grid.osnum, 
                       objid     = msc_grid.objid,
                       p_classid = &ClassId );
    }
  }
  else
  {
    /* 
     * we use the original
     */
    msc_grid = *PGrid;
  }

  /*
   * Check if we don't already have it
   */
  for (ndx = 0; ndx < SSnb_objects; ndx++)
  {
    if ( SSObjects [ndx].grid.osnum == msc_grid.osnum &&
         SSObjects [ndx].grid.objid == msc_grid.objid )
    {
      break;
    }
  }

  if (ndx == SSnb_objects)
  {

     /* Check if it's locatable/displayable flags are set */
    sts = gr$get_properties( object_id = &msc_grid,
                             properties_mask = &props);

    if (!(sts & 1))
    {
      status = OM_E_ABORT;
      goto wrapup;
    }
    else if ( !(props & GRIS_DISPLAYABLE) || !(props & GRIS_LOCATABLE) )
    {
      /* 
       *  We reject elements that are not locatable or not displayable
       */
      *msg = MSSUCC;
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    /*
     * Check if the object is close enough
     */
    if (SSRefLock)
    {
      /*
       * Point locate -> distance between a point and the element
       */
      sts = om$send ( msg = message GRvg.GRptdis ( msg, 
                                                  &p_UserInfo->type, 
                                                   p_UserInfo->matrix, 
                                                   p_UserInfo->point, 
                                                  &Distance ), 
                      targetos = msc_grid.osnum, 
                      targetid = msc_grid.objid, 
                      senderid = NULL_OBJID );
      if (!(sts & *msg & 1))
      {
        status = OM_E_ABORT;
        goto wrapup;
      }
    }
    else
    {
      IGRpoint       LinePoint;
      double         UParm;
      struct GRparms CurveParameters;

      /*
       * Bore line locate -> distance between a line and the element
       */
      sts = om$send ( msg = message GRgraphics.GRlnproject ( 
                                                  msg, 
                                                 &p_UserInfo->type, 
                                                  p_UserInfo->matrix, 
                                                  p_UserInfo->PBoreLine, 
                                                  LinePoint, 
                                                  p_UserInfo->ConstraintPoint,
                                                 &UParm, 
                                                 &CurveParameters ),
                      targetid = msc_grid.objid, 
                      targetos = msc_grid.osnum, 
                      senderid = NULL_OBJID );
      if (!(sts & *msg & 1))
      {
        status = OM_E_ABORT;
        goto wrapup;
      }

      MA2ptdis ( msg, LinePoint, p_UserInfo->ConstraintPoint, &Distance );
    }

    if (Distance < p_UserInfo->tolerance)
    {
      /*
       * We take that element -> hilite it, stop the R-tree search and
       * add the object to the list of objects we look at.
       * First we build the display buffer.
       */
      if (SSRefLock)
      {
        sts = om$send ( 
           msg = message GRgraphics.GRptproject( &msg_loc, 
                                                 &p_UserInfo->type, 
                                                  p_UserInfo->matrix, 
                                                  p_UserInfo->point, 
                                                  p_UserInfo->ConstraintPoint,
                                                 &parms ), 
           targetid = msc_grid.objid,
           targetos = msc_grid.osnum, 
           senderid = NULL_OBJID );
        if (!(sts & msg_loc & 1))
        {
          status = OM_E_ABORT;
          goto wrapup;
        }
      }

      sts = om$send ( msg = message GRvg.GRgetsymb ( &msg_loc, &symb ),
                      targetid = msc_grid.objid, 
                      targetos = msc_grid.osnum, 
                      senderid = NULL_OBJID );
      if (!(sts & msg_loc & 1))
      {
        status = OM_E_ABORT;
        goto wrapup;
      }
      sts = om$send ( msg = message GRvg.GRgenabsg ( &msg_loc,
                                                     &p_UserInfo->type, 
                                                      p_UserInfo->matrix, 
                                                     &tmp_ptr ), 
                      targetid = msc_grid.objid, 
                      targetos = msc_grid.osnum, 
                      senderid = NULL_OBJID );
      if (!(sts & msg_loc & 1))
      {
        status = OM_E_ABORT;
        goto wrapup;
      }

      bc = (struct IGRbsp_curve *)tmp_ptr;

      BSalloccv ( bc->order, 
                  bc->num_poles, 
                  (IGRboolean) bc->rational, 
                  bc->num_boundaries,
                 &geometry, 
                 &rc );
      if (rc != BSSUCC)
      {
        status = OM_E_ABORT;
        goto wrapup; 
      }

      BScv_copy ( &rc, bc, geometry );
      if (rc != BSSUCC)
      {
        status = OM_E_ABORT;
        goto wrapup; 
      }
      p_ele_attr = (struct IGResbc *)malloc ( sizeof ( struct IGResbc ) );
      if (!p_ele_attr)
      {
        status = OM_E_NODYNMEM;
        goto wrapup; 
      }
      p_ele_attr->is_polydis = 0;
      p_ele_attr->is_curvedis = 1;
      p_display_attr = (struct IGRdisplay *) malloc (sizeof(struct IGRdisplay));
      if (!p_display_attr)
      {
        status = OM_E_NODYNMEM;
        goto wrapup; 
      }

      /*
       * adjust display atributes to have at least a line weight of 2 and 
       * always be a solid line
       */
      if ( symb.display_attr.weight < 2 )
      {
        symb.display_attr.weight = 2;
      }
      symb.display_attr.style = 0;

      memcpy(p_display_attr, &symb.display_attr, sizeof ( struct IGRdisplay ));

      status = dp$build_dis_buffer ( buffer = &ele_header, 
                                     ele_spec_att = p_ele_attr, 
                                     display_att = p_display_attr, 
                                     geometry = geometry );

      /*
       * set the type of element according to it's classid
       */
      if (om$is_ancestry_valid ( 
            subclassid = ClassId,
             superclassid = OPP_GR3dlineseg_class_id ) == OM_S_SUCCESS)
      {
        type = SSLINE;
      }
      else if (om$is_ancestry_valid ( 
               subclassid = ClassId,
               superclassid = OPP_GR3dcircle_class_id ) == OM_S_SUCCESS)
      {
        type = SSCIRCLE;
      }
      else if (om$is_ancestry_valid ( 
                subclassid = ClassId,
                superclassid = OPP_GR3dcirarc_class_id ) == OM_S_SUCCESS)
      {
        type = SSARC; 
      }
      else if (om$is_ancestry_valid (
                subclassid = ClassId,
                superclassid = OPP_GR3dpoint_class_id) == OM_S_SUCCESS)
      {
        type = SSPOINT;
      }
      else if (om$is_ancestry_valid (
                 subclassid = ClassId,
                 superclassname = "GRbcsubbc" ) == OM_S_SUCCESS)
      {
        type = SSBSCURVE; 
      }
      else 
      {
        type = SSPOINT;
      }

      /*
       * Initialize the keypoints for that new element
       */
      switch (type)
      {
        case SSPOINT:
        {
          BScveval ( bc, 0.0, 0, first, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          break;
        }

        case SSARC:
        {
          BScveval ( bc, 0.0, 0, first, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          BScveval ( bc, 1.0, 0, last, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          BScveval ( bc, 0.5, 0, middle, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;

        }

        case SSCIRCLE:
        {
          BSrdcencrcv ( &rc, bc, &uparm, &Boundary, &Radius, &Radius, &Radius,
              &Radius, center, center );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          break;

        }

        case SSLINE :
        {
          BScveval ( bc, 0.5, 0, middle, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          /* !!! NO break !!! */
        }

        case SSBSCURVE :
        {
          BScveval ( bc, 0.0, 0, first, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          BScveval ( bc, 1.0, 0, last, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          BScveval ( bc, 0.5, 0, middle, &rc );
          if (rc != BSSUCC)
            return OM_E_ABORT;
          break;
        }
      }

      /*
       * Make room for a new object if list is full.
       * in 2.4.0.13 - test for determining if list was full is fixed.  
       * Before this, major memory corruptions were occuring. SRH 8/30/93
       */
      if (SSnb_objects >= SS_MAX_OBJECTS)
      { 
        /*
         * Free the first object
         */
        SSListFreeMember( 0 );

        /*
         * Shift the list to bump the last object out and make room for the
         * new one.  The "oldest" objects have the smallest indices.
         */
        for (ndx = 0; ndx < SSnb_objects - 1; ndx++)
        {
          SSObjects [ndx] = SSObjects [ndx + 1];
        }
        SSnb_objects--;
      }

      if (SSObjects [SSnb_objects].buffers = 
           (struct DPele_header *)malloc ( sizeof ( struct DPele_header ) ))
      {
        struct IGRline OriginalLine;
        struct IGRline_seg  ExtendedLine;
        IGRpoint       FirstPoint, SecondPoint;
        long           LocalStatus;
        int            KeyPtIndex;

        /*
         * Add the object to the list and pass back pointer to
         * display buffer.
         */
        SSObjects [SSnb_objects].grid = msc_grid;
        memcpy ( &SSObjects [SSnb_objects].buffers [0], &ele_header, 
          sizeof ( struct DPele_header ) );
        SSObjects [SSnb_objects].NbBuffers = 1;

        for (KeyPtIndex = 0; KeyPtIndex < SS_MAX_KEYPOINTS; KeyPtIndex++)
        {
          SSObjects [SSnb_objects].KeyPointActive [KeyPtIndex] = 0;
        }

        switch (type)
        {
          case SSPOINT:
          {
            memcpy ( SSObjects [SSnb_objects].KeyPoints [0], 
                     first[0], 
                     sizeof ( IGRpoint ) );
            SSObjects [SSnb_objects].NbKeyPoints = 1;
            break;
          }

          case SSLINE:
          {
            memcpy ( SSObjects [SSnb_objects].KeyPoints [0], 
                     first[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [1], 
                     middle[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [2], 
                     last[0], 
                     sizeof ( IGRpoint ) );
            SSObjects [SSnb_objects].NbKeyPoints = 3;

            /*
             *  Extrapolate the points defining the line to the edge of
             *  the design cube.
             */
            OriginalLine.point1 = first[0];
            OriginalLine.point2 = last[0];

            FirstPoint[0] = FirstPoint[1] = FirstPoint[2] 
              = GRDGNLIMITS_MIN_D + 1;
            SecondPoint[0] = SecondPoint[1] = SecondPoint[2] 
              = GRDGNLIMITS_MAX_D - 1;

            ExtendedLine.beg_point = SSObjects [SSnb_objects].ExtendedPoints [0];
            ExtendedLine.end_point = SSObjects [SSnb_objects].ExtendedPoints [1];

            MAlncbclip ( &LocalStatus, 
                         &OriginalLine, 
                          FirstPoint, 
                          SecondPoint,
                         &ExtendedLine );
            break;
          }

          case SSBSCURVE :
          {
            memcpy ( SSObjects [SSnb_objects].KeyPoints [0], 
                     first[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [1], 
                     last[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [2], 
                     middle[0], 
                     sizeof ( IGRpoint ) );
            SSObjects [SSnb_objects].NbKeyPoints = 3;

            /*
             *  No Extrapolation of curve to the edge of the design cube.
             */
            break;
          }

          case SSARC:
          {
            memcpy ( SSObjects [SSnb_objects].KeyPoints [0], 
                     first[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [1], 
                     center, 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [2], 
                     last[0], 
                     sizeof ( IGRpoint ) );
            memcpy ( SSObjects [SSnb_objects].KeyPoints [3], 
                     middle[0], 
                     sizeof ( IGRpoint ) );
            SSObjects [SSnb_objects].NbKeyPoints = 4;
            SSObjects [SSnb_objects].Radius = Radius;
            SSObjects [SSnb_objects].KeyPointActive [0] = 1;
            break;
          }

          case SSCIRCLE:
          {
            /* save center point in keypoint list for this element */
            memcpy ( SSObjects [SSnb_objects].KeyPoints [0], 
                     center, 
                     sizeof ( IGRpoint ) );
            /*
             * If the reference plane lock is on then add the 3, 12, 9 and 
             * 6 o'clock positions as key points.
             */
            if (SSRefLock)
            {
              IGRpoint CenterPoint;
              int      Index, Sign;
              long     LocalStatus, one = 1;

              /*
               * Convert the center to the coordinate system of the reference 
               * plane
               */
              MAptsxform( &LocalStatus, &one, SSRefMatrix, center, CenterPoint);

              /*
               * If the center is (x, y) then the 4 key points are (x+radius,y),
               * (x - radius, y), (x, y + radius) and (x, y - radius).
               */
              for (Index = 1, Sign = 1; Index < 5; Index++, Sign = -Sign)
              {
                memcpy( SSObjects [SSnb_objects].KeyPoints [Index], 
                        CenterPoint,
                        sizeof ( IGRpoint ) );
                SSObjects[SSnb_objects].KeyPoints[Index][Index/3]+=Sign*Radius;
                MAptsxform ( &LocalStatus, 
                             &one, 
                              SSInvRefMatrix, 
                              SSObjects [SSnb_objects].KeyPoints [Index], 
                              SSObjects [SSnb_objects].KeyPoints [Index] );
              }
              SSObjects [SSnb_objects].NbKeyPoints = 5;
            }
            else
            {
              SSObjects [SSnb_objects].NbKeyPoints = 1;
            }
            SSObjects [SSnb_objects].Radius = Radius;
            break;
          }

          default: 
          {
            SSObjects [SSnb_objects].NbKeyPoints = 0;
          }
        }

        SSObjects [SSnb_objects].type = type;
        p_UserInfo->p_object = &SSObjects [SSnb_objects];
        SSnb_objects++;

        /*
         * Store the last constraint
         */
        SSLastAvailable = 1;

        memcpy ( SSLastConstraintPoint, 
                 p_UserInfo->ConstraintPoint, 
                 sizeof ( IGRpoint ) );

        SSLastConstraintType = SSONELEMENT;
      }

      /* a good place to call PrintObjectList() for debug */

      /*
       * Make sure that the R-tree pass stops here
       */
      status = OM_I_STOP_SENDING;
    }
  }

wrapup:

  return status;
}

end implementation Root;


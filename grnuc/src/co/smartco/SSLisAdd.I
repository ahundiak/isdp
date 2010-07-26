/*

Name
  SSListAdd.I

Description
  Functions used to manipulate the order of SSobjects in the
  SSObjects[] array.

Notes

  SSListAdd
  SSListRemove
  SSListKeyptActive


 "oldest"    0    Obj1
             1    Obj2
             2    Obj3
             3    Obj4
             4    Obj5
             5    Obj6
 "newest"    6    Obj7
             7    ----
             8    ----
             9    ----

 */

class implementation Root;

#include <math.h>
#include "bserr.h"
#include "bsvalues.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"

/* prototypes */
#include "bscveval.h"
#include "bsrdcencrcv.h"
#include "bscv_copy.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "maidmx.h"
#include "malncbcli.h"
#include "maptsxfor.h"

/* When a constraint is found, it's associated element(s) is/are highlight
 * with a line weight of CONSTRAINT_WEIGHT if that element's actual weight 
 * is less than or equal to CONSTRAINT_WEIGHT 
 */
#define  CONSTRAINT_WEIGHT   1

/*

Name
  SSListAddGrid
  SSListAddMember

Abstract

Synopsis

int SSListAddObject( objid, osnum, flag )
int SSListAddMember( p_ssobj, flag )

  GRobjid      objid   objid of element to be typed
  GRspacenum   osnum   osnum of element to be typed (if 0, master OS assumed)
  SMObject     *p_ssobj  (IN)  prepackaged SMObject to be added to list
  int          flag      (IN)  if grid already in list: 0 = no-action; 
                                                        1 = move to top
Description
  If the object (objid) is not already in the list, it is added to the end of
  the list (thus becoming the "newest" element).  If it is already in the
  list and if 'flag' is set to 1 - it is moved to the end of the list.

Return Value

Notes
  Public

  Global variables modified:
    SSObjects[]
    SSnb_objects
    SSLastObject1
    SSLastObject2

Index

Keywords

History
  09/07/93 : Shelley R. Heard : created


 */

/* message imports */
from GRvg import GRgenabsg;
from GRvg import GRgetsymb;


int SSListAddObject( objid, osnum, flag )
  GRobjid      objid;
  GRspacenum   osnum;
  int           flag;
{

  long msg = OM_S_SUCCESS,
       sts = OM_S_SUCCESS;

  int rc = OM_S_SUCCESS,
      type,
      ss_obj_index;

  BSrc  bsrc = BSSUCC;
  
  struct IGRbsp_curve *p_bc,
                      *p_geometry;

  double uparm = 0.0,
         radius;

  IGRpoint center,
           dummy_center,
           first[1],
           middle[1],
           last[1];

  IGRmatrix matrix;

  short matrix_type;

  struct IGRdisplay *p_display_attr = NULL;

  struct IGResbc *p_ele_attr = NULL;

  struct GRsymbology symb;

  GRspacenum loc_osnum;

  struct DPele_header ele_header;

  IGRboolean Boundary;

  SSObject NewObject;

  /*
   * If the element is already in the list, then exit.
   */
  if ( SSListMember( objid, osnum, &ss_obj_index ) )
  {
    goto quit;
  }
  /*
   * Determine the type of element
   */
  if ( osnum )
  {
    loc_osnum = osnum;
  }
  else
  {
    ex$get_cur_mod ( osnum = &loc_osnum );
  }

  SSGetElementType( objid, loc_osnum, &type );
  /*
   * Get the abstract (bspline) geometry and copy it for storage in the SSObject
   */  
  matrix_type = MAIDMX;
  MAidmx ( &sts, matrix );
  
  sts = om$send ( msg = message GRvg.GRgenabsg ( &msg,
                                                 &matrix_type,
                                                 matrix,
                                                 (char **) &p_bc ),
                  targetid = objid,
                  targetos = loc_osnum,
                  senderid = NULL_OBJID );
  if (!(sts & msg & 1))
  {
    rc = OM_E_ABORT;
    goto quit;
  }

  BSalloccv ( p_bc->order,
              p_bc->num_poles,
              (short)p_bc->rational,
              p_bc->num_boundaries,
             &p_geometry,
             &bsrc );
  if (bsrc != BSSUCC)
  {
    rc = OM_E_ABORT;
    goto quit;
  }

  BScv_copy ( &bsrc, p_bc, p_geometry );
  if (bsrc != BSSUCC)
  {
    rc = OM_E_ABORT;
    goto quit;
  }

  sts = om$send ( msg = message GRvg.GRgetsymb ( &msg, &symb ),
                  targetid = objid, 
                  targetos = loc_osnum, 
                  senderid = NULL_OBJID );
  if (!(sts & msg & 1))
  {
    rc = OM_E_ABORT;
    goto quit;
  }


  p_ele_attr = (struct IGResbc *)malloc ( sizeof ( struct IGResbc ) );
  if (!p_ele_attr)
  {
    rc = OM_E_NODYNMEM;
    goto quit;
  }
  p_ele_attr->is_polydis = 0;
  p_ele_attr->is_curvedis = 1;
  p_display_attr = (struct IGRdisplay *) malloc (sizeof(struct IGRdisplay));

  if (!p_display_attr)
  {
    rc = OM_E_NODYNMEM;
    goto quit;
  }
  /*  adjust display atributes to have at least a line weight of 2 and 
   * always be a solid line
   */
  if ( symb.display_attr.weight < CONSTRAINT_WEIGHT )
  {
    symb.display_attr.weight = CONSTRAINT_WEIGHT;
  }
  symb.display_attr.style = 0;

  memcpy(p_display_attr, &symb.display_attr, sizeof ( struct IGRdisplay ));

  sts = dp$build_dis_buffer ( buffer = &ele_header,
                              ele_spec_att = p_ele_attr,
                              display_att = p_display_attr,
                              geometry = p_geometry );

  /*
   * Extract the various keypoints (first,mid,last,center pts) for that
   * new object, according to it's type
   */
  switch (type)
  {
    case SSCIRCLE:
    case SSARC:
    {

      BSrdcencrcv ( &bsrc, p_bc, &uparm, &Boundary, &radius, &radius, &radius,
          &radius, center, dummy_center );
      if (bsrc != BSSUCC)
      {
        rc = OM_E_ABORT;
        goto quit;
      }
      if ( type == SSCIRCLE ) 
      {
	break;
      }
      /* ARCs need first/mid/last points so no break */
    }

    case SSLINE :
    case SSBSCURVE :
    {
      BScveval ( p_bc, 1.0, 0, last, &bsrc );
      if (bsrc != BSSUCC) { rc = OM_E_ABORT; goto quit; }

      BScveval ( p_bc, 0.5, 0, middle, &bsrc );
      if (bsrc != BSSUCC) { rc = OM_E_ABORT; goto quit; }

      /* NO BREAK!!!!! ALL four types need a first point */
    }
    case SSPOINT:
    {
      BScveval ( p_bc, 0.0, 0, first, &bsrc );
      if (bsrc != BSSUCC) { rc = OM_E_ABORT; goto quit; }
    }
  }


  if ( NewObject.buffers = 
       (struct DPele_header *) malloc ( sizeof ( struct DPele_header ) ))
  {
    struct IGRline OriginalLine, ExtendedLine;
    IGRpoint       FirstPoint, SecondPoint;
    long           LocalStatus;
    int            KeyPtIndex;

    /*
     * Add the object to the list and pass back pointer to
     * display buffer.
     */
    NewObject.grid.objid = objid;
    NewObject.grid.osnum = loc_osnum;
    memcpy ( &NewObject.buffers [0], &ele_header, sizeof(struct DPele_header) );
    NewObject.NbBuffers = 1;

    NewObject.type = type;
    switch (type)
    {
      case SSPOINT:
      {
        memcpy ( NewObject.KeyPoints [0],
                 first[0],
                 sizeof ( IGRpoint ) );
        NewObject.NbKeyPoints = 1;
        break;
      }

      case SSLINE:
      {
        memcpy ( NewObject.KeyPoints [0],
                 first[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [1],
                 middle[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [2],
                 last[0],
                 sizeof ( IGRpoint ) );
        NewObject.NbKeyPoints = 3;

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

        ExtendedLine.point1 = NewObject.ExtendedPoints [0];
        ExtendedLine.point2 = NewObject.ExtendedPoints [1];

        MAlncbclip ( &LocalStatus, 
                     &OriginalLine, 
                     FirstPoint, 
                     SecondPoint,
                     (struct IGRline_seg *) &ExtendedLine );
        break;
      }

      case SSBSCURVE :
      {
        memcpy ( NewObject.KeyPoints [0],
                 first[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [1],
                 last[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [2],
                 middle[0],
                 sizeof ( IGRpoint ) );
        NewObject.NbKeyPoints = 3;

        /*
         *  No Extrapolation of curve to the edge of the design cube.
         */
        break;
      }

      case SSARC:
      {
        memcpy ( NewObject.KeyPoints [0],
                 first[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [1],
                 center,
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [2],
                 last[0],
                 sizeof ( IGRpoint ) );
        memcpy ( NewObject.KeyPoints [3],
                 middle[0],
                 sizeof ( IGRpoint ) );
        NewObject.NbKeyPoints = 4;
        NewObject.Radius = radius;
        break;
      }

      case SSCIRCLE:
      {
        /* save center point in keypoint list for this element */
        memcpy ( NewObject.KeyPoints [0],
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
            memcpy( NewObject.KeyPoints [Index],
                    CenterPoint,
                    sizeof ( IGRpoint ) );
            NewObject.KeyPoints[Index][Index/3] += Sign * radius;
            MAptsxform ( &LocalStatus,
                         &one,
                          SSInvRefMatrix,
                          NewObject.KeyPoints [Index],
                          NewObject.KeyPoints [Index] );
          }
          NewObject.NbKeyPoints = 5;
        }
        else
        {
          NewObject.NbKeyPoints = 1;
        }
        NewObject.Radius = radius;
        break;
      }

      default:
      {
        NewObject.NbKeyPoints = 0;
      }
    }

    /*
     * deactivate all keypoints
     */
    for (KeyPtIndex = 0; KeyPtIndex < SS_MAX_KEYPOINTS; KeyPtIndex++)
    {
      NewObject.KeyPointActive [KeyPtIndex] = 0;
    }

    /* add to list */
    SSListAddMember( &NewObject, flag );
  }
  else
  {
    rc = OM_E_NODYNMEM;
  }

quit:
  return rc;
}

#argsused
int SSListAddMember( p_ssobj, flag )
  SSObject  *p_ssobj;
  int        flag;     /* for future use */
{
  int rc = OM_S_SUCCESS;

  /*
   * Do we need to make room for a new object?
   */
  if (SSnb_objects >= SS_MAX_OBJECTS)
  {
    int ndx;

    /*
     * Yes.  Then free memory of oldest (first) SSObject in list
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

  SSObjects [SSnb_objects] = *p_ssobj;
  SSnb_objects++;

  return rc;
}

/*

Name
  SSFreeSSObject

Abstract

Synopsis
  int SSFreeSSObject( pObject )
    SSObject *pObject     (IN)  SSObject to free memory from

Description
  Frees all malloc'd memory for a specified SSObject.  This does NOT
  remove such an element from the SSObjects[] list.

Return Value
  MSSUCC - no problems
  MSFAIL - failed to free memory

Notes
  Private

Index

Keywords

History
  09/22/93 : Shelley R. Heard : created

 */

int SSFreeSSObject( pObject )
  SSObject *pObject;
{
  BSrc bsrc = BSSUCC;
  int ii;
  
  /*
   * Free the object in slot pointed to by pObject
   */
  for ( ii = 0; ii < pObject->NbBuffers; ii++ )
  {
    if ( pObject->buffers [ii].geometry.bspcurve )
    {
      BSfreecv ( &bsrc, pObject->buffers [ii].geometry.bspcurve );
      pObject->buffers [ii].geometry.bspcurve = NULL;
    }
    if ( pObject->buffers [ii].ele_spec_att.bspcurve )
    {
      free ( pObject->buffers [ii].ele_spec_att.bspcurve );
      pObject->buffers [ii].ele_spec_att.bspcurve = NULL;
    }
    if ( pObject->buffers [ii].dis_att )
    {
      free ( pObject->buffers [ii].dis_att );
      pObject->buffers [ii].dis_att = NULL;
    }
  }
  if ( pObject->buffers )
  {
    free ( pObject->buffers );
    pObject->buffers = NULL;
  }

  return ( bsrc == BSSUCC ) ? MSSUCC : MSFAIL;
}

int SSListFreeMember( index )
  int index;
{
  return SSFreeSSObject( &SSObjects[index] );
}

end implementation Root;

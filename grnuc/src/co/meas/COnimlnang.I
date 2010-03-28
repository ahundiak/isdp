/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
*/ 


/* 
    Name

    IGRlong CO_ni_measure_line_angle(msg,
                                     Events,
                                     ModuleInfo,
                                     Angle,
                                     Units,
                                     my_id,
                                     MyChannelStruct,
                                     ObjectsGrid )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    IGRdouble            *Angle;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid;
                                                                               

Abstract
    This function measures the line_angle of an element
                                                                            
Arguments

    msg
        return codes

    events
        not used

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    Angle
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to measure

Status returns

    om error codes

History
    bmr 05/13/87 : created

*/
class implementation Root;

#include "coimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

extern    IGRboolean    MAang3pt();
extern    IGRboolean    MAutoparms();

from  GRvg      import GRgenabsg;
from IGEgragad  import DPinrot;

/*----------------------------------------
 *  CO_ni_measure_line_angle
 *----------------------------------------
 */
IGRlong CO_ni_measure_line_angle(msg,
				 Events,
				 ModuleInfo,
				 Angle,
				 Units,
				 my_id,
				 MyChannelStruct,
				 ObjectsGrid )
     
     IGRlong              *msg;
     struct GRevent       *Events[];
     struct GRmd_env      *ModuleInfo;
     IGRdouble            *Angle;
     IGRchar              *Units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *MyChannelStruct;
     struct GRid          *ObjectsGrid;
     
{
  IGRlong                      status;         /* return code              */
  struct GRid                  line;
  IGRboolean                   b_status;
  struct IGRbsp_curve         *bspline_ptr;      
  IGRchar                     *ptr;
  IGRuint                      NumberObjectsFound;
  OM_S_OBJECT_LINKAGE          ChannelLinkage[1];
  struct GRid                  ViewGrid;
  IGRdouble                    Mangle[3];
  IGRpoint                     SweepPoint;    /* sweep point on the curve */
  IGRpoint                     IsectPoint;    /* isect point on the curve */
  IGRpoint                     AxisPoint;     /* axis  point on the curve */
  IGRlong                      segnum;
  IGRdouble                    t;
  
  *msg = MSSUCC;
  
  if ( MyChannelStruct != NULL )  /* extract object from channel */
    {
      /*
       *  find out who is on my channel
       */
      status = om$get_channel_objects(objid = my_id,
				      p_chanselect = MyChannelStruct,
				      list = ChannelLinkage,
				      size = 1,
				      count = &NumberObjectsFound );
      line.objid = ChannelLinkage[0].S_objid;
      line.osnum = ChannelLinkage[0].osnum;
    }
  else                            /* grid passed */
    
    {
      line = *ObjectsGrid;
    }
  
  /*
   * generate the abstract geometry of element 
   */
  status = om$send(msg = message GRvg.GRgenabsg(msg,         
					      &ModuleInfo->md_env.matrix_type,
						ModuleInfo->md_env.matrix,
						&ptr),
		   targetid = line.objid,
		   targetos = line.osnum);
  
  _m_check2q(status,*msg);
  
  bspline_ptr = (struct IGRbsp_curve *) ptr;
  b_status = MAutoparms ( msg,
			 bspline_ptr,
			 &Events[0]->located_object[0].geom_parms.u,
			 &segnum,
			 &t );
  
  ViewGrid.osnum = Events[0]->event.button.osnum;
  ViewGrid.objid = Events[0]->event.button.objid;
  
  Events[0]->event.button.x = bspline_ptr->poles[segnum*3+0];
  Events[0]->event.button.y = bspline_ptr->poles[segnum*3+1];
  Events[0]->event.button.z = bspline_ptr->poles[segnum*3+2];
  
  Events[1]->event.button.x = bspline_ptr->poles[(segnum-1)*3+0];
  Events[1]->event.button.y = bspline_ptr->poles[(segnum-1)*3+1];
  Events[1]->event.button.z = bspline_ptr->poles[(segnum-1)*3+2];
  
  b_status = CO_ni_world_to_view( msg,
				 Events[0],
				 &ViewGrid,
				 SweepPoint );
  
  b_status = CO_ni_world_to_view( msg,
				 Events[1],
				 &ViewGrid,
				 IsectPoint );
  
  /*
   *  The Sweep and Isect points are now in View coordinates and projected
   *  onto the view's X/Y plane.  To get a relative X axis point, we can add
   *  1.0 to the X coordinate of the Isect point.
   */
  AxisPoint[0] = IsectPoint[0] + 1.0;  /* X */
  AxisPoint[1] = IsectPoint[1];        /* Y */
  AxisPoint[2] = IsectPoint[2];        /* Z */
  
  b_status = MAang3pt( msg,   
		      AxisPoint,
		      IsectPoint,
		      SweepPoint,
		      Mangle );
  
  *Angle = ( Mangle[0] >= PI ) ? ( Mangle[0] - PI ) : Mangle[0];
  
  /*
   *  we are measuring angle
   */
  strncpy( Units, GRIO_ANGLE, GRIO_MAX_ALIAS_SIZE );
  
 quit:
  return( status );
}

end implementation Root;

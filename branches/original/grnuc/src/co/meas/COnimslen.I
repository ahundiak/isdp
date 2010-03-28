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

    IGRlong CO_ni_measure_length(msg,
                                 events,
                                 module_info,
                                 length,
                                 Units,
                                 my_id,
                                 p_chanselect,
                                 object_grids )

    IGRlong              *msg;
    struct GRevent       *events[];
    struct GRmd_env      *module_info;
    IGRdouble            *length;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *p_chanselect;
    struct GRid          *object_grids;


Abstract
    This function measures the length of an element

Arguments

    msg
        return codes

    events
        events[0] - u_parm in locate info used for segment id : srh - 09/18/89

    module
        context of located object

    cob_id
        object id of calling object, or at least some object

    length
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used

    p_chanselect
        pointer to a chaselect structure for located object on channel

    object_grids
        object to measure

Status returns

    om error codes

History
    trc 03/27/87 : created
    srh 09/15/89 : added absolute/local support

*/
class implementation Root;

#include "coimport.h"
#include "codebug.h"


#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "csmacros.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"


#define   U_PARMS        events[0]->located_object[0].geom_parms.u

from GRcurve  import   GRtotlength;

from GRvg     import   GRgetsize,
		       GRgetgeom,
		       GRgeomprops; 

/*----------------------------------------
 *  CO_ni_measure_length
 *----------------------------------------
 */
IGRlong CO_ni_measure_length(msg,
                             events,
                             module_info,
                             length,
                             units,
                             my_id,
                             p_chanselect,
                             object_grids )

     IGRlong              *msg;
     struct GRevent       *events[];
     struct GRmd_env      *module_info;
     IGRdouble            *length;
     IGRchar              *units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *p_chanselect;
     struct GRid          *object_grids;

{
   IGRint
      ret_size;
   IGRlong   size;

   IGRlong
      status = MSSUCC,
      chan_count;

   IGRboolean
      absolute_flag;

   struct GRprops
      properties;

   struct GRid
      measured_object;

   OM_S_OBJECT_LINKAGE  channel_linkage[1];



   _m_debug_str( "> CO_ni_measure_length" );

   if ( p_chanselect != NULL )
   {
      /*
       *  get grid of single element on channel for future sends by objid
       */
      status = lc$get_channel_count( objid        =  my_id,
                                     p_chanselect =  p_chanselect,
                                     count        = &chan_count );
      _m_checkq( status );

      status = lc$get_channel_objects( objid        =  my_id,
                                       p_chanselect =  p_chanselect,
                                       list         =  channel_linkage,
                                       size         =  1,
                                       count        = &chan_count);

      if ( status != OM_I_LISTOVFLOW )
      {
         *msg = MSSUCC;
         measured_object.objid = channel_linkage[0].S_objid;
         measured_object.osnum = channel_linkage[0].osnum;
      }
      _m_checkq( status );
   }

   /*
    *  IF ( ( element is segmented ) && ( the absolute flag is NOT set ) )
    *  THEN get the end point of the segment
    *       measure the distance between the endpoints
    *  ELSE measure total length of element
    */
   status = om$send(
         msg = message GRcurve.GRgeomprops( msg,
                                           &module_info->md_env.matrix_type,
                                            module_info->md_env.matrix,
                                           &properties ),
         targetid = measured_object.objid,
         targetos = measured_object.osnum );
   
   size = sizeof( IGRboolean );
   status = gr$get_local_abs_flag( msg    =  msg,
                                   sizbuf = &size,
                                   buffer = &absolute_flag,
                                   nret   = &ret_size );

   if ( ( ! absolute_flag ) && properties.is_segmented )
   {
      struct IGRbsp_curve *p_geom;
      IGRdouble t_parm;
      IGRlong segnum;

      status = om$send(
            msg = message GRvg.GRgetsize( msg,
                                         &module_info->md_env.matrix_type,
                                          module_info->md_env.matrix,
                                         &size ),
            targetid = measured_object.objid,
            targetos = measured_object.osnum );

      p_geom = (struct IGRbsp_curve *)om$malloc( size = size );

      status = om$send(
            msg = message GRvg.GRgetgeom( msg,
                                         &module_info->md_env.matrix_type,
                                          module_info->md_env.matrix,
                                          (IGRchar *)p_geom ),
            targetid = measured_object.objid,
            targetos = measured_object.osnum );
      _m_checkq( status );

      if ( MAutoparms( msg,  p_geom, &U_PARMS, &segnum, &t_parm ) )
      {
	 IGRboolean b_status;
         IGRdouble  points[6];
         IGRint     coord_index, pole_index;

         /* segment numbers begin with 1 */
         pole_index = (segnum - 1) * 3;

         for ( coord_index = 0; coord_index < 6; coord_index++ )
         {
            points[coord_index] =  p_geom->poles[pole_index + coord_index ];
         }

         status = cs$cvt_to_lcl( msg  = msg,
                                 cs_os = measured_object.osnum,
                                 npts = 2,
                                 wld  = points,
                                 lcl  = points );  /* is this ok (mike?) */
         _m_check2q( status, *msg );

         b_status = MA2ptdis( msg,
                             &points[0],
                             &points[3],
                              length );
         _m_check2q( b_status, *msg );
      }
   }
   else
   {
      IGRshort	local_matrix_type;
      IGRmatrix	local_matrix;

      status = COcompute_acs_lcl_matrix( msg,
                                         module_info->md_env.matrix_type,
                                         module_info->md_env.matrix,
                                         &local_matrix_type,
                                          local_matrix );

      /*
       *     measure the element
       */
      status = om$send(msg = message GRcurve.GRtotlength(msg,
                                                        &local_matrix_type,
                                                         local_matrix,
                                                         length ),
                       targetid = measured_object.objid,
                       targetos = measured_object.osnum );

      _m_check2p( status, *msg, "CO_ni_measure_length - failed GRtotlength" );

   }

   /*
    *  we are measuring distance
    */
   strncpy( units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );

quit:

   _m_debug_str( "< CO_ni_measure_length" );

   return( status );
}

end implementation Root;

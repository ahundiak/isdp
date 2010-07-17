
/* $Id: VCCmdPGdyn.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPGdyn.I
 *
 * Description:
 *      Implementation file for place guide command object dynamics
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPGdyn.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/07/14  22:51:56  pinnacle
# Replaced: vccmd/VCCmdPGdyn.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/03  18:14:54  pinnacle
# Replaced: vccmd/VCCmdPGdyn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/11/25  17:44:56  pinnacle
# Created: vccmd/VCCmdPGdyn.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPG;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igrdef.h"

#include "VCCmdStr.h"
#include "VCCmdForm.h"

/*
#define MY_DEBUG
*/


/***************************************************************************/

IGRint VCpgcndyn (struct          VCmlcndyn_info  *info,
                  struct          EX_button       *point,
                  IGRdouble                       *matrix,
                  struct          GRid            **objects,
                  IGRint                          *num_objects,
                  struct          DPele_header    **buffers,
                  IGRint                          *num_buffers,
                  IGRchar                         *dummy_in1,
                  IGRchar                         *dummy_in2,
                  IGRchar                         *dummy_in3,
                  IGRchar                         **dummy_out1,
                  IGRchar                         **dummy_out2,
                  IGRchar                         **dummy_out3)

{
  IGRint         indic;

  indic = info->numbuff - 1;


#ifdef MY_DEBUG
  printf ("pgcndyn, lastbuf %d\n",indic);
#endif

  /*A Update passed dynamic info parameter from event data */

  switch (info->dynamics)
  {
    case VC_MLDYN_LINE:

      /*@@@@@ would like to correct zdepth..... @@@@@ */
      /*C Copy passed button point to last seg of dynamic polyline */
   
      info->dpele_buff[indic].geometry.polyline->points[3] = point->x;
      info->dpele_buff[indic].geometry.polyline->points[4] = point->y;
      info->dpele_buff[indic].geometry.polyline->points[5] = point->z;

      break;

    default:
      {    /* section  -- get rid of compiler messages    */
        IGRdouble         *Lmatrix;
        struct GRid       *Lobjects;
        IGRint            *Lnum;
        IGRchar           *Ldummy;

        Lmatrix  = matrix;
        Lobjects = *objects;
        Lnum     = num_objects;
        Ldummy   = dummy_in1;
        Ldummy   = dummy_in2;
        Ldummy   = dummy_in3;
        Ldummy   = *dummy_out1;
        Ldummy   = *dummy_out2;
        Ldummy   = *dummy_out3;
      }

      printf("pgcndyn: only DYN and DYN3 implemented \n"); 
      printf("dynamics = %d \n", info->dynamics); 
      break;
  }

  /* Update passed buffer and num_buffer for dp$dynamics() */

  *buffers = info->dpele_buff;

  *num_buffers = info->numbuff;  

  return TRUE;
} /* end function to handle dynamics */


method dynamics ( int dynamics ; int * sts )
{
  int         status = OM_S_SUCCESS;
  IGRint      i;
  IGRint      inum;
  IGRdouble   d6points[6];        /* points of last seg */

  struct VCmlcndyn_info   pgcndyn_info;    
  struct IGRpolyline      line1;      /* current line     */
  struct IGRpolyline      line2;      /* 2nd for last seg */
  struct IGRdisplay       display2;

  extern IGRint  VCpgcndyn();

#ifdef MY_DEBUG
      printf (" --dynamics %d points\n",me->nMyPnts);
#endif

  if (me->nVert <= 0) return (OM_S_SUCCESS);

  if (dynamics == VC_MLDYN_LINE)
  {
      /*A prepare display buffers */
       
      pgcndyn_info.dynamics = dynamics;

      line1.points     = me->dVert;
      line1.num_points = me->nVert;

      status = 
      dp$build_dis_buffer(buffer      = &(pgcndyn_info.dpele_buff[0]),
                          type        = IGRPY,
                          geometry    = &line1,
                          display_att = &me->ActiveDisplay);

      /*A Line2 as one connecting "point" with last */
        
      /*C Copy event point in last seg */
      d6points[3] = me->event1.event.button.x;
      d6points[4] = me->event1.event.button.y;
      d6points[5] = me->event1.event.button.z;

      /*C Copy previous point in last seg */

      inum = (me->nVert - 1) * 3;

      for( i = 0; i < 3; i++ )
        d6points[i] = me->dVert[inum + i];

      line2.num_points = 2;
      line2.points = d6points;

      display2        = me->ActiveDisplay;
      display2.weight = 1;
      display2.style  = 1; 
   
      /*A Build buffers */

      status = 
      dp$build_dis_buffer(buffer      = &(pgcndyn_info.dpele_buff[1]),
                          type        = IGRPY,
                          geometry    = &line2,
                          display_att = &display2);

      /* invoke real handler dynamics */

      pgcndyn_info.numbuff = 2;

      status = 
      dp$dynamics(dyn_fun     = VCpgcndyn,
                  information = &pgcndyn_info);
  }
  else
  {
      status =
      om$send(msg = message CEO.dynamics( dynamics, sts ),
             mode = OM_e_wrt_message,
         targetid = my_id );
  }
  
  as$status();

  return OM_S_SUCCESS;
}

end implementation VCCmdPG;


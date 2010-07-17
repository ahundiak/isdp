
/* $Id: VCMLCnDyn.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLCnDyn.I
 *
 * Description:
 *      Implementation file for place cable command object dynamics
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLCnDyn.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/05/10  15:17:08  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/07  20:00:16  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/07  14:18:16  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.6  1997/04/28  22:34:28  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:00:22  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/03  18:12:42  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.3  1996/12/18  17:47:58  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/11  21:52:48  pinnacle
# Replaced: vccmd/VCMLCnDyn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:20:00  pinnacle
# Created: vccmd/VCMLCnDyn.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPC;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igrdef.h"

#include "VCproto.h"

#include "bsdistptpt.h"
/*
#include "bsproj0.h"
*/
extern int  BSproj0();

#define   VCPLUSVC       0.99995
#define   VCMINVC       -0.99995

/*    set statics so we can change dynamics approach
      while already in dynamics                         */

static  IGRboolean     bORTHO;
static  IGRboolean     bDEPTH;
static  IGRboolean     bGOING;

/*
#define MY_DEBUG
*/


/***************************************************************************/

/*      coordinate preservation function                                   */

IGRint VC_coord_pres (IGRdouble       *dCIN,
                      IGRdouble       *dPREV,
                      IGRdouble       *dMatrix,
                      IGRboolean       bDepth,
                      IGRboolean       bOrtho,
                      IGRboolean       bGoing,
                      IGRdouble       *dCOUT)
{
  IGRint          i, ii, iKeep;
  IGRdouble       dDist, dSav;
  
  for (i=0; i<3; i++)
    dCOUT[i] = dCIN[i];

  if (!bGoing) return 0;

  ii = iKeep = -1;
  dSav = 0.0;

  for (i=0; i<3; i++)
  {
     if ((dMatrix[i+8] > VCPLUSVC) || (dMatrix[i+8] < VCMINVC))
         ii = i;
  }

  if (ii >= 0)      /*    othogonal window           */
  {
    /*    NOTE: Ortho INCLUDES depth preservation   */

    if (bOrtho || bDepth)
      dCOUT[ii] = dPREV[ii];

    if (bOrtho)
    {
      for (i=0;i<3; i++)
      {
        if (i == ii) continue;

        dDist = fabs (dCOUT[i] - dPREV[i]);
        if (dDist > dSav)
        {
          iKeep = i;
          dSav  = dDist;
        }
      }

      for (i=0;i<3; i++)
      {
        if (i != iKeep)
          dCOUT[i] = dPREV[i];
      }
    }
  }
  else
  {                 /*    iso... window         */
                    /*    bdepth is meaningless here, see about ortho  */
    if (bOrtho)
    {
      IGRdouble       dOFF[3];

      for (i=0;i<3; i++)
      {
        dOFF[i] = fabs (dCIN[i] - dPREV[i]);

        if (dOFF[i] > dSav)
        {
           iKeep = i;
           dSav  = dOFF[i];
        }
      }

#ifdef MY_DEBUG
    printf (" ISO dcin   %f %f %f\n",dCIN[0],dCIN[1],dCIN[2]);
    printf (" ISO dprev  %f %f %f\n",dPREV[0],dPREV[1],dPREV[2]);
    printf (" ISO offset %f %f %f select %d\n",dOFF[0],dOFF[1],dOFF[2],iKeep);
#endif
      for (i=0;i<3; i++)
      {
        if (i != iKeep)
          dCOUT[i] = dPREV[i];
      }
    }
  }

  return 0;
}



/***************************************************************************/

IGRint VCmlcndyn (struct          VCmlcndyn_info  *info,
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
  IGRdouble      dP[3];

  indic = info->numbuff - 1;

  /*A Update passed dynamic info parameter from event data */

  switch (info->dynamics)
  {
    case VC_MLDYN_LINE:

      dP[0] = point->x;
      dP[1] = point->y;
      dP[2] = point->z;

      /*@@@@@ would like to correct zdepth..... @@@@@ */
      /*C Copy passed button point to last seg of dynamic polyline */
/*
      printf (" VEC %f %f %f %f\n",matrix[8], matrix[9],matrix[10],matrix[11]);
      info->dpele_buff[indic].geometry.polyline->points[3] = point->x;
      info->dpele_buff[indic].geometry.polyline->points[4] = point->y;
      info->dpele_buff[indic].geometry.polyline->points[5] = point->z;
*/

      VC_coord_pres (dP, info->dLL, matrix,
                     bDEPTH, bORTHO, bGOING,
                   &info->dpele_buff[indic].geometry.polyline->points[3]);

      break;

    case VC_MLDYN_CONN:
    case VC_MLDYN_ATTC:

      /*C Do nothing about given button "point" */
/*
      info->dpele_buff[indic].geometry.polyline->points[3] = point->x;
      info->dpele_buff[indic].geometry.polyline->points[4] = point->y;
      info->dpele_buff[indic].geometry.polyline->points[5] = point->z;
*/
/*
      VC_coord_pres (&info->dpele_buff[indic].geometry.polyline->points[0],
                     info->dLL, matrix,
                     bDEPTH, bORTHO, bGOING,
                   &info->dpele_buff[indic].geometry.polyline->points[3]);
*/
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

      printf("lncndyn: only DYN and DYN3 implemented \n"); 
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
  int		  status = OM_S_SUCCESS;

  IGRlong     retmsg;
  IGRint      i,n;
  IGRint      ifrom, ito, inum;
  IGRint      iprev;
  IGRdouble   d6points[6];        /* points of last seg */

  struct VCmlcndyn_info   lncndyn_info;    
  struct IGRpolyline      line2;      /* 2nd for last seg */
  struct IGRdisplay       display2;

  extern IGRint  VCmlblink();
  extern IGRint  VCmlcndyn();

#ifdef MY_DEBUG
      printf (" --dynamics %d points\n",me->nMyPnts);
#endif

  /*   do the default..... */
  if ((dynamics != VC_MLDYN_LINE) &&
      (dynamics != VC_MLDYN_CONN) &&
      (dynamics != VC_MLDYN_ATTC))
  {
    status =
    om$send(msg = message CEO.dynamics( dynamics, sts ),
           mode = OM_e_wrt_message,
       targetid = my_id );
    as$status();

    return OM_S_SUCCESS;
  }

  if (!(me->bGoing)) return (OM_S_SUCCESS);

  /*A prepare display buffers */
       
  lncndyn_info.dynamics = dynamics;

  ito   = -1;
  ifrom =  0;
  n=0;
  iprev = -1;
  for (i=0; i<=me->nMySect; i++)
  {
    switch (me->mySect[i].type)
    {
      default:
        ifrom = ito + 1;
        break;

      case VCC_POINT_EXTERN:
        break;

      case VCC_STRING:
        ito = me->mySect[i].iTo;
        inum = ito - ifrom + 1;

        if (iprev != VCC_POINT_EXTERN)
        {
          ifrom = me->mySect[i].iFrom;

          inum = ito - ifrom + 1;

          if (inum > 0)
          {
            me->DYline[n].points     = (IGRdouble *) &(me->myPnts[ifrom]);
            me->DYline[n].num_points = inum;

            status = 
            dp$build_dis_buffer(buffer      = &(lncndyn_info.dpele_buff[n]),
                                type        = IGRPY,
                                geometry    = &(me->DYline[n]),
                                display_att = &me->ActiveDisplay);
            n++;
          }
        }
        else
        {
          me->DYline[n-1].num_points = inum;
        }
        break;
    }

    iprev = me->mySect[i].type;
  }

  /*  for "line" state set up for rubberbanding    */

  if (dynamics == VC_MLDYN_LINE)
  { /*A Line2 as one connecting "point" with last */
        
    /*C Copy event point in last seg */
    d6points[3] = me->event1.event.button.x;
    d6points[4] = me->event1.event.button.y;
    d6points[5] = me->event1.event.button.z;

    /*C Copy previous point in last seg */

    for( i = 0; i < 3; i++ )
      d6points[i] = me->myPnts[(me->nMyPnts - 1)].xyz[i];

    line2.num_points = 2;
    line2.points = d6points;

    display2        = me->ActiveDisplay;
    display2.weight = 1;
    display2.style  = 1; 
   
    /*A Build buffers */

    status = 
    dp$build_dis_buffer(buffer      = &(lncndyn_info.dpele_buff[n]),
                        type        = IGRPY,
                        geometry    = &line2,
                        display_att = &display2);
    n++;
  }

  /* invoke real handler dynamics */

  lncndyn_info.numbuff = n;

  lncndyn_info.bDEPTH  = me->bDepth;
  lncndyn_info.bORTHO  = me->bOrtho;
  lncndyn_info.bGOING  = me->bGoing;

  status =
  om$send (msg = message VCCmdPC.VCDynRefresh (&retmsg),
      targetid = my_id);

  lncndyn_info.dLL[0]  = me->dLAST[0];
  lncndyn_info.dLL[1]  = me->dLAST[1];
  lncndyn_info.dLL[2]  = me->dLAST[2];

#ifdef MY_DEBUG
  printf ("to dynamics with %d buffers\n", n);
#endif

  status = 
  dp$dynamics(dyn_fun     = VCmlcndyn,
              information = &lncndyn_info);

  as$status();

  return OM_S_SUCCESS;
}

method   VCDynRefresh (IGRlong     *sts)
{

   *sts = MSSUCC;

   bORTHO = me->bOrtho;
   bDEPTH = me->bDepth;
   bGOING = me->bGoing;

   return (OM_S_SUCCESS);
}

end implementation VCCmdPC;


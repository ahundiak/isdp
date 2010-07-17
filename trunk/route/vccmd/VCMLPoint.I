
/* $Id: VCMLPoint.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLPoint.I 
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLPoint.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/05/23  13:13:44  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/07  20:00:04  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/07  14:17:44  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.6  1997/04/28  22:34:10  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:00:10  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/09  19:59:36  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:36:46  pinnacle
# Replaced: vccmd/VCMLPoint.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:22:42  pinnacle
# Created: vccmd/VCMLPoint.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 ****************************************************************************/


/*            METHODS

            VCGetNextPointType       
            VCPushPoint              
            VCPopPoint                */

class implementation VCCmdPC;

#include "VCproto.h"

#include "bsdistptpt.h"

/*
#define MY_DEBUG 
*/

/***********  EXTERN ***********/

from    IGEgragad       import  DPinrot;




method VCGetNextPointType ( long * sts )
{
  int      status = OM_S_SUCCESS;
  int      form_label;
  double   SelFlag;
        
  SelFlag = 0;
  form_label = VCC_PC_CONTROL_FORM;

#ifdef MY_DEBUG
  printf (" getnextpointtype\n");
#endif

  *sts = VCL_LINK_FREE_POINT;

  /*C Try Connect Point */

  FIg_get_value ( me->pCtlAtt, VCPCAB_CONNECT, &SelFlag );

  if( SelFlag == 1 ) 
  {
    _put_response( resp = VCL_LINK_CONNECT );
    *sts = VCL_LINK_CONNECT;
    goto quit;
  }

  /*C Try Attach  */

  FIg_get_value ( me->pCtlAtt, VCPCAB_ATTACH, &SelFlag );

  if( SelFlag == 1 ) 
  {
    _put_response( resp = VCL_LINK_ATTACH );
    *sts = VCL_LINK_ATTACH;
    goto quit;
  }

  /*C Default is free point */

#ifdef MY_DEBUG
  printf (" getnextpointtype free\n");
#endif

  _put_response( resp = VCL_LINK_FREE_POINT );
  *sts = VCL_LINK_FREE_POINT;

  quit:
  return OM_S_SUCCESS;
}


method VCPushPoint ( long * sts )
{
  IGRint       status;
  IGRdouble    d3pt[3];
  IGRdouble    dinpt[3];
  IGRmatrix    win_matrix;
  IGRlong      retmsg;
  IGRshort     nCP;

  nCP = 0;

  /*A Get input data point */ 

  if( me->event1.response == EX_DATA )
  {
    dinpt[0] = me->event1.event.button.x;
    dinpt[1] = me->event1.event.button.y;
    dinpt[2] = me->event1.event.button.z;

#ifdef MY_DEBUG
    printf (" event coords %f %f %f\n",dinpt[0], dinpt[1], dinpt[2]);
#endif

    status =
    om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
        senderid = NULL_OBJID,
        targetid = me->event1.event.button.objid,
        targetos = me->event1.event.button.osnum);
    as$status();

    if (!me->bBrk)
      VC_coord_pres (dinpt, me->dLAST, (IGRdouble *) win_matrix,
                     me->bDepth, me->bOrtho, me->bGoing, d3pt);
    else
    {
      IGRint    i;
 
      for (i=0;i<3;i++)
        d3pt[i] = dinpt[i];
    }

#ifdef MY_DEBUG
    printf (" win vector   %f %f %f\n",win_matrix[8], win_matrix[9],
                                       win_matrix[10]);
    printf (" -mod- coords %f %f %f\n",d3pt[0], d3pt[1], d3pt[2]);
#endif
  }
  else if( me->event1.response == EX_VALUE )
  {
#ifdef MY_DEBUG
    printf( "response type EX_VALUE not implemented \n");
#endif
  }

  if (me->bBrk)
  {
    double            dSelOff = 0;
    double            dSelOn  = 1;

    status =
    om$send (msg = message VCCmdPC.VCMLAddNode
                         (VCC_BREAK_OFF, d3pt, d3pt, nCP, nCP, NULL),
        targetid = my_id);

    FIg_set_value ( me->pCtlAtt, VCPCAB_BREAK, dSelOff );
    FIg_set_value ( me->pCtlAtt, VCPCAB_DIG, dSelOn );

    me->bBrk   = FALSE;
  }

  /*   add point to buffer    */

  status =
  om$send (msg = message VCCmdPC.VCMLAddStrP (d3pt),
      targetid = my_id);

  return OM_S_SUCCESS;
}



method VCPopPoint ( long * sts )
{
  IGRint   i;

  if( me->nSecPts > 1 )
  {
#ifdef MY_DEBUG
    i = me->nMyPnts - 1;
    printf( "removing %dth point at %f %f %f \n", i,
                                        me->myPnts[i].xyz[0], 
                                        me->myPnts[i].xyz[1], 
                                        me->myPnts[i].xyz[2]);
#endif
    for( i = 0; i < 3; i++ ) 
    {
      me->myPnts[me->nMyPnts - 1].xyz[i] = 0;
      me->dLAST[i] = me->myPnts[me->nMyPnts - 2].xyz[i];
    }
    me->nMyPnts--;
    me->nSecPts--;

    me->mySect[me->nMySect].iTo--;
  }
  else
  {
    *sts = VCL_EMPTY_STACK;
  }
 
  return OM_S_SUCCESS;
}

method  VCMLAddStrP (IGRdouble  *dCin)
{
  IGRint       status;
  IGRint       bufSize;
  IGRint       i;

  bufSize = om$dimension_of( varray = me->myPnts );
  if( bufSize < me->nMyPnts + 1 )
  {
    status =
    om$vla_set_dimension( varray = me->myPnts,
                            size = bufSize + VC_LINK_INCRBUF);
  }

  bufSize = om$dimension_of( varray = me->mySect );
  if( bufSize < me->nMySect + 1 )
  {
    status =
    om$vla_set_dimension( varray = me->mySect,
                            size = bufSize + VC_LINK_INCRBUF);
  }

  /*A Collinearity handling */

  if (me->nSecPts >= 2)
  {
    if( VC_colinear(me->myPnts[me->nMyPnts - 2].xyz,
                    me->myPnts[me->nMyPnts - 1].xyz,  dCin) )
    {
      /* replace previous point with new data. don't add new point */

#ifdef MY_DEBUG
    printf (" COLINEAR, new point %d\n",(me->nMyPnts - 1));
#endif
      for( i = 0; i < 3; i++ )
        me->dLAST[i] = me->myPnts[me->nMyPnts - 1].xyz[i] = dCin[i];

      goto quit;
    }
      /*C else fall through */
  }
  else
  if (me->nSecPts == 1)
  { /*   extra check for double first point   */
    if (VC_samept (me->myPnts[me->nMyPnts - 1].xyz,  dCin))
    {
#ifdef MY_DEBUG
       printf (" Skip first point\n");
#endif
       goto quit;
    }
  }

#ifdef MY_DEBUG
  printf (" AddStrP str %d - %f %f %f\n",
                me->nMyPnts,dCin[0], dCin[1], dCin[2]);
#endif

  /*C Copy input data point as new point */

  for( i = 0; i < 3; i++ )
    me->dLAST[i] = me->myPnts[me->nMyPnts].xyz[i] = dCin[i];

  if (me->nSecPts >= 1)
    me->nLdig = VC_digit (me->myPnts[me->nMyPnts - 1].xyz, dCin);
  else
    me->nLdig = 0;

  if (me->nSecPts == 0)
  { /*    open new string    */
    me->mySect[me->nMySect].type    = VCC_STRING;
    me->mySect[me->nMySect].iFrom   = me->nMyPnts;
    me->mySect[me->nMySect].strno   = 0;
    /*  set up for dynamics   */
    me->DYline[me->nMySect].points  = (IGRdouble *)
                                      &(me->myPnts[me->nMyPnts].xyz[0]);
  }

  me->bGoing = TRUE;
  me->bBegCP = FALSE;
  me->nSecPts++;

  me->mySect[me->nMySect].iTo   = me->nMyPnts;
  me->nMyPnts++;

  quit:
  return (OM_S_SUCCESS);
}



method  VCMLAddNode (IGRint      nType;
                     IGRdouble  *dCin;
                     IGRdouble  *dCout;
                     IGRshort    iCPbeg;
                     IGRshort    iCPend;
              struct GRid       *par_chld)
{
  IGRint       status;
  IGRint       bufSize;

  /*    expand buffers if needed     */

  bufSize = om$dimension_of( varray = me->myPnts );
  if( bufSize < me->nMyPnts + 1 )
  {
    status =
    om$vla_set_dimension( varray = me->myPnts,
                            size = bufSize + VC_LINK_INCRBUF);
  }

  bufSize = om$dimension_of( varray = me->mySect );
  if( bufSize < me->nMySect + 1 )
  {
    status =
    om$vla_set_dimension( varray = me->mySect,
                            size = bufSize + VC_LINK_INCRBUF);
  }

  if (nType == VCC_STRING)
  {
    status =
    om$send (msg = message VCCmdPC.VCMLAddStrP (dCin),
        targetid = my_id);

  }
  else
  {
#ifdef MY_DEBUG
    printf (" Addnode node %d - %f %f %f\n",nType, dCin[0], dCin[1], dCin[2]);
#endif

    if (me->nSecPts > 0)
    {  /*  close of string if necessary   */
      status =
      om$send (msg = message VCCmdPC.VCMLAddStrP (dCin),
          targetid = my_id);

#ifdef MY_DEBUG
    printf (" Forced close \n");
#endif

      me->nMySect++;
      me->nSecPts = 0;
    }

    /*  create node section      */

    me->mySect[me->nMySect].type    = nType;
    me->mySect[me->nMySect].iFrom   = iCPbeg;
    me->mySect[me->nMySect].iTo     = iCPend;

    if (par_chld != NULL)
    {
      me->ptObjs[me->nPtObjs].objid = par_chld->objid;
      me->ptObjs[me->nPtObjs].osnum = par_chld->osnum;

      me->mySect[me->nMySect].parno = me->nPtObjs;
      me->nPtObjs++;
    }
    else
      me->mySect[me->nMySect].parno = -1;

    me->nMySect++;
  }

  return OM_S_SUCCESS;
}

method  VCMLPopNode (long  *sts)
{

  return OM_S_SUCCESS;
}

end implementation VCCmdPC;



/* $Id: VCCmdPBi.I,v 1.2 2001/02/20 01:09:30 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPBi.I
 *
 * Description:
 *      Implementation file for place backshell command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPBi.I,v $
 *  Revision 1.2  2001/02/20 01:09:30  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.6  2000/03/16  20:01:14  pinnacle
# Replaced: vccmd/VCCmdPBi.I for:  by lawaddel for route
#
# Revision 1.5  2000/03/13  17:05:42  pinnacle
# Replaced: vccmd/VCCmdPBi.I for:  by lawaddel for route
#
# Revision 1.4  2000/03/03  21:34:50  pinnacle
# Replaced: vccmd/VCCmdPBi.I for:  by lawaddel for route
#
# Revision 1.3  1999/03/04  05:48:36  pinnacle
# Replaced: vccmd/VCCmdPBi.I for: TR 179801249 by aharihar for route
#
# Revision 1.2  1998/12/22  17:00:48  pinnacle
# Replaced: vccmd/VCCmdPBi.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/09/10  17:40:10  pinnacle
# Replaced: vccmd/VCCmdPBi.I for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:58:28  pinnacle
# Created: vccmd/VCCmdPBi.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  09/10/97      Alwin   Modified to add method VCBEvaluate and dynamics.
 *                        And VCBFollowCursor and VCBfollowdyn.
 *                        - for CR179701611
 *
 *  12/20/98      law     CR179802404 - Allow rotation of terminals/connectors
 * 4 Mar 1999	  Anand   TR 179801249 - Dynamics of backshell did not track
 * 			  the mouse pointer properly during placement
 *  02/25/00      Alwin   TR179702187 - Terminal not displaying after backshell
 *                        was placed on terminal.
 * 03/03/00       law     CR179900814 - If guide is parent, snap to end.
 *************************************************************************/

class implementation VCCmdPB;

#include "VCCmdForm.h"
#include "VCmacros.h"
#include <math.h>
#include "VDmem.h"
#include "VCstructs.h"
#include "matypemx.h"
#include "bstypes.h"
#include "mamulmx.h"
#include "bsinv_mat.h"
#include "dpdef.h"
#include "vrdbgmacros.h"
#include "bsdistptpt.h"

#define  DYNCOMP 100

/*
#define MY_DEBUG
*/

from   GRgraphics  import    GRaltconstruct, GRcopy,
                             GRdelete, GRdisplay, GRxform;
from   VCRoot      import    VCGetMatrix;
from   IGEgragad   import    DProtate;
from   VCGuide     import    VCGetCptCoord;

extern GRclassid        OPP_GRbcsubbc_class_id;
extern GRclassid        OPP_GR3dlinestr_class_id;

%safe
#include "VX_FIproto.h"
static IGRdouble dPrevCurPt[] = {0.0, 0.0, 0.0};
%endsafe



/*=======================================================================*/

method VCCmdStart ( int * sts )
{
  IGRshort   nCount;
  IGRlong    retmsg;
  IGRint     status;

  status = OM_S_SUCCESS;

  *sts = VC_RTC_ALLOK;

  me->Product    = VC_PROD_NONE;
  me->CommGadget = VC_GDG_CMD_BKSH;
  me->nTagCat    = 0;

  me->FCmain     = VC_FPOS_PB_MAIN;
  me->FCsub      = VC_FPOS_PB_SUB;
  me->FCcontrol  = -1;

  me->pSysAtt    = me->forms[VC_FRM_MAIN].form_ptr;
  me->pUsrAtt    = me->forms[VC_FRM_SUB].form_ptr;
  me->pCtlAtt    = NULL;

  me->nVCConn_type = VC_GEN_BKSHLL | VC_GEN_BITERM;

  vc$bksh_idx (p_count = &nCount,
               osnum   = me->My_OS);

  if (nCount > 0)
  {
     me->CClist = _MALLOC (nCount * VC_MAX_CCODE, IGRchar);
     me->CCdesc = _MALLOC (nCount * VC_MAX_SDESC, IGRchar);
     if (me->CClist == NULL) return (OM_E_NODYNMEM);

     vc$bksh_idx (p_count = &me->nCC,
                  osnum   = me->My_OS,
                  p_desc  = me->CCdesc,
                  p_codes = me->CClist);
  }

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdInit ( int * sts )
{
  IGRint   i;

  *sts = VC_RTC_ALLOK;

  me->ConstrId.objid = NULL_OBJID;
  me->ConstrId.osnum = me->ModuleInfo.md_id.osnum;
  me->RefId.objid    = NULL_OBJID;
  me->RefId.osnum    = me->ModuleInfo.md_id.osnum;

  for (i=0; i<16; i++)
    me->dValues[i] = 0;

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdGetRef ( int * sts )
{
  int          status;
  me->My_localret = VC_RTC_ALLOK;

 *sts = VC_RTC_ALLOK;

  /*A get the located object */
  me->RefId = me->event1.located_object[0].located_obj;

  status =
  as$make_source (go_grid  = me->RefId,
                  mod_env  = &me->event1.located_object[0].module_info,
                  as_os    = me->ModuleInfo.md_id.osnum,
                  as_grid  = &me->RefId);

__DBGpr_mat("ModuleInfo matrix from VCCmdGetRef",me->ModuleInfo.md_env.matrix);
#ifdef MY_DEBUG
  printf (" Refid bksh <%d %d>\n",me->RefId.objid, me->RefId.osnum);
#endif

  return OM_S_SUCCESS;
}

method VCBEvaluate ( int *sts )
{
  IGRint                  status;
  IGRint                  i;
  IGRint                  NumPar;
  IGRlong                 retmsg;
  struct GRid             parId[4];

  /*  define the parent   */

  for(i=0;i<4;i++)
  {
    parId[i].objid      = NULL_OBJID;
    parId[i].osnum      = me->ModuleInfo.md_id.osnum;
  }

  /*  attribute parents   */
  status =
  om$send (msg = message VCAT.VCAT_coll (&retmsg, &parId[0], &parId[1]),
      targetid = my_id);

  me->GenInfo.nNbAttr       = 2;

  parId[me->GenInfo.nNbAttr] = me->RefId;
  NumPar                     = 3;

  me->GenInfo.nStat         = VC_STATUS_INIT;
  me->GenInfo.nType         = me->nVCConn_type;
  me->GenInfo.cRep          = me->nACTrep;
  me->GenInfo.nNbTopo       = 1;
  me->GenInfo.nProduct      = me->Product;
  me->GenInfo.nProduct      = me->Product;
  me->GenInfo.bNoMtoFlg     = me->bMTO;

  strcpy (me->GenInfo.szCode, me->CompCode);
  VC_INITSTR (me->GenInfo.szTagno);

  me->GenInfo.Attr.Term.nCpt           = 0;
  me->GenInfo.Attr.Term.nOff           = me->nVal;
  me->GenInfo.Attr.Term.dOffVal        = me->dValues;
__DBGpr_mat("dValue matrix sent to CreateBksh",me->dValues);
__DBGpr_mat("ModuleInfo matrix sent CreateBksh",me->ModuleInfo.md_env.matrix);
  status =
  VC_CreateBksh (&retmsg, NumPar, parId, &me->GenInfo, me->ActiveLevel,
                 &me->ActiveDisplay, &me->ModuleInfo, &me->ConstrId);

return OM_S_SUCCESS;
}

IGRint VCBfollowdyn( strComp, point, matrix, objects, num_objects,
                    buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
                    dummy_out1, dummy_out2, dummy_out3 )
struct          VCParams        *strComp;
struct          EX_button       *point;
IGRdouble                       *matrix;
struct          GRid            **objects;
IGRint                          *num_objects;
struct          DPele_header    **buffers;
IGRint                          *num_buffers;
IGRchar                         *dummy_in1;
IGRchar                         *dummy_in2;
IGRchar                         *dummy_in3;
IGRchar                         **dummy_out1;
IGRchar                         **dummy_out2;
IGRchar                         **dummy_out3;
/*.VCBfollowdyn */
{
  IGRshort      nFour=4, nOne=1;
  IGRshort      nTranType;
  IGRlong       status, retcode;
  IGRdouble     Matrix[16], dCoord[4], dLocCoord[4], OutMatrix[16];
  IGRdouble	TempMatrix[16];
  BSrc          bsretcode;

  status  = OM_S_SUCCESS;

  dCoord[0] = point->x;
  dCoord[1] = point->y;
  dCoord[2] = point->z;
  dCoord[3] = 1.0;

/*** Below modified for rotation of parent cr179802404 ****/
  status = om$send ( msg = message VCRoot.VCGetMatrix( &retcode, -1, 
                                        Matrix, &strComp->md_env ),
                                senderid = NULL_OBJID,
                                targetid = strComp->Parent.objid,
                                targetos = strComp->Parent.osnum );

/*** Block added for CR179900814 ***/
{
   GRclassid          parentClassId;
   IGRchar         c200ClassName[200];
   IGRshort CpNum;
   IGRdouble dCptCoor0[3], dCptCoor1[3];

   om$get_classid (objid = strComp->Parent.objid,
                   osnum = strComp->Parent.osnum,
               p_classid = &parentClassId);

   om$get_classname(classid = parentClassId, classname = c200ClassName);
   if(!strcmp(c200ClassName,"VCGuide"))
   {
      IGRint i;
      IGRdouble dP0,dP1;
      BSrc  rc;

      CpNum = 0;
      status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retcode,
                 CpNum,dCptCoor0, &strComp->md_env ),
                                senderid = NULL_OBJID,
                                targetid = strComp->Parent.objid,
                                targetos = strComp->Parent.osnum );
      CpNum = 1;
      status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retcode,
                 CpNum,dCptCoor1, &strComp->md_env ),
                                senderid = NULL_OBJID,
                                targetid = strComp->Parent.objid,
                                targetos = strComp->Parent.osnum );

      dP1 = BSdistptpt (&rc, dCoord, dCptCoor1);
      dP0 = BSdistptpt (&rc, dCoord, dCptCoor0);

      if(dP0 < dP1)
      {
         for(i=0;i<3;i++) {
           dCoord[i] = dCptCoor0[i];
         }
      }
      else
      {
         for(i=0;i<3;i++) {
           dCoord[i] = dCptCoor1[i];
         }
      }
   }

}


  MAidmx( &retcode, TempMatrix );
  TempMatrix[3] = Matrix[3];
  TempMatrix[7] = Matrix[7];
  TempMatrix[11] = Matrix[11];
	/* Following line added by Anand for TR 179801249 */
  TempMatrix[15] = Matrix[15];

  BSinv_mat( nFour, TempMatrix, OutMatrix, &bsretcode );
  MAmulmx( &retcode, &nFour, &nFour, &nOne, OutMatrix, dCoord, dLocCoord );

  TempMatrix[3] = dPrevCurPt[0] - dLocCoord[0];
  TempMatrix[7] = dPrevCurPt[1] - dLocCoord[1];
  TempMatrix[11] =dPrevCurPt[2] - dLocCoord[2];

  dPrevCurPt[0] = dLocCoord[0];
  dPrevCurPt[1] = dLocCoord[1];
  dPrevCurPt[2] = dLocCoord[2];
  /* -- Apply transformation matrix to graphics -- */
__DBGpr_mat("TempMatrix" , TempMatrix);
  BSinv_mat( nFour, TempMatrix, OutMatrix, &bsretcode );

  MAtypemx( &retcode, OutMatrix, &nTranType);
__DBGpr_mat("OutMatrix" , OutMatrix);
  status =
  om$send ( msg      = message GRgraphics.GRxform ( &retcode,
                                                &strComp->md_env,
                                                &nTranType,
                                                OutMatrix,
                                                &strComp->CompId.objid ),
                     senderid = NULL_OBJID,
                     targetid =  strComp->CompId.objid,
                     targetos =  strComp->CompId.osnum );

  *objects = &strComp->CompId;
  *num_objects = 1;
  {
        /* This has been added to get rid of compiler messages  */
        IGRdouble         *Lmatrix;
        IGRchar           *Ldummy;

        *num_buffers = 0;
        *buffers = NULL;
        Lmatrix  = matrix;
        Ldummy   = dummy_in1;
        Ldummy   = dummy_in2;
        Ldummy   = dummy_in3;
        Ldummy   = *dummy_out1;
        Ldummy   = *dummy_out2;
        Ldummy   = *dummy_out3;
  }

return OM_S_SUCCESS;
}

struct VCParams BackShell;

IGRint VCBFollowCursor ( struct GRid *CompId, struct GRmd_env *md_env )
{
   IGRlong status = OM_S_SUCCESS, msg;
   struct GRid Duplicate;

   //BackShell.CompId = *CompId; tr179702187
   BackShell.md_env = *md_env;

      /* Modified for tr179702187 */
   BackShell.CompId.osnum = CompId->osnum;
   status = om$send ( msg = message GRgraphics.GRcopy( &msg, &BackShell.md_env,
								  &BackShell.md_env, &BackShell.CompId.objid ),
						   senderid = NULL_OBJID,
						   targetid = CompId->objid,
						   targetos = CompId->osnum );

   /* This "dPrevCurPt" needs to be intialized before calling the
      "dp$dynamics" macro, or else it gets retained and it will cause problem
      if stay in the command and keep executing the forms for successive
      placement of BackShells */
   dPrevCurPt[0] = dPrevCurPt[1] = dPrevCurPt[2] = 0.0;

   /*printf("\n Calling dp$dynamics \n" );*/
   status = dp$dynamics ( dyn_fun     = VCBfollowdyn,
                          information = &BackShell );

      /* Modified for tr179702187 */
   if( BackShell.CompId.objid != NULL_OBJID )
   {
      enum GRdpmode Mode;
__DBGpr_mat("md_env matrx",md_env->md_env.matrix);
      Mode = GRbe;
      status = om$send ( msg = message GRgraphics.GRdisplay( &msg,
                                   &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix, &Mode,
                                   &md_env->md_id ),
                         senderid = NULL_OBJID,
                           targetid = CompId->objid,
                           targetos = CompId->osnum );

	  /*
      status = om$send ( msg = message GRgraphics.GRdelete( &msg, md_env ),
                                   senderid = NULL_OBJID,
                                   targetid = CompId->objid,
                                   targetos = CompId->osnum );

      status = om$send ( msg = message GRgraphics.GRdelete( &msg, md_env ),
                                   senderid = NULL_OBJID,
                                   targetid = BackShell.CompId.objid,
                                   targetos = BackShell.CompId.osnum );
     //BackShell.CompId.objid = NULL_OBJID;
	  */

	 //added this code for deleting the duplicate Connection Components
	 // for TR179702187
	 {
		  IGRint cn_type;
		  struct GRid	ObjectList[2];
		  ObjectList[0] = *CompId;
		  ObjectList[1] = BackShell.CompId;

		  nd$wait_batch (type   = GR_DELETED,
					 l_object   = ObjectList,
					 l_obj_info = &cn_type,
					 nb_obj     = 2);

		  nd$exec_batch();
             /* Added to redisplay the terminal parent for tr179702187 */
                  Mode = GRbd;
                  status = om$send ( msg = message GRgraphics.GRdisplay( &msg,
                                   &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix, &Mode,
                                   &md_env->md_id ),
                         senderid = NULL_OBJID,
                         targetid = BackShell.Parent.objid,
                         targetos = BackShell.Parent.osnum );

	 }
   }

   return status;
}

method dynamics ( int dynamics; int *sts )
{
  IGRlong status;
  *sts = MSSUCC;

  if ( dynamics == DYNCOMP )
  {
        BackShell.Parent = me->RefId;

        status =
        VCBFollowCursor( &me->ConstrId, &me->ModuleInfo);
  }

 
  /* Alwin - tr179702187 */
  {
	enum GRdpmode Mode;
	  IGRint cn_type;
	  IGRlong retmsg;

	  Mode = GRhd;
	  status = om$send ( msg = message GRgraphics.GRdisplay( &retmsg,
			   &me->ModuleInfo.md_env.matrix_type,
			   me->ModuleInfo.md_env.matrix, &Mode,
			   &me->ModuleInfo.md_id ),
		   targetid = me->RefId.objid,
		   targetos = me->RefId.osnum );

	  nd$wait_batch (type   = GR_GEOM_POSTED,
				 l_object   = &me->RefId,
				 l_obj_info = &cn_type,
				 nb_obj     = 1);

	  nd$exec_batch();
  }

return OM_S_SUCCESS;
}

end implementation VCCmdPB;


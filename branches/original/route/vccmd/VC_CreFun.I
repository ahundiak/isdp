
/* $Id: VC_CreFun.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VC_CreFun.I
 *
 * Description:
 *      Implementation file for creation functions
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VC_CreFun.I,v $
 *  Revision 1.3  2002/05/08 15:48:24  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.2  2001/02/20 01:10:02  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/20  04:13:16  pinnacle
# Replaced: vccmd/VC_CreFun.I for:  by kddinov for route
#
# Revision 1.4  1998/04/03  22:07:02  pinnacle
# Replaced: vccmd/VC_CreFun.I for:  by kddinov for route
#
# Revision 1.3  1998/03/31  07:12:14  pinnacle
# Replaced: vccmd/VC_CreFun.I for: TR 179800045 by aharihar for route
#
# Revision 1.2  1998/03/12  10:18:28  pinnacle
# Replaced: vccmd/VC_CreFun.I for: TR179800045 by aharihar for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/11  21:55:22  pinnacle
# Replaced: vccmd/VC_CreFun.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  22:54:48  pinnacle
# Replaced: vccmd/VC_CreFun.I for:  by hverstee for cabling
#
# Revision 1.2  1997/04/29  20:55:58  pinnacle
# Replaced: vccmd/VC_CreFun.I for:  by hverstee for cabling
#
# Revision 1.1  1997/04/28  22:36:10  pinnacle
# Created: vccmd/VC_CreFun.I by hverstee for cabling
#
 *
 * History:
 *  12/20/96      hv      New
 *  12 Mar 98     Anand   Set the cable instance immediately after the object
 *			  is created and before NDplace is called.
 *  27 Mar '98    Anand   VCCSetOffset method was modified to take care of
 *                        possible future revision. Some changes needed to be 
 *                        made here to take care of those modifications.
 *  4-98	KDD	VCCSetOffset return to 2 arguments. 
 *
 *************************************************************************/

class implementation VCAT;

#include "VDmem.h"
#include "VCcreate.h"
#include "VCstructs2.h"

#include "vrdbgmacros.h"
#include "vc_default.h"

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);

/*
#define  MY_DEBUG
*/

from  ACrg_collect  import  ACset_list_attribute;
from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  ACcreate;
from  ACrg_collect  import  GRchgname;

from  GRgraphics    import  GRdelete, GRdisplay;
from  ACncpx        import  NDplace;

from  NDnode        import  NDchg_state;
from  VCRoot        import  VCChildren;

from  VCRoot        import  VCInitInstance;
from  VCCable       import  VCCSetOffset, VCCSetCon_Data;

extern GRclassid   OPP_ACrg_collect_class_id;
extern GRclassid   OPP_VCElTerm_class_id;
extern GRclassid   OPP_VCFoTerm_class_id;
extern GRclassid   OPP_VCElCable_class_id;
extern GRclassid   OPP_VCFoCable_class_id;
extern GRclassid   OPP_VCGuide_class_id;
extern GRclassid   OPP_VCBksh_class_id;




extern
IGRint      VC_CreateColl (IGRlong        *msg,
                           IGRshort        nNum,
                    struct ACrg_coll      *Coll,
                    struct GRid           *CGRid)
{
  IGRlong    retmsg;
  IGRint     status;
  IGRint     Num;
  IGRchar    szPathName[20];

  *msg = MSFAIL;
  Num  = nNum;
  szPathName[0] = '\0';

  status =
  om$construct ( classid = OPP_ACrg_collect_class_id,
                 p_objid = &(CGRid->objid),
                 osnum   = CGRid->osnum,
                 msg     = message ACrg_collect.ACcreate
                                              (&retmsg,szPathName ) ) ;
  if (status & OM_S_SUCCESS)
  {
    status =
    om$send( msg = message NDnode.NDchg_state
                           ((IGRchar)ND_DEL_NO_CH ,(IGRchar)~ND_DEL_NO_CH),
        senderid = NULL_OBJID,
        targetid = CGRid->objid,
        targetos = CGRid->osnum ) ;
    as$status ();

    status =
    om$send( msg = message ACrg_collect.ACset_list_attribute
                                       (&retmsg, Num, Coll),
        senderid = NULL_OBJID,
        targetid = CGRid->objid,
        targetos = CGRid->osnum ) ;

    *msg = MSSUCC;
  }

  return (OM_S_SUCCESS);
}


extern
IGRint      VC_CreateTerm (IGRlong        *msg,
                           IGRint          NumPar,
                    struct GRid           *Parents,
                    struct VCGenInfo      *GenIn,
                           short           Level,
                    struct IGRdisplay     *DispAtt,
                    struct GRmd_env       *md_env,
                    struct GRid           *OutId)
{
  IGRint           status;
  IGRlong          retmsg;
  GRclassid        ConClassid;
  IGRchar         *pConst;

  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;

  /*A ----- Fill in ConstructionList structure ----- */

  *msg   = MSSUCC;
  pConst = (IGRchar *) &ConstructionList;

  ConstructionList.msg        = &retmsg;
  ConstructionList.env_info   = md_env;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = Level;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = 0;
  ConstructionList.display    = DispAtt;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

/* 4-98 KDD use single point default selection function
*  if (GenIn->nProduct == VC_PROD_ELEC)
*    ConClassid = OPP_VCElTerm_class_id;
*  else
*    ConClassid = OPP_VCFoTerm_class_id;
*/

  status =VCGetDefaultInfo( (IGRint) GenIn->nProduct, 
				VC_GET_TERM_CLASS_ID, (char *)&ConClassid);


  assoc_list.num_parents      = NumPar;
  assoc_list.parents          = Parents;
  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) GenIn;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

  status =
  om$construct (classid = ConClassid,
                p_objid = &OutId->objid,
                osnum   = OutId->osnum,
                 msg    = message ACncpx.NDplace
                            (&assoc_list, md_env, pConst));

  if (!(status & OM_S_SUCCESS))
  {
    *msg = MSFAIL;

    status =
    om$send (msg   = message GRgraphics.GRdelete (&retmsg, md_env),
          senderid = NULL_OBJID,
          targetid = OutId->objid,
          targetos = OutId->osnum) ;
    as$status();
  }

  return (status);
}

extern
IGRint      VC_CreateCab  (IGRlong        *msg,
                           IGRint          NumPar,
                    struct GRid           *Parents,
                    struct VCGenInfo      *GenIn,
                           short           Level,
                    struct IGRdisplay     *DispAtt,
                    struct GRmd_env       *md_env,
                    struct GRid           *OutId,
		    IGRshort               nTermCount,
                    IGRdouble             *Offset,
		    IGRboolean		   bSubCable,
		    IGRint		   NumLeads,
		    IGRchar		  (*LdNames)[VC_MAX_LEAD_ID]
			  )
{
  IGRint           status,i;
  IGRlong          retmsg;
  GRclassid        ConClassid;
  IGRchar         *pConst;

  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;

  SetProc( VC_CreateCab ); Begin;

  /*A ----- Fill in ConstructionList structure ----- */

  *msg   = MSSUCC;
  pConst = (IGRchar *) &ConstructionList;

  ConstructionList.msg        = &retmsg;
  ConstructionList.env_info   = md_env;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = Level;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = 0;
  ConstructionList.display    = DispAtt;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

/* 4-98 KDD use single point default selection function
*  if (GenIn->nProduct == VC_PROD_ELEC)
*    ConClassid = OPP_VCElCable_class_id;
*  else
*    ConClassid = OPP_VCFoCable_class_id;
*/

  status =VCGetDefaultInfo( (IGRint) GenIn->nProduct, 
				VC_GET_CAB_CLASS_ID, (char *)&ConClassid);


  assoc_list.num_parents      = NumPar;
  assoc_list.parents          = Parents;
  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) GenIn;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

/* Following lines of code added by Anand for TR 179800045 */

  /* -------------------------- */
  /* -- CONSTRUCT THE OBJECT -- */
  /* ------------------------- */
 
  status =
  om$construct (classid = ConClassid,
                p_objid = &OutId->objid,
                osnum   = OutId->osnum);
  __DBGpr_obj(" new object", *(OutId) );
  __CheckSTS( status , "construction of cable object failed!",wrapup);

  /* -------------------------- */
  /* -- INITIALIZE INSTANCE -- */
  /* ------------------------- */
 
  status = om$send( msg      = message VCRoot.VCInitInstance (&retmsg),
                    senderid = NULL_OBJID,
                    targetid = OutId->objid,
                    targetos = OutId->osnum) ;
 
  __DBGpr_int( " Term Count ", nTermCount );
 
  /* -------------------------- */
  /* -- SET TERMINAL OFFSETS -- */
  /* ------------------------- */
 
  if( nTermCount )
  {
      struct VCOffset *OffsetStruct;
      OffsetStruct = _CALLOC( nTermCount, struct VCOffset);

      for( i=0; i<nTermCount; i++ )
      {
	 OffsetStruct[i].Index = i;
	 OffsetStruct[i].Offset[0] = Offset[3*i] ;
	 OffsetStruct[i].Offset[1] = Offset[3*i+1] ;
	 OffsetStruct[i].Offset[2] = Offset[3*i+2] ;

	 __DBGpr_vec( " Vectors ", &Offset[3*i] );
      }

      /* For release 2.5, pass the third argument as zero to signify that
	 the type of OffsetStruct is struct VCOffset. */

      status = om$send ( msg = message VCCable.VCCSetOffset( OffsetStruct,
							     nTermCount),
		    senderid = NULL_OBJID,
		    targetid = OutId->objid,
		    targetos = OutId->osnum);
      __CheckSTS(status,"setting offset of cable wrt terminal failed!",wrapup);
      _FREE(OffsetStruct);
  }
 
  /* -------------------------- */
  /* -- NOW CALL THE NDPLACE -- */
  /* ------------------------- */
 
  status = om$send ( msg = message ACncpx.NDplace(&assoc_list, md_env, pConst),
                senderid = NULL_OBJID,
                targetid = OutId->objid,
                targetos = OutId->osnum);
  __CheckSTS( status , "NDplace didn't quite work!", wrapup);


/* Above lines of code added by Anand for TR 179800045 */

 /* ----------------------------------------------------------------------- *
  * Moved these calls from within NDplace (VCCplace.I) to here. VCCbInitCon *
  * is being replaced by VCCSetCon_Data to support normal and sub-cables.   *
  * Calling this method requires that the cable's relationships be set.     *
  * Further, NDplace did not provide an option to send the lead information *
  * through its arguments.						    *
  * ----------------------------------------------------------------------- */

  /* ------------------------ */
  /*A Initialize Connectivity */
  /* ------------------------ */

  status =
  om$send( msg = message VCCable.VCCSetCon_Data( &retmsg, NumLeads, NULL,
						 LdNames ),
      senderid = NULL_OBJID,
      targetid = OutId->objid,
      targetos = OutId->osnum );

wrapup:
  if (!(status & OM_S_SUCCESS))
  {
    *msg = MSFAIL;

    status =
    om$send (msg   = message GRgraphics.GRdelete (&retmsg, md_env),
          senderid = NULL_OBJID,
          targetid = OutId->objid,
          targetos = OutId->osnum) ;
    as$status();

    OutId->objid = NULL_OBJID;
  }

  End
  return (status);
}

extern
IGRint      VC_CreateGd   (IGRlong        *msg,
                           IGRint          NumPar,
                    struct GRid           *Parents,
                    struct VCGenInfo      *GenIn,
                           short           Level,
                    struct IGRdisplay     *DispAtt,
                    struct GRmd_env       *md_env,
                    struct GRid           *OutId)
{
  IGRint           status;
  IGRlong          retmsg;
  GRclassid        ConClassid;
  IGRchar         *pConst;

  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;

  /*A ----- Fill in ConstructionList structure ----- */

  *msg   = MSSUCC;
  pConst = (IGRchar *) &ConstructionList;

  ConstructionList.msg        = &retmsg;
  ConstructionList.env_info   = md_env;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = Level;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = 0;
  ConstructionList.display    = DispAtt;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

  ConClassid                  = OPP_VCGuide_class_id;

  assoc_list.num_parents      = NumPar;
  assoc_list.parents          = Parents;
  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) GenIn;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

  status =
  om$construct (classid = ConClassid,
                p_objid = &OutId->objid,
                osnum   = OutId->osnum,
                 msg    = message ACncpx.NDplace
                            (&assoc_list, md_env, pConst));

  if (!(status & OM_S_SUCCESS))
  {
    *msg = MSFAIL;

    status =
    om$send (msg   = message GRgraphics.GRdelete (&retmsg, md_env),
          senderid = NULL_OBJID,
          targetid = OutId->objid,
          targetos = OutId->osnum) ;
    as$status();
  }

  return (status);
}

extern
IGRint      VC_CreateBksh (IGRlong        *msg,
                           IGRint          NumPar,
                    struct GRid           *Parents,
                    struct VCGenInfo      *GenIn,
                           short           Level,
                    struct IGRdisplay     *DispAtt,
                    struct GRmd_env       *md_env,
                    struct GRid           *OutId)
{
  IGRint           status;
  IGRlong          retmsg;
  GRclassid        ConClassid;
  IGRchar         *pConst;

  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;

  /*A ----- Fill in ConstructionList structure ----- */

  *msg   = MSSUCC;
  pConst = (IGRchar *) &ConstructionList;

  ConstructionList.msg        = &retmsg;
  ConstructionList.env_info   = md_env;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = Level;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = 0;
  ConstructionList.display    = DispAtt;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

  ConClassid                  = OPP_VCBksh_class_id;

  assoc_list.num_parents      = NumPar;
  assoc_list.parents          = Parents;
  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) GenIn;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

  status =
  om$construct (classid = ConClassid,
                p_objid = &OutId->objid,
                osnum   = OutId->osnum,
                 msg    = message ACncpx.NDplace
                            (&assoc_list, md_env, pConst));

  if (!(status & OM_S_SUCCESS))
  {
    *msg = MSFAIL;

    status =
    om$send (msg   = message GRgraphics.GRdelete (&retmsg, md_env),
          senderid = NULL_OBJID,
          targetid = OutId->objid,
          targetos = OutId->osnum) ;
    as$status();
  }

  return (status);
}





end implementation VCAT;


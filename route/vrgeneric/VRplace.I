/* $Id: VRplace.I,v 1.5 2002/05/21 16:34:52 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrgeneric / VRplace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRplace.I,v $
 *  Revision 1.5  2002/05/21 16:34:52  anand
 *  TR 6375
 *
 *  Revision 1.4  2002/05/03 13:50:57  louis
 *  TR5959 pload cleanup for symbolization
 *
 *  Revision 1.3  2001/02/20 01:14:20  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 20:44:31  anand
 *  SP merge
 *
# Revision 1.1  2000/05/23  23:19:30  pinnacle
# Created: route/vrgeneric/VRplace.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/07/17  19:09:50  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by r250_int for route
#
# Revision 1.4  1997/07/07  21:49:26  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by yzhu for route
#
# Revision 1.3  1997/03/05  18:13:50  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by hverstee for route
#
# Revision 1.2  1997/02/28  11:19:04  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/11  15:52:42  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by hverstee for route240
#
# Revision 1.3  1996/03/19  22:04:32  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  00:02:18  pinnacle
# Replaced: vrgeneric/VRplace.I for:  by r240_int for route240
#
 *
 * History:
 *  MM/DD/YY   AUTHOR  DESCRIPTION
 *  01/16/96   tlb      Add protoypes
 *  07/07/97   yzhu	use VDsetAttDrSymb 
 *  05/02/02   law      tr5959 cleanup
 *  05/21/02   Anand    TR 6375 - symbology incorrect for new comps.
 *************************************************************************/
/*
     CLASS  NAME: VRGeneric
     METHOD NAMES: NDplace

     Abstract: This file contains the method to place a generic Generic
    
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------    ------------------------------------
     *msg    IGRlong    return code

     NOTES:
     The return code in the input argument list can have the 
    following values:

    MSSUCC - successful
          MSFAIL - if failure


     CHANGE HISTORY:

  * 09-DEC-91  1.4.3.14  
    Bruno
    - VRInitInstances method has been removed.
      VRplace and VREvaluate methods now call VRSetInstances.
    - VREvaluate has one more argument "Graphics" which returns
      the component's graphics.

***********************************************************************/



class implementation VRGeneric;

#include "asbox.h"
#include "nddef.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "acrepdef.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"
#include "vddgndef.h"
#include "v_drw.h"


#define AS_DEBUG  1
/*
#define MY_DEBUG  1
*/

extern GRclassid  OPP_ACheader_class_id;


method NDplace( struct GRas      *asso_lis;
                struct GRmd_env  *md_env;
                       IGRchar   *go_cnst_lis)
{
  IGRlong     retmsg;
  IGRint      status,i;
  IGRint      FeetCount,ConnectType;
  IGRchar     szMacroName[10];

  struct GRid         FeetList [1];
  struct GRsymbology  symb;
  struct GRid             hdr, collId; /* for symbology collector */
  VD_drwOutputData        *output = NULL;

  SetProc( VRGeneric_NDplace ); Begin


  if ( asso_lis->as_attr == NULL || md_env == NULL || go_cnst_lis == NULL ) 
  {
    /*| ERROR -> MISSING ATTRIBUTES */
    End
    return OM_E_INVARG;
  }

  /* KLUDGE FOR CORRECTIONS WHICH DO NOT EVALUATE B4 PLACING */
  if ( !me->nNbAttr )
  {  /*| Correction treatment */
    ConnectType = ND_NEW;
    me->nNbAttr = ((struct VRGenInfo *) asso_lis->as_attr)->nNbAttr;

    /* -- attach myself to my definition -- */

    status =
    om$send(  msg = message VRGeneric.VRGetDefName (&retmsg,szMacroName),
         targetid = my_id );
    as$status(action = RET_STATUS);

    status =
    om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg,szMacroName),
       targetid = my_id );
    as$status(action = RET_STATUS);

  }
  else  ConnectType = ND_ADD;

  /* -------------------------- */
  /* -- INITIALIZE INSTANCE -- */
  /* ------------------------- */

  status =
  om$send( msg = message VRGeneric.VRSetInstance
                            (&retmsg, (struct VRGenInfo *) asso_lis->as_attr),
      targetid = my_id);
  as$status(action = RET_STATUS);

  /* ------------------------ */
  /* -- INSERT CC IN GRAPH -- */
  /* ------------------------ */

  /*" %d Templates given\n", asso_lis->num_parents */

  if (asso_lis->num_parents)
  {
    status =
    om$send( msg = message NDnode.NDconnect (asso_lis->num_parents,
                                   asso_lis->parents, NULL_GRID,ConnectType),
        targetid = my_id);
    as$status(action = RET_STATUS);
  }

  /* --------------------*/
  /* -- BUILD GRAPHICS --*/
  /* --------------------*/

  /* Graphic temporarely given in the parents' list */

  /*| Construct graphics*/

  status =
  om$send( msg = message ACncpx.ACconstruct_feet
                         (&retmsg, 0, 0, NULL, md_env, &FeetCount, FeetList),
      targetid = my_id );
  as$status ( action = RET_STATUS );

  /* Below lines added by Anand for TR 6375 */

#if defined(vdsDEBUG) // || defined(DBG_PROD_NAME)
  status = om$send( msg = message GRvg.GRgetsymb (&retmsg, &symb),
		    targetid = my_id );

  __DBGpr_int("comp's preset colr",symb.display_attr.color);
  __DBGpr_int("NDplace go_cnst_lis color",
		     ((struct GRvg_construct *) go_cnst_lis)->display->color);
  __DBGpr_int("comp's preset wght",symb.display_attr.weight);
  __DBGpr_int("NDplace go_cnst_lis weight",
		     ((struct GRvg_construct *) go_cnst_lis)->display->weight);
  __DBGpr_int("comp's preset level",symb.level);
  __DBGpr_int("NDplace go_cnst_lis level",
		     ((struct GRvg_construct *) go_cnst_lis)->level);
#endif

  symb.display_attr = *(((struct GRvg_construct *) go_cnst_lis)->display);
  symb.level        =  (((struct GRvg_construct *) go_cnst_lis)->level);

  for( i=0 ; i<FeetCount ; i++ )
  {
      __DBGpr_obj("Setting symbology on foot",FeetList[i]);
      status = om$send(msg = message GRvg.GRputsymb(&retmsg,&symb),
		       targetid = FeetList[i].objid,
		       targetos = FeetList[i].osnum );
      as$status();
  }
  /* Above lines added by Anand for TR 6375 */

  status =
  om$send( msg = message ACncpx.ACchange_feet(FeetCount, FeetList, md_env ),
      targetid = my_id );
  as$status ( action = RET_STATUS );

  /* -- set symbology -- */

/* tr5959 pload cleanup-ACchange_feet has this functionality */

/* Yes, it does. However, since the below code was/is located AFTER calling
 * ACchange_feet, we should have put more thought before commenting it out.
 * TR 6375 caused us to revisit this code - Anand. */

#if 0
  if ( !(me->Status & VR_ERROR) )
  {
    symb.display_attr = *(((struct GRvg_construct *) go_cnst_lis)->display);
    symb.level        =  (((struct GRvg_construct *) go_cnst_lis)->level);

    /* yzhu attr.symb or user defined file for symbology driven */
    collId.objid = NULL_OBJID ;
    hdr.objid = my_id;
    hdr.osnum = OM_Gw_current_OS;

    status =
    VDgetVdCollId( &retmsg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
    if( (status&retmsg&1) ) {
       status = VDsetAttDrSymb(&retmsg, hdr, md_env, output );
       if( !(status&retmsg&1) ) {
              status =
    	      om$send(msg = message GRvg.GRputsymb(&retmsg,&symb),
       				targetid = my_id);
       }
       VD_drwFreeOutputData( &output ) ;
    }
    else {
    /* Added this method for CR: 179700254 */
    status = om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
                                        &retmsg,
                                        "routeattr.symb",
                                        md_env,
                                        &symb),
                   targetid = my_id );
    /* as$status(); Do not check return status */
    /*     do not check anything .............. HV, 3/4/97
    if ( retmsg == 0 ){                          */

	status =
    	om$send(msg = message GRvg.GRputsymb(&retmsg,&symb),
       		targetid = my_id);
    	as$status();
/*    do not check anything .............. HV, 3/4/97
    }
*/
    }
  }
#endif

  End
  return ( OM_S_SUCCESS );
}/* end NDplace */

/**************************************************************************/

method VRSetInstance  (IGRlong      *msg;
                struct VRGenInfo    *Instance)

{
  IGRint     status;
  IGRlong    retmsg;

  SetProc( VRGeneric_VRSetInstance ); Begin
  *msg = MSSUCC;

  me->Status = Instance->nStatus;

  if (Instance->szAABBCC[0] != '\0' &&
      (strcmp(Instance->szAABBCC,me->szAABBCC)) )
  {
    if (me->Status & VR_BUILT_IN)
    {
      /*| BUILT_IN comp becomes MANUAL */
      me->Status = 0;

    }/* end built in component replace */
    else
    if (me->Status & VR_SYSTEM)
    {
      /*| Set status to VR_FORCED */
      status =
      om$send ( msg = message VRGeneric.VRSetStatus 
                                (&retmsg, (IGRshort)(VR_FORCED),
                                          (IGRshort)(VR_FORCED)),
           targetid = my_id );
      as$status ();
    }/* end system component replace */
  }

  /*K Since the szAABBCC field has been increased to 13 characters
      but the instance field is still 7 characters :
      we must prevent any memory violation */
  {
    IGRchar  cTmp;

    cTmp = Instance->szAABBCC[6];
    /*C set end of string at the 7th character */
    Instance->szAABBCC[6] = '\0';
    strcpy ( me->szAABBCC,Instance->szAABBCC );
    /*C restore the 7th character */
    Instance->szAABBCC[6] = cTmp;
  }

  me->nOption    = Instance->nOption;
  me->xform_chan = Instance->cRep;
  me->nNbTopo    = Instance->nNbTopo;
  me->nJustif    = Instance->nJustif;
  me->cNoMtoFlg  = Instance->cNoMtoFlg;
  
  strcpy (me->szNumber, Instance->szNumber);
  strcpy (me->szNotes,  Instance->szNotes);

  status =
  om$send (msg = message VRGeneric.VRNotifyCorrections ( msg, 0 ),
      targetid = my_id );

  End
  return ( OM_S_SUCCESS );
}/* end VRSetInstance */

/**************************************************************************/

method  VREvaluate (  IGRlong      *msg;
               struct VRGenInfo    *Instance;
               struct GRid         *SysParamId;
               struct GRid         *UserParamId;
               struct GRid         *MissParamId;
                      IGRint       *NumMaxTopo;
                      IGRint       *TopoType;
                      IGRint       *NbMissing;
                      IGRchar    ***MissingNames;
               struct ret_struct  **MissingStr;
               struct GRid         *Graphics;
               struct GRmd_env     *md_env )
{

  IGRchar      AcRep;
  IGRlong      retmsg;
  IGRint       status;
  IGRchar      szMacroName[80];
  IGRint       NbCpts;
  IGRshort     nMacroType;

  struct GRid  ParamIds[2], GraphicId;
  SetProc( VRGeneric_VREvaluate ); Begin
  *msg = MSSUCC;

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE\n");
#endif

  GraphicId.osnum = OM_Gw_current_OS;
  GraphicId.objid = NULL_OBJID;

  /* -------------------------- */
  /* -- INITIALIZE INSTANCE -- */
  /* ------------------------- */

  /* -- set aabbcc code -- */

  me->szAABBCC[0] = '\0';

  /* -- Set number of connect points to minimum -- */

  me->nNbCpts = 0;
  status =
  om$send( msg = message VRGeneric.VRSetInstance  (&retmsg, Instance),
      targetid = my_id);
  as$status(action = RET_STATUS);

  /* -- Test whether I already have topology -- */

  /*| Evaluation without topology */
  status =
  om$send( msg = message VRGeneric.VRSetStatus
                                     (&retmsg, VR_EVALUATE, VR_EVALUATE ),
      targetid = my_id);
  as$status(action = RET_STATUS);

  /* -- attach myself to my definition -- */

  status =
  om$send( msg = message VRGeneric.VRGetDefName (&retmsg,szMacroName),
      targetid = my_id );
  as$status(action = GOTO_VALUE, value = EVAL_ERROR );

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to ACattach\n");
#endif

  status =
  om$send(msg = message ACcpx.ACattach ((IGRint *)&retmsg,szMacroName),
     targetid = my_id );
  as$status(action = GOTO_VALUE, value = EVAL_ERROR );

  /* ------------------------------------ */
  /* -- Connect Parameters Collections -- */
  /* ------------------------------------ */

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to VRChgParams\n");
#endif

  status =
  om$send( msg = message VRGeneric.VRChgParams
                           (&retmsg, SysParamId, UserParamId, MissParamId),
      targetid = my_id);
  as$status(action = GOTO_VALUE, value = EVAL_ERROR );

  /*" I have %d attributes collections\n", me->nNbAttr */

  /* ------------------------------- */
  /* -- Get component's DBParams -- */
  /* ------------------------------- */

  ParamIds[0].objid = my_id; ParamIds[0].osnum = OM_Gw_current_OS;

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to VRGetMacro\n");
#endif

  status = 
  om$send ( msg = message VRGeneric.VRGetMacro
                                ( msg, szMacroName, &AcRep, &nMacroType,
                                  &ParamIds[1], NbMissing, MissingNames,
                                  MissingStr, md_env ),
       targetid = my_id);
  if ( !(status & OM_S_SUCCESS) ) goto EVAL_ERROR;

  if(  *msg == VR_MISSING_IN_SEARCH && ParamIds[1].objid != NULL_OBJID )
  {
    struct  GRid  CompId;

#ifdef MY_DEBUG
    printf ("GENERIC EVALUATE from VRGetMacro %d %d\n",AcRep, nMacroType);
    printf ("GENERIC EVALUATE to VRMissingPbId\n");
#endif

    /*| ---- We have missing in user ---- */
    CompId.objid = my_id;
    CompId.osnum = md_env->md_id.osnum;
    status = 
    VRMissingPbId (&retmsg, &CompId, &ParamIds[1], Graphics, md_env );
    End
    return status;
  }

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to VRnum_cpts\n");
#endif

  status =
  VRnum_cpts(szMacroName, &NbCpts);

  if ( !(status & OM_S_SUCCESS) )
  {
    printf(" -----> Macro : %s not found\n", szMacroName);
    goto EVAL_ERROR;
  }

  me->nNbCpts = (IGRshort) NbCpts;

  if ( NumMaxTopo )
  {
    /*" Return %d max topo\n",NbCpts*/
    *NumMaxTopo = NbCpts;
  }

  if (*NbMissing) 
  {
    /*| There are missing parameters. Cannot go further */
    *msg = MSFAIL;
    End
    return OM_S_SUCCESS;
  }

  /* --------------------------------------------- */
  /* -- Place graphics for topologic evaluation -- */
  /* --------------------------------------------- */

  /* -- Select macro class based on component type -- */

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE construct ACheader\n");
#endif

  status =
  om$construct (classid = OPP_ACheader_class_id,
                p_objid = &GraphicId.objid, 
                osnum   = GraphicId.osnum );
  as$status ( action = RET_STATUS );

  /*" Graphic created : <%d,%d>\n", GraphicId.objid, GraphicId.osnum */
  /*| place the header out of the rtree */

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to ACmplace rep = %d\n",AcRep);
  printf ("GENERIC EVALUATE to ACmplace %s\n",szMacroName);
#endif

  status =
  om$send ( msg = message ACncpx.ACmplace
                          ((IGRint *)&retmsg, AChdr_noprotect|AChdr_nodisplay,
                           AcRep, szMacroName,
                           (ParamIds[1].objid == NULL_OBJID) ? 1 : 2,
                           ParamIds, md_env  ),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum);
  as$status ( action = GOTO_VALUE, value = EVAL_ERROR );

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to NDmove_to_root\n");
#endif

  /* -- Move header to Root header -- */
  status=
  om$send ( msg = message NDnode.NDmove_to_root
                                  (&retmsg,&GraphicId,md_env),
       targetid = GraphicId.objid,
       targetos = GraphicId.osnum);
  as$status ( action = GOTO_VALUE, value = EVAL_ERROR );

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to ACchange_feet\n");
#endif

  /* -- Set my graphics foot -- */
  status =
  om$send( msg = message ACncpx.ACchange_feet ( 1, &GraphicId, md_env ),
      targetid = my_id ) ;
  as$status ();

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE to reset\n");
#endif

  /* -- Reset Evaluate status -- */
  status =
  om$send( msg = message VRGeneric.VRSetStatus
                                    (&retmsg, VR_EVALUATE, !VR_EVALUATE ),
      targetid = my_id);
  as$status(action = RET_STATUS);

End
return OM_S_SUCCESS;

EVAL_ERROR:

#ifdef MY_DEBUG
  printf ("GENERIC EVALUATE error id = %d\n",GraphicId.objid);
#endif

  /*| ERROR -> Evaluate not performed */

  if ( GraphicId.objid != NULL_OBJID )
  {
    /* Delete graphics */
    status =
    om$send ( msg = message NDnode.NDdelete ( md_env ),
         targetid = GraphicId.objid,
         targetos = GraphicId.osnum);
  }

  om$send( msg = message VRGeneric.VRSetStatus
                                     (&retmsg, VR_EVALUATE, !VR_EVALUATE ),
      targetid = my_id);
  End
  return OM_E_ABORT;

}/* end VREvaluate */

end implementation VRGeneric;

/* $Id: VRGenVdsOver.I,v 1.5 2001/03/20 19:53:29 anand Exp $  */

/****************************************************************************
 * I/ROUTE
 *
 * File:  vrgeneric/VRGenVdsOver.I
 *
 * Description:
 *
 *  This file contains route definitions for the methods (override)
 *  defined at VDSroot class.
 *
 * Revision History:
 *  $Log: VRGenVdsOver.I,v $
 *  Revision 1.5  2001/03/20 19:53:29  anand
 *  vd$modUsrAttributes - final update (TR 4899)
 *
 *  Revision 1.4  2001/03/20 19:07:09  ad
 *  Initial update for mod User attributes
 *
 *  Revision 1.3  2001/02/20 01:14:09  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/12 20:44:18  anand
 *  SP merge
 *
# Revision 1.1  2000/05/23  23:17:46  pinnacle
# Created: route/vrgeneric/VRGenVdsOver.I by lawaddel for Service Pack
#
# Revision 1.2  1998/05/22  19:14:42  pinnacle
# TR179801102
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/01/05  00:07:12  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by impd for route
#
# Revision 1.2  1997/12/30  15:41:30  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/04  21:21:38  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.14  1996/06/10  20:52:28  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by yzhu for route240
#
# Revision 1.13  1996/05/23  15:52:28  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by ashankar for route240
#
# Revision 1.10  1996/05/13  15:02:04  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by ashankar for route240
#
# Revision 1.9  1996/04/09  23:43:56  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by ashankar for route240
#
# Revision 1.8  1996/04/04  17:12:30  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by hverstee for route240
#
# Revision 1.7  1996/04/02  21:43:32  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by ashankar for route240
#
# Revision 1.6  1996/03/30  16:48:56  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by azuurhou for route240
#
# Revision 1.5  1996/03/17  18:53:44  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by azuurhou for route240
#
# Revision 1.4  1996/01/17  00:01:46  pinnacle
# Replaced: vrgeneric/VRGenVdsOver.I for:  by r240_int for route240
#
 *
 * History:
 *  MM/DD/YY  AUTHOR DESCRIPTION
 *  08/10/94  Manyam Creation and definition for the 
 *                   method   "VRmodUsrAttributes()"
 *  08/11/94  Manyam Defined the method "VDSmodUsrAttributes"
 *  06/06/95  Manyam Defined VDgetParameters
 *  01/16/96  tlb    Add protoypes
 *  03/17/96  adz    VDgetParameters need to check Id's
 *  03/28/96  adz    MissId was UsrId (Invalid).
 *  12/xx/97  kdd    VDGetParamsId 
 *  05/22/98  ah     TR179801102 VDgetParameters causing core dumps
 *  03/20/01  Ad &   JTS TR 4899 - default module env is set to NULL in
 *  	      Anand  vd$modUsrAttributes calls. Ensure a module env is defined
 *  		     in VDSmodUsrAttributes.
 ****************************************************************************/

class implementation VRGeneric;

#include  <string.h>
#include  "exdef.h"
#include  "exmacros.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "ACattrib.h"
#include  "nddef.h"
#include  "ndmacros.h"
#include  "vrdbgmacros.h"
#include  "vdparmacros.h"
#include  "VDmem.h"
#include  "VRchgattrdef.h"
#include  "VRutildef.h"
#include  "VRutilmacros.h"
#include  "vdparmacros.h"
#include  "vrtools_pto.h"
#include  "vdprocinfo.h"

/*
#define MY_DEBUG
*/

from  ACrg_collect  import  AClist_attribute;
from  ACmacro_defn  import  ACgive_feet_desc;

extern GRclassid OPP_ACpretend_class_id;
/*+mo
  Overridden Message
  VDSmodUsrAttributes from VDSroot

  Abstract
  Motivation : Each I/ROUTE entity has three diff collections
  as  it's parents. System collection, User collection and Missing 
  collection. This design is different from other I/VDS products. 
  The method has been overriden to suit this design and serve the 
  functionality.
  
        Adds user attributes to the object, modifies user or missing 
  attributes of the object, and deletes user attributes from the 
  object according to the following logic :
               If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
               otherwise, 
                   If the attribute exists, it is modified to reflect
                   the new type and value.
                   If the attribute does not exist, it is created with the
                   new type and value.

  Arguments
        OUT     IGRlong           *msg    Completion code.
        IN      IGRint            NbAttr  Number of user attributes 
                                                to be modified
        IN      struct ACrg_coll  *pAttributes  List of attributes 
        IN      struct GRmd_env   *pMdEnv  Module environment of object

  Notes/Remarks
        - Return MSFAIL in *msg, only if some error is encountered.
          Otherwise return MSSUCC.
        - NbAttr is the number of user attributes to be modified for the object.
        - the type of an attribute can have the following values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE
              AC_ATTRIB_TYPE_NOT_DEF

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available 
        OM_W_ABORT      : if some other error
  OM_E_INVARG  : invalid arguments
-mo*/

method  VDSmodUsrAttributes (IGRlong    *msg;
                             IGRint      NbAttr;
                      struct ACrg_coll  *pAttributes;
                      struct GRmd_env   *pMdEnv  )
{
  IGRint       status = OM_S_SUCCESS, i, NbCor;
  IGRint       AttrType, Index, Operation, cn_type;
  IGRlong      retmsg;
  IGRchar      c100Msg[100];
  IGRboolean   bUserModified = FALSE;
  IGRint       NbChildren;

  struct GRid     MyId, CollId[3], NewUserCollId;
  struct GRid    *pChildren;
  struct GRid     FeetId, CorId;
  struct GRmd_env myEnv;

  SetProc( VRGeneric_VDSmodUsrAttributes ); Begin
  /*A initialization  */
  *msg       = MSSUCC;
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  /*A validate the arguments  */
  if ( NbAttr <= 0 || !pAttributes )
  {
    End
    return   OM_E_INVARG;
  }

  /* Below lines added by Ad and Anand for TR 4899 */
  if ( !pMdEnv )
  {
    /*
     * add local matrix
     */
        gr$get_module_env(buffer = &myEnv);

        myEnv.md_id.osnum = OM_Gw_current_OS;
        ex$get_modid(mod_osnum =  myEnv.md_id.osnum,
                     mod_id    = &myEnv.md_id.objid );
        pMdEnv = &myEnv;
  }
  /* Above lines added by Ad and Anand for TR 4899 */

  /*A get my collection parents  */
  status = 
  om$send ( msg = message VRGeneric.VRGetParams
                                (&retmsg, &CollId[0], &CollId[1], &CollId[2] ),
       targetid = MyId.objid,
       targetos = MyId.osnum );
  as$status( action = RET_STATUS );

  NewUserCollId.objid = NULL_OBJID;
  NewUserCollId.osnum = CollId[1].osnum;

  NbChildren = 0;

  if ( CollId[1].objid != NULL_OBJID )
  {
    NbChildren = 0;
    /*A get number of children  */
    status =
    om$send( msg = message NDnode.NDget_objects
                             (ND_CHILDREN | ND_IN_BUF, NULL, 0, &pChildren, 
                                  0, OM_K_MAXINT, &NbChildren ),
        targetid = CollId[1].objid,
        targetos = CollId[1].osnum );
    as$status( action = RET_STATUS );
  }

  /*A copy only if the collection has more than one child */
  if ( NbChildren > 1 )
  {
    status =
    VR$ModifyCollection (  p_msg      = &retmsg,
                         Operation    = VR_MERGE_COLL,
                 p_InputCollectionId  = &CollId[1],
                p_OutputCollectionId  = &NewUserCollId );
    as$status( action = RET_STATUS );
  }
  else
    NewUserCollId = CollId[1];
    
  /*A process each of the attribute so as to modify 
  the existing one or add it as a new attribute    */
  
  for ( i=0; i<NbAttr; i++ )
  {
    /*A get the attribute's status or type  */
    status =
    VRGetParameterType( &retmsg, &MyId, pAttributes[i].name,
                                           &AttrType, pMdEnv );

    /*A continue the process for rest of the attributes
    even if an error occurs        */
    if( !(retmsg & MSSUCC) || !(status & OM_S_SUCCESS) ) 
    {
      sprintf ( c100Msg, "Can not process the attribute : %s", 
                                          pAttributes[i].name );
      UI_status( c100Msg);
      *msg = MSFAIL;
      continue;
    }
    
    /*A process the attribute  */
    switch( AttrType )
    {
      case VR_DB_ATTR:
      sprintf( c100Msg, " Cannot modify Static attribute : %s",
                                                pAttributes[i].name );
      Index = -1;
      break;
      
      case VR_SYSTEM_ATTR:
      sprintf( c100Msg, " Cannot modify System attribute : %s",
                                                pAttributes[i].name );  
      Index = -1;
      break;  

      case VR_USER_ATTR:
      sprintf( c100Msg, " Modifying the User attribute : %s",
                                                pAttributes[i].name );  
      Index = 1;
      bUserModified = TRUE;
      break;  

      case VR_MISSING_ATTR:
      sprintf( c100Msg, "Cannot modify Missing attributes : %s",
                                                pAttributes[i].name );  
      Index = -1;
      break;  

      case VR_ATTRIBUTE_NE:
      sprintf( c100Msg, " Adding the attribute : %s to User collection",
                                                pAttributes[i].name );  
      Index = 1;
      bUserModified = TRUE;
      break;  

      default:
      sprintf( c100Msg, "Invalid attribute type" );
      Index = -1;      
      break;
      
    }/*end switch  */

    /*A display appropriate message  */  
    UI_status( c100Msg );

    /*A modify or add or delete the attribute  */
    if ( Index != -1 )
    {
      if ( pAttributes[i].desc.type == VD_ATTRIB_DELETE &&
                           AttrType == VR_USER_ATTR )
          Operation = VR_SUBSTR_COLL;
      else
      if ( AttrType == VR_ATTRIBUTE_NE )
          Operation = VR_UNION_COLL;
      else
          Operation = VR_UPDATE_COLL;

      status = 
      VR$ModifyCollection ( p_msg  = &retmsg,
                     Operation     = Operation,
            p_ParamsListToModify   = &pAttributes[i],
                 NbParamsToModify  = 1,
             p_OutputCollectionId  = &NewUserCollId );
      as$status();
    } else 
      *msg = MSFAIL;/* set to indicate that process is not
                       successful on all of the attributes*/

  } /*end processing for attrbutes  */


  if ( !bUserModified )
  {
    End
    return OM_S_SUCCESS;
  }

  /*A this is required so as to avoid unnecessary 
      disconnection and connection      */

  if( NewUserCollId.objid == CollId[1].objid &&
      NewUserCollId.osnum == CollId[1].osnum )      goto compute;

  /*A detach the previous collections and attach the new ones  */

  status = 
  om$send ( msg = message VRGeneric.VRChgParams
                               (&retmsg, &CollId[0], &NewUserCollId, NULL ),
       targetid = MyId.objid,
       targetos = MyId.osnum );
  as$status( action = RET_STATUS );
  
  /*A do i need to send recompute or the collections themselves 
      take care about that : i need to confirm about this    */
  
  /*A The best way is to leave the option to the caller
      itself whether to recompute or not. This would be better if he is
      going to change lot of components at once. So that he can execute
      in batch mode  : Manyam : 10 August 1994      */

compute:

/***  Present Implementation is go for complete recompute. In case a partial
 ***  recompute is needed go for the following code.
 ***

           struct GRid MacroId, *FeetId;
           IGRint i, j, NbFeet, retcode, cn_type;
           IGRuint count;
           IGRboolean to_compute;
           struct myfeet *FeetList;
           OM_S_OBJECT_LINKAGE *child;

           FeetId = NULL;
           child  = NULL;

           status = om$send( msg = message ACcpx.find_macro ( &MacroId ),
                           targetid = MyId.objid,
                           targetos = MyId.osnum );
           as$status(action = RET_STATUS);

           status = om$send( msg = message ACcpx_defn.ACgive_feet_desc
                                   ( &NbFeet, ( struct myfeet **)&FeetList),
                                   targetid = MacroId.objid,
                                   targetos = MacroId.osnum );
           as$status(action = RET_STATUS);

           FeetId = _MALLOC (NbFeet, struct GRid);

           for( i=0; i<NbFeet; i++ )
           {
                   FeetId[i].objid = NULL_OBJID;
                   status = om$send( msg = message NDmacro.ACreturn_foot
                                   ( &retmsg,FeetList[i].name, &FeetId[i],
                                           &pMdEnv->md_env.matrix_type,
                                      (IGRdouble *)pMdEnv->md_env.matrix ),
                                   targetid = MyId.objid,
                                   targetos = MyId.osnum );
                   as$status(action = RET_STATUS);

                   if( !strcmp( FeetList[i].name, "user" ) )
                   {
                           status =
                                VR$ModifyCollection ( p_msg     = &retmsg,
                                   Operation               = VR_MERGE_COLL,
                                   p_InputCollectionId     = &NewUserCollId,
                                   p_OutputCollectionId    = &FeetId[i] );
                           as$status();
                   }
           }


           status = om$get_channel_count( objid = MyId.objid,
                                           osnum = MyId.osnum,
                                           p_chanselect = &ND_children,
                                           count = &count );
           as$status( action = RET_STATUS );

           if( count > 0 )
           {
                   child = _MALLOC (count, OM_S_OBJECT_LINKAGE);
                   if(!child)
                   {
                     End
                     return OM_E_NODYNMEM;
                   }

                   status = om$get_channel_objects( objid = MyId.objid,
                                                   osnum = MyId.osnum,
                                                   p_chanselect = &ND_children,
                                                   list = child,
                                                   size = count,
                                                   count = &count );
           }

           for ( i=0; i<count; i++ )
           {
                   to_compute=TRUE;
                   for ( j=0; j<NbFeet; j++ )
                   {
                           if( child[i].S_objid == FeetId[j].objid &&
                                   child[i].osnum == FeetId[j].osnum )
                           {
                                   to_compute=FALSE;
                                   break;
                           }
                   }

                   if( to_compute )
                   {
                           cn_type = ND_COMP;
                           nd$wait_batch(  type       = GR_GEOM_POSTED,
                                           l_object   = &child[i],
                                           nb_obj     = 1 );
                           nd$exec_batch();

                   }
           }

           _FREE ( child);
           _FREE ( FeetId );

  END FUTURE ENHANCEMENT                                          ***/

  status =
  om$send( msg = message NDmacro.ACreturn_foot
                               ( &retmsg,"user", &FeetId,
                                 &pMdEnv->md_env.matrix_type,
                                 (IGRdouble *)pMdEnv->md_env.matrix ),
      targetid = MyId.objid,
      targetos = MyId.osnum );
  as$status(action = RET_STATUS);

  if( FeetId.objid != NULL_OBJID )
  {
     status =
     VR$ModifyCollection ( p_msg     = &retmsg,
             Operation               = VR_MERGE_COLL,
             p_InputCollectionId     = &NewUserCollId,
             p_OutputCollectionId    = &FeetId );
     as$status();

     status =
    om$send ( msg = message VRGeneric.VRGetCorrections
                                       (&retmsg, 1, &CorId, &NbCor ),
         targetid = MyId.objid,
         targetos = MyId.osnum );

    cn_type = ND_COMP;
    if( CorId.objid != NULL_OBJID )
    {
       nd$wait_batch ( type = GR_GEOM_POSTED,
        l_object = &CorId,
        nb_obj = 1 );
    }
  }

  nd$wait_batch(  type       = GR_GEOM_POSTED,
                  l_object   = &MyId,
                  nb_obj     = 1 );
  nd$exec_batch();

  End
  return   OM_S_SUCCESS;
}/*end VDSmodUsrAttributes  */


/*+mo
  Overridden Message
  VDSgetUsrAttributes from VDSroot

  Abstract
  Motivation : Each I/ROUTE entity has three diff collections
  as  it's parents. System collection, User collection and Missing 
  collection. This design is differant from other I/VDS suit of 
  products. The method has been overriden to suit this design
  and serve the functionality.

  This method can be used either to get the number of user 
  attributes or the list of user attributes or both for a given 
  I/ROUTE object. Pass NULL as an argument if output is not required.

  Arguments
        OUT     IGRlong           *msg    Completion code.
        OUT     IGRint            *pNbAttrs  Number of user attributes or 
            NULL
        OUT     struct ACrg_coll  **pAttr  List of attributes or NULL
        IN      struct GRmd_env   *pMdEnv  Module environment of object

  Notes/Remarks
        - Return MSFAIL in *msg, only if some error is encountered.  Even if
          object has no user attributes, *msg should be MSSUCC.
        - pNbAttrs is number of user attributes for the object : 0 or more.
        - Memory should be allocated for the list of ACrg_coll structures to 
          return the attributes, in the method implementation.

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available 
        OM_W_ABORT      : if some other error
  OM_E_INVARG  : invalid arguments

-mo*/

method  VDSgetUsrAttributes( IGRlong    *msg ;
                             IGRint     *pNbAttrs;
                      struct ACrg_coll **pAttr;
                      struct GRmd_env   *pMdEnv )
{
  IGRint      status=OM_S_SUCCESS;
  IGRint      NbAttr=0;
  IGRlong     retmsg;

  struct  GRid        UsrCollId;
  struct  ACrg_coll  *pList=NULL;

  SetProc( VRGeneric_VDSgetUsrAttributes ); Begin
  /*A initialization  */
  *msg = MSSUCC;

  /*A validate the arguments  */
  if( !pNbAttrs || !pAttr )
  {
    End
    return   OM_E_INVARG;
  }

  /*A get my user collection object id  */
  status = 
  om$send ( msg = message VRGeneric.VRGetParams
                                      (&retmsg, NULL, &UsrCollId, NULL ),
       targetid = my_id );

  if ( retmsg != MSSUCC )
  {
    End
    return  OM_W_ABORT;
  }

  /*A get the number of attributes in user collection  */
  status = 
  om$send( msg = message ACrg_collect.AClist_attribute
                                 (&retmsg, 0, pList, &NbAttr ),
      targetid = UsrCollId.objid,
      targetos = UsrCollId.osnum );
  as$status( action = RET_STATUS );

  if ( pNbAttrs )  *pNbAttrs = NbAttr;
  if ( !pAttr || !NbAttr  )  
  {
    End
    return  OM_S_SUCCESS;
  }

  /*C Allocate the memory for the collection array */
  *pAttr = NULL;
  *pAttr = _MALLOC (NbAttr, struct ACrg_coll);

  if ( !*pAttr ) 
    {  *msg = MSFAIL;
       End
       return  OM_E_NODYNMEM;
    }

  /* -- Get all attributes from the collection -- */
  status = 
  om$send( msg = message ACrg_collect.AClist_attribute
                                      (&retmsg, NbAttr, *pAttr, &NbAttr ),
      targetid = UsrCollId.objid,
      targetos = UsrCollId.osnum );
  as$status( action = RET_STATUS );

  End
  return  OM_S_SUCCESS;  
}/*end VDSgetUsrAttributes  */



/*+mo
  Overridden Message
  VDSgetCompDesc from VDSroot

  Abstract
  Motivation : Each I/ROUTE entity has a database collection that is 
  known only to each object. The invention of ths message was after 
  VRGetCompDesc in Route. So this is implemented only in I/ROUTE.

  Arguments
  OUT     IGRlong           *msg          Completion code.
  IN/OUT  struct ACrg_coll  *Param        Pointer to parameter structure.
  IN      struct GRmd_env   *pMdEnv       Module environment of object
-mo*/

method VDSgetCompDesc ( IGRlong      *msg;
                 struct ACrg_coll    *Param;
                 struct GRmd_env     *pMdEnv )
{
  IGRint    status;

  SetProc( VRGeneric_VDSgetCompDesc ); Begin
  status =
  om$send (msg = message VRGeneric.VRGetCompDesc (msg, Param, pMdEnv ),
      senderid = NULL_OBJID,
      targetid = my_id );

  End
  return status;

} /* End VDSgetCompDesc */

/*+mo
  Overridden Message
  VDGetModel from VDSroot

  Abstract
  Motivation : Each I/ROUTE entity has a parameter box ( ModelId)that is 
  known only to each object. The invention of ths message was after 
  VRGetModel in Route. So this is implemented only in I/ROUTE.

  Arguments
  OUT     IGRlong           *msg          Completion code.
  OUT    struct GRid       *ModelId   Pointer to parameter structure.
  IN      struct GRmd_env   *pMdEnv       Module environment of object
-mo*/

method VDGetModel (IGRlong  *msg;
            struct GRid     *ModelId;
            struct GRmd_env *pMdEnv )
{
  IGRint    status;

  SetProc( VRGeneric_VDGetModel ); Begin
  status =
  om$send ( msg = message VRGeneric.VRGetModel (msg, ModelId, pMdEnv ),
       senderid = NULL_OBJID,
       targetid = my_id );

  End
  return status;

} /* End VDGetModel */



/*+mo
  Overridden Message
  VDgetParameters from VDSroot

  Abstract
        Returns the list of all parameters for the object.

  Arguments
        IGRlong           *msg      O      Completion code.
        IGRint            *nbParams O      Number of parameters
        struct ACrg_coll  **parList O      List of parameters
        struct GRmd_env   *md_env   I      Module environment of object

  Notes/Remarks
        - nbParams is the total number of parameters for the object : 0 or more.
        - Memory will be allocated for the list of ACrg_coll structures 
          in the method implementation.  Needs to be freed by the caller.
  - IMPORTANT NOTE : the names of the parameters must be the complete
          --------------
    names (for eg : stat_attr:macro_name, or attributes:op_pres )

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available
        OM_W_ABORT      : if some other error
-mo*/

method VDgetParameters(        IGRlong                 *msg;
                               IGRint                  *nbParams;
                               struct ACrg_coll        **parList;
                               struct GRmd_env         *md_env )
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       NbInt;
  IGRint       NbBuff;
  IGRint       NbOut;
  IGRint       NbTot;
  IGRint       i, j, k, Index;

  struct ACrg_coll   *tmpList;
  struct ACrg_coll   *CollBuf;
  struct GRid         CollId[4];
  struct GRid         MyId;

  /*A validate the arguments  */
  SetProc( VRgeneric_VDgetParameters ); Begin

  if ( !msg || !md_env )
  {
     End
     return  OM_E_INVARG;
  }

  /*A initialization  */
  *msg       = MSSUCC;
  *nbParams  = 0;
  *parList   = NULL;
  tmpList    = NULL ;
  CollBuf    = NULL;

  NbInt    = 0 ;
  NbTot    = 0 ;
  NbBuff   = 0 ;

  CollId[0].objid = NULL_OBJID ;
  CollId[1].objid = NULL_OBJID ;
  CollId[2].objid = NULL_OBJID ;
  CollId[3].objid = NULL_OBJID ;

  /*A get the Model Id  */
  /* -------------------------------------------------------------
   * TR179801102 This generates an error message if the spec is not
   * found, probably should fail silently or put them message in the status bar
   * Look in VRinfo.I
   */
  status = 
  om$send(msg = message VRGeneric.VRGetModel( &retmsg, &CollId[3], md_env ),
     targetid = my_id );

  /*A get the sys, usr, missing collection Ids  */
  status = 
  om$send ( msg = message VRGeneric.VRGetParams
                              ( &retmsg, &CollId[0], &CollId[1], &CollId[2] ),
       targetid = my_id );

  for (i=0; i<4; i++)
  {
    NbOut = 0;

    /* ---------------------------------------------------------------
     * TR179801102 CollId[0] should be CollId[i]
     */
    if ( CollId[i].objid != NULL_OBJID )
    {
      status = 
      vd$get_parameters(  sts  = &retmsg,
                       object  = &CollId[i],
                       md_env  = md_env,
                        count  = &NbOut );
      if( !(status & retmsg & OM_S_SUCCESS )) NbOut = 0;
      if (NbBuff < NbOut) NbBuff = NbOut;
#ifdef MY_DEBUG
      printf ("Coll %d number %d\n",i,NbOut);
#endif
    }

    NbTot += NbOut;
  }

  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  /* -------------------------------------------------------
   * TR179801102 This core dumps when getting the values for
   * "flow_rate" and "equiv_dia"
   * Fixed in VRGenOver.I
   */
  status = VRGetInternalAttributes( MyId, &tmpList, &NbInt, md_env );
  if( !(status & OM_S_SUCCESS )){ NbInt = 0 ; }

  /*A set the nb of total parameters  */
  *nbParams = NbTot + NbInt;

  __DBGpr_int(" NbParams  ", *nbParams );

  if( ! *nbParams )
  {
    *msg  = MSSUCC ;
    status  = OM_S_SUCCESS ;
    goto wrapup ;
  }

  /*A allocate the memory  for collection  */
  /* -----------------------------------------------------
   * TR179801102 In the test case, none of the collectors are found
   * which means NbBuff is 0 which means allocating 0 bytes which is not good
   * Easiest fix is to just add 1 to the number allocated 
   */
  *parList = _MALLOC (*nbParams + 1, struct ACrg_coll);
  CollBuf  = _MALLOC (NbBuff + 1,    struct ACrg_coll);

  if ( !(*parList) || !(CollBuf))
  {
    status = OM_E_NODYNMEM;
    printf( "VDgetParameters:Could not allocate dynamic memory\n");
    goto wrapup;
  }

  Index=0;

  if( NbInt && tmpList )
  {
    for( i=0; i<NbInt; i++ )  (*parList)[i] = tmpList[i];
    Index += NbInt ;
  }

  for (i=0; i<4; i++)
  {
    NbOut = 0;
    /* ---------------------------------------------------------------
     * TR179801102 CollId[0] should be CollId[i]
     */
    if ( CollId[i].objid != NULL_OBJID )
    {
      status =
      vd$get_parameters(  sts  = &retmsg,
                       object  = &CollId[i],
                        plist  = CollBuf,
                         size  = NbBuff,
                       md_env  = md_env,
                        count  = &NbOut );
      if( !(status & retmsg & OM_S_SUCCESS )) NbOut = 0;
    }

    for (j=0; j<NbOut; j++)
    {
      for (k=0; k<Index; k++)
      {
        if (strcmp (CollBuf[j].name, (*parList)[k].name) == 0)
        {
#ifdef MY_DEBUG
          printf (" Bypass duplicate %s in %d\n",CollBuf[j].name,i);
#endif
          goto brk;
        }
      }

      (*parList)[Index] = CollBuf[j];

       Index++;

       brk:
       continue;
    }
  }

  *nbParams = Index;

  __DBGpr_int(" Index .. ", Index );

wrapup:

  _FREE( CollBuf );
  _FREE( tmpList );

  End
  return  status;
}

/*------------------------------------------------------------------------------
* 12-97 KDD . VDGetParamsId
* 
* Direct this method to VRGetParams.
------------------------------------------------------------------------------*/
method VDGetParamsId( IGRlong *msg;    struct GRid *SysParamId;
                                       struct GRid *UsrParamId;
                                       struct GRid *AddParamId )
{
  IGRlong		status;

  SetProc( VRGeneric_VDGetParamsId ); Begin
  status = om$send( msg      = message VRGeneric.VRGetParams
				( msg, SysParamId, UsrParamId, AddParamId), 
                    targetid = my_id);

End
return status; 
}


/*
  Public Message        VDprocAttr
        Get product information like, weight, center of gravity, mass and range
  Arguments
        OUT     long            *msg            Completion code.
        IN      struct GRmd_env *md_env.
        IN      int             flag            see vdprodinfo.h.
        OUT     VDprcAttr       *prcAttr.       see vdprodinfo.h

  Status/Return Code
        OM_S_SUCCESS    if success;

*/

method VDprocAttr (	IGRlong		*lMsg;
			struct GRmd_env	*MdEnv;
			IGRint		Flag;
			VDprcAttr	*prcAttr )
{
IGRint		status;

SetProc( VRGeneric_VDprocAttr ); Begin

status = om$send ( msg = message VDSroot.VDprocAttr (	lMsg,
							MdEnv,
							Flag,
							prcAttr ),
		mode		= OM_e_wrt_message,
		targetid	= my_id );

End
return status;

} /* end method VDprocAttr */

end implementation VRGeneric;


/* $Id: VCRvdsover.I,v 1.3 2001/02/20 01:11:19 build Exp $  */

/* I/CABLE
 *
 * File:   vcroot/VCRvdsover.I
 *
 * Description:
 *
 *   This file contains CABLE definitions for the methods (override)
 *   defined at VDSroot class.
 *
 * Revision History:
 *   $Log: VCRvdsover.I,v $
 *   Revision 1.3  2001/02/20 01:11:19  build
 *   Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *   Revision 1.2  2001/01/30 19:22:26  louis
 *   TR4342
 *
# Revision 1.2  2000/02/04  21:47:22  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/02/24  22:38:44  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by kddinov for route
#
# Revision 1.3  1998/02/24  22:38:08  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by kddinov for route
#
# Revision 1.2  1997/12/12  20:44:58  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by kddinov for route
#
# Revision 1.4  1997/07/22  14:32:24  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  21:57:56  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/19  15:53:30  pinnacle
# Replaced: vcroot/VCRvdsover.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:13:30  pinnacle
# Created: vcroot/VCRvdsover.I by hverstee for cabling
#
 *
 * History:
 *   MM/DD/YY   AUTHOR      DESCRIPTION
 *   06/27/96   HV          New
 *   02/04/00   law         CR179702191 additional attributes for formatted
 *                          text
 *   01/17/01	law	    TR4342-crashing on error component
 *************************************************************/

class implementation VCRoot;

#include <stdio.h>
#include  "vrdbgmacros.h"
#include  "vdparmacros.h"
#include  "VDmem.h"
#include  "vds.h"
#include  "VDmsg.h"
#include  "parametric.h"
#include  "v_pplslc.h"

#include  "VCproto.h"

from  ACdiowner     import  ACrem_attribute;

from  ACrg_collect  import  ACcreate;
from  ACrg_collect  import  ACset_list_attribute;
from  ACrg_collect  import  ACmod_list_attribute;
from  ACrg_collect  import  ACadd_list_attribute;
from  VRGeneric     import  ACgive_structure;

/*+mo
  Overridden Message
  VDSmodUsrAttributes from VDSroot

  Abstract
  Motivation : Each I/CABLE entity has two diff collections
  as  it's parents. System collection and User collection.
  This design is different from other I/VDS products. 
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
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nCchild;
  IGRshort    nPar;
  IGRshort    nPTYP;
  IGRint      i;
  IGRint      Index;
  IGRchar     c100Msg[100];
  IGRboolean  bUserModified;

  struct GRid     MyId;
  struct GRid     CollId;

  /*A initialization  */
  *msg = MSSUCC;
  bUserModified = FALSE;

  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  /*A validate the arguments  */
  if ( NbAttr <= 0 || !pAttributes || !pMdEnv )
    return   OM_E_INVARG;

  /*A get my collection parents  */
  status = 
  om$send ( msg = message VCRoot.VCGetUsrPar
                           (&retmsg, &CollId, &nCchild, &nPar, NULL),
       targetid = my_id);

  if (nCchild > 1)
  { /*  if user collection is shared split off it's own   */
    IGRchar           szPathName[10];

    struct ACrg_coll *Coll;

    VC_INITSTR (szPathName);

    Coll = _MALLOC (nPar, struct ACrg_coll);

    status =
    om$send ( msg = message VCRoot.VCGetUsrPar
                           (&retmsg, &CollId, &nCchild, &nPar, Coll),
         targetid = my_id);

    CollId.objid = NULL_OBJID;

    status =
    om$construct ( classid = OPP_ACrg_collect_class_id,
                   p_objid = &(CollId.objid),
                   osnum   = CollId.osnum,
                   msg     = message ACrg_collect.ACcreate
                                              (&retmsg,szPathName ) ) ;

    status =
    om$send( msg = message NDnode.NDchg_state
                           ((IGRchar)ND_DEL_NO_CH ,(IGRchar)~ND_DEL_NO_CH),
        targetid = CollId.objid,
        targetos = CollId.osnum ) ;
    as$status ();

    status =
    om$send( msg = message ACrg_collect.ACset_list_attribute
                                   (&retmsg, (IGRint) nPar, Coll),
        targetid = CollId.objid,
        targetos = CollId.osnum ) ;

    bUserModified = TRUE;
  }

  /*A process each of the attribute so as to modify 
  the existing one or add it as a new attribute    */
  
  for ( i=0; i<NbAttr; i++ )
  {
    nPTYP = VCDB_AttrNamToType (pAttributes[i].name);

    /*A process the attribute  */
    switch (nPTYP)
    {
      case VCPT_INTERNAL:
      sprintf( c100Msg, " Cannot modify Internal attribute : %s",
         pAttributes[i].name );
      Index = -1;
      break;
      
      case VCPT_SYSTEM:
      sprintf( c100Msg, " Cannot modify System attribute : %s",
         pAttributes[i].name );  
      Index = -1;
      break;  

      case VCPT_USER:
      sprintf( c100Msg, " Modifying the User attribute : %s",
         pAttributes[i].name );  
      Index = 1;
      break;  

      case VCPT_DB:
      sprintf( c100Msg, " Cannot modify DB attribute : %s",
         pAttributes[i].name );  
      Index = -1;
      break;  

      case VCPT_UNDEFINED:
      sprintf( c100Msg, " Adding attribute : %s to User collection",
         pAttributes[i].name );  
      Index = 1;
      break;  

      default:
      sprintf( c100Msg, "Invalid attribute type" );
      Index = -1;      
      break;
      
    }/*end switch  */

    /*A display appropriate message  */  
    UI_status( c100Msg );

    /*A modify or add or delete the attribute  */
    if ( Index == 1 )
    {
      if (pAttributes[i].desc.type == VD_ATTRIB_DELETE)
      {
        status =
        om$send (msg = message ACdiowner.ACrem_attribute
                                 (&retmsg, pAttributes[i].name ),
            targetid = CollId.objid,
            targetos = CollId.osnum ) ;
      }
      else
      {
        status =
        om$send (msg = message ACrg_collect.ACadd_list_attribute
                                 (&retmsg, 1, &pAttributes[i]),
            targetid = CollId.objid,
            targetos = CollId.osnum ) ;

        if (!retmsg)
        status =
        om$send (msg = message ACrg_collect.ACmod_list_attribute
                                 (&retmsg, 1, &pAttributes[i]),
            targetid = CollId.objid,
            targetos = CollId.osnum ) ;
      }

    } else 
      *msg = MSFAIL;/* set to indicate that process is not
          successful on all of the attributes*/

  } /*end processing for attrbutes  */

  if (bUserModified)
  {  /*A this is required so as to avoid unnecessary 
         disconnection and connection      */

    /*A detach the previous collections and attach the new ones  */

    status = 
    om$send (msg = message VCRoot.VCChgParam
                              (&retmsg, (IGRshort) VC_USRATT, &CollId),
        targetid = my_id);

    /*A do i need to send recompute or the collections themselves 
        take care about that : don't think so......

    nd$wait_batch(  type       = GR_GEOM_POSTED,
                    l_object   = &MyId,
                    nb_obj     = 1 );
    nd$exec_batch();
                                    i need to confirm about this    */
  }

  return   OM_S_SUCCESS;
}/*end VDSmodUsrAttributes  */

/*+mo
  Overridden Message
  VDSgetUsrAttributes from VDSroot

  Abstract
  Motivation : Each I/CABLE entity has two diff collections
  as  it's parents. System collection and User collection
  This design is different from other I/VDS suite of 
  products. The method has been overriden to suit this design
  and serve the functionality.

  This method can be used either to get the number of user 
  attributes or the list of user attributes or both for a given 
  I/CABLE object. Pass NULL as an argument if output is not required.

  Arguments
        OUT     IGRlong           *msg    Completion code.
        OUT     IGRint            *pNbAttrs  Number of user attributes or NULL
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

method  VDSgetUsrAttributes (IGRlong      *msg ;
                             IGRint       *pNbAttrs;
                      struct ACrg_coll   **pAttr;
                      struct GRmd_env     *pMdEnv )
{
  IGRint      status;
  IGRshort    nChild, nPar;

  struct GRmd_env   *pLoc;
  struct GRid        UsrCollId;
  struct ACrg_coll  *pList;

  pLoc  = pMdEnv;      /*   compiler warning    */
  pList = NULL;

  /*A validate the arguments  */
  if (!pNbAttrs && !pAttr)  return   OM_E_INVARG;

  status =
  om$send (msg = message VCRoot.VCGetUsrPar
                   (msg, &UsrCollId, &nChild, &nPar, NULL),
      targetid = my_id);

  if (pNbAttrs) *pNbAttrs = nPar;

  if (nPar > 0 )
  {
    pList = _MALLOC (nPar, struct ACrg_coll);

    if (!pList) return  OM_E_NODYNMEM;

    status =
    om$send (msg = message VCRoot.VCGetUsrPar
                     (msg, &UsrCollId, &nChild, &nPar, pList),
        targetid = my_id);
  }

  *pAttr = pList;

  return  OM_S_SUCCESS;  

}/*end VDSgetUsrAttributes  */


method VDGetModel( IGRlong     *msg;
            struct GRid        *ModelId;
            struct GRmd_env    *pMdEnv )
{
  struct GRmd_env    *pLoc;

  pLoc = pMdEnv;     /*   compiler warning   */

  return (
  om$send ( msg = message VCRoot.VCGetModel (msg, ModelId),
             targetid = my_id ));
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
  IGRshort     nNbIns, nNbSys, nNbUsr;
  IGRshort     nSys, nUsr;
  IGRint       NbTot;
  IGRint       nAtt;
  IGRint       nDB;
  IGRint       i;
  IGRshort     nIndex, nMap;
  IGRchar     *pAttNam;
  IGRchar     ClassName[100];

  struct ACrg_coll   *Local, locnuatt[20];
  IGRint nbAddAttr;
  struct GRid         SysId, UsrId;
  struct GRid         ModelId;
  struct ret_struct   rts, l_rs;

  if ( !msg || !md_env )
    return  OM_E_INVARG;

  /*A initialization  */
  *msg       = MSSUCC;
  *nbParams  = 0;
  *parList   = NULL;

  nIndex = nMap = -1;

  SysId.objid   = NULL_OBJID ;
  UsrId.objid   = NULL_OBJID ;

  /*A get the sys, usr collection Ids  */
  status = 
  om$send ( msg = message VCRoot.VCGetInsPar (&retmsg, &nNbIns, NULL),
       targetid = my_id );

  status = 
  om$send ( msg = message VCRoot.VCGetSysPar
                           (&retmsg, &SysId, &nSys, &nNbSys, NULL),
       targetid = my_id );

  status = 
  om$send ( msg = message VCRoot.VCGetUsrPar
                           (&retmsg, &UsrId, &nUsr, &nNbUsr, NULL),
       targetid = my_id );

  /*   count the number of DB parameters for this item   */

  status = 
  om$send ( msg = message VCRoot.VCGetModel (&retmsg, &ModelId),
       targetid = my_id );

  nDB = 0;
  /** TR4342 **/
  if(ModelId.objid != NULL_OBJID)
  {
    for (nAtt = 0; nAtt < VC_DB_PARA_LIMIT; nAtt++)
    {
      status =
      om$send ( msg = message VCDB.VCGpAnum
                            (&retmsg, nIndex, nMap, nAtt, &rts),
         targetid = ModelId.objid,
         targetos = ModelId.osnum);

      if (retmsg == MSSUCC) nDB++;
    }
  }
  /***** CR179702191 installation of additional attributes ******/

  {
    IGRchar locattr[VD_K_tokMAX_SIZE];
    IGRint i,count;

    om$get_classname( objid   = my_id,
                      osnum   = OM_Gw_current_OS, 
                    classname = ClassName);
    {
      count = 0;
      vd$ppl_exec(  file_name = "VRattribute",func_name = ClassName );
      vd$ppl_get_size(  which_info = OUTPUT_INFO, size = &count );
      nbAddAttr = 0;
      for(i=0; i<count; i++)
      {
        IGRint foot_index, intmsg;

        vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
                                index      = i,
                                value      = &locattr );
        foot_index = -1;
        intmsg = 0;
        status=
        om$send (msg = message VRGeneric.ACgive_structure
                        (&intmsg, &foot_index, locattr, &l_rs, md_env),
                targetid = my_id);
        /* Allow for additional attributes NOT to be on object */
        /*** if give_struct NOT a failure ***/
        if( status & intmsg & 1 )
        {

            strcpy( locnuatt[nbAddAttr].name, locattr);

            if(l_rs.type == double_type)
            {
               locnuatt[nbAddAttr].desc.value.att_exp =
                                          l_rs.var.root_pm_st.value;
               locnuatt[nbAddAttr].desc.type          = AC_ATTRIB_DOUBLE;


            }
            else
            {
               strcpy(locnuatt[nbAddAttr].desc.value.att_txt,
                                      l_rs.var.text_st.text_string);
               locnuatt[nbAddAttr].desc.type = AC_ATTRIB_TEXT;
            }
            nbAddAttr++;
        }
     }

     }
  }
  *nbParams = NbTot = nNbIns + nNbSys + nNbUsr + nDB + nbAddAttr;

  if (parList)
  {
    Local = _MALLOC (NbTot, struct ACrg_coll);
    if (Local == NULL) return (OM_E_NODYNMEM);

    status = 
    om$send ( msg = message VCRoot.VCGetInsPar (&retmsg, &nNbIns, Local),
         targetid = my_id );

    status = 
    om$send ( msg = message VCRoot.VCGetSysPar
                           (&retmsg, &SysId, &nSys, &nNbSys, &Local[nNbIns]),
       targetid = my_id );

    status = 
    om$send ( msg = message VCRoot.VCGetUsrPar
                   (&retmsg, &UsrId, &nUsr, &nNbUsr, &Local[nNbIns + nNbSys]),
       targetid = my_id );

    *nbParams = nNbIns + nNbSys + nNbUsr;

    /*** cr179702191 add in addtional attributes ***/
    if(nbAddAttr)
    {
      for(i=0; i<nbAddAttr; i++)
      {
        Local[*nbParams] = locnuatt[i];
        (*nbParams)++;
      }
    }

    if(ModelId.objid != NULL_OBJID)
    {
      for (nAtt = 0; nAtt < VC_DB_PARA_LIMIT; nAtt++)
      {
        status =
        om$send ( msg = message VCDB.VCGpAnum
                            (&retmsg, nIndex, nMap, nAtt, &rts),
           targetid = ModelId.objid,
           targetos = ModelId.osnum);

        if (retmsg != MSSUCC) continue;
        pAttNam = VCDB_AttrNumToNam ((IGRshort) nAtt);
        for (i=0; i<(*nbParams); i++)
           if (strcmp (pAttNam, Local[i].name) == 0) goto BYPASS;
        strcpy (Local[*nbParams].name, pAttNam);
        if (rts.type == text_type)
        {
          Local[*nbParams].desc.type = AC_ATTRIB_TEXT;
          strcpy (Local[*nbParams].desc.value.att_txt,
                                 rts.var.text_st.text_string);
          (*nbParams)++;
        }
        else
        if (rts.type == double_type)
        {
          Local[*nbParams].desc.type = AC_ATTRIB_DOUBLE;
          Local[*nbParams].desc.value.att_exp = rts.var.root_pm_st.value;
          (*nbParams)++;
        }

        BYPASS:;
      }
    }
    *parList = Local;
  }

  return  status;
}

method  VDSgetCompDesc(IGRlong          *msg;
                       struct ACrg_coll *Param;
                       struct GRmd_env  *md_env )
{
   /*  for VRGeneric only, dummy this    */

  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method VDgetObjDef( 	long *msg ; 
			VDobjDef *myDef ) 
{

        myDef->info             = VD_I_ObjVCRoot ;
        myDef->type             = 0 ;

        *msg    = MSSUCC ;

        return (OM_S_SUCCESS)  ;
}

end implementation VCRoot;


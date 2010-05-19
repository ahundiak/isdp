/* $Id: SMMnSfUsrAtt.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMcompi.I
 *
 * Description:
 *
 *      Implementation of user attributes methods for structural surfaces 
 *      
 *      Methods :
 *           VDSgetUsrAttributes
 *           VDSmodUsrAttributes
 *
 *
 * Notes :
 *      The methods have the same implementation as that of the compartment 
 *      objects implementation.  So they have been copied from the compartment
 *      implementation file "SMcompUsrAtt.I".
 *
 * Revision History:
 *	$Log: SMMnSfUsrAtt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/29  09:20:52  pinnacle
# Replaced: smstrsf/imp/SMMnSfUsrAtt.I for:  by ksundar for vds.240
#
# Revision 1.3  1995/02/22  21:19:20  pinnacle
# Replaced: smstrsf/imp/SMMnSfUsrAtt.I by rmanem r#
#
# Revision 1.2  1995/01/06  17:47:22  pinnacle
# Replaced:  smstrsf/imp/SMMnSfUsrAtt.I r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      08/15/94	R. Manem 		Creation date.
 *	01/06/95	R. Manem		check for nbAttrs value instead 
 *						of nbAtt for 0 in 
 *						VDmodUsrAttributes
 *      02/22/95        R. Manem                Modify foot along with template
 *
 * -------------------------------------------------------------------------
 */


class implementation SMMainSf;


#include "string.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "vdparmacros.h"

#include "exproto.h"

#include "SMdef.h"
#include "ACattrib.h"
#include "ACdyn_col.h"
#include "ACrg_collect.h"

#include "nddef.h"
#include "ndmacros.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"
#include  "VDmem.h"

#include "AS_status.h"

extern int SMDelOneAttType();        /* defined in smcomp/SMcompUsrAtt.I */
extern int VDgetAttrIndex();         /* defined in smcomp/SMcompUsrAtt.I */

from ACrg_collect       import  ACset_list_attribute;
from ACdyn_col          import  ACset_att_prop;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSgetUsrAttributes from VDSroot

  Abstract

        This method retrieves the user attributes of the structural
        surface  objects.

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             *nbAttrs         O       No of user attributes
     struct ACrg_coll   **att            O       List of attributes
     struct GRmd_env    *md_env          I       Module environment of object

  Status
      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/

method VDSgetUsrAttributes( IGRlong          *msg;
                            IGRint           *nbAttrs;
                            struct ACrg_coll **att;
                            struct GRmd_env  *md_env )
{
   IGRlong           status;
   IGRshort          type;

   *nbAttrs = 0;
   
   /* initialize sman type of attributes - user attributes only */

   type = 0 | SM_USER_ATT | SM_DYNAMIC_ATT;

   /* get the list of user attributes */

   status = om$send( msg = message SMAttMgr.SMGetAttType( msg, type, nbAttrs,
                                                          att ),
                     targetid = my_id );
   as$status( );

#ifdef DEBUG
   printf("\nnbAttrs = %d", *nbAttrs);
#endif

   return status;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSmodUsrAttributes from VDSroot

  Abstract

        Adds user attributes to the object, modifies user attributes of the
        object, and deletes user attributes from the object according to the
        following logic :

               If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
               otherwise,
                   If the attribute exists, it is modified to reflect
                   the new type and value.
                   If the attribute does not exist, it is created with the
                   new type and value.

               It is not an error to delete an attribute that does not exist.

  Algorithm

       get the list of all attributes (SMListAtt)
      
       for each attribute to be modified

          get attribute by name (SMGetAtt)

          if attr exists and is not a user attribute
             print error message, continue with next attribute

          if attr type = VD_ATTRIB_DELETE
             delete one attribute from list (SMDelOneAttType)
          else 
             if attribute exists
                modify it
             else
                add the attribute

       set the new list of attributes (SMResetAtt)


       Remarks :
       We cannot use SMSetAttr function for modifying or adding attribute in
       the list because that function does not set the type of the attribute
       if it already exists, it only modifies the value of the attribute, and 
       hence does not allow change of attribute type from TEXT to DOUBLE 
       or vice versa.
      

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             nbAttrs          I       No of user attributes to be
                                                 modified
     struct ACrg_coll   *att             I       List of attributes to be
                                                 modified
     struct GRmd_env    *md_env          I       Module environment of object


   Notes
        - the type of an attribute (att[i].desc.type) can have the following
          values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Status/Return Code
      OM_S_SUCCESS      always
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/


method VDSmodUsrAttributes( IGRlong          *msg;
                            IGRint           nbAttrs;
                            struct ACrg_coll *att;
                            struct GRmd_env  *md_env )
{

   int              i, index;
   IGRint           list_len, found, nbAtt = 0;
   IGRlong          status = OM_S_SUCCESS;
   IGRchar          stsstr[100];
   IGRshort         type,
                        user_att_type,
                        is_user_att,
                        int_prop, user_prop,
                        *l_type = NULL;
   struct ACrg_coll one_att, *l_att = NULL;
   struct GRid		footId, obj;

   if( !nbAttrs )
      goto wrapup;

   status = om$send( msg = message SMAttMgr.SMListAtt( msg, 0,
                                                       &nbAtt, NULL, NULL ),
                     targetid = my_id );
   as$status( action = RET_STATUS );

   list_len = nbAttrs + nbAtt;

   l_att = _MALLOC( list_len, struct ACrg_coll); 
   l_type = _MALLOC( list_len, IGRshort);

   if( l_att == NULL || l_type == NULL )
   {
      status = OM_E_NODYNMEM;
      goto wrapup;
   }
    
   status = om$send( msg = message SMAttMgr.SMListAtt( msg, nbAtt,
                                                       &nbAtt, l_att, l_type ),
                     targetid = my_id );
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   for( i = 0 ; i < nbAttrs ; i++ )
   {
      /* Get the attribute, if it exists */

      strcpy( one_att.name, att[i].name );
      status = om$send( msg = message SMAttMgr.SMGetAtt( msg, 1, 
                                                         &one_att, &type ),
                        targetid = my_id );
     
      as$status();

      found = status & *msg & 1;
      is_user_att = type & SM_USER_ATT;

      if( found && !is_user_att )
      {

         /* attribute exists as a system attribute : print error message */

         printf("\n\nCannot add attribute \"%s\" : ", att[i].name );
         printf("\n\tAlready exists as a system attribute\n\n" );
                 
         sprintf( stsstr, "System attr \"%s\" already exists", 
                 att[i].name );
         UI_status( stsstr );
         continue;
      }

#ifdef DEBUG
    printf("\n\nAttribute %s : found = %d, is_user_att = %d", att[i].name, 
                               found, is_user_att );
#endif

      if( att[i].desc.type == VD_ATTRIB_DELETE )
      {
      
         /* Delete the attribute */

         SMDelOneAttType( l_att, l_type, &nbAtt, att[i].name );

      }
      else
      {
         user_att_type = 0 | SM_USER_ATT | SM_DYNAMIC_ATT;

         /* get the index of the attribute in the list, if present */

         found = VDgetAttrIndex( att[i].name, l_att, nbAtt, &index );

         if( found )
         {
            /* modify the attribute */
          
            l_att[index] = att[i];
            l_type[index] = user_att_type;
         }
         else
         {
            /* add the attribute */

            l_att[nbAtt] = att[i];
            l_type[nbAtt++] = user_att_type;
         }
      }
   }

   status = om$send( msg = message SMAttMgr.SMResetAtt( msg, nbAtt,
                                                        l_att, l_type ),
                     targetid = my_id );
   as$status();


   /* get the foot collector, and update it */

   status = om$send( msg        = message NDmacro.ACreturn_foot( msg,
                                                                "attr",
                                                                &footId,
                                                                NULL, NULL ),
                targetid        = my_id );

   as$status();

#ifdef DEBUG
   printf("\nFoot id = %d,%d", footId.objid, footId.osnum );
#endif

   status = om$send( msg        = message ACrg_collect.ACset_list_attribute(
                                                                msg,
                                                                nbAtt,
                                                                l_att ),
                targetid        = footId.objid,
                targetos        = footId.osnum );
   as$status();

   for( i = 0 ; i < nbAtt ; i++ )
   {
      int_prop = 0;
      user_prop = 0;

      if( l_type[i] & SM_STATIC_ATT )
         int_prop |= AC_ATTRIB_LOCK;
      user_prop = l_type[i] & AC_ATTRIB_MASK_USER;

      status = om$send( msg     = message ACdyn_col.ACset_att_prop( msg,
                                                                l_att[i].name,
                                                                int_prop,
                                                                user_prop ),
                        targetid = footId.objid,
                        targetos = footId.osnum );
   }

   /* execute object */

   obj.objid = my_id;
   obj.osnum = OM_Gw_current_OS;

   nd$wait_batch(       type    = GR_GEOM_POSTED,
                        nb_obj  = 1,
                        l_object= &obj );
   nd$exec_batch();

wrapup :

   _FREE( l_att ) ;
   _FREE( l_type ) ;

   return status;
}

end implementation SMMainSf;
 


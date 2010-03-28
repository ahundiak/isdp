/*----
 
     ABSTRACT:    

    This function will add/remove/locate an object to/from a btree.
    In order to use this function the btree must be a member of
    the NOD object.
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------------
     num_spaces   IGRint         number of object spaces that are to
                                 be used. 
     *p_OSNUMS    GRspacenum     ptr to an array of space numbers
                                 to be used.
     *btreename   IGRchar        ptr to name of the btree which is
                                 in the GR NOD object.
     *objectname  IGRchar        ptr to name of the object to be 
                                 added/removed/located
     *objid       GRobjid        ptr to object id of the object to be 
                                 added/removed/located
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        MSSUCC : operation successfull
                                 MSFAIL : operation failed
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods:        
                  OMbtree.add 
                  OMbtree.remove
                  OMbtree.translate
                  GRget_NOD_object
-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

     TMK   06/12/86  : Creation date.
     HGW   10/16/86  : Redesigned.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        Given the name of a btree and an array of OS numbers, the 
        required object is either added, removed or located from the 
        btree in the specified OS's.  In case of adding or removing 
        an object, only one OS should be sent as the argument.
        In case of locating, if more than one OS is sent, the sequence
        of searching will be according to the order of OS numbers sent
        in an array.
----*/
/*EH*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "grerr.h"
#include "exmacros.h"

from OMbtree import add, remove, translate, OMbtree_constr, btree_contents;

#define TRUE  1
#define FALSE 0
#define OR    ||

IGRint GRbtreeadd( msg, num_spaces, p_OSNUMS, btreename,
                    objectname, objid)

IGRlong     *msg;
IGRint      num_spaces;
GRspacenum  *p_OSNUMS;
IGRchar     *btreename;
IGRchar     *objectname;
GRobjid     *objid;
{
IGRlong          status;
IGRlong          msg1;
IGRint           i;
GRobjid          btreeobjid; /* objid of the btree           */
OM_S_KEY_DESC    KEY;        /* key description record       */


   status = OM_S_SUCCESS;
   KEY.type = KEY_STRING;
   KEY.key.p_string = objectname;
   *msg = MSSUCC;

   for (i=0; i < num_spaces; ++i)
   {    
      /*
       *  Get the object id of the btree.
       */

      status = GRget_btree (&msg1, btreename, p_OSNUMS[i], &btreeobjid);

      if( !(status & msg1 & 1))
      {
         *msg = MSFAIL;
         return( OM_W_ABORT );
      }

      
      status = om$send(mode = OM_e_wrt_object,
               msg = message OMbtree.add(&KEY, objid, 0, (int *)&msg1),
               senderid = NULL_OBJID, targetid = btreeobjid,
               targetos = p_OSNUMS[i] );

      msg1 = msg1^1;        /* XOR msg1 so that 1:succ and 0:fail */
      if( !(status & msg1 & 1) )
      {
         *msg = MSFAIL;
         return( OM_W_ABORT );
      }
   }  /* end of for loop */
   return ( OM_S_SUCCESS );
} 

/******************************************************************/
IGRint GRbtreeremove( msg, num_spaces, p_OSNUMS, btreename, 
                       objectname, objid)

IGRlong     *msg;
IGRint      num_spaces;
GRspacenum  *p_OSNUMS;
IGRchar     *btreename;
IGRchar     *objectname;
GRobjid     *objid;
{
IGRlong          status;
IGRlong          msg1;
IGRint           i;
GRobjid          btreeobjid; /* objid of the btree           */
OM_S_KEY_DESC    KEY;        /* key description record       */


   status = OM_S_SUCCESS;
   KEY.type = KEY_STRING;
   KEY.key.p_string = objectname;
   *msg = MSSUCC;

   for (i=0; i < num_spaces; ++i)
   {    
      /*
       *  Get the object id of the btree.
       */

      status = GRget_btree (&msg1, btreename, p_OSNUMS[i], &btreeobjid);

      if( !(status & msg1 & 1))
      {
         *msg = MSFAIL;
         return( OM_W_ABORT );
      }

      status = om$send(mode = OM_e_wrt_object,
               msg = message OMbtree.remove(&KEY, objid, 0, (int *)&msg1),
               senderid = NULL_OBJID, targetid = btreeobjid,
               targetos = p_OSNUMS[i] );

      msg1 = msg1^1;        /* XOR msg1 so that 1:succ and 0:fail */
      if( !(status & msg1 & 1) )
      {
         *msg = MSFAIL;
         return( OM_W_ABORT );
      }
   }  /* end of for loop */
   return ( OM_S_SUCCESS );
} 

/********************************************************************/
IGRint GRbtreelocate( msg, num_spaces, p_OSNUMS, btreename, 
                     objectname, objarray, loc_OS)

IGRlong          *msg;        /* return code 0: fail 1: succ  */
IGRint           num_spaces;  /* max no of OS                 */
GRspacenum       *p_OSNUMS;   /* ptr to an array of OSNUM's   */
IGRchar          *btreename;
IGRchar          *objectname; /* name of object to be located */
OM_S_OBJARRAY    *objarray;   
/* struct OM_S_OBJARRAY 
   {
      int size; size of array
      int count;  no of entries
      int tree_type; type of tree
      OM_S_OBJID array[]; array to hold objid's
   }
*/
GRspacenum       *loc_OS;    /* located object space number   */
{
    IGRlong           status;
    IGRlong           msg1;
    GRobjid           btreeobjid; /* objid of the btree          */
    IGRint            i = 0;
    IGRint            size,count;
    OM_S_KEY_DESC     KEY;

    status = OM_S_SUCCESS;
    KEY.type = KEY_STRING;
    KEY.key.p_string =objectname;
    *msg = MSSUCC;


    if ( num_spaces > 0 )
    {    
        /*
         *  Get the object id of the btree.
         */

        /*
          Note: variable i initialized to zero 1/5/93, suspect that this code
          is never hit since it had been random for ages -- mrm
        */

        status = GRget_btree (&msg1, btreename, p_OSNUMS[i], &btreeobjid);

        if( ! (status & msg1 & 1) )
        {
            *msg = MSFAIL;
            return( OM_W_ABORT );
        }

        status = om$send(mode = OM_e_wrt_object,
                         msg = message OMbtree.translate(objarray,&KEY,0,0,
                                                         (int *)&msg1),
                         senderid = NULL_OBJID, targetid = btreeobjid,
                         targetos = p_OSNUMS[i]);

        msg1 = msg1^1;          /* XOR msg1 so that 1:succ and 0:fail */
        if( !(status & msg1 & 1) ) 
        {
            *msg = MSFAIL;
            return( OM_W_ABORT );
        }

        size = (objarray->size - sizeof(OM_S_OBJARRAY))/ sizeof(OM_S_OBJID);
        size++; /*  Add one for the object id imbeded in the structure */
        count = objarray->count;
        *loc_OS = p_OSNUMS[i];

        if ( count > size )
        {
            *msg = GR_I_EXCEDBUF;
            return (OM_S_SUCCESS);         
        }
        else
        {
            return(OM_S_SUCCESS);
        }
    }
    return(OM_S_SUCCESS);
} 

/********************************************************************/
IGRint GRbtreelocate_all ( msg, osnum, btreename, objects, start, size, 
                           count)
IGRlong              *msg;
GRspacenum           osnum;
IGRchar              *btreename;
OM_p_BTREE_CONTENTS  objects;
IGRint               start;
IGRint               size;
IGRint               *count;         
{
IGRlong           om_msg;
IGRlong           ret_msg;
GRobjid           btreeobjid;   /* objid of the btree          */

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   /*
    *  Get the object id of the btree.
    */

   om_msg = GRget_btree (&ret_msg, btreename, osnum, &btreeobjid);

   if(om_msg & ret_msg & 1)
   {
      /*
       *  Call the btree contents method.
       */

      *count = size;
      om_msg = om$send(
               msg = message OMbtree.btree_contents (start, count, objects,
               (int *)&ret_msg),
               senderid = NULL_OBJID, targetid = btreeobjid,
               targetos = osnum);

      ret_msg = ret_msg ^ 1;     /* XOR msg so that 1:succ and 0:fail */

      if(om_msg & ret_msg & 1)
      {
         /*
          *  get the total number of objects in the btree
          */

         om_msg = om$send (msg = message OMbtree.btree_contents
                                (start, count, NULL, (int *)&ret_msg),
                           senderid = NULL_OBJID,
                           targetid = btreeobjid,
                           targetos = osnum);

         ret_msg = ret_msg ^ 1;     /* XOR msg so that 1:succ and 0:fail */

         if (*count > size)
         {
            *msg = GR_I_EXCEDBUF;
         }
      }else
      {
         *msg = MSFAIL;
         om_msg = OM_W_ABORT;
      }
   }else
   {
      *msg = MSFAIL;
      om_msg = OM_W_ABORT;
   }
   return (om_msg);
} 

/********************************************************************/
IGRint GRbtreecount (msg, osnum, btreename, count)
IGRlong              *msg;
GRspacenum           osnum;
IGRchar              *btreename;
IGRint               *count;         
{
    IGRlong           sts;
    IGRlong           rc;
    GRobjid           btreeobjid;   /* objid of the btree */

    *count = -1;
    *msg = MSFAIL;

    /* get the object id of the btree */

    sts = GRget_btree (&rc, btreename, osnum, &btreeobjid);

    if (sts & rc & 1)
    {
        /* get the total number of objects in the btree */

        sts = om$send (msg = message OMbtree.btree_contents
                            (0, count, NULL, (int *)&rc),
                       senderid = NULL_OBJID,
                       targetid = btreeobjid,
                       targetos = osnum);

        rc = rc ^ 1;     /* XOR rc so that 1:succ and 0:fail */

        if (sts & rc & 1)
        {
            *msg = MSSUCC;
        }
    }
    return ((*msg) & 1);
} 

IGRint GRget_btree (msg, btreename, osnum, btree_objid)
IGRlong     *msg;
IGRchar     btreename[];
GRspacenum  osnum;
GRobjid     *btree_objid;
{
IGRlong  om_msg;
IGRlong  ret_msg;
GRobjid  NOD_objid; 

   *msg = MSSUCC;

   /*
    *  Get the object id of the btree.
    */

   om_msg = GRget_global_mgr_id (&ret_msg, btreename, osnum, btree_objid);

   /*
    *  If the btree was not found then construct a btree object and
    *  add it to the NOD.
    */

   if (! (om_msg & 1))
   {
      /*
       *  Get the NOD.
       */

      om_msg = GRget_NOD_object(&ret_msg, osnum, &NOD_objid);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  Construct a btree object for the local symbol library.
          *  Give it an unique name, i.e. "gr$sd_btree", and put it in NOD.
          */

         om_msg = om$construct ( classname = "OMbtree", 
                  osnum = osnum, p_objid = btree_objid, 
                  msg = message OMbtree.OMbtree_constr(BTREE_STRING, 
                  (int *)&ret_msg));

         if (om_msg & 1)
         {  
            /* 
             *  Add the symbol btree to NOD. 
             */

            om_msg = ex$add_name_to_NOD (NODobjid = NOD_objid, 
                     objname = btreename, objid = *btree_objid, 
                     mod_osnum = osnum);
         }
      }
   }
   return(om_msg);
}
end implementation Root;


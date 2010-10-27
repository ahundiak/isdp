/* $Id: VDeqUsrAttr.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	vdequip/imp/ VDeqUsrAttr.I
 *
 * Description:
 *	Implementation of user attribute methods for Equipment objects. 
 *
 *      Methods :
 *            VDSgetUsrAttributes
 *            VDSmodUsrAttributes
 *	      VDgetObjDef
 *
 * History:
 *      08/15/94       R. Manem              Creation
 *	11/12/94	adz		add for old equipment.
 *	02/22/95	R. Manem	Modify foot along with template
 *	08/18/95	R. Manem	Fixed bug in malloc size : had
 *					missed out the "mark_user" attribute
 *
 * -------------------------------------------------------------------------
 */


class implementation VDequipment;

#include "string.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "exproto.h"

#include "vdparmacros.h"
#include "VDGadgDef.h"
#include "VDmsg.h"

#include "AS_status.h"

#include "nddef.h"
#include "ndmacros.h"

from ACrg_collect     import  AClist_attribute;
from ACrg_collect     import  ACset_list_attribute;

extern double strtod();
extern int VDgetAttrIndex();

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDModAddAttr

  Abstract

 	Given the name of an attribute, add this attribute or modify its value
 	in the given array of ACrg_coll, depending of the value of the flag:  
                                             	 		
   	-VD_ADD_ATTR    : Add attribute (if already existing -> error)
   	-VD_MOD_ATTR    : Mod attribute (if does not exists  -> error)
   	-VD_MODADD_ATTR : Try to modfify if exists else add                 


  Returns
	returns 1 if success
	0 otherwise

 -------------------------------------------------------------------------
*/

int VDModAddAttr(
char name[],             /* [I] Name of the attribute               */
struct ACrg_coll ACrg[], /* [O] Array of ACrg_col where to modify   */
int *nb_attr,            /* [I/O] Number of element in the ACrg     */   
int type,                /* [I] ACrg_type type of attribut          */
double  f,               /* [I] value of attribut (if double)       */
char str[],              /* [I] value of attribut (if text)         */
int max_attr,            /* [I] max nb_attr possible in ACrg        */ 
int flag                 /* [I] mode (modify-add) of operation      */   
)
/*
-fi */

{

  if(SMGetAttr(name, ACrg,(IGRshort *)NULL,*nb_attr,
	       (int *)NULL,(IGRdouble *)NULL,(IGRchar *)NULL,(IGRshort *)NULL))
   {
     if(flag == VD_ADD_ATTR) return 0;
   }
  else
   {
     if(flag == VD_MOD_ATTR) return 0;
   }

  if(SMSetAttr(name,ACrg,(IGRshort *)NULL,nb_attr,
	       type,f,str,0,max_attr))
    return 1;
  else
    return 0;
}


/*+fi
 -------------------------------------------------------------------------
  Internal Function VDDelOneAttrib

  Abstract
        This function is used to delete from the given ACrg, an 	
	attribute given by his name.

  Returns
	returns 1 if success
	0 otherwise

 -------------------------------------------------------------------------
*/

int VDDelOneAttrib(
struct ACrg_coll work_att[],         /* [I/O] Array of ACrg_col where delete */
int              *work_nb_att,       /* [I/O] Number of element in  ACrg     */
char             *name               /* [I] Name of attribute to delete      */
)
/*
-fi */
{
  int att_ind = 0,i;

  if(*work_nb_att <= 0) {printf("No attribute defined\n");return 0;}

  for(i = 0; i < *work_nb_att; i++)
    if(strcmp(work_att[i].name,name) == 0)
     {
       att_ind = i;
       break;
     }
  
  if(i ==  *work_nb_att) return 0; /* Attribute not found */

  if(att_ind + 1 < *work_nb_att)
   {
     memcpy(&work_att[att_ind],&work_att[att_ind+1],
	    (*work_nb_att - att_ind - 1) * sizeof(struct ACrg_coll));
   }

  *work_nb_att = *work_nb_att - 1;
  return 1;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDSgetUsrAttributes from VDSroot

  Abstract

        This method retrieves the user attributes and their values of the 
        object.

  Arguments

     IGRlong            *msg             O       completion code
     IGRint             *nbAttrs         O       No of user attributes
     struct ACrg_coll   **att            O       List of user attributes
     struct GRmd_env    *md_env          I       Module environment of object

  Status/Return Code
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
   IGRint            i, totalNbAtt, nbUsrAtt, startUsrIndex = 0;
   IGRlong           status;
   IGRboolean        found;
   struct GRid       dyn_box;
   struct ACrg_coll  *dynAtt = NULL;

   /* initialize values and pointers */

   (*nbAttrs) = 0;
   *att = NULL;

   /* get the rg_collector object for the dynamic and user attributes */
 
   status = om$send( msg = message ACcpx.ACfind_temp_obj( (IGRint *)msg, 
                                                          "userpara",
                                                          &dyn_box ),
                     targetid = my_id );
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   /* Get the number of dynamic and user attributes */

   status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 0,
                                                                  NULL,
                                                                  &totalNbAtt ),
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );
   
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

#ifdef DEBUG
   printf("\nNumber of dynamic and user attributes : %d", totalNbAtt );
#endif

   if( !totalNbAtt )
      goto wrapup;

   /* allocate space for list of attributes */

   dynAtt = (struct ACrg_coll *)om$malloc( size = (sizeof( struct ACrg_coll ) *
                                           (totalNbAtt) ));

   if( dynAtt == NULL )
   {
      *msg = MSFAIL;
      status = OM_E_NODYNMEM;
      goto wrapup;
   }
  
   /* Get the attributes */

   status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 
                                                                  totalNbAtt,
                                                                  dynAtt,
                                                                  &totalNbAtt ),
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );
   
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   found = FALSE;
   for( i = 0 ; i < totalNbAtt ; i++ )
      if( !strcmp( dynAtt[i].name, "mark_user" ) )
      {
         found = TRUE;
         startUsrIndex = i + 1;
         break;
      }

#ifdef DEBUG
   printf("\nStarting Index for user attributes : %d", startUsrIndex );
#endif


   nbUsrAtt = totalNbAtt - startUsrIndex;

   /* if there are no user attributes, return */

   if( !found || !nbUsrAtt )
      goto wrapup;

   /* allocate space for list of attributes */

   *att = (struct ACrg_coll *)om$malloc( size = sizeof( struct ACrg_coll ) *
                                                nbUsrAtt );

   if( *att == NULL )
   {
      *msg = MSFAIL;
      status = OM_E_NODYNMEM;
      goto wrapup;
   }

   /* copy each user attribute into the output list */

   for( i = startUsrIndex ; i < totalNbAtt ; i++ )
   {
      (*att)[*nbAttrs] = dynAtt[i];
      (*nbAttrs)++;
   }

wrapup :
   
   /* if some error, free the output attribute list */

   if( !( status & *msg & 1 ) )
      if( *att )
         free( *att );


   /* free the local dynamic attributes list */

   if( dynAtt )
      free( dynAtt );

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


  Algorithm

     get the GRid of the static attributes rg collector.
     get the list of the static attributes.

     get the GRid of the dynamic attributes rg collector.
     get the list of the dynamic attributes.
     Check for "mark_user", if not found, create one.
 
     for each attr 
          if attr exists as dynamic or static attr
               print error message; continue with next attribute

          if attr type = VD_ATTRIB_DELETE
               delete it from the list (VDDelOneAttrib)
          else
               if attribute exists
                  modify it
               else
                  add the attribute

      Assign the new list of attributes to the rg_collector.

      Remarks :
      We cannot use VDModAddAttr or SMSetAttr functions for modifying or 
      adding attribute in the list because the function does not set 
      the type of the attribute if it already exists, it only modifies 
      the value of the attribute, and hence does not allow change of 
      attribute type from TEXT to DOUBLE or vice versa.


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

   IGRint           i, j, index;
   IGRint           maxAttrs, nbDynAtt, nbStatAtt, nbDynUsrAtt;
   IGRint           startUsrIndex = 0;
   IGRlong          status;
   IGRchar          stsstr[100];
   IGRboolean       found;
   struct GRid      dyn_box, stat_box;
   struct ACrg_coll *statAtt = NULL, *dynAtt = NULL;

   struct GRid      dynBoxFoot, 
		    obj;

   /* get the foot collector */

   status = om$send( msg	= message NDmacro.ACreturn_foot( msg,
								"dyn_attr",
								&dynBoxFoot,
								NULL, NULL ),
		targetid	= my_id );
   as$status();

#ifdef DEBUG
   printf( "\nmodUsrAttributes : my_id = %d, foot = %d", my_id, 
						dynBoxFoot.objid );
#endif

   /* get the rg_collector object for the static attributes */

   maxAttrs	= 0;
   nbDynAtt	= 0;
   nbStatAtt	= 0;
   nbDynUsrAtt	= 0;
 
   status = om$send( msg = message ACcpx.ACfind_temp_obj( (IGRint *)msg, 
                                                          "syspara",
                                                          &stat_box ),
                     targetid = my_id );
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   /* Get the number of static attributes */
   status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 0,
                                                                  NULL,
                                                                  &nbStatAtt),
                     targetid = stat_box.objid,
                     targetos = stat_box.osnum );
   
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

#ifdef DEBUG
   printf("\nNumber of static attributes : %d", nbStatAtt );
#endif

   if( nbStatAtt )
   {

      /* allocate space for list of attributes */

      statAtt = (struct ACrg_coll *)om$malloc( size = 
                                               (sizeof( struct ACrg_coll ) *
                                               (nbStatAtt) ));

      if( statAtt == NULL )
      {
         *msg = MSFAIL;
         status = OM_E_NODYNMEM;
         goto wrapup;
      }
     
      /* Get the list of static attributes */
   
      status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 
                                                                  nbStatAtt,
                                                                  statAtt,
                                                                  &nbStatAtt ),
                        targetid = stat_box.objid,
                        targetos = stat_box.osnum );
      
      as$status();
   
      if( !(status & *msg & 1) )
         goto wrapup;
   }
   
   
   /* get the rg_collector object for the dynamic and user attributes */
 
   status = om$send( msg = message ACcpx.ACfind_temp_obj( (IGRint *)msg, 
                                                          "userpara",
                                                          &dyn_box ),
                     targetid = my_id );
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   /* Get the number of dynamic and user attributes */

   status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 0,
                                                                  NULL,
                                                                  &nbDynUsrAtt),
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );
   
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

#ifdef DEBUG
   printf("\nNumber of dynamic and user attributes : %d", nbDynUsrAtt );
#endif

   /* one more for "mark_user" attribute, if it is not present */

   maxAttrs = nbDynUsrAtt + nbAttrs + 1;

   /* allocate space for list of dynamic and user attributes */

   dynAtt = (struct ACrg_coll *)om$malloc( size = (sizeof( struct ACrg_coll ) *
                                                  (maxAttrs) ));

   if( dynAtt == NULL )
   {
      *msg = MSFAIL;
      status = OM_E_NODYNMEM;
      goto wrapup;
   }
  
   /* Get the list of attributes */

   status = om$send( msg = message ACrg_collect.AClist_attribute( msg, 
                                                                  maxAttrs,
                                                                  dynAtt,
                                                                  &nbDynUsrAtt),
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );
   
   as$status();

   if( !(status & *msg & 1) )
      goto wrapup;

   /* Add "mark_user" attribute if it does not already exist in the list */

   VDModAddAttr(  "mark_user",
                  dynAtt,
                  &nbDynUsrAtt,
                  AC_ATTRIB_DOUBLE,
                  0.0,
                  "",
                  maxAttrs,
                  VD_ADD_ATTR );

   /* 
    * Starting Index of the user attributes : the one next to 
    *                                         "mark_user" attribute;
    * number of dynamic attributes          : all dynamic attrs + "mark_user"
    */
       
   for( i = 0 ; i < nbDynUsrAtt ; i++ )
      if( !strcmp( dynAtt[i].name, "mark_user" ) )
      {
         startUsrIndex = i + 1;
         nbDynAtt = startUsrIndex;
         break;
      }

#ifdef DEBUG
   printf("\nStarting Index for user attributes : %d", startUsrIndex );
   printf("\nNumber of dynamic attributes : %d", nbDynAtt );
#endif

   for( i = 0 ; i < nbAttrs ; i++ )
   {
      /* 
       * if attribute exists as a dynamic or static attr, print message 
       * and continue with the next one
       */

      found = FALSE;

      for( j = 0 ; j < nbDynAtt ; j++ )

         if( !strcmp( dynAtt[j].name, att[i].name ) )
         {
            printf("\n\nCannot add attribute \"%s\" : ", att[i].name );
            printf("\n\tAlready exists as a dynamic attribute\n\n");
            sprintf( stsstr, "Dynamic attr \"%s\" already exists", att[i].name);
            UI_status( stsstr );
            found = TRUE;
            break;
         }

      if( found )
         continue;

      for( j = 0 ; j < nbStatAtt ; j++ )
         if( !strcmp( statAtt[j].name, att[i].name ) )
         {
            printf("\n\nCannot add attribute \"%s\" : ", att[i].name );
            printf("\n\tAlready exists as a static attribute\n\n");
            sprintf( stsstr, "Static attr \"%s\" already exists", att[i].name);
            UI_status( stsstr );
            found = TRUE;
            break;
         }

      if( found )
         continue;

      if( att[i].desc.type == VD_ATTRIB_DELETE )
      {
         /* delete the attribute */

         VDDelOneAttrib( dynAtt, &nbDynUsrAtt, att[i].name );
      }
      else
      {
         /* get the index of the attribute in the list, if present */

         found = VDgetAttrIndex( att[i].name, dynAtt, nbDynUsrAtt, &index );

         if( found )

            /* modify the attribute */

            dynAtt[index] = att[i];

         else
   
            /* add the attribute */

            dynAtt[nbDynUsrAtt++] = att[i];
        }

   }

   /* Set up the new list of attributes in the rg collector */

   status = om$send( msg = message ACrg_collect.ACset_list_attribute( msg,
                                                                    nbDynUsrAtt,
                                                                    dynAtt ),
                     targetid = dyn_box.objid,
                     targetos = dyn_box.osnum );
   as$status();

   /* update the foot collector too */

   status = om$send( msg = message ACrg_collect.ACset_list_attribute( msg,
                                                                    nbDynUsrAtt,
                                                                    dynAtt ),
                     targetid = dynBoxFoot.objid,
                     targetos = dynBoxFoot.osnum );
   as$status();

   /* execute foot to recompute dependencies of foot */

   obj.objid = my_id;
   obj.osnum = OM_Gw_current_OS;
   nd$wait_batch(	type	= GR_GEOM_POSTED,
			nb_obj	= 1,
/*
			l_object= &dynBoxFoot );
*/
			l_object= &obj );
   nd$exec_batch();

wrapup :

   if( statAtt )
      free( statAtt );

   if( dynAtt )
      free( dynAtt );

   return status;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDgetObjDef from VDSroot

  Abstract

        This method retrieves object specific attributes

  Arguments

     IGRlong            *msg             O       completion code
     VDobjDef           *myDef           O       Object attribute

  Status/Return Code
      OM_S_SUCCESS      if success


 -------------------------------------------------------------------------
-mo*/

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VD_I_ObjEquipment ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjDef */

/*----------------------------------------------------------------------------*/

end implementation VDequipment;

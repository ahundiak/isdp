#ifndef REpointer_h
#define REpointer_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSpointer. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

  EMS_ASobject_id            1
  EMS_ASobject_key           2
  EMS_ASkey_and_id           3
  EMS_ASobjid_tag           4
  EMS_ASobjid_name          5
  EMS_AStagkey_and_id        6

History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
*/


/* Begin pp 05/15/91 */

/* Type of the pointer object */

#define EMS_ASobject_id  1 /* Contains object id of the component which it is
                              pointing to */
/*
 * In this case the objid is stored in EMSassoc vla.
 *
 * OM_S_OBJID objid;
 */

#define EMS_ASobject_key 2 /* Contains key of the component which it is  
                              pointing to relative to the creator who is
                              a parent of the pointer */
/*
 * In this case only the key is stored in EMSassoc vla. This structure
 * is defined in EMSkey.h
 * struct EMSkey
 * {
 *   unsigned short chan_count;      
 *   unsigned short chan_index;     
 *   unsigned char  sub_item_type; 
 * };
 */

#define EMS_ASkey_and_id 3 /* Contains both key and object id */

/*
 * If both key and id are stored then the recomputation information of
 * the pointer object can be unpacked by typecasting to the following
 * structure. This is defined in EMSkey.h 

 struct EMSobjid_key
 {
  OM_S_OBJID objid;
  unsigned char key_info[];
 };
*/
#define   EMS_ASnoncount_key          4
#define   EMS_ASlong_key	     5

#endif

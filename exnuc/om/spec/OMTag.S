								/*+private*/
								/*+cldesc*/
class specification OMTag (4:1) of Root;


/*----------------------------------------------------------------------------
   Description:

   OMTag objects are used for the storage and maintenance of tag records.
   Tag records associate an object id with a unique 32-bit number called
   a tag.  Tags are unique within an object space.  These tag records
   are used in conjunction with connect records contained in OMTagCon
   objects (in other object spaces) to identify and maintain tagged 
   connections.

   Only one OMTag object can exist in an object space.  It will contain
   the tags for all tagged objects in that OS.  The OMTag is connected
   to the OSO on the "Group" channel.  An OMTag object will only 
   exist when there are tagged objects in an object space.
---------------------------------------------------------------------------*/   
								/*-cldesc*/
								/*+clrev*/
/*--------------------------------------------------------------------------
   Revisions:

   RME  4-April-1987   Initial release of this class.

--------------------------------------------------------------------------*/
   								/*-clrev*/

								/*+clincs*/
#include "OMtags.h"
								/*-clincs*/

								/*+clid*/
instance OMTag
{
   OMuint            next_tag;    /* Next available tag to use. */
   OMuint            num_tags;    /* Number of non-null tags in vla. */
   OMuint            h_free;      /* Index of head of hash free list.  (Only
                                     valid when OMTag object is in memory.) */
   int               next_index;  /* Next index in vla for a tag record. */
   OMuword           flags;       /* Indicates recycling tags and tag out
                                     of order. */   

   int  hash_block_size;  /*  Total number of hash entries allocated.  */

   variable OM_S_TAG_RECORD tag_rec[];   /* Array of tag records. */

   channel { (many_to_one) OMObjSpace;} to_OSO;  /* Connect me to OSO. */

};
								/*-clid*/

								/*+clmsg*/
message initialize(int flag);

message insert_tag(OM_S_OBJID objid; 
                   OMuint *p_tag;
                   OM_p_TAG_RECORD p_tag_rec );

message remove_tag(OM_S_OBJID objid);

message get_record_vla(OM_p_TAG_RECORD *pp_tag_rec; 
                       OMuint *p_count; 
                       OMuword *p_flags);

message set_up();

message rehash_objids();
								/*-clmsg*/

								/*+clover*/
override delete;
								/*-clover*/


end specification OMTag;
								/*-private*/

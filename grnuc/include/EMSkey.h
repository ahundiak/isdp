#ifndef EMSkey_include
#define EMSkey_include

/*
 * Moved this file to GRNUC since this is need by EMSpointerA and that
 * had to be moved.
 * pp 06/09/92
 */

/*
 * Defines follow:
 */

/*Possible types of sub-items on the sub-item channel*/
#define EMSkey_UNKNOWN          0
#define EMSkey_CONNECTOR        1
#define EMSkey_LOOP             2
#define EMSkey_PARTEDGE         3
#define EMSkey_EDGE             4
#define EMSkey_GRALOOP          5

/*
 * Structures follow:
 */

struct EMSkey
{
  unsigned short chan_count;      /*total sub-items on channel.     */
  unsigned short chan_index;      /*Index to the sub-item..         */
  unsigned char  sub_item_type;   /*type of this item (see above)   */
};

/*Notes:  above chan_count & chan_index are defined as unsigned short 
 *        since the maximim connections OM supports is 65535 (which is max size
 *        of an unsigned short). 
 */

#ifndef __DDP__
/* For support of oldfiles only, This structure should no longer be used. */
 struct EMSobjid_key
 {
  OM_S_OBJID objid;
  unsigned char key_info[1];
 };
#endif


#ifndef __DDP__

struct EMSnoncountkey {
  OM_S_OBJID objid;
  IGRshort item_type;
  IGRshort info_type;
  IGRshort size;
  char key[1];
};

struct EMStmp_key {
  IGRshort item_type;
  IGRshort info_type;
  IGRshort offset;
  char *key;
};

struct EMSlong_key {
  OM_S_OBJID objid;
  struct EMStmp_key noncount_st;
  unsigned char key_info[1];
};

#endif
/* These options are used during storage of ids and keys */

#define EMS_OPT_STORE_ID       0x1 
#define EMS_OPT_STORE_KEY      0x2 
#define EMS_OPT_CHECK_ACTIVE   0x4 
#define EMS_OPT_STORE_TAG      0x8 /* Get tag from id */
#define EMS_OPT_STORE_TAGKEY      0x10 

/* Type of associated information */
#define EMS_SEGMT_NONE	0
#define EMS_SEGMT_TAG	1
#define EMS_SEGMT_NAME	2

/* These options are used to manage storage of objects whose keys have
 * to be updated when the object space goes to sleep and also to keep
 * track of DPR nodes which have to be redone because they were undone
 * for the purpose of storing the key.
 */
#define EMS_OPT_ADD    0x1 /* Add to the list */
#define EMS_OPT_REMOVE 0x2 /* Remove from the list */

#define EMS_OPT_ID_FROM_KEY 0x1 /* Get id from key */
#define EMS_OPT_KEY_FROM_ID 0x2 /* Get key from id */

/* End pp 05/15/91 */

#endif


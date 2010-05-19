/* $Id: OMtags.h,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/exnuc / OMtags.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: OMtags.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef OM_D_TAGS
#define OM_D_TAGS 1

#define OM_TAG_HASHOBJID(objid) ((int)((objid) % (OM_Gw_tag_hashtable_size)))
#define OM_K_TAG_FREEHASH ((OMuint) -1)

struct OM_sd_tag_hash_entry
{
   OMuint                      next;   /*  Array index of collision.  */
   OMuint                      index;  /*  Index into tag record vla. */
};

typedef struct OM_sd_tag_hash_entry OM_S_TAG_HASHENT;
typedef struct OM_sd_tag_hash_entry *OM_p_TAG_HASHENT;

struct OM_sd_tag_record
{
   OMuint      tag;
   OM_S_OBJID  objid;
   OMuword     version;
};

typedef struct OM_sd_tag_record OM_S_TAG_RECORD;
typedef struct OM_sd_tag_record *OM_p_TAG_RECORD;

struct OM_sd_get_record_vla_args
{
   OM_p_TAG_RECORD *pp_tag_rec;
   OMuint          *p_count;
   OMuword         *p_flags;
};

typedef struct OM_sd_get_record_vla_args OM_S_GETRECVLA_ARGS;
typedef struct OM_sd_get_record_vla_args *OM_p_GETRECVLA_ARGS;


#define OM_K_MAXOBJECT_TAG ((OMuint) -1)

/*  Following are bit flags used in the OMTag object flag word.  */
 
#define OM_Tf_tags_unordered 0x1  /* Tags are not sorted in tag order. */
#define OM_Tf_recycling_tags 0x2  /* Tags are being recycled.          */
#define OM_Tf_vla_compressed 0x4  /* The vla of tag records has been
                                     compressed.  */

/*===========================*/
/*  TAG CONNECT DEFINITIONS  */
/*===========================*/

typedef struct OM_sd_tagcon_link *OM_p_TAGCON_LINK;

struct OM_sd_tagcon_link 
{
   OM_S_OBJID        objid;
   char              int_osname[OM_K_MAXINTOSNAME_LEN];
   OM_p_TAGCON_LINK  next;
};
typedef struct OM_sd_tagcon_link OM_S_TAGCON_LINK;

#define   OM_K_TAGEND    (OMuword)0xffff

#endif

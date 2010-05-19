/* $Id: OMTagCon.S,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/exnuc / OMTagCon.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: OMTagCon.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

								/*+private*/
								/*+cldesc*/
class specification OMTagCon (4:1) of Root;


/*----------------------------------------------------------------------------
   Description:

   OMTagCon objects maintain a list of records which describe tagged
   connections.  A tagged connection is always between objects in
   different object spaces.  The connection itself is maintained as
   an ISO connection.  However, the OMTagCon object stores enough
   information to re-establish this connection at a later time.
   (Presumably between a RO object space and a RW object space. That is,
   if a connection is made to a RO object space, the ISO information
   will be lost when that object space is deleted.  If that RO object
   space is loaded at a later time, other object spaces that contain
   OMTagCon objects can re-establish any tagged connections that exist
   between them.)

   Many different OMTagCon objects can exist in an object space.  In fact,
   one exists for each other object space that contains tagged connections
   to the object space containing the OMTagCon object.  All OMTagCon
   objects in an object space are connected to the OSO via the "Group"
   channel.  If no tagged connections exist with other object spaces,
   no OMTagCon objects will exist.
----------------------------------------------------------------------------*/
								/*-cldesc*/
								/*+clrev*/
/*----------------------------------------------------------------------------
   Revisions:

   RME 4-April-1987    Initial release of this class.

----------------------------------------------------------------------------*/
								/*-clrev*/

                                                                /*+clinc*/
#include "OMtags.h"
                                                                /*-clinc*/
								/*+clid*/
struct OM_sd_connect_record
{
   OM_S_OBJID     objid;       /* Object id of object in this OS.  */
   OMuint         tag;         /* Tag of object in other OS. */

   OM_S_CHANNUM   cnum;        /* Channel connected to in this OS. */
   OM_S_CHANNUM   other_cnum;  /* Channel connected to in the other OS. */

   OMuword        index;       /* Optional index on channel in this OS. */
   OMuword        other_index; /* Optional index on channel in the other OS. */

   OMuword        version;     /* Used to identify when the initial connection
                                  was made. */

   OMuword        flags;       /* Version mismatch or unresolved connection. */
   OMuword        next;        /* Index of next record or NULL. */
   OMuword        prev;        /* Index of previous record or NULL. */
};


instance OMTagCon
{
   OMuword first_tag;                   /* Start of tag list or OM_K_TAGEND  */
   OMuword first_free;                  /* Start of free list or OM_K_TAGEND */

   char    osname[OM_K_MAXINTOSNAME_LEN];  /* Internal OS name of the other
                                           object space which contains the
                                           tag records that correspond
                                           with my connect records. */
 
   OMuint  count;                       /* Number of active records in vla. */

   channel { (many_to_one) OMObjSpace; } to_OSO;
   variable struct OM_sd_connect_record  con_rec[];
};
								/*-clid*/
                                                                /*+clover*/
override delete, debug;
                                                                /*-clover*/
								/*+clmsg*/
message initialize ( OMuword other_os );

message set_up ();

message add ( OM_S_TAG_CON_INFO *info_str; OM_p_CHANNEL_LINK p_chan_link );

message remove ( OMuword vla_ndx );

message reconnect ( OM_p_TAG_RECORD p_tag_rec; OMuint count; OMuword flags );

message identify_yourself ( OMuword tag_osnum; OMuword *first_tag;
                            struct OM_sd_connect_record **p_con_rec );

message prep_write ();
								/*-clmsg*/

end specification OMTagCon;
								/*-private*/


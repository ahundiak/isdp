class	specification	OMISO (2:0) of Root;			/*+cldesc*/

/*
Class:		OMISO

  ISO objects are used to maintain connections between objects that have
  been constructed in different object spaces.

  For example an object a in OSx connected to object b in OSy:

				\
		OSx		\		OSy
				\
        --------      -------   \  -------      --------
	|object|      | ISO |   \  | ISO |	|object|
	|      |<---->| OSx |	\  | OSy |<---->|      |
	|  a   |      | to  |	\  | to  |      |  b   |
	|      |      | OSy |   \  | OSx |	|      |
	--------      -------	\  -------      --------
				\
				\

   Rather than connecting a directly to b, a is linked to  the ISO object
   in OSx that links OSx to OSy.  There is a corresponding ISO object
   (they always and must exist in pairs) in OSy that links OSy to OSx.
   Each ISO pair links all connections between their respective object
   spaces.  In this way the connection information can be maintained 
   when either or both of the object spaces are not loaded.  Also
   when an object in one space is disconnect from to an 
   object in a space that is not currently loaded the ISO entry for
   that connection is marked.  At some future time when both object 
   spaces are loaded at the same time this mark will be noticed
   and the disconnect will be completed.

   Variable length arrays in the ISO expand and contract as
   objects are connected and disconnected.  If no connections exist
   between two Objects spaces then the ISO object pairs will not 
   exist.  They spring into being when the first ISO type connection is
   made and are deleted when all connections between the respective
   object spaces have been disconnected.

   Array entry index n in each ISO object of a pair supports the same 
   connection.  Thus if object a points to entry 5 in its OSx to OSy ISO
   then object b will also point to entry 5 in its OSy to OSx ISO.
*/								/*-cldesc*/
								/*+clrev*/
/*			
Author:		kerry kilbride
Creation Date:	1986
Change History:	

cgp001	23-apr-1986	OM3.2	Add messages: resolve_yourself & 
				dissolve_yourself

cgp002	29-apr-1986	OM3.2	Add new flag (ISO_to_transeint) and
				change resolve_yourself message parameter

kek001   1-jul-1986	OM4.0   OM 4.0 changes.
*/								/*-clrev*/


#include 	"OMminimum.h"

extern OMuword OM_Gw_defISO_size;
extern OMuword OM_Gw_defISO_ext;

								/*+clid*/
/* ---- actual #defines are in OMrelation.h ---------------	
   ---- definitions for w_ISO_flags -----------
   ISO_no_target	  1	 target OS not loaded -- note that
				 in this case osnum and S_target_iso
				 will both be null

   ISO_to_transient	  2	target OS is transient. Set at write OS
   				time.

   ---- definitions for ISO_data.w_flags ------

   ISO_disconnected	  1	 this os obj has disconnected
   ISO_to_object	  2	 s_objid points to object
   ISO_logical_disconnect 4      flags disconnect of RO to RW on RO side
   ISO_logical_connect    8      flags connect of RO to RW on RW side

-------------------------------------------------------- */

struct ISO_data {
   OMuword	w_flags;	/* status of entry - will be zero */
				/* if entry not in use */
   OM_S_CHANNUM	chan;		/* this os obj channel number */
   union {
     int	i_next;		/* index of next available entry */
     OM_S_OBJID	s_objid;	/* this os object */
   }  iso_u;
};
typedef	struct	ISO_data	S_ISO_DATA;

instance	OMISO
{
   OMuword	osnum;		/* target OS number */
   OMuword	w_ISO_flags;	/* status of this ISO */
   OMuword	w_dcount;	/* number of dangles - ie pending 
				   deleted and disconnected */
   OMuword	w_dummy;	/* alignment variable */
   OM_S_OBJID	S_target_iso;   /* for ISO in target OS */
   int		i_first;	/* index of first available entry */
   variable struct ISO_data iso_d []; /* default size is runtime param */
};								/*-clid*/

								/*+clover*/
override	debug, delete;
								/*-clover*/
								/*+clmsg*/
message		reset_OSnumber		();
message		set_OSnumber		(OMuword target_OS);
message		unlink_entry 		(OMuword entry_index);
message		unlink_all		();
message		resolve_yourself 	(char *target_OSintname);
message		dissolve_yourself 	(OMuword target_OS);
message		get_index_oid		(OMuword index; OM_S_OBJID *oid;
  					 OM_S_CHANNUM *channum);
message		fixup_for_write		();
message		do_dangles		(OMuword target_OS; int SendToPartner);
message		is_readonly();
      								/*-clmsg*/

end	specification	OMISO;

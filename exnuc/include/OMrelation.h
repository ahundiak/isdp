/*
---------------------------------------------------------------------------

	Name:			OMrelation.h
	Author:			Kerry Kilbride
	Creation Date:		20-jun-1986
	Operating System(s):	Unix SYSV, v2
	Abstract:

	Defines structure used by connect/disconnect/move/copy.
	Also defines ISO flag values.

	Revision History:

---------------------------------------------------------------------------
*/

#ifndef	OM_D_RELATION
#define	OM_D_RELATION	1
#endif

/*  -------------------------------------------------------
  Data related to one side of a connect/disconnect request 
  will be kept in OM_sd_connect_side.  All fields in this 
  struct are related to a single object. This struct will be
  passed around by pointer to related subroutines. 
----------------------------------------------------------- */

struct OM_sd_connect_side {
	/* fields specified explicitly by caller */
  OMuword		osnum;		/* this object's OS number */
  OM_S_OBJID		objid;		/* this object */
  int			relidx;		/* ordered index for this chan */
	/* fields derived immediately by build_side */
  OM_S_RIP		rip;		/* derived from osnum, s_objid */
  OM_p_CHANNEL_HDR     *pp_chan;	/* derived from chansel */
  OM_S_CHANNUM		channum;	/* derived from chansel */
  OM_p_CHANNEL_DEFN	chdef;		/* derived from chansel */
  OM_p_CLASSDEF		p_cld;		/* derived from instance */
  int                  *p_chandata;     /* derived from chansel */
  OM_S_BIG_TAIL         tail;           /* derived from chansel */
	/* fields derived when target known is osnums != */
  OM_S_OBJID		iso_objid;	/* iso in this OS between this 
					   object and target object */
	/* fields set when known */
  OM_p_CHANNEL_LINK     p_chlink;	/* channel link to target object
					   or iso */
  OMbyte		chused;		/* set if p_chlink is in use
					   else reset */
  OMuword		iso_index;	/* ISO index for this connection */
  int			status;		/* used for info status passback */
};

typedef struct OM_sd_connect_side *OM_p_CONNECT_SIDE;
typedef struct OM_sd_connect_side  OM_S_CONNECT_SIDE;

/* --- definitions for ISO instance element ISO_data.w_flags --- */

#define ISO_disconnected       1	/* this os obj has disconnected   */
#define ISO_to_object          2        /* s_objid points to object       */
#define ISO_logical_disconnect 4        /* flags disconnect on RO side of */
                                        /* RW to RO OS connection         */
#define ISO_logical_connect    8        /* flags connect on RW side of    */
                                        /* RW to RO OS connection         */

/* --- definitions for ISO instance element w_ISO_flags --- */

#define ISO_no_target	       1	/* target OS not loaded           */
#define ISO_to_transient       2	/* taregt ISO was a transient     */
#define ISO_to_read_only       4        /* target OS is read only         */

#define OM_K_OSNOTHERE  -1 /* means OS has not been loaded */

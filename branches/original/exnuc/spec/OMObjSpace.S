class	specification	OMObjSpace (4:0) of Root;


#include "OMOSfilehdr.h"

/* Revision:

cgp001	feb-12-1986	Make a subclass of OMquery

cgp002	11-jun-1986	OM4.0 changes: no query,  and draw all OSD
			stuff into OSO

rme001  11-aug-1986     add NOD messages.
*/

#define OM_K_NOOIDAVAIL	(OMuint) -1

extern	OM_S_OBJID			OM_GO_CurrentMOSD;
extern	OMuint				*OM_Gp_1stOSAvail;
extern	OMuword				OM_Gw_maxOSnumber;
extern	OM_p_OSD			*OM_GA_OSOs[];

struct ISOd_data {
  char		s_int_os_name[OM_K_MAXINTOSNAME_LEN];
		/* s_int_os_name[0] == '\0' when entry not in use */
  union OM_sd_iso_u {
	int 	i_next;		/* next available entry */
	OM_S_OBJID s_objid;	/* of related ISO object */
  } iso_u;
};


instance 	OMObjSpace
{
  char			CreTimeDate[16];/* creation time and date */
  char			TimeDate[16];	/* time and date of last write
					   in a string of format:
					   "hhmmmmddyyyy" plus 
					   terminating NULL plus pad */
  OM_p_OS_FILEHDR	p_filehdr;	/* pointer to file header */
  OM_S_OSD		OSD;		/* the OS descriptor part of OSO */
  int			OS_HoleCount;	/* count of holes in file */
  variable  OM_S_OSHOLE OS_holes[];     /* reverse ordered VLA of holes in
					   filed OS (in file) */

  int		  	FirstISO;	/* index first empty iso_d */
  variable struct ISOd_data iso_d []; 	/* default size & ext is a */

  variable OM_S_GROUP_EXTENT freeoids[0]; /* oids belonging to no group */

  channel { (one_to_many,
	     initial=10, increment=20) OMOSCO; }	    to_OSCOs;
  channel { (one_to_many, abs_ordered,
	     initial=10, increment=20) OMCluster;}   to_ClusDscs;
  channel { (one_to_many,
	     initial=1, increment=20) OMGroup, OMSupGroup, OMTag, OMTagCon; }  to_GrpDscs;
  channel { (one_to_many,
	     initial=1, increment=20) } to_NamObjDir;
};

override	delete;

message		change_name	(char *name; OM_e_OVRWRT_FLG overwrite);

message 	pass 		(OM_S_CLASSLIST *classlist;
				 OM_E_WRT_FLAG wrt_flag;
				 OM_S_MESSAGE *msg);

message         get_status      (OM_p_OSSTATUS p_stat);

message		init_OMObjSpace	();
message		execute		();
message		cleanup		();

message		translate_group_name (char *name; OM_p_OBJID p_oid);

message		dissolve_ISOs	();
message		resolve_ISOs	();
message		fixup_for_write ();
message		fix_osd 	();

message		find_iso 	(OMuword t_osn;
				 OM_p_OBJID p_oid);
message		get_iso		(OMuword t_osn;
				 OM_p_OBJID p_oid);
message		make_iso_entry  (OM_S_OBJID iso_oid;
				 OMuword    tar_osn);
message		print_isodir	(int flg);
message		remove_iso	(OM_S_OBJID i_oid);
message		add_class	(char *name;
				 OMuword classid);
message         update_isodir   ( char *old_int_name, *new_int_name );


end 	specification 	OMObjSpace;

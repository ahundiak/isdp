class 	specification 	OMMOSD (4:0) of Root;


#include	"OMMOSD.h"

#define METHODS_40 4

struct OM_sd_mosd_entry {
	OMuword	   OS_number;		/* i.e. index into OM_GA_OSDs ..  */
	OM_S_OBJID OS_oid;		/* oid; if NULL_OBJID, slot is avail*/
	char	   OS_name[OM_K_MAXOSNAME_LEN];	/* name */
	};

instance OMMOSD
{
  OMuword				w_number_entries;  /* size of vla */
  OMuword				w_number_used;     /* used entries */
  variable struct OM_sd_mosd_entry 	st_oslist[2];  /*mosdos + transos*/
};


override	delete;

message get_OS_list	(int size; int *count; 
			 OMuword *OSnumbers; OM_S_OBJID *OSoids);
message MOSD_init	();
message pass_thru 	( OM_S_CLASSLIST *classlist; 
			 OM_E_WRT_FLAG wrt_flag;
			 OM_S_MESSAGE *msg );

message add_entry 	(OMuint osnum; OM_S_OBJID oid; char *s_name );
message	delete_entry	(OMuint osnum);

message modified_OS_wrt();
message	modify_entry	(char *s_name; OMuint modtype; int modvalue);
message pass 		(char *p_argstruct );
message	save_envr	(char *s_filename );
message	restore_envr	(char *s_filename );
message	translate_entry	(char *s_name; uword *w_resultOS; 
			 OM_p_OBJID result_objid );


end 	specification 	OMMOSD;

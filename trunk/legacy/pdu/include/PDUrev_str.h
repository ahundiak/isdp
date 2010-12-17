#include        "MEMstruct.h"

/* Existing/New Assembly Structure */

struct PDUrev_assy {
	int	ex_level;
	char	*ex_catalog;
	char	*ex_partid;
	char	*ex_revision;
	char	*ex_desc;
	char	*ex_cofilename;
	char	*ex_parttype;
	int 	p_level;
	int	p_pchildno;
	int	p_childno;
	char	*p_attached;
	char	*p_quantity;
	char	*p_usageid;
	char	*p_tagno;
	char	*p_alttagno;
	char	*p_incbom;
	char	*p_incstr;
	char	*p_explode;
	char	*p_history;
	int	n_catalogno;
	int	n_itemno;
	int	new_level;
	char	*new_catalog;
	char	*new_partid;
	char	*new_revision;
	char	*new_desc;
	char	*new_cofilename;
	char	*new_cifilename;
	char	*new_parttype;
	char	*new_usageid;
	char	delete[2];		/* delete part from structure - N */
	char	ems_reffile[2];		/* EMS reference file - default = N */
	char	add[2];			/* add part to structure - N */
	char	display[2];	/* part is not displayed on the form - Y */
	char	add_db[2];		/* add part to database - default = N */
	int	mcf_row;		/* row marker for the MCF - def = -1 */
        int     dyn_attr_count;
        char    **dyn_attr_names;
        char    **dyn_attr_values;
	struct	PDUattr_data *ex_attr_data;
	struct	PDUattr_data *new_attr_data;
	struct  PDUrev_assy  *next;
        };

/* Attribute Structure */

struct PDUattr_data {
	MEMptr	attr_bufr;
	MEMptr	data_bufr;
	MEMptr	file_bufr;
	MEMptr	list_bufr;
	MEMptr	func_bufr;
        };

struct PDUparts_list {
	char	*catalog;
	char	*partid;
	char	*revision;
	char	*description;
	char	*parttype;
	char	*cofilename;
	char	*cifilename;
        struct  PDUparts_list *next;
        };

struct PDUassy_parts_list {
	int	p_level;
	int	p_childno;
	int	p_pchildno;
	char	*catalog;
	char	*partid;
	char	*revision;
        struct  PDUassy_parts_list *next;
        };

struct PDUfile_list {
	char 	*cofilename;
	struct PDUfile_list *next;
	};

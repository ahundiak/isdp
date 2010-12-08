/***************************************************
 * Product Data Manager data structure definitions *
 ***************************************************/

#ifndef PDMstr
#define PDMstr 1

#include	"PDUextdef.h"
#include	"MEMstruct.h"

struct PDUrefresh
	{
	char		*username;
        long		user_id;
	char		*rev_project;
        char            *cat_path;
	char		*rev_catalog;
	char		*rev_partid;
        char            *rev_parttype; /* added for parametrics support */
	char		*rev_revision;
	char		*rev_filename;
	char		*rev_description;
	char		*act_project;
	char		*act_catalog;
	char		*act_partid;
        char            *act_parttype; /* added for parametrics support */
	char		*act_revision;
	char		*act_filename;
	char		*act_description;
        char            *new_project;
        char            *new_catalog;
        char            *new_partid;
        char            *new_revision;
        char            *new_parttype;
        char            *new_description;
	char		*search_criteria;
	char		*sort_criteria;
	char 		*loc_format_name;
	char		*loc_search_name;
	char  		*loc_sort_name;
	char		*cat_format_name;
	char		*cat_search_name;
	char		*cat_sort_name;		
	char		*bom_display_name;
	char		*bom_print_name;	
	char		*view;

	int		line_number;
	char		*serial_number;
	int		command;
	long		status;

	char		*part_list;
	char		*bom_list;
	char		*attach_list;
	char		*aux_ptr1;
	char		*aux_ptr2;
        char            *dynamic_part_list; /* list of all dynamic parts */
        char            *dynamic_value_list; /* list of values of parameters */
	char		*parm_part_list;
        char		*parm_value_list;
 
        char		*wrkst_username;
        char		*wrkst_passwd;
        char		*wrkst_cwd;
        char		*wrkst_node;
	};
  	
#endif

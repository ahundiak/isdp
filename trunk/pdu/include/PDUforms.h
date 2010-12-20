/***************************************************
 * Product Data Manager data structure definitions *
 ***************************************************/

#include "FI.h"

struct PDUforms
	{
	Form		login_form_id;
	Form		local_files_form_id;
        Form            sort_form_id; 
	Form		part_operations_form_id;
        Form            seed_form_form_id;
	Form		define_assy_form_id;
        Form            single_list_form_id;
        Form            mcf_list_form_id;
        Form            cat_name_form_id;
        Form            cat_attr_form_id;
        Form            design_form_id;
	Form		dynamic_attr_form_id;
	Form		replace_part_form_id;
	Form		part_list_form_id;
	Form		topdown_form_id;
        Form            report_form_id;
        Form            copy_file_form_id;
        Form            design_options_form_id;
        Form            sort_options_form_id;
        Form            bom_contents_form_id;
        Form            file_list_form_id;
        Form            parts_list_form_id;
        Form            parametric_catalog_form_id;
        Form            change_symbology_form_id;
        Form            parametric_parts_form_id;
        Form            design_parts_form_id;
        Form            part_file_list_form_id;
        Form            cancel_list_form_id;
        Form            where_used_form_id;
        Form            define_lib_form_id;
        Form            origin_list_form_id;
        Form            class_cat_form_id;
        Form            assembly_display_form_id;
        Form            ex_file_form_id;
        Form            flag_form_id;
        Form            move_state_form_id;
        Form            search_format_form_id;
        Form            rev_assy_form_id;
        Form            attr_value_form_id;
        Form            active_part_form_id;
	} ;

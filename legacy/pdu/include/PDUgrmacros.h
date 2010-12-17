#include "gr.h"
/*******************************************************************************
PDUgrmacros.h

*******************************************************************************/
/******************************************************************************

Macro:

     pdm$create_bom

     This macro creates a BOM for a part.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     status              *int                O   Status.
     catalog_name        *char               I   Catalog name.
     part_id             *char               I   Part name.
     revision            *char               I   Part's revision.

Sample Invocation:

     int   status;
     char  *catalog;
     char  *part_id;
     char  *part_rev;

     pdm$create_bom(status = &status,
                 catalog_name	   = catalog,
		 part_id           = part_id,
		 revision	   = part_rev
               );

Return Status:

	Invalid Catalog 
	Invalid Part 
	Invalid Revision
        Part not an Assembly
        Successful Completion

******************************************************************************/
#omdef pdm$create_bom(  status,
			catalog_name,
			part_id,
			revision
		     );

	PDUprepare_create_bom(status,
			     catalog_name,
			     part_id,
			     revision
			     );

#endomdef

/******************************************************************************

Macro:

     pdm$deactivate_part

     This macro deactivates a part.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     status              int *              O    Status 
     save_flag           int                I    0 - do not save active file
                                                 1 - do save active file 
                                                 1 is default

Sample Invocation:

     pdm$deactivate_part(&status,
                      save_flag = 1
                      );

Return Status:

	Invalid Catalog 
	Invalid Part 
	Invalid Revision
        Successful Completion

******************************************************************************/
#omdef pdm$deactivate_part(status,
                          save_flag = 1
			  );

	PDUprepare_deactivate_part(status,
                                  save_flag
			          );

#endomdef

/******************************************************************************

Macro:

     pdm$activate_part

     This macro activates a part.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     status              *int                O   Return status.
     catalog_name        *char               I   Catalog name.
     part_id             *char               I   Part name.
     revision            *char               I   Part's revision.
     file_name           *char               I   Filename wanting to activate.

Sample Invocation:

     int   ret_status;
     char  *catalog;
     char  *part_id;
     char  *part_rev;
     char  *filename;

     pdm$activate_part(
                 status            = &ret_status,
                 catalog_name	   = catalog,
		 part_id           = part_id,
		 revision	   = part_rev,
		 file_name	   = filename
               );

Return Status:

	Invalid Catalog 
	Invalid Part 
	Invalid Revision
        Successful Completion

******************************************************************************/
#omdef pdm$activate_part(status,
			catalog_name,
			part_id,
			revision,
			file_name);

	PDUprepare_activate_part(status,
			catalog_name,
			part_id,
			revision,
			file_name);

#endomdef
/******************************************************************************

Macro:

     pdm$create_catalog

     This macro creates a catalog.

Arguments:

     ARGUMENT            DATA TYPE                I/O  DESCRIPTION
     status              *int                      O   Return status.
     catalog_name        *char                     I   Catalog name.
     catalog_descr       *char                     I   Catalog description.
     acl_name            *char                     I   Catalog ACL. Defaulted to
                                                       NFM_CATALOG_ACL
     template_cat        *char                     I   Template Catalog.
     static_attr         *struct PDUattribute_info I   Static Attributes to Add
     dynamic_attr        *struct PDUattribute_info I   Dynamic Attributes to Add

Note: struct PDUattribute_info is defined in PDUnode.h

Sample Invocation:

     int   ret_status;
     char  *catalog;
     char  *description;
     char  *old_catalog;

     pdm$create_catalog(
                 status            = &ret_status,
                 catalog_name	   = catalog,
		 catalog_descr     = description
                 template_cat      = old_catalog;
               );

Return Status:

	Catalog already exists.
        Invalid ACL.
        Invalid Attriubte.
        Invalid Datatype.
        Successful Completion

******************************************************************************/
#omdef pdm$create_catalog(status,
			catalog_name,
			catalog_descr = NULL,
                        acl_name = "NFM_CATALOG_ACL",
                        template_cat = NULL,
                        static_attr = NULL,
                        dynamic_attr = NULL);

	PDUprepare_create_catalog(status,
			catalog_name,
			catalog_descr, acl_name,
                        template_cat, static_attr,dynamic_attr);

#endomdef
/******************************************************************************

Macro:

     pdm$where_used

     This macro creates a where used list for a part.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     status              *int                O   Return status.
     catalog_name        *char               I   Catalog name.
     part_id             *char               I   Part Name
     revision            *char               I   Part revision
     report_name         *char               I   Report Name 
     filename            char[51]            I   Filename for report
     display             int                 I   0-Don't display report. default
                                                 1-Display report
Sample Invocation:

     int   ret_status;
     char  *catalog;
     char  *part;
     char  *rev;
     char  *report;
     char  file[51];

     pdm$where_used(
                 status            = &ret_status,
                 catalog_name	   = catalog,
		 part_id           = part,
                 revision          = rev
                 report_name       = report
                 filename          = file
               );

Return Status:

	Invalid Catalog 
	Invalid Part 
	Invalid Revision
        Invalid Report
        Invalid Filename
        Successful Completion

******************************************************************************/
#omdef pdm$where_used(status,
			catalog_name,
			part_id,
                        revision,
                        report_name,
                        filename = "",
                        display = 0);

	PDUprepare_where_used(status,
			catalog_name,
                        part_id, 
                        revision,
                        report_name,
                        filename,
                        display);

#endomdef

/******************************************************************************

Macro:

     pdm$delete_occurrence

     This macro deletes a part occurrence in the active assembly. This macro 
     does not delete the part definition from the database.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     lw_status           *long               O   Status.
     spr_mod_env         *struct GRmd_env    I   Module information
     spr_part            *struct GRid        I   Object ID of part to be deleted

Sample Invocation:

     long  status;
     struct *Grid part;

     pdm$delete_occurrence(lw_status = &status,
                           spr_part = part);

Return Status:

      PDM_E_BAD_OBJID
      PDM_E_NULL_OBJID
      PDM_E_DELETE_PARAMETRIC_PART
      PDM_E_DETACH_MACRO_LIB
      PDM_E_INVALID_PART_POINTER
      PDM_S_SUCCESS
      
******************************************************************************/
#omdef pdm$delete_occurrence(lw_status,
                             spr_mod_env = NULL,
                             spr_part);

	pdmoDeletePartOccurrence(lw_status,
                                 spr_mod_env,
                                 spr_part);

#endomdef

/******************************************************************************

Macro:

     pdm$place_part

     This macro places a part occurrence in the active assembly. 

Arguments:

Argument       Data Type      I/O  Description
status         *long          O    Return status
part           *struct GRid   O    object ID of placed part
n_catalogname  *char          I    catalog name
n_itemname     *char          I    part number
n_itemrev      *char          I    part revision
n_cofilename   *char          I    file name
p_usageid      *char          I    part usage identification
p_viewname     *char          I    graphic view name
p_quantity     double         I    part quantity
p_explode      *char          I    explode in BOM (Y or N)
p_attach       *char          I    attach file (Y or N)
p_alttagno     *char          I    unique alternate tag number
p_incstr       *char          I    background part (Y or N)
p_incbom       *char          I    include in BOM (Y or N)
dyn_count      int            I    dynamic attribute count
dyn_names      **char         I    dynamic attribute name array
dyn_values     **char         I    dynamic attribute value array
dynloc_count   int            I    dynamic locate input count
dynloc_names   **char         I    dynamic locate input names
dynloc_id      *struct GRid   I    dynamic locate input object ID
origin         double[3]      I    position by three point origin point
x_point        double[3]      I    position by three point x-axis point
y_point        double[3]      I    position by three point y-axis point
position_cs    *struct GRid   I    position by coordinate system

Sample Invocation:

     struct GRid *part = NULL;

     pdm$place_part(status = &status, part = &part, n_catalogname = "test_api", 
                    n_itemname = "api_part1", n_itemrev = "a");

Return Status:

PDM_S_SUCCESS
PDM_E_CAT_NULL
PDM_E_PART_NULL
PDM_E_REV_NULL
PDM_E_CAT_NOT_FOUND
PDM_E_PART_NOT_FOUND
PDM_E_PARTREV_NOT_FOUND
PDM_E_BAD_DYNLOC
PDM_E_BAD_DYNATTR
PDM_S_SUCCESS
PDM_E_DYN_TRIP
PDM_E_DYN_LOC_TRIP
PDM_E_BAD_DYN_LOC_ERROR
PDM_E_DUPLICATE_USAGEID
PDM_E_LENGTH_USAGEID
PDM_E_VIEWNAME_NOT_EXIST
PDM_E_INVALID VALUE
PDM_E_BAD_POSITION
PDM_E_DUP_ALTTAGNO
PDM_E_PLACE_PART
PDM_E_PLACE_PARAMETRIC_PART
      
******************************************************************************/
#omdef pdm$place_part(status,
                      part,
                      n_catalogname, 
                      n_itemname,
                      n_itemrev,
                      n_cofilename = NULL,
                      p_usageid = NULL,
                      p_viewname = NULL,
                      p_quantity = 1.0,
                      p_explode = NULL,
                      p_attach = NULL,
                      p_alttagno = NULL,
                      p_incstr = NULL,
                      p_incbom = NULL,
                      dyn_count = 0,
                      dyn_names = NULL,
                      dyn_values = NULL, 
                      dynloc_count = 0,
                      dynloc_names = NULL,
                      dynloc_id = NULL,
                      origin = NULL,
                      x_point = NULL,
                      y_point = NULL,
                      position_cs = NULL
                      );
                             
                             

	pdmoPlacePart(status,
                      NULL,
                      part,
                      n_catalogname, 
                      n_itemname, 
                      n_itemrev,
                      n_cofilename,
                      p_usageid,
                      p_viewname,
                      p_quantity,
                      p_explode,
                      p_attach,
                      p_alttagno,
                      p_incstr,
                      p_incbom,
                      dyn_count,
                      dyn_names,
                      dyn_values,
                      dynloc_count,
                      dynloc_names,
                      dynloc_id,
                      origin,
                      x_point,
                      y_point,
                      position_cs
                      );
#endomdef

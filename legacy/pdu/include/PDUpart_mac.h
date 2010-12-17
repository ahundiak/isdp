/******************************************************************************
Macro:

     pdm$add_part

     This macro allows the user to add a part to a catalog.

Arguments:

     ARGUMENT            DATA TYPE                I/O  DESCRIPTION
     status              *int                      O   Return status.
     catalog             *char                     I   Catalog Name.
     partid              *char                     I   Part Number.
     revision            *char                     I   Part Revision.
     parttype            *char                     I   Part Type.
     description         *char                     I   Part Description.
     acl_name            *char                     I   ACL Name
     stg_name            *char                     I   Checked In Storage Name
     attrs               *struct PDUattribute_info I   Attributes to Add
     files               *struct file_info         I   Files to Add

Note: struct attribute_info is defined in PDUmac_struc.h
      struct file_info is defined in PDUmac_struc.h

Sample Invocation:

     int   return_status;
     char *catalog;
     char *part;
     char *rev;
     char *type;
     char *desc;
     char *acl_name;
     char *stg_name;
     struct attribute_info *attr_list;
     struct file_info      *file_list;

     pdm$add_part(
                  status     = &return_status,
                  catalog    = catalog,
                  partid     = part,
                  revision   = rev,
                  parttype   = type,
                  description= desc,
                  acl_name   = acl_name,
                  stg_name   = stg_name,
                  attrs      = attr_list,
                  files      = file_list
                 );

Return Status:

     PDM_E_BAD_DATA                          Bad Data
     PDM_E_INVALID_INPUT                     Invalid input
     PDM_E_IDENTIFER_TOO_LONG                Identifier too long
     PDM_E_CAT_NOT_FOUND                     Catalog does not exist
     PDM_E_PART_EXISTS                       Part already exist
     PDM_E_PART_FIELD_BLANK                  A Part Must Be Specified
     PDM_E_REV_FIELD_BLANK                   A Revision Must Be Specified
     PDM_E_INVALID_PART_TYPE                 Invalid Part Type
     PDM_E_ADD_ITEM                          Could not add part to catalog
     PDM_S_SUCCESS                           Successful Completion

******************************************************************************/
#omdef pdm$add_part(status,
                    catalog,
                    partid,
                    revision,
                    parttype = NULL,
                    description = NULL,
                    acl_name = "PDM_PART_ACL",
                    stg_name = "NFMFILES",
                    attrs = NULL,
                    files = NULL
                    );

       PDUm_add_part(status,
                     catalog,
                     partid,
                     revision,
                     parttype,
                     description,
                     acl_name,
                     stg_name,
                     attrs,
                     files
                     );

#endomdef
/******************************************************************************
Macro:

     pdm$chg_part

     This macro allows the user to change an existing part.  Files may
     be added or changed.

Arguments:

     ARGUMENT            DATA TYPE                I/O  DESCRIPTION
     status              *int                      O   Return status
     catalog             *char                     I   Catalog Name
     partid              *char                     I   Part Number
     revision            *char                     I   Part Revision
     parttype            *char                     I   Part Type
     description         *char                     I   Part Description
     acl_name            *char                     I   ACL Name
     stg_name            *char                     I   Checked In Storage Name
     attrs               *struct attribute_info    I   Attributes to Change
     add_files           *struct file_info         I   Files to Add
     chg_files           *struct chg_file_info     I   Files to Change

Note: struct attribute_info is defined in PDUmac_str.h
      struct file_info is defined in PDUmac_str.h
      struct chg_file_info is defined in PDUmac_str.h

Sample Invocation:

     int   return_status;
     char *catalog;
     char *part;
     char *rev;
     char *type;
     char *desc;
     char *acl_name;
     char *stg_name;
     struct attribute_info *attr_list;
     struct file_info      *add_list;

     pdm$chg_part(
                  status     = &return_status,
                  catalog    = catalog,
                  partid     = part,
                  revision   = rev,
                  parttype   = type,
                  description= desc,
                  acl_name   = acl_name,
                  stg_name   = stg_name,
		  attrs      = attr_list,
                  add_files  = add_list,
                  chg_files  = NULL
                 );

Return Status:

     PDM_E_BAD_DATA                          Bad Data
     PDM_E_INVALID_INPUT                     Invalid input
     PDM_E_IDENTIFIER_TOO_LONG               Identifier too long
     PDM_E_CAT_NOT_FOUND                     Catalog does not exist
     PDM_E_PART_NOT_FOUND                    Part does not exist
     PDM_E_PART_FIELD_BLANK                  A Part Must Be Specified
     PDM_E_REV_FIELD_BLANK                   A Revision Must Be Specified
     PDM_E_INVALID_PART_TYPE                 Invalid Part Type
     PDM_E_ADD_ITEM                          Could not add part to catalog
     PDM_S_SUCCESS                           Successful Completion

******************************************************************************/
#omdef pdm$chg_part(status,
                    catalog,
                    partid,
                    revision,
                    parttype = NULL,
                    description = NULL,
                    acl_name = "PDM_PART_ACL",
                    stg_name = "NFMFILES",
                    attrs = NULL,
                    add_files = NULL,
                    chg_files = NULL
                    );

       PDUm_chg_part(status,
                     catalog,
                     partid,
                     revision,
                     parttype,
                     description,
                     acl_name,
                     stg_name,
                     attrs,
                     add_files,
                     chg_files
                     );

#endomdef
/******************************************************************************
Macro:

     pdm$review_pt

     This macro facilitates the reviewing of a part from a specific catalog.

Arguments:

     ARGUMENT            DATA TYPE                 I/O  DESCRIPTION
     status              *int                       O   Return status.
     catalog             *char                      I   Catalog Name.
     part_id             *char                      I   Part Number.
     part_rev            *char                      I   Part Revision.
     attrs               **struct PDUattribute_info O   Attributes to Review
     files               **struct file_info         O   Files to Review

Note: struct PDUattribute_info is defined in PDUmac_struc.h
      struct file_info is defined in PDUmac_struc.h

Sample Invocation:

     int   return_status;
     char *catalog;
     char *part_id;
     char *rev;

     pdm$review_pt(
                  status     = &return_status,
                  catalog    = catalog,
                  part_id    = part_id,
                  part_rev   = rev
                 );

Return Status:

     PDM_E_BAD_DATA                         Bad Data
     PDM_E_INVALID_INPUT                    Invalid input
     PDM_E_IDENTIFIER TOO_LONG              Identifier too long
     PDM_E_CAT_NOT_FOUND                    Catalog does not exist
     PDM_E_PART_EXISTS                      Part already exist
     PDM_E_PART_FIELD_BLANK                 A Part Must Be Specified
     PDM_E_REV_FIELD_BLANK                  A Revision Must Be Specified
     PDM_S_SUCCESS                          Successful Completion

******************************************************************************/
#omdef pdm$review_pt(status,
                    catalog,
                    part_id,
                    part_rev,
                    attrs = NULL,
                    files = NULL
                    );

       PDUm_review_pt(status,
                     catalog,
                     part_id,
                     part_rev,
                     attrs,
                     files
                     );

#endomdef

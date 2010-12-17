/******************************************************************************

Macro:

     pdm$load_attribute_structure

     This macro loads attribute information into a structure of type
     PDUattribute_info.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status.
     attribute           *char                       I   Attribute name.
     datatype            *char                       I   Datatype of attribute.
     synonym             *char                       I   Synonymn of attribute
     value               *char                       I   Value of attribute
     attr_list           struct PDU_attribute_info ** I/O List of attribute
                                                     structure.
Sample Invocation:

     int   ret_status;
     char  *atribute;
     char  *datatype;
     char  *synonym;
     char  *value;
     struct PDUattribute_info *user_attr;

     pdm$load_attribute_structure(
                 status            = &ret_status,
                 attribute         = attribute,
                 datatype          = datatype,
                 synonym           = synonym,
                 value             = value
                 attr_list         = &user_attr;
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$load_attribute_structure(status,
                        attribute = NULL,
                        datatype = NULL,
                       synonym = NULL,
                        value = NULL,
                        attr_list);

        PDUprepare_load_attribute_structure(status,
                        attribute,
                        datatype,
                        synonym,
                        value,
                        attr_list);

#endomdef
/******************************************************************************

Macro:

     pdm$free_attribute_structure

     This macro frees a linklist of type PDUattribute_info.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status.
     attr_list           struct PDU_attribute_info ** I/O List of attribute
                                                     structures to free.
Sample Invocation:

     int   ret_status;
     char  *atribute;
     char  *datatype;
     char  *synonym;
     char  *value;
     struct PDUattribute_info *user_attr;

     pdm$load_attribute_structure(
                 status            = &ret_status,
                 attribute         = attribute,
                 datatype          = datatype,
                 synonym           = synonym,
                 value             = value
                 attr_list         = &user_attr;
               );
     pdm$create_catalog(
                 status            = &ret_status,
                 catalog_name      = "test",
                 user_attr         = user_attr
               );
     pdm$free_attribute_structure(
                 status            = &ret_status,
                 attr_list         = &user_attr
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$free_attribute_structure(status,
                        attr_list);

        PDUprepare_free_attribute_structure(status,
                        attr_list);

#endomdef
/******************************************************************************

Macro:

     pdm$load_file_structure

     This macro loads file information into a link list of structures to
     be used when adding a new part or adding files to an existing part.

     The parameter "mode" is defined in the file PDUmacrodef.h.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status
     file_desc           *char                       I   File Description
     local_fn            *char                       I   Local Filename
     storage_fn          *char                       I   Storage Filename
     file_type           *char                       I   File Type
     mode                 int                        I   Flag for ADD
     file_list           struct PDU_file_info **     I/O List of files

Sample Invocation:

     int   ret_status;
     char  *file_desc;
     char  *local_fn;
     char  *storage_fn;
     char  *file_type;
     int    mode;
     struct file_info *user_file;

     pdm$load_file_structure(
                 status            = &ret_status,
                 file_desc         = file_desc,
                 local_fn          = local_fn,
                 storage_fn        = storage_fn,
                 file_type         = file_type,
                 mode              = ADD,
                 file_list         = &user_file;
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$load_file_structure(status,
                        file_desc = NULL,
                        local_fn,
                        storage_fn = NULL,
                        file_type = NULL,
                        mode = 0,
                        file_list);

        PDUload_file_structure(status,
                        file_desc,
                        local_fn,
                        storage_fn,
                        file_type,
                        mode,
                        file_list);

#endomdef
/******************************************************************************

Macro:

     pdm$free_file_structure

     This macro frees a linklist of type file_info.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status
     file_list           struct PDU_file_info **     I/O List of files

Sample Invocation:

     int   ret_status;
     struct file_info *user_files;

     pdm$free_file_structure(
                 status            = &ret_status,
                 file_list         = &user_files
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$free_file_structure(status,
                        file_list);

       PDUfree_file_structure(status,
                        file_list);

#endomdef

/******************************************************************************

Macro:

     pdm$load_change_structure

     This macro loads file information into a link list of structures to
     be used when changing the files associated with a part.

     The parameter "mode" is defined in the file PDUmacrodef.h.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status
     file_desc           *char                       I   File Description
     chg_file_desc       *char                       I   File Description
     local_fn            *char                       I   Local Filename
     chg_local_fn        *char                       I   Local Filename
     storage_fn          *char                       I   Storage Filename
     chg_storage_fn      *char                       I   Storage Filename
     file_type           *char                       I   File Type
     chg_file_type       *char                       I   File Type
     mode                 int                        I   Flag for CHANGE
     chg_file_list       struct chg_file_info **     I/O List of files

Sample Invocation:

     int   ret_status;
     char  *file_desc;
     char  *chg_file_desc;
     char  *local_fn;
     char  *chg_local_fn;
     char  *storage_fn;
     char  *chg_storage_fn;
     char  *file_type;
     char  *chg_file_type;
     int    mode;
     struct chg_file_info *user_file;

     pdm$load_change_structure(
                 status            = &ret_status,
                 file_desc         = file_desc,
                 chg_file_desc     = chg_file_desc,
                 local_fn          = local_fn,
                 chg_local_fn      = chg_local_fn,
                 storage_fn        = storage_fn,
                 chg_storage_fn    = chg_storage_fn,
                 file_type         = file_type,
                 chg_file_type     = chg_file_type,
                 mode              = CHANGE,
                 chg_file_list     = &user_file;
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$load_change_structure(status,
                        file_desc = NULL,
                        chg_file_desc = NULL,
                        local_fn,
                        chg_local_fn,
                        storage_fn = NULL,
                        chg_storage_fn = NULL,
                        file_type = NULL,
                        chg_file_type = NULL,
                        mode = 2,
                        chg_file_list);

        PDUload_change_structure(status,
                        file_desc,
                        chg_file_desc,
                        local_fn,
                        chg_local_fn,
                        storage_fn,
                        chg_storage_fn,
                        file_type,
                        chg_file_type,
                        mode,
                        chg_file_list);

#endomdef
/******************************************************************************

Macro:

     pdm$free_change_file_structure

     This macro frees a linklist of type file_info.

Arguments:

     ARGUMENT            DATA TYPE                  I/O  DESCRIPTION
     status              *int                        O   Return status
     chg_file_list       struct PDU_file_info **     I/O List of files

Sample Invocation:

     int   ret_status;
     struct chg_file_info *user_files;

     pdm$free_change_file_structure(
                 status            = &ret_status,
                 chg_file_list     = &user_files
               );

Return Status:

        Invalid Input
        Successful Completion

******************************************************************************/
#omdef pdm$free_change_file_structure(status,
                        chg_file_list);

       PDUfree_change_file_structure(status,
                        chg_file_list);

#endomdef

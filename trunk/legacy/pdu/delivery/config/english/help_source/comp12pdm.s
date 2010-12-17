<TP>pdm_macros
:I/PDM API Macros:
This topic describes the set of macros that exist to access
I/PDM and I/PDU from a program.  These macros can be used in
PPL programs or  in regular C programs linked with the
product.  This topic provides the syntax and examples for
each macro.  The examples are implemented as PPL files.  C
program examples would be similar to the PPL examples
provided in this section, differing mainly in the way data is
obtained from the user (the PDM macro calls are the same in
PPL and in C programs).
<F>

Macro                  Description         Include
                                           File

pdm$activate_part()    Retrieve a part     PDUgrmacros.h
                       model file.
pdm$add_part()         Add a part to the   PDUpart_mac.h
                       PDM database.
pdm$checkin_part()     Checks a part in    PDMfile_mac.h
                       to the PDM
                       storage area.
pdm$checkout_part()    Check a part out    PDMfile_mac.h
                       to the
                       workstation.
pdm$chg_part()         Change a part or    PDUpart_mac.h
                       add new files to
                       an existing part.
pdm$copy_files()       Copy a part file    PDMfile_mac.h
                       or list of files
                       to the
                       workstation.
pdm$create_bom()       Generate a BOM      PDUgrmacros.h
                       for an assembly.
pdm$create_catalog()   Create a catalog.   PDUgrmacros.h
pdm$deactivate_part()   Close the active
                        part file.
pdm$free_attribute_structure()   Free a linklist      PDUload_free.h
                                 of type
                                 PDUattribute_info.
pdm$free_file_structure()   Free a linklist      PDUload_free.h
                            of type
                            PDUattribute_info.
pdm$load_attribute_structure()   Load attribute       PDUload_free.h
                                 information into
                                 a structure of
                                 type
                                 PDUattribute_info.
pdm$load_file_structure()   Load file            PDUload_free.h
                            information into
                            a structure of
                            type
                            PDUattribute_info.
pdm$login()            Log into I/PDM.     PDMlog_macro.h
pdm$logout()           Log out of I/PDM.   PDMlog_macro.h
pdm$query_bom()        Retrieve list of
                       available BOMs in
                       database.
pdm$query_for_catalogs()   Retrieve list of
                           catalogs in the
                           database.
pdm$query_for_parts()   Retrieve list of    PDUpart_mac.h
                        parts in a
                        catalog.
pdm$review_pt()        Review a part
                       from a specific
                       catalog.
pdm$ris_query()        An adhoc query
                       utility.
pdm$ris_stmt()         An adhoc data
                       manipulation
                       utility.
pdm$where_used()       Create a where      PDUgrmacros.h
                       used list for a
                       part.

<T>
For related information, see the following topic:<T>

<ST>activate_part  pdm$activate_part
<ST>pd$add_part pdm$add_part
<ST>pd$checkin_part pdm$checkin_part
<ST>pd$checkout_part pdm$checkout_part
<ST>chg_part  pdm$chg_part
<ST>pd$copy_part_local pdm$copy_files
<ST>pd$create_bom pdm$create_bom
<ST>create_catalog  pdm$create_catalog
<ST>pd$deactivate_part pdm$deactivate_part
<ST>free_att  pdm$free_attribute_structure
<ST>free_file  pdm$free_file_structure
<ST>load_att  pdm$load_attribute_structure
<ST>load_file  pdm$load_file_structure
<ST>pd$login pdm$login
<ST>pd$logout pdm$logout
<ST>query_bom  pdm$query_bom
<ST>query_for_catalogs  pdm$query_for_catalogs
<ST>query_for_parts  pdm$query_for_parts
<ST>review_pt  pdm$review_pt
<ST>ris_query  pdm$ris_query
<ST>ris_stmt  pdm$ris_stmt
<ST>wh_used  pdm$where_used


<ETP>
<TP>activate_part
:pdm$activate_part:
This macro activates a specific part.

<F>pdm$activate_part(
                   status,
                   catalog_name,
                   part_id,
                   revision,
                   file_name
                 )<T>
<F>

Argument     Data       I/O    Description
             Type

status       *int        O     Return status.
catalog_name   *char       I     Catalog name.
part_id      *char       I     Part name
revision     *char       I     Part's
                               revision.
file_name    *char       I     The name of the
                               file to
                               activate.<T>
Example

<F>#include  "PDUerror.h"
#include  "PDUgrmacros.h"

int   ret_status;
char  *catalog;
char  *part_id;
char  *part_rev;
char  *filename;

pdm$activate_part(
                  status = &ret_status,
                  catalog_name = catalog,
                  part_id = part_id,
                  revision = part_rev,
                  file_name = filename
                 );<T>
Status Returns
<F>

PDM_E_CAT_NOT_FOUND         Invalid Catalog
PDM_E_PART_NOT_FOUND        Invalid Part
PDM_E_PARTREV_NOT_FOUND     Invalid Revision
PDM_S_SUCCESS               Successful
                            Completion<T>

<ETP>
<TP>pd$add_part
:pdm$add_part:
This macro adds a part to a specific catalog

<F>pdm$add_part (
               status,
               catalog,
               part_id,
               part_rev,
               part_type,
               part_desc,
               acl_name,
               stg_name
              )<T>
<F>

Argument   Data Type           I/O   Description

status   *int                  O    Return Status.
catalog   *char                I    Catalog name.
part_id   *char                I    Part number.
part_rev   *char                I    Part revision.
part_type   *char                I    Part type.
part_desc   *char                I    Part
                                      description.
acl_name   *char                I    ACL name.
stg_name   *char                I    Checked in
                                     storage name.
attrs    *struct               I    Attributes to
         PDUattribute_info          add.
files    *struct               I    Files to add.
         PDUfile_info<T>
Notes

struct PDUattribute_info is defined in PDUmac_struc.h
struct PDUfile_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUpart_mac.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  return_status;
char *catalog;
char *part_id;
char *rev;
char *part_type;
char *description;
char *acl_name;
char *stg_name;

pdm$add_part (
               status = &return_status,
               catalog = catalog,
               part_id = part_id,
               part_rev = rev,
               part_type = part_type,
               part_desc = desc,
               acl_name = acl_name,
               stg_name = stg_name
             );<T>
Status Returns
<F>

PDM_E_BAD_DATA              Bad data.
PDM_E_INVALID_INPUT         Invalid input.
PDM_E_IDENTIFIER_TOO_LONG   Identifier too long.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_EXIST            Part already exists.
PDM_E_PART_FIELD_BLANK      A Part must be
                            specified.
PDM_E_REV_FIELD_BLANK       A Revision must be
                            specified.
PDM_E_INVLAID_PART_TYPE     Invalid Part Type.
PDM_E_ADD_ITEM              Could not add part
                            to catalog.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$checkin_part
:pdm$checkin_part:
This macro checks in a part.

<F>pdm$checkin_part (
                    status,
                    catalog_name,
                    partid,
                    revision
                   )<T>
<F>

Argument     Data       I/O    Description
             Type

status       int         O     Return status.
catalog_name   *char       I     Catalog name.
partid       *char       I     Part number.
revision     *char       I     Part revision.<T>
Example

<F>#include "PDMfile_mac.h"
#include "PDUerror.h"

int  return_status;
char *catalog;
char *partid;
char *revision;

pdm$checkin_part(
                 status = &return_status,
                 catalog_name = catalog,
                 partid = part,
                 revision = revision
                );<T>
Status Returns
<F>

PDM_I_ENTER_CATALOG         User must enter a
                            catalog.
PDM_I_ENTER_PART            User must enter a
                            part.
PDM_I_ENTER_REVISION        User must enter a
                            revision.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_NOT_FOUND        Part does not exist.
PDM_E_PARTREV_NOT_FOUND     Revision does not
                            exist.
PDM_E_FILE_NOT_FOUND        File does not exist.
PDM_E_PART_CHECKEDIN        Part must be checked
                            out.
PDM_E_CMD_CANCELLED         Command Cancelled.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$checkout_part
:pdm$checkout_part:
This macro checks out a part and activates it if the activate
flag is set to TRUE.

<F>pdm$checkout_part (
                    status,
                    catalog_name,
                    partid,
                    revision,
                    activate_flag
                   )<T>
<F>

Argument    Data       I/O    Description
            Type

return_status   int        O     Return status.
catalog_name   *char      I     Catalog name.
partid      *char       I     Part name.
revision    *char       I     Part revision.
activate_flag   int        I     Activation
                                 indicator.<T>
Example

<F>#include "PDMfile_mac.h"
#include "PDUerror.h"

int  return_status;
char *catalog;
char *partid;
char *revision;
int  activate;

pdm$checkout_part (
                   status = &return_status,
                   catalog_name = catalog,
                   partid = partnum,
                   revision = rev,
                   activate_flag = activate
                  );<T>
Status Returns
<F>

PDM_I_ENTER_CATALOG         User must enter a
                            catalog.
PDM_I_ENTER_PART            User must enter a
                            part.
PDM_I_ENTER_REVISION        User must enter a
                            revision.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_NOT_FOUND        Part does not exist.
PDM_E_PARTREV_NOT_FOUND     Revision does not
                            exist.
PDM_E_FILE_NOT_FOUND        File does not exist.
PDM_E_PART_CHECKED_OUT      Part is already
                            checked out.
PDM_E_CMD_CANCELLED         Command Cancelled.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>chg_part
:pdm$chg_part:
This macro facilitates the changing of an existing part and/or
adding new files to an existing part.

<F>pdm$chg_part (
              status,
              catalog,
              part_id,
              part_rev,
              part_type,
              part_desc,
              acl_name,
              stg_name
             )<T>
<F>

Argument   Data Type           I/O   Description

status     int                  O    Return
                                     status.
catalog    *char                I    Catalog
                                     name.
part_id    *char                I    Part name.
part_rev   *char                I    Part
                                     revision.
part_desc   *char                I    Part
                                      description.
acl_name   *char                I    ACL name.
stg_name   *char                I    Checked in
                                     storage
                                     name.
attrs      *struct              I    Attributes
           PDUattribute_info         to change.
files      *struct              I    Files to
           PDUfile_info              change or
                                     add.<T>
Note

struct PDUattribute_info is defined in PDUmac_struc.h
struct PDUfile_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUpart_mac.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  return_status;
char *catalog;
char *part_id;
char *rev;
char *part_type;
char *description;
char *acl_name;
char *stg_name;

pdm$chg_part (
              status = &return_status,
              catalog = catalog,
              part_id = part_id,
              part_rev = rev,
              part_type = part_type,
              part_desc = desc,
              acl_name = acl_name,
              stg_name = stg_name
             );<T>
Status Returns
<F>

PDM_E_BAD_DATA              Bad Data.
PDM_E_INVALID_INPUT         Invalid input.
PDM_E_IDENTIFIER_TOO_LONG   Identifier too long.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_NOT_FOUND        Part does not exist.
PDM_E_PART_FIELD_BLANK      A Part must be
                            specified.
PDM_E_REV_FIELD_BLANK       A Revision must be
                            specified.
PDM_E_INVALID_PART_TYPE     Invalid Part Type.
PDM_E_ADD_ITEM              Could not add part
                            to catalog.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$copy_part_local
:pdm$copy_files:
This macro copies the files of the specified part to the current
working directory.  If the active flag is set to TRUE, the part is
activated.

<F>pdm$copy_files (
                status,
                catalog_name,
                partid,
                revision,
                activate_flag
               )<T>
<F>

Argument     Data       I/O    Description
             Type

return_status   int         O     Return status.
catalog_name   *char       I     Catalog name.
partid       *char       I     Part name.
revision     *char       I     Part revision.
activate_flag   int         I     Activation
                                  indicator.<T>
Example

<F>#include "PDMfile_mac.h"
#include "PDUerror.h"

int  return_status;
char *catalog;
char *partid;
char *revision;
int  *activate;

pdm$copy_files (
                status = &return_status,
                catalog_name = catalog,
                partid = part,
                revision = rev,
                activate_flag = activate
               );<T>
Status Returns
<F>

PDM_I_ENTER_CATALOG         User must enter a
                            catalog.
PDM_I_ENTER_PART            User must enter a
                            part.
PDM_I_ENTER_REVISION        User must enter a
                            revision.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_NOT_FOUND        Part does not exist.
PDM_E_PARTREV_NOT_FOUND     Revision does not
                            exist.
PDM_E_FILE_NOT_FOUND        File does not exist.
PDM_I_PART_CHECKIN          Part must be checked
                            in.
PDM_E_CMD_CANCELLED         Command Cancelled.
PDM_S_SUCCESS               Successful
                            Completion<T>

<ETP>
<TP>pd$create_bom
:pdm$create_bom:
This macro creates a Bill of Materials (BOM) for the specified
part.

<F>pdm$create_bom (
                status,
                catalog_name,
                part_id,
                revision
               )<T>
<F>

Argument     Data       I/O    Description
             Type

status       int         O     Return
                               status.
catalog_name   *char       I     Catalog
                                 name.
part_id      *char       I     Part name.
revision     *char       I     Part's
                               revision.<T>
Example

<F>#include "PDUerror.h"
#include "PDUgrmacros.h"

int  status;
char *catalog;
char *part_id;
char *part_rev;
char *filename;

pdm$create_bom (
                status = &status,
                catalog_name = catalog,
                part_id = part_id,
                revision = partrev
               );<T>
Status Returns
<F>

PDM_E_CAT_NOT_FOUND         Invalid Catalog.
PDM_E_PART_NOT_FOUND        Invalid Part.
PDM_E_PARTREV_NOT_FOUND     Invalid Revision.
PDM_E_PART_NOT_ASSEMBLY     Part not an Assembly
PDM_S_SUCCESS               Successful
                            Completion<T>

<ETP>
<TP>create_catalog
:pdm$create_catalog:
This macro creates a catalog.

<F> pdmn$create_catalog (
                      status,
                      catalog_name,
                      catalog_descr,
                      template_cat
                    )<T>
<F>

Argument     Data Type            I/O   Description

status       int                   O    Return
                                        status.
catalog_name   *char                 I    Catalog
                                          name.
catalog_descr   *char                 I    Catalog
                                           description.
acl_name     *char                 I    Catalog
                                        ACL.
                                        Default is
                                        NFM_CATALOG_ACL.
template_cat   *char                 I    Template
                                          catalog.
static_attr   *struct               I    Static
              PDUattribute_info          attributes
                                         to add.
dynamic_attr   *struct               I    Dynamic
               PDUattribute_info          attributes
                                          to add.<T>
Notes

struct PDUattribute_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUgrmacros.h"
#include "PDUmac_struc.h"

int  ret_status;
char *catalog;
char *description;
char *old_catalog;

pdm$create_catalog (
                     status = &ret_status,
                     catalog_name = catalog,
                     catalog_descr = description
                     template_cat = old_catalog
                  );<T>
Status Returns
<F>

PDM_E_CATALOG_EXISTS        Catalog already
                            exists.
PDM_E_ACLNAME_NOT_FOUND     Invalid ACL.
PDM_E_INVALID_ATTR          Invalid Attribute.
PDM_E_INVALID_DATATYPE      Invalid Datatype.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$deactivate_part
:pdm$deactivate_part:
This macro deactivates a part.

<F>pdm$deactivate_part (
                     status,
                     save_flag
                    )<T>
<F>

Argument   Data       I/O    Description
           Type

status    int*         O     Return status.
save_flag   int         I     0<F>-do not
                              savefile, 1<F>-save
                              active file.
                              Default is 1.<T>
Example

<F>#include "PDUerror.h"
#include "PDUgrmacros.h"

int  status;
int  save_flag;

pdm$deactivate_part (
                     &status,
                     save_flag = 1
                    );<T>
Status Returns
<F>

PDM_E_CAT_NOT_FOUND         Invalid Catalog.
PDM_E_PART_NOT_FOUND        Invalid Part.
PDM_E_PARTREV_NOT_FOUND     Invalid Revision.
PDM_S_SUCCESS               Successful
                            Completion<T>

<ETP>
<TP>free_att
:pdm$free_attribute_structure:
This macro frees a linklist of type PDUattribute_info.

<F>pdm$free_attribute_structure (
                              status,
                              attr_list
                             )<T>
<F>

Argument   Data Type          I/O   Description

status     *int                O    Return
                                    status.
attr_list   struct                I/O   List of
            PDUattribute_info**         attribute
                                        structures to
                                        free.<T>
Notes

struct PDUattribute_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  ret_status;
char *attribute;
char *datatype;
char *synonym;
char *value;
struct PDUattribute_info *user_attr;

pdm$load_attribute_structure (
                              status = &ret_status,
                              attribute = attribute,
                              datatype = datatype'
                              synonym = synonym,
                              value = value
                              attr_list = &user_attr
                             );

pdm$create_catalog(
                   status = &ret_status,
                   catalog_name = "test",
                   user-attr = user_attr
                  );

pdm$free_attribute_structure(
                             status = &ret_status,
                             attr_list = &user_attr
                            );<T>
Status Returns
<F>

PDM_E_INVALID_INPUT         Invalid Input
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>free_file
:pdm$free_file_structure:
This macro frees a linklist of type PDUfile_info.

<F>pdm$free_file_structure (
                         status,
                         file_list
                        )<T>
<F>

Argument   Data Type       I/O   Description

status     int              O    Return
                                 status.
file_list   struct           I/O   List of file
            PDUfile_info**         structures to
                                   free.<T>
Notes

struct PDUfile_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUpart_mac.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  ret_status;
char *file_desc;
char *local_fn;
char *chg_local_fn;
char *storage_fn;
char *file_type;
struct PDUattribute_info *user_files;

pdm$load_file_structure (
                         status = &ret_status,
                         file_desc = file_desc,
                         local_fn = local_fn,
                         chg_local_fn = chg_local_fn,
                         storage_fn = storage_fn,
                         file_type = file_type,
                         file_list = &user_files,
                        );

pdm$add_part(
             status = &return_status,
             catalog = catalog,
             part_id = part_id,
             part_rev = rev,
             part_type = part_type,
             part_desc = desc,
             acl_name = acl_name,
             stg_name = stg_name,
             attrs = attrs
            );

pdm$free_file_structure(
                        status = &ret_status,
                        file_list = &user_files
                       );<T>
Status Returns
<F>

PDM_E_INVALID_INPUT         Invalid Input
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>load_att
:pdm$load_attribute_structure:
This macro loads attribute information into a structure of type
PDUattribute_info.

<F>pdm$load_attribute_structure (
                              status,
                              attribute,
                              datatype,
                              synonym,
                              value,
                              attr_list
                             )<T>
<F>

Argument   Data Type              I/O   Description

status   *int                    O    Return
                                      status.
attribute   *char                   I    Attribute
                                         name.
datatype   *char                   I    Datatype of
                                        attribute.
synonym   *char                   I    Synonym of
                                       attribute.
value    *char                   I    Value of
                                      attribute.
attr_list   struct                 I/O   List of
            PDUattribute_info **         attribute
                                         structure.<T>
Notes

struct PDUattribute_info is defined in PDUmac_struc.h

Example

<F>#include "PDUerror.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  ret_status;
char *attribute;
char *datatype;
char *synonym;
char *value;
struct PDUattribute_info *user_attr;

pdm$load_attribute_structure (
                              status = &ret_status,
                              attribute = attribute,
                              datatype = datatype'
                              synonym = synonym,
                              value = value
                              attr_list = &user_attr;
                             );<T>
Status Returns
<F>

PDM_E_INVALID_INPUT         Invalid Input
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>load_file
:pdm$load_file_structure:
This macro loads file information into a structure of type
PDUfile_info.

<F>pdm$load_file_structure (
                         status,
                         file_desc,
                         local_fn,
                         chg_local_fn,
                         storage_fn,
                         file_type,
                         mode,
                         file_list
                        )<T>
<F>

Argument     Data Type         I/O   Description

status       *int               O    Return
                                     status.
file_desc    *char              I    File
                                     Description.
local_fn     *char              I    Local
                                     Filename.
chg_loc_fn   *char              I    Changed name
                                     of existing
                                     local
                                     filename.
storage_fn   *char              I    Storage
                                     Filename
file_type    *char              I    File Type
mode         int                I    Flag to
                                     Add<F> or
                                     Change<F> a
                                     file.
file_list    struct            I/O   List of file
             PDUfile_info**          structure.<T>
Notes

The parameter mode is defined in the file PDUmac_struc.h.
The parameter chg_loc_fn is used for changing the existing
local filename (local_fn). struct PDUfile_info is defined in
PDUmac_struc.h.

Example

<F>#include "PDUerror.h"
#include "PDUpart_mac.h"
#include "PDUload_free.h"
#include "PDUmac_struc.h"

int  ret_status;
char *file_desc;
char *local_fn;
char *chg_loc_fn;
char *storage_fn;
char *file_type;
int  mode;
struct PDUfile_info *user_file;

pdm$load_file_structure (
                         status = &ret_status,
                         file_desc = file_desc,
                         local_fn = local_fn,
                         chg_local_fn = chg_local_fn,
                         storage_fn = storage_fn,
                         file_type = file_type,
                         mode = ADD_MODE,
                         file_list = &user_file
                        );<T>
Status Returns
<F>

PDM_E_INVALID_INPUT         Invalid Input
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$login
:pdm$login:
This macro logs a user into I/PDM.
<F>pdm$login (
           status,
           server_name,
           environment_name,
           user_name,
           passwd
          )<T>
<F>

Argument        Data       I/O   Description
                Type

status          *int        O    Return status.
server_name     *char       I    Server name.
environment_name   *char       I    Environment name.
user_name       *char       I    Username.
passwd          *char       I    Password.<T>
Notes

A NULL string can be passed for the password.

Example

<F>#include "PDUerror.h"
#include "PDMlog_macro.h"

int  return_status;
char *server;
char *environment;
char *username;
char *passwd;

pdm$login (
           status = &return_status,
           environment_name = environment,
           user_name = username,
           passwd = password
          );<T>
Status Returns
<F>

PDM_E_BAD_NODE              Invalid Server Name.
PDM_E_BAD_PROTOCOL          Cannot connect using
                            current protocol.
PDM_E_BAD_ENV               Invalid Environment
                            Name.
PDM_E_CLH                   Environment not
                            updated in
                            clearinghouse
                            database.
PDM_E_USER__PASSWD          Invalid Username
                            Password.
PDM_E_BAD_USERNAME          Invalid Username.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>pd$logout
:pdm$logout:
This macro logs a user out of I/PDM.

<F>pdm$logout (
            status
           )<T>
<F>

Argument     Data       I/O    Description
             Type

return_status   int         O     Return status.<T>
Example

<F>#include "PDUerror.h"
#include "PDMlog_macro.h"

int  return_status;

pdm$logout (
            status = &return_status
           );<T>
Status Returns
<F>

PDM_E_CMD_CANCELLED         Command Cancelled.
PDM_S_SUCCESS               Successful
                            Completion.<T>

<ETP>
<TP>query_bom
:pdm$query_bom:
This macro queries a list of BOMs in the database.

<F>pdm$query_bom  (
                status,
                count,
                boms,
               )<T>
<F>

Argument   Data Type       I/O    Description

status    *int              O     Return status.
count     *int              O     Number of BOMS in
                                  database.
boms      *struct           O     An array of
          PDMboms                 structure with BOM
                                  information.<T>
Example

<F>#include "PDMmacros.h"
#include "PDMstruct.h"

int status = PDM_S_SUCCESS, count = 0;
PDMboms boms;

pdm$query_bom (
               status = &status,
               count = &count,
               boms = &boms
              );<T>
Status Returns
<F>

PDM_S_SUCCESS          Successful
                       Completion.
PDM_E_NO_BOMS          No BOMs in the
                       database.
PDM_E_SQL_QUERY        SQL query syntax
                       error.<T>

<ETP>
<TP>query_for_catalogs
:pdm$query_for_catalogs:
This macro queries a list of catalogs in the database.

<F>pdm$query_for_catalogs  (
                         status,
                         count,
                         catalogs
                        )<T>
<F>

Argument   Data Type         I/O   Description

status     *int               O    Return status.
count      *int               O    Number of
                                   catalogs in
                                   database.
catalogs   *struct            O    An array of
           PDMcatalogs             structure with
                                   catalog
                                   information.<T>
Example

<F>#include "PDMstruct.h"
#include "PDMmacros.h"

int status = PDM_S_SUCCESS, count = 0;
PDMcatalogs catalogs;

pdm$query_for_catalogs (
                        status = &status,
                        count = &count,
                        catalogs = &catalogs
                       );<T>
Status Returns
<F>

PDM_S_SUCCESS               Successful
                            Completion.
PDM_E_NO_CATALOGS_FOUND     No catalogs in the
                            database.
PDMS_NO_SUCH_TABLE          nfmcatalogs<F> table
                            not found.
PDM_E_SQL_QUERY             SQL query syntax
                            error.<T>

<ETP>
<TP>query_for_parts
:pdm$query_for_parts:
This macro queries a list of parts in the specified catalog.

<F>pdm$query_for_parts (
                     status,
                     catalog,
                     count,
                     parts
                    )<T>
<F>

Argument   Data Type       I/O   Description

status    *int             O    Return status.
catalog   *char            I    Catalog name.
count     *int             O    Number of parts
                                in catalog.
parts     *struct          O    An array of
          PDMparts              structure with
                                part
                                information.<T>
Example

<F>#include "PDMmacros.h"
#include "PDMstruct.h"

int status = PDM_S_SUCCESS, count = 0;
char *catalog;
PDMparts parts;

pdm$query_for_parts (
                     status = &status,
                     catalog = rev_catalog,
                     count = &count,
                     parts = &parts
                    );<T>
Status Returns
<F>

PDM_S_SUCCESS               Successful Completion.
PDM_E_NO_PARTS_FOUND        No parts in the
                            catalog.
PDM_E_CATALOG_NOT_FOUND     Catalog is not in the
                            database.
PDM_E_TOO_MANY_PARTS        More than 2000 parts
                            are returned from this
                            query.  Use better
                            query criteria.
PDM_E_SQL_QUERY             SQL query syntax
                            error.<T>

<ETP>
<TP>review_pt
:pdm$review_pt:
This macro reviews a part from a specific catalog.

<F>pdm$review_pt  (
                status,
                catalog,
                part_id,
                part_rev
               )<T>
<F>

Argument   Data Type            I/O   Description

status     *int                  O    Return
                                      status.
catalog    *char                 I    Catalog
                                      name.
part_id    *char                 I    Part
                                      Number.
part_rev   *char                 I    Part
                                      Revision

<T>
A filename, REVIEW_PT<T>, which contains all the attribute and
file information for the specified part, is created when the
review part macro is executed.  This file will be located in the
current working directory.

Example

<F>#include "PDUerror.h"

int return_status;
char *catalog;
char *part_id;
char *rev;

pdm$review_pt (
               status = &return_status,
               catalog = catalog,
               part_id = part_id,
               part_rev = rev
              );<T>
Status Returns
<F>

PDM_E_BAD_DATA              Bad Data.
PDM_E_INVALID_INPUT         Invalid input.
PDM_E_IDENTIFIER_TOO_LONG   Identifier too long.
PDM_E_CAT_NOT_FOUND         Catalog does not
                            exist.
PDM_E_PART_EXISTS           Part already exist.
PDM_E_PART_FIELD_BLANK      A Part must be
                            specified.
PDM_E_REV_FIELD_BLANK       A Revision must be
                            specified.
PDM_S_SUCCESS               Successful Completion.<T>

<ETP>
<TP>ris_query
:pdm$ris_query:
This macro is an adhoc query utility.  You can make any valid
SQL query.

<F>pdm$ris_query (
                status,
                query,
                rows,
                output_buffer,
                ris_err_code
               )<T>
<F>

Argument   Data       I/O   Description
           Type

status     *int        O    Return status.
query      *char       I    Any valid SQL query.
rows       *int        O    Number of records
                            [rows or tuples] which
                            are returned.
output_buffer   **char      O    Stream of char buffer
                                 which is the output of
                                 the given query.
                                 Column outputs are
                                 delimited by ~<F>.
                                 NULL values are
                                 substituted by nil<F>.
                                 This character string
                                 is malloced based on
                                 the data size.  There
                                 is no need to
                                 allocate.  It's the
                                 programmer's
                                 responsibility to free
                                 this up.
ris_err_code   *int        O    RIS error codes for
                                information.<T>
Example

<F>int status = PDM_S_SUCCESS, rows = 0, ris_err_code = 0;
char *query, *output_buffer;

    query = (char *) malloc (512);
    memset(query,NULL,512);

sprintf(query,"SELECT n_itemno, n_itemname, n_itemrev FROM equipment");

<S>Note:<T>

Do not give statement like sprintf(query,"SELECT * FROM
equipment"); You need to be specific on the column names. <F>
 „<T>

pdm$ris_query ( status = &status, query = query, rows =
               &rows, output_buffer = output_buffer, ris_err_code

Status Returns
<F>

SQL_S_SUCCESS            Successful Completion.
SQL_E_CLEAR              Error in clearing dynamic
                         statement.
SQL_E_CLOSE              Error in closing a
                         cursor.
SQL_E_CURSOR             Error in opening a
                         cursor.
SQL_E_DATA_TYPE          Unknown data type.
SQL_E_DECLARE            Error in declaring the
                         datatype.
SQL_E_DESCRIBE           Error in describing the
                         output variables.
SQL_E_DUPLICATE_VALUE    Duplicate value in the
                         unique index column.
SQL_E_DUP_ATTR_NAME      Duplicate columns in the
                         query.
SQL_E_EXECUTE            Error in executing the
                         query.
SQL_E_FETCH              Error in fetching the
                         answer.
SQL_E_INVALID_LOCK_TABLES   Lock table should be
                            first statement in trans.
SQL_E_MALLOC             Could not allocate the
                         memory.
SQL_E_MESSAGE            Error in message
                         translation.
SQL_E_NOT_QUERY          Not a valid SQL query.
SQL_E_NOT_STMT           Not a valid SQL
                         statement.
SQL_E_OPEN               Error in opening a
                         statement.
SQL_E_PREPARE            Error in preparing the
                         statement.
SQL_E_UNKNOWN_COLUMN     Unknow column in the
                         query.
SQL_I_NO_ROWS_FOUND      No rows found which
                         satisfy the given
                         condition.
SQL_E_TABLE_EXISTS       Table already exists.<T>

<ETP>
<TP>ris_stmt
:pdm$ris_stmt:
This macro is a adhoc data manipulation utility.  You can make
any valid data manipulation [create, update, insert, delete,
commit] SQL statement.

<F>pdm$ris_stmt  (
                status,
                statement,
                ris_err_code
               )<T>
<F>

Argument     Data Type   I/O   Description

status       *int         O    Return status.
statement    *char        I    Any valid SQL statement.
ris_err_code   *int         O    RIS error codes for
                                 information.<T>
Example

<F>int status = SQL_S_SUCCESS, ris_err_code = 0;
char *statement;

    statement = (char *) malloc (512);
    memset (statement,NULL,512);

pdm$ris_stmt (
               status = &status,
               statement = statement,
               ris_err_code = &ris_err_code
              );<T>
Status Returns
<F>

SQL_S_SUCCESS            Successful Completion.
SQL_E_CLEAR              Error in clearing dynamic
                         statement.
SQL_E_CLOSE              Error in closing a
                         cursor.
SQL_E_CURSOR             Error in opening a
                         cursor.
SQL_E_DATA_TYPE          Unknown data type.
SQL_E_DECLARE            Error in declaring the
                         datatype.
SQL_E_DESCRIBE           Error in describing the
                         output variables.
SQL_E_DUPLICATE_VALUE    Duplicate value in the
                         unique index column.
SQL_E_DUP_ATTR_NAME      Duplicate columns in the
                         query.
SQL_E_EXECUTE            Error in executing the
                         query.
SQL_E_FETCH              Error in fetching the
                         answer.
SQL_E_INVALID_LOCK_TABLES   Lock table should be
                            first statement in trans.
SQL_E_MALLOC             Could not allocate the
                         memory.
SQL_E_MESSAGE            Error in message
                         translation.
SQL_E_NOT_QUERY          Not a valid SQL query.
SQL_E_NOT_STMT           Not a valid SQL
                         statement.
SQL_E_OPEN               Error in opening a
                         statement.
SQL_E_PREPARE            Error in preparing the
                         statement.
SQL_E_UNKNOWN_COLUMN     Unknow column in the
                         query.
SQL_I_NO_ROWS_FOUND      No rows found which
                         satisfy the given
                         condition.
SQL_E_TABLE_EXISTS       Table already exists.<T>

<ETP>
<TP>wh_used
:pdm$where_used:
This macro creates a where used list for a part.

<F>pdm$where_used  (
                 status,
                 catalog_name,
                 part_id,
                 revision,
                 report_name,
                 filename,
                 display
                )<T>
<F>

Argument     Data      I/O   Description
             Type

status       *int       O    Return status.
catalog_name   *char      I    Catalog name.
part_id      *char      I    Part name.
revision     *char      I    Part revision.
report_name   *char      I    Report Name.
filename     char[51]    I    Filename for
                              report.
display      int        I    0<F> - Don't
                             display report.
                             1<F> - Display
                             report.<T>
Example

<F>#include "PDUerror.h"
#include "PDUgrmacros.h"

int  ret_status;
char *catalog;
char *part;
char *rev;
char *report;
char file[51];

pdm$where_used (
                status &ret_status,
                catalog_name = catalog,
                part_id = part,
                revision = rev,
                report_name = report,
                filename = file,
                display = display
               );<T>
Status Returns
<F>

PDM-E_CAT_NOT_FOUND         Invalid Catalog.
PDM_E_PART_NOT_FOUND        Invalid Part.
PDM_E_PARTREV_NOT_FOUND     Invalid Revision.
PDM_E_NO_EXISTING_FORMAT    Invalid Report.
PDM_E_INVALID_CHAR_IN_LOCFN   Invalid Filename.
PDM_S_SUCCESS               Successful Completion.<T>

<ETP>

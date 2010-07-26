/*******************************************************************************
partmacros.h

General Description:

    This file contains all macros needed to create, modify, save and query 
    parts and to generate part reports.

Macros provided:

    Creation:
 
    o co$part_construct()           - construct part from objects and attribtues.
    o co$part_place()               - place a part from a cell library.
    o co$part_get_template()        - gets a representative id for a part number.

    Attribute Modification and Query:
    
    o co$part_put_attr()            - add/modify a part attribute.
    o co$part_rem_attr()            - remove a part attribute.
    o co$part_get_attr()            - get an attribute/value pair from a part.
    o co$part_get_all_attr()        - get all attrubute/value pairs for a part.
    o co$part_change ()             - change a part from on type to another.
        
    Part Query:

    o co$part_get_parts()           - get a list of parts, counts and ids.

    Reporting:
 
    o co$part_construct_partslist() - creates a partslist header.
    o co$part_add_to_partslist()    - adds a part(s) to a partslist.
    o co$part_list()                - writes part info to a file.

    Misc:
    
    o co$part_pass ()               - pass a message to specified type of part.

Dependencies:

    partdef.h
    part.h
          
Notes:

    part type       - a general class of parts (3/4" BOLTS).
    part            - a instance of a part type.
    parts_dir       - a directory containing instances of parts.
    catalog         - catalog name.
    number          - part number.
    revision        - part revision.
    attr            - an attribute for a part (Part Description).
    value           - the value for an attribute (3/4" BOLT).
    type            - the type of attribute, GR_STATIC_ATTR or GR_DYNAMIC_ATTR
History:

     2/9/90   Jay Wallingford     Creation Date
     08/16/91 Jamal Shakra        Modification Date
     
*******************************************************************************/

#ifndef partmacros_include
#define partmacros_include


#include <stdio.h>
#include "growner.h"
#include "grdpbdef.h"
#include "grdpb.h"


struct GRpart_item
{
    IGRchar     * part;
    IGRint        part_id;
};





/******************************************************************************
Macro: 

     co$part_construct

     This macro constructs a part from a list of attributes/value pairs.
     A graphic group is constructed with the list of graphic objects, and
     then added to the part.

Arguments:

     ARGUMENT       DATA TYPE          I/O  DESCRIPTION
     msg            *IGRlong            O   Address of the return code.
     mod_env        *struct GRmd_env    I   Module enviroment.
     parts_dir      *IGRchar            I   Parts directory.
     catalog        *IGRchar            I   Parts catalog .
     number         *IGRchar            I   Part number.
     revision       *IGRchar            I   Part revision.
     description    *IGRchar            I   Part description.
     part           *struct GRid        O   Part's id.
     attr           *IGRchar []         I   List of pointers to attribute names.
     value          *IGRchar []         I   List of pointers to attribute values.
     type            IGRint []          I   List of attribute types
     num             IGRint             I   Number of attribute/value pointers.
     object          struct GRobj_env[] I   List of object ids to be added. 
     num_objects     IGRint             I   Number of object ids.
     gg_flag         IGRint             I   If set graphic group of objects will
                                            be constructed and attached to part.
                                            
Sample Invocation:

     IGRchar ** attr, ** value;
     struct GRobj_env objects[5];
     struct GRid part_id;
     
     attr[0] = "NUMBER";   
     attr[1] = "DESCRIPTION";
     value[0] = "BOLT2/10A"; 
     value[1] = "ISO Bolt (2cm diam, 10cm length)";
     type[0] = type[1] = GR_STATIC_ATTR;
     
     status = co$part_construct ( msg = &msg,
                                  parts_dir = ":myfile:usr:mypartslist",
                                  part = &part_id,
                                  attr = attr,
                                  value = value,
                                  type = type,
                                  num = 2,
                                  objects = objects,
                                  num_objects = 5
                                );
Notes:

    When creating a part at least two part attribute name/value pairs MUST be
    supplied. The first attribute MUST uniquely describe the part type
    (Part Number) and the second attribute MUST be a short description 
    for the part type (Part Name). The part number allows the number
    of parts of a certain type to be determined. This is used when generating
    a bill of material and/or parts lists. The description is displayed when
    the part is located in the file. This allows the user to quickly
    determine what the part is without having to resort to commands which 
    browse part attributes.

    If the directory is not specified the default parts directory will
    be used (:filename:parts).
    
    MSSUCC       Success
    MSFAIL       Failure

******************************************************************************/
#omdef co$part_construct ( msg,
                           mod_env = NULL,
                           parts_dir = NULL,
                           catalog = NULL,
                           number = NULL,
                           revision = NULL,
                           description = NULL,
                           part,
                           attr = NULL,
                           value = NULL,
                           type = NULL,
                           num,
                           object = NULL,
                           num_objects = 0,
                           gg_flag = 0 )
                          
       COpart_construct_func ( (msg),
                               (mod_env),
                               (parts_dir),
                               (catalog),
                               (number),
                               (revision),
                               (description),
                               (part),
                               (attr),
                               (value),
                               (type),
                               (num),
                               (object),
                               (num_objects),
                               (gg_flag) )
#endomdef

/******************************************************************************
Macro: 

     co$part_get_template

     This macro gets the id of a part which matches the specified
     part number.

Arguments:

     ARGUMENT       DATA TYPE        I/O      DESCRIPTION
     msg            *IGRlong         O        Address of the return code.
     mod_env        *struct GRmd_env I        Module enviroment.
     parts_dir      *IGRchar         I        Parts directory.
     catalog        *IGRchar         I        Catalog.
     number         *IGRchar         I        Part number.
     revision       *IGRchar         I        Part revision.
     part           *struct GRid     I        Representative part.

Sample Invocation:
     
     struct GRid    part_id;

     status = co$part_get_template ( msg = &msg,
                                     number = "A10-2020",
                                     part = &part_id );

Return Codes:

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_get_template ( msg,
                              mod_env = NULL,
                              parts_dir = NULL,
                              catalog = NULL,
                              number,
                              revision = NULL,
                              part )
                          
       COpart_attr_func ( CO_part_template,
                          (msg),
                          (mod_env),
                          (parts_dir),
                          (catalog),
                          (part),
                          (number),
                          (revision),
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL )
#endomdef

/******************************************************************************
Macro: 

     co$part_put_attr

     This macro adds/modifies attribute name/values.

Arguments:

     ARGUMENT       DATA TYPE        I/O      DESCRIPTION
     msg            *IGRlong         O        Address of the return code.
     mod_env        *struct GRmd_env I        Module enviroment.
     parts_dir      *IGRchar         I        Parts directory.
     catalog        *IGRchar         I        Catalog directory.
     part           *struct GRid     I        Representative part.
     number         *IGRchar         I        Part number.
     revision       *IGRchar         I        Part revision.
     attr           *IGRchar         I        Attribute name.
     value          *IGRchar         I        Attribute value.
     type            IGRint          I        Attribute type.

Sample Invocation:

     status = co$part_put_attr ( msg = &msg,
                                 part = &part_id,
                                 attr = "MATERIAL",
                                 value = "STEEL",
                                 type = GR_STATIC_ATTR )

Return Codes:

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_put_attr ( msg,
                          mod_env = NULL,
                          parts_dir = NULL,
                          catalog = NULL,
                          part = NULL ^
                          number = NULL,
                          revision = NULL,
                          attr,
                          value,
                          type )
                          
       COpart_attr_func ( CO_part_put,
                          (msg),
                          (mod_env),
                          (parts_dir),
                          (catalog),
                          (part),
                          (number),
                          (revision),
                          (attr),
                          NULL,
                          (value),
                          (type),
                          NULL )
#endomdef

/*******************************************************************************
Macro: 

     co$part_rem_attr

     This macro removes attributes name/value pairs from a part

Arguments:

     ARGUMENT       DATA TYPE        I/O      DESCRIPTION
     msg            *IGRlong         O        Address of the return code.
     mod_env        *struct GRmd_env I        Module enviroment.
     parts_dir      *IGRchar         I        Parts directory.
     catalog        *IGRchar         I        Catalog directory.
     part           *struct GRid     I        Representative part.
     number         *IGRchar         I        Part number.
     revision       *IGRchar         I        Part revision.
     attr           *IGRchar         I        Attributes name.
     
Sample Invocation:

    status = co$part_rem_attr ( msg = &msg,
                                part = &part_id,
                                attr = "MATERIAL" );
Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_rem_attr ( msg,
                          mod_env = NULL,
                          parts_dir = NULL,
                          catalog = NULL,
                          part = NULL ^
                          number = NULL,
                          revision = NULL,
                          attr )
                             
       COpart_attr_func ( CO_part_rem,
                          (msg),
                          (mod_env),
                          (parts_dir),
                          (catalog),
                          (part),
                          (number),
                          (revision),
                          (attr),
                          NULL,
                          NULL,
                          NULL,
                          NULL )
#endomdef

/*******************************************************************************
Macro: 

     co$part_get_attr

     This macro gets an attribute value for an attribute name.

Arguments:

     ARGUMENT       DATA TYPE           I/O      DESCRIPTION
     msg            *IGRlong            O        Address of the return code.
     mod_env        *struct GRmd_env    I        Module enviroment.
     parts_dir      *IGRchar            I        Parts directory.
     catalog        *IGRchar            I        Catalog directory.
     part           *struct GRid        I        Representative part.
     number         *IGRchar            I        Part number.
     revision       *IGRchar            I        Part revision.
     attr           *IGRchar            I        Attribute name.
     index          *IGRint             I        Attribute index.
     value          *IGRchar            O        Attribute value.
     type           *IGRint             O        Attribute type.
     
Sample Invocation:

    IGRlong msg;
    struct GRid part_id;
    IGRchar value[MAX_VALUE];
    IGRint  type;
    
    status = co$part_get_attr ( msg = &msg,
                                part = &part_id,
                                attr = "NUMBER",
                                value = value,
                                type = &type )

Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_get_attr ( msg,
                          mod_env = NULL,
                          parts_dir = NULL,
                          catalog = NULL,
                          part = NULL ^
                          number = NULL,
                          revision = NULL,
                          attr = NULL,
                          index = NULL,
                          value = NULL,
                          type = NULL )
                                                    
       COpart_attr_func ( CO_part_get,
                          (msg),
                          (mod_env),
                          (parts_dir),
                          (catalog),
                          (part),
                          (number),     
                          (revision),
                          (attr),
                          (index),
                          (value),
                          (type),
                          NULL )
#endomdef

/*******************************************************************************
Macro: 

     co$part_get_all_attr

     This macro gets all attribute/value pairs for a part.

Arguments:

     ARGUMENT       DATA TYPE           I/O       DESCRIPTION
     msg            *IGRlong            O        Address of the return code.
     mod_env        *struct GRmd_env    I        Module enviroment.
     parts_dir      *IGRchar            I        Parts list directory.
     catalog        *IGRchar            I        Catalog directory.
     part           *struct GRid        I        Representative part.
     number         *IGRchar            I        Part number.
     revision       *IGRchar            I        Part revision.
     attr           *IGRchar[]          O        List of pointers to names.
     value          *IGRchar[]          O        List of pointers to values.
     type            IGRint[]           O        List of attribute types.
     num            *IGRint             IO       Size of lists.
     
Sample Invocation:

    struct GRid part_id;
    IGRchar     attr_data[100][MAX_ATTR], value_data[100][MAX_VALUE];
    IGRchar     * attr[100], * value[100];
    IGRint      i, num;

    co$part_get_all_attr ( msg = &msg,
                           part = &part_id,
                           num = &num )
                                    
    if (num <= 100)
    {
        for (i=0; i<num; ++i) 
        {
            attr[i] = &attr_data[i * MAX_ATTR];
            value[i] = &value_data[i * MAX_VALUE];
        }
    
        co$part_get_all_attr ( msg = &msg,
                               part = &part_id,
                               attr = attr,
                               value = value,
                               num = &num );
    }
    
Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_get_all_attr ( msg,
                              mod_env = NULL,
                              parts_dir = NULL,
                              catalog = NULL,
                              part = NULL ^
                              number = NULL,
                              revision = NULL,
                              attr = NULL,
                              value = NULL,
                              type = NULL,
                              num )
                                                    
       COpart_attr_func ( CO_part_all,
                          (msg),
                          (mod_env),
                          (parts_dir),
                          (catalog),
                          (part),
                          (number),     
                          (revision),
                          (attr),
                          NULL,
                          (value),
                          (type),
                          (num) )
#endomdef


/*******************************************************************************
Macro: 

     co$part_place

     This macro places the active cell as a part.

Arguments:

     ARGUMENT       DATA TYPE           I/O     DESCRIPTION
     msg            *IGRlong            O       Address of the return code.
     mod_env        *struct GRmd_env    I       Module enviroment.
     origin         *struct GRevent     I       Placement point.
     scale          *struct GRdpb_scale I       Placement scale.
     angle          *IGRdouble          I       Placement angle.
     level          *IGRshort           I       Placement level.
     part           *struct GRid        O       List of part ids.
     num            *IGRint             IO      Size of part id list.

Sample Invocation:
    struct GRevent  origin;
    struct GRid     part_id[5];
    IGRint          size_part_id = 5;
        
    co$part_place ( msg = &msg,
                    origin = &origin,
                    part = part_id,
                    num = &size_part_id );

Return values:

    MSSUCC              - successful
    MSFAIL              - failure
    CO_E_NO_CELL        - active cell not found    (partdef.h)

Notes:                              

    If scale, angle, level or module are not specified they will be retrieved
    from the DPB.
    
    MSSUCC       success
    MSFAIL       failure
         
*******************************************************************************/
#omdef co$part_place ( msg,
                       mod_env = NULL,
                       origin,
                       scale = NULL,
                       angle = NULL,
                       level = NULL,
                       part,
                       num )

       COpart_place_func ( (msg),
                           (mod_env),
                           (origin),
                           (scale),
                           (angle),
                           (level),
                           (part),
                           (num) )

#endomdef

/*******************************************************************************
Macro: 

     co$part_get_parts

     This macro return the list of parts.

Arguments:

     ARGUMENT       DATA TYPE        I/O      DESCRIPTION
     msg            *IGRlong         O        Address of the return code.
     mod_env        *struct GRmd_env I        Module enviroment.
     parts_dir      *IGRchar         I        Parts directory to search.
     catalog        *IGRchar         I        Catalog directory to search.
     part            struct GRid []  O        Representative part ids.
     number         *IGRchar []      O        List of part number strings.
     revision       *IGRchar []      O        List of part revision strings.
     name           *IGRchar []      O        List of part description strings.
     quantity        IGRint  []      O        List of part quantities.
     num            *IGRint          IO       Size of lists/number of parts.

Sample Invocation:

    struct GRid  object[100];
    IGRchar     number_data[100][MAX_VALUE];
    IGRchar     * number[100];
    IGRchar     name_data[100][MAX_VALUE];
    IGRchar     * name[100];
    IGRint      num;
    
    co$part_get_parts ( msg = &msg,
                        num = &num );

    if (num < 100)
    {
        for (i=0; i<100; ++i)
        {
            number[i] = number_data[i];
            name[i] = name_data[i];
        }

        co$part_get_parts ( msg = &msg,
                            part = object,
                            number = number,
                            name = name,
                            num = &num );
    }
    
Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_get_parts ( msg,
                           mod_env = NULL,
                           parts_dir = NULL,
                           catalog = NULL,
                           part = NULL,
                           number = NULL,
                           revision = NULL,
                           name = NULL,
                           quantity = NULL,
                           num )

                               
                             
       COpart_get_parts_func ( (msg),
                               (mod_env),
                               (parts_dir),
                               (catalog),
                               (part),
                               (number),
                               (revision),
                               (name),
                               (quantity),
                               (num) )
#endomdef

/*******************************************************************************
Macro: 

     co$part_construct_partslist

     This macro creates partslist header.

Arguments:

     ARGUMENT       DATA TYPE        I/O      DESCRIPTION
     msg            *IGRlong         O        Address of the return code.
     mod_env        *struct GRmd_env I        Module enviroment.
     partslist      *struct GRid     O        Partslist id.
     name           *IGRchar         I        Partslist name.
     desc           *IGRchar         I        Partslist description.
     block          *struct GRid     I        Partslist header block.
     cols           *IGRint          I        Number of columns.
     attr           *IGRchar []      I        Attribute for each column.
     just           *IGRchar []      I        Justification for each column.
     text           *struct GRid     I        Titles for each column.
     line           *struct GRid     I        Divider lines. (num_cols - 1)
     
Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_construct_partslist ( msg,
                                     mod_env = NULL,
                                     partslist,
                                     name = NULL,
                                     desc = NULL,
                                     block,
                                     cols,
                                     attr,
                                     just,
                                     text,
                                     line )
                             
        COpart_construct_partslist_func ( (msg),
                                          (mod_env),
                                          (partslist),
                                          (name),
                                          (desc),
                                          (block),
                                          (cols),
                                          (attr),
                                          (just),
                                          (text),
                                          (line) )
                                     
#endomdef


/*******************************************************************************
Macro: 

     co$part_add_to_partslist

     This macro add a part(s) to the partslist.

Arguments:

     ARGUMENT       DATA TYPE         I/O      DESCRIPTION
     msg            *IGRlong          O        Address of the return code.
     mod_env        *struct GRmd_env  I        Module enviroment.
     partslist      *IGRchar          I        Partslist name.
     object         *struct GRobj_env I        Part ids to add.
     num_objects     IGRint           I        Number of part ids.
     line_no        *IGRint           O        Line number for each part added.
     
Notes:                              

    If part and number are NULL, num blank entries will be added to the 
    partslist.
    
    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_add_to_partslist ( msg,
                                  mod_env = NULL,
                                  partslist = NULL,
                                  object = NULL,
                                  num_objects,
                                  line_no = NULL )
                            
       COpart_list_func ( CO_part_add_to_partslist,
                          (msg),
                          (mod_env),
                          (partslist),
                          (FILE *)NULL,
                          (object),
                          (num_objects),
                          (line_no) )
                                                                     
#endomdef

/*******************************************************************************
Macro: 

     co$part_delete_partslist_entries

     This macro deletes all entries on the specified partslist.

Arguments:

     ARGUMENT       DATA TYPE         I/O      DESCRIPTION
     msg            *IGRlong          O        Address of the return code.
     mod_env        *struct GRmd_env  I        Module enviroment.
     partslist      *IGRchar          I        Partslist name.
     
Notes:                              

    If partlist or mod_env is NULL the default will be used. 
    
    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_delete_partslist_entries ( msg,
                                          mod_env = NULL,
                                          partslist = NULL )
                            
       COpart_delete_partslist_entries_func ( (msg),
                                              (mod_env),
                                              (partslist) )
#endomdef

/*******************************************************************************
Macro: 

     co$part_update_partslist

     This macro update the specified partslist.

Arguments:

     ARGUMENT       DATA TYPE         I/O      DESCRIPTION
     msg            *IGRlong          O        Address of the return code.
     mod_env        *struct GRmd_env  I        Module enviroment.
     partslist      *IGRchar          I        Partslist name.
     
Notes:                              

    If partlist or mod_env is NULL the default will be used. 
    
    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_update_partslist ( msg,
                                  mod_env = NULL,
                                  partslist = NULL )
                            
       COpart_update_partslist_func ( (msg),
                                      (mod_env),
                                      (partslist) )
#endomdef

/*******************************************************************************
Macro: 

     co$part_list

     This macro writes part information to a file.

Arguments:

     ARGUMENT       DATA TYPE         I/O      DESCRIPTION
     msg            *IGRlong          O        Address of the return code.
     mod_env        *struct GRmd_env  I        Module enviroment.
     FILE           *file             I        File pointer.
     object         *struct GRobj_env I        Part ids to process.
     num_objects     IGRint           I        Number of part ids.
     
Notes:                              

    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_list ( msg,
                      mod_env = NULL,
                      file = NULL,
                      object,
                      num_objects )
                            
       COpart_list_func ( CO_part_write_to_file,
                          (msg),
                          (mod_env),
                          NULL,
                          (file),
                          (object),
                          (num_objects),
                          NULL )
                                                                     
#endomdef

/*******************************************************************************
Macro: 

     co$part_pass

     This macro passes a message to all parts of the specified type.

Arguments:

     ARGUMENT       DATA TYPE         I/O      DESCRIPTION
     msg            *IGRlong          O        Address of the return code.
     pass_msg       OM_p_MESSAGE      I        Message to pass.    
     mod_env        *struct GRmd_env  I        Module enviroment.
     senderid       GRobjid           I        Sender object id.
     senderos       GRspacenum        I        Sender object space number.
     catalog        *IGRchar          I        Catalog name.
     number         *IGRchar          I        Part number of parts to pass to.
     revision       *IGRchar          I        Part revision.
     
Notes:                              
    
    MSSUCC       success
    MSFAIL       failure
     
*******************************************************************************/
#omdef co$part_pass ( msg,
                      pass_msg,
                      mod_env,
                      senderid = my_id,
                      senderos = OM_Gw_current_OS,
                      catalog = NULL, 
                      number,
                      revision = NULL )
                            
       COpart_pass_func ( (msg),
                          (pass_msg),
                          (mod_env),
                          (senderid),
                          (senderos),
                          (catalog),
                          (number), 
                          (revision) )
                                                                     
#endomdef
#endif



#ifndef ASSEMMACROS_H
#define ASSEMMACROS_H

/*
 * File:    
 *
 *  assemmacros.h
 *
 * Description:
 *
 *  This file contains all macros needed to create, modify, delete, save and
 *  query part definitions and instances. 
 *
 *  In the assembly modeling system there are four types of part defintions:
 *  
 *  1. FILE PART DEFINITION: This type of part definition defines an EMS
 *     design file as a part by associating a part number and revision as
 *     well as other user defined attributes with the file. Initially the
 *     graphics on all layers in the file will be considered the defining
 *     graphics for the part, this may change later if local part definitions
 *     are introduced. Once a file part definition has been created for a 
 *     file that file may be placed as a part instance in another design file.
 *
 *  2. LOCAL PART DEFINITION: Often it may be convenient to define several 
 *     working parts in a single design file. The local part definition 
 *     allows the creation of several part definitions within a design file
 *     using levels to distinguish between the parts. The file that these 
 *     parts are being created in must be defined as a part by creating a 
 *     file part definition. Local part definitions are defined by a set of 
 *     attributes and a list of layers that that part will use as it's 
 *     graphic definition. If graphics already exist on the layers that 
 *     are assigned to a new local part definition then those graphics 
 *     will be considered part of the new local part definition. Local 
 *     part definitions will show up on a bill of materials as a single 
 *     instance of a part of that type. Local parts may NOT be placed
 *     as instances any other way. In order to make a local part eligible
 *     to be placed as an instance in other design files it must be split
 *     into it's own design file using the appropriate macro.
 *
 *  3. GRAPHIC PART DEFINITION: This type of part definition allows any
 *     set of graphic objects to be defined as a part. This definition of
 *     the graphics as a part exists only locally and cannot be used in
 *     other files. The graphic part definition may be used to define
 *     macros or cells as instances of parts. The graphics which are used
 *     to defined the part instance graphically are considered finished.
 *     These graphic objects will be owned rigidly so the components cannot
 *     be accessed.
 *
 *  4. NON-GRAPHIC PART DEFINITION: This type of part definition allows 
 *     a part to be created whose instances will show up in the BOM and
 *     partslist but will not have a graphci handle or graphic definition.
 *
 *  5. REFERENCE PART DEFINITION: When a file which has been defined as a 
 *     part, using the file part defintion, is placed as an instance in 
 *     another file, a reference part defintion is automatically created. 
 *     There is no way to create this type of part definition directly. 
 *     It can only be created by placing an instance of a file part 
 *     definition using the appropriate macro. The reference part definition
 *     acts as a cache for the attributes that define the file as a part.
 *     This part will insure that as the attributes that are cached are
 *     kept in sync with the attributes that define the design file as a part.
 *
 *  There are two attributes which make a part unique within the assembly
 *  modeling system: part number and revision. By default file part defintions
 *  will set the part number equal to the filename and will set the revision
 *  to 1. Local and graphic part definitions will set the revision to 1 by 
 *  default but require that a part number be assigned. Reference part 
 *  definitions get their part number and revision (as well as all other 
 *  defining attributes) from the file part definition that's associated 
 *  with the file that is being attached.
 *
 *  It is not necessary to assign an official part number when the part
 *  is in design. It may be something as simple as "bracket" or "piston", 
 *  this number may be changed latter on and the change will be relected 
 *  in the bill of material and parts list. Similarly the set of attributes
 *  which define a part need not be defined up front but may be added to,
 *  modified and removed from as you progress through your design.
 *
 *  Once a file, graphic or non-graphic part definition has been created it 
 *  is possible to place instances of these definitions. The three types of 
 *  part instances which may be placed in an assembly file correspond to
 *  the definition that the are created from:
 *
 *  1. FILE PART INSTANCE: When this type of instance is placed a filename
 *     and orientation information must be specified. The filename may be
 *     aquired by using one of the file management macros described below.
 *     When this type of instance is placed a reference file attachment is
 *     created which displays the part graphics and a cached part defintion
 *     is created which gathers it's defining set of attributes from the 
 *     file part definition in the file that has been attached. The cached
 *     part definition is a "slave" of the file part defintion, meaning that
 *     the cached definition will always update itself from the file
 *     definition.
 *
 *  2. GRAPHIC PART INSTANCE: A graphic part instance is placed by specifying
 *     a graphic part defintion, a set of graphic objects and orientation
 *     information. The graphic objects which are specified may be associative,
 *     however, the graphic roots of these associative objects may not be
 *     shared with other associative graphic objects which are not specified
 *     in the list of graphic objects. This is necessary to insure that the
 *     graphic object's orientation is not coupled to other graphics in the
 *     file, thus making the instance eligible for participation in an assembly
 *     constraint graph. If graphics aren't specified an instance will be
 *     created which is tracked by a BOM and parts list but will not have
 *     a handle associated with it.
 *
 *  2. NON-GRAPHIC PART INSTANCE: A non-graphic part instance is placed by 
 *     specifying a non-graphic part defintion.
 *
 *  The attributes which define a part/instance fall into four categories:
 *
 *  1. PART SPECIFIC ATTRIBUTES: These attributes may only be added
 *     to the part definition. Attributes like part number, part revision, 
 *     and part description are examples of definition specific attributes, 
 *     attributes whose values are the same for each instance of a part
 *     no matter which assembly file that part was placed in.
 *
 *  2. INSTANCE SPECIFIC ATTRIBUTES: These attributes may be added to the
 *     part definition and the instance. Added to a part definition, instance 
 *     specific attributes serve as a "template" for the instances that are 
 *     created from that part definition. When the instance is created these 
 *     attributes and their default values will be automatically copied from 
 *     the definition to the instance. Additionally instance specific 
 *     attributes may added be to individual instances and the value of these
 *     attributes are always independent of other instances and definitions.
 *    
 *  3. COMMON ATTRIBUTES: These attributes are similar to part
 *     specific attributes in that they are the same for all instances of
 *     a part. However, common attributes may only be added to local or
 *     reference part definitions. Item number as called out on a parts list
 *     and part count are two examples of common attributes that are created
 *     by the system. 
 *
 *  4. LINK ATTRIBUTES: These attributes are attributes which exist on 
 *     the instance. The values of these attributes are determined by 
 *     the value of part specific attributes on the instance's part
 *     definition. Link attributes are special attributes which are used
 *     in parametric applications and can only be created using special
 *     macros.
 *
 *  The objects that you will create with assembly modeling modeling macros
 *  are the same objects created within the EMS assembly modeling system, in
 *  fact we use the same macros that you will use in your application to 
 *  implement this system. These objects will be used by the assembly 
 *  constraint system as well as all assembly modeling and reporting commands 
 *  in EMS. In order to implement this system we will need to reserve certain
 *  attribute names. Most of these attributes will be accessible by customer
 *  as read-only, some may be modifiable, and some will be under complete
 *  user control but the meaning and use of the attribute will be determined
 *  by the system. These names and the customer's access to these attributes
 *  are listed below:
 *
 *  Name           Type         Description             Permission
 *  -------------------------------------------------------------------------
 *  name           PART         Part Name               Read
 *  number         PART         Part Number             Add/Read/Write
 *  revision       PART         Part Revision           Add/Read/Write
 *  description    PART         Part Description        Add/Read/Write
 *  filename       PART         Part Filename           Read
 *  catalog        PART         Catalog (Macro/Cell)    Read
 *  entry          PART         Entry in Catalog        Read
 *  weight         PART         Weigth of part.         Add/Read/Write/Delete
 *  cost           PART         Cost of part            Add/Read/Write/Delete
 *  mass           PART         Mass of part            Add/Read/Write/Delete
 *  speed          PART         Speed                   Add/Read/Write/Delete
 *  material       PART         Material                Add/Read/Write/Delete
 *  item           COMMON       Part Item Number        Read/Write
 *  count          COMMON       Number of Instances     Read
 *  quantity       INSTANCE     Instance Quantity       Add/Read/Write/Delete
 *  origin         INSTANCE     Origin of Instance      Read
 *  view           INSTANCE     Saved view.             Read/Write
 *  asm_*          *            *                       Read
 *  -------------------------------------------------------------------------
 *  
 *  The "asm_*" attribute name reserves all attribute names starting with
 *  "asm_" to the assembly modeling system. 
 *
 *  THE FOLLOWING FUNCTIONALITY HAS NOT BEEN IMPLEMENTED YET. ATTRIBUTE
 *  NAME SYNONYMS WILL BE ADDED TO THE ASSEMBLY MODELING SYSTEM IN THE 
 *  NEAR FUTURE.
 *
 *  In order to support multiple languages a synonym table may be added 
 *  to the assembly modeling system to setup synonyms for the attributes
 *  names listed above.
 *
 *  THE FOLLOWING FUNCTIONALITY HAS NOT BEEN IMPLEMENTED YET. ATTRIBUTE
 *  CONSTRAINTS WILL BE ADDED TO THE ASSEMBLY MODELING SYSTEM IN THE 
 *  NEAR FUTURE.
 *
 *  Once attributes have been defined for a part two types of constraints 
 *  may be applied on those attributes:
 *
 *  1. RANGE ATTRIBUTE CONSTRAINTS: These attribute constraints require that
 *     the attribute value be between two arbituary values. There are three
 *     variations of range attribute constraints:
 *
 *          o INCLUSIVE RANGE CONSTRAINT: Where the value must be greater
 *            than or equal to the lower constraint range value and the 
 *            value must also be less than or equal to the higher 
 *            constraint range value.
 *
 *          o EXCLUSIVE RANGE CONSTRAINT: Where the value must be greater
 *            than the lower constraint range value and less than the 
 *            higher constraint range value.
 *
 *  2. LIST ATTRIBUTE CONSTRAINTS: These attribute constraints allow the
 *     value of an attribute to be selected from a list. There are two
 *     variations on this type of constraint:
 *
 *          o EXHAUSTIVE LIST CONSTRAINT: Where the value must be one of
 *            the values in the list.
 *
 *          o SUGGESTIVE LIST CONSTRAINT: Where the value may be selected
 *            from a list of values but isn't required to match those value.
 *
 *  In order to get the reverse of a constraint a NOT operations may be 
 *  applied to the constraint. An example would be where you want to have
 *  a value lie outside of a particular exclusive range, you would apply
 *  the NOT operator to the INCLUSIVE RANGE CONSTRAINT.
 * 
 *  Attribute constraints may be applied only to definition or instance
 *  attributes on part definitions. 
 *
 * Macros Provided:
 *
 *  Before using the following macros the you should look at both 
 *  the assemdef.h and assem.h include files. These files will describe
 *  the data structures and constants that you will use with these
 *  macros.
 *
 *
 *  Part Definition Creation:
 *
 *      asm$create_file_part ()      - Defines a file as a part.
 *
 *      asm$create_local_part ()     - Subdivides the file part into part
 *                                     definitions using levels.
 *
 *      asm$create_cached_part ()    - Defines graphic, non-graphic and
 *                                     reference parts.
 *
 *
 *  Part Query:
 *
 *      asm$get_file_part ()         - Gets a file part definition. 
 *
 *      asm$part_count ()            - Returns the number of parts of a 
 *                                     particular type.
 *
 *      asm$get_part ()              - Gets a part definition by index
 *                                     or name and type.
 *
 *  Part Properties Query, Modification:
 *
 *      asm$get_part_type ()         - Returns the type of part.
 *
 *      asm$get_part_identity ()     - Returns the part number, revision and
 *                                     description.
 *
 *      asm$get_active_part ()       - Returns the active local or file part.
 *
 *      asm$set_active_part ()       - Sets the active part.
 *
 *
 *  Instance Creation:
 *
 *      asm$create_instance ()       - Creates an instance of a cached part:
 *                                     graphic, non-graphic or reference parts.
 *
 *  Instance Query:
 *
 *      asm$instance_count ()        - Returns the number of instances of a 
 *                                     cached part definition.
 *      asm$get_instance ()          - Gets an instance of a cached 
 *                                     part defintion by index of name.
 *
 *  Instance Properties Query, Modification:
 * 
 *      asm$get_instance_part ()     - Returns the local or cached part
 *                                     definition that describes the instance.
 *      asm$num_instance_graphics () - Returns the number of graphics
 *
 *      asm$get_instance_graphics () - Returns the graphic description of the
 *                                     the instance. 
 *                                     for a local part instance.
 *      asm$get_instance_handle ()   - Returns the handle for the instance.
 *
 *      asm$get_instance_type ()     - Returns the type of part instance was
 *                                     created from.
 *
 *  Assembly Properties Macros:
 *
 *      asm$get_display_props ()     - Returns the layers and types display.
 *
 *      asm$set_display_props ()     - Changes the display props.
 *
 *      asm$get_behavior_props ()    - Gets the behavior properties.
 *
 *      asm$set_behavior_props ()    - Sets the behavior properties.
 *
 *      asm$get_application_props () - Gets the application properties.
 *
 *      asm$set_application_props () - Sets the application properties.
 *
 *  Part/Instance Attribute Creation, Modification and Query:
 *
 *      asm$attribute_count ()       - Returns the number of attributes on a
 *                                    part/instance.
 *      asm$get_attribute ()         - Returns an attribute by name or index.
 *
 *      asm$add_attribute ()         - Adds an attribute to a part/instance.
 *
 *      asm$mod_attribute ()         - Modifies an attribute on a part/instance.
 *
 *      asm$rem_attribute ()         - Removes an attribute from a 
 *                                    part/instance.
 *      asm$link_attribute ()        - Links a part attr on an instance.
 *
 *  Reporting:
 *
 *      asm$create_partslist ()  - Creates a partslist in a drawing file.
 *
 *      asm$update_partslist ()  - Updates the existing partslist.
 *
 *      asm$write_bom ()         - Writes out a bill of materials to file.
 *
 *
 * Dependencies:
 *
 *      assemdef.h
 *      assem.h
 *
 * Notes:
 *
 * History:
 *
 *      4/23/93     jay wallingford     creation date
 *      5/06/93     Jamal Shakra        modification date 
 *
 */

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Part Macros                                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$create_file_part                                               |
 |                                                                           |
 | This macro is used to create a file part. This type of part defines the   |
 | active file as a part. Once created the file can be used to instantiate a |
 | reference part in another file. If the number and revision are left blank |
 | the part number will default to the filename and the revision will default|
 | to 1.
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment for part.     |
 |        IGRchar         * number          Attribute defining part number.  |
 |        IGRchar         * revision        Attribute defining part revision.|
 |        IGRint            num_attributes  Number of additional attributes. |
 |        EMattr          * attributes      Additional attributes.           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Id of newly create part.         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$create_file_part (msg,
                             mod_env = NULL,
                             behavior = EM_DEFAULT_BEHAVIOR,
                             app_props = 0,
                             number = NULL,
                             revision = NULL,
                             num_attributes = 0,
                             attributes = NULL,
                             part_id = NULL)

       EMcreate_part ((msg),
                      (mod_env),
                      EM_FILE_PART,
                      EM_DEFAULT_DISPLAY,
                      (behavior),
                      (app_props),
                      (number),
                      (revision),
                      NULL,
                      NULL,
                      (num_attributes), 
                      (attributes),
                      NULL,
                      NULL,
                      (part_id),
                      NULL)
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$create_local_part                                              |
 |                                                                           |
 | This macro is used to create a local part. This type of part subdivides   |
 | the active file which must be defined as a part into other parts locally. |
 | Once created all graphics which fall of the assigned layers of this part  |
 | will be considered part of this part. In addition to part number and      |
 | revision, a list of levels which belong to this part must be specified.   |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env          Module environment for part.    |
 |        IGRchar         * number           Attribute defining part number. |
 |        IGRchar         * revision         Attribute defining part revision|
 |        IGRint            num_attributes   Number of additional attributes.|
 |        EMattr          * attributes       Additional attributes.          |
 |        IGRchar         * layers_string    Owned layers, string format.    |
 |        IGRlong         * layers           Owned layers, 32 IGRlongs.      |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Id of newly create part.         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$create_local_part (msg,
                              mod_env = NULL,
                              display = EM_DEFAULT_DISPLAY,
                              behavior = EM_DEFAULT_BEHAVIOR,
                              app_props = 0,
                              number = NULL,
                              revision = NULL,
                              num_attributes = 0,
                              attributes = NULL,
                              layers = NULL ^
                              layers_string = NULL,
                              part_id = NULL)

       EMcreate_part ((msg),
                      (mod_env),
                      EM_LOCAL_PART,
                      (display),
                      (behavior),
                      (app_props),
                      (number),
                      (revision),
                      NULL,
                      NULL,
                      (num_attributes), 
                      (attributes),
                      (layers),
                      (layers_string),
                      (part_id),
                      NULL)
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$create_cached_part                                             |
 |                                                                           |
 | This macro is used to create a cached part. Cached parts get their        |
 | definition from some external source like a model file or a macro library |
 | For the graphic and non-graphic part it's the applications responsibility |
 | to determine where to get the attribute definition for the part. There are|
 | several types of cached parts, each requiring a specific set of           |
 | attributes:                                                               |
 |                                                                           |
 |  Reference    - This type of part references a file part which is in a    |
 |                 specified file which will be attached as a reference file.|
 |                 This type should be EM_REFERENCE_PART. In addition to the |
 |                 part number and revision, the filename attribute should   |
 |                 also be specified all other attributes will be ignored    |
 |                 since the attributes will be copied from the file part in |
 |                 the specified file. Actually the part number and revision |
 |                 may be NULL'ed out, in which case these attributes will   |
 |                 also be copied from the file part in the specified file.  |
 |                                                                           |
 |  Graphic      - This part type defines a part definition which may be     |
 |                 used to define any arbituary graphic object as a part.    |
 |                 Only the part part number and revision needs to be        |
 |                 specified as attributes. The type should be               |
 |                 EM_GRAPHIC_PART.                                          |
 |                                                                           |
 |  Non-Graphic  - This part type defines a part defintion which may be used |
 |                 to create instances which do not have any graphics        |
 |                 associated with them. The type is EM_NON_GRAPHIC.         |
 |                                                                           |
 |  Macro        - This type of local part defines a macro as a part. The    |
 |                 type that should be used is EM_MACRO_PART. In addition    |
 |                 to part number and revision, a catalog and entry attribute|
 |                 must be specified. The catalog should be set to the name  |
 |                 of the macro library and the entry should be set to the   |
 |                 name of the macro. Additionally attributes should be      |
 |                 added to the part whose name cooresponds to the names of  |
 |                 inputs to the macro. NOT SUPPORTED YET!!                  |
 |                                                                           |
 |  Cell         - This type of local part defines a cell as a part. The     |
 |                 type that should be used is EM_CELL_PART. In addition     |
 |                 to part number and revision, a catalog and entry attribute|
 |                 must be specified. The catalog should be set to the name  |
 |                 of the cell library and the entry should be set to the    |
 |                 name of the cell. NOT SUPPORTED YET!!                     |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment for part.     |
 |        IGRint            type            Type of part to create.          |
 |        IGRchar         * number          Attribute defining part number.  |
 |        IGRchar         * revision        Attribute defining part revision.|
 |        IGRchar         * filename        Filename of file part.           |
 |        IGRchar         * view            Default saved view.              |
 |        IGRint            num_attributes  Number of additional attributes. |
 |        EMattr          * attributes      Additional attributes.           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Id of newly create part.         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$create_cached_part (msg,
                               mod_env = NULL,
                               type = EM_REFERENCE_PART,
                               display = EM_DEFAULT_DISPLAY,
                               behavior = EM_DEFAULT_BEHAVIOR,
                               app_props = 0,
                               number = NULL,
                               revision = NULL,
                               filename = NULL,
                               view = NULL,
                               num_attributes = 0,
                               attributes = NULL,
                               part_id = NULL)

       EMcreate_part ((msg),
                      (mod_env),
                      (type),
                      (display),
                      (behavior),
                      (app_props),
                      (number),
                      (revision),
                      (filename),
                      (view),
                      (num_attributes), 
                      (attributes),
                      NULL,
                      NULL,
                      (part_id),
                      NULL)
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_file_part                                                  |
 |                                                                           |
 | This macro returns the file part definition for the active file.          |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment of file part. |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Id of part.                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_file_part (msg,
                          mod_env = NULL,
                          part_id = NULL)

       EMget_file_part ((msg),
                        (mod_env),
                        (part_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$part_count                                                     |
 |                                                                           |
 | This macro returns the number of part definitions of the specified type.  |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment for parts.    |
 |        IGRint            type            Cached part types.               |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * count           Number of parts.                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$part_count (msg,
                       mod_env = NULL,
                       type = EM_PART_TYPES,
                       count)	

       EMpart_count ((msg),
                     (mod_env),
                     (type),
                     (count))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_part                                                       |
 |                                                                           |
 | This macro returns a part definition of a specified type by               |
 | number/revision or index.                                                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment for parts.    |
 |        IGRint            type            Cached part types.               |
 |        IGRchar         * number          Part number.                     |
 |        IGRchar         * revision        Part revision.                   |
 |        IGRint            index           Index.                           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Id of part.                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_part (msg,
                     mod_env = NULL,
                     type = EM_PART_TYPES,
                     number = NULL,
                     revision = NULL,
                     index = -1,
                     part_id = NULL)

       EMget_part ((msg),
                   (mod_env),
                   (type),
                   (number),
                   (revision),
                   (index),
                   (part_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_part_type                                                  |
 |                                                                           |
 | This macro returns type of part.                                          |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         Part id.                         |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * type            Type of part.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_part_type (msg,
                          part_id,
                          type)

       EMget_part_type ((msg),
                        (part_id),
                        (type))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_part_identity                                              |
 |                                                                           |
 | This macro returns the part number and revision for a part.               |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         Id of part.                      |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        EMattr          * number          Part number.                     |
 |        EMattr          * revision        Part revision.                   |
 |        EMattr          * description     Part description.                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_part_identity (msg,
                              part_id,
                              number = NULL,
                              revision = NULL,
                              description = NULL)

       EMget_part_identity ((msg),
                            (part_id),
                            (number),
                            (revision),
                            (description))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_active_part                                                |
 |                                                                           |
 | This macro gets the active local part.                                    |
 |                                                                           |
 |                                                                           |
 | Output: IGRlong         * msg             Return code.                    |
 |         struct GRid     * part_id         Active part.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_active_part (msg,
                            part_id = NULL)

       EMget_active_part ((msg),
                          (part_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_active_part                                                |
 |                                                                           |
 | This macro sets the active local part. Either a local or file part may be |
 | made active. This will cause the active layer to change to the default    |
 | active layer associated with that part and for the active display to be   |
 | updated as well as updating the display of the previously active part to  |
 | it's non-active display. If no part is entered the file part will be made |
 | active.                                                                   |
 |                                                                           |
 | Input:  struct GRid     * part_id         File or local part.             |
 |                                                                           |
 | Output: IGRlong         * msg             Return code.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_active_part (msg,
                            part_id = NULL)

       EMset_active_part ((msg),
                          (part_id))
#endomdef



/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Instance Macros                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$create_instance                                                |
 |                                                                           |
 | This macro is used to create an instance of a part definition. The type   |
 | of instance which is created is determined by the part defintion that is  |
 | specified. Each type require a specific set of input arguments according  |
 | to the type of the part defintion:                                        |
 |                                                                           |
 |  Reference    - This type of instance requires a placement matrix and     |
 |                 origin to be specified. If a part_id doesn't exist for    |
 |                 for the instance already the part_id argument should be   |
 |                 set to NULL and the filename argument should be set to    |
 |                 name of the file that contains the file part to be placed.| 
 |                                                                           |
 |  Graphic      - This type of instance requires a graphic object's id to   |
 |                 specified and optionally a list of graphic roots if the   |
 |                 graphic object is associative.                            |
 |                                                                           |
 |  Nongraphic   - This type of instance doesn't require any special         |
 |                 arguments.                                                |
 |                                                                           |
 |  Macro        - This type of instance requires a list of graphic roots to |
 |                 be provided. These roots will be used to satisfy the      |
 |                 placement of the macro. NOT SUPPORTED YET!                |
 |                                                                           |
 |  Cell         - This type of instance requires a placement matrix and     |
 |                 origin to be specified. NOT SUPPORTED YET!                |
 |                                                                           |
 | General Input:                                                            |
 |        struct GRmd_env * mod_env         Module environment for part.     |
 |        struct GRid     * part_id         Id of part to instance from.     |
 |        IGRint            quantity        Number of instances to represent.|
 |        IGRint            num_attributes  Number of user attributes.       |
 |        EMattr          * attributes      User attributes.                 |
 |                                                                           |
 | Graphic Part Instance Input:                                              |
 |        IGRint            num_graphics    Number of graphic objects.       |
 |        struct GRid     * graphic_ids     Ids of graphic objects.          |
 |        IGRpoint          origin          Origin of the placement.         |
 |        struct GRid       window_id       Window id.                       |
 |     or IGRmatrix         matrix          Rotation matrix includes origin. |
 |                                                                           |
 | Non-Graphic Part Instance Input:                                          |
 |        IGRint            quantity        Especially usefull here!         |
 |                                                                           |
 | Reference Part Instance Input:                                            |
 |        IGRpoint          origin          Origin of the placement.         |
 |        struct GRid       window_id       Window id.                       |
 |        IGRchar         * view            Optional saved view.             |
 |     or IGRmatrix         matrix          Rotation matrix includes origin. |
 |        IGRchar         * filename        Filename containing part. Opt.   |
 |        IGRchar         * view            Optional saved view.             |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * instance_id     Id of newly create instance.     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$create_instance (msg,
                            mod_env = NULL,
                            type = 0,
                            display = EM_DEFAULT_DISPLAY,
                            behavior = EM_DEFAULT_BEHAVIOR,
                            app_props = 0,
                            part_id = NULL,
                            filename = NULL,
                            view = NULL,
                            number = NULL,
                            revision = NULL,
                            quantity = 1,
                            num_graphics = 0,
                            graphic_ids = NULL,
                            origin = NULL,
                            window_id = NULL,
                            matrix = NULL,
                            num_attributes = 0,
                            attributes = NULL,
                            instance_id)

       EMcreate_instance  ((msg),
                           (mod_env),
                           (type),
                           (display),
                           (behavior),
                           (app_props),
                           (part_id),
                           (filename),
                           (view),
                           (number),
                           (revision),
                           (quantity),
                           (num_graphics),
                           (graphic_ids),
                           (origin),
                           (window_id),
                           (matrix),
                           (num_attributes),
                           (attributes),
                           (instance_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$instance_count                                                 |
 |                                                                           |
 | This macro returns the number of instances for a given part definition.   |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         Part id.                         |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * count           Number of instances              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$instance_count (msg,
                           part_id,
                           count)

       EMinstance_count ((msg),
                         (part_id),
                         (count))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_instance                                                   |
 |                                                                           |
 | This macro returns a instance at the specified index.                     |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         Id of part.                      |
 |        IGRint            index           Index of the instance.           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * instance_id     Id of part.                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_instance (msg,
                         part_id,
                         index,
                         instance_id)

       EMget_instance  ((msg),
                        (part_id),
                        (index),
                        (instance_id))
#endomdef
                         
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_instance_part                                              |
 |                                                                           |
 | This macro gets the instance's part defintion.                            |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance's id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * part_id         Part id.                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_instance_part (msg,
                              instance_id,
                              part_id)

       EMget_instance_part ((msg),
                            (instance_id),
                            (part_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$num_instance_graphics                                          |
 |                                                                           |
 | This macro returns the number of graphic representations for instance.    |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance's id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * num_graphics    Number of graphics.              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$num_instance_graphics (msg,
                                  instance_id,
                                  num_graphics)

       EMnum_instance_graphics ((msg),
                                (instance_id),
                                (num_graphics))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_instance_graphics                                          |
 |                                                                           |
 | This macro returns the instance's graphic representations                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance's id.                   |
 |        IGRint          * num_graphics    Size of buffer.                  |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * num_graphics    Number of ids.                   |
 |        struct GRid     * graphic_ids     Graphic ids.                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_instance_graphics (msg,
                                  instance_id,
                                  num_graphics,
                                  graphic_ids)

       EMget_instance_graphics ((msg),
                                (instance_id),
                                (num_graphics),
                                (graphic_ids))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_instance_handle                                            |
 |                                                                           |
 | This macro returns the instance's handle.                                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance's id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * handle_id       Handle id.                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_instance_handle (msg,
                                instance_id,
                                handle_id)

       EMget_instance_handle ((msg),
                              (instance_id),
                              (handle_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_instance_type                                              |
 |                                                                           |
 | This macro returns type of part the instance was create from.             |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance id.                     |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * type            Type of part.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_instance_type (msg,
                              instance_id,
                              type)

       EMget_instance_type ((msg),
                            (instance_id),
                            (type))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Properties Macros                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_display_props                                              |
 |                                                                           |
 | This macro returns display properties of the describe, part or instance.  |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Describe/instance/part id.       |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * display         Display properties.              |
 |        IGRlong         * layers          Layers on.                       |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | The display  properties are defined in assemdef.h and are listed below    |
 | for convience:                                                            |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |  EM_HANDLE_DISPLAYED     - Should handles be displayed?                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_display_props (msg,
                              id,
                              display = NULL,
                              layers = NULL)

       EMget_display_props ((msg),
                            (id),
                            (display),
                            (layers))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_display_props                                              |
 |                                                                           |
 | This macro sets the display properties of the describe, instance or part. |
 | If a part id is supplied then that part and all it's instances will be    | 
 | set.                                                                      |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRmd_env * mod_env         Module environment for object.   |
 |        struct GRid     * id              Describe/instance/part id.       |
 |        IGRboolean        update          Update display?                  |
 |        IGRint          * display         Display properties.              |
 |        IGRlong         * layers          Layers on.                       |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | The display  properties are defined in assemdef.h and are listed below    |
 | for convience:                                                            |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |  EM_HANDLE_DISPLAYED     - Should handles be displayed?                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_display_props (msg,
                              mod_env = NULL,
                              id,
                              update = TRUE,
                              display = NULL,
                              layers = NULL)

       EMset_display_props ((msg),
                            (mod_env),
                            (id),
                            (update),
                            (display),
                            (layers))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_behavior_props                                             |
 |                                                                           |
 | This macro returns behavior properties of the describe, part or instance. |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Describe/instance/part id.       |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * behavior        Display properties.              |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | The behavior properties are defined in assemdef.h and are listed below    |
 | for convience:                                                            |
 |                                                                           |
 |  EM_PART_ACTIVE      - Local part is active part?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_behavior_props (msg,
                               id,
                               behavior)

       EMget_behavior_props ((msg),
                             (id),
                             (behavior))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_behavior_props                                             |
 |                                                                           |
 | This macro sets the behavior properties of the describe, instance or part.|
 | If a part id is supplied then that part and all it's instances will be    | 
 | set.                                                                      |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Describe/instance/part id.       |
 |        IGRint            behavior        Behavior properties.             |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | The behavior  properties are defined in assemdef.h and are listed below   |
 | for convience:                                                            |
 |                                                                           |
 |  EM_PART_ACTIVE      - Local part is active part?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_behavior_props (msg,
                               id,
                               behavior)

       EMset_behavior_props ((msg),
                             (id),
                             (behavior))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_application_props                                          |
 |                                                                           |
 | This macro returns application properties of the describe, part or        |
 | instance.                                                                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Describe/instance/part id.       |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRuint         * props           Display properties.              |
 |                                                                           |
 | Note: The application properties are defined by the high 4 bits in a long.|
 | The EM_APPLICATION_PROPS mask defines these bits, it is found in          |
 | assemdef.h                                                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_application_props (msg,
                                  id,
                                  props)

       EMget_application_props ((msg),
                                (id),
                                (props))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_application_props                                          |
 |                                                                           |
 | This macro sets the application properties of the describe, instance or   |
 | part. If a part id is supplied then that part and all it's instances will |
 | be set.                                                                   |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Describe/instance/part id.       |
 |        IGRuint           props           Application properties.          |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 | Note: The application properties are defined by the high 4 bits in a long.|
 | The EM_APPLICATION_PROPS mask defines these bits, it is found in          |
 | assemdef.h                                                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_application_props (msg,
                                  id,
                                  props)

       EMset_application_props ((msg),
                                (id),
                                (props))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Attribute Macros                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$attribute_count                                                |
 |                                                                           |
 | This macro returns the number of attributes on a part or instance.        |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Part or instance's id.           |
 |        IGRint            type            Type of attributes.              |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * count           Number of attributes             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$attribute_count (msg,
                            id,
                            type = EM_ATTRIBUTE_MEMBERS,
                            count)

       EMattribute_count ((msg),
                          (id),
                          (type),
                          (count))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_attribute                                                  |
 |                                                                           |
 | This macro an attribute by name or index.                                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Part or instance's id.           |
 |        IGRchar         * name            Name of attribute.               |
 |        IGRint            type            Type of attribute.               |
 |        IGRint            index           Index of attribute.              |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        EMattr          * attribute       Attributes                       |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_attribute (msg,
                          id,
                          name = NULL,
                          type = EM_ATTRIBUTE_MEMBERS,
                          index = -1,
                          attribute = NULL)

       EMget_attribute  ((msg),
                         (id),
                         (name),
                         (type),
                         (index),
                         (attribute))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$add_attribute                                                  |
 |                                                                           |
 | This macro adds an attribute to a part or instance object.                |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Part or instance's id.           |
 |        EMattr          * attribute       Attributes                       |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$add_attribute (msg,
                          id,
                          attribute)

       EMadd_attribute ((msg),
                        (id),
                        (attribute))
#endomdef
                         
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$link_attribute                                                 |
 |                                                                           |
 | This macro links an part specific attribute on a instance's part to the   |
 | instance.                                                                 |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * instance_id     Instance's id.                   |
 |        IGRchar         * name            Part attribute's name.           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        EMattr          * attribute       Link attribute.                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$link_attribute (msg,
                           instance_id,
                           name,
                           attribute)

       EMlink_attribute ((msg),
                         (instance_id),
                         (name),
                         (attribute))
#endomdef
                         
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$mod_attribute                                                  |
 |                                                                           |
 | This macro modifies an attribute by name or index.                        |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Part or instance's id.           |
 |        IGRchar         * name            Name of attribute.               |
 |        IGRint            type            Type of attribute.               |
 |        IGRint            index           Index of attribute.              |
 |        EMattr          * attribute       Modified attribute.              |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$mod_attribute (msg,
                          id,
                          name = NULL,
                          type = EM_ATTRIBUTE_MEMBERS,
                          index = -1,
                          attribute = NULL)

       EMmod_attribute  ((msg),
                         (id),
                         (name),
                         (type),
                         (index),
                         (attribute))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$rem_attribute                                                  |
 |                                                                           |
 | This macro removes an attribute by name or index.                         |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Part or instance's id.           |
 |        IGRchar         * name            Name of attribute.               |
 |        IGRint            type            Type of attribute.               |
 |        IGRint            index           Index of attribute.              |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$rem_attribute (msg,
                          id,
                          name = NULL,
                          type = EM_ATTRIBUTE_MEMBERS,
                          index = -1)

       EMrem_attribute  ((msg),
                         (id),
                         (name),
                         (type),
                         (index))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$next_itemno_attribute                                          |
 |                                                                           |
 | This macro returns an attribute which defines the next available item     |
 | number for a part. It's already formated for addition to the part.        |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        EMattr          * attribute       Itemno attributes                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$next_itemno_attribute (msg,
                                  mod_env = NULL,
                                  attribute)

       EMnext_itemno_attribute  ((msg),
                                 (mod_env),
                                 (attribute))
#endomdef


/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Constraint Macros                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_feature_instance                                           |
 |                                                                           |
 | This macro determines what instance the input feature belongs to. This may|
 | be used to determine the two instances that are needed to place an        |
 | assembly constraint.                                                      |
 |                                                                           |
 | Input:                                                                    |
 |       struct GRmd_env * feature_loc_env Environment feature was located in|
 |       struct GRid     * feature_id      Feature to get instance from.     |
 |                                                                           |
 | Output:                                                                   |
 |       IGRlong     * msg            Return code.                           |
 |       struct GRid * instance_id    Instance input feature belongs to.     |
 |                                                                           |
 | Return:                                                                   |
 |      ASM_S_SUCCESS                 Instance found.                        |
 |      ASM_E_ABORT                   Instance not found.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_feature_instance (msg,
                                 feature_loc_env = NULL,
                                 feature_id,
                                 instance_id)

       EMget_feature_instance ((msg), 
                               (feature_loc_env),
                               (feature_id),
                               (instance_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$add_constraint                                                 |
 |                                                                           |
 | This macro puts an assembly constraint. The features that are being used  |
 | to constrain the instances must be part of the instance. If the addition  |
 | of the constraint causes an overconstraint situation then the return msg  |
 | will be ASM_E_OVERCONSTRAINED and a list of conflicting constraint ids    |
 | are returned in the ids buffer.                                           |
 |                                                                           |
 | Input:                                                                    |
 |       IGRlong     * msg            Return code.                           |
 |       IGRint        type           The type of constraint. Defined in     |
 |                                    assemdef.h. EM_MATE, EM_ALIGN, etc.    | 
 |       struct GRid * instance1_id   1st instance to constrain.             |
 |       struct GRid * instance2_id   2nd instance to constrain.             |
 |       FEATURE_INFO *feature_1      1st feature on which constraint applies|
 |       FEATURE_INFO *feature_2      2nd feature on which constraint applies|
 |       IGRchar     * offset         Offset syntax value, any legal syntax. |
 |       IGRboolean    direction      Initial direction for the constraint.  |
 |                                                                           |
 | Output:                                                                   |
 |       IGRlong     * msg            Return code.                           |
 |       struct GRid * constraint_id  Created constraint.                    |
 |       IGRint      * num_ids        Number of ids in ids buffer.           |
 |       struct GRid **ids            Malloced buffer of object grids. If the|
 |                                    macro fails with ASM_E_OVERCONSTRAINTED|
 |                                    then the ids will be the conflicting   |
 |                                    constraints, otherwise the ids will    |
 |                                    be instances which need to be erased   |
 |                                    and displayed.                         |
 |                                                                           |
 | Return:                                                                   |
 |      ASM_S_SUCCESS                 Constraint successfully placed.        |
 |      ASM_E_OVERCONSTRAINED         Overconstrained, constraint not placed.|
 |      ASM_E_ABORT                   Catostrophic error.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$add_constraint (msg,
                           type=EM_GROUND,
                           instance1_id=NULL,
                           instance2_id,
                           feature_1=NULL,
                           feature_2=NULL,
                           offset = "0.0",
                           constraint_id,
                           num_ids=NULL,
                           ids=NULL)

       EMadd_assembly_constraint ((msg),
                                 (type), 
                                 (instance1_id), 
                                 (instance2_id),
                                 (feature_1), 
                                 (feature_2),
                                 (offset),
                                 (constraint_id),
                                 (num_ids),
                                 (ids))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$rem_constraint                                                 |
 |                                                                           |
 | This macro removes an assembly constraint.                                |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid * constraint_id  The grid of the constr to be removed. |
 |                                                                           |
 | Output:                                                                   |
 |       IGRlong     * msg           Return code.                            |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$rem_constraint(msg, 
                          constraint_id)
       EMdelete_constraint ((msg), 
                           (constraint_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Describe Macros                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$add_feature_description                                        |
 |                                                                           |
 | This macro is used to describe a feature of a part. Feature descriptions  |
 | do not show up in the bill-of-material or parts list.                     |
 |                                                                           |
 | Input:                                                                    |
 |        IGRchar         * directory       Directory for description object.|
 |        IGRchar         * name            Name for description object.     |
 |        IGRboolean        active          Make active?                     |
 |        IGRchar         * feature_name    Feature name used during locate. |
 |        struct GRid     * feature_id      Feature to describe.             |
 |        IGRint            num_attributes  Number of additional attributes. |
 |        EMattr          * attributes      Additional attributes.           |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * description_id  Id of newly created description. |
 |                                                                           |
 | Notes:                                                                    |
 |                                                                           |
 | Supplying a feature name serves to override the locate identifier for the |
 | feature. If the feature is a cylinder, normally this object would locate  |
 | as "solid cylinder - layer 1" but if a feature name such as "hole" is     |
 | specified in this macro the same object would locate as "hole - layer 1". |
 |                                                                           |
 | The feature name will be stored on the object as an attribute called      |
 | "feature_name". This attribute may be retrieved, deleted or modified      |
 | using the attribute macros described above.                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$add_feature_description (msg,
                                    directory = NULL,
                                    name,
                                    active = FALSE,
                                    feature_name = NULL,
                                    feature_id,
                                    num_attributes = 0,
                                    attributes = NULL,
                                    description_id = NULL)

       EMadd_feature_description ((msg),
                                  (directory),
                                  (name),
                                  (active),
                                  (feature_name),
                                  (feature_id),
                                  (num_attributes), 
                                  (attributes),
                                  (description_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_feature_description                                        |
 |                                                                           |
 | This macro will return the description object for a give graphic object.  |
 | This description object, if one exists, may be used to add, modify, delete|
 | and retrieve attributes which describe the graphic object using the       |
 | attribute macros defined above.                                           |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * feature_id      Feature to get description of.   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * description_id  Description object's id.         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_feature_description (msg,
                                    feature_id,
                                    description_id = NULL)

       EMget_feature_description ((msg),
                                  (feature_id),
                                  (description_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$rem_feature_description                                        |
 |                                                                           |
 | This macro is used to remove a description of a feature.                  |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * feature_id      Described feature.               |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code.                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$rem_feature_description (msg,
                                    feature_id)

       EMrem_feature_description ((msg),
                                  (feature_id))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Reporting Macros                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$create_partslist                                               |
 |                                                                           |
 | This macro is used to create a partslist.                                 |
 |                                                                           |
 | Input:                                                                    |
 |      struct GRmd_env * mod_env                                            |
 |      struct GRid     * partslist       Used for update an existing list   |
 |      IGRint            numcols         Number of columns                  |
 |      IGRchar        ** attrs           list of attribute names            |
 |      IGRchar        ** titles          list of attribute titles           |
 |      IGRint          * numcolchars     column width in chars              |
 |      IGRint          * justification   1 - CENTER 2 - LEFT 3 - RIGHT      |
 |      IGRint            crnr_flg        1 - TOP RIGHT 0 - BOTTOM RIGHT.    |
 |      LISTPARAMS      * paramvals       List format parameters             |
 |      struct     GRid * windowgrid      window id for partslist            |
 |      IGRdouble       * plcmnt_pt       corner point based on crnr_flg     |
 |      IGRchar         * viewname        plcmnt viewname                    |
 |      IGRint            ascii_out       0 - no ascii output                |
 |      IGRchar         * filename        ascii file name                    |
 |                                                                           |
 | Output:                                                                   |
 |      IGRlong         * msg             Return code, MSSUCC or MSFAIL.     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$create_partslist (msg,
                             mod_env = NULL,
                             partslist,
                             numcols,
                             attrs,
                             titles,
                             numcolchars,
                             justification,
                             paramvals,
                             crnr_flg = 1,
                             windowgrid,
                             plcmnt_pt,
			     viewname,
                             ascii_out = 0,
                             filename = NULL )


	EMpart_create_partslist ( (msg), 
                                 (mod_env),
                                 (partslist),
                                 (numcols),
                                 (attrs),
                                 (titles),
                                 (numcolchars),
                                 (justification),
                                 (paramvals),
                                 (crnr_flg),
                                 (windowgrid),
                                 (plcmnt_pt),
				 (viewname),
                                 (ascii_out),
                                 (filename) )
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_constraint_attrs                                           |
 |                                                                           |
 | This macro returns the constraint specific attributes.                    |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              constraint id.                   |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRuint         * attrs           constraint attributes.           |
 |                                                                           |
 | Note: The constraint attributes are defined in assemdef.h                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_constraint_attrs (msg,
                                 id,
                                 attrs)

       EMget_constraint_attrs ((msg),
                               (id),
                               (attrs))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_constraint_attrs                                           |
 |                                                                           |
 | This macro sets the attributes of the constraint, like EM_ALIGN_REVERSED, |
 | EM_SPECIAL_MATE ... as defined in assemdef.h                              |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * id              Constraint id.                   |
 |        IGRuint           attrs           Constraint attributes .          |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_constraint_attrs (msg,
                                 id,
                                 attrs)

       EMset_constraint_attrs ((msg),
                               (id),
                               (attrs))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_cnstr_parts_in_env                                         |
 |                                                                           |
 | This macro returns the parts with constraints in the given env upto the   |
 | given depth.                                                              |
 |                                                                           |
 | Input:                                                                    |
 |         struct GRid     * level0_part    Top level part id                |
 |         struct GRmd_env * level0_env     Top level part env               |
 |	   IGRint            options	    Options to build the list        |
 |                                          ( defined in assemdef.h )        |
 |                                            INQ_MAX_DEPTH                  |
 |                                            INQ_PROPS                      |
 |                                            INQ_PRT_WITH_INC_CNSTR         |
 |                                            INQ_PRT_WITH_OUT_CNSTR         |
 |                                            INQ_ALL_PRT_WITH_CNSTR         |
 | Input/Output:                                                             |
 |                                                                           |
 |         IGRint          * inq_depth      This is used in the manner:      |
 |                                          1. When options is set with      |
 |                                             INQ_MAX_DEPTH, the OUTPUT     |
 |                                             maximum depth is returned in  |
 |                                             this variable and NO list     |
 |                                             is returned.                  |
 |                                          2. When options is NOT set with  |
 |                                             INQ_MAX_DEPTH, the maximum    |
 |                                             depth in this variable is used| 
 |                                             to form the list.             |
 |                                                                           |
 | Output:                                                                   |
 |	   struct GRid    ** list           list of parts with constraints   |
 |         IGRint          * count          part count                       |
 |                                                                           |
 | Note:                                                                     |
 |   It is the responsibility of the caller to free the memory allocated     |
 |   to the list being returned.                                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_cnstr_prts_in_env (level0_part,
				  level0_env,
				  inq_depth,
				  options = 0,
                                  list,
				  count )

        EMget_cpart_list( (level0_part),
			  (level0_env),
			  (inq_depth),
			  (options),
			  (list), 
                          (count))
#endomdef

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_paired_parts                                               |
 |                                                                           |
 | This macro gets the parts between which the constraint is acting.         |
 | The direction is p1 --> C --> p2. ie., p2 is incident part.               | 
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * cnstrid         Constraint id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * p1_id           Part1 id                         |
 |        struct GRid     * p2_id           Part2 id                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_paired_parts (msg,
                             cnstrid,
                             p1_id = NULL,
                             p2_id = NULL)

       EMget_paired_parts ((msg),
                           (cnstrid),
                           (p1_id),
                           (p2_id))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_paired_features                                            |
 |                                                                           |
 | This function gets the features and their enviroments between which the   |
 | constraint is acting.                                                     |
 | The direction is p1 --> C --> p2. ie., p2 is incident part.               |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * cnstrid         Constraint id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * f1_id           Part1's feature id               |
 |        struct GRid     * f1_env          Part1's feature environment      |
 |        struct GRid     * f2_id           Part2's feature id               |
 |        struct GRid     * f2_env          Part2's feature environment      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_paired_features (msg,
                                cnstrid,
                                f1_id,
                                f1_env = NULL,
                                f2_id,
                                f2_env = NULL)

       EMget_paired_features ((msg),
                              (cnstrid),
                              (f1_id),
                              (f1_env),
                              (f2_id),
                              (f2_env))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_cnstr_exp_info                                             |
 |                                                                           |
 | This function gets the info about the expression connected to the         |
 | constraint.                                                               |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * cnstrid         Constraint id.                   |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        struct GRid     * exp_id          Expresssion id                   |
 |        IGRchar         * exp_name        Expression  name                 |
 |        IGRdouble       * exp_value       Expression  value                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_cnstr_exp_info (msg,
                               cnstrid,
                               exp_id = NULL,
                               exp_name = NULL,
                               exp_value )

       EMget_exp_info ((msg),
                       (cnstrid),
                       (exp_value),
                       (exp_name),
                       (exp_id))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$set_constraint_value                                           |
 |                                                                           |
 | This function sets the offset value of the expression connected to the    |
 | given constraint.                                                         |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * cnstrid         Constraint id.                   |
 |        IGRchar         * exp_syntax      Expression  syntax               |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$set_constraint_value (msg,
                                 cnstrid,
                                 exp_syntax )

       EMset_constraint_value ((msg),
                               (cnstrid),
                               (exp_syntax))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_constraints_count                                          |
 |                                                                           |
 | This macro gets the count of constraints INTO or OUT of the given part    |
 | Input:                                                                    |
 |        struct GRid     * part_id         part id                          |
 |        IGRint            in_out          0 - IN constraints only          |
 |                                          1 - OUT constraints only         |
 |                                          2 - both IN/OUT constraints      |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * count           Number of constraints            |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_constraints_count (msg,
                                 part_id,
                                 in_out = 2,
                                 count )

       EMget_constraints_count ((msg),
                               (part_id),
                               (in_out),
                               (count))
#endomdef   


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_constraint                                                 |
 |                                                                           |
 | This function gets the constraint at the given index of the given part    |
 | and also returns whether the constraint is INTO or OUT of the given part  |
 | Note: The index is counted starting from the first IN constraint to the   |
 |       last OUT constraint.                                                |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         part id                          |
 |        IGRint            index           constraint index                 |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * in_out          IN or OUT of the given part      | 
 |        IGRint          * type            type of constraint               | 
 |        struct GRid     * cnstrid        constraint id                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_constraint (msg,
                           part_id,
                           index,
                           in_out,
                           type = NULL,
                           cnstrid )

       EMget_constraint_at_index((msg),
                         	(part_id),
                         	(index),
                         	(in_out),
                         	(type),
	                        (cnstrid))
#endomdef   

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macro: asm$get_remaining_dof                                              |
 |                                                                           |
 | This macro gets the remaining dof of the given part                       |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         part id.                         |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * dof             Remaining dof                    |
 |        IGRchar         * dof_str         descriptive dof string           | 
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$get_remaining_dof (msg,
                              part_id,
                              dof,
                              dof_str= NULL)

       EMget_remaining_dof ((msg),
                            (part_id),
                            (dof),
                            (dof_str))
#endomdef   

/*---------------------------------------------------------------------------+
 |									     |
 | Macro: asm$update_part_display				             |
 |  									     |
 | This macro updates the part display                                       |
 |									     |
 | Input:  								     |
 |        struct GRid    *part_id          part id.                          |
 |        struct GRmd_env *mod_env         module environment.               |
 | Output:								     |
 |        IGRlong         *msg             Return code, MSSUCC or MSFAIL     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#omdef asm$update_part_display(msg,
			       part_id,
			       mod_env = NULL)
       EMupdate_part_display((msg),(part_id), (mod_env))
#endomdef


/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Assembly Macro Function Prototypes                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" 
{
#endif
extern IGRlong EMcreate_part __((IGRlong * msg,struct GRmd_env * mod_env,
                                 IGRint type,IGRint display, IGRint behavior,
                                 IGRuint app_props, IGRchar * number,
                                 IGRchar * revision,IGRchar * filename,
                                 IGRchar * view,IGRint num_attributes, 
                                 EMattr * attributes,IGRlong * layers,
                                 IGRchar * layers_string,struct GRid *part_id,
                                 struct GRid *ref_id));

extern IGRlong EMget_file_part __((IGRlong * msg,struct GRmd_env * mod_env,
                                  struct GRid * part_id));
extern IGRlong EMpart_count __((IGRlong * msg, struct GRmd_env * mod_env,
                                IGRint type, IGRint * count));
extern IGRlong EMget_part __((IGRlong * msg,struct GRmd_env * mod_env,
                              IGRint type, IGRchar * number,
                              IGRchar * revision,
                              IGRint index, struct GRid * part_id));
extern IGRlong EMget_part_type __((IGRlong * msg,struct GRid * part_id,
                                  IGRint * type));
extern IGRlong EMget_part_identity __((IGRlong * msg, struct GRid * part_id,
                                       EMattr * number, EMattr * revision,
                                       EMattr * description));

extern IGRlong EMget_active_part __((IGRlong * msg, struct GRid * part_id));
extern IGRlong EMset_active_part __((IGRlong * msg, struct GRid * part_id));

extern IGRlong EMconstruct_reffile __((IGRlong * msg,struct GRmd_env * mod_env,
                                      IGRchar * filename,IGRchar * view,
                                      IGRuint props,IGRuint ref_props,
                                      IGRchar * name,IGRdouble * origin,
                                      IGRdouble * matrix,
                                      struct GRid * reffile_id));
extern IGRlong EMconstruct_handle __((IGRlong * msg,struct GRmd_env * mod_env,
                                     IGRuint props,IGRchar * name,
                                     IGRdouble * origin,
                                     IGRdouble * matrix,struct GRid * handle_id));
extern IGRlong EMcreate_instance __((IGRlong * msg,struct GRmd_env * mod_env,
                                     IGRint type, IGRint display, IGRint behavior,
                                     IGRuint app_props,struct GRid * part_id,
                                     IGRchar * filename,IGRchar * view,
                                     IGRchar * number,IGRchar * revision,
                                     IGRint quantity,IGRint num_graphics, 
                                     struct GRid * graphic_ids,IGRdouble * origin,
                                     struct GRid * window_id,IGRdouble * matrix,
                                     IGRint num_attributes, EMattr * attributes,
                                     struct GRid * instance_id));
extern IGRlong EMinstance_count __((IGRlong * msg,struct GRid * part_id,IGRint * count));
extern IGRlong EMget_instance __((IGRlong * msg,struct GRid  * part_id,IGRint index,
                                 struct GRid  * instance_id));
extern IGRlong EMget_instance_part __((IGRlong * msg,struct GRid * instance_id,
                                      struct GRid * part_id));

extern IGRlong EMnum_instance_graphics __((IGRlong * msg,
                                           struct GRid * instance_id,
                                           IGRint * num_graphics));
extern IGRlong EMget_instance_graphics __((IGRlong * msg,
                                           struct GRid * instance_id,
                                           IGRint * num_graphics,
                                           struct GRid  * graphic_ids));
extern IGRlong EMget_instance_handle __((IGRlong * msg,
                                         struct GRid * instance_id,
                                         struct GRid  * handle_id));
extern IGRlong EMget_instance_name __((IGRlong * msg,struct GRid * instance_id,
                                      IGRchar * name));
extern IGRlong EMset_instance_name __((IGRlong * msg,struct GRid * instance_id,
                                      IGRchar * name));
extern IGRlong EMget_instance_type __((IGRlong * msg,struct GRid * instance_id,
                                      IGRint * type));

extern IGRlong EMget_display_props __((IGRlong * msg,struct GRid * id,
                                       IGRint * display, IGRlong * layers));
extern IGRlong EMset_display_props __((IGRlong * msg,struct GRmd_env * mod_env,
                                       struct GRid * id,IGRboolean update,
                                       IGRint * display, IGRlong * layers));
extern IGRlong EMget_behavior_props __((IGRlong * msg,struct GRid * id,
                                       IGRint * behavior));
extern IGRlong EMset_behavior_props __((IGRlong * msg,struct GRid * id,
                                        IGRint behavior));
extern IGRlong EMget_application_props __((IGRlong * msg,struct GRid * id,
                                           IGRuint * props));
extern IGRlong EMset_application_props __((IGRlong * msg,struct GRid * id,
                                           IGRuint props));
extern IGRlong EMattribute_count __((IGRlong * msg,struct GRid * id,IGRint type,IGRint * count));
extern IGRlong EMget_attribute __((IGRlong * msg,struct GRid * id,IGRchar * name,
                                  IGRint type,IGRint index,EMattr * attribute));
extern IGRlong EMadd_attribute __((IGRlong * msg,struct GRid * id,EMattr * attribute));
extern IGRlong EMlink_attribute __((IGRlong * msg,struct GRid * instance_id,
                                    IGRchar * name, EMattr * attribute));
extern IGRlong EMmod_attribute __((IGRlong * msg,struct GRid * id,IGRchar * name,
                                  IGRint type,IGRint index,EMattr * attribute));
extern IGRlong EMrem_attribute __((IGRlong * msg,struct GRid * id,IGRchar * name,
                                  IGRint type,IGRint index));
extern IGRlong EMnext_itemno_attribute  __((IGRlong * msg,struct GRmd_env * mod_env,
                                            EMattr * attribute));
extern IGRboolean EMis_feature_instance __((IGRlong * msg,struct GRid * id,
                                           struct GRid * instance_id));
extern IGRlong EMget_feature_instance __((IGRlong * msg,
                                          struct GRmd_env * mod_env,
                                         struct GRid * id,
                                          struct GRid * instance_id));
extern IGRlong EMadd_assembly_constraint __((IGRlong *msg,IGRint type,
                                             struct GRid * instance1_id,
                                             struct GRid * instance2_id,
                                             FEATURE_INFO * feature_1,
                                             FEATURE_INFO * feature_2,
                                             IGRchar * offset,
                                             struct GRid * constraint_id,
                                             IGRint * num_ids,
                                             struct GRid **ids));
#if defined(__cplusplus)
}
#endif
#endif

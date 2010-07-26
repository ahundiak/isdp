/******************************************************************************

part.h

General Description:

    This file contains the structure used in the construction of 
    GRpart objects.

Structures defined:
     
    GRpart_class_attr       - construction class attributes
                    
Dependencies:

    partdef.h
              
History:

     2/9/90   Jay Wallingford     Creation Date
     
*******************************************************************************/

#ifndef part_include
#define part_include

/******************************************************************************

Structure:
    
    GRpart_class_attr

    This structure is used when constructing a part. A part is constructed
    from a list of graphics, static attributes, and dynamics attributes. 
    Static attributes are shared among all parts of a particular type. When 
    a static attribute is changed on one part it is changed for all parts of 
    that type. Dynamic attributes contain information which is specific to
    an individual part such as position, amount, etc. A list of part types
    is used to indicate the type of an attribute/value pair.

Note:

    There MUST be at least 2 static attribute/value pairs specified on 
    construction :

        o The first MUST be an attribute/value pair describing a
          unique part number. The value string will be used to 
          construct the part directory in the partslist directory
          that you specify.

        o The second MUST be an attribute/value pair for the part
          description. The first 29 characters of this description 
          will be displayed when the part is located. The 29 
          charater limit is a limitation of the GRgraphics.GRgetobjinfo 
          method.

    No dynamic attribute/value pairs are required on construction.
    
Example:

    struct GRpart_class_attr    part_attr;
    IGRchar * attr[2], * value[2];
    IGRchar attr_data[2][MAX_ATTR], value_data[2][MAX_VALUE];
    IGRint  type[2];

    attr[0] = attr_data[0]; value[0] = value_data[0];
    attr[1] = attr_data[1]; attr[1] = attr_data[1];

    strcpy(attr_data[0], "Number");
    strcpy(attr_data[1], "Name");
    strcpy(value_data[0], "BOLT1A");
    strcpy(value_data[1], "Part Number: BOLT1A, Source: ABC Fasteners");
    type[0] = type[0] = GR_STATIC_ATTR;

    part_attr.parts_dir = ":myfile:usr:myapp:PARTS"
    part_attr.attr = attr;
    part_attr.value = value;
    part_attr.type = type;
*******************************************************************************/

/*
 * Limits for attribute name/value pairs.
 */
#define MAX_ATTR        30  /* Maximum size of an attribute name  */
#define MAX_VALUE       256 /* Maximum size of an attribute value */

/*
 * Types of attributes that may be added to a part. 
 * Maximum of 8 types.
 */
#define GR_STATIC_ATTR      0x01
#define GR_DYNAMIC_ATTR     0x02

/*
 * Attribute types which are updated automatically between parts 
 * of the same type.
 *
 * There are 8 different part types available. The GRpart class uses two
 * of these, GR_STATIC_ATTR and GR_DYNAMIC_ATTR, leaving 6 attribute types
 * available for applications to use when subclassing off GRpart. The 
 * GR_COMMON_ATTR mask is used to specify attribute types which should have 
 * the same general behavior as the static attributes.
 */
#define GR_COMMON_ATTR  GR_STATIC_ATTR

struct GRpart_class_attr
{
    IGRchar *   parts_dir;
    IGRchar *   catalog;
    IGRchar *   number;
    IGRchar *   revision;
    IGRchar *   description;
    IGRchar **  attr;
    IGRchar **  value;
    IGRint  *   type;
    IGRint      num;
};

#endif

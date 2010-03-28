/*
Abstract
        The class for units of measure
Notes
        The UOM manager mantains global hash tables and circular lists.
        At wake_up time, all uom_tables from inner most to outer most
        product are read and merged together. The tables & lists are
        constructed by merging the super information with the uom_table
        lists.  The information in the super takes precedence.
         
        Unit/variant information is marked for saving in the super
        whenever a unit type is modified or any conversion to/from
        a unit alias.  At sleep time all unit types and variants that
        are marked for saving a stored in the super.
History
        ELP     12/05/91 : modified version of original uom implementation
                           written by Richard Eade
*/

class specification UOMsuper (2:0) of global_class;

#include "igrtypedef.h"
#include "UOMdef.h"
#include "UOM.h"

instance UOMsuper {
/*
 *  List of unit types.  A unit type carries its name, dimensions, default
 *  aliases, and readout specs.  Indicies into this table are stored with
 *  variants.
 */
  variable UOMS_TYPE type[];
/*
 *  List of unit variants.  Each unit type can have many ways to represent
 *  itself.  This is called a unit variant.  A variant carries a pointer
 *  (actually an index) into the type table, a pointer (actually an index)
 *  into the pkey table, a scale & shift factor.
 */
  variable UOMS_VARIANT variant[];
/*
 *  List of NULL terminated strings.  Each string is a set of alises for
 *  an above variant.  The set of aliases for a variant is separated by
 *  a space.  Indicies into this table are stored with variants.
 */
  variable char pkey[];
};
#ifndef BASE_EMS
override
  sleep,         /* merge global units info. into my info */
  wake_up,       /* Need to merge my info with global units info. */
  debug;         /* Dump stored units tables */

/* PRIVATE */
message store_unit_type( UOM_TYPE *type );
/*
Abstract
     This routine stores a unit type into the UOM super
Arguments
     *type        UOM_TYPE       unit type data
Return Values
     UOM_S_SUCCESS              - success
     UOM_E_UNEXPECTED_NULL_PTR  - type arg null
     odd return codes indicate  - success
     even return codes indicate - failure
*/

/* PRIVATE */
message store_unit_variant( char *typename; UOM_VARIANT *variant );
/*
Abstract
     This routine stores a unit variant into the UOM super
Arguments
     *typename    char           name of unit type to store variant into
     *variant     UOM_VARIANT    variant data
Return Values
     UOM_S_SUCCESS              - success
     OM_E_NODYNMEM              - no dynamic memory
     UOM_E_TYPE_NOT_FOUND       - unit type 'typename' not found
     UOM_E_UNEXPECTED_NULL_PTR  - typename or variant arg null
     odd return codes indicate  - success
     even return codes indicate - failure
*/

/* PRIVATE */
message store_unit_readout( char *typename;
                            UOM_READOUT *primary, *secondary, *tertiary );
/*
Abstract
     This routine stores a readout specs into the UOM super
Arguments
     *typename    char           name of unit type to store readout specs into
     *primary     UOM_READOUT    optional - primary readout data
     *secondary   UOM_READOUT    optional - secondary readout data
     *tertiary    UOM_READOUT    optional - tertiary readout data
Return Values
     UOM_S_SUCCESS              - success
     UOM_E_TYPE_NOT_FOUND       - unit type 'typename' not found
     UOM_E_UNEXPECTED_NULL_PTR  - typename arg null
     odd return codes indicate  - success
     even return codes indicate - failure
*/

/* PRIVATE */
message store_list( UOM_TYPE **uom_types );
/*
Abstract
     This routine stores types & variants that have been marked for
     saving into the UOM super
Arguments
     **uom_types  UOM_TYPE       the list of unit types to store
Return Values
     UOM_S_SUCCESS              - success
     odd return codes indicate  - success
     even return codes indicate - failure
*/

/* PRIVATE */
message retrieve_list( UOM_TYPE **uom_types );
/*
Abstract
     This routine retrieves the list of unit types & variants stored
     in the UOM super
Arguments
     **uom_types  UOM_TYPE       the list of unit types stored
Notes
     deallocate uom_types using
       UOM_free_type( &uom_types )
Return Values
     UOM_S_SUCCESS              - success
     odd return codes indicate  - success
     even return codes indicate - failure
*/
#endif /* BASE_EMS */
message get_distance_units( char units[] );

end specification UOMsuper;

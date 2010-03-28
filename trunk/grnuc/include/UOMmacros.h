#ifndef UOMmacros_included
#define UOMmacros_included 1

#include "UOMdef.h"
#include "UOM.h"
#include "UOMextern.h"

/*----------------------- uom$get_super  ------------------------------

  uom$get_super( osnum,
                 p_objid )

  Abstract:
     This macro retrieves the UOM super object id

  Arguments:
     OMuword      osnum         i   the os to retrieve from
     OM_S_OBJID   *p_objid      o   the UOM super object id
 
  Sample Call:
     int sts;
     OM_S_OBJID super;

     sts = uom$get_super( p_objid = &super );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_I_CREATED -  Success, super was created
     UOM_S_SUCCESS -  Success, super already exists
     UOM_E_UNEXPECTED_NULL_PTR - p_objid arg null
*/

#omdef uom$get_super( osnum = OM_Gw_current_OS,
                      p_objid )

  UOM_get_super_objid( (osnum), (p_objid) )

#endomdef

/*----------------------- uom$get_dimensions  ------------------------------

  uom$get_dimensions( osnum,
                      typename,
                      aliasname,
                      dims )

  Abstract:
     This macro retrieves the dimensions for a unit type given a unit type
     name or an unit alias name.
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *typename    i   the unit type name
     char          *aliasname   i   the unit alias name
                                    an aliasname may be type qualified
                                      ex.  qualified -> "mm:distance"
                                      ex.  non-qualified -> "mm"
     UOMdimensions dims         o   the dimensions for requested unit
 
  Sample Call:
     int sts;

     sts = uom$get_dimensions( typename = GRIO_DISTANCE, dims = dims );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_ALIAS_NOT_FOUND -  unit alias not found
     UOM_E_UNEXPECTED_NULL_PTR - typename and aliasname or dims args null
*/

#omdef uom$get_dimensions( osnum = OM_Gw_current_OS,
                           typename = NULL ^
                           aliasname = NULL,
                           dims )

#if !om$specified (typename) && !om$specified (aliasname)
# omerror "Must specify <typename> or <aliasname>"
#else
  UOM_lookup_dims( (osnum), (typename), (aliasname), (dims) )
#endif

#endomdef

/*----------------------- uom$get_variant  ------------------------------

  uom$get_variant( osnum,
                   aliasname,
                   pp_variant )

  Abstract:
     This macro retrieves the data for the specified unit alias
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *aliasname   i   the unit alias name
                                    an aliasname may be type qualified
                                      ex.  qualified -> "mm:distance"
                                      ex.  non-qualified -> "mm"
     UOM_VARIANT   **pp_variant o   pointer to variant data
 
  Notes:
     pp_variant is READONLY data.

  Sample Call:
     int sts;
     UOM_VARIANT *variant;

     sts = uom$get_variant( aliasname = "inches", pp_variant = &variant );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_ALIAS_NOT_FOUND -  unit alias not found
     UOM_I_ALIAS_TRUNCATED - found a variant but unit alias was truncated
     UOM_I_TYPE_TRUNCATED - found a variant but aliasname unit type qualifier
                            was truncated
     UOM_E_UNEXPECTED_NULL_PTR - aliasname or pp_variant arg null
*/

#omdef uom$get_variant( osnum = OM_Gw_current_OS,
                        aliasname,
                        pp_variant )

  UOM_lookup_alias( (osnum), (aliasname), (pp_variant) )

#endomdef

/*----------------------- uom$get_type  ------------------------------

  uom$get_type( osnum,
                typename,
                dims,
                pp_type )

  Abstract:
     This macro retrieves the data for the specified unit type
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *typename    i   the unit type name
     UOMdimensions dims         i   the dimensions of a unit type
     UOM_TYPE      **pp_type    o   pointer to type data
 
  Notes:
     pp_type is READONLY data.

  Sample Call:
     int sts;
     UOM_TYPE *type;

     sts = uom$get_type( typename = GRIO_DISTANCE, pp_type = &type );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_I_TYPE_TRUNCATED - found a type but typename was truncated
     UOM_E_UNEXPECTED_NULL_PTR - typename or pp_type arg null
*/

#omdef uom$get_type( osnum = OM_Gw_current_OS,
                     typename = NULL ^
                     dims = NULL,
                     pp_type )

#if !om$specified (typename) && !om$specified (dims)
# omerror "Must specify <typename> or <dims>"
#else
  UOM_lookup_type( (osnum), (typename), (dims), (pp_type) )
#endif

#endomdef

/*----------------------- uom$get_readout  ------------------------------

  uom$get_readout( osnum,
                   typename,
                   primary,
                   secondary,
                   tertiary )

  Abstract:
     This macro retrieves the readout specs for a unit type
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *typename    i   the unit type name
     UOM_READOUT   *primary     o   optional - primary readout specs
     UOM_READOUT   *secondary   o   optional - secondary readout specs
     UOM_READOUT   *tertiary    o   optional - tertiary readout specs
 
  Sample Call:
     int sts;
     UOM_READOUT primary;

     sts = uom$get_readout( typename = GRIO_DISTANCE, primary = &primary );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_UNEXPECTED_NULL_PTR - typename arg null
*/

#omdef uom$get_readout( osnum = OM_Gw_current_OS,
                        typename,
                        primary = NULL,
                        secondary = NULL,
                        tertiary = NULL )

  UOM_readout_spec( (osnum), (typename), 1, (primary), (secondary), (tertiary) )

#endomdef

/*----------------------- uom$set_readout  ------------------------------

  uom$set_readout( osnum,
                   typename,
                   primary,
                   secondary,
                   tertiary )

  Abstract:
     This macro stores the readout specs for a unit type
     
  Arguments:
     OMuword       osnum        i   the os to store into
     char          *typename    i   the unit type name
     UOM_READOUT   *primary     o   optional - primary readout specs
     UOM_READOUT   *secondary   o   optional - secondary readout specs
     UOM_READOUT   *tertiary    o   optional - tertiary readout specs
 
  Sample Call:
     int sts;
     UOM_READOUT primary;

       ... code to fill in primary readout structure ...

     sts = uom$set_readout( typename = GRIO_DISTANCE, primary = &primary );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_UNEXPECTED_NULL_PTR - typename arg null
*/

#omdef uom$set_readout( osnum = OM_Gw_current_OS,
                        typename,
                        primary = NULL,
                        secondary = NULL,
                        tertiary = NULL )

  UOM_readout_spec( (osnum), (typename), 0, (primary), (secondary), (tertiary) )

#endomdef

/*----------------------- uom$cvt_to_readout  ----------------------------

  uom$cvt_to_readout( osnum,
                      ivalue,
                      ialias,
                      typename,
                      num_oalias,
                      oalias,
                      readout,
                      field_size,
                      fraction_mode,
                      out_buf )

  Abstract:
     This macro converts a value to a string.  The string format is derived
     from the input readout specs (if specfied) or the default readout specs
     for the given output aliases.
     
  Arguments:
     OMuword       osnum        i   the os to convert from
     double        ivalue       i   the value to convert to readout format
     char          *ialias      i   optional -
                                      if specified
                                        denotes units in which ivalue
                                        is in.  ialias may be type
                                        qualified
                                          ex.  qualified -> "mm:distance"
                                          ex.  non-qualified -> "mm"
                                      otherwise
                                        denotes ivalue in dbu's
     char          *typename    i   optional -
                                      if specified && oalias not specified
                                        uses the default aliases & readout
                                        specs for the specified unit type
     int           *num_olias   i   optional -
                                      if specified
                                        denotes number of output aliases in
                                        oalias
     UOMalias_name *oalias      i   optional -
                                      if specified
                                        array of aliases to be used
     UOM_READOUT   *readout     i   optional -
                                      if specified
                                        overrides default primary readout
                                      otherwise
                                        uses default primary readout
     short         *field_size  i   optional -
                                      size of out_buf
     short         *fraction_mode i optional -
                                      if specified
                                        deterimes if fractional part of value
                                        is returned as ascii or single
                                        fractional string.
     char          *out_buf     o   the formated value
 
  Sample Call:
     int sts;
     short field_size = 132;
     char buff[132];

     sts = uom$cvt_to_readout( ivalue = 1.0, ialias = "feet",
                               field_size = &field_size,
                               typename = GRIO_DISTANCE,
                               out_buf = buff );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_UNEXPECTED_NULL_PTR - typename arg null
*/

#omdef uom$cvt_to_readout( osnum = OM_Gw_current_OS,
                           ivalue,
                           ialias = NULL,
                           typename = NULL,
                           num_oalias = NULL,
                           oalias = NULL,
                           readout = NULL,
                           field_size = NULL,
                           fraction_mode = NULL,
                           out_buf )

#if !om$specified (typename) && !om$specified (oalias)
# omerror "Must specify <typename> or <oalias>"
#else
  UOM_convert_to_readout( (osnum), (ivalue), (ialias), (typename), (num_oalias),
                          (oalias), (readout), (field_size), (fraction_mode),
                          (out_buf) )
#endif

#endomdef

/*----------------------- uom$add_notify_function  ----------------------------

  uom$add_notify_function( func )

  Abstract:
     This macro adds func to the list of notify functions.  When the UOM
     super receives a request to update default aliases or readout specs
     for a unit type all the notify functions are called.

     The function called should be written as follows:

     int func( osnum, typename, default_changed )
     OMuword osnum;               os in which change occured
     char *typename;              unit type in which change occured
     int default_changed;         1 => default aliases changed
                                  0 => readout changed
     {
       ...
       return 1;
     }
     
  Arguments:
     int           (*func)()    i   pointer to a function to added
 
  Sample Call:
     int sts;

     extern int app_notify_func();

     sts = uom$add_notify_function( func = app_notify_func );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$add_notify_function( func )

  UOM_add_function( (func) )

#endomdef

/*----------------------- uom$del_notify_function  ----------------------------

  uom$del_notify_function( func )

  Abstract:
     This macro removes func from the list of notify functions.
     
  Arguments:
     int           (*func)()    i   pointer to a function to remove
 
  Sample Call:
     int sts;

     extern int app_notify_func();

     sts = uom$del_notify_function( func = app_notify_func );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$del_notify_function( func )

  UOM_del_function( (func) )

#endomdef

/*----------------------- uom$get_type_dbu  ----------------------------

  uom$get_type_dbu( osnum, typename, alias )

  Abstract:
     This macro retrieves the dbu alias for the given unit type
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *typename    i   the unit type name
     char          *alias       o   the dbu for the given unit type
 
  Sample Call:
     int sts;
     UOMalias_name dbualias;

     sts = uom$get_type_dbu( typename = GRIO_DISTANCE, alias = dbualias );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND - the specified unit type was not found
     UOM_E_ALIAS_NOT_FOUND - the dbu alias for the specified unit type
                             was not found
*/

#omdef uom$get_type_dbu( osnum = OM_Gw_current_OS,
                         typename,
                         alias )

  UOM_get_type_dbu( osnum, typename, alias )

#endomdef

/*----------------------- uom$get_defaults  ------------------------------

  uom$get_defaults( osnum,
                    typename,
                    num_defaults,
                    defaults )

  Abstract:
     This macro retrieves the default aliases for a unit type
     
  Arguments:
     OMuword       osnum        i   the os to retrieve from
     char          *typename    i   the unit type name
     int           *num_defaults o  number of defaults
     UOMalias_name *defaults    o   the default aliases for specified unit type
 
  Sample Call:
     int sts;
     int ndfs;
     UOMalias_name dfs[ UOM_K_MAX_DEFS ];

     sts = uom$get_defaults( typename = GRIO_DISTANCE, num_defaults = &ndfs,
                             defaults = dfs );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_UNEXPECTED_NULL_PTR - typename arg null
*/

#omdef uom$get_defaults( osnum = OM_Gw_current_OS,
                         typename,
                         num_defaults,
                         defaults )

  UOM_default_units( (osnum), (typename), 1, (num_defaults), (defaults) )

#endomdef

/*----------------------- uom$set_defaults  ------------------------------

  uom$set_defaults( osnum,
                    typename,
                    num_defaults,
                    defaults )

  Abstract:
     This macro stores the default aliases for a unit type
     
  Arguments:
     OMuword       osnum        i   the os to store into
     char          *typename    i   the unit type name
     int           *num_defaults i  number of defaults
     UOMalias_name *defaults    i   the default aliases for specified unit type
 
  Sample Call:
     int sts;
     int ndfs;
     UOMalias_name dfs[ UOM_K_MAX_DEFS ];

     ndfs = 3;
     strcpy( dfs[0], "yards" );
     strcpy( dfs[1], "feet" );
     strcpy( dfs[2], "inches" );
     
     sts = uom$set_defaults( typename = GRIO_DISTANCE, num_defaults = &ndfs,
                             defaults = dfs );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_TYPE_NOT_FOUND -  unit type not found
     UOM_E_UNEXPECTED_NULL_PTR - typename arg null
*/

#omdef uom$set_defaults( osnum = OM_Gw_current_OS,
                         typename,
                         num_defaults,
                         defaults )

  UOM_default_units( (osnum), (typename), 0, (num_defaults), (defaults) )

#endomdef

/*----------------------- uom$cvt_value_to_dbu  ------------------------------

  uom$cvt_value_to_dbu( osnum,
                        ivalue,
                        ialias,
                        ovalue,
                        dims )

  Abstract:
     This macro converts a value in specified units to data base units
     
  Arguments:
     OMuword       osnum         i  the os to convert from
     double        ivalue        i  the value to convert
     char          *ialias       i  optional -
                                      if specified
                                        denotes units in which ivalue
                                        is in.  ialias may be type
                                        qualified
                                          ex.  qualified -> "mm:distance"
                                          ex.  non-qualified -> "mm"
                                      otherwise
                                        denotes ivalue in dbu's
     double        *ovalue       o  the value in dbu's
     UOMdimensions dims          o  optional -
                                      if specified
                                        dimensions of input as found thru
                                        alias lookup
 
  Sample Call:
     int sts;
     double distdbu;

     sts = uom$cvt_value_to_dbu( ivalue = 2.0, ialias = "feet",
                                 ovalue = &distdbu );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_ALIAS_NOT_FOUND -  alias not found
*/

#omdef uom$cvt_value_to_dbu( osnum = OM_Gw_current_OS,
                             ivalue,
                             ialias = NULL,
                             ovalue,
                             dims = NULL )

  UOM_convert_value_to_dbu( (osnum), (ivalue), (ialias), (ovalue), (dims) )

#endomdef

/*----------------------- uom$cvt_dbu_to_value  ------------------------------

  uom$cvt_dbu_to_value( osnum,
                        ivalue,
                        oalias,
                        ovalue )

  Abstract:
     This macro converts a value in data base units to specified units
     
  Arguments:
     OMuword       osnum         i  the os to convert from
     double        ivalue        i  the value in dbu's
     char          *oalias       i  optional -
                                      if specified
                                        denotes units in which ovalue
                                        will be in.  oalias may be type
                                        qualified
                                          ex.  qualified -> "mm:distance"
                                          ex.  non-qualified -> "mm"
                                      otherwise
                                        denotes ovalue in dbu's
     double        *ovalue       o  the value converted
 
  Sample Call:
     int sts;
     double feet;

     sts = uom_cvt_dbu_to_value( ivalue = 24.0, oalias = "feet",
                                 ovalue = &feet );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
     UOM_E_ALIAS_NOT_FOUND -  alias not found
*/

#omdef uom$cvt_dbu_to_value( osnum = OM_Gw_current_OS,
                             ivalue,
                             oalias = NULL,
                             ovalue )

  UOM_convert_dbu_to_value( (osnum), (ivalue), (oalias), (ovalue) )

#endomdef

/*----------------------- uom$cvt_value_to_value  ----------------------------

  uom$cvt_value_to_value( msg,
                          unit_type,
                          osnum,
                          alias_to_cvt_from,
                          alias_to_cvt_to,
                          num_vals,
                          values_in,
                          values_out )

  ABSTRACT:
  --------- 
     This macro will convert values in a specified unit to a value of
   another unit type.  Any number of values may be converted in one call. 
   All unit conversions are performed in DPFP arithmethic.


  ARGUMENTS:
  ----------   

   *msg               IGRlong     o - same as macro status

   *unit_type         IGRchar     i - Indicates what type of unit conversion is
                                      performed.  For example,
                                         GRIO_DISTANCE converts to distance
                                         GRIO_ANGLE    converts to angle
                                         GRIO_AREA     converts to area

    osnum             OMuword     i -  object space conversion is to occur in.
                                          
   *alias_to_cvt_from IGRchar     i -  This describes the unit type of the 
                                       input values.  If NULL, then we assume
                                       the conversion is from working units.

   *alias_to_cvt_to   IGRchar     i -  This describes the unit type of the 
                                       output values.  If NULL, then we assume
                                       the conversion is to working units.
                                      
    num_vals          IGRint      i - The number of values to convert.
    
   *values_in         IGRdouble[] i - The array of values to convert.
   
   *values_out        IGRdouble[] o - The array of converted values.  May
                                      occupy the same sapce as values_in.
    
 Sample Call:
   int status;
   double values_in[2], values_out[2];
 
   values_in[0] = 42.0;
   values_in[1] = 12.0;

   status = uom$cvt_value_to_value( msg = &msg,
                                    unit_type = GRIO_DISTANCE ,
                                    alias_to_cvt_from = "inches",
                                    alias_to_cvt_to = "feet",
                                    num_vals = 2,
                                    values_in = values_in,
                                    values_out = values_out );
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success

*/

#omdef uom$cvt_value_to_value( msg, 
                               unit_type,
                               osnum = OM_Gw_current_OS,
                               alias_to_cvt_from = NULL,
                               alias_to_cvt_to = NULL,
                               num_vals,
                               values_in,
                               values_out )

  UOM_cvt_value_to_value( (msg), (unit_type), (osnum), (alias_to_cvt_from),
                          (alias_to_cvt_to), (num_vals), (values_in),
                          (values_out) )

#endomdef 

/*----------------------- uom$cvt_imp_to_alias  ------------------------------

       uom$cvt_imp_to_alias( msg,
                             unit_type,
                             osnum,
                             working_units,
                             num_alias,
                             num_conversions,
                             readout_spec,
                             field_size,
                             inverse_scale_flag,
                             fraction_mode,
                             cvt_list )
                 
       ABSTRACT:
       ---------   
          This macro will convert from a number of working units to the
       number of default output units.  This number will be place in cvt_list
       postfixed by the alias of that unit.  All conversions will be based
       upon what is stored in the unit of measurement object as the default
       output alias. Therefore, if only a primary unit is stored for output
       conversion only one string will be returned in cvt_list.

 Arguments:

   *msg            IGRlong       same as macro status

   *unit_type      IGRchar       Indicates what type of unit conversion is
                                 performed.  For example,
                                   GRIO_DISTANCE converts to distance
                                   GRIO_ANGLE    converts to angle
                                   GRIO_AREA     converts to area
                                  
    osnum          OMuword        object space conversion is to occur in.

   *working_units  IGRdouble      number of working units to convert.
   
   *num_alias      IGRshort       number of default aliases to process to
                                  (i.e if default output aliases were
                                  set to yards, feet, and inches via the
                                  MD=, and num_alias was passed equal to
                                  2. The results would be calc. in yards
                                  and feet.)
                                  
    num_conversions IGRshort      several conversions can occur with 
                                  only one call.  This variable indicates
                                  how many conversions are to occur.
                                  If num_conversions is greater than 1, 
                                  working_units should be an array of doubles,
                                  and cvt_list should be an array of pointers
                                  to character.
    
    *readout_spec  struct GRIOreadout_spec
                                  If the calling program does not wish to 
                                  use the currently defined readout spec
                                  a overriding readout spec can be passed in.
                                                              
    *field_size    IGRshort       size of field returned string will fix in,
                                  required for proper justification of text.

    inverse_scale_flag IGRshort   indicates whether or not to apply the
                                  inverse scaling factor.  If the unit type
                                  is not scalable this argument is ignored.
                                  The flag is an index that detremines which
                                  of the ACS scales (x,y,z,etc) is inverted an
                                  applied to the results.

    *fraction_mode IGRshort       the fractional part of the returned value may
                                  be returned as a decimal, as ascii characters
                                  representing a fraction or as a single 
                                  fractional character.  If this variable is not
                                  null, it specifies the mode, otherwise the
                                  dpb value is used.
                                   
    *cvt_list      IGRchar        an array of characters to place ascii text in.
   

 Sample Call:
   int status;
 
   status = uom$cvt_imp_to_alias( msg =  &msg,
                                  unit_type = GRIO_DISTANCE,
                                  working_units = &working_units,
                                  num_alias = &num_alias,
				  cvt_list = output_string );
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
*/

#omdef uom$cvt_imp_to_alias( msg,
                             unit_type,
                             osnum = OM_Gw_current_OS,
                             working_units,
                             num_alias,
                             num_conversions = 1,
                             readout_spec = NULL,
                             field_size = NULL,
                             inverse_scale_flag = GRIO_X_SCALE,
                             fraction_mode = NULL,
                             cvt_list )

  UOM_cvt_imp_to_alias( (msg), (unit_type), (osnum), (working_units),
                        (num_alias), (num_conversions),
                        (readout_spec), (field_size),
                        (inverse_scale_flag), (fraction_mode),
                        (cvt_list) )

#endomdef

/*-------------------------- uom$cvt_exp_to_alias ----------------------------

        uom$cvt_exp_to_alias( msg,
                              unit_type,
                              osnum,
                              num_def,
                              output_alias,
                              working_units,
                              readout_spec,
                              field_size,
                              inverse_scale_flag,
                              fraction_mode,
                              cvt_list )


       ABSTRACT:
       ---------   
          This macro will convert from a number of working units to the
       number of output units.  This number will be place in cvt_list
       postfixed by the alias of that unit.  All conversions will be based
       upon whatis passed in the output_alias array.  Therefore, if only a 
       primary unit is passed in output_alias only one string will be 
       returned in cvt_list.

 Arguments:

   *msg            IGRlong        same as macro status

   *unit_type      IGRchar        Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
                                      
   *num_def        IGRshort       number of output aliases
   
   *output_alias   GRIOalias_name an array of aliases to be used in conversions
    
   *working_units  IGRdouble      number of working units to convert.
   
   *readout_spec  struct GRIOreadout_spec                       
                                  If the calling program does not wish to 
                                  use the currently defined readout spec
                                  a overriding readout spec can be passed in.
                                  
   *field_size    IGRshort        size of field returned string will fix in,
                                  required for proper justification of text.

   inverse_scale_flag IGRshort    indicates whether or not to apply the
                                  inverse scaling factor.  If the unit type
                                  is not scalable this argument is ignored.
                                  The flag is an index that detremines which
                                  of the ACS scales (x,y,z,etc) is inverted an
                                  applied to the results.

   *fraction_mode IGRshort        the fractional part of the returned value may
                                  be returned as a decimal, as ascii chars
                                  representing a fraction or as a single 
                                  fractional character.  If this variable is not
                                  null, it specifies the mode, otherwise the
                                  dpb value is used.
                                   
   *cvt_list       IGRchar        an array of characters to place ascii text in.

 Sample Call:
   int status;
 
   status = uom$cvt_exp_to_alias( msg =  &msg,
                                  unit_type = GRIO_DISTANCE,
                                  num_def = &num_def,
                                  output_alias = output_alias_list,
                                  working_units = &working_units,
                                  cvt_list = output_string );
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
  OM_E_NODYNMEM  - no dynamic memory avaliable
*/

#omdef uom$cvt_exp_to_alias( msg,
                             unit_type,
                             osnum = OM_Gw_current_OS,
                             num_def,
                             output_alias,
                             working_units,
                             readout_spec = NULL,
                             field_size = NULL,
                             inverse_scale_flag = GRIO_X_SCALE,
                             fraction_mode = NULL,
                             cvt_list )

  UOM_cvt_exp_to_alias( (msg), (unit_type), (osnum), (num_def),
                        (output_alias), (working_units),
                        (readout_spec), (field_size),
                        (inverse_scale_flag), (fraction_mode),
                        (cvt_list) )

#endomdef

/*------------------------ uom$cvt_imp_to_wrk ---------------------------------

   uom$cvt_imp_to_wrk( msg,
                       unit_type,
                       osnum,
                       primary,
                       secondary,
                       tertiary,
                       result )

  ABSTRACT:
  --------- 
     This macro will return to the caller the sum total of working
   units in the primary, secondary, and tertiary arguments.
   all conversions will be based on the default units stored
   in the unit of measurement object.  

  ARGUMENTS:
  ----------   

   *msg            IGRlong        same as macro status

   *unit_type      IGRchar        Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area
                                  
    osnum          OMuword        object space conversion is to occur in.
    
    primary         IGRdouble     num of primary units

    secoundary      IGRdouble     num of secondary units

    tertiary        IGRdouble     num of tertiary units

   *result          IGRdouble     number of working units
                                  returned.
   

 Sample Call:
   int status;
 
   status = uom$cvt_imp_to_wrk( msg = &msg,
                                unit_type = GRIO_DISTANCE,
                                primary = 100.0,
                                result = &result_cvt);

   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
*/

#omdef uom$cvt_imp_to_wrk( msg, 
                           unit_type,
                           osnum = OM_Gw_current_OS,
                           primary,
                           secondary = 0.0,
                           tertiary  = 0.0,
                           result )

  UOM_cvt_imp_to_wrk( (msg), (unit_type), (osnum), (primary), (secondary),
                      (tertiary), (result) )

#endomdef

/*--------------------------- uom$cvt_exp_to_wrk --------------------------

   uom$cvt_exp_to_wrk( msg,
                       unit_type,
                       osnum,
                       units,
                       alias,
                       result );


  ABSTRACT:
  --------- 
     This macro will return to the caller the number of working
   units after units is converted.
   all conversions will be based on the default units passed
   to the unit of measurement object.  

  ARGUMENTS:
  ----------   

   *msg            IGRlong        same as macro status

   *unit_type      IGRchar        Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
                                          
    units          IGRdouble      num of units to convert

   *alias          IGRchar        name of alias

   *result         IGRdouble      number of working units
                                  returned.
   

 Sample Call:
   int status;
 
   status = uom$cvt_exp_to_wrk( msg = &msg,
                                unit_type = GRIO_DISTANCE,
                                units = 12.0
                                alias = "feet"
                                result = &result);

   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
*/

#omdef uom$cvt_exp_to_wrk( msg, 
                           unit_type,
                           osnum = OM_Gw_current_OS,
                           units,
                           alias,
                           result )

  UOM_cvt_exp_to_wrk( (msg), (unit_type), (osnum), (units), (alias),
                      (result) )

#endomdef

/*-------------------------- uom$is_unit_scalable ----------------------------

  uom$is_unit_scalable( msg,
                        unit_type,
                        osnum,
                        is_scalable )
  Abstract:
     This method sets a user-supplied boolean flag to indicate if the
     units of this object can be scaled.

   Arguments:

     IGRlong      *msg          o   same as macro status

     IGRchar      *unit_type    i   type of unit object.  For example,
                                      GRIO_DISTANCE ( distance )
                                      GRIO_ANGLE    ( angle )
                                      GRIO_AREA     ( area )
                                  
     OMuword       osnum        i   object space unit object is in.
                                    defaults to OM_Gw_Current_OS.
   
     IGRboolean   *is_scalable  o  flag indicates if unit is scalable
                                    TRUE  - unit is scalable.
                                    FALSE - unit is not scalable.
    Sample Call:
      int status;
 
      IGRboolean  is_scalable;
      IGRlong     msg;
      status = uom$is_unit_scalable( msg =  &msg,
                                     unit_type = GRIO_DISTANCE,
                                     is_scalable = &is_scalable );
      if ( status & 1 ) {
        ... everything is ok ...
      }
      else {
        ... an error occured ...
      }

    Return Status :  
     UOM_S_SUCCESS -  Success

*/

#omdef uom$is_unit_scalable( msg, 
                             unit_type,
                             osnum = OM_Gw_current_OS,
                             is_scalable )

  UOM_is_unit_scalable( (msg), (unit_type), (osnum), (is_scalable) )

#endomdef

/*--------------------------- uom$update_readout_spec ---------------------

  uom$update_readout_spec( msg,
                           unit_type,
                           osnum,
                           update_flag,
                           readout_spec )
  ABSTRACT:
  --------- 
          This macro will either extract from the unit object the default
       readout specs, or load them depending on the value of update_flag.


  ARGUMENTS:
  ----------   

   *msg            IGRlong        same as macro status

   *unit_type       IGRchar       Indicates what type of unit conversion is
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

    osnum          OMuword        object space conversion is to occur in.
    
    update_flag    IGRboolean     true: update with contents in readout_spec
                                  false: retrieve contents into readout_spec
    
    readout_spec  struct GRIOreadout_spec  

 Sample Call: To update readout spec
   int status;
 
   status = uom$update_readout_spec( msg = &msg,
                                     unit_type = GRIO_DISTANCE,
                                     readout_spec = &readout_spec );
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Sample Call: To retrieve readout spec
   int status;
 
   status = uom$update_readout_spec( msg = &msg,
                                     unit_type = GRIO_ANGLE,
                                     update_flag = FALSE;
                                     readout_spec = &readout_spec );
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
*/

#omdef uom$update_readout_spec( msg, 
                                unit_type,
                                osnum = OM_Gw_current_OS,
                                update_flag = TRUE,
                                readout_spec )
                                   
  UOM_update_readout_spec( (msg), (unit_type), (osnum), (update_flag),
                           (readout_spec) )

#endomdef

/*--------------------------- uom$get_default_units --------------------------
       uom$get_default_units( msg,
                              table_name,
                              osnum,
                              flag,
                              num_defaults,
                              default_units )

       ABSTRACT:
       --------- 
                 This macros will retrieve from the unit object the currrently
              defined input or output default units.    

 Arguments:

   *msg             IGRlong       same as macro status

   *table_name      IGRchar       Indicates what type of unit conversion is 
				  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

     osnum          OMuword       Object space variable is to be stored in.
    
    *flag           short         Which defaults are to be retrieved.
                                  0 retrieve input defaults
                                  1 retrieve output defaults 
    
    *num_defaults   short         Indicates how many defaults are currently 
                                  defined.
                                  
    *default_units  GRIOalias_name address of character array to store strings
                                   in.
 Sample Call:
   int status;
   char   return_array[3][40];
   short flag = 0;

   status = uom$get_default_units( msg = &msg,
                                   table_name = GRIO_DISTANCE,
                                   flag = &flag,
                                   num_defaults = num_default,
                                   default_units = return_array )
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
*/

#omdef uom$get_default_units( msg,
                              table_name,
                              osnum = OM_Gw_current_OS,
                              flag,
                              num_defaults,
                              default_units )

  UOM_get_default_units( (msg), (table_name), (osnum), (flag), (num_defaults),
                         (default_units) )
                  
#endomdef

/*--------------------------- uom$put_default_units --------------------------
       uom$put_default_units( msg,
                              table_name,
                              osnum,
                              flag,
                              num_defaults,
                              default_units )

       ABSTRACT:
       --------- 
                 This macros will retrieve from the unit object the currrently
              defined input or output default units.    

 Arguments:

   *msg             IGRlong       same as macro status

   *table_name      IGRchar       Indicates what type of unit conversion is 
                                  performed.  For example,
                                     GRIO_DISTANCE converts to distance
                                     GRIO_ANGLE    converts to angle
                                     GRIO_AREA     converts to area

     osnum          OMuword       Object space variable is to be stored in.
    
    *flag           short         Which defaults are to be retrieved.
                                  0 retrieve input defaults
                                  1 retrieve output defaults 
    
    *num_defaults   short         Indicates how many defaults are currently 
                                  defined.
                                  
    *default_units  GRIOalias_name address of character array to store strings
                                   in.
 Sample Call:
   int status;
   char   return_array[3][40];
   short flag = 0;

   status = uom$put_default_units( msg = &msg,
                                   table_name = GRIO_DISTANCE,
                                   flag = &flag,
                                   num_defaults = num_default,
                                   default_units = return_array )
   if ( status & 1 ) {
     ... everything is ok ...
   }
   else {
     ... an error occured ...
   }

 Return Status :  
  UOM_S_SUCCESS -  Success
  OM_E_NODYNMEM -  no dynamic memory avaliable
*/

#omdef uom$put_default_units( msg,
                              table_name,
                              osnum = OM_Gw_current_OS,
                              flag,
                              num_defaults,
                              default_units )
                       
  UOM_put_default_units( (msg), (table_name), (osnum), (flag), (num_defaults),
                         (default_units) )
                  
#endomdef

/*----------------------- uom$process_table_in_to_out  ----------------

  uom$process_table_in_to_out()

  Abstract:
     This macro enables processing of uom_tables from inner most product
     to outer most product.  This is the system default.

  Sample Call:
     int sts;

     sts = uom$process_table_in_to_out();
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$process_table_in_to_out()

  UOM_set_uom_table_processing_order( 1 )

#endomdef

/*----------------------- uom$process_table_out_to_in  ----------------

  uom$process_table_out_to_in()

  Abstract:
     This macro enables processing of uom_tables from outer most product
     to inner most product.

  Sample Call:
     int sts;

     sts = uom$process_table_out_to_in();
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$process_table_out_to_in()

  UOM_set_uom_table_processing_order( 0 )

#endomdef

/*----------------------- uom$mark_all_for_write  ---------------------

  uom$mark_all_for_write( osnum )

  Abstract:
     This macro marks all unit types for writing.  When the object space
     is saved all marked unit types will be written to the UOM instance
     data.

  Arguments:
     OMuword      osnum         i   the os to retrieve from

  Sample Call:
     int sts;

     sts = uom$mark_all_for_write();
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$mark_all_for_write( osnum = OM_Gw_current_OS )

  UOM_mark_all_for_write( (osnum) )

#endomdef

/*----------------------- uom$mark_for_write  -------------------------

  uom$mark_for_write( osnum,
                      typename )

  Abstract:
     This macro marks a single unit type for writing.  When the object space
     is saved all marked unit types will be written to the UOM instance
     data.

  Arguments:
     OMuword      osnum         i   the os to retrieve from
     char         *typename     i   the unit type to mark

  Sample Call:
     int sts;

     sts = uom$mark_for_write( typename = GRIO_DISTANCE );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$mark_for_write( osnum = OM_Gw_current_OS,
                           typename )

  UOM_mark_for_write( (osnum), (typename) )

#endomdef

/*----------------------- uom$give_table  -----------------------------

  uom$give_table( osnum,
                  table )

  Abstract:
     This macro returns a pointer to the complete uom_table, for the
     specified object space, that is stored in memory.

  Arguments:
     OMuword      osnum         i   the os to retrieve from
     UOM_TYPE     *table        o   the complete uom_table that is
                                    stored in memory

  Notes:
     table is READONLY data.

  Sample Call:
     int sts;
     UOM_TYPE *type_table

     sts = uom$give_table( table = &type_table );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$give_table( osnum = OM_Gw_current_OS,
                       table )

  UOM_give_table( (osnum), (table) )

#endomdef

/*----------------------- uom$get_variant_shortname  ------------------

  uom$get_variant_shortname( osnum,
                             variant,
                             aliasname,
                             typename,
                             shortname,
                             index )

  Abstract:
     This macro returns the "shortname" for the given unit type variant.
     The shortname is defined to be the longest alias that is greater
     then 1 character and less then or equal to 10 characters.

  Arguments:
     OMuword       osnum           i   the os to retrieve from
     UOM_VARIANT   *variant        [i]  the variant structure
     char          *aliasname      [i]  the unit alias name
                                        an aliasname may be type qualified
                                          ex.  qualified -> "mm:distance"
                                          ex.  non-qualified -> "mm"
     char          *typename       [i]  the unit type to get aliases for
                                        if specified restricts lookup of
                                        aliasename to the scope specified
                                        unless aliasname is qualified.
     UOMalias_name shortname       o    the shortname for the specified
                                        variant
     int           *index;         [o]  optional - if specified this value
                                        represents the index into the
                                        aliases array for the chosen shortname

  Sample Call:
     int sts;
     UOMalias_name sname;

     sts = uom$get_variant_shortname( aliasname = "inch", shortname = sname );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$get_variant_shortname( osnum = OM_Gw_current_OS,
                                  variant = NULL
                                  ^ aliasname = NULL,
                                  typename = NULL,
                                  shortname,
                                  index = NULL )

  UOM_get_variant_shortname( (osnum), (variant), (typename), (aliasname),
                             (shortname), (index) )

#endomdef

/*----------------------- uom$get_type_aliases  -----------------------

  uom$get_type_aliases( osnum,
                        typename,
                        aliases )

  Abstract:
     This macro returns a null terminated array of null terminated aliases
     for the specified unit type.

  Arguments:
     OMuword      osnum         i   the os to retrieve from
     UOM_TYPE     *type         [i] the type structure
     char         *typename     [i] the unit type to get aliases for
     char         **aliases     o   the array of aliases

  Notes:
     The memory returned in aliases must be deallocted using free from
     malloc(3x).

  Sample Call:
     int sts;
     int ii;
     char **aliases = 0;

     sts = uom$get_type_aliases( typename = GRIO_DISTANCE, aliases = &aliases );
     if ( sts & 1 ) {
       ... everything is ok ...
       ii = 0;
       while ( aliases[ii] ) {
         printf( "alias #%d <%s>\n", ii, aliases[ii] );
         ii++;
       }
     }
     else {
       ... an error occured ...
     }

     ... wrapup code ...
     if ( aliases ) {
       ii = 0;
       while ( aliases[ii] ) {
         free( aliases[ii] );
         ii++;
       }
       free( aliases );
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$get_type_aliases( osnum = OM_Gw_current_OS,
                             type = NULL
                             ^ typename = NULL,
                             aliases )

  UOM_get_type_aliases( (osnum), (type), (typename), (aliases) )

#endomdef

/*----------------------- uom$get_variant_aliases  --------------------

  uom$get_variant_aliases( osnum,
                           variant,
                           typename,
                           aliasname,
                           aliases )

  Abstract:
     This macro returns a null terminated array of null terminated aliases
     for the specified unit alias.

  Arguments:
     OMuword      osnum         i   the os to retrieve from
     UOM_VARIANT  *variant      [i] the variant structure
     char         *typename     [i] the unit type to get aliases for
                                    if specified restricts lookup of
                                    aliasename to the scope specified
                                    unless aliasname is qualified.
     char         *aliasname    i   the unit alias name
                                    an aliasname may be type qualified
                                      ex.  qualified -> "mm:distance"
                                      ex.  non-qualified -> "mm"
     char         **aliases     o   the array of aliases

  Notes:
     The memory returned in aliases must be deallocted using free from
     malloc(3x).

  Sample Call:
     int sts;
     int ii;
     char **aliases = 0;

     sts = uom$get_variant_aliases( aliasname = "inch", aliases = &aliases );
     if ( sts & 1 ) {
       ... everything is ok ...
       ii = 0;
       while ( aliases[ii] ) {
         printf( "alias #%d <%s>\n", ii, aliases[ii] );
         ii++;
       }
     }
     else {
       ... an error occured ...
     }

     ... wrapup code ...
     if ( aliases ) {
       ii = 0;
       while ( aliases[ii] ) {
         free( aliases[ii] );
         ii++;
       }
       free( aliases );
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$get_variant_aliases( osnum = OM_Gw_current_OS,
                                variant = NULL
                                ^ aliasname = NULL,
                                typename = NULL,
                                aliases )

  UOM_get_variant_aliases( (osnum), (variant), (typename), (aliasname),
                           (aliases) )

#endomdef

/*----------------------- uom$report_error  ---------------------------

  uom$report_error( msg,
                    str )

  Abstract:
     This macro returns a string given a UOM error return code

  Arguments:
     int          msg           i   the error return code
     char         *str          [o] the error string

  Sample Call:
     int sts;
     char str[256];

     sts = uom$report_error( msg = sts );
     if ( sts & 1 ) {
       ... everything is ok ...
     }
     else {
       ... an error occured ...
     }

  Return Status:
     UOM_S_SUCCESS -  Success
*/

#omdef uom$report_error( msg,
                         str = NULL )

  UOM_report_error( (msg), (str) )

#endomdef

#endif          /* #ifndef UOMmacros_included above */

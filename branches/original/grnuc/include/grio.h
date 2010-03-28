/*
 * Dependencies:
 *   igr.h
 *   griodef.h
 *   go.h
 *   ex.h
 *
 *   History:
 *
 *    srh  09/03/87  - modified GRevent and GRlc_info structures to remove
 *                     unneeded fields
 *
 */

#ifndef grio_include
#   define grio_include

    /* unit alias name buffer */
    typedef   IGRchar   GRIOalias_name[GRIO_MAX_ALIAS_SIZE];

    /*
     *   Structures for Units subsytem
     */
    struct GRIOalias_entry
    {
       GRIOalias_name alias;
       IGRshort   index;
    };

    struct GRIOgnunit_definition
    {
       IGRdouble  num_parent_units;
       IGRdouble  working_units;
       IGRshort   parent_index;
    };

    struct GRIOvar_def
    {
  	IGRshort type;
  	union
  	 {
  	 	IGRdouble fvalue;
  	 	IGRint    ivalue;
  	 	IGRchar   string[40];
                IGRpoint  point;
  	 } contents;
    };

    struct GRIOreadout_spec
    {
    	IGRshort   justification;     /* GRIO_RIGHT, GRIO_CENTER, GRIO_LEFT */
    	                              /* GRIO_LEFT default                  */
    	IGRshort   mode;              /* GRIO_DECIMAL, GRIO_FRACTIONAL      */
    	                              /* GRIO_DECIMAL only supported        */
        IGRshort   precision;         /* .0001 default. used only if mode
                                          is GRIO_DECIMAL                   */
        IGRshort   denominator;       /* 1/16  default. used only if mode
                                         is GRIO_FRACTIONAL                 */
        IGRshort   case_type;         /* upper, lower, none. nine default   */
    	IGRboolean leading_zeros;     /* TRUE, FALSE: defaults to FALSE     */
    	IGRboolean trailing_zeros;    /* TRUE, FALSE: defaults to FALSE     */
    	IGRshort   decimal_char;      /* defaults to GRIO_PERIOD            */
    	IGRshort   thousands_char;    /*defaults to GRIO_NONE, no character */

    	IGRshort   intermeas_spacing;      /* defaults to 2 spaces               */
    	                              /* # spaces between measurements      */
    	                              /* ex. 2 spaces: 2 ft  1 in           */
    	                              /* ex. 3 spaces: 2 ft   1 in          */

    	IGRshort   intrameas_spacing; /* defaults to 1 space                */
    	                              /* # spaces between number and alias  */
    	                              /* ex 1 spaces: 1 ft  2 in            */
    	                              /* ex 0 spaces: 1ft  2in              */

    	IGRchar    left_fill_char;    /* defaults to a space                */
    	IGRboolean alias_displayed;   /* defaults to TRUE                   */
    };



    /*
     *---------------------------------------------------------------------
     *  exec/grutil.h stuff
     *---------------------------------------------------------------------
     */

    enum  GRlocate_action
    {   add_all,
	add_inside,
	add_outside,
	add_overlap,
        end_transition,
	start_transition,
	post_object,
	check_object,
	add_nopost
    };

    /*
     *  GRlc_info from old exec/include/lc.h
     */
    struct GRlc_info
    {
       struct  GRid             located_obj;    /* located object    */
       struct  GRmd_env         module_info;    /* mapping for module*/
               IGRpoint         proj_pnt;       /* projected point   */
       struct  GRparms          geom_parms;     /* geometric params  */
    };
        
    /*
     *  Data event structure for IGE
     */
    struct GRevent
    {
        IGRint response;        /* response defined in EX_def.h */
        IGRint nbytes;          /* number of bytes transferred in node  */
        union 
        {
            struct EX_button        button;
                   IGRchar          keyin[GR_MAX_CHAR];
                   IGRdouble        value;
        } event;

        IGRint      subtype;    /* subtype of this data point           */
        IGRshort    num_id;     /* number of big id's in this structure */
        IGRshort    num_val;    /* number of numeric values             */
        IGRdouble   values[2];
        struct GRlc_info        located_object[2];
    };

    struct GRspecified_obj
    {
       struct GRid          objid;
       struct GRmd_env      md_env;
       struct GRid          window_id;
    };

    /*
     *  Stuff from old .../exec/include/grvalue.h
     */
    struct GR_vsd
    {
       IGRlong	start;
       IGRlong	end_ptr;
       IGRchar	delimiter;
       IGRchar	field_delimiter;
       IGRlong	buffer_size;
       IGRchar	buffer[MAX_BUF_SIZE];
    };

    struct GR_token
    {
       IGRlong type;
       IGRchar data[MAX_TOKEN_SIZE];
    };
    

    /*
     *  Added for multi_point generators; minimum data on software queue
     *  that has a subtype - overlays a portion of GRevent struct in memory
     */
    struct CO_soft_event
    {
       union
       {
          struct EX_button  button;
                 IGRchar    keyin[GR_MAX_CHAR];
                 IGRdouble  value;
       } event;

       IGRint  subtype;
    };

#endif /* grio_include */

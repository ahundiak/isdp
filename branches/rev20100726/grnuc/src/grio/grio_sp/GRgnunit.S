/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP%
----
%HD%
    CLASS NAME:  GRgnunit
    SUBCLASS OF: GRunit

----
%MD%
   MESSAGES DECLARED: 
                       message GRgnunitcvrt
                       message GRgnunitadd
                       message GRgnunitdel
                       message GRgnunitgetspec
                       message GRgnunitputspec

    MESSAGES OVERRIDDEN:  none
   
----
%NB%
 NOTES:
            This file declares and describes all methods used in the
            generic unit of measurement subsystem. The generic subsystem
            (GRgnunit) is a subclass of GRunit. This class provide methods
            for linear conversion (i.e distance, angle, time, etc.).


----
%CH%
 CHANGE HISTORY:
     
      Design Date   BMR 12/03/86   
      add return_list 01/08/92   

----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

---- */

/*EH*/


class specification GRgnunit (1:0) of GRunit;

instance GRgnunit
{
     IGRshort                                 num_definition;
     variable  struct GRIOgnunit_definition   unit_list[1];
     struct GRIOreadout_spec                  readout_spec;
};



#if 0
message GRgnunitcvrt(IGRint                   *rc;
    		     GRIOalias_name           *input_alias;
                     IGRshort                 *num_output_alias;
		     GRIOalias_name           *output_alias_list[];
           	     IGRdouble                *quantity;
	             IGRdouble                *result_list);
/*

Abstract
         This message will convert a quantity of a given alias to working units,
         working units to an alias, or one alias to another alias.
 
Arguments
        rc: MSFAIL    alias currently not defined.
            MSSUCC    conversion complete.
 
        input_alias:  pointer to alias name. If input alias name is a 
                      NULL pointer we will assume quanity is in working units
                      and convert to whatever alias is supplied in
                      output_alias_list. If a input alias is supplied we will 
                      verify alias exist, and convert to whatever alias is 
                      supplied in output_alias_list. If no alias is supplied
                      we will convert to working units.

       num_output_alias:  number of alias's contained in output_alias_list,
                           on return this variable will contain the number of
                           results returned in result_list. If no alias is 
                           provided we will try and convert to working units.

       output_alias_list:  pointer to a list of alias name. If a 
                            output_alias_list is supplied all units will 
                            be converted accordingly, and placed in 
                            result_list. If no alias is supplied we will 
                            convert to working units.
     
       quanity:  number of input_alias units to convert.

       result_list:   pointer to a list of results. result_list will 
                       correspond to alias supplied in output_alias_list.

Files:
           GRgnunitcvrt.I
 */



message GRgnunitadd(IGRlong         *rc;
                    IGRchar         *parent_alias;
                    IGRshort        *num_alias;
                    GRIOalias_name  *alias_list;
                    IGRdouble       *num_parent_units);
/*
Abstract
         This message will add an alias to the unit of measurement
         object.
 
Arguments
         rc: MSFAIL    parents alias currently not defined.
             MSSUCC    entry added to unit of measurement object.
 
         parent_alias:  points to ascii string definition of parent
                        unit, if NULL this definition will be the root

         num_alias:     number of  alias sent.

         alias_list:    list of alias assocated with this defination.

         num_parent_units: number of parent units required to form new
                           unit.
                           
Files:
         GRgnunitadd.I
 */


message GRgnunitdel(IGRlong         *rc;
                    IGRshort        *num_alias;
                    GRIOalias_name  *alias_list);
/*
Abstract

        This message removes the alias from the unit of measurement object.
 
Arguments
         rc: MSFAIL    alias currently not defined.
             MSSUCC    entry deleted from unit of measurement object.
 
         num_alias;  number of alias in alias list.

         alias_list:  pointer to a list of alias

Files:
         GRgnunitdel.I
 */

message GRgnunitgetspec(IGRlong                  *rc;
                        struct GRIOreadout_spec  *readout_spec);
/*
Abstract

        This message retrieves the readout spec from the unit object
 
Arguments
         rc: MSFAIL    no read out specs currently defined
             MSSUCC    read out specs returned.

         readout_spec: will contain read out spec.
Files:
         GRgnunitgets.I
 */

message GRgnunitputspec(IGRlong                  *rc;
                        struct GRIOreadout_spec  *readout_spec);
/*
Abstract

        This message updates the readout specs in the unit object
 
Arguments
         rc:MSSUCC    read out specs updates.

         readout_spec: will contain read out spec.
Files:
         GRgnunitputs.I
 */


message	get_first_aliases (
	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	**names;	/* o - A list of first aliases on each line	*/
				/*	for the specified unit type		*/
				/*	(allocated by this method).		*/
				/*	access i-th name by			*/
				/*	names[i * GRIO_MAX_ALIAS_SIZE]		*/
	IGRlong	*num_names;	/* o - Number of names output			*/
);
/*
Abstract: 	This method will return the first (short)  alias on every
		line of the uom_table.
		( eg. "distance" -> "in", "ft", "mm", "cm", "m", ... )

		The first alias on each line has been restricted to 10
		characters in order that it may be displayed on a form.
		The subsequent aliases on the line may be more descriptive.
*/
message get_synonyms (

	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	*UnitName;	/* i - Short unit name for which to find the	*/
				/*	available aliases			*/
	IGRchar	**names;	/* o - An array of unit names of that are aliases */
				/*	for the short unit name			*/
				/*	(allocated by this method).		*/
				/*     access i-th name by names[i * GRIO_MAX_ALIAS_SIZE] */
	IGRlong	*num_names;	/* o - Number of names output			*/
	IGRdouble *toDatabase;	/* o - Conversion factor. 			*/
				/*	unit * toDatabase = database units	*/
);
/*
Abstract: 	This method returns the synonyms of a unit type.
		Synonyms are a list of names that appear on one line in the
		uom_table and possess the same relationship to the database
		units.
*/

message get_database_units (

	IGRlong	*msg;		/* o - Ret status: MSSUCC or MSFAIL		*/
	IGRchar	name[];		/* o - The name of the database units		*/
);
/*
Abstract: 	This method will return the database units.
		( ex. "LENGTH" -> "inch" )
*/
#endif

message return_list( char **uom_type );

override debug;

end specification GRgnunit;


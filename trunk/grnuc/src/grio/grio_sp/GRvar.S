/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP%
----
%HD%
    CLASS NAME:  GRvar
    SUBCLASS OF: GRunit

----
%MD%
    MESSAGES DECLARED: 
                       message GRvarcvrt
                       message GRvaradd
                       message GRvardel

%CH%
 CHANGE HISTORY:
     
     Design Date   BMR 2/24/86   

---- */

class specification GRvar (1:0) of GRunit;

instance GRvar
{
     IGRlong      num_variables;
     variable     struct GRIOvar_def  var_list[1];
};



message GRvarcvrt(IGRint         *rc;
 		  GRIOalias_name     *input_alias;
                  struct GRIOvar_def *output_variable);
/*
Abstract
         This message will convert a given alias to its variable definition.

 
Arguments
        rc: MSFAIL    alias currently not defined.
            MSSUCC    conversion complete.
 
	input_alias:  input alias name to convert.

        output_variable:  output definition that defines 
Files:
           GRvarcvrt.I
 */



message GRvaradd(IGRlong        *rc;
                 GRIOalias_name     *input_alias;
                 struct GRIOvar_def *input_variable);
/*
Abstract adds a alias and variable to the object
 
Arguments
         rc: MSFAIL    parents alias currently not defined.
             MSSUCC    entry added to unit of measurement object.
 
         input_alias: ascii string pointing to alias name

         input_variable: def. of input variable.

                           
Files:
         GRvaradd.I
 */


message GRvardel(IGRlong     *rc;
                 IGRshort    *num_alias;
                 GRIOalias_name  *alias_list);
/*
Abstract

        This message removes the alias .
 
Arguments
         rc: MSFAIL    alias currently not defined.
             MSSUCC    entry deleted from unit of measurement object.
 
         num_alias;  number of alias in alias list.

         alias_list:  pointer to a list of alias

Files:
         GRvardel

 */

override debug;

 end specification GRvar;



/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP%
----
%HD%
    CLASS NAME:  GRunit
    SUBCLASS OF: Root

----
%MD%
    MESSAGES DECLARED: 
                       message GRunitget_def
                       message GRunitchg_def
           	       message GRunitadd_als
                       message GRunitfin_als
                       message GRunitdel_als
                       message GRis_unit_scalable

    MESSAGES OVERRIDDEN:  none
   
----
%NB%
 NOTES:
            This file declares and describes all methods used in the
          units subsystem.

----
%CH%
 CHANGE HISTORY:
     
      BMR 12/03/86    Design Date   
      BMR 04/17/89    added GRis_unit_scalable

----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

---- */

/*EH*/


class specification GRunit (1:0) of Root;

#include "msdef.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

instance GRunit
{
     IGRshort                 num_alias;
     variable                 struct GRIOalias_entry      alias_list[1];
     IGRshort                 num_defs_in;
     GRIOalias_name           default_alias_in[3];
     IGRshort                 num_defs_out;
     GRIOalias_name           default_alias_out[3];
};


message GRunitget_def(IGRlong        *rc;
                      IGRshort       *flag;
                      IGRshort       *num_defaults;
                      GRIOalias_name *default_units);
/*
Abstract
        This message retrieves the a list of default units store in 
        the object.
 
Arguments
         rc: 
             MSSUCC: alias returned. 
             MSFAIL: invalid flag

         flag: flag = 0 get input defaults
               flag = 1 get output defaults

         num_defaults: number of defaults currently defined.

         default_units: list of alias that is the current defaults.

Files:
         GRunitgetdef.I
 */



message GRunitchg_def(IGRlong        *rc;
                      IGRshort       *flag;
                      IGRshort       *num_defaults;
                      GRIOalias_name *default_units);

/*
Abstract
        This message changes the list of input default units stored in 
        the object.
 
Arguments
         rc: 
             MSSUCC - alias update.
             MSFAIL - alias specified did not exist.
                      invalid flag.

         flag: flag = 0 set input defaults
               flag = 1 set output defaults

         num_defaults: number of defaults to be defined.

         default_units: list of alias that will be current defaults.

Files:
         GRunitchgdef.I
 */

message GRunitadd_als(IGRlong         *rc;
                      IGRshort        *def_index;
                      IGRboolean      *modify_flag;
                      IGRboolean      *alias_added;
                      IGRshort        *num_alias;
                      GRIOalias_name  *alias_list);
/*
Abstract
         This message will add an alias to a unit of measurement
         object.
 
Arguments
         rc: MSFAIL    parents alias currently not defined.
             MSSUCC    entry added to unit of measurement object.
 
         def_index:    index in definition list

         alias_added:  TRUE alias was added
                       FALSE none of the alias was added (already exist and
                        modify_flag = FALSE)
                            
         modify_flag:  TRUE if alias exist replace with alias passed.
                       FALSE don't modify existing alias.

         num_alias:    number of  alias sent.

         alias_list:   list of alias assocated with this defination.

Files:
         GRunitaddals.I
 */



message GRunitfin_als(IGRlong           *rc;
                      GRIOalias_name    *alias;
                      IGRshort          *def_index;
                      IGRboolean         *located);
/*
Abstract
        This message determine if a alias is currently defined.
 
Arguments
         rc:        MSFAIL or MSSUCC

         alias:     pointer to alias name.

         def_index: Index into definition list.

         located:   TRUE alias exist
                    FALSE alias does not exist
 
Files:
         GRunitfindal.I
 */


message GRunitdel_als(IGRlong        *rc;
                      GRIOalias_name *alias;
                      IGRshort       *def_index;
                      IGRboolean     *last_alias_deleted;
                      IGRshort       *flag);
/*
Abstract

        This message removes the alias from the unit of measurement object.
 
Arguments
         rc:     MSFAIL alias currently not defined.
                 MSSUCC entry deleted from unit of measurement object.
 
         alias:  pointer to alias name.

         last_alias_deleted:  TRUE if last alias of the corresponding 
                                 definition was deleted.
                              FALSE if last alias was not deleted.


         flag:   TRUE all alias of the corresponding defination.
                 FALSE delete only this alias. 
 
Files:
         GRunitdelals.I
 */

message   GRis_unit_scalable(IGRlong      *msg;
                             IGRboolean  *flag);


/*
Abstract:
                This method sets a user-supplied boolean flag to 
       indicate if the units of this object can be scaled.
              

Arguments:
     
       IGRboolean     *flag  flag indicates if unit is scalable
                             If flag is equal to TRUE, units of this 
                              object can be scaled.
                             If flag is equal to FALSE, units of this 
                              object cannot be scaled.
Files:
       GRisunitsc.I
*/

 end specification GRunit;


/*

Name
  class ECtrmcrvele

Abstract
  This command object gathers the data and calls the methods
  needed to trim multiple curve elements to a single element

Notes
  The user needs to have more than one ( i.e., at least two)
  curve elements in order to run this command

History
  sjv     11/18/87        date of creation
  sjv     02/13/88        modified for cleanup at delete & to mark
                          points given by user
  sjv     02/17/88        modified to continue with more input in case
                          of disjoint result
  rlw     01/05/89        Fixed command key.
  dhm     03/23/89        Fixed display located channel problem by
                          initializing event1's module_info.
  Carlos  03/26/92        Changed product from $EMS to $MODEL.
  Carlos  05/01/92        Made changes to use the message system
                          at least for the command name.
*/

class specification ECtrmcrvele (1:0) of ECconst;

#include "EMSstruct.h"


instance ECtrmcrvele
{
 variable struct EMScrv_info_sd  crv_info[];      /* VLA of curve ids. */
 IGRint                          num_crvs,        /* number of curves */
                                 num_dup_crvs,
                                 accept_response; /* save for reuse on
                                                     duplicate input */
 struct GRevent                  accept_event;    /* save for reuse on
                                                     duplicate input */
 IGRboolean                      is_crv_ambig,
                                 is_crv_disjnt;   /* to check for parts of
                                                     curve */
 GRobjid                         compcrv_id;      /* resultant composite curve
                                                     or profile if assoc. flag
                                                     is on. */
};


message init_event1_md_env ( long * sts );

override sleep;

override wakeup;

override init;

message my_delete ( long * sts );

message patch_get_event ( long * sts );

message push_accept_event ( long * sts );

message restart_cmd ( long * sts );

message save_loc_info ( long * sts );

message reject_loc_info ( long * sts );

message process ( long * sts );

message confirm_result ( long * sts );

message cancel_result ( long * sts );

message cancel_part_result ( long * sts );

message hilight_curves ( long * sts );

end specification ECtrmcrvele;

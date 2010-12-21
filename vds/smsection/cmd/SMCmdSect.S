class specification SMCmdSect (1:0) of VDS_LOCATE;



#include <stdio.h>
#include <string.h>
#include <math.h>
#include "OMmacros.h"
#include  "growner.h"
#include  "coparamac.h"
#include "asmacros.h"

#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACrg_collect.h"

#include "FI.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "SMsection.h"

#include "SMmsg.h"


instance SMCmdSect
{
  struct GRid sect_id;  /* Id of the working section */

  variable struct GRid save_comp[1];
  variable struct GRmd_env save_comp_env[1];

  /* List of the compart corresponding to the last save */

  int save_nb_comp; /* Number of  polygon in preceding list*/

  variable struct GRid work_comp[1];
  variable struct GRmd_env work_comp_env[1];

  /* Buffer for compart : modified when user add, delete one*/

  int work_nb_comp; /* Number of assigned polygon */  

  struct GRid     save_frame[2 * SM_MAX_PARTS];
  struct GRmd_env save_frame_env[2 * SM_MAX_PARTS];
  /* List of frame id if multi part section */
  int save_nb_frame;

  struct GRid     work_frame[2 * SM_MAX_PARTS];
  struct GRmd_env work_frame_env[2 * SM_MAX_PARTS];

  /* Buffer of frame id if multi part section */ 

  int work_nb_frame;

  struct SMSectInfo save_info;     /* The info of the section */
  struct SMSectInfo work_info;     /* Buffer for  info of section */ 

  IGRchar save_unit[80];          /* Current distance unit */
};


override form_notification;

message init_form_new_sect ( long * sts );

message control_sect ( long * sts );

message place_sect (IGRlong *msg);

message modif_sect (IGRlong *msg);

override save_all;

override reset_all;

message mode_list ( long * sts );

message add_locate_comp ( long * sts );

message put_sect_param ( long * sts );

message copy_param ( long *sts ; int flag);

message add_locate_frame ( long * sts );

override erase_hilite;

message hilite_half ( long * sts );

message chg_state_button ( int *sts ; IGRboolean enable);

message toggle_mode ( long *sts ; int mode );

message control_unit ( long * sts );

override form_position;

message locate_sect ( long * sts );

override delete_all;

end specification SMCmdSect;

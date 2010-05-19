class specification VDCmdAutxt (1:0) of VDCmdtxldr;

#include "ex.h"

#define NUM_STATES  3 
#define NUM_TOKENS  6

enum possibleStates{ WAITMAC,
                     WAIT_FRM,
                     WAIT_WIND
                    };

enum possibleActions{  NILL,
                       ERROR,
                       START_CON,
                       STOMAC,
                       FORM_DIS,
                       CHECK_WID,
                       STORE_WIND,
                       PLACE_ANNOT
                     };

enum possible_entries { PARENT,
                        POINT,
                        NOENT };


instance VDCmdAutxt
{
  variable struct GRobj_env    obj_selected[0]; /* selected objects for annot */
  IGRpoint                     offset;
  double                       position;
  IGRboolean                   boxed,form_displayed,check_frm;
  int                          all_objs,count;
  GRspacenum                   cur_os;          /* current object space */
  IGRchar                      filename[132];   /* design filename      */
  struct EX_button             window;
  double                       angle1, angle2,
                               mylen1, mylen2;
  IGRint                       no_ldr;
};

override  init_type,
          wakeup,
          execute,
          notify_form,
          LC_selection,
          txt_output,
          display_form,
          place_form;

message VDPlace_annotation( long *sts );
           
end specification VDCmdAutxt; 

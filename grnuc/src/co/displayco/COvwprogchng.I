class implementation COvwchar;

#include	<FI.h>
#include 	"exdef.h"
#include	"exmacros.h"
#include	"dpdef.h"
#include 	"dp.h"
#include	"dpmacros.h"
#include	"lydef.h"
#include 	"viewdef.h"
#include	"msdef.h"
#include 	"grmessage.h"

%safe
#include        "DPviewvol.h"
#include        "DPsetinq.h"
%endsafe

method proc_chgs()
{
  IGRlong msg;
  IGRint  status = OM_S_SUCCESS;
  struct var_list gad_list[8];
  IGRlong return_bytes;
  IGRlong error;
  IGRint	flags[2];
  IGRdouble act_z_pt[3];
  IGRdouble disp_depths[6];


  gad_list[0].var = GRAGAD_NAME;
  gad_list[0].var_ptr = (IGRchar *)me->name;
#if defined(__STDC__)
  gad_list[0].num_bytes = sizeof(IGRchar) * DI_PATH_MAX;
#else
  gad_list[0].num_bytes = sizeof(IGRchar) * PATH_MAX;
#endif
  gad_list[0].bytes_returned = &return_bytes;

  flags[0] = 0xffffffff;
  flags[1] = me->flags;
  gad_list[1].var = GRAGAD_FLAGS;
  gad_list[1].var_ptr = (IGRchar *)flags;
  gad_list[1].num_bytes = sizeof(IGRint) * 2; 
  gad_list[1].bytes_returned = &return_bytes;

  gad_list[2].var = GRID_PER_REF_X;
  gad_list[2].var_ptr = (IGRchar *)&me->num_grid_x;
  gad_list[2].num_bytes = sizeof(IGRlong); 
  gad_list[2].bytes_returned = &return_bytes;

  gad_list[3].var = GRID_PER_REF_Y;
  gad_list[3].var_ptr = (IGRchar *)&me->num_grid_y;
  gad_list[3].num_bytes = sizeof(IGRlong); 
  gad_list[3].bytes_returned = &return_bytes;

  gad_list[4].var = UOR_PER_REF_X;
  gad_list[4].var_ptr = (IGRchar *)&me->dis_grid[0];
  gad_list[4].num_bytes = sizeof(IGRdouble); 
  gad_list[4].bytes_returned = &return_bytes;

  gad_list[5].var = UOR_PER_REF_Y;
  gad_list[5].var_ptr = (IGRchar *)&me->dis_grid[1];
  gad_list[5].num_bytes = sizeof(IGRdouble); 
  gad_list[5].bytes_returned = &return_bytes;

  gad_list[6].var = CONSTRUCT_PL_ORG;
  gad_list[6].var_ptr = (IGRchar *)me->const_org;
  gad_list[6].num_bytes = sizeof(IGRdouble)*3; 
  gad_list[6].bytes_returned = &return_bytes;

  gad_list[7].var = END_PARAM;


/* MUST KEEP me-> (instance data) until sure that the sets are good 
	if a set is bad should I replace the old data or leave the data
	they keyed in so that they will understand the error message

*/

  status = dp$inq_set_gragad(msg = &msg,
                             inq0_set1 = 1,
                             which_error = &error,
                             var_list = gad_list, 
                             gragad_objid = me->source_id.objid,
                             osnum = me->source_id.osnum);
  if ( !(status & 1))
  {
#ifdef DEBUG
    printf("Error in inq_set in COvwprogchng\n");
    om$report_error(sts = status);
#endif
    goto fini;
  }		

  act_z_pt[0] = 0.0;
  act_z_pt[1] = 0.0;
  act_z_pt[2] = me->wld_act_z;

  
  disp_depths[0] = 0;
  disp_depths[1] = 0;
  disp_depths[3] = 0;
  disp_depths[4] = 0;
  if ( me->flags & IS_PERSP )
  {
     disp_depths[2] = me->wld_dis_dep[1];
     disp_depths[5] = me->wld_dis_dep[0];
  }
  else
  {
     disp_depths[2] = me->wld_dis_dep[0];
     disp_depths[5] = me->wld_dis_dep[1];
  }

  status =dp$view_vol(msg = &msg,
                      display_depths = disp_depths,
                      active_z = act_z_pt,
                      gg_id = &me->source_id);
  if( ! (1 & status) )
  {
#ifdef DEBUG
    printf("\nError in inq_set in COvwvol\n");
#endif
  }

fini:
  return(OM_S_SUCCESS);

}

end implementation COvwchar;

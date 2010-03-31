/* - special conversion routine EMSsf_lift instance - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"

struct EMSsf_lift_instance
{
  int                          num_instructions;
  struct OM_sd_varlenarr_descr move_info;
};

struct EMinstruction_table_info
{
    union operation_params
    {
       double  vt_pt[2];
       double end_pts[4];
    } params;
    unsigned short move_operation;
};

EMSsf_lift_OMPORT_EMSsf_lift(classid, ME, me)
short classid;
char *ME;
struct EMSsf_lift_instance *me;
{
  int    sts, buf_len, num_instr, ii;
  char   *buffer;
  struct EMinstruction_table_info *i_ptr;

  buf_len = OMPORT_INTEGER_VALUE(&me->move_info.i_count);

  if(!buf_len) return (1);

  buffer = (char *)((unsigned int) (&me->move_info) +
           OMPORT_INTEGER_VALUE(&me->move_info.i_offset));

  i_ptr = (struct EMinstruction_table_info *) buffer;  

  num_instr = OMPORT_INTEGER_VALUE(&me->num_instructions);

  for(ii=0; ii<num_instr; ii++)
  {
    sts = OMPORT_CONV_DOUBLE(i_ptr[ii].params.end_pts, 4);

    sts = OMPORT_CONV_SHORT(&i_ptr[ii].move_operation, 1);
  }

  return(sts);
}


EMSsl_lift_OMPORT_EMSsf_lift(classid, ME, me)
short  classid;
char   *ME;
struct EMSsf_lift_instance *me;
{
    return(EMSsf_lift_OMPORT_EMSsf_lift(classid, ME, me));
}

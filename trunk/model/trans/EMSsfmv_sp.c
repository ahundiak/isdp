/* - special conversion routine EMSsfmove - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"

struct EMSsfmove_instance
{
  double   from_point[3];
  double   to_point[3];
  struct   OM_sd_varlenarr_descr move_info;
  unsigned short     no_of_instructions;
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

struct EMexec_info
{
  struct EMinstruction_table_info instruction;
  short index;
};

EMSsfmove_OMPORT_EMSsfmove(classid, ME, me)
short classid;
char *ME;
struct EMSsfmove_instance *me;
{
  int    sts, buf_len, num_instr, ii;
  char   *buffer;
  struct EMexec_info *i_ptr;

  buf_len = OMPORT_INTEGER_VALUE(&me->move_info.i_count);

  if(!buf_len) return (1);

  buffer = (char *)((unsigned int) (&me->move_info) +
           OMPORT_INTEGER_VALUE(&me->move_info.i_offset));

  i_ptr = (struct EMexec_info *) buffer;  

  num_instr = buf_len; /*OMPORT_SHORT_VALUE(&me->no_of_instructions);*/

  for(ii=0; ii<num_instr; ii++)
  {
    /*convert biggest array in union*/
    sts = OMPORT_CONV_DOUBLE(i_ptr[ii].instruction.params.end_pts, 4);

    sts = OMPORT_CONV_SHORT(&i_ptr[ii].instruction.move_operation, 1);

    sts = OMPORT_CONV_SHORT(&i_ptr[ii].index, 1);
  }

  return(sts);
}


EMSslmove_OMPORT_EMSsfmove(classid, ME, me)
short  classid;
char   *ME;
struct EMSsfmove_instance *me;
{
    return(EMSsfmove_OMPORT_EMSsfmove(classid, ME, me));
}

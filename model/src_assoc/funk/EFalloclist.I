/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSdpr;

void EFalloc_list(EMmsg, array, num_in_array, array_size, num_more, incr,
                  options) 
IGRlong           *EMmsg; 
GRobjid           **array; 
IGRint            num_in_array;
IGRint            *array_size;
IGRint            num_more;
IGRint            incr;
IGRushort options;
/*
Description
    Handle alloc/realloc of in/out list fields.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    DLB 01/28/91    Creation.
*/
{
  IGRint tmp_cnt;

  *EMmsg = EMS_S_Success;

  if (num_more)
  {
    tmp_cnt = num_more + num_in_array;
    if (*array_size < tmp_cnt)
    {
      /*Perform realloc or malloc*/
      tmp_cnt += incr;   
      if (*array_size)
      {
        *array = (GRobjid *) om$realloc(ptr = (IGRchar *) *array, 
                                        size = tmp_cnt * sizeof(GRobjid));
      }
      else
      {
        *array = (GRobjid *) om$malloc(size = tmp_cnt * sizeof(GRobjid));
      }

      if (!*array) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
      *array_size = tmp_cnt;
    }
  }

wrapup:
  return;
}
end implementation EMSdpr;

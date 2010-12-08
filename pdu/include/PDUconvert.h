#ifndef PDUconvert_h
#define PDUconvert_h

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

struct PDUold_part_list
{
  char                      *catalog;
  char                      *number;
  char                      *revision;
  char                      *part_type;
  struct  PDUold_part_list  *next;
};

struct PDUnth_ref_objects
{
  struct  GRid                 obj_id;
  int                          level;
  char                        *seq_no;
  struct  PDUnth_ref_objects  *next;
};

#endif

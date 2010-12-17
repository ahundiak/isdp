#include        <igetypedef.h>
#include        <igrtypedef.h>
#include        <gr.h>

/*
 * This structure is used in conjunction with the ppl program put_queue.u
 */
struct PDUqueue_info
        {
         IGRint        mode;
         IGRchar       *cmd;
         IGRchar       *cmd_key;
         IGRchar       *string;
         IGRdouble     point[3];
         IGRint        response;
         GRobjid       obj;
         IGRdouble     value;
         OMuword       osnum;
         IGRint        pos;
         struct PDUqueue_info *next;
        };

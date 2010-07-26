
class specification Root (3:0) of Root;


/* revisions

cgp001	jan-28-1986	Use OMminimum.h

ems001  mar-19-1987     Add include for OMprimitives.h (which was removed
                        from OMminimum.h)
*/

#include 	<stddef.h> /* required by opp */
#include 	"OMminimum.h"
#include        "OMprimitives.h"

instance Root
 {
  OM_S_OBJECTHDR OPPobjecthdr;
 };

message debug ();
message delete (int f_defer_flag);
message connect 
		(OM_S_CHANSELECT to_sel;
		 int to_idx;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel;
		 int fr_idx);
message disconnect
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel);

message wild_disconnect
		(OM_S_CHANSELECT to_sel);
message move_chan
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel);
message copy_chan
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID fr_objid;
		 OMuword fr_os;
		 OM_S_CHANSELECT fr_sel);

message unknown (OM_S_MESSAGE *msg);

message range_disconnect
		(OM_S_CHANSELECT to_sel;
		 int low_idx;
		 int hi_idx);

message set_operation
		(OM_S_CHANSELECT to_sel;
		 OM_S_OBJID op2_objid;
		 OMuword op2_os;
		 OM_S_CHANSELECT op2_sel;
		 OM_S_OBJID op3_objid;
		 OMuword op3_os;
		 OM_S_CHANSELECT op3_sel;
		 char operation;
		 OMuword preserve);

message ARwrite(int *return_code; int starting );

message ARread(int *return_code; char *keyword );


end specification Root;

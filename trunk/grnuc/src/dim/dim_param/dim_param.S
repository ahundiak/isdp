class specification dim_param (2:0) of DMproot;

#include "OMmacros.h"

#include "asbox.h"
#include "dimdef.h"
#include "dim.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dm_status.h"

override GRvg;

instance dim_param
{
	int version_no;
	int type;
	variable char data[0];
};

message give_internal(int type; int size; char *data);
message store_internal(int type; int size; char *data);
message datcmp(int *rc; int type; int size; char *data);
message convert();

message translate(IGRint type; struct GRid *p_grid);
message find_match(IGRint type, size; char *data; struct GRid *match);

message update(
	IGRint type;
	IGRint size;
	char *data;
	struct GRmd_env *md_env;
	struct GRid *new_grid);

message edit(
	IGRint type;
	IGRint size;
	char *data;
	struct GRmd_env *md_env;
	struct GRid *new_grid);

message delete_no_ch(IGRint par_count[]);

message pass_message(OM_p_MESSAGE p_msg);

message import_param(
	IGRint *msg;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *copy);

override NDplace;
override NDcopy;

end specification dim_param;


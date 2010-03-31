struct	object_node_info
	{
	struct GRid			id;
	struct object_node_info		*next;
	IGRint				level;
	};
	
struct	xhatch_node_info
	{
	struct GRobj_env		id;
	struct xhatch_node_info		*next;
	struct object_node_info		*holes;
	struct object_node_info		*lines;
	IGRint				level;
	IGRboolean			xhatch_object;
	};

#define	ONP_MAX		100
#define	XNP_MAX		100

struct	object_node_pool_info
	{
	struct object_node_info		pool[ONP_MAX];
	struct object_node_pool_info	*next;
	IGRint				index;
	};

struct	xhatch_node_pool_info
	{
	struct xhatch_node_info		pool[XNP_MAX];
	struct xhatch_node_pool_info	*next;
	IGRint				index;
	};



#ifndef dimlocate_include

#define dimlocate_include

/* - Structure defining action handler info - */

struct DMact_info
{
	struct GRid cmd;		/* GRid of CO sending message*/
	struct GRlc_stack stack;	/* Locate stack */
};

#endif


#include "OMport.h"

struct OMrtree_instance {
int count;
unsigned long objid;
char tree_page[4080];
};

OMrtree_OMPORT_OMrtree(classid, ME, me)
short classid;
char *ME;
struct OMrtree_instance *me;
{

	int sts;
	
	sts = OMPORT_CONV_BY_TEMPLATE_NAME(me->tree_page, "OMrtree_page", 1);
	if(!sts) return(0);

        return(1);

}


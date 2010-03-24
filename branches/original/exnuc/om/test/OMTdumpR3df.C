#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMintprims.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"

#define ERROR(E)	(fprintf E, exit(1))
#define OM_ERROR(E,S)	(fprintf E, om$report_error(sts=S), exit(S))

dump_rtree_page(osnum, objid)
OMuword		osnum;
OM_S_OBJID	objid;
{
	struct OMrtree_instance
	{
		int		count;
		OM_S_OBJID	objid;
		R_PAGE_3D_FLT	tree_page;
	} *me;

	R_PAGE_3D_FLT	*cur_page_p;
	int		sts, i;
	char		*type;
	OM_S_RIP	rip;

	sts = om$get_any_instance(p_rip=&rip, osnum=osnum, objid=objid);
	if (!(1&sts))
		OM_ERROR((stderr, "error in om$get_any_instance(%u.%u)\n", osnum, objid), sts);

	printf("Page %u.%u:\n", osnum, objid);
	
	me = (struct OMrtree_instance *)((char *)rip.p_object + sizeof(*rip.p_object));
	printf("count  ...................  %d\n", me->count);
	printf("objid  ...................  %u\n", me->objid);

	cur_page_p = &me->tree_page;

	type =
		(cur_page_p->Header.Page_type == R_LF_RT_PAGE ? "R_LF_RT_PAGE" :
		(cur_page_p->Header.Page_type == R_NL_RT_PAGE ? "R_NL_RT_PAGE" :
		(cur_page_p->Header.Page_type == R_LF_NR_PAGE ? "R_LF_NR_PAGE" :
		(cur_page_p->Header.Page_type == R_NL_NR_PAGE ? "R_NL_NR_PAGE" :
		"other" ))));

	printf("Header.Page_type  ........  %s (%d)\n", type, cur_page_p->Header.Page_type);
	printf("Header.Rtree_type  .......  %d\n", cur_page_p->Header.Rtree_type);
	printf("Header.Key_count  ........  %u\n",cur_page_p->Header.Key_count);

	for (i = 0; i < cur_page_p->Header.Key_count; ++i)
	{
		printf("[%d]\t", i);
		printf("{%9.2f", cur_page_p->Key[i].xmin);
		printf(", %9.2f", cur_page_p->Key[i].ymin);
		printf(", %9.2f}\n", cur_page_p->Key[i].zmin);

		printf("\t", i);
		printf("{%9.2f", cur_page_p->Key[i].xmax);
		printf(", %9.2f", cur_page_p->Key[i].ymax);
		printf(", %9.2f}\t", cur_page_p->Key[i].zmax);
		if (NOT_R_LEAF(cur_page_p->Header.Page_type))
			printf("page: %u\n", cur_page_p->Objid[i]);
		else
			printf("objid: %u\n", cur_page_p->Objid[i]);
	}
	printf("\n");
	if (NOT_R_LEAF(cur_page_p->Header.Page_type))
		for (i = 0; i < cur_page_p->Header.Key_count; i++)
			dump_rtree_page(osnum, cur_page_p->Objid[i]);
}

DB_dump_rtree3df(osnum, objid)
OMuword		osnum;
OM_S_OBJID	objid;
{
	printf("================= Dumping rtree (%u.%u)\n", osnum, objid);
	dump_rtree_page(osnum, objid);
	printf("=========================================\n");
}

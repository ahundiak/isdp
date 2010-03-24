static DIunode **DIuntrees = NULL	/* all the untrees		*/;
/*static DIunode *DIcur_untree;	*/	/* the current untree		*/
/*static DIint   DInb_untrees = NULL; */	/* number of untrees	*/
static DIint   *DIusizes = NULL		/* the size of the untrees 	*/;

#define DIusize sizeof(DIunode)
#define DIgetunode(os,objid) (DIunode *)((DIuntrees[os])?bsearch(&objid,DIuntrees[os],DIusizes[os],DIusize,(int(*)(const void *,const void *))DIBcomp_ptrs):NULL)

static DIBcomp_ptrs ( p1, p2 )
                      DIobjid *p1, *p2	/* pointers to the entries 	IN  */;
{
  return (*p1 == *p2) ? 0 : (*p1 < *p2) ? -1 : 1;
}

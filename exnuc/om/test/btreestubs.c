
/* This file contains stubs for the Btree functionality that is not available
   on NT
*/
#ifdef NT
tdelete()
{
   printf("Stub Hit for _tdelete()\n");
}

tfind()
{
   printf("Stub Hit for _tfind()\n");
}

tsearch()
{
   printf("Stub Hit for _tsearch()\n");
}

twalk()
{
   printf("Stub Hit for _twalk()\n");
}
#endif

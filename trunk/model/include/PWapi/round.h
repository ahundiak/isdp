/*

 OVERVIEW
 Structures and API prototypes for the placement and query on round edge
 feature.

 NOTES

 HISTORY
 Aditya  03/19/96  Creation

*/

#ifndef _RoundAPI_include
#define _RoundAPI_include


#if defined(__STDC__) || defined(__cplusplus)
#ifndef _PW_
#define _PW_(args) args
#endif
#else
#ifndef _PW_
#define _PW_(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C"
{
#endif

extern PWresult pwRoundEdges _PW_((
  PWobjid surface_entity,
  PWosnum os,
  int num_edge_sets,
  struct PWrndedgeset *edge_sets,
  PWboolean is_chamfer,
  PWobjid *rounded_solid));

#if defined(__cplusplus)
}
#endif

#endif

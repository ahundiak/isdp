#ifndef _geomloop_proto_h 
#define _geomloop_proto_h

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

extern struct PWgeomloop *pwCreateGeomloop  _PW_((
  struct PWgeomloop **p_loops
));

extern PWboolean pwRemoveGeomloop _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_remove_node
));

extern void pwFreeGeomloop _PW_((
  struct PWgeomloop *p_loops 
));

extern void pwInsertAtInxGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_insert_node, 
  int index
));

extern PWboolean pwSwapNodesGeomloop  _PW_(( 
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_a_node, 
  struct PWgeomloop *p_b_node
));

extern void pwAppendGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_append_node
));

extern void pwPrefixGeomloop  _PW_((
  struct PWgeomloop **p_loops,
  struct PWgeomloop *p_prefix_node
));

extern int pwNumGeomloop _PW_((
  struct PWgeomloop *p_from_node
));

extern struct PWgeomloop *pwNodeAtInxGeomloop  _PW_((
  struct PWgeomloop *p_from_node, 
  int index
));

extern PWboolean pwInxOfNodeGeomloop  _PW_((
  struct PWgeomloop *p_from_node,
  struct PWgeomloop *p_node, 
  int *index
));

extern struct PWgeomloop *pwHeadGeomloop  _PW_((
  struct PWgeomloop *p_loops
));

extern struct PWgeomloop *pwTailGeomloop  _PW_((
  struct PWgeomloop *p_loops
));



#if defined(__cplusplus) 
} 
#endif 

#endif 

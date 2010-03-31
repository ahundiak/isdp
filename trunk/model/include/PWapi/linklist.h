#ifndef _linklist_proto_h 
#define _linklist_proto_h

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

extern char *pwCreateNode _PW_((
  char **p_list,
  unsigned int  size
));

extern PWboolean pwRemoveNode _PW_((
  char **p_list,
  char *p_remove_node
));

extern int pwNumNodes _PW_((
  char *p_from_node
));

extern char *pwNodeAtInx _PW_((
  char *p_from_node,
  int  index
));

extern PWboolean pwInxOfNode _PW_((
  char *p_from_node,
  char *p_node,
  int  *index
));

extern char *pwHead _PW_((
  char *p_list
));

extern char *pwTail _PW_((
  char *p_list
));

extern void pwInsertNodeAtInx _PW_((
  char **p_list,
  char *p_insert_node,
  int  index
));

extern PWboolean pwSwapNodes _PW_((
  char **p_list,
  char *p_a_node,
  char *p_b_node
));

extern void pwAppendNode _PW_((
  char **p_list,
  char *p_append_node
));

extern void pwPrefixNode _PW_((
  char **p_list,
  char *p_prefix_node
));


#if defined(__cplusplus) 
} 
#endif 

#endif 

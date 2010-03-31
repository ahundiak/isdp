#ifndef _cvintpt_proto_h 
#define _cvintpt_proto_h

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

extern struct PWcvintpt_list *pwCreateCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts 
));

extern void pwFreeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern PWboolean pwRemoveCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_remove_node
));

extern PWboolean pwFreeNodeCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_free_node
));

extern void pwInsertAtInxCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_insert_node,
  int                   index
));

extern PWboolean pwSwapNodesCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_a_node,
  struct PWcvintpt_list *p_b_node
));

extern void pwAppendCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_append_node
));

extern void pwPrefixCvintptList _PW_((
  struct PWcvintpt_list **p_cvintpts,
  struct PWcvintpt_list *p_prefix_node
));

extern int pwNumCvintptList _PW_((
  struct PWcvintpt_list *p_from_node
));

extern struct PWcvintpt_list *pwNodeAtInxCvintptList _PW_((
  struct PWcvintpt_list *p_from_node,
  int                   index
));

extern PWboolean pwInxOfNodeCvintptList _PW_((
  struct PWcvintpt_list *p_from_node,
  struct PWcvintpt_list *p_node,
  int                   *index
));

extern struct PWcvintpt_list *pwHeadCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern struct PWcvintpt_list *pwTailCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern void pwSetContainCvintpt _PW_((
  struct PWcvintpt      *p_cvintpt,
  int                   side,
  enum   PWcontaintype  containment
));

extern enum PWcontaintype  pwGetContainCvintpt _PW_((
  struct PWcvintpt      *p_cvintpt,
  int                   side
));

extern void pwSetNoSiblingCvintpt  _PW_((
  struct PWcvintpt *p_cvintpt 
));

extern void pwUnsetNoSiblingCvintpt _PW_((
  struct PWcvintpt *p_cvintpt
));

extern PWboolean pwIsNoSiblingCvintpt _PW_((
  struct PWcvintpt *p_cvintpt
));

extern void pwSetContainCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts, 
  int                   side,
  enum   PWcontaintype  containment
));

extern enum PWcontaintype pwGetContainCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern void pwSetArbSeqCvintptList  _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern void pwUnsetArbSeqCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWboolean pwIsArbSeqCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern void pwSetCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern void pwUnsetCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts,
  int                   side
));

extern PWboolean pwIsCoincCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts, 
  int                   side
));

extern void pwSetInfoNodeCvintptList  _PW_((
  struct PWcvintpt_list *p_cvintpts 
));

extern void pwUnsetInfoNodeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWboolean pwIsInfoNodeCvintptList _PW_((
  struct PWcvintpt_list *p_cvintpts
));

extern PWresult pwSortCvintptList _PW_((
  struct PWcvintpt_list  **p_cvintpts,    /*  I/O  */
  double                 tol               /*   I   */
));



#if defined(__cplusplus) 
} 
#endif 

#endif 

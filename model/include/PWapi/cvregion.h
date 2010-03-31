#ifndef _cvregion_proto_h 
#define _cvregion_proto_h

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

extern struct PWcvregion_list *pwCreateCvregionList _PW_((
  struct PWcvregion_list **p_cvregions 
));

extern void pwFreeCvregionList _PW_((
  struct PWcvregion_list *p_cvregions 
));

extern PWboolean pwRemoveCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_remove_node
));

extern PWboolean pwFreeNodeCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_free_node
));

extern void pwInsertAtInxCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_insert_node,
  int                    index
));

extern PWboolean pwSwapNodesCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_a_node,
  struct PWcvregion_list *p_b_node
));

extern void pwAppendCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_append_node
));

extern void pwPrefixCvregionList _PW_((
  struct PWcvregion_list **p_cvregions,
  struct PWcvregion_list *p_prefix_node
));

extern int pwNumCvregionList _PW_((
  struct PWcvregion_list *p_from_node
));

extern struct PWcvregion_list *pwNodeAtInxCvregionList _PW_((
  struct PWcvregion_list *p_from_node,
  int                    index
));

extern PWboolean pwInxOfNodeCvregionList _PW_((
  struct PWcvregion_list *p_from_node,
  struct PWcvregion_list *p_node,
  int                    *index
));

extern struct PWcvregion_list *pwHeadCvregionList _PW_((
  struct PWcvregion_list *p_cvregions
));

extern struct PWcvregion_list *pwTailCvregionList _PW_((
  struct PWcvregion_list *p_cvregions
));

extern void pwSetContainCvregion _PW_((
  struct PWcvregion     *p_cvregion, 
  enum   PWcontaintype  containment
));

extern enum PWcontaintype pwGetContainCvregion _PW_((
  struct PWcvregion *p_cvregion
));

extern void pwSetDegenCvregion  _PW_((
  struct PWcvregion *p_cvregion
));

extern void pwUnsetDegenCvregion _PW_((
  struct PWcvregion *p_cvregion 
));

extern PWboolean pwIsDegenCvregion _PW_((
  struct PWcvregion *p_cvregion
));



#if defined(__cplusplus) 
} 
#endif 

#endif 

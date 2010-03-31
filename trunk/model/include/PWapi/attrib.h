#ifndef _attrib_proto_h 
#define _attrib_proto_h

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

extern struct PWattrib *pwCreateIntAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  int              attrib_val
));

extern struct PWattrib *pwCreateDoubleAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  double           attrib_val
));

extern struct PWattrib *pwCreateGenAttrib  _PW_((
  struct PWattrib  **p_attrib_list, 
  unsigned int     ident,
  char             *p_gen_val,
  void             (*free_func)(char *),
  char             *(*copy_func)(char *)
));

extern PWboolean pwGetIntAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  int              *attrib_val
));

extern PWboolean pwGetDoubleAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  double           *attrib_val
));

extern PWboolean pwGetGenAttrib _PW_((
  struct PWattrib  *p_attrib, 
  unsigned int     ident,
  char             **attrib_val
));

extern struct PWattrib *pwGetAttribPtr _PW_((
  struct PWattrib    *p_attrib, 
  unsigned int       ident,
  enum PWattribtype  attribtype
));

extern void pwFreeAttribList _PW_(( 
  struct PWattrib *p_attrib
));

extern void pwRemoveAttrib _PW_((
  struct PWattrib **p_attrib,
  struct PWattrib *p_remove_attrib
));

extern struct PWattrib *pwCopyAttribList _PW_((
  struct PWattrib *p_attrib
));



#if defined(__cplusplus) 
} 
#endif 

#endif 

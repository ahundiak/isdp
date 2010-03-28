#ifndef nd_include
#define nd_include

/* structure used in the copy graph message */
struct NDcp_list
 {
  OM_S_OBJID original,
	     clone;
  int position;
 };

struct NDcp_struct
 {
  struct NDcp_list *list;
  int nb_obj;
 };
#endif /* ND */

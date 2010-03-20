#ifndef FIgraphic_included
#define FIgraphic_included	1

struct FIgraphic_instance
{
  char		  line_weight;
  short		  line_style;
  char        * dash_list;  /* dmb:09/29/92:Dropped unsigned for ANSI */
  int		  list_len;
};

#endif

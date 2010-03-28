#eofifdef GMpriv_include
#define   GMpriv_include
/*
  File dependencies :

  EXgrid.h
  GMhcode.h
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*        Definition of the internal structure of an element for a graph      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct GMelmt               /* Element contained in the graph structure       */
  {
  unsigned short ind_parent; /* Index of the first parent                     */
  unsigned short nb_parent;  /* Number of parents of the element              */
  unsigned short state;      /* Temporary state for the graph manager         */
  short  int_attr;           /* Internal attribute of the element             */
};

struct GMmodif              /* Definition of a request for dynamic broadcast  */
  {
  struct GRid    object;    /* Object modified                                */
  unsigned short level;     /* Level of the notification                      */
  char           type;      /* Type of modification for the element           */
};

struct GMsel_list           /* To select the new root and tip list in dynamic */
  {
  struct GMlist *l_greq;    /* Index of the element                           */
  short  int_attr;          /* Internal attribute of the element              */
};

struct GManc_pair           /* Definition of a pair (element <--> ancestor)   */
  {
  unsigned short anc_index; /* Index of the ancestor                          */
  unsigned short key_index; /* Index of the element                           */
};

#define GMS_BEG_LOOP    0   /* To specify the selection on the beg_loop field */
#define GMS_END_LOOP    1   /* To specify the selection on the end_loop field */
#define GMS_LOOP        2   /* To specify the selection on the loops fields   */

/*
 Internal types
 --------------
*/

#define GM_MIN_LEVEL 0      /* Minimum level for a node in the graph          */
#define GM_UNKNOWN   0xffff /* Unknown level for a node in the graph          */
#define GM_NULL_ATTR 0x0000 /* Null attribute for an element                  */

/*
 Internal types for the trigger:
 -------------------------------
*/

#define GM_BR_INFO  0xf000   /* Types relative to broadcast information       */

#define GM_BROAD    0x1000   /* Elements already broadcast                    */

#define GM_OR_STOP  0x2000   /* The successors of this element will not       */
                             /* receive the same function and will take the   */
                             /* same attribute                                */

#define GM_AND_STOP 0x4000   /* The successors of this element will not       */
                             /* receive the same function if all of its roots */
                             /* return GM_AND_STOP. In this case the successor*/
                             /* will take the same attribute                  */

#define GM_TAG      0x8000   /* This element received a tag during the        */
                             /* broadcast, this tag is used to inform its     */
                             /* successors during the broadcast               */

#define GM_SICK     0x0200   /* This element is sick during the broadcast        */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 Types for the broadcast state of the graph                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define  GM_CONTINUE     0x00  /* The graph continue the broadcast            */
#define  GM_MODIFY       0x01  /* The topology of the graph is modified       */
#define  GM_TEST_MODIFY  0x02  /* The graph has to be tested been stacked     */
#define  GM_ABORT_BROAD  0x04  /* The broadcast of the function must abort    */
#define  GM_STOP_BROAD   0x14  /* The broadcast is stoped by the user         */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*            Types to define the level of modification of a graph            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GM_R_TOPOLOG     GM_REQ_DELETE|GM_REQ_CONNECT|GM_REQ_DISCONNECT
#define GM_R_NEWCONNECT  GM_REQ_DISCONNECT|GM_REQ_CONNECT

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                  Default parameters of the graph manager                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GML_SIZE_AVERAGE   5   /* Average number of elements in a list        */
#define DEFAULT_NB_GRAPH   2   /* Default number of graphs in the graph system*/
#define GM_REQ_SIZE       10   /* Average number of requests for a graph syst.*/
#define FACTOR           1.5   /* Factor to realloc memory                    */
#define AV_NB_PAR          3   /* Average number of parents for a node        */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


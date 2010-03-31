/* ###################   APOGEE COMPILED   ################## */
class specification ECrmDjRg (1:0) of ECelement;

/*
ABSTRACT

Identify or remove disjoint regions.

USER INTERFACE

Identify disjoint regions

- 1) .

- 2) .

- 3) .

Remove disjoint regions

- 1) .

- 2) .

- 3) .

- 4) .

- 5) .

INSTANCE

action:  action to perform on way to next state.

p_area:  pointer to content of current region.

p_node:  tree node of current region.

p_gathered:  tree of gathered disjoint regions.

p_iterated:  stack of regions which have been shown.

p_marked:  stack of regions which have been marked.

attr:  locate attributes.

rtree_classes, elig_classes:  class lists for locate.

NOTE

Because pointers are kept in the instance data, objects of this
class must never be written to a file.

Because memory for objects is calloc'd, there is no explicit
init message override.

HISTORY

15 Feb 1989 jBk Genesis.
*/

# include "EMSadt.h"

instance ECrmDjRg
{
    IGRchar action;
    struct EMStreeHeap *p_area;
    struct EMStreeNode *p_node;
    struct EMStreeHeap *p_gathered;
    struct EMStreeHeap *p_iterated;
    struct EMStreeHeap *p_marked;
    struct GRlc_locate attr;
    OM_S_CLASSLIST rtree_classes, elig_classes;
};

override execute;
/*
MOTIVATION

I override this method because I have defined this class' unique
finite state machine via the execute method.

FILE

ECrmDjRgi.I
*/

override delete;
/*
MOTIVATION

Because some pointers are kept in the instance data, they need to
be freed.

FILE

ECrmDjRgi.I
*/

end specification ECrmDjRg;

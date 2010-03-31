# ifndef EMSadt_include
# define EMSadt_include 1

/*
DESCRIPTION

Contains various general purpose abstract data types.

HISTORY

07 Dec 1988 jBk Added comments regarding field position.
04 Oct 1988 jBk Added struct EMSelementWithList.
14 Sep 1988 jBk Genesis.
*/

/*
    EMStreeNode, EMStreeHeap:  structures for trees

    The fields of EMStreeNode and EMStreeHeap are not intended
    for use outside EFtree... and EFnode... functions.  You can
    bet they will change.  I even would recommend against using
    variables of type EMStreeNode and EMStreeHeap outside the
    EFtree... and EFnode... functions.  A pointer to character
    probably always is good enough to represent a pointer to one
    of these beasts. 
*/

struct EMStreeNode
{
    union
    {
        struct EMStreeNode *parent;
        struct EMStreeNode *nextFree;
    } pnf;
    struct EMStreeNode *left;
    struct EMStreeNode *right;
    char *content;
};

/*
    EMSteInHeap is 14 so sizeof struct EMStreeHeap is 240, which,
    with 8 bytes of malloc header, makes 248 per heap.
*/

# define EMSteInHeap 14

/*
    EMSthSize is the assumed size of a struct EMStreeHeap.
*/

# define EMSthSize   240

/*
    The nodeHeap field of struct EMStreeHeap is for storage of
    the pointer to another heap which is used to provide space
    for the contents of tree nodes.  Note that such space is not
    currently necessary if the content you wish to store has a
    size of less than or equal to a pointer to character.  If the
    nodeHeap field does not contain a pointer to a heap of memory
    (or some other useful gadget), then it ought to contain NULL.
*/

struct EMStreeHeap
{
    struct EMStreeNode elements[EMSteInHeap];
    struct EMStreeNode *freeElements;
    struct EMStreeNode *usedElements;
    struct EMStreeHeap *nextHeap;
    char *nodeHeap;
};

/*
    EMSgenericCountedElement:  generic element with a count.

    It is important that the content field remain first in struct
    EMSgenericCountedElement because this enables simple access
    to the content field, for purposes such as comparison, by
    simple functions intended to work on simple types.
*/

struct EMSgenericCountedElement
{
    char *content;
    int count;
};

/*
    EMSelementWithList:  an element which comes with a list.

    See struct EMSgenericCountedElement for a note regarding the
    position of the content field.
*/

struct EMSelementWithList
{
    char *content;
    struct EMStreeHeap *list;
};

# endif

/* ###################   APOGEE COMPILED   ################## */
class specification ECdebugEd (1:0) of ECelement;

/*
ABSTRACT

Write basic geometric elements to file; read basic geometric
elements from a file; edit basic geometric elements with the
editor of choice.

USER INTERFACE

Debug write geometry

- 1) Enter filename which is to be written.

- 2) Identify elements to write until MOVE_ON, at which time the
file is closed.

- 3) Restart at step 1.

Debug read geometry

- 1) Enter filename which is to be read, and all the elements
therein are read, instantiated and displayed.

- 2) Restart at step 1.

Debug edit geometry

- 1) Identify elements to write until MOVE_ON, at which time the
editor is invoked.

- 2) Edit the geometric elements in the file.

- 3) When the editor is exited, the elements in the temporary
file are read, instantiated and displayed.

- 4) Restart at step 1.

INSTANCE

action:  action to perform on way to next state.

fp:  file pointer.

attr:  locate attributes.

rtree_classes, elig_classes:  class lists for locate.

NOTE

Because pointers are kept in the instance data, objects of this
class must never be written to a file.

Because memory for objects is calloc'd, there is no explicit
init message override.

HISTORY

29 Dec 1989 DLB Added write_to_stdout flag.
23 Sep 1989 rlw Increased eligible class list in instance data from
                a size of 2 to a size of 3.
01 May 1989 jBk Genesis.
*/

# include <stdio.h>

instance ECdebugEd
{
    IGRchar action;
    FILE *fp;
    char tempEditFileName[BUFSIZ];
    struct GRlc_locate attr;
    OMuword rtreeClassids[2];
    OMuword eligClassids[3];
    OM_S_CLASSLIST rtree_classes, elig_classes;
    IGRboolean write_to_stdout;
};

override execute;
/*
MOTIVATION

I override this method because I have defined this class' unique
finite state machine via the execute method.

FILE

ECdebugEdi.I
*/

override delete;
/*
MOTIVATION

Because a file pointer is kept in the instance data, it must be
closed if it is non-NULL.

FILE

ECdebugEdi.I
*/

end specification ECdebugEd;

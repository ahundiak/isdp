/* ###################   APOGEE COMPILED   ################## */
class specification EMSname (1:0) of EMSlistener;

/*
ABSTRACT

This class is designed for associating a description with a
geometry.  It could be used anywhere a description is needed.

INSTANCE

to_described

This is a channel to the described entity.

name

This is the vla containing the description.

HISTORY

11-Feb-1988 jBk Added EMcmpDescription message.
30-Sep-1987 jBk Creation.
*/

# ifndef EMStypedef_include
# include "EMStypedef.h"
# endif

instance EMSname
{
    channel
    {
        (rel_ordered, many_to_many, initial=1, increment=1)
    } to_described;
    variable char name[0];
};

override EMascopy;
/*
MOTIVATION

This causes the description object to be copied and connected
with its copied described object.
*/

message EMputDescription (EMSrc *rc; char description[]);
message EMappDescription (EMSrc *rc; char appendix[]);
/*
ABSTRACT

Add to the description in the instance data.

ARGUMENTS

rc

    A pointer to the returned value.  It is the same as the
    returned value of this message.

description

    A null terminated string which becomes the description in the
    instance data.

appendix

    A null terminated string which is appended to the description
    in the instance data.

RETURNED VALUES

    OM_S_SUCCESS for complete success.

    Other codes for things such as vla inextensibility.

FILE

    EMnamei.I
*/

message EMgetDescription (EMSrc *rc; char description[]; int len);
/*
ABSTRACT

This message causes a member of this class to reveal the
description in its instance data.

ARGUMENTS

rc

    A pointer to the returned value.  It is the same as the
    returned value of this message.

description

    It is to here the null terminated description string is
    copied.

len

    If len is NULL, all of the description shall be copied to
    the description buffer.  For len >= 1, a null-terminated
    string of length (as would be determined by strlen (3))
    no more than len is returned.  For len >= 1, the description
    buffer must be at least of size len+1.

RETURNED VALUES

    OM_S_SUCCESS on complete success.

    OM_E_INVARG if size is neither NULL nor greater than 1.  Two
    is the minimum length for meaningful data:  one character and
    a null terminator.

FILE

    EMnamei.I
*/

message EMlenDescription (EMSrc *rc; int *len);
/*
ABSTRACT

This message causes a member of this class to disclose the length
of the description (not including the null terminator) in its
instance data.

ARGUMENTS

rc

    A pointer to the returned value.  It is the same as the
    returned value of this message.

len

    A pointer to the returned length.

RETURNED VALUES

Currently, always OM_S_SUCCESS.

FILE

    EMnamei.I
*/

message EMcmpDescription (EMSrc *rc; char string[]; int *relationship);
/*
ABSTRACT

This message causes a member of this class to compare its
description with an input string (cf. strcmp in string(3C)).

ARGUMENTS

rc

    A pointer to the returned value.  It is the same as the
    returned value of this message.

string

    The input string for the comparison.

relationship

    Pointer to the result of the comparison:  less than zero if
    string is lexically less than my description, zero if
    equivalent and greater than zero if lexically greater.

RETURNED VALUES

Currently, always OM_S_SUCCESS.

FILE

    EMnamei.I
*/

end specification EMSname;

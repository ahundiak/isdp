/* ###################   APOGEE COMPILED   ################## */
class specification ECigdscell (1:0) of ECigdsiems, COcvtclsl;

/*
DESCRIPTION

This class works like COcvtclsl, used as the IGDS cell library to
I/Draft translator, but uses the extensions of I/EMS to translate
more accurately.

HISTORY

09 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
02 Feb 1989 rlw Modified to add conditional compilation statements
                for the I/DRAW product.
*/
from ECigdsiems inherit cvt_type1214;
#ifndef IDRAW
from ECigdsiems inherit cvt_type1819, cvt_type23;
#endif
/*
MOTIVATION

Both ECigdsiems and COcvtclsl are subclasses of COcvigdsige.
Since these messages are the COcvigdsige messages whose
implementations are overridden by ECigdsiems and which are not
overridden by COcvtclsl, I need to use the ECigdsiems
implementations to use the extensions of I/EMS to translate a
cell library from IGDS to I/EMS more accurately.
*/
#ifndef IDRAW
from ECigdsiems inherit cvt_type2;
#endif
/*
MOTIVATION

If unnamed orphan cells occur in cell libraries, I want to check
for them.
*/

end specification ECigdscell;

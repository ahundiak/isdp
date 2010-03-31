#ifndef _dpb_h
#define _dpb_h

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

extern PWresult pwGetDpbInfo _PW_ ((
    struct PWdpbdata *dpbdata,
    PWosnum os
));

extern PWresult pwSetBSFromDpbInfo _PW_ ((
    struct PWdpbdata *dpbdata
));

#if defined(__cplusplus)
}
#endif

#endif







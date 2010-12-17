/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mdlerrs.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   mdlerrs.h -- Error status definitions for MDL			|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mdlerrsH__)
#define __mdlerrsH__

#define	    MDLERR_NOTRANSFORM	    -101
#define	    MDLERR_BADVIEWNUMBER    -102
#define	    MDLERR_INSFINFO	    -103
#define	    MDLERR_FILE2SUB3	    -104
#define	    MDLERR_BADELEMENT	    -105
#define	    MDLERR_INVREGEX	    -106
#define	    MDLERR_BADFILENUMBER    -107
#define	    MDLERR_FILEREADONLY	    -108
#define	    MDLERR_DISKFULL	    -109
#define	    MDLERR_WRITEINHIBIT	    -110
#define	    MDLERR_WRITEFAILED	    -111
#define	    MDLERR_MODIFYCOMPLEX    -112
#define	    MDLERR_CANNOTOPENFILE   -113
#define	    MDLERR_ENDOFFILE	    -114
#define	    MDLERR_BADSCANLIST	    -115
#define	    MDLERR_INSFMEMORY	    -116
#define	    MDLERR_NOTCMPLXHDR	    -117
#define	    MDLERR_ALREADYLOADED    -118
#define	    MDLERR_BADFILETYPE	    -119
#define	    MDLERR_READFAILED       -120
#define	    MDLERR_NOSUCHAPPLICATION -121
#define	    MDLERR_REJECTED	    -122
#define	    MDLERR_NOMATCH	    -123
#define	    MDLERR_AMBIGUOUS	    -124
#define	    MDLERR_BADSLOT	    -125
#define	    MDLERR_BADARG	    -126
#define	    MDLERR_BADCOPYPARALLEL  -127
#define	    MDLERR_RESOURCENOTFOUND -128
#define	    MDLERR_NOCELLLIBRARY    -129
#define	    MDLERR_VIEWNOTDISPLAYED -130
#define	    MDLERR_CELLNOTFOUND	    -131
#define	    MDLERR_CELLEXISTS	    -132
#define	    MDLERR_INVALIDCELL	    -133
#define	    MDLERR_BADINDEX	    -134
#define	    MDLERR_CELLTOOLARGE	    -135
#define	    MDLERR_INVALIDLIBRARY   -136
#define	    MDLERR_BADLINKERINFO    -137
#define	    MDLERR_NOTAVAILABLE	    -138
#define	    MDLERR_CELLLIB2DGN3	    -139

/* B-Spline Errors */
#define	    MDLERR_NOPOLES	    -500
#define	    MDLERR_NOKNOTS	    -501
#define	    MDLERR_NOWEIGHTS	    -502 
#define	    MDLERR_NOBOUNDS	    -503
#define	    MDLERR_NONUMBOUNDS	    -504
#define	    MDLERR_NOBSPHEADER	    -505
#define	    MDLERR_TOOFEWPOLES	    -506
#define	    MDLERR_TOOMANYPOLES	    -507
#define	    MDLERR_BADBSPELM	    -508
#define	    MDLERR_BADPARAMETER	    -509
#define	    MDLERR_BADORDER	    -510
#define	    MDLERR_BADPERIODICITY   -511
#define	    MDLERR_BADPOLES    	    -512
#define	    MDLERR_BADKNOTS    	    -513
#define	    MDLERR_BADWEIGHTS  	    -514
#define	    MDLERR_BADSPIRALDEFINITION -515


/*  MDL Errors for the expression parser.  (to be added to MDLErrors) */
#define	    MDLERR_FIRSTEXPRERROR   (-700)
#define	    MDLERR_ALREADYINUSE	    -700
#define	    MDLERR_BADTYPE	    -701
#define	    MDLERR_NEEDINT	    -702
#define	    MDLERR_STRUCTNEEDED	    -703
/*  The following codes are all reserved for errors in numeric constants */
#define	    MDLERR_NUMERRORS	    -704
#define	    MDLERR_BADHEX	    -705
#define	    MDLERR_NEEDEXPONENT	    -706
#define	    MDLERR_BADOCTAL	    -707
#define	    MDLERR_BADFLOAT	    -708
#define	    MDLERR_BADSTRING	    -709
#define	    MDLERR_BADCHARCONS	    -710 
#define	    MDLERR_ILLEGALCHAR	    -711
#define	    MDLERR_UNSUPPORTED	    -712
#define	    MDLERR_NOSYMBOL	    -713
#define	    MDLERR_SYNTAXERROR	    -714
#define	    MDLERR_INVALIDSYMBOL    -715
#define	    MDLERR_TYPESINCOMPATIBLE -716
#define	    MDLERR_CANNOTDEREF	    -717
#define	    MDLERR_NOTSTRUCT	    -718
#define	    MDLERR_NOTMEMBER	    -719
#define	    MDLERR_ADDRNOTKNOWN	    -720
#define	    MDLERR_TOOCOMPLEX	    -721
#define	    MDLERR_INVALIDFORSTRUCT -722
#define	    MDLERR_INVALIDFORFLOAT  -723
#define	    MDLERR_DIVIDEBYZERO	    -724
#define	    MDLERR_ADDRNOTVALID	    -725
#define	    MDLERR_INVALIDFORTYPE   -726
#define	    MDLERR_INTEGRALNEEDED   -727
#define	    MDLERR_NOTVALIDEXPRESS  -728
#define	    MDLERR_NOTFUNCTION	    -729
#define	    MDLERR_TOOMANYARGUMENTS -730
#define	    MDLERR_TOOFEWARGUMENTS  -731
#define	    MDLERR_BADRSCTYPE	    -732
#define	    MDLERR_INVALIDFORFUNC   -733
#define	    MDLERR_LASTEXPRERROR    (-733)
#define	    MDLERR_NOACSDEFINED	    -734
#define	    MDLERR_ACSREPLACED	    -735
#define	    MDLERR_ACSNOTFOUND	    -736
#define	    MDLERR_VIEWNOTFOUND	    -737
#define	    MDLERR_INVALIDACSTYPE   -734    
#define	    MDLERR_INVALIDBUTTON    -735
#define	    MDLERR_NOREFSLOTS	    -736
#define	    MDLERR_NOTDESIGNFILE    -736
#define	    MDLERR_3DREF2DMASTER    -737
#define	    MDLERR_DUPLICATELOGICAL -738
#define	    MDLERR_NOTSINGLEVIEW    -739
#define	    MDLERR_INVALIDREFORG    -740
#define	    MDLERR_INVALIDMASTERORG -741
#define	    MDLERR_INVALIDREF	    -742
#define	    MDLERR_INVALIDCLIP	    -743
#define	    MDLERR_INVALIDPATSPACE  -744
#define	    MDLERR_NONCLOSEDPATELM  -745
#define	    MDLERR_NONSOLIDPATELM   -746
#define	    MDLERR_NONCLOSEDELM	    -747
#define	    MDLERR_ELMFILLED	    -748
#define	    MDLERR_ELMNOTFILLED	    -749
#define	    MDLERR_ELMTOOLARGE	    -750

/* Resource Manager Error Codes	*/
#define     MDLERR_RSCERROR    	    -900
#define     MDLERR_RSCFILEERROR	    -901
#define     MDLERR_RSCHANDLEINVALID -902
#define     MDLERR_RSCFILENOTFOUND  -903
#define     MDLERR_RSCINSFMEM	    -904
#define     MDLERR_RSCWRITEERROR    -905
#define     MDLERR_RSCWRITEVIOLATION -906
#define     MDLERR_RSCADDRINVALID   -907
#define     MDLERR_RSCTYPEINVALID   -908
#define     MDLERR_RSCALREADYEXISTS -909
#define     MDLERR_RSCBADVERSION    -910
#define     MDLERR_RSCINUSE	    -911
#define     MDLERR_RSCNOTFOUND	    -912
#define     MDLERR_RSCSTRINGNOTFOUND -913
#define     MDLERR_RSCQRYIDINVALID  -914
#define     MDLERR_RSCDIRECTADDPEND -915

#endif	    /* __mdlerrsH__ */

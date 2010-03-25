#ifndef DIPDEF
/*
** DIP message types
*/
#define	DIP_CONFIG		'\001'
#define	DIP_ATTRIBUTES		'\002'
#define	DIP_ACCESS		'\003'
#define	DIP_CONTROL		'\004'
#define	DIP_CONTINUE		'\005'
#define	DIP_ACK			'\006'
#define	DIP_ACC_CMP		'\007'
#define	DIP_DATA		'\010'
#define	DIP_STATUS		'\011'
#define	DIP_KEYDEF		'\012'
#define	DIP_ALLOC		'\013'
#define	DIP_SUMM		'\014'
#define	DIP_DATTIM		'\015'
#define	DIP_PROTECT		'\016'
#define	DIP_NAME		'\017'
#define	DIP_ACL			'\020'
#define	DIP_CHD			'\021'
#define DIP_FLUSH		'\022'
#define DIP_FLUSH_ACK		'\023'
#define DIP_ENDOFSESSION	 0xff

/* Configuration message definitions */ 

#define	DIP_OS_RT11	'\001'
#define	DIP_OS_RSTSE	'\002'
#define	DIP_OS_RSX11S	'\003'
#define	DIP_OS_RSX11D	'\004'
#define	DIP_OS_RSX11M	'\005'
#define	DIP_OS_IAS	'\006'
#define	DIP_OS_VAXVMS	'\007'
#define	DIP_OS_TOPS20	'\010'
#define	DIP_OS_TOPS10	'\011'
#define	DIP_OS_RTS8	'\012'
#define	DIP_OS_OS8	'\013'
#define	DIP_OS_RSX11MP	'\014'
#define	DIP_OS_COPOS11	'\015'
#define	DIP_OS_UNIX	'\016'

#define	DIP_FSYS_RMS11	'\001'
#define	DIP_FSYS_RMS20	'\002'
#define	DIP_FSYS_RMS32	'\003'
#define	DIP_FSYS_FCS11	'\004'
#define	DIP_FSYS_RT11	'\005'
#define	DIP_FSYS_NONE	'\006'
#define	DIP_FSYS_TOPS20	'\007'
#define	DIP_FSYS_TOPS10	'\010'
#define	DIP_FSYS_OS8	'\011'
#define	DIP_FSYS_UNIX	'\012'

/* Attributes message definitions */

#define	DIP_ATT_DATYPE		0x1
#define	DIP_ATT_ORG		0x2
#define	DIP_ATT_RFM		0x4
#define	DIP_ATT_RAT		0x8
#define	DIP_ATT_BLS		0x10
#define	DIP_ATT_MRS		0x20
#define	DIP_ATT_ALQ		0x40
#define	DIP_ATT_BKS		0x80
#define	DIP_ATT_FSZ		0x100
#define	DIP_ATT_MRN		0x200
#define	DIP_ATT_RUNSYS		0x400
#define	DIP_ATT_DEQ		0x800
#define	DIP_ATT_FOP		0x1000
#define	DIP_ATT_BSZ		0x2000
#define	DIP_ATT_DEV		0x4000
#define	DIP_ATT_SDC		0x8000
#define	DIP_ATT_LRL		0x10000
#define	DIP_ATT_HBK		0x20000
#define	DIP_ATT_EBK		0x40000
#define	DIP_ATT_FFB		0x80000
#define	DIP_ATT_SBN		0x100000

#define	DIP_DTP_ASCII	0x1
#define	DIP_DTP_IMAGE	0x2
#define	DIP_DTP_EBCDIC	0x4
#define	DIP_DTP_CMPRES	0x8
#define	DIP_DTP_EXECUT	0x10
#define	DIP_DTP_PRIVIL	0x20
#define	DIP_DTP_SECRET	0x80

#define	DIP_ORG_SEQ	0
#define	DIP_ORG_REL	020
#define	DIP_ORG_IDX	040
#define	DIP_ORG_HSH	060

#define	DIP_RFM_UDF	0
#define	DIP_RFM_FIX	1
#define	DIP_RFM_VAR	2
#define	DIP_RFM_VFC	3
#define	DIP_RFM_STM	4
#define	DIP_RFM_STMLF	5
#define	DIP_RFM_STMCR	6

#define	DIP_RAT_FTN	0x1
#define	DIP_RAT_CR	0x2
#define	DIP_RAT_PRN	0x4
#define	DIP_RAT_BLK	0x8

#define	DIP_FOP_MXV	(1<<1)
#define	DIP_FOP_SUP	(1<<2)
#define	DIP_FOP_TMP	(1<<3)
#define	DIP_FOP_TMD	(1<<4)
#define	DIP_FOP_DFW	(1<<5)
#define	DIP_FOP_RWO	(1<<7)
#define	DIP_FOP_POS	(1<<8)
#define	DIP_FOP_WCK	(1<<9)
#define	DIP_FOP_NEF	(1<<10)
#define	DIP_FOP_RWC	(1<<11)
#define	DIP_FOP_SPL	(1<<13)
#define	DIP_FOP_SCF	(1<<14)
#define	DIP_FOP_DLT	(1<<15)
#define	DIP_FOP_CTG	(1<<20)
#define	DIP_FOP_CBT	(1<<21)
#define	DIP_FOP_RCK	(1<<23)
#define	DIP_FOP_CIF	(1<<25)
#define	DIP_FOP_TEF	(1<<28)
#define	DIP_FOP_OFP	(1<<29)

/* Access message definitions */

#define	DIP_ACFUN_OPEN		1
#define	DIP_ACFUN_CREATE	2
#define	DIP_ACFUN_RENAME	3
#define	DIP_ACFUN_ERASE		4
#define	DIP_ACFUN_PRINT		5
#define	DIP_ACFUN_DIRECTORY	6
#define	DIP_ACFUN_SUBMIT	7
#define DIP_ACFUN_COMMAND	8
#define	DIP_ACFUN_TYPE		9

#define DIP_ACOPT_COMPRESS      0x01
#define DIP_ACOPT_INHIBIT       0X02
#define	DIP_ACOPT_GO_NOGO	0x10
#define	DIP_ACOPT_STREAM	0x20

#define	DIP_FAC_PUT	0x1
#define	DIP_FAC_GET	0x2
#define	DIP_FAC_DEL	0x4
#define	DIP_FAC_UPD	0x8
#define	DIP_FAC_TRN	0x10
#define	DIP_FAC_BIO	0x20
#define	DIP_FAC_BRO	0x40

#define	DIP_SHR_PUT	0x1
#define	DIP_SHR_GET	0x2
#define	DIP_SHR_DEL	0x4
#define	DIP_SHR_UPD	0x8
#define	DIP_SHR_MSE	0x10
#define	DIP_SHR_UPI	0x20
#define	DIP_SHR_NIL	0x40

#define	DIP_DSP_ATT	0x1
#define	DIP_DSP_KEY	0x2
#define	DIP_DSP_ALL	0x4
#define	DIP_DSP_SUM	0x8
#define	DIP_DSP_DTM	0x10
#define	DIP_DSP_PRO	0x20
#define	DIP_DSP_ACL	0x80
#define	DIP_DSP_NAM	0x100

/* Control message definitions */

#define	DIP_CTLFUN_GET_READ	1
#define	DIP_CTLFUN_CONNECT	2
#define	DIP_CTLFUN_UPDATE	3
#define	DIP_CTLFUN_PUT_WRITE	4
#define	DIP_CTLFUN_DELETE	5
#define	DIP_CTLFUN_REWIND	6
#define	DIP_CTLFUN_TRUNCATE	7
#define	DIP_CTLFUN_MODIFY	8
#define	DIP_CTLFUN_RELEASE	9
#define	DIP_CTLFUN_FREE		10
#define	DIP_CTLFUN_FLUSH	12
#define	DIP_CTLFUN_NXTVOL	13
#define	DIP_CTLFUN_FIND		14
#define	DIP_CTLFUN_EXTEND	15
#define	DIP_CTLFUN_DISPLAY	16
#define	DIP_CTLFUN_SPACE_FWD	17
#define	DIP_CTLFUN_SPACE_BKWD	18
#define DIP_CTLFUN_SKIP		19

#define	DIP_CTLMEN_RAC	    0X1
#define	DIP_CTLMEN_KEY	    0X2
#define	DIP_CTLMEN_KRF	    0X4
#define	DIP_CTLMEN_ROP	    0X8
#define	DIP_CTLMEN_HSH	    0X10
#define	DIP_CTLMEN_DISPLAY  0X20

/* Continue-transfer message definitions */

#define	DIP_CONFUN_RETRY	1
#define	DIP_CONFUN_SKIP		2
#define	DIP_CONFUN_ABORT	3
#define	DIP_CONFUN_RESUME	4

/* Access-complete message definitions */

#define	DIP_CMPFUN_CLOSE	1
#define	DIP_CMPFUN_RESPONSE	2
#define	DIP_CMPFUN_PURGE	3
#define	DIP_CMPFUN_EOS		4
#define	DIP_CMPFUN_SKIP		5
#define	DIP_CMPFUN_BREAK	6

/* Allocation menu definitions */

#define	DIP_ALLMEN_VOL	0x1
#define	DIP_ALLMEN_ALN	0x2
#define	DIP_ALLMEN_AOP	0x4
#define	DIP_ALLMEN_LOC	0x8
#define	DIP_ALLMEN_RFI	0x10
#define	DIP_ALLMEN_ALQ	0x20
#define	DIP_ALLMEN_AID	0x40
#define	DIP_ALLMEN_BKZ	0x80
#define	DIP_ALLMEN_DEQ	0x100

/* Date-time message definitions */

#define	DIP_DAT_CDT	0x1
#define	DIP_DAT_RDT	0x2
#define	DIP_DAT_EDT	0x4
#define	DIP_DAT_RVN	0x8

/* Protection message definitions */

#define	DIP_MASK_DENYREAD	0x1
#define	DIP_MASK_DENYWRITE	0x2
#define	DIP_MASK_DENYEXECUTE	0x4
#define	DIP_MASK_DENYDELETE	0x8

/* define some dip structures */

struct cnfgblk
{
    short   bufsiz;
    char    ostype;
    char    filesys;
    char    vernum;
    char    econum;
    char    usrnum;
    char    softver;
    char    usrsoft;
    char    flags;
};

struct attblk
{
    short   datatype;
    char    org;
    char    rfm;
    char    rat;
    short   bls;
    short   mrs;
    long    alq;
    char    bks;
    char    fsz;
    long    mrn[2];
    short   deq;
    long    fop[2];
    char    bsz;
    long    dev[2];
    long    sdc[2];
    short   lrl;
    long    hbk;
    long    ebk;
    short   ffb;
    long    sbn;
};

struct accblk
{
    char    accfunc;
    long    accopt;
    char    filespec[256];
};

struct ctlblk
{
    char    ctlfunc;
};

struct cmpblk
{
    char    cmpfunc;
    long    cmpfop[2];
    short   check;
};

struct stsblk
{
    short   stscode;
    long    rfa[2];
    long    recnum[2];
    char    errstr[256];
};

struct allblk
{
    long    allmenu;
    short   vol;
    long    aln;
    long    aop;
    long    loc[2];
    long    alq;
    char    aid;
    char    bkz;
    char    deq;
};

struct dtmblk
{
    long    datmenu;
    char    cdt[19];
    char    rdt[19];
    char    edt[19];
    short   rvn;
};

struct problk
{
    long    protmenu;
    char    owner[41];
    long    protsys;
    long    protown;
    long    protgrp;
    long    protwld;
};

struct namblk
{
    char    file[256];
};

struct chdblk
{
    char    filespec[256];
};
#define	DIPDEF
#endif	/* DIPDEF */

/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							lu62usr.h
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		user include file for transaction programs
**	
**	REVISION HISTORY:
*/
 
#ifndef symdim_h
#define symdim_h xxx

/*** symdim.h		system-wide symbolic dimemsions */

/* maximum lengths of character strings	*/
#define		MAXCPL		8		/* controller process name */
#define		MAXPUL		8		/* pu name */
#define		MAXLUL		8		/* locally known lu name */
#define		MAXFQLL		17		/* fully qualified lu name */
#define		MAXUNLL		8		/* uninterpreted lu name */
#define		MAXLINL		8		/* line name */
#define		MAXLCLL		8		/* line class name */
#define		MAXSTAL		8		/* station name */
#define		MAXMODL		8		/* mode name */
#define		MAXTPL		64		/* transaction program name */
#define		MAXPGNM		MAXTPL	/* 		"			"	"	*/
#define		MAXSECL		10		/* security field */
#define		MAXMAPL		64		/* map name */
#define		MAXLLPL		8		/* lu-lu password */
#define		MAXNID      8		/* network id */
#define		MAXNLUN		8		/* network lu name */
#define		MAXXBL		2		/* xid block number */
#define		MAXXNM		3		/* xid id number */
#define		MAXIPL		120		/* input file/execute name */
#define		MAXPIPE		MAXIPL	/*	"		"	name */
#define		MAXOBJL		MAXIPL	/* general comm manager object */
#define		MAXADNR		40		/* auto-dial string */
#define		MAXXSTR		255		/* max length of xid string sent/recd */
#define		MAXNXID		10		/* max # of valid received xid's */
#define		MAXABF		10		/* max # of async characters sent
								   or received in async passthrough
								   mode */
#define		MAXLUW		26		/* logical unit of work identifier */
#define		MAXBITMP	8		/* cov 'define/modify' bit map */

/* qllc - x25 */
#define		MAXDTEADR	15		/*max # of digits in a x25 dte address*/
#define		MAXCUD		16		/* max # of octets in call user data */
#define		MAXFAC		63		/* max # of octets in facilities field*/

/* maximum length of the variable section of the cm' message */
#define 	MAXVAR		200		/* segment length */
#define		MAXTOTVAR	1800	/* sum of all segments */

/* maximum length of the variable section of the nm' message */
#define		MAXNVAR		200

/* number of fields between nm and pu */
#define		NM08SIZ		16	
#define		NM16SIZ		10
#define		NM32SIZ		5

/* maximal line speed (baud rate) */
#define		MAXLSPD		56000

#endif /* symdim_h */
#ifndef ludef_h
#define ludef_h

/* ludef.h */

/* lu device class: */
#define CM_XXXX		0		/* not configured */
#define CM_PRIN		1		/* 3287 printer */
#define CM_TERM		2		/* 3278 terminal */
#define CM_RJE		3		/* rje device */
#define CM_LU62		4		/* lu 6.2 device */
#define CM_LU0		5		/* lu 0 */

/* lu configuration bits: */
#define CM_DFLU		0x01	/* bit 0	1 if the default lu */
#define CM_TRMD		0x02	/* bit 1	1 if terminate on disconnect */
#define CM_SYSM		0x04	/* bit 2	1 if system mode */
#define CM_INDP		0x08	/* bit 3	1 if independent LU */

/* lu name type used internally and in some messages to identify an lu
	name as local, fully qualified or uninterpreted */
#define NAME_LC 1
#define NAME_FQ 2
#define NAME_UI 3

/* forced lu disable bit */
#define LU_FORC		0x01

/* security field acceptance on incoming allocation requests */
/* from the remote lu: */
#define CM_NOAS		0	/* no access security info accepted */
#define CM_COAS		1	/* Security Information fields accepted */
#define CM_AVER		2	/* Already Verified indicator accepted */

#endif /* ludef.h */
#ifndef tpdef_h
#define tpdef_h

/* tpdef.h */


/* security level values for ALLOCATE verb */
#define SEC_NONE	0		/* none */
#define	SEC_SAME	1		/* same security level as this remotely
								started TP */
#define SEC_PGM		2		/* security information supplied by caller*/


/* defined type of security verification required for incoming
	allocation requests (none, conversation, or access; access
	has a subfield - profile, user_id, or user_id_profile)		*/
#define	CM_NOSV		1
#define	CM_CONV		2
#define	CM_ACCS		3

	/* (subfield if the security verification type is access */
#define	CM_PROF		1
#define	CM_USID		2
#define	CM_UIDP		3


/* allocation return control for ALLOCATE verb */
#define SS_ALLOC	0		/* when allocated */
#define SS_DELAY	1		/* delayed allocation */
#define SS_IMMED	2		/* immediate return */

/* sync level support: */
/* NOTE: These values are as specified in BIND request and fmh5
   and should not be changed. */
#define CM_SY0		0		/* none */
#define CM_CNFM		0x01	/* confirm is supported */
#define CM_CNSY		0x02	/* confirm, syncpoint, and backout
							   are supported */

/* sync level support defined for a transaction program : */
/* NOTE: These values should correspond to the ones above. */
#define CM_CONF		0x01	/* 'confirm' is supported */
#define CM_SYNC		0x02	/* 'syncpoint' is supported */
#define CM_NOSL		0x04	/* 'none' is supported */

/* privilege masks: */
#define CM_NOPR		0x01L	/* no privileges	*/
#define CM_CNPR		0x02L	/* cnos privilege	*/
#define CM_SCPR		0x04L	/* session_control priv	*/
#define CM_DFPR		0x08L	/* define privilege	*/
#define CM_DSPR		0x10L	/* display privilege */
#define CM_SSPR		0x20L	/* start/stop priv	*/
#define CM_SNPR		0x40L	/* send privilege	*/
#define CM_ASPR		0x80L	/* allocate_service_tp privilege */

/* tp starting execution status: */
#define CM_ENAB	1			/* enabled */
#define CM_TDIS	2			/* temporarily disabled */
#define CM_PDIS	3			/* permanently disabled */

/* define tpr conversation type (mapped | basic)	*/
#define		CM_MAPPD	0x01	
#define		CM_BASIC	0x02

/* conversation type as specified in fmh5 */
#define	CM_BCON		0xd0	/* basic */
#define	CM_MCON		0xd1	/* mapped */
			

/* started or attached */
#define STARTED 0				 /* tp was (locally) started - sent by
									CM in power-on response */
#define ATTACHED 1				 /* tp was (remotely) attached - sent by
									CM in power-on response */

#endif /* tpdef.h */
#ifndef pccst_h
#define pccst_h

/* conversation states */
#define CVS_REST 0 
#define CVS_SEND 1 
#define CVS_DEFR 2
#define CVS_RECV 3
#define CVS_CONF 4
#define CVS_SYNC 5
#define CVS_BACK 6
#define CVS_DEAL 7

#endif
			/** Conversation API user definitions **/



/* the following values may be passed to a receive verb */
#define FILL_LL  1	/* get next logical record */
#define FILL_BUF 2	/* fill buffer, disregarding logical record length */


/* the following values are set in the lu62wtrc field */
#define       LU62DATA 1
#define       LU62IND  2

/* When lu62wtrc is set to LU62DATA */
#define       DA_CMPL 1  /* complete logical record   */
#define       DA_INCP 2  /* incomplete logical record */
#define       LL_TRNC 4  /* logical record truncated - currently unused*/
#define 	  FMH_CMP 8  /* complete fmh logical record */
#define 	  FMH_INCP 0x10	/* incomplete fmh logical record */
#define	      DA_DAT    0x20	/* received data - set when
				   user specifies not to receive
				   in logical lengths */

/* When lu62wtrc is set to LU62IND */
#define IND_SEND	1	/* set when prepare-to-receive-flush 
							is expected */
#define IND_CONF	2	/* set when confirm is expected */
#define IND_CFSD	4	/* set when prepare to receive confirm
							is expected */
#define IND_CFDA	8	/* set when deallocate confirm is executed */


/* the following constants are used in DEALLOCATE verb for type parameter */
#define DA_SYNC  1 /* do according to sync level */
#define DA_FLUSH 2 /* specified flush */ 
#define DA_CONF  3 /* specified confirm */
#define DA_ABNDP 4 /* abend program */
#define DA_ABNDS 5 /* abend svc */
#define DA_LOCAL 6 /* Deallocate local */
#define DA_ABNDT 7 /* abend timer */

 
/* The following constants are used in PP_TO_RCV verb for type parameter*/
#define PP_SYLVL 1 /* do according to sync level */
#define PP_FLUSH 2 /* flush data before going to receive state*/
#define PP_CONF  3 /* confirm before going to receive state */

/* The following constants are used for LOCK parameter for PP_TO_RCV */
#define PP_LK_SH 0 /* lock is short */
#define PP_LK_LG 1 /* long lock */


/* The following constants are used for the type parameter in SEND_ERR */
#define SE_PROG 1
#define SE_SVC  2

/* The following constants are used in TEST verb */
#define TS_POST 1
#define TS_RTS  2


#define OK 0	/* generic positive return flag - this should not be changed */

/* The following codes are returned to user via the lu62rc1 field
 *		NOTE WELL:	The following return codes should be distinct
 *					from any of the resaon codes listed below
 */
#define RC_ALCER  71 		/* ALLOCATION ERROR */
#define RC_BACK   72  		/* backed out */
#define RC_PGNTR  73  		/* PROGRAM ERROR - no trunc */
#define RC_SVTRC  74  		/* SVC ERROR - truncated */
#define RC_RFAIL  75 		/* Resource Failure - no retry*/
#define RC_DANML  76   		/* DEALLOCATE NORMAL */
#define RC_UNSCS  77   		/* unsucessful */
#define RC_PSNAC  78		/* posting not active */
#define RC_MAPNS  79		/* mapping not supported    */
#define RC_MAPNF  80		/* map not found            */
#define RC_MAPEX  81		/* map execution failed.    */
#define PARM_ERR  82		/* parameter error			*/
#define RC_PGTRC  83  		/* PROGRAM ERROR - truncated */
#define RC_PGPUR  84  		/* PROGRAM ERROR - purging */
#define RC_SVNTR  85  		/* SVC ERROR - no trunc */
#define RC_SVPUR  86  		/* SVC ERROR - purging */
#define RC_ABPGM  87   		/* DEALLOCATE ERROR - deallocate abend */
#define RC_ABSVC  88  		/* DEALLOCATE ERROR - deallocate SVC */
#define RC_ABTIM  89   		/* DEALLOCATE ERROR - deallocate timer */
#define RC_RFTRY  90		/* resource failure - retry	       */
#define RC_FMHNS  91		/* fmh data not supported */
#define RC_BREAK  92		/* LU62BRK was called and API successfully
							   broke out of a pended read */


/*
 * list of possible reason codes
 *	Possible Reason codes when return code is
 *		either ALLOCATION_ERROR(RC_ALCER) or RESOURCE_FAILURE(RS_FAIL)
 */
#define NORMAL		0			/* normal tp outage */
#define RS_RETRY	1			/*  retry                      */
#define RS_NOTRY	2			/*  no retry                   */
#define RS_SYLVL	3			/*  synchronization level      */
#define RS_BIDLIM	4			/* bid limit exceeded			*/
#define RS_TPNR		5			/*  tp. program not recgonised */ 
#define RS_PIPNA	6			/*  pip not allowed         */ 
#define RS_PIPNC	7			/*  pip not specified correctly*/ 
#define RS_CVMIS	8			/*  conversation type mismatch */ 
#define RS_SYLNS	9			/*  syncl level not supported  */
#define RS_RCLNS	10			/*  reconnect level not supp.  */
#define RS_TPNAN	11			/*  Tp. not available. No retry*/
#define RS_TPNAR	12			/*  Tp. not available. Retry   */
#define RS_SECNV	13			/*  security not valid.         */
#define RS_LIMIT	14			/*  some limit has been exceeded */
#define RS_NOTDA  	15			/* Something other that data was received */
#define RS_DATA   	16		/* Data is received */


/* returned with PARM_ERR: */
#define RS_INVLU	17			/* invalid LU name */

/* values for security array indicating which security subfields
	are defined */
#define SEC_UID	1		/* user id */
#define SEC_PSWD 2		/* password */
#define PROFILE 4		/* profile id */





/* The following are the list of Abend codes */
#define A_UNATCH  800   /* program not attached */
#define A_MYNAME  900   /* invalid local program name specified */
#define A_CVID   1000   /* invalid resource id specified */
#define A_NULLCB 1001	/* NULL lcb supplied on verb call */
#define A_NULWCB 1002	/* NULL wcb supplied on WAIT call */
#define A_BADWCB 1003	/* Bad value # conversations in wcb on WAIT call */
#define A_CVTYP  1010   /* invalid conversation type specified */
#define A_SYNLVL 1020   /* invalid sync level specified */
#define A_LUNAM  1030   /* invalid logical unit name length */
#define A_TPSVC  1032   /* invalid privelege to invoke a service program */
#define A_SNAMG  1034   /* SNASVCMG specified by non service program */
#define A_INVSEC 1036   /* invalid security data */
#define A_PATPN  1040   /* invalid partner program specified */
#define A_INRCTL 1042   /* invalid return control specified on allocate verb */
#define A_INVPC  1044   /* invalid pip number specified. */
#define A_INVPL  1046   /* invalid pip length specified. */
#define A_NOPIP  1047	/* pip data missing */
#define A_LLCHK  1050   /* logical record not sent */
#define A_LENER  1060   /* invalid length specified */
#define A_STCHK  1080   /* state check for this verb */
#define A_NOCFM  1090   /* CONFIRM requested when sync level set to NONE */
#define A_IPCER  3000   /* API inter-process communication error*/
#define A_DATYP  4000   /* invalid type parameter on deallocate verb*/
#define A_PPLOCK 4010   /* invalid lock paramter specified on PP_TO_REC*/
#define A_PPTYP  4020   /* invalid type parameter specified on PP_TO_REC*/
#define A_ATTCH  4030	/* LU62ATTCH called a second time */
#define A_NOTRMT 5000   /* LU62CVCT issued by local program */
#define A_INVPP  5010   /* remote sent invalid pip data */
#define A_POSTYP 5030   /* invalid type specified on post verb */
#define A_SETYP  5040   /* invalid type specified on send-error verb*/
#define A_NOFMH  6000   /* remote did not send expected fmh7 */
#define A_TESTYP 6020   /* invalid test parameter specified */
#define A_LOGID  6030   /* invalid log id specified. */
#define A_RCVLN  6040   /* invalid receive len error */
#define A_PSTLN  6050   /* invalid posting length error */
#define A_PLUNAM 6060   /* invalid partner lu name type */
#define A_BDMPN  6070   /* invalid map name */
#define A_FILL   6080   /* invalid fill parameter */
#define A_BDSNS  6090	/* unrecognized sense code in fmh7 */
#define A_BDBRK  7000	/* LU62BRK was called and API could not
						   successfully break out of verb */

/* The following abend conditions could arise because they are not
** supported.
*/
#define A_SECRTY 8000   /* security PGM not supported */
#define A_MAPNSP 8010   /* MAP not supported */
#define A_FMHNSP 8020   /* FMH not supported. */


/* The following abend conditions arise if there are any errors
** in communicating with the Manager process.
*/
#define A_MGPIPE 100      /* could not open pipe to manager */
#define A_MYPIPE 200      /* could make and open return pipe */
#define A_NOMGR  300	  /* Manager not reading input pipe*/
#define A_MYLU   400      /* LU in LU62ATTCH undefined or not enabled */

#define A_RSFAIL 9000   /* lu6.2 manager could not allocate resource*/


/* structure used for holding strings in control blocks */
typedef struct
{
	         char *string;	/* pointer to string */
	unsigned char len;	/* string length     */
} strng;

/* security data structure */
typedef struct
{
	char sec_id;		/* security identification = 
				**	SEC_UID  (user id)
				**	SEC_PSWD (password)
				**	PROFILE  (profile id)
				*/
	int  sec_len;		/* security data length */
	char *sec_dat;		/* security data */
} SEC_DATA;

/* structure passed as paramter to LU62ATTCH function*/
typedef struct
{
	char *name;     /* transaction program name */
	char namelen;   /* transaction program name length */
	char *mgrname;  /* path to the LU6.2 Manager */
	char mgrlen;    /* length of path to the LU6.2 Manager */
	char *luname;   /* local lu name */
	char lunlen;    /* local lu name length */
	char *fqlname;  /* fully qualified lu name */
	char fqllen;    /* fully qualified lu name length */
	char trcon;     /* 1 = turn trace on
			   0 = turn trace off */
	char *trfname;  /* if trace is on, pointer to trace file name 
			   else NULL */
	char trflen;    /* trace file name length */
	char aeflag;	/* 1 = ASCII-to-EBCDIC conversion is necessary
			   for lu, tp and mode names on data
			   transmissions
			   0 = no conversion necessary */
	int (*func) (); /* address to user's abend function or NULL */
} atchstr;
	/* /usr2/53/include/user/cfg62.h: Constants relevant to ipc wiring. */
/* generated by ipcwire. */




#define max_dseg 512

#define max_dru 1024

#define num_pus 4

#define num_lus 256

#define lnk_coun 260

#define num_ses 256

#define num_sss 260

#define num_sta 8

#define num_lin 4

#define num_con 16

#define num_txb 7

#define num_rxb 14

#define MAX_SNA 4

#define MAX_TPCB 80

#define MAX_LUCB 64

#define MAX_RCB 256

#define MAX_ENT 128

#define MAX_SCB 256

#define MAX_SHL 16

#define MAX_SALS 128

#define MAX_ALS 32

#define MAX_PIPS 32

/* + /^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\/^\ + */
/*              Proprietary Information of                          */
/*                Systems Strategies Inc.                           */
/* Copyright (C) as an unpublished work created in 1985, 1986, 1987 */
/*                 All Rights Reserved                              */
/* Unauthorized copying, adaptation, display, use or disclosure     */
/* without the permission of Systems Strategies Inc. is prohibited. */
/* + \./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./ + */

	/* /usr2/53/include/user/cfg62.h ends here. */

/* The following is the type definition for PIP structure that the
** user uses for supplying the PIP parameters on the ALLOCATE verb
** as well as in receiving PIP parameters on the LU62CVCT function
*/

typedef struct 
{
     int pipc; /* When used in Allocate verb, represents actual number 
               ** of pips supplied via the PIP substructure.
               ** When used in LU62CVCT call, represents maximum number
               ** of pips that the pips structure is capable of holding.
               */
	 char trunc;	/* was last pip subfield truncated? */

    struct 
    {
       short piplen; /* actual length of a single pip. Set by user
                     ** for ALLOCATE verb and set by API in
                     ** LU62CVCT call (if remotely attached).
                     */
       char  *pipdatp; /* pointer to actual pip data. Set by user
                       ** for ALLOCATE verb and set by API for
                       ** LU62CVCT call (if remotely attached).
                       */ 
    } pips[MAX_PIPS];

} PIP; 


/*********************************************************************/
/*                                                                   */
/*                                                                   */
/*     lu62lcb.h: Local conversation block. 						 */
/*                                                                   */
/*     WHAT:  Used to store and pass information (to user) related to*/
/*            a conversation verb. User allocates one structure per  */
/*			  conversation.										     */
/*                                                                   */
/*     AUTHOR: Kishore Yerramilli - SYSTEMS STRATEGIES               */
/*                                                                   */
/*     DATE:   DEC 23,1985                                           */
/**********************************************************************/



typedef struct
{
	short lu62cvid;    /* conversation id assigned by lu 6.2
					   ** when conversation is allocated.
					   */
    char  lu62cvst;    /* transaction program conversation state*/
	char  lu62prts;    /* =1 if partner prog. is requesting permission to
					   ** send.
					   */
	short lu62rc1;     /* return code */
    short lu62rc2;     /* return sub-code */
    short lu62wtrc;    /* what has been received on the conversation
                       ** = LU62DATA if data was received
                       ** = LU62IND if indication was recieved
                       */
    union
    {
       short lu62data; /* if lu62what_rcv is set to lu62data, this variable
                      ** will contain information about data.
                      */ 

       short lu62ind; /* if lu62what_rcv is set to lu62ind, this variable wil
                      ** contain information about the indication type.
                      */
    } rcv_typ;

    short mapsiz;      /* received map name size */
    char mapnam[MAXMAPL];   /* received map name */
} lu62lcb;
/*********************************************************************/
/*                                                                   */
/*                                                                   */
/*     lu62wcb.h:  lu62 wait control block      			         */
/*                                                                   */
/*     WHAT:   defines structure used to pass parameters by user pgm */
/*	           execute WAIT verb.								     */
/*                                                                   */
/*     AUTHOR: Kishore Yerramilli - SYSTEMS STRATEGIES               */
/*                                                                   */
/*     DATE:   JAN 7,1986                                            */
/**********************************************************************/


typedef struct
{
	int    w_indx;  /* index of posted conversation in w_lcb
					** (0,1,2,..., MAX_RCB)
					*/
	int	   w_lcbno; /* how may addresses in the following array*/
	lu62lcb *w_lcb[MAX_RCB]; /* array of lcb addresses */
} lu62wcb; 
/* Atribute Control Block used for GET_ATTRIBUTES verb. */

typedef struct
{

	char lcllen;					/* local fq lu length */
    char lcluname[MAXFQLL+1]; 		/* local fully qualified name of this LU */
	char pfllen;					/* partner fq LU length */
    char pfluname[MAXFQLL+1];       /* fully qualified name of partner LU*/
	char plulen;					/* partner local LU length */
    char pluname[MAXLUL+1];  		/* partner local LU name */

	char mdlen;						/* mode name length */
    char mode_name[MAXMODL+1];	    /* The mode name for the session on which
                              		** the conversation was allocated.
                              		*/
    int  sync_lvl;   				/* synchronisation at which conversation
                     				** was allocated.
                     				*/

	char  ulen;				  		/* user id length */	
    char  sec_uid[MAXSECL+1];		/* security user id carried on
									** allocation request
                      				*/
	char  plen;				  		/* profile id length */	
    char sec_pfile[MAXSECL+1]; 		/* security profile carried on
									** allocation req.
                        			*/
	char  luwlen;					/* logical unit of work length */
	char  luw[MAXLUW+1];			/* logical unit of work */
	char  xlen;						/* length of next array */

	char  resrvd[64];				/* extra room */
} lu62acb;
/*********************************************************************/
/*                                                                   */
/*                                                                   */
/*     lu62crb.h: conversation request block definition              */ 
/*                                                                   */
/*     WHAT:  used to pass parameters to the ALLOCATE api verb.      */
/*                                                                   */
/*     AUTHOR: Kishore Yerramilli - SYSTEMS STRATEGIES               */
/*                                                                   */
/*	EDIT HISTORY													 */
/*	----------------------------------------------------------		 */
/*	HHS		02/29/88	Added "#define MALLOC()"					 */
/*                                                                   */
/*     DATE:   DEC 23,1985                                           */
/*********************************************************************/

	/* avoid collisions with "malloc()" */
#define	MALLOC(x,y)	MALLOK(x,y)


typedef struct
{
	strng luname;   /* target lu name */
	short lunmtyp;  /* lu name type = NAME_LC (local)
					**				  NAME_FQ (fully qualified)
					**				  NAME_UI (uninterpreted)
					*/
										
    strng snamode;  /* mode name */
    strng tpn;      /* partner transaction program name */
	char cvtyp;    /* conversation type = CM_BASIC (basic)
				    **					  CM_MAPPD (mapped)
				    */
	short rcntrl;   /* conditon for return to transaction program;
				    ** allowable values = SS_ALLOC (when allocated)
					**					  SS_DELAY (delayed allocation)
					**					  SS_IMMED (immediate return)
				    */

    short syn_lvl;  /* synchronization level = CM_SY0 (none)
					**						   CM_CNFM (sync confirm)
				    */


	char sec_typ;	/* security type = SEC_NONE (no security)
					** 				   SEC_SAME (same as remote program)
					**				   SEC_PGM  (supplied by user)
					*/

    SEC_DATA *security[3]; /* pointers to structs of type SEC_DATA or NULL	*/
    PIP			  *pipdat; /* pointer to PIP structure or NULL				*/
} lu62crb;

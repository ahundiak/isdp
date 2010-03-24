
#define MAXMSGS 100000
#define MAXOBJS 100000

#define STA 'A'
#define STB 'B'
#define STC 'C'
#define STD 'D'

#define	STAIDX	0
#define	STBIDX	1
#define	STCIDX	2
#define	STDIDX	3

#define STASIZE 16
#define STBSIZE 128
#define STCSIZE 1024
#define STDSIZE 4096

#define DOIT        0
#define CONSTRUCT   1
#define DELETE      2

struct msgProf
{
  int             cmd;
  union
  {
    char          cls;
    struct msg
    {
      int         objIdx;
      int         varyAmt;
    } m;
  } u1;
};
typedef struct msgProf MsgProf;


extern	int ST_f_verbose;
extern	int ST_f_Verbose;
extern	int ST_Gi_netNeg;
extern	int ST_Gi_netPos;
extern  int ST_f_verbErr;
extern  int ST_i_varyAmt;
extern  int ST_f_showWrStats;
extern  int ST_f_readOnly;
extern  int ST_f_noMod;
extern  int ST_f_debug;
extern	int ST_f_measureMsg;
extern	int ST_f_doRandom;
extern  char  *ST_profile;
extern  char  *ST_osname;
extern  char  *ST_osclass;

extern  void  memmap ();
extern  void  pverify ();
extern  void  fverify ();
extern	void  chkBlkAdr ();

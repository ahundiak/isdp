/* @(#)skybolt.h       0.1 */
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ++
+                                                                            +
+    Copyright (c) 1989 Sky Computer Incorporated                            +
+                                                                            +
+    This file contains information proprietary to Sky Computer Inc.         +
+    This software is supplied under terms of a license or non-disclosure    +
+    agreement and should be treated as confidential in accordance with      +
+    this agreement.                                                         +
+                                                                            +
++ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

#ifndef SKYBOLT_H
#define SKYBOLT_H

/*
 * The Bolt Table Structure
 *	(built by boltattach)
 */

#define NAME_LEN	20	/* max length of bolt name */
#define MAXBOLT		4	/* maximum number of open bolt's */

#include "boltregs.h"		/* bolt register defines */



/* 
 * Bolt Message Window Defines
 */

#define MESSAGE_WINDOW_OFFSET	0x6000	/* location of message window */
			/*0x6000 bytes from the start of Bolt memory */

#define BOLT_IDENT_NUMBER	0x092681

#define BOLT_IS_IDLE		0x0
#define BOLT_IS_DONE		0x1
#define BOLT_IS_WORKING		0x2

/* i860 interrupt types */
#define NO_INTERRUPTS	0	
#define INTERRUPT_DONE	0	
#define INTERRUPT_ON	1	

#define SET_I860_WIERDO_INT	0x00000001 /* i860 interrupt, cause unknown */
#define HOST_TO_I960_INT	0x00000002
#define I960_TO_HOST_INT	0x00000004
#define SET_I860_SSTEP_INT	0x00000020
#define SET_I860_SYSCALL_INT	0x00000040
#define SET_I860_BREAK_INT	0x00000080
#define SET_I860_ITRAP_INT	0x00000100
#define SET_I860_EXTERN_INT	0x00000200
#define SET_I860_IATRAP_INT	0x00000400
#define SET_I860_DATRAP_INT	0x00000800
#define SET_I860_FPTRAP_INT	0x00001000
#define SET_I860_UNIMPL_SYSCALL 0x00002000
#define SET_BOLTERR		0x00004000
#define I960_SYS_CALL		0x00008000

#define CLR_I860_WIERDO_INT	~SET_I860_WIERDO_INT
#define CLR_I860_ITRAP_INT	~SET_I860_ITRAP_INT
#define CLR_I860_EXTERN_INT	~SET_I860_EXTERN_INT
#define CLR_I860_IATRAP_INT	~SET_I860_IATRAP_INT
#define CLR_I860_DATRAP_INT	~SET_I860_DATRAP_INT
#define CLR_I860_FPTRAP_INT	~SET_I860_FPTRAP_INT

/* i960 interrupt types */
#define SET_I960_INT		0x00000001 /* generic i960 interrupt */
#define CLR_I960_INT		~SET_I960_INT

#define SET_I960_DMA_INT	0x00008000 /*generic i960 SYS call */

/* host interrupt types (stuff written to mailbox) */
#define HOST_TO_BOLT_INTERRUPT	0x00000001 /* generic "2-bolt" int */
#define SET_HOST_WANTS_GO  	0x00000002 /* host tells bolt to go */
#define HOST_WANTS_INTERRUPTS	0x00000004 /* enable  host interrupts */
#define NO_HOST_INTERRUPTS	0x00000008 /* disable host interrupts */
#define HOST_CALL_COMPLETE	0x00000010 /* host is done (with sys_call) */

/* host-to-bolt interrupt types */
#define SET_HOST_WANTS_STOP  	0x00000001 /* host tells bolt to stop */
#define SET_HOST_WANTS_GO  	0x00000002 /* host tells bolt to go */
#define SET_HOST_WANTS_BREAK	0x00000020 /* host abort signal given */
#define SET_BOLT_SIGNAL         0x00000040 /* host/960 raises signal on bolt */
#define SET_I960_SIGNAL         0x00000080 /* host     raises signal on i960 */

/* Bit in iopcsr indicating request from 860 */
#define IOP_REQUEST_PENDING	0x00000008 /* request from the IOP to host */

#define FIRST_VERSION		0x33534001 /* id associated with 1st release */
#define CFG_REG_VERSION		0x8199     /* id associated with cfg_reg */

#define SYS_CALL_INT		1
#define WIERD_IT_INT		2
#define WIERD_IN_INT		2



/*
 * Supplemental DAT (data access trap) Codes
 */

#define OKAY            1
#define NOT_ALIGNMENT   1
#define NOT_PROTECTED   1
#define ALIGNMENT       2
#define PROTECTED       4
#define UNKNOWN_DAT     8
#define NOT_LDST_INST   16
#define INVALIDPAGE     32
#define UNWRITABLE      64

/*
 *  Environmental Variable Defines
 */

#define BOLTnoload	 0x00000001L	/* don't load ucode */
#define BOLTnorun	 0x00000002L	/* don't execute the program */
#define BOLTnocache	 0x00000004L	/* disable internal cache */
#define BOLTnoecache	 0x00000008L	/* disable external cache */
#define BOLTverbose	 0x00000010L	/* be verbose */
#define BOLTminimum	 0x00000020L	/* minimal support (for vtx & diags) */
#define BOLTwarIII 	 0x00000040L	/* Warrior III environment */
#define BOLTfull_load 	 0x00000080L	/* force full load */
#define BOLTzeromem 	 0x00000100L	/* zero eap and malloc'd memory */
#define BOLTrpterrs 	 0x00000200L	/* report mem/par/bus errs */

#define BOLT_FATAL_ERROR 0x80000000L	/* make errors fatal */
/*
 *  file type defines
 */

#define I960_MONITOR		1
#define I860_KERNEL		2
#define I860_APPLICATION	3

/*
 *  Arithmetic exception handling modes
 */

#define AREX_UNSET  -1
#define AREX_IGNORE  0
#define AREX_FATAL   1
#define AREX_REPORT  2

/*
 *  Stepping mode (for window's continue_mode entry)
 */

#define SINGLE_STEP_I860	1
#define CONTINUE_I860		2

/*
 * Default i860 kernel and i960 monitor files.
 */

#define DEFAULT860FILE	"/usr/sky/bolt/bin/kernel"
#ifdef SKYSTATION
#define DEFAULT960FILE  "/usr/sky/bolt/bin/statmon"
#else
#define DEFAULT960FILE  "/usr/sky/bolt/bin/monitor"
#endif

/*
 * Polling vs. Interrupting Defines
 */

#define NEVER_POLL              0
#define ALWAYS_POLL             -1
#define DEFAULT_POLL_TIME       100

#define POLL_ONLY       1
#define NO_POLLING      2
#define MIXED           4
#define TIMEOUT         8
#define DISABLE_INTS    1
#define ENABLE_INTS     2

/* defines for basic type of bolt */
#define	_9U_BASE		0
#define _6U_BASE		1
#define INTER_BASE	2
#define STAT_BASE	3

/* defines for AP config reg */
#define NO_PROCESSOR	0
#define i860_DRAM	1
#define i860_SRAM	2

/* defines for AP card speeds */
#define _33MHZ		0
#define _40MHZ		1

/* defines for AP card types */
#define _SRAM		0
#define _DRAM		1


/* defines in dbsky and skybolt */
#define VMEBERRI   0x04000000		/* IOP master VME slave bus er*/
#define ROMWERR    0x08000000		/* write to ROM error */
#define MEMERRI    0x10000000		/* memory address out of range*/
#define PECERR     0x20000000		/* parity */
#define EXPERR     0x40000000		/* expansion bus error */
#define VSBERRI    0x80000000		/* VSB bus error */
#define EXTINTERRI 0x1			/* unexpected external interrupt */

#define	ulong	unsigned long

#define NUMBER_OF_SIGNALS  32

#define CLEAR_EXT_SIG_TYPE	0
#define FROM_960		1
#define FROM_HOST		2
#define FROM_860		4

typedef struct sky_syscall {    /* size = 0xb0 */
    long interrupt_status;      /* interrupt completion status */
    long interrupt_type;        /* interrupt type code */
    long sys_call_number;       /* system call number */
    long sys_call_errno;        /* copy of host's errno variable */
    long sys_call_parms[20];    /* arguments for system calls kept here */
    long sys_call_ret_val[2];   /* return val for system calls put here */
    long event_flags[16];       /* event flags for sync/misc use */
    long message[2];            /* miscellaneous entries */
    } SKY_SYSCALL;

typedef struct sky_signal {                    /* size = 0x290 */
    int          signal_keeper;                /* has signal been raised? */
    int          signal_mask;                  /* has signal been masked? */
    struct {                                   /* one per signal type */
        int      (*func_ptr)();                /* address of handler */
        int      sig;                          /* arg #1 for handler */
        int      code;                         /* arg #2 for handler */
        regs_t   *scp;                         /* arg #3 for handler */
        char     *addr;                        /* arg #4 for handler */
        }        sig_table[NUMBER_OF_SIGNALS];
    int          signal_count;                 /* count of # of raised sigs */
    int          signal_mcount;                /* count of # of masked sigs */
    } SKY_SIGNAL; 

typedef struct sky_itimer {     /* size = 0x40 */
    ulong itime_active;         /* active interval timers */
    ulong tic_interval;         /* # tics before 960 interrupt */
    ulong tic_load_val;         /* val to be put to timer counter */
    ulong itime_alarm[4];       /* # tics for alarm */
    ulong itime_interval[4];    /* # tics for interval */
    ulong itime_counter[4];     /* current # tics per itimer */
    ulong itime_signal;         /* count of signals to i860 */
    } SKY_ITIMER;

struct bolt_table {
    long id;			/* fd/chan of bolt */
    struct bolt_device *regs;	/* bolt registers */
    struct bolt_message_window *window;	/* pointer to message window */
    char *boltstart;		/* start of bolt memory */
    char *boltend;		/* end of bolt memory */
    char name[NAME_LEN];        /* bolt name */
    long prom_id;		/* prom id number */
    long type;			/* Type (6U/9U) of board */
    long procs;			/* Number of i860 on board */
    long speed;			/* Speed of procs (33/40MHz) */
    long sram_dram;		/* Tyep of procs (SRAM/DRAM) */
    long has_ecache;		/* If the board has an external cache */
    long int_support;		/* Whether interrupts are supported */
    long has_960_sram;		/* If 960 has private SRAM */
    long has_cache_freeze;	/* If board has cache-freeze support */
    long has_holdholda;		/* If has HOLD/HOLDA fix for parity */
    long has_vsb_slave;         /* Has support for VSB slave */
    long has_vme_master;        /* Has master VME support */
    long has_vsb_master;        /* Has master VSB support */
    long has_vme_block;		/* Has support for VME block moves */
    long has_vsb_block;		/* Has support for VSB block moves */
    long has_parity;            /* Has support for parity */
    long has_mp_support;	/* If has support for MP */
    long maxmem;		/* Maximum amount of memory on board */
    char release_string[80];	/* String found in id prom */
    long cfg_reg;               /* faked or real contents of config reg */
#ifdef MP
    int  mpcnt;                 /* number of active processors */
    char *mp[4];                /* memory start per platform */
    int mpsize[4];              /* memory size per platform */
#endif
};


/* 
 * The Bolt Message Window Structure
 * 	(kept at location XXXXX in Bolt memory).
 */

struct bolt_message_window {
    long timer_high;		/* (0x0) bits 63..32 of timer counter */
    long timer_low;		/* (0x4) bits 31.. 0 of timer counter */
    long load_flag;		/* (0x8) bolt re-load indicator */
    long host_sp_signal;	/* (0xc) marks src of int as host or i960 */
    SKY_SYSCALL i860_call;      /* (0x10)  stuff for i860-gen'd sys calls */
    SKY_SYSCALL i960_call;      /* (0xc0)  stuff for i960-gen'd sys calls */
    SKY_SYSCALL host_call;      /* (0x170) stuff for host-gen'd sys calls */
    SKY_ITIMER skyitimer;       /* (0x220) sky interval timer structure */
    SKY_SIGNAL skysig;          /* (0x260) sky signal handler structure */
    long AE_mode;		/* (0x4f0) excep mode:0=ignore,1=fatal,2=rpt */
    float etime[2];	        /* (0x4f4) holds elapsed time */
    long pad1[1];               /* (0x4fc) filler */
    /* 
     * See boltregs.h for description of next entry.  It is a big 
     * and complicated description of the i860 register save area. 
     * The "regs_t" entry MUST start on a quad boundary.
     */
    regs_t i860_regs;           /* (0x500) holds image of regs (size=0x190) */
    };                          /* size = 0x690 */


#ifndef SKYSTATION
#define ERR_NAME	"BOLT"	/* device name used when printing errors */
#define BASE_DEV_NAME	"/dev/bolt"	/* base for device name */
/*
 * The Bolt Registers Structure
 */

#ifndef SRX
struct bolt_device {
        unsigned long   host_csr_reg;   /* 00 (r/w) host ctl/sts reg (4) */
        unsigned long   iop_csr_reg;    /* 04 (r/w) i960 ctl/sts reg (32) */
        unsigned long   timer_counter;  /* 08 (r/w) timer counter (32) */
        unsigned long   timer_rd_clr;   /* 0c (r)   timer read and clear (32) */        unsigned long   cmd_counter;    /* 10 (r/w) command counter (8) */
        unsigned long   cmd_cnt_inc;    /* 14 (w)   cmd cntr increment (8) */
        unsigned long   cmd_cnt_dec;    /* 18 (w)   cmd cntr decrement (8) */
        unsigned long   blk_xfer_cnt;   /* 1c (r/w) block transfer count (8) */
        unsigned long   pad1[1];        /* 20 (r/w) hole filler (32) */
        unsigned long   mailbox1;       /* 24 (r/w) mailbox (16) */
        unsigned long   ap_csr1;        /* 28 (r/w) AP csr (for MP only) */
        unsigned long   ap_csr2;        /* 2c (r/w) AP csr (for MP only) */
        unsigned long   pad2[1];        /* 30       hole filler (32) */
        unsigned long   ram_addr_reg;   /* 34 (r/w) RAM address register (32) */        unsigned long   pad3a[1];       /* 38       hole filler (32) */
        unsigned long   cfg_reg;        /* 3c (w)   configuration reg (4) */
        unsigned long   pad3b[1];       /* 40       hole filler (32) */
        unsigned long   vme_membase;    /* 44 (r/w) VME mem base addr reg (8) */        unsigned long   vme_ivec_reg;   /* 48 (r/w) VME int vector reg (8) */
        unsigned long   vme_csr_reg;    /* 4c (r/w) VME ctl/sts reg (16/8) */
        unsigned long   vme_int_iop;    /* 50 (w)   VME int i/o proc (1) */
        unsigned long   vme_read_reg;   /* 54 (r)   VME read data reg (32) */
        unsigned long   vme_csr_reg2;   /* 58 (r/w) VME ctl/sts reg (8) */
        unsigned long   pad4[1];        /* 5c       hole filler (64) */
        unsigned long   vsb_iobase;     /* 60 (r/w) VSB i/o base addr reg (8) */        unsigned long   vsb_membase;    /* 64 (r/w) VSB mem base addr reg (8) */        unsigned long   vsb_ivec_reg;   /* 68 (r/w) VSB int vector reg (8) */
        unsigned long   vsb_csr_reg;    /* 6c (r/w) VSB ctl/sts reg (16/8) */
        unsigned long   pad5[1];        /* 70       hole filler (32) */
        unsigned long   vsb_read_reg;   /* 74 (r)   VSB read data reg (32) */
        unsigned long   vsb_csr_reg2;   /* 78 (r/w) VSB ctl/sts reg pt 2 (8) */
        } ;
 
#else
struct bolt_device {
	unsigned long	host_csr_reg;	/* 00 (r/w) host ctl/sts reg (4) */
	unsigned long	iop_csr_reg;	/* 04 (r/w) i960 ctl/sts reg (32) */
	unsigned long	timer_counter;	/* 08 (r/w) timer counter (32) */
	unsigned long	timer_rd_clr;	/* 0c (r)   timer read and clear (32) */
	unsigned long	cmd_counter;	/* 10 (r/w) command counter (8) */
	unsigned long	cmd_cnt_inc;	/* 14 (w)   cmd cntr increment (8) */
	unsigned long	cmd_cnt_dec;	/* 18 (w)   cmd cntr decrement (8) */
	unsigned long	blk_xfer_cnt;	/* 1c (r/w) block transfer count (8) */
	unsigned long	pad1[1];	/* 20 (r/w) hole filler (32) */
	unsigned long 	mailbox1;	/* 24 (r/w) mailbox (16) */
	unsigned long 	ap_csr1;	/* 28 (r/w) AP csr (for MP only) */
	unsigned long 	ap_csr2;	/* 2c (r/w) AP csr (for MP only) */
        unsigned long   pad2[1];	/* 30       hole filler (32) */
	unsigned long	ram_addr_reg;	/* 34 (r/w) RAM address register (32) */
        unsigned long   pad3a[1];	/* 38       hole filler (32) */
        unsigned long   cfg_reg;	/* 3c (w)   configuration reg (4) */
/**/    unsigned long   srxbadd;	/* 40       SRX mem base addr */
/**/	unsigned long	srxcntl;	/* 44 (r/w) SRX csr */ 
/**/	unsigned long	vme_ivec_reg;	/* 48 (r/w) SRX tag reg */
	unsigned long	vme_csr_reg;	/* 4c (r/w) SRX int reg */
	unsigned long   vme_int_iop;	/* 50 (w)   SRX select reg */
	unsigned long   vme_read_reg;	/* 54 (r)   VME read data reg (32) */
	unsigned long	srxpoll;	/* 58 (r/w) VME ctl/sts reg (8) */
        unsigned long   pad4[1];	/* 5c       hole filler (64) */
	unsigned long   vsb_iobase;	/* 60 (r/w) VSB i/o base addr reg (8) */
	unsigned long   vsb_membase;	/* 64 (r/w) VSB mem base addr reg (8) */
	unsigned long	vsb_ivec_reg;	/* 68 (r/w) VSB int vector reg (8) */
	unsigned long	vsb_csr_reg;	/* 6c (r/w) VSB ctl/sts reg (16/8) */
	unsigned long	pad5[1];	/* 70       hole filler (32) */
/**/	unsigned long   srx_read_reg;	/* 74 (r)   SRX read data reg (32) */
	} ;
#endif /* done with the SRX case */
#else
#define ERR_NAME	"STAT"	/* device name used when printing errors */
#define BASE_DEV_NAME	"/dev/sk"	/* base for device name */


/*
 * The Bolt Registers Structure
 */

struct bolt_device {
	unsigned long	host_csr_reg;	/* 00 (r/w) host ctl/sts reg (8) */
	unsigned long	iop_csr_reg;	/* 04 (r/w) i960 ctl/sts reg (32) */
	unsigned long	timer_counter;	/* 08 (r/w) timer counter (32) */
	unsigned long	timer_rd_clr;	/* 0c (r)   timer read and clear (32) */
	unsigned long	cmd_counter;	/* 10 (r/w) command counter (8) */
	unsigned long	cmd_cnt_inc;	/* 14 (w)   cmd cntr increment (8) */
	unsigned long	cmd_cnt_dec;	/* 18 (w)   cmd cntr decrement (8) */
	unsigned long	blk_xfer_cnt;	/* 1c (r/w) block transfer count (8) */
	unsigned long	pad1[1];	/* 20       hole filler (32) */
	unsigned long	mailbox1;	/* 24 (r/w) mailbox (16) */
        unsigned long   pad2[3];	/* 28..30   hole filler (96) */
	unsigned long	ram_addr_reg;	/* 34 (r/w) RAM address register (32) */
	unsigned long	pad3[2];	/* 38..40  hole filler (32) */
	unsigned long   scsi_ctl_reg;	/* 40 (r)   SCSI Config. register (8) */
	} ;

struct skyscsi_device {
	unsigned char	scsi_ctl0_reg;	/* 00 (r/w) SCSI Control reg 0 */
	unsigned char	scsi_ctl1_reg;	/* 01 (r/w) SCSI Control reg 1 */
	unsigned char	scsi_did_reg;	/* 02 (r/w) SCSI Destination ID reg */
	unsigned char	scsi_ien_reg;	/* 03 (r/w) SCSI Interrupt Enable reg */
	unsigned char	scsi_cid_reg;	/* 04 (r/w) SCSI Chip ID reg */
	unsigned char	scsi_xfer_reg;	/* 05 (r/w) SCSI Transfer reg */
	unsigned char	scsi_odl_reg;	/* 06 (r/w) SCSI Output Data Latch reg */
	unsigned char	scsi_ocl_reg;	/* 07 (r/w) SCSI Output Control Latch reg */
	unsigned char	scsi_fbr_reg;	/* 08 (r)   SCSI First Byte Received reg */
	unsigned char	scsi_idl_reg;	/* 09 (r)   SCSI Input Data Latch reg */
	unsigned char	scsi_bdl_reg;	/* 0a (r)   SCSI Bus Data Latch reg */
	unsigned char	scsi_bcl_reg;	/* 0b (r)   SCSI Bus Control Lines reg */
	unsigned char	scsi_dstat_reg;	/* 0c (r)   DMA Status reg */
	unsigned char	scsi_stat0_reg;	/* 0d (r)   SCSI Status reg 0 */
	unsigned char	scsi_stat1_reg;	/* 0e (r)   SCSI Status reg 1 */
	unsigned char	scsi_stat2_reg;	/* 0f (r)   SCSI Status reg 2 */
	unsigned char	pad1[4];	/* 10..13   reserved */
	unsigned char	scsi_ctst0_reg;	/* 14 (r)   Chip Test reg 0 */
	unsigned char	scsi_ctst1_reg;	/* 15 (r)   Chip Test reg 1 */
	unsigned char	scsi_ctst2_reg;	/* 16 (r)   Chip Test reg 2 */
	unsigned char	scsi_ctst3_reg;	/* 17 (r)   Chip Test reg 3 */
	unsigned char	scsi_ctst4_reg;	/* 18 (r/w) Chip Test reg 4 */
	unsigned char	scsi_ctst5_reg;	/* 19 (r/w) Chip Test reg 5 */
	unsigned char	scsi_ctst6_reg;	/* 1a (r/w) Chip Test reg 6 */
	unsigned char	scsi_ctst7_reg;	/* 1b (r/w) Chip Test reg 7 */
	unsigned long   temp;		/* 1c..1f (r/w) temp stack reg */
	unsigned char	scsi_dfifo_reg;	/* 20 (r/w) DMA FOFO reg */
	unsigned char	scsi_istat_reg;	/* 21 (r/w) Interrupt Status reg */
	unsigned char	pad2[2];	/* 22..23   reserved */
	unsigned char	dmabyte[3];	/* 24..26 (r/w) DMA Byte Count reg */
	unsigned char	scsi_dcmd_reg;	/* 27 (r/w) DMA Command reg */
	unsigned long	dnad;		/* 28..2b (r/w) DMA Next Address for Data reg */
	unsigned long	dsp;		/* 2c..2f (r/w) DMA Scripts Pointer reg */
	unsigned long	dsps;		/* 30..33 (r/w) DMA Scripts Pointer Save reg */
	unsigned char	scsi_dmode_reg;	/* 34 (r/w) DMA Mode reg */
	unsigned char	pad3[4];	/* 35..38   reserved */
	unsigned char	scsi_dien_reg;	/* 39 (r/w) DMA Interrupt Enable reg */
	unsigned char	scsi_dwt_reg;	/* 3a (r/w) DMA watchdog Timer reg */
	unsigned char	scsi_dctl_reg;	/* 3b (r/w) DMA Control reg */
	unsigned char	pad4[4];	/* 3c..3f   reserved */
	} ;

extern unsigned long boltregbase;
extern unsigned long scsiregbase;
extern unsigned long membase;

#define READ_REG(reg,val)	pkt=get_pktiopb(ROUTE,(caddr_t *)&tmp_hold,CDB_GROUP1,1,sizeof(struct hold),B_READ,NULL_FUNC); \
				MAKECOM_G1(pkt,devp,FLAG_NOINTR,0x3c,(int)reg,1); \
				scsi_poll(pkt); \
				free_pktiopb(pkt,(caddr_t)tmp_hold,sizeof(struct hold)); \
				val = tmp_hold->temp;

#define WRITE_REG(reg,val)	tmp_hold->temp = val; \
				pkt=get_pktiopb(ROUTE,(caddr_t *)&tmp_hold,CDB_GROUP1,1,sizeof(struct hold),B_WRITE,NULL_FUNC); \
				MAKECOM_G1(pkt,devp,FLAG_NOINTR,0x3b,(int)reg,1); \
				scsi_poll(pkt); \
				free_pktiopb(pkt,(caddr_t)tmp_hold,sizeof(struct hold));

#endif

/*
 * Some Global Variables
 */

#define bolt_noshare
extern struct bolt_device bolt_noshare *bolt_regs;
extern struct bolt_table bolt_noshare *curbolt;
extern struct bolt_device bolt_noshare boltregs_;
extern struct bolt_table bolt_noshare bolt_[MAXBOLT];

#endif


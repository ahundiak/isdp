/* @(#)boltregs.h       0.1 */
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

#ifndef BOLTREGS_H
#define BOLTREGS_H

/*
 * The Bolt Register Defines
 */

/*
 * Host control register bits (r/w)
 */

#define HOST_TOTAL_RESET	0x00000001	/* reset the entire board */
#define HOST_I960_RESET		0x00000002	/* reset the i960 */
#define HOST_MAP_PROM 		0x00000004	/* map prom to ibus ram space */
#define HOST_IOP_ERROR		0x00000008	/* IOP self-test error */
#define HOST_ENDIAN		0x00000010	/* mask for endian bit */

#define HOST_CLEAR_ALL		0x00000010	/* reset that saves endian */

#define HOST_LOW_MASK		0x0000000f	/* reset that saves endian */

#define HOST_TOTAL_UNRESET	~HOST_TOTAL_RESET

/*
 * IOP (i960) control register bits (r/w)
 */

#define IOP_GO     	0x00000001	/* tell i860 to go */ 
#define IOP_ICACHE_DIS	0x00000002	/* i860 internal cache disable */ 
#define IOP_ECACHE_DIS  0x00000004	/* i860 external cache disable */ 
#define IOP_FRC_PERR	0x00000008	/* force parity error */
#define IOP_MAP_TAG_RAM	0x00000010	/* map cache tag ram direct to i860 */
#define IOP_ERRINT_ENA	0x00000020      /* allow error interrupts */
#define IOP_TIMEINT_ENA 0x00000080      /* allow timer overflow interrupt */
#define IOP_VSBINT_ENA	0x00000100      /* allow VSB interrupts */
#define IOP_VMEINT_ENA	0x00000200      /* allow VME interrupts */
#define IOP_EXPINT_ENA	0x00000400      /* allow expansion (other) interrupts */
#define IOP_APINT_ENA	0x00000800      /* allow AP (i860) interrupts */
#define IOP_TIMER_ENA	0x00001000      /* allow timer overflow interrupt */
#define IOP_BLKINT_ENA	0x00002000      /* allow block mode interrupts */
#define IOP_MBXINT_ENA	0x00004000      /* allow mailbox interrupts */
#define IOP_LED1	0x00008000      /* turn on LED 1 */
#define IOP_LED2	0x00010000      /* turn on LED 2 */
#define IOP_LED3	0x00020000      /* turn on LED 3 */
#define BLU_LED_ON      0x00010000      /* turn on BLUE LED */
#define BLU_LED_OFF     0x00000000      /* turn off BLUE LED */
#define IOP_INT_I860	0x00040000      /* interrupt to i860 */
#define IOP_I860_INT	0x00080000      /* interrupt from i860 */
#define IOP_TIME_INT	0x00100000      /* timer interrupt */
#define IOP_MBX_INT	0x00200000      /* mailbox interrupt */
#define IOP_BLKCNT_0	0x00400000      /* block count equal zero */
#define IOP_VME_INT     0x00800000      /* VME interrupt */
#define IOP_EXP_INT     0x01000000      /* expansion interrupt */
#define IOP_VSB_INT     0x02000000      /* VSB interrupt */
#define IOP_VME_BUSERR	0x04000000      /* VME bus error */
#define IOP_ROM_WRERR	0x08000000      /* i960 writes to PROM address */
#define IOP_MEMERR	0x10000000      /* i960/i860 addressing error */
#define IOP_PARERR	0x20000000      /* i960/i860 addressing error */
#define IOP_EXP_BUSERR	0x40000000      /* expansion bus error */
#define IOP_VSB_BUSERR	0x80000000      /* VSB bus error */

#define IOP_CLEAR_ALL  	0x00000000	/* clear this register completely */
#define IOP_RESET	~IOP_GO		/* reset the i860 */ 
#define IOP_CONFIG_BITS	0x00000026
/*
 * what to look at to check for a 'live' board 
 */

#define IOP_EXISTS_MSK	0x7fff
#define IOP_EXISTS	0		/* On bus reset, low-15 of IOPCSR
					   should be 0 */

#ifdef MP
/* AP_CSR1 defines */
#define RESAP0		0x1
#define RESAP1		0x2
#define RESAP2		0x4
#define RESAP3		0x8
#define RESAP4		0x10
#define RESAP5		0x20
#define RESAP6		0x40
#define RESAP7		0x80
#define APIEN0		0x100
#define APIEN1		0x200
#define APIEN2		0x400
#define APIEN3		0x800
#define APIEN4		0x1000
#define APIEN5		0x2000
#define APIEN6		0x4000
#define APIEN7		0x8000
#define IKEN0		0x10000
#define IKEN1		0x20000
#define IKEN2		0x40000
#define IKEN3		0x80000
#define IKEN4		0x100000
#define IKEN5		0x200000
#define IKEN6		0x400000
#define IKEN7		0x800000
#define EKEN0		0x1000000
#define EKEN1		0x2000000
#define EKEN2		0x4000000
#define EKEN3		0x8000000
#define EKEN4		0x10000000
#define EKEN5		0x20000000
#define EKEN6		0x40000000
#define EKEN7		0x80000000
#define RESAP_MASK	~(RESAP0|RESAP1|RESAP2|RESAP3| \
				RESAP4|RESAP5|RESAP6|RESAP7)
#define GO_MASK		(RESAP0|RESAP1|RESAP2|RESAP3| \
				RESAP4|RESAP5|RESAP6|RESAP7)
/* AP_CSR2 defines */
#define APINT0          0x1
#define APINT1          0x2
#define APINT2          0x4
#define APINT3          0x8
#define APINT4          0x10
#define APINT5          0x20
#define APINT6          0x40
#define APINT7          0x80
#define INTAP0          0x100
#define INTAP1          0x200
#define INTAP2          0x400
#define INTAP3          0x800
#define INTAP4          0x1000
#define INTAP5          0x2000
#define INTAP6          0x4000
#define INTAP7          0x8000
#define MEMERR0           0x10000
#define MEMERR1           0x20000
#define MEMERR2           0x40000
#define MEMERR3           0x80000
#define MEMERR4           0x100000
#define MEMERR5           0x200000
#define MEMERR6           0x400000
#define MEMERR7           0x800000
#define PECERR0           0x1000000
#define PECERR1           0x2000000
#define PECERR2           0x4000000
#define PECERR3           0x8000000
#define PECERR4           0x10000000
#define PECERR5           0x20000000
#define PECERR6           0x40000000
#define PECERR7           0x80000000

#endif

#ifdef MP
#define IOP_CSR_RESET(a)	((a)->ap_csr1 &= ~RESAP0)
#define IOP_CSR_GO(a)		((a)->ap_csr1 |=  RESAP0)
#define LOAD_BOLT		load_bolt
#define UNLOAD_BOLT		unload_bolt
#define SET_MISC_960_ADDRS      set_misc_960_addrs

#ifdef INTERGRAPH
#define READ_I860_REGISTER(ptr,value_ptr) *(value_ptr) = ptr
#define HOST_SET_REG(ptr,value)  ptr = value
#define HOST_AND_REG(ptr,value)  ptr &= value
#define HOST_OR_REG(ptr,value)  ptr |= value
#define HOST_WRT_MBOX(ptr,value) { ptr |= value; \
                                   while (ptr & value); \
                                 }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) *(ptr) = *(value_ptr)
#define READ_BOLT_MEM(value_ptr,ptr,size) *(value_ptr) = *(ptr)
#define WRITE_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define READ_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define BOLTREAD(fd,buf,siz,type) NREAD(fd,buf,siz)
#define BOLTWRITE(fd,buf,siz) NWRITE(fd,buf,siz)
#endif  /* INTERGRAPH */


#else /* not MP */
#define IOP_CSR_RESET(a)	((a)->iop_csr_reg &= IOP_RESET)
#define IOP_CSR_GO(a)		((a)->iop_csr_reg |= IOP_RESET)

#ifdef sony
#define READ_I860_REGISTER(ptr,value_ptr) { sony_reg_space(curbolt->id); \
					    *(value_ptr) = ptr; \
					    sony_mem_space(curbolt->id); }
#define HOST_SET_REG(ptr,value)  { sony_reg_space(curbolt->id); \
				   ptr = value; \
				   sony_mem_space(curbolt->id); }
#define HOST_AND_REG(ptr,value)  { sony_reg_space(curbolt->id); \
				   ptr &= value; \
				   sony_mem_space(curbolt->id); }
#define HOST_OR_REG(ptr,value)  { sony_reg_space(curbolt->id); \
				   ptr |= value; \
				   sony_mem_space(curbolt->id); }
#define HOST_WRT_MBOX(ptr,value) { sony_reg_space(curbolt->id); \
				   ptr |= value; \
				   while (ptr & value); \
				   sony_mem_space(curbolt->id); }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) *(ptr) = *(value_ptr)
#define READ_BOLT_MEM(value_ptr,ptr,size) *(value_ptr) = *(ptr)
#define WRITE_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define READ_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define BOLTREAD(fd,buf,siz,type) read(fd,buf,siz)
#define BOLTWRITE(fd,buf,siz) write(fd,buf,siz)
#endif	/* sony */
#ifdef SKYSTATION	/* Sun SKYSTATION */
#define READ_I860_REGISTER(ptr,value_ptr)  reg_read(curbolt->id,value_ptr,&ptr)
#define HOST_SET_REG(ptr,value)  { int tmp = value; \
				   reg_write(curbolt->id,&tmp,&ptr); \
				 }
#define HOST_AND_REG(ptr,value)  { int tmp; \
				   reg_read(curbolt->id,&tmp,&ptr); \
				   tmp &= value; \
				   reg_write(curbolt->id,&tmp,&ptr); \
				 }
#define HOST_OR_REG(ptr,value)   { int tmp; \
				   reg_read(curbolt->id,&tmp,&ptr); \
				   tmp |= value; \
				   reg_write(curbolt->id,&tmp,&ptr); \
				 }
#define HOST_WRT_MBOX(ptr,value) { int tmp = value; \
				   reg_write(curbolt->id,&tmp,&ptr); \
				   do \
				       reg_read(curbolt->id,&tmp,&ptr); \
				   while (tmp & value); \
				 }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) mem_write(curbolt->id,value_ptr,ptr,size)
#define READ_BOLT_MEM(value_ptr,ptr,size) mem_read(curbolt->id,value_ptr,ptr,size)
#define WRITE_BOLT_MEMBLOCK(value_ptr,ptr,size) mem_write(curbolt->id,value_ptr,ptr,size)
#define READ_BOLT_MEMBLOCK(value_ptr,ptr,size) mem_read(curbolt->id,ptr,value_ptr,size)
#define BOLTREAD(fd,buf,siz,type) boltread(fd,buf,siz,type)
#define BOLTWRITE(fd,buf,siz) boltwrite(fd,buf,siz)
#endif	/* SKYSTATION */

#ifdef sun_mmap
#define READ_I860_REGISTER(ptr,value_ptr) *(value_ptr) = ptr
#define HOST_SET_REG(ptr,value)  ptr = value
#define HOST_AND_REG(ptr,value)  ptr &= value
#define HOST_OR_REG(ptr,value)  ptr |= value
#define HOST_WRT_MBOX(ptr,value) { ptr |= value; \
				   while (ptr & value); \
				 }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) *(ptr) = *(value_ptr)
#define READ_BOLT_MEM(value_ptr,ptr,size) *(value_ptr) = *(ptr)
#define WRITE_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define READ_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define BOLTREAD(fd,buf,siz,type) read(fd,buf,siz)
#define BOLTWRITE(fd,buf,siz) write(fd,buf,siz)
#endif	/* sun_mmap */

#ifdef VXWORKS
#define read fioRead
#define READ_I860_REGISTER(ptr,value_ptr) *(value_ptr) = ptr
#define HOST_SET_REG(ptr,value)  ptr = value
#define HOST_AND_REG(ptr,value)  ptr &= value
#define HOST_OR_REG(ptr,value)  ptr |= value
#define HOST_WRT_MBOX(ptr,value) { ptr |= value; \
				   while (ptr & value); \
				 }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) *(ptr) = *(value_ptr)
#define READ_BOLT_MEM(value_ptr,ptr,size) *(value_ptr) = *(ptr)
#define WRITE_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define READ_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define BOLTREAD(fd,buf,siz,type) fioRead(fd,buf,siz)
#define BOLTWRITE(fd,buf,siz) write(fd,buf,siz)
#endif	/* VXWORKS */

#ifdef SGI
#define READ_I860_REGISTER(ptr,value_ptr) *(value_ptr) = ptr
#define HOST_SET_REG(ptr,value)  ptr = value
#define HOST_AND_REG(ptr,value)  ptr &= value
#define HOST_OR_REG(ptr,value)  ptr |= value
#define HOST_WRT_MBOX(ptr,value) { ptr |= value; \
				   while (ptr & value); \
				 }
#define WRITE_BOLT_MEM(value_ptr,ptr,size) *(ptr) = *(value_ptr)
#define READ_BOLT_MEM(value_ptr,ptr,size) *(value_ptr) = *(ptr)
#define WRITE_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define READ_BOLT_MEMBLOCK(src,dst,size) bcopy(src,dst,size)
#define BOLTREAD(fd,buf,siz,type) read(fd,buf,siz)
#define BOLTWRITE(fd,buf,siz) write(fd,buf,siz)
#endif	/* SGI */
#ifdef SRECORDS
#define BOLTREAD(fd,buf,siz,type) boltread(fd,buf,siz,type)
#define BOLTWRITE(fd,buf,siz) boltwrite(fd,buf,siz)
#endif
#define LOAD_BOLT		load_bolt
#define UNLOAD_BOLT		unload_bolt
#define SET_MISC_960_ADDRS      set_misc_960_addrs

#endif /* MP */



/*
 * VME control register bits (r/w)
 */

#define VME_SLAVE_ENA	0x0001		/* enable VME slave mode */
#define VME_INT_REQ	0x0002		/* set for 960-to-host interrupts */
#define VME_BURST_ENA   0x0004          /* enable VME burst mode */
#define VME_CLR_TIMEOUT	0x0008          /* clear VME timeout interrupt */
#define VME_BUS_REQ_L0	0x0000		/* set VME bus request level = 0 */
#define VME_BUS_REQ_L1	0x0100		/* set VME bus request level = 1 */
#define VME_BUS_REQ_L2	0x0200		/* set VME bus request level = 2 */
#define VME_BUS_REQ_L3	0x0300		/* set VME bus request level = 3 */
#define VME_INT_REQ_L1	0x0400		/* set VME int request level = 1 */
#define VME_INT_REQ_L2	0x0800		/* set VME int request level = 2 */
#define VME_INT_REQ_L3	0x0c00		/* set VME int request level = 3 */
#define VME_INT_REQ_L4	0x1000		/* set VME int request level = 4 */
#define VME_INT_REQ_L5	0x1400		/* set VME int request level = 5 */
#define VME_INT_REQ_L6	0x1800		/* set VME int request level = 6 */
#define VME_INT_REQ_L7	0x1c00		/* set VME int request level = 7 */
#define VME_ADDR_BIT31 	0x2000		/* set i960 for high 2 Giga of VME */
#define VME_IO_BIT16 	0x4000		/* set A16 VME access */
#define VME_IO_BIT24 	0x8000		/* set A24 VME access */

#define VME_CLEAR_ALL  	0x00000000	/* clear this register completely */

#define VME_BUS_REQ_MSK	0x0300		/* mask for VME bus request level */
#define VME_INT_REQ_MSK	0x1c00		/* mask for VME int request level */

#define VME_MASTR_ENA  0x1f      /* mask for master mode enable on 6U */

/*
 * VSB control register bits (r/w)
 */

#define VSB_SLAVE_ENA	0x0001		/* enable VSB slave mode */
#define VSB_INT_REQ	0x0002		/* set for 960-to-vsb_master ints */
#define VSB_BURST_ENA   0x0004          /* enable VSB burst mode */
#define VSB_CLR_TIMEOUT	0x0008          /* clear VSB timeout interrupt */
#define VSB_MSTR_ACC_L0	0x0000		/* set VSB master access level = 0 */
#define VSB_MSTR_ACC_L1	0x0100		/* set VSB master access level = 1 */
#define VSB_MSTR_ACC_L2	0x0200		/* set VSB master access level = 2 */
#define VSB_MSTR_ACC_L3	0x0300		/* set VSB master access level = 3 */
#define VSB_SEL_ALT   	0x0400		/* alternate VSB master addr space */
#define VSB_ADDR_HI_00	0x0000		/* set VSB high addr = 00 */
#define VSB_ADDR_HI_01	0x0800		/* set VSB high addr = 01 */
#define VSB_ADDR_HI_10	0x1000		/* set VSB high addr = 10 */
#define VSB_ADDR_HI_11	0x1800		/* set VSB high addr = 11 */

#define VSB_CLEAR_ALL  	0x00000000	/* clear this register completely */

#define VSB_MSTR_ACC_MSK 0x0300		/* mask for VSB master access level */
#define VSB_ADDR_HI_MSK	0x1800		/* mask for high VSB address bits */

#define VSB_MASTR_ENA  0x3       /* mask for master mode enable on 6U */


/*
 * IOP Mailbox settings.
 */

/* Message from host to bolt to tell bolt to stop what it is doing. */
#define MBX_STOP_PROCESSING	(short)0x0001	

/*
 * Bolt IOCTL definitions
 */

#ifdef sun_mmap
#define BOLTSETMEMSZ	_IOW(v, 0, int)
#define BOLTGETMEMSZ	_IOR(v, 1, int)
#define BOLTGETTYPE 	_IOR(v, 2, int)
#define BOLTMAPWINDOW 	_IOR(v, 3, int)
#endif

#ifdef SKYSTATION
#ifdef SUN
#define BOLTSETMEMSZ	_IOW(v, 0, int)
#define BOLTGETMEMSZ	_IOR(v, 1, int)
#define BOLTGETTYPE 	_IOR(v, 2, int)
#define SKIOCSCMD	_IOR(v, 3, int)
#define BOLTMAPWINDOW 	_IOR(v, 4, int)
#else
#define BOLTSETMEMSZ	_IOW('v', 0, int)
#define BOLTGETMEMSZ	_IOR('v', 1, int)
#define BOLTGETTYPE 	_IOR('v', 2, int)
#define SKIOCSCMD	_IOR('v', 3, int)
#define BOLTMAPWINDOW 	_IOR(v, 4, int)
#endif
#endif

#ifdef sony
#define BOLTSETMEMSZ	_IOW(v, 0, int)
#define BOLTGETMEMSZ	_IOR(v, 1, int)
#define BOLTGETTYPE 	_IOR(v, 2, int)
#define BOLTNOISEON     _IO(v, 3)    /* Turn driver noise on (must be root) */
#define BOLTNOISEOFF    _IO(v, 4)    /* Turn driver noise off (must be root) */
#define BOLTREGSPACE    _IO(v, 5)    /* Set VME space to BOLT registers */
#define BOLTMEMSPACE    _IO(v, 6)    /* Set VME space to BOLT memory */
#define BOLTPUSHSPACE   _IO(v, 7)    /* Save VME address space on "stack" */
#define BOLTPOPSPACE    _IO(v, 8)    /* Restore VME addr space from "stack" */
#define BOLTMAPWINDOW 	_IOR(v, 9, int)
#endif

#ifdef VXWORKS
#define BOLTSETMEMSZ    0
#define BOLTGETMEMSZ    1
#define BOLTGETTYPE     2
#define BOLTGETREGADDR  3
#define BOLTGETMEMADDR  4
#define BOLTALLOCMEM    5
#define BOLTMAPWINDOW   6
#endif	/* VXWORKS */

#ifdef SGI
#define BOLTSETMEMSZ    0
#define BOLTGETMEMSZ    1
#define BOLTGETTYPE     2
#define BOLTGETREGADDR  3
#define BOLTGETMEMADDR  4
#define BOLTFILLMEM     5
#define BOLTCHECKMEM    6
#define BOLTMAPWINDOW   7
#endif

char **xargv;		/* for boltload finding ucode in a.out */

/*
 *  miscellaneous register access definitions
 */

#define boltgo()  curbolt->regs->iop_csr_reg |= IOP_GO
#define boltrst() curbolt->regs->iop_csr_reg &= ~IOP_GO
#define boltsts(value) *(value) = curbolt->regs->iop_csr_reg


/*
 * A description of the i860 Register Save Area.
 *	(matches simulator requirements) 
 */

/* 64 bits integers, used by the I unit */
typedef struct l_i_t
{
        unsigned long	low;
        unsigned long	high;
} l_i;

typedef union i_s_t_t {
         float		s;
         double		d;
         unsigned long	w[2];
         l_i	l;
} i_s_t;

/* 64 bit integer overlays, to support the various pixel sizes */
typedef union {
        l_i	l;
        unsigned short	h[4];
        unsigned char	b[8];
} i_u_r;

typedef struct {
        unsigned char	cas_ws;
        unsigned char	ras_ws;
        unsigned char	ads2na;
        unsigned char	r1;
} m_s_t;

typedef struct {			/* i860 Register storage */
	unsigned long iregs[32];	/* was "n10_word" */
	union {
		float  s[32];
		double d[16];
		unsigned long w[32];
		l_i l[16];
		unsigned short h[64];
	} fregs;
	i_s_t	t, ki, kr;
	i_u_r   merge;
	i_s_t	lpipe[3];	/* Load pipe		*/
	i_s_t	apipe[3];	/* A unit pipeline	*/
	i_s_t	mpipe[3];	/* M unit pipeline	*/
	i_u_r	ipipe;		/* I unit pipeline	*/
	unsigned long	fsr[3]; 
	unsigned long	psr;
	unsigned long	fir;
	unsigned long	dirbase;
	unsigned long	db;
	unsigned long	epsr;
	unsigned long	pc;
	unsigned long	total_time, partial_time;
	unsigned long	t_start, t_end;
	m_s_t	mem_spec;
	m_s_t	mem_spec2;
	unsigned long	i_cache_size, d_cache_size, tlb_size;
	float 		 i_chrc, d_chrc, tlb_chrc;
	unsigned long	intr_addr;
	unsigned long	clock_tick;
	unsigned long	trap_addr;
	unsigned long	num_instr;
	unsigned long	sim_ctrl_reg;
	unsigned long	t1;
	unsigned long	t2;
	unsigned long	mem_config;
	unsigned long	spfir; 
	unsigned long	sppsr;
	unsigned long	spfsr[3]; 
	i_s_t	splpipe[3];	/* Load pipe		*/
	i_s_t	spapipe[3];	/* A unit pipeline	*/
	i_s_t	spmpipe[3];	/* M unit pipeline	*/
} regs_t;

/*
 * i860 register defines
 */

#define PSR_FULL_INTMASK	0x1f00	/* i860 interrupt masks */
#define PSR_IT_MASK		0x0100
#define PSR_IN_MASK		0x0200
#define PSR_IAT_MASK		0x0400
#define PSR_DAT_MASK		0x0800
#define PSR_FPT_MASK		0x1000

#define PSR_DIM_MASK		0x4000	/* dual instruction mode bit */

#define FSR_SE_MASK		0x0100	/* i860 FP interrupt masks */
#define FSR_FULL_MASK	       0x1ff00	

#endif

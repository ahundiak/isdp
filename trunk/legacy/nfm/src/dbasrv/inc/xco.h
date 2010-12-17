/* $Revision: 1.1 $ */
/*#ident	"@(#)xco.h	1.3 10/5/88  Copyright (c) 1988 Intergraph Corp."*/

/*
** include file for XNS Connection-Oriented Transport Layer Streams Driver
*/

#define XCO_STR_ID	1
#define XCO_NUM_IOBS	5
#define XCO_NUM_RCVS	2	/* rcvs_active bit field in struct xco   */
				/* must be big enough to hold this value */
#define XCO_SLPRIO	PZERO

#define XCO_CIND_MAX	4
#define XCO_REACC_MAX	5
#define XCO_MIN_PKT_SZ	1
#define XCO_MAX_PKT_SZ	4096
#define XCO_HI_WATER	(4 * XCO_MAX_PKT_SZ)
#define XCO_LO_WATER	(2 * XCO_MAX_PKT_SZ)

#define XCO_TSDU_SIZE	(-1)
#define XCO_ETSDU_SIZE	1
#define XCO_CDATA_SIZE	(-2)
#define XCO_DDATA_SIZE	(-2)
#define XCO_ADDR_SIZE	(sizeof(struct xco_adr))
#define XCO_OPT_SIZE	0
#define XCO_TIDU_SIZE	strmsgsz

#define XCO_NUM(X)	((struct xco *)(X) - xco_xco)

#define XCO_OPEN_TO	15000
#define XCO_WINDOW	(-4)

#define XCO_CLOSE_IOB	1
#define XCO_CLOSE_DEAC	2

#define xco_chk_status(c,n)	((c != CP_SUCCESS_ST) ? c : ((n & 1) ? 0 : n)) 

struct xco_adr {
	unchar	net[4];
	unchar	host[6];
	unchar	socket[2];
};

#ifdef INKERNEL

struct xco_iob {
	cpcmd_t		 cmd;
	cpnrp_t		 nrp;
	struct xco	*xcop;
	mblk_t		*mp;
	queue_t		*q;
	short		 cind;
	short		 state;
#define XCO_IOB_FREE	 0
#define XCO_IOB_IDLE	 1
#define XCO_IOB_INCP	 2
#define XCO_IOB_COMP	 3
#define XCO_IOB_BACK	 4
#define XCO_IOB_CIND	 5
#define XCO_IOB_CCON	 6
#define XCO_IOB_RXDT	 7
#define XCO_IOB_DSCI	 8
};

/*
**	Listener connect indication structure
*/
struct	xco_cind {
	long		inuse;		/* cind in use indicator  */
	struct xco_adr	srcadr;		/* peer address structure */
};

/*
**	XCO control structure
*/
struct xco {
	unchar		 state;
	unchar		 closing;
	ushort		 fatal:1;
	ushort		 dxing:1;
	ushort		 need_iob:1;
	ushort		 rcvs_active:2;
	ushort		 unused:11;
	queue_t		*rdq;
	short		 a_id[2];
	struct xco_adr	 bind_addr;
	struct xco_adr	 peer_addr;
	short		 max_cind;
	short		 tot_cind;
	int		 xco_tx_cnt;
	int		 xco_rx_cnt;
	struct xco_cind	 cind[XCO_CIND_MAX];
	struct xco_iob   iob[XCO_NUM_IOBS];
};

#define XCO_CIND_MSGSZ (sizeof(struct T_conn_ind) + XCO_ADDR_SIZE+XCO_OPT_SIZE)
#define XCO_INFA_MSGSZ (sizeof(struct T_info_ack))
#define XCO_BACK_MSGSZ (sizeof(struct T_bind_ack) + XCO_ADDR_SIZE)
#define XCO_OPTA_MSGSZ (sizeof(struct T_optmgmt_ack) + XCO_OPT_SIZE)
#define XCO_DSCI_MSGSZ (sizeof(struct T_discon_ind))
#define XCO_CCON_MSGSZ (sizeof(struct T_conn_con) + XCO_ADDR_SIZE+XCO_OPT_SIZE)
#define XCO_ERRA_MSGSZ (sizeof(struct T_error_ack))
#define XCO_RXXD_MSGSZ (sizeof(struct T_exdata_ind))
#define XCO_RXRD_MSGSZ (sizeof(struct T_data_ind))
#define XCO_RXDT_MSGSZ 1454

#define XCO_MPDBSZ(mp) (mp->b_datap->db_lim - mp->b_datap->db_base)

#endif

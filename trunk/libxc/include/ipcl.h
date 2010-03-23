#define IPCL_QKEY 666
#define IPCL_MTYP 666

#define IPCL_MES	6661
#define IPCL_SEM	6662
#define IPCL_SHM	6663

#define IPCL_MSGSIZ	8

#define IPCL_NOSWITCH	040000

#define IPCL_QPROT	0666

typedef struct IPCL_msgbuf {
	union {
		long			mtype;
		struct IPCL_msgbuf	*next;
	} msgu;
	
#define Mtype	msgu.mtype
#define Next	msgu.next

	int			type;
	int			id;

} IPCL_msgbuf,  *p_IPCL_msgbuf;

#define IPCL_msgget(KEY, MSGFLG)\
	IPCL_get(IPCL_MES, KEY, 0, MSGFLG)
	
#define IPCL_semget(KEY, NSEMS, SEMFLG)\
	IPCL_get(IPCL_SEM,  KEY, NSEMS, SEMFLG)
	
#define IPCL_shmget(KEY, SIZE, SHMFLG)\
	IPCL_get(IPCL_SHM, KEY, SIZE, SHMFLG)

#define IPCL_msgctl(ID, CMD, BUF)\
	IPCL_ctl(IPCL_MES, ID, 0, CMD, BUF)
	
#define IPCL_semctl(ID, SEMNUM, CMD, ARG)\
	IPCL_ctl(IPCL_SEM, ID, SEMNUM, CMD, ARG)
	
#define IPCL_shmctl(ID, CMD, BUF)\
	IPCL_ctl(IPCL_SHM, ID, 0, CMD, BUF)


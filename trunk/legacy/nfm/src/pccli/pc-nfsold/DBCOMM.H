/* SPONSOR Server commands */
#define LOGIN			500
#define LIST_NODES		501
#define	LIST_CATS		502
#define LIST_ITEMS		503
#define LIST_ITEM_INFO		504
#define LIST_SYN		505
#define LIST_META		506
#define GET_TYPE		507
#define GET_REMOTE_FILE		508
#define GET_NODE		509
#define ANY_SQL 		510
#define LOGFILE 		511
#define ADDCHECKIN 		512
#define CHECKIN_ITEM 		513
#define CHECKOUT_ITEM 		514
#define COPYFILE 		515
#define WRITE_IF_FILE		516
#define GET_PLOT_QUEUES		517
#define	GET_SETUP		518
#define GET_OFF_OD		520
#define	LIST_SA			521
#define	CHECKOUT_SET		522
#define	CHECKIN_SET		523
#define	ADD_ITEM		524
#define	LIST_SETS		525
#define	LIST_SET_MEMBERS	526
#define	GET_ALL_QUEUES		527
#define	ADD_SET			528
#define	ADD_SET_ITEM		529
#define	ADD_SET_MBR		530
#define	LIST_ENVS		531
#define	COPY_ITEM		532
#define	COPY_SET		533
#define	COPY_MF_ITEM		534
#define	CHECKIN_MF_ITEM		535
#define	LIST_USERS		536
#define	LIST_WORKFLOWS		537
#define	TOGGLE			538
#define	TRANSITION_YES		539
#define	TRANSITION_NO		540
#define	SET_MAX_RETURN		541
#define	CATALOG_ATTR		542
#define	CREATE_CATALOG		543
#define CHECKOUT_MF_ITEM        544
#define MODIFY_CATALOG          545
#define GET_SQL_ERROR		546
#define	COPY_ITEM_OK		547
#define LOAD_WORKFLOW           548
#define ADD_ACL                 549
#define ADD_ACL_USER            550
#define DELETE_ACL_USER         551
#define ADD_USER                552
#define PUSH_TEXT_FILE		553
#define PULL_TEXT_FILE          554
#define	PULL_PIPED_INFO		555
#define	SHELL_COMMAND		556
#define	SUBMIT_CACHE		557
#define	SUBMIT_PLOTS		558
#define	ADD_STORAGE_AREA	559
#define	SET_DEBUG_LEVEL		560
#define	GET_NFM_ERROR		561
#define GET_REDLINE_INFO        562
#define ADD_NFM_NODE	        563
#define	VALIDATE_DATE		564
#define CANCEL_STATE            565
#define VERIFY_PASSWORD         566
#define	APPEND_TEXT_FILE	567
#define SEND_DATA		600

/* Size of SPONSOR server's storage buffer. */
#define MAXBUFSIZE 		51200	/* 50k bytes */
#define MAXKBYTES	16384	/* instead of 2048 (2k) bytes, size of communication buffer */

/* Size of communication buffer, Clipper and DOS respectively. */
#define WS_MAX_BYTES	32000	/* 32000 bytes, size of communication buffer */
#define PC_MAX_BYTES	8000	/* 8000 bytes, size of communication buffer */


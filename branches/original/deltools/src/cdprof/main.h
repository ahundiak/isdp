#define		RW_OWNER	00600	/* owner can read and write to file   */

/* lengths of fields */

#define		MAG_LEN		4	/* magic number for the base1 file    */
#define		OLD_PROD_LEN	7	/* product number - old style         */
#define		PROD_LEN	9	/* product number                     */
#define		BAS4_PROD_LEN	15	/* Newest product number              */
#define		IND_LEN		2	/* index to product                   */
#define		LEN_LEN		2	/* length of file                     */
#define		EID_LEN		4	/* eid for a customer                 */
#define		OFF_LEN		4	/* offset into file for a customer    */
#define		REL_LEN		3	/* release prefix to the key          */
#define		KEY_LEN		16	/* one key                            */
#define		BAS4_KEY_LEN	21	/* New KeyLen                         */
#define		CUS_LEN		8  	/* eid plus offset for each customer  */
#define		KEY_AND_PROD	28	/* key and product number with extra  */
#define		BAS4_KEY_AND_PROD 39    /* key and product number with extra  */
#define		HEADER1		8	/* header on the base1 file           */
#define		HEADER2		3	/* header on the temp file            */


/* other stuff */

#define		CMD_LEN		30	/* length of a command to ksh         */
#define		FIRST		-1	/* signifies first customer           */

#define		FROM_START	0	/* seek from start of file            */
#define		FROM_HERE	1	/* seek from pointer in file          */
#define		FROM_END	2	/* seek from end of file              */

#define		TRUE		1
#define		FALSE		0

#define		MAXLINE		300

/* defines used by LOFT Query */

/* Go down in structure History */ 
#define VL_Q_DOWN_AFTER		0x0001	/* Browse Function in History after 
					Entry*/
#define VL_Q_DOWN_DIRECT	0x0002	/* Browse Function directly on nodes 
					include between top limit and entry*/   

/* Back up in structure History */
#define VL_Q_TOP_LIM_MASK	0x0003	/* Browse Function From XXX to Entry */
#define VL_Q_TOP_CURRENT	0x0000	/*	XXX = CURRENT		     */
#define VL_Q_TOP_SOURCE		0x0001	/*	XXX = SOURCE		     */
#define VL_Q_TOP_ORIGINAL	0x0002	/*	XXX = ORIGINAL		     */

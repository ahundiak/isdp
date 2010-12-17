/* This file contains the #defines for functions in systools directory .
 This file must be included after the NFMschema.h. */

/* Password Encryption/Decryption Codes */
#define C1      23
#define C2      43

/* Maximum filename is set to 512 = 4 * NFM_FILENAME ( defined in NFMschema.h)*/ 
#define MAX_FILENAME    4*NFM_FILENAME

/* Old code needs these defines */

#define NFM_FIXED_ENCRYPT_LENGTH        25
#define NFM_MAX_PASSWD_LENGTH           14

/* Define temporary size to be 4* NFM_FILENAME */

#define TEMP_SIZE	4*NFM_FILENAME

/* A constant to be subtracted from time to reduce the time */
#define TIME_CONSTANT   686350000 /* Some time(GMT) in seconds in Oct, 1991 */


/* #defines for NFM_mkpath */

#define MAX_PATH_SIZE 301
#define MAX_DIRS 20


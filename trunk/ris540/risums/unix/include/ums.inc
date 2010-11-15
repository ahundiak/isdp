c
	parameter (UMS_MAX_BUFLEN = 512)
c
c File Initialization Options
c
c Save index based on message numbers
	parameter (UMS_INDEX = 1)
c Save the primary message keys
	parameter (UMS_KEY = 3)
c Save the secondary message keys
	parameter (UMS_KEY2 = 8)
c Save the message text
	parameter (UMS_MESSAGE = 5)
c
c UMSMsgCode Options
c
c Do not interpret component
	parameter (UMS_SUPPRESS_COMP = 1)
c Do not interpret type
	parameter (UMS_SUPPRESS_TYPE = 2)
c Do not interpret extension
	parameter (UMS_SUPPRESS_EXT = 4)
c
c UMS Return Codes
c
	parameter (UMS_S_SUCCESS = 1)
c File already initialized
	parameter (UMS_I_DUPINIT = 11)
c File not found or accessible
	parameter (UMS_E_NOFILE = 18)
c Not indexed message file
	parameter (UMS_E_INVFMT = 26)
c Invalid file version
	parameter (UMS_E_INVVER = 34)
c Too many files open
	parameter (UMS_E_TOOMANY = 42)
c Other (obscure) open error
	parameter (UMS_E_OPEN = 50)
c Error setting file position
	parameter (UMS_E_SEEK = 58)
c Error reading message file
	parameter (UMS_E_READ = 66)
c Read past the end-of-file
	parameter (UMS_E_EOF = 74)
c Message number/key not found
	parameter (UMS_E_NOTFND = 82)
c File not initialized
	parameter (UMS_E_NOTINIT = 90)
c Insufficient virtual memory
	parameter (UMS_E_INSVMEM = 98)
c Invalid initialization option
	parameter (UMS_E_INVOPT = 106)
c Message text not in memory
	parameter (UMS_W_NOTINMEM = 112)

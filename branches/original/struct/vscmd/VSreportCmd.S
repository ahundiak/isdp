/*
	I/STRUCT
*/
class specification VSreportCmd (1:0) of VSpartopCmd ;

instance VSreportCmd {

	/*
	 * Pointer to input-file-name form.
	 */
	char		*fileForm ;

	VSfileFormInfo	fileInfo ;
} ;

message createFileForm( long *msg ) ;

message fileFormDismissed( int dismissType ) ;

message fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ ) ;

override operation ;

end specification VSreportCmd ;

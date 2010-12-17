# Install.sun remove.sun etc..
# Modified for Sun version - Vasu 30.11.93
#
echo "rcp ..."
rcp -p install.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/install.sun
#rcp -p share.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/share.sun
rcp -p remove.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/remove.sun
rcp -p product.def delserv@aec:/usr5/delserv/nfm/i_nfmsrv/product.def
rcp -p README delserv@aec:/usr5/delserv/nfm/i_nfmsrv/README
echo



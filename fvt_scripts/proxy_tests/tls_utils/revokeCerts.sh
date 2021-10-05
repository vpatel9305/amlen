set -x
if [ "$1" == "" -o "$2" == "" ] ; then
  echo "usage: $0 <cert size> <dir to create>"
  echo "  e.g. $0 2048 certs2Kb"
  exit 1
fi

SIZE=$1
DIR=$2
CURRDIR=$(pwd)

rm -rf $DIR
mkdir -p $DIR ; cd $DIR
cp ../clientext_revoke.cfg .
touch revcertindex
echo 0500 > revcertserial
echo 0500 > revcrlnumber

openssl genrsa -out revRootCA-key.pem     $SIZE >/dev/null 2>/dev/null
openssl genrsa -out revokeCA-key.pem     $SIZE >/dev/null 2>/dev/null
openssl genrsa -out clientRevoke-key.pem $SIZE >/dev/null 2>/dev/null


openssl req -new -x509 -days 3560 -subj "/C=US/ST=Texas/L=Austin/O=IBM/OU=Corporate/CN=revRoot" -extensions revRoot_ca -config clientext_revoke.cfg -set_serial 500 -key revRootCA-key.pem -out revRootCA-crt.pem
openssl req -new -days 3560 -subj "/C=US/ST=Texas/L=Austin/O=IBM/OU=Corporate/CN=revoke" -key revokeCA-key.pem -out revokeCA-crt.csr
#openssl req -new -x509 -days 3560 -key revokeCA-key.pem -out revokeCA-crt.csr

#openssl x509 -days 3560 -in revRootCA-crt.csr -out revRootCA-crt.pem -signkey revRootCA-key.pem -set_serial 500 -extfile clientext_revoke.cfg
openssl x509 -days 3560 -in revokeCA-crt.csr -out revokeCA-crt.pem -req -CA revRootCA-crt.pem -CAkey revRootCA-key.pem -set_serial 501 -extensions revoke_ca -extfile clientext_revoke.cfg
#openssl x509 -days 3560 -in revokeCA-crt.csr -out revokeCA-crt.pem -set_serial 500 -extensions revoke_ca -extfile clientext_revoke.cfg

openssl req -new -days 3560 -subj "/C=US/ST=Texas/L=Austin/O=IBM/OU=IMATEST/CN=clientRevoke" -key clientRevoke-key.pem -out clientRevoke1-crt.csr
openssl req -new -days 3560 -subj "/C=US/ST=Texas/L=Austin/O=IBM/OU=IMATEST/CN=clientRevoke" -key clientRevoke-key.pem -out clientRevoke2-crt.csr
openssl req -new -days 3560 -subj "/C=US/ST=Texas/L=Austin/O=IBM/OU=IMATEST/CN=clientRevoke" -key clientRevoke-key.pem -out clientRevoke3-crt.csr

openssl x509 -days 3560 -in clientRevoke1-crt.csr -out clientRevoke1-crt.pem -req -CA revokeCA-crt.pem -CAkey revokeCA-key.pem -extensions revoke_ca -set_serial 512 2>/dev/null
openssl x509 -days 3560 -in clientRevoke2-crt.csr -out clientRevoke2-crt.pem -req -CA revokeCA-crt.pem -CAkey revokeCA-key.pem -extensions revoke_ca -set_serial 513 2>/dev/null
openssl x509 -days 3560 -in clientRevoke3-crt.csr -out clientRevoke3-crt.pem -req -CA revokeCA-crt.pem -CAkey revokeCA-key.pem -extensions revoke_ca -set_serial 514 2>/dev/null

#TODO - more work on this section
openssl pkcs12 -export -inkey clientRevoke-key.pem -in clientRevoke1-crt.pem -out clientRevoke1.p12 -password pass:password
openssl pkcs12 -export -inkey clientRevoke-key.pem -in clientRevoke2-crt.pem -out clientRevoke2.p12 -password pass:password
openssl pkcs12 -export -inkey clientRevoke-key.pem -in clientRevoke3-crt.pem -out clientRevoke3.p12 -password pass:password

keytool -importkeystore -srckeystore clientRevoke1.p12 -destkeystore ibmRevoke.jks -srcstoretype pkcs12 -deststorepass password -deststoretype jks -srcstorepass password
keytool -importkeystore -srckeystore clientRevoke2.p12 -destkeystore ibmRevoke.jks -srcstoretype pkcs12 -deststorepass password -deststoretype jks -srcstorepass password
keytool -importkeystore -srckeystore clientRevoke3.p12 -destkeystore ibmRevoke.jks -srcstoretype pkcs12 -deststorepass password -deststoretype jks -srcstorepass password
keytool -import -trustcacerts -file imaserverb-crt.pem -keystore ibmRevoke.jks -storepass password -noprompt -alias proxyDefaultCtx
keytool -import -trustcacerts -file ../../keystore/servercert.pem -keystore ibmRevoke.jks -storepass password -noprompt -alias mqttsDefaultCtx

#END TODO - more work on this section

openssl ca -config clientext_revoke.cfg -gencrl -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -out revcrl0.crl

openssl ca -config clientext_revoke.cfg -revoke clientRevoke1-crt.pem -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -cert revokeCA-crt.pem
openssl ca -config clientext_revoke.cfg -gencrl -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -out revcrl1.crl

openssl ca -config clientext_revoke.cfg -revoke clientRevoke2-crt.pem -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -cert revokeCA-crt.pem
openssl ca -config clientext_revoke.cfg -gencrl -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -out revcrl2.crl

openssl ca -config clientext_revoke.cfg -revoke clientRevoke3-crt.pem -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -cert revokeCA-crt.pem
openssl ca -config clientext_revoke.cfg -gencrl -cert revokeCA-crt.pem -keyfile revokeCA-key.pem -out revcrl3.crl

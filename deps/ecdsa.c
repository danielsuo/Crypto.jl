#include <stdlib.h>
#include <stdio.h>
#include <openssl/ec.h>
#include <openssl/obj_mac.h> // for NID_secp256k1

// for executable:  gcc -lcrypto -std=c99 priv2pub.c -o priv2pub
// for dynamic lib: gcc -lcrypto -std=c99 -fPIC -shared -Wl,-soname,libpriv2pub.so.1 priv2pub.c -o libpriv2pub.so.1.0

// calculates and returns the public key associated with the given private key
// - input private key and output public key are in hexadecimal
// - output is null-terminated string
// form = POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED|HYBRID]
void ec_pubkey_create(unsigned char *seckey,
                      unsigned char *pubkey,
                      int pubkey_length,
                      int curve_id,
                      point_conversion_form_t form
                      )
{
  // create group
  EC_GROUP *ec_group = EC_GROUP_new_by_curve_name( curve_id );

  // convert priv key from hexadecimal to BIGNUM
  BIGNUM *seckey_bn = BN_new();
  BN_hex2bn( &seckey_bn, seckey );

  // compute pub key from priv key and group
  EC_POINT *pub = EC_POINT_new( ec_group );
  EC_POINT_mul( ec_group, pub, seckey_bn, NULL, NULL, NULL );

  // TODO: change to point2oct
  // convert pub_key from elliptic curve coordinate to hexadecimal string
  memcpy(pubkey, EC_POINT_point2hex( ec_group, pub, form, NULL ), pubkey_length * sizeof(unsigned char));

  EC_GROUP_free( ec_group ); BN_free( seckey_bn ); EC_POINT_free( pub );
}

// testcase : 
// $./priv2pub 18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725
// 0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6
// 0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6

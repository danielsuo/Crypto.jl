#include <stdlib.h>
#include <stdio.h>
#include <openssl/ec.h>

// Include for curve constants
#include <openssl/obj_mac.h>

// Return public key associated with given secret key over specified curve
// secret_key: 
// public_key: 
// public_key_length: 
// curve_id: https://github.com/openssl/openssl/blob/master/crypto/objects/obj_mac.h
// form: POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED|HYBRID]
void ec_public_key_create(const char *secret_key,
                          unsigned char *public_key,
                          int public_key_length,
                          int curve_id,
                          point_conversion_form_t form
                          )
{
  // Create group based on provided curve
  EC_GROUP *ec_group = EC_GROUP_new_by_curve_name( curve_id );

  // Convert private key to BIGNUM
  BIGNUM *secret_key_bn = BN_new();
  BN_hex2bn( &secret_key_bn, secret_key );

  // Compute public key from private key
  EC_POINT *pub = EC_POINT_new( ec_group );
  EC_POINT_mul( ec_group, pub, secret_key_bn, NULL, NULL, NULL );

  // Generate corresponding public key generated with against ECDSA secp256k1
  // (65 bytes, 1 byte 0x04, 32 bytes corresponding to X coordinate, 32 bytes 
  // corresponding to Y coordinate)
  size_t len = EC_POINT_point2oct( ec_group, pub, form, NULL, 0, NULL );
  EC_POINT_point2oct( ec_group, pub, form, public_key, len, NULL );

  EC_GROUP_free( ec_group ); BN_free( secret_key_bn ); EC_POINT_free( pub );
}
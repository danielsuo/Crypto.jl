#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <openssl/bn.h>
#include <openssl/ec.h>
 #include <openssl/ecdsa.h>

// Include for curve constants
#include <openssl/obj_mac.h>

// TODO: consider using bytes rather than hex strings
int ec_keys(EC_KEY *keys,
            const char *priv_key,
            const char *pub_key,
            int curve_id)
{
  // Error if neither priv_key nor pub_key are set
  if (priv_key == NULL && pub_key == NULL) {
    return -1;
  }

  // Create group based on provided curve
  EC_GROUP *ec_group = EC_GROUP_new_by_curve_name( curve_id );
  BIGNUM *priv_key_bn = BN_new();
  EC_POINT *pub_key_point = EC_POINT_new( ec_group );

  if (priv_key != NULL) {
    BN_hex2bn( &priv_key_bn, priv_key );
    EC_KEY_set_private_key( keys, priv_key_bn );
  }

  if (pub_key != NULL) {
    EC_POINT_hex2point( ec_group, pub_key, pub_key_point, NULL );
  } else {
    EC_POINT_mul( ec_group, pub_key_point, priv_key_bn, NULL, NULL, NULL );
  }

  EC_KEY_set_group( keys, ec_group );
  EC_KEY_set_public_key( keys, pub_key_point );

  EC_GROUP_free( ec_group );
  BN_free( priv_key_bn );
  EC_POINT_free( pub_key_point );

  // TODO: We should implement better error checking
  return 1;
}

// Return public key associated with given secret key over specified curve
// priv_key: hex string
// pub_key: pointer to return array of Uint8
// curve_id: https://github.com/openssl/openssl/blob/master/crypto/objects/obj_mac.h
// form: POINT_CONVERSION_[UNCOMPRESSED|COMPRESSED|HYBRID]
void ec_pub_key(unsigned char *pub_key,
                const char *priv_key,
                int curve_id,
                point_conversion_form_t form
                )
{
  EC_KEY *keys = EC_KEY_new();

  // Fill EC_KEY object with group and private/public keys
  ec_keys( keys, priv_key, NULL, curve_id );

  const EC_GROUP *group = EC_KEY_get0_group( keys );
  const EC_POINT *pk_point = EC_KEY_get0_public_key( keys );
  const BIGNUM *priv = EC_KEY_get0_private_key( keys );

  // Generate corresponding public key generated with against ECDSA secp256k1
  // (65 bytes, 1 byte 0x04, 32 bytes corresponding to X coordinate, 32 bytes 
  // corresponding to Y coordinate)
  size_t len = EC_POINT_point2oct( group, pk_point, form, NULL, 0, NULL );
  EC_POINT_point2oct( group, pk_point, form, pub_key, len, NULL );

  EC_KEY_free( keys );
}

unsigned int ec_sign(unsigned char *sig,
                     const unsigned char *hash,
                     int hashlen,
                     const char *priv_key,
                     int curve_id
                    )
{
  EC_KEY *keys = EC_KEY_new();

  // Fill EC_KEY object with group and private/public keys
  ec_keys( keys, priv_key, NULL, curve_id );

  unsigned int *siglen = malloc(sizeof(unsigned int));
  ECDSA_sign( 0, hash, hashlen, sig, siglen, keys );

  EC_KEY_free( keys );

  return *siglen;
}

int ec_verify(const unsigned char *hash,
              int hashlen,
              const unsigned char *sig,
              int siglen,
              const char *pub_key,
              int curve_id
              )
{
  EC_KEY *keys = EC_KEY_new();

  ec_keys( keys, NULL, pub_key, curve_id );

  int result = ECDSA_verify( 0, hash, hashlen, sig, siglen, keys );

  EC_KEY_free( keys );

  return result;
}

int main( int argc, char **argv )
{
  // unsigned char *pub = malloc(130);
  // get priv key from cmd line and compute pub key
  // ec_pub_key( pub, argv[1], 714, POINT_CONVERSION_UNCOMPRESSED );
  // printf( "%s\n", pub );
  // free( pub );

  // unsigned char *sig = malloc(72);
  // int *siglen = malloc(sizeof(int));

  // ec_sign( sig, argv[1], strlen(argv[1]), argv[2], NID_secp256k1 );

  // unsigned char *sig = malloc(72 * sizeof(unsigned char));
  // int siglen = ec_sign( sig, argv[1], strlen(argv[1]), argv[2], NID_secp256k1 );

  // printf("%d\n", siglen);
  // printf("sig: ");
  // for (int i = 0; i < siglen; i++) {
  //   printf("%x", sig[i]);
  // }
  // printf("\n");

  // printf("%d\n", ec_verify(argv[1], strlen(argv[1]), sig, siglen, argv[3], NID_secp256k1));

  return 0;
}

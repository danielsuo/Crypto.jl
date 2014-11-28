using Crypto
using Base.Test

##############################################################################
##
## Crypto tests
##
##############################################################################

# SHA2 tests
# Test empty string
@test Crypto.SHA2.sha256("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

@test Crypto.SHA2.sha256("a", is_hex=false) == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
@test Crypto.SHA2.sha256("Scientific progress goes 'boink'", is_hex=false) == "2f2ba2a09a66771bf1fdf541af6e9db4b443145f9935ddd5d4c323c21a8bdcee"
@test Crypto.SHA2.sha256("I'd hold you up to say to your mother, 'this kid's gonna be the best kid in the world. This kid's gonna be somebody better than anybody I ever knew.' And you grew up good and wonderful. It was great just watching you, every day was like a privilege. Then the time come for you to be your own man and take on the world, and you did. But somewhere along the line, you changed. You stopped being you. You let people stick a finger in your face and tell you you're no good. And when things got hard, you started looking for something to blame, like a big shadow. Let me tell you something you already know. The world ain't all sunshine and rainbows. It's a very mean and nasty place and I don't care how tough you are it will beat you to your knees and keep you there permanently if you let it. You, me, or nobody is gonna hit as hard as life. But it ain't about how hard ya hit. It's about how hard you can get hit and keep moving forward. How much you can take and keep moving forward. That's how winning is done! Now if you know what you're worth then go out and get what you're worth. But ya gotta be willing to take the hits, and not pointing fingers saying you ain't where you wanna be because of him, or her, or anybody! Cowards do that and that ain't you! You're better than that! I'm always gonna love you no matter what. No matter what happens. You're my son and you're my blood. You're the best thing in my life. But until you start believing in yourself, ya ain't gonna have a life. Don't forget to visit your mother.", is_hex=false) == "a5d8cfb99203ae8cd0c222e8aaef815a7a53493f650c5dec0d73de7f912e91f2"

# Test > 448 bits (> 56 characters)
@test Crypto.SHA2.sha256("asdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqw", is_hex=false) == "07a95e647687cf0e8cd3d0ca78c9cc9b120ab41497f5f3be912c6c3f1ecd3a31"

# Test hex strings
@test Crypto.SHA2.sha256("800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592"
@test Crypto.SHA2.sha256("8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592") == "507a5b8dfed0fc6fe8801743720cedec06aa5c6fca72b07c49964492fb98a714"

# RIPEMD tests
@test Crypto.RIPEMD.ripemd160("asdf", is_hex=false) == "0ef2aed6346def670a8019e4ea42cf4c76018139"
@test Crypto.RIPEMD.ripemd160("", is_hex=false) == "9c1185a5c5e9fc54612808977ee8f548b2258d31"
@test Crypto.RIPEMD.ripemd160("a", is_hex=false) == "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe"
@test Crypto.RIPEMD.ripemd160("abc", is_hex=false) == "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc"
@test Crypto.RIPEMD.ripemd160("message digest", is_hex=false) == "5d0689ef49d2fae572b881b123a85ffa21595f36"
# @test Crypto.RIPEMD.ripemd160("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", is_hex=false) == "b0e20b6e3116640286ed3a87a5713079b21f5189"
# @test Crypto.RIPEMD.ripemd160("I'd hold you up to say to your mother, 'this kid's gonna be the best kid in the world. This kid's gonna be somebody better than anybody I ever knew.' And you grew up good and wonderful. It was great just watching you, every day was like a privilege. Then the time come for you to be your own man and take on the world, and you did. But somewhere along the line, you changed. You stopped being you. You let people stick a finger in your face and tell you you're no good. And when things got hard, you started looking for something to blame, like a big shadow. Let me tell you something you already know. The world ain't all sunshine and rainbows. It's a very mean and nasty place and I don't care how tough you are it will beat you to your knees and keep you there permanently if you let it. You, me, or nobody is gonna hit as hard as life. But it ain't about how hard ya hit. It's about how hard you can get hit and keep moving forward. How much you can take and keep moving forward. That's how winning is done! Now if you know what you're worth then go out and get what you're worth. But ya gotta be willing to take the hits, and not pointing fingers saying you ain't where you wanna be because of him, or her, or anybody! Cowards do that and that ain't you! You're better than that! I'm always gonna love you no matter what. No matter what happens. You're my son and you're my blood. You're the best thing in my life. But until you start believing in yourself, ya ain't gonna have a life. Don't forget to visit your mother.", is_hex=false) == "fff55c23c197b4fded67e09424e5aef9dafad1c6"

# ECDSA tests
a = Crypto.ECDSA.FiniteFields.makeModular(324,3851)
b = Crypto.ECDSA.FiniteFields.makeModular(1287,3851)
insecureCurve = Crypto.ECDSA.EllipticCurves.Curve(a,b)
x = Crypto.ECDSA.FiniteFields.makeModular(920,3851)
y = Crypto.ECDSA.FiniteFields.makeModular(303,3851)
basePoint = Crypto.ECDSA.EllipticCurves.ConcretePoint(x,y,insecureCurve)

aliceSecretKey = rand(0:255)
bobSecretKey = rand(0:255)

alicePublicKey = aliceSecretKey * basePoint
bobPublicKey = bobSecretKey * basePoint

sharedSecret1 = bobSecretKey * alicePublicKey
sharedSecret2 = aliceSecretKey * bobPublicKey

@test sharedSecret1 == sharedSecret2

# This file is a part of Julia. License is MIT: https://julialang.org/license

using Random

is_effect_free(args...) = Core.Compiler.is_effect_free(Base.infer_effects(args...))

⟷(a::T, b::T) where T <: Union{Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128} = a === b
⟷(a::T, b::T) where T <: BigInt = a == b

@testset "gcd/lcm" begin
    # All Integer data types take different code paths -- test all
    for T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, BigInt)
        @test gcd(T(3)) ⟷ T(3)
        @test gcd(T(3), T(5)) ⟷ T(1)
        @test gcd(T(3), T(15)) ⟷ T(3)
        @test gcd(T(0), T(15)) ⟷ T(15)
        @test gcd(T(15), T(0)) ⟷ T(15)
        if T <: Signed
            @test gcd(T(-12)) ⟷ T(12)
            @test gcd(T(0), T(-15)) ⟷ T(15)
            @test gcd(T(-15), T(0)) ⟷ T(15)
            @test gcd(T(3), T(-15)) ⟷ T(3)
            @test gcd(T(-3), T(-15)) ⟷ T(3)
        end
        @test gcd(T(0), T(0)) ⟷ T(0)

        @test gcd(T(2), T(4), T(6)) ⟷ T(2)
        if T <: Signed
            @test gcd(T(2), T(4), T(-6)) ⟷ T(2)
            @test gcd(T(2), T(-4), T(-6)) ⟷ T(2)
            @test gcd(T(-2), T(4), T(-6)) ⟷ T(2)
            @test gcd(T(-2), T(-4), T(-6)) ⟷ T(2)
        end

        if T != BigInt
            @test gcd(typemax(T), T(1)) === T(1)
            @test gcd(T(1), typemax(T)) === T(1)
            @test gcd(typemax(T), T(0)) === typemax(T)
            @test gcd(T(0), typemax(T)) === typemax(T)
            @test gcd(typemax(T), typemax(T)) === typemax(T)
            @test gcd(typemax(T), typemax(T)-T(1)) === T(1)     # gcd(n, n-1) = 1. n and n-1 are always coprime.
        end

        if T <: Signed && T != BigInt
            @test gcd(-typemax(T), T(1)) === T(1)
            @test gcd(T(1), -typemax(T)) === T(1)
            @test gcd(-typemax(T), T(0)) === typemax(T)
            @test gcd(T(0), -typemax(T)) === typemax(T)
            @test gcd(-typemax(T), -typemax(T)) === typemax(T)
            @test gcd(typemax(T), -typemax(T)) === typemax(T)
            @test gcd(-typemax(T), typemax(T)) === typemax(T)

            @test gcd(typemin(T), T(1)) === T(1)
            @test gcd(T(1), typemin(T)) === T(1)
            @test gcd(typemin(T), typemin(T)+T(1)) === T(1) # gcd(n, n+1) = 1. n and n+1 are always coprime.
            @test_throws OverflowError gcd(typemin(T), typemin(T))
            @test_throws OverflowError gcd(typemin(T), T(0))
            @test_throws OverflowError gcd(T(0), typemin(T))
        elseif T != BigInt
            # For Unsigned Integer types, -typemax(T) == 1.
            @test gcd(-typemax(T), T(1)) === T(1)
            @test gcd(T(1), -typemax(T)) === T(1)
            @test gcd(-typemax(T), T(0)) === T(1)
            @test gcd(T(0), -typemax(T)) === T(1)
            @test gcd(-typemax(T), -typemax(T)) === T(1)
            @test gcd(-typemax(T), typemax(T)) === T(1)
            @test gcd(typemax(T), -typemax(T)) === T(1)

            # For Unsigned Integer types, typemin(T) == 0.
            @test gcd(typemin(T), T(1)) === T(1)
            @test gcd(T(1), typemin(T)) === T(1)
            @test gcd(typemin(T), typemin(T)+T(1)) === T(1) # gcd(n, n+1) = 1. n and n+1 are always coprime.
            @test gcd(typemin(T), typemin(T)) === T(0)
            @test gcd(typemin(T), T(0)) === T(0)
            @test gcd(T(0), typemin(T)) === T(0)
        end

        @test lcm(T(0)) ⟷ T(0)
        @test lcm(T(2)) ⟷ T(2)
        @test lcm(T(2), T(3)) ⟷ T(6)
        @test lcm(T(3), T(2)) ⟷ T(6)
        @test lcm(T(4), T(6)) ⟷ T(12)
        @test lcm(T(6), T(4)) ⟷ T(12)
        @test lcm(T(3), T(0)) ⟷ T(0)
        @test lcm(T(0), T(3)) ⟷ T(0)
        @test lcm(T(0), T(0)) ⟷ T(0)
        if T <: Signed
            @test lcm(T(-12)) ⟷ T(12)
            @test lcm(T(0), T(-4)) ⟷ T(0)
            @test lcm(T(-4), T(0)) ⟷ T(0)
            @test lcm(T(4), T(-6)) ⟷ T(12)
            @test lcm(T(-4), T(-6)) ⟷ T(12)
        end

        @test lcm(T(2), T(4), T(6)) ⟷ T(12)
        @test lcm(T(2), T(4), T(0)) ⟷ T(0)
        if T <: Signed
            @test lcm(T(2), T(4), T(-6)) ⟷ T(12)
            @test lcm(T(2), T(-4), T(-6)) ⟷ T(12)
            @test lcm(T(-2), T(-4), T(-6)) ⟷ T(12)
            @test lcm(T(-2), T(0), T(-6)) ⟷ T(0)
        end

        if T != BigInt
            @test lcm(typemax(T), T(1)) === typemax(T)
            @test lcm(T(1), typemax(T)) === typemax(T)
            @test lcm(typemax(T), T(0)) === T(0)
            @test lcm(T(0), typemax(T)) === T(0)
            @test lcm(typemax(T), typemax(T)) === typemax(T)
            @test_throws OverflowError lcm(typemax(T), typemax(T)-T(1)) # lcm(n, n-1) = n*(n-1). Since n and n-1 are always coprime.
            @test_throws OverflowError lcm(typemax(T), T(2))

            let x = isqrt(typemax(T))+T(1) # smallest number x such that x^2 > typemax(T)
                @test lcm(x, x) === x
                @test_throws OverflowError lcm(x, x+T(1))   # lcm(n, n+1) = n*(n+1). Since n and n+1 are always coprime.
            end

            if T <: Signed
                @test lcm(-typemax(T), T(1)) === typemax(T)
                @test lcm(T(1), -typemax(T)) === typemax(T)
                @test lcm(-typemax(T), T(0)) === T(0)
                @test lcm(T(0), -typemax(T)) === T(0)
                @test lcm(-typemax(T), -typemax(T)) === typemax(T)
                @test lcm(typemax(T), -typemax(T)) === typemax(T)
                @test lcm(-typemax(T), typemax(T)) === typemax(T)

                @test_throws OverflowError lcm(typemin(T), T(1))
                @test_throws OverflowError lcm(T(1), typemin(T))
                @test lcm(typemin(T), T(0)) === T(0)
                @test lcm(T(0), typemin(T)) === T(0)
                @test_throws OverflowError lcm(typemin(T), typemin(T)+T(1)) # lcm(n, n+1) = n*(n+1).
                @test_throws OverflowError lcm(typemin(T), typemin(T))
            else
                # For Unsigned Integer types, -typemax(T) == 1.
                @test lcm(-typemax(T), T(1)) === T(1)
                @test lcm(T(1), -typemax(T)) === T(1)
                @test lcm(-typemax(T), T(0)) === T(0)
                @test lcm(T(0), -typemax(T)) === T(0)
                @test lcm(-typemax(T), -typemax(T)) === T(1)
                @test lcm(-typemax(T), typemax(T)) === typemax(T)
                @test lcm(typemax(T), -typemax(T)) === typemax(T)

                # For Unsigned Integer types, typemin(T) == 0.
                @test lcm(typemin(T), T(1)) === lcm(T(0), T(1)) === T(0)
                @test lcm(T(1), typemin(T)) === T(0)
                @test lcm(typemin(T), T(0)) === T(0)
                @test lcm(T(0), typemin(T)) === T(0)
                @test lcm(typemin(T), typemin(T)) === T(0)
                @test lcm(typemin(T), typemin(T)+T(1)) === T(0)
            end
        end
    end
    @test lcm(0x5, 3) == 15
    @test gcd(0xf, 20) == 5
    @test gcd(UInt32(6), Int8(-50)) == 2
    @test gcd(typemax(UInt), -16) == 1
    @test gcd(typemax(UInt), BigInt(1236189723689716298376189726398761298361892)) == 1

    @testset "effects" begin
        @test is_effect_free(gcd, Tuple{Int,Int})
        @test is_effect_free(lcm, Tuple{Int,Int})
    end
end

@testset "gcd/lcm for arrays" begin
    for T in (Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, BigInt)
        @test gcd(T[]) ⟷ T(0)
        @test gcd(T[3, 5]) ⟷ T(1)
        @test gcd(T[3, 15]) ⟷ T(3)
        @test gcd(T[0, 15]) ⟷ T(15)
        if T <: Signed
            @test gcd(T[-12]) ⟷ T(12)
            @test gcd(T[3,-15]) ⟷ T(3)
            @test gcd(T[-3,-15]) ⟷ T(3)
        end
        @test gcd(T[0, 0]) ⟷ T(0)

        @test gcd(T[2, 4, 6]) ⟷ T(2)
        @test gcd(T[2, 4, 3, 5]) ⟷ T(1)

        @test lcm(T[]) ⟷ T(1)
        @test lcm(T[2, 3]) ⟷ T(6)
        @test lcm(T[4, 6]) ⟷ T(12)
        @test lcm(T[3, 0]) ⟷ T(0)
        @test lcm(T[0, 0]) ⟷ T(0)
        if T <: Signed
            @test lcm(T[-2]) ⟷ T(2)
            @test lcm(T[4, -6]) ⟷ T(12)
            @test lcm(T[-4, -6]) ⟷ T(12)
        end

        @test lcm(T[2, 4, 6]) ⟷ T(12)
    end

    # Issue #55379
    @test lcm([1//2; 1//2]) === lcm([1//2, 1//2]) === lcm(1//2, 1//2) === 1//2
    @test gcd(Int[]) === 0
    @test lcm(Int[]) === 1
    @test gcd(Rational{Int}[]) === 0//1
    @test_throws ArgumentError("lcm has no identity for Rational{$Int}") lcm(Rational{Int}[])
end

⟷(a::Tuple{T, T, T}, b::Tuple{T, T, T}) where T <: Union{Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128} = a === b
⟷(a::Tuple{T, T, T}, b::Tuple{T, T, T}) where T <: BigInt = a == b
@testset "gcdx" begin
    for T in (Int8, Int16, Int32, Int64, Int128, BigInt)
        @test gcdx(T(5), T(12)) ⟷ (T(1), T(5), T(-2))
        @test gcdx(T(5), T(-12)) ⟷ (T(1), T(5), T(2))
        @test gcdx(T(-5), T(12)) ⟷ (T(1), T(-5), T(-2))
        @test gcdx(T(-5), T(-12)) ⟷ (T(1), T(-5), T(2))
        @test gcdx(T(-25), T(-4)) ⟷ (T(1), T(-1), T(6))
        @test gcdx(T(0), T(0)) ⟷ (T(0), T(0), T(0))
        @test gcdx(T(8), T(0)) ⟷ (T(8), T(1), T(0))
        @test gcdx(T(0), T(-8)) ⟷ (T(8), T(0), T(-1))
    end
    x, y = Int8(-12), UInt(100)
    d, u, v = gcdx(x, y)
    @test x*u + y*v == d
end

@testset "gcd/lcm/gcdx for custom types" begin
    struct MyRational <: Real
        val::Rational{Int}
    end
    Base.promote_rule(::Type{MyRational}, T::Type{<:Real}) = promote_type(Rational{Int}, T)
    (T::Type{<:Real})(x::MyRational) = T(x.val)

    @test gcd(MyRational(2//3), 3) == gcd(2//3, 3) == gcd(Real[MyRational(2//3), 3])
    @test lcm(MyRational(2//3), 3) == lcm(2//3, 3) == lcm(Real[MyRational(2//3), 3])
    @test gcdx(MyRational(2//3), 3) == gcdx(2//3, 3)

    # test error path
    struct MyOtherRational <: Real
        val::Rational{Int}
    end
    @test_throws MethodError gcd(MyOtherRational(2//3), MyOtherRational(3//4))
    @test_throws MethodError lcm(MyOtherRational(2//3), MyOtherRational(3//4))
    @test_throws MethodError gcdx(MyOtherRational(2//3), MyOtherRational(3//4))
end

@testset "invmod(n, m)" begin
    @test invmod(6, 31) === 26
    @test invmod(-1, 3) === 2
    @test invmod(1, -3) === -2
    @test invmod(-1, -3) === -1
    @test invmod(0x2, 0x3) === 0x2
    @test invmod(2, 0x3) === UInt(2)
    @test invmod(0x8, -3) === -1
    @test_throws DomainError invmod(0, 3)

    # For issue 29971
    @test invmod(UInt8(1), typemax(UInt8))  === 0x01
    @test invmod(UInt16(1), typemax(UInt16)) === 0x0001
    @test invmod(UInt32(1), typemax(UInt32)) === 0x0000_0001
    @test invmod(UInt64(1), typemax(UInt64)) === 0x0000_0000_0000_0001

    for T in (UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, BigInt)
        @test invmod(T(3), T(124))::T == 83
    end

    for T in (Int8, Int16, Int32, Int64, Int128)
        @test invmod(T(3), unsigned(T)(124)) == 83
    end

    # Verify issue described in PR 58010 is fixed
    @test invmod(UInt8(3), UInt16(50000)) === 0x411b

    for T in (Int8, UInt8)
        for x in typemin(T):typemax(T)
            for m in typemin(T):typemax(T)
                if m != 0 && try gcdx(x, m)[1] == 1 catch _ true end
                    y = invmod(x, m)
                    @test mod(widemul(y, x), m) == mod(1, m)
                    @test div(y, m) == 0
                else
                    @test_throws DomainError invmod(x, m)
                end
            end
        end
    end
end

@testset "invmod(n)" begin
    for T in (Int8,UInt8,Int16,UInt16,Int32,UInt32,Int64,UInt64,Int128,UInt128)
        if sizeof(T) ≤ 2
            # test full domain for small types
            for a = typemin(T)+true:T(2):typemax(T)
                b = invmod(a)
                @test a * b == 1
            end
        else
            # test random sample for large types
            for _ = 1:2^12
                a = rand(T) | true
                b = invmod(a)
                @test a * b == 1
            end
        end
    end
end

@testset "invmod(n, T)" begin
    for S in (Int8,UInt8,Int16,UInt16,Int32,UInt32,Int64,UInt64,Int128,UInt128),
        T in (Int8,UInt8,Int16,UInt16,Int32,UInt32,Int64,UInt64,Int128,UInt128)
        for _ = 1:2^8
            a = rand(S) | true
            b = invmod(a, T)
            @test (a * b) % T == 1
            @test (a % T) * b == 1
        end
    end
end

@testset "powermod" begin
    @test powermod(2, 3, 5) == 3
    @test powermod(2, 3, -5) == -2

    @test powermod(2, 0, 5) == 1
    @test powermod(2, 0, -5) == -4

    @test powermod(2, -1, 5) == 3
    @test powermod(2, -2, 5) == 4
    @test powermod(2, -1, -5) == -2
    @test powermod(2, -2, -5) == -1

    @test powermod(2, typemin(Int128), 5) == 1
    @test powermod(2, typemin(Int128), -5) == -4

    @test powermod(2, big(3), 5) == 3
    @test powermod(2, big(3), -5) == -2
    @inferred  powermod(2, -2, -5)
    @inferred  powermod(big(2), -2, UInt(5))
end

@testset "nextpow/prevpow" begin
    fs = (prevpow, nextpow)
    types = (Int8, BigInt, BigFloat)
    for f ∈ fs, P ∈ types, R ∈ types, p ∈ 1:20, r ∈ 2:5
        q = P(p)
        n = R(r)
        @test f(r, p) == f(n, q)
    end

    @test nextpow(2, 3) == 4
    @test nextpow(2, 4) == 4
    @test nextpow(2, 7) == 8
    @test_throws DomainError nextpow(0, 3)
    @test_throws DomainError nextpow(3, 0)

    @test prevpow(2, 3) == 2
    @test prevpow(2, 4) == 4
    @test prevpow(2, 5) == 4
    @test prevpow(Int64(10), Int64(1234567890123456789)) === Int64(1000000000000000000)
    @test prevpow(10, 101.0) === 100
    @test prevpow(10.0, 101) === 100.0
    @test_throws DomainError prevpow(0, 3)
    @test_throws DomainError prevpow(3, 0)

    # "argument is beyond the range of type of the base"
    @test_throws DomainError prevpow(Int8(3), 243)
    @test_throws DomainError nextpow(Int8(3), 243)

    # "result is beyond the range of type of the base"
    @test_throws OverflowError nextpow(Int8(3), 82)
end

@testset "ndigits/ndigits0z" begin
    @testset "issue #8266" begin
        @test ndigits(-15, base=10) == 2
        @test ndigits(-15, base=-10) == 2
        @test ndigits(-1, base=10) == 1
        @test ndigits(-1, base=-10) == 2
        @test ndigits(2, base=10) == 1
        @test ndigits(2, base=-10) == 1
        @test ndigits(10, base=10) == 2
        @test ndigits(10, base=-10) == 3
        @test ndigits(17, base=10) == 2
        @test ndigits(17, base=-10) == 3
        @test ndigits(unsigned(17), base=-10) == 3

        @test ndigits(146, base=-3) == 5
    end
    @testset "ndigits with base power of 2" begin
        @test ndigits(17, base = 2) == 5
        @test ndigits(123, base = 4) == 4
        @test ndigits(64, base = 8) == 3
        @test ndigits(8436, base = 16) == 4
        @test ndigits(159753, base = 32) == 4
        @test ndigits(3578951, base = 64) == 4
    end
    let (n, b) = rand(Int, 2)
        -1 <= b <= 1 && (b = 2) # invalid bases
        @test ndigits(n) == ndigits(big(n)) == ndigits(n, base=10)
        @test ndigits(n, base=b) == ndigits(big(n), base=b)
    end

    for b in -1:1
        @test_throws DomainError ndigits(rand(Int), base=b)
    end
    @test ndigits(Int8(5)) == ndigits(5)

    # issue #19367
    @test ndigits(Int128(2)^64, base=256) == 9

    # test unsigned bases
    @test ndigits(9, base=0x2) == 4
    @test ndigits(0x9, base=0x2) == 4

    # ndigits is defined for Bool
    @test iszero([Base.ndigits0z(false, b) for b in [-20:-2;2:20]])
    @test all(n -> n == 1, Base.ndigits0z(true, b) for b in [-20:-2;2:20])
    @test all(n -> n == 1, ndigits(x, base=b) for b in [-20:-2;2:20] for x in [true, false])

    # issue #29148
    @test ndigits(typemax(UInt64), base=-2) == ndigits(big(typemax(UInt64)), base=-2)
    for T in Base.BitInteger_types
        n = rand(T)
        b = -rand(2:100)
        @test ndigits(n, base=b) == ndigits(big(n), base=b)
    end

end

primitive type BitString128 128 end

@testset "bin/oct/dec/hex/bits" begin
    @test string(UInt32('3'), base = 2) == "110011"
    @test string(UInt32('3'), pad = 7, base = 2) == "0110011"
    @test string(3, base = 2) == "11"
    @test string(3, pad = 2, base = 2) == "11"
    @test string(3, pad = Int32(2), base = Int32(2)) == "11"
    @test string(3, pad = typemin(Int128) + 3, base = 0x2) == "11"
    @test string(3, pad = 3, base = 2) == "011"
    @test string(-3, base = 2) == "-11"
    @test string(-3, pad = 3, base = 2) == "-011"

    @test string(9, base = 8) == "11"
    @test string(-9, base = 8) == "-11"
    @test string(-9, base = 8, pad = 5) == "-00011"
    @test string(-9, base = 8, pad = Int32(5)) == "-00011"

    @test string(121, base = 10) == "121"
    @test string(121, base = 10, pad = 5) == "00121"
    @test string(121, base = 10, pad = 5) == "00121"

    @test string(12, base = 16) == "c"
    @test string(-12, pad = 3, base = 16) == "-00c"
    @test string(-12, pad = Int32(3), base = Int32(16)) == "-00c"

    @test string(5, pad = 7, base = 2) == "0000101"

    @test bitstring(Int16(3)) == "0000000000000011"
    @test bitstring('3') == "00110011000000000000000000000000"
    @test bitstring(1035) == (Int == Int32 ? "00000000000000000000010000001011" :
        "0000000000000000000000000000000000000000000000000000010000001011")
    @test bitstring(Int128(3)) == "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011"
    @test bitstring(reinterpret(BitString128, Int128(3))) == "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011"
end

@testset "digits/base" begin
    @test digits(5, base = 3) == [2, 1]
    @test digits(5, pad = 3) == [5, 0, 0]
    @test digits(5, pad = Int32(3)) == [5, 0, 0]
    # The following have bases powers of 2, but don't enter the fast path
    @test digits(-3, base = 2) == -[1, 1]
    @test digits(-42, base = 4) == -[2, 2, 2]

    @test_throws DomainError string(5, base = typemin(Int128) + 10)

    @testset "digits/base with bases powers of 2" begin
        @test digits(4, base = 2) == [0, 0, 1]
        @test digits(5, base = Int32(2), pad=Int32(3)) == [1, 0, 1]
        @test digits(42, base = 4) == [2, 2, 2]
        @test digits(321, base = 8) == [1, 0, 5]
        @test digits(0x123456789abcdef, base = 16) == 15:-1:1
        @test digits(0x2b1a210a750, base = 64) == [16, 29, 10, 4, 34, 6, 43]
        @test digits(0x02a01407, base = Int128(1024)) == [7, 5, 42]
    end

    @testset "digits/base with negative bases" begin
        @testset "digits(n::$T, base = b)" for T in (Int, UInt, BigInt, Int32, UInt32)
            @test digits(T(8163), base = -10) == [3, 4, 2, 2, 1]
            if !(T<:Unsigned)
                @test digits(T(-8163), base = -10) == [7, 7, 9, 9]
            end
            if T !== BigInt
                b = rand(-32:-2)
                for n = T[rand(T), typemax(T), typemin(T)]
                    # issue #29183
                    @test digits(n, base=b) == digits(signed(widen(n)), base=b)
                end
            end
        end
        @test [string(n, base = b)
               for n = [-10^9, -10^5, -2^20, -2^10, -100, -83, -50, -34, -27, -16, -7, -3, -2, -1,
                        0, 1, 2, 3, 4, 7, 16, 27, 34, 50, 83, 100, 2^10, 2^20, 10^5, 10^9]
               for b = [-2, -3, -7, -10, -60]] ==
                   ["11000101101001010100101000000000", "11211100201202120012",
                    "144246601121", "1000000000", "2hANlK", "111000111010100000",
                    "122011122112", "615462", "100000", "1XlK", "1100000000000000000000",
                    "11000202101022", "25055043", "19169584", "59Hi", "110000000000",
                    "12102002", "3005", "1036", "Iu", "11101100", "121112", "1515",
                    "1900", "2K", "11111101", "120011", "1651", "97", "2b", "11010010",
                    "2121", "1616", "50", "1A", "100010", "2202", "51", "46", "1Q",
                    "100101", "1000", "41", "33", "1X", "110000", "1102", "35", "24",
                    "1i", "1001", "1202", "10", "13", "1r", "1101", "10", "14", "17",
                    "1v", "10", "11", "15", "18", "1w", "11", "12", "16", "19", "1x", "0",
                    "0", "0", "0", "0", "1", "1", "1", "1", "1", "110", "2", "2", "2",
                    "2", "111", "120", "3", "3", "3", "100", "121", "4", "4", "4",
                    "11011", "111", "160", "7", "7", "10000", "211", "152", "196", "G",
                    "1101111", "12000", "146", "187", "R", "1100110", "12111", "136",
                    "174", "Y", "1110110", "11022", "101", "150", "o", "1010111", "10002",
                    "236", "123", "1xN", "110100100", "10201", "202", "100", "1xe",
                    "10000000000", "2211011", "14012", "19184", "1h4",
                    "100000000000000000000", "2001112212121", "162132144", "1052636",
                    "1uqiG", "1101001101111100000", "21002022201", "1103425", "1900000",
                    "SEe", "1001100111011111101111000000000", "120220201100111010001",
                    "44642116066", "19000000000", "1xIpcEe"]
    end
end

@testset "leading_ones, count_zeros, etc." begin
    @test leading_ones(UInt32(Int64(2) ^ 32 - 2)) == 31
    @test leading_ones(1) == 0
    @test leading_zeros(Int32(1)) == 31
    @test leading_zeros(UInt32(Int64(2) ^ 32 - 2)) == 0

    @test Base.top_set_bit(3) == 2
    @test Base.top_set_bit(-Int64(17)) == 64
    @test Base.top_set_bit(big(15)) != Base.top_set_bit(big(16)) == Base.top_set_bit(big(17)) == 5
    @test_throws DomainError Base.top_set_bit(big(-17))

    struct MyInt <: Integer
        x::Int
    end
    MyInt(x::MyInt) = x
    Base.:+(a::MyInt, b::MyInt) = a.x + b.x

    for n in 0:100
        x = ceil(Int, log2(n + 1))
        @test x == Base.top_set_bit(Int128(n)) == Base.top_set_bit(unsigned(Int128(n)))
        @test x == Base.top_set_bit(Int32(n)) == Base.top_set_bit(unsigned(Int64(n)))
        @test x == Base.top_set_bit(Int8(n)) == Base.top_set_bit(unsigned(Int8(n)))
        @test x == Base.top_set_bit(big(n))   # BigInt fallback
        @test x == Base.top_set_bit(MyInt(n)) # generic fallback
    end

    for n in -10:-1
        @test 128 == Base.top_set_bit(Int128(n)) == Base.top_set_bit(unsigned(Int128(n)))
        @test 32  == Base.top_set_bit(Int32(n)) == Base.top_set_bit(unsigned(Int32(n)))
        @test 8   == Base.top_set_bit(Int8(n)) == Base.top_set_bit(unsigned(Int8(n)))
        @test_throws DomainError Base.top_set_bit(big(n))
        # This error message should never be exposed to the end user anyway.
        err = n == -1 ? InexactError : DomainError
        @test_throws err Base.top_set_bit(MyInt(n))
    end

    @test count_zeros(Int64(1)) == 63
end

@testset "factorial" begin
    @test factorial(3) == 6
    @test factorial(Int8(3)) === 6
    @test_throws DomainError factorial(-3)
    @test_throws DomainError factorial(Int8(-3))
end

@testset "isqrt" begin
    @test isqrt(4) == 2
    @test isqrt(5) == 2
    @test isqrt(Int8(4)) === Int8(2)
    @test isqrt(Int8(5)) === Int8(2)
end

@testset "issue #4884" begin
    @test isqrt(9223372030926249000) == 3037000498
    @test isqrt(typemax(Int128)) == parse(Int128,"13043817825332782212")
    @test isqrt(Int128(typemax(Int64))^2-1) == 9223372036854775806
    @test isqrt(0) == 0
    for i = 1:1000
        n = rand(UInt128)
        s = isqrt(n)
        @test s*s <= n
        @test (s+1)*(s+1) > n
        n = rand(UInt64)
        s = isqrt(n)
        @test s*s <= n
        @test (s+1)*(s+1) > n
    end
end

# issue #9786
let ptr = Ptr{Cvoid}(typemax(UInt))
    for T in (Int, Cssize_t)
        @test T(ptr) == -1
        @test ptr == Ptr{Cvoid}(T(ptr))
        @test typeof(Ptr{Float64}(T(ptr))) == Ptr{Float64}
    end
end

# issue #15911
@inferred string(1)

# issue #22837
for b in [-100:-2; 2:100;]
    @test Base.ndigits0z(0, b) == 0
end

@testset "constant prop in gcd" begin
    ci = code_typed(() -> gcd(14, 21))[][1]
    @test ci.code == Any[Core.ReturnNode(7)]

    ci = code_typed(() -> 14 // 21)[][1]
    @test ci.code == Any[Core.ReturnNode(2 // 3)]
end
@testset "binomial" begin
    for T in (Int8, Int16, Int32, Int64)
        for x in rand(-isqrt(typemax(T)):isqrt(typemax(T)), 1000)
            @test binomial(x,T(1)) == x
            x>=0 && @test binomial(x,x-T(1)) == x
            @test binomial(x,T(2)) == div(x*(x-1), 2)
            x>=0 && @test binomial(x,x-T(2)) == div(x*(x-1), 2)
        end
        @test @inferred(binomial(one(T),one(T))) isa T

        # Arguments of different Integer types do not lead to computation of
        # generalized binomial coefficient (issue #54296)
        @test @inferred(binomial(Int64(5), T(2))) === Int64(10)
    end
    for x in ((false,false), (false,true), (true,false), (true,true))
        @test binomial(x...) == (x != (false,true))
    end

    # binomial(x,k) for non-integer x
    @test @inferred(binomial(10.0,3)) === 120.0
    @test @inferred(binomial(10//1,3)) === 120//1
    @test binomial(2.5,3) ≈ 5//16 === binomial(5//2,3)
    @test binomial(2.5,0) == 1.0
    @test binomial(35.0, 30) ≈ binomial(35, 30) # naive method overflows
    @test binomial(2.5,-1) == 0.0
end

# concrete-foldability
@test Base.infer_effects(gcd, (Int,Int)) |> Core.Compiler.is_foldable
@test Base.infer_effects(gcdx, (Int,Int)) |> Core.Compiler.is_foldable
@test Base.infer_effects(invmod, (Int,Int)) |> Core.Compiler.is_foldable
@test Base.infer_effects(binomial, (Int,Int)) |> Core.Compiler.is_foldable
@testset "concrete-foldability: `hastypemax`" begin
    @test Base.infer_effects(Base.hastypemax, (Type,)) |> Core.Compiler.is_foldable
    @test Base.infer_effects(Base.hastypemax, (DataType,)) |> Core.Compiler.is_foldable
    for t in (Bool, Int, BigInt)
        @test Base.infer_effects(Base.hastypemax, (Type{t},)) |> Core.Compiler.is_foldable
    end
end

@testset "`hastypemax`" begin
    @test Base.hastypemax(Bool)
    @test Base.hastypemax(Int)
    @test !Base.hastypemax(BigInt)
end

@testset "literal power" begin
    @testset for T in Base.uniontypes(Base.HWReal)
        ns = (T(0), T(1), T(5))
        if T <: AbstractFloat
            ns = (ns..., T(3.14), T(-2.71))
        end
        for n in ns
            @test n ^ 0 === T(1)
            @test n ^ 1 === n
            @test n ^ 2 === n * n
            @test n ^ 3 === n * n * n
            @test n ^ -1 ≈ inv(n)
            @test n ^ -2 ≈ inv(n) * inv(n)
        end
    end
end

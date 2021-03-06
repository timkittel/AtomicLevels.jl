using Random

@testset "Orbitals" begin
    @testset "kappa" begin
        import AtomicLevels: assert_orbital_ℓj
        @test assert_orbital_ℓj(0, hi"1/2") === nothing
        @test assert_orbital_ℓj(1, hi"1/2") === nothing
        @test assert_orbital_ℓj(1, 3//2) === nothing
        @test assert_orbital_ℓj(2, 2.5) === nothing
        @test_throws ArgumentError assert_orbital_ℓj(0, 0)
        @test_throws ArgumentError assert_orbital_ℓj(0, 1)
        @test_throws ArgumentError assert_orbital_ℓj(0, 3//2)
        @test_throws ArgumentError assert_orbital_ℓj(5, 1//2)
        @test_throws MethodError assert_orbital_ℓj(hi"1", hi"1/2")

        import AtomicLevels: kappa_to_ℓ
        @test_throws ArgumentError kappa_to_ℓ(0)
        @test kappa_to_ℓ(-1) == 0
        @test kappa_to_ℓ( 1) == 1
        @test kappa_to_ℓ(-2) == 1
        @test kappa_to_ℓ( 2) == 2
        @test kappa_to_ℓ(-3) == 2
        @test kappa_to_ℓ( 3) == 3

        import AtomicLevels: kappa_to_j
        @test_throws ArgumentError kappa_to_j(0)
        @test kappa_to_j(-1) == 1//2
        @test kappa_to_j( 1) == 1//2
        @test kappa_to_j(-2) == 3//2
        @test kappa_to_j( 2) == 3//2
        @test kappa_to_j(-3) == 5//2
        @test kappa_to_j( 3) == 5//2

        import AtomicLevels: ℓj_to_kappa
        @test ℓj_to_kappa(0, hi"1/2") == -1
        @test κ"s" == -1
        @test ℓj_to_kappa(1, hi"1/2") == 1
        @test κ"p-" == 1
        @test ℓj_to_kappa(1, 3//2) == -2
        @test κ"p" == -2
        @test ℓj_to_kappa(2, 3//2) == 2
        @test κ"d-" == 2
        @test ℓj_to_kappa(2, 5//2) == -3
        @test κ"d" == -3
        @test ℓj_to_kappa(3, 5//2) == 3
        @test κ"f-" == 3
        @test ℓj_to_kappa(3, 7//2) == -4
        @test κ"f" == -4
        @test_throws ArgumentError ℓj_to_kappa(0, hi"3/2")
        @test_throws ArgumentError ℓj_to_kappa(0, 0)
        @test_throws ArgumentError ℓj_to_kappa(6, 1//2)
    end

    @testset "Construction" begin
        @test o"1s"   == Orbital(1, 0)
        @test o"2p"   == Orbital(2, 1)
        @test o"2[1]" == Orbital(2, 1)

        @test ro"1s"   == RelativisticOrbital(1, -1) # κ=-1 => s orbital
        @test ro"2p-"  == RelativisticOrbital(2,  1, hi"1/2")
        @test ro"2p-"  == RelativisticOrbital(2,  1, 1//2)
        @test ro"2p"   == RelativisticOrbital(2,  1, 3//2)
        @test ro"2[1]" == RelativisticOrbital(2,  1, 3//2)

        @test o"kp" == Orbital(:k,1)
        @test o"ϵd" == Orbital(:ϵ,2)

        @test ro"kp"  == RelativisticOrbital(:k, 1, 3//2)
        @test ro"ϵd-" == RelativisticOrbital(:ϵ, 2, 3//2)

        @test_throws ArgumentError AtomicLevels.orbital_from_string(Orbital, "2p-")
        @test_throws ArgumentError AtomicLevels.orbital_from_string(Orbital, "sdkfl")

        @test_throws ArgumentError Orbital(0, 0)
        @test_throws ArgumentError Orbital(1, 1)
        @test_throws ArgumentError RelativisticOrbital(0, 0)
        @test_throws ArgumentError RelativisticOrbital(1, 1)
        @test_throws ArgumentError RelativisticOrbital(1, 0, 3//2)
    end

    @testset "Order" begin
        @test sort(shuffle([o"1s", o"2s", o"2p", o"3s", o"3p"])) ==
            [o"1s", o"2s", o"2p", o"3s", o"3p"]
        @test sort([o"ls", o"kp", o"2p", o"1s"]) ==
            [o"1s", o"2p", o"kp", o"ls"]

        @test sort(shuffle([ro"1s", ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p"])) ==
            [ro"1s", ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p"]
        @test sort([ro"ls", ro"kp", ro"2p", ro"1s"]) ==
            [ro"1s", ro"2p", ro"kp", ro"ls"]
    end

    @testset "Range of orbitals" begin
        @test os"6[s-d] 5[d]" == [o"5d", o"6s", o"6p", o"6d"]
        @test os"k[s-g] l[s-g]" == [o"ks", o"kp", o"kd", o"kf", o"kg",
                                    o"ls", o"lp", o"ld", o"lf", o"lg"]

        @test ros"6[s-d] 5[d]" == [ro"5d-", ro"5d", ro"6s", ro"6p-", ro"6p", ro"6d-", ro"6d"]
        @test ros"k[s-g] l[s-g]" == [ro"ks", ro"kp-", ro"kp", ro"kd-", ro"kd", ro"kf-", ro"kf", ro"kg-", ro"kg",
                                     ro"ls", ro"lp-", ro"lp", ro"ld-", ro"ld", ro"lf-", ro"lf", ro"lg-", ro"lg"]
    end

    @testset "Flip j" begin
        @test AtomicLevels.flip_j(ro"1s") == ro"1s"
        @test AtomicLevels.flip_j(ro"2p-") == ro"2p"
        @test AtomicLevels.flip_j(ro"2p") == ro"2p-"
        @test AtomicLevels.flip_j(ro"3d-") == ro"3d"
        @test AtomicLevels.flip_j(ro"3d") == ro"3d-"

        @test AtomicLevels.flip_j(ro"kd-") == ro"kd"
        @test AtomicLevels.flip_j(ro"kd") == ro"kd-"
    end

    @testset "Degeneracy" begin
        @test degeneracy(o"1s") == 2
        @test degeneracy(o"2p") == 6
        @test degeneracy(o"3d") == 10

        @test degeneracy(o"kp") == 6

        @test degeneracy(ro"1s") == 2
        @test degeneracy(ro"2p-") == 2
        @test degeneracy(ro"2p") == 4
        @test degeneracy(ro"3d-") == 4
        @test degeneracy(ro"3d") == 6

        @test degeneracy(ro"kp-") == 2
        @test degeneracy(ro"kp") == 4
    end

    @testset "Parity" begin
        @test iseven(parity(o"1s"))
        @test isodd(parity(o"2p"))
        @test iseven(parity(o"3s"))
        @test isodd(parity(o"3p"))
        @test iseven(parity(o"3d"))

        @test isodd(parity(o"kp"))

        @test iseven(parity(ro"1s"))
        @test isodd(parity(ro"2p"))
        @test iseven(parity(ro"3s"))
        @test isodd(parity(ro"3p"))
        @test iseven(parity(ro"3d"))

        @test isodd(parity(ro"kp"))
    end

    @testset "Symmetry" begin
        @test symmetry(o"1s") == 0
        @test symmetry(o"2s") == symmetry(o"1s")
        @test symmetry(o"2s") != symmetry(o"2p")

        @test symmetry(ro"1s") == symmetry(ro"2s")
        @test symmetry(ro"2p") == symmetry(ro"3p")
        @test symmetry(ro"2p") != symmetry(ro"2p-")
    end

    @testset "Bound" begin
        @test isbound(o"1s")
        @test isbound(o"3d")
        @test isbound(ro"1s")
        @test isbound(ro"3d")
        @test !isbound(o"ks")
        @test !isbound(o"ϵd")
        @test !isbound(ro"ks")
        @test !isbound(ro"ϵd")
    end

    @testset "Magnetic quantum numbers" begin
        @test mℓrange(o"1s") == 0:0
        @test mℓrange(o"2p") == -1:1
        @test mℓrange(o"3d") == -2:2
    end

    @testset "Spin orbitals" begin
        @test_throws ArgumentError SpinOrbital(o"1s", 1, true)
        @test_throws ArgumentError SpinOrbital(o"ks", 1, true)
        @test_throws ArgumentError SpinOrbital(o"2p", -3, true)

        soα = SpinOrbital(o"1s", 0, true)
        soβ = SpinOrbital(o"1s", 0, false)

        po₋α = SpinOrbital(o"2p", -1, true)
        po₀α = SpinOrbital(o"2p", 0, true)
        po₊α = SpinOrbital(o"2p", 1, true)
        po₋β = SpinOrbital(o"2p", -1, false)
        po₀β = SpinOrbital(o"2p", 0, false)
        po₊β = SpinOrbital(o"2p", 1, false)

        @test degeneracy(soα) == 1
        @test soα < soβ

        @test parity(soα) == parity(soβ) == p"even"

        @test parity(po₋α) == p"odd"
        @test parity(po₀α) == p"odd"
        @test parity(po₊α) == p"odd"
        @test parity(po₋β) == p"odd"
        @test parity(po₀β) == p"odd"
        @test parity(po₊β) == p"odd"

        @test symmetry(soα) != symmetry(soβ)

        @test symmetry(po₋α) != symmetry(po₀α)
        @test symmetry(po₋α) != symmetry(po₊α)
        @test symmetry(po₊α) != symmetry(po₀α)

        @test symmetry(po₋β) != symmetry(po₀β)
        @test symmetry(po₋β) != symmetry(po₊β)
        @test symmetry(po₊β) != symmetry(po₀β)

        @test symmetry(po₋α) != symmetry(po₋β)
        @test symmetry(po₀α) != symmetry(po₀β)
        @test symmetry(po₊α) != symmetry(po₊β)

        @test symmetry(po₋α) == symmetry(SpinOrbital(o"3p", -1, true))

        @test isbound(soα)
        @test !isbound(SpinOrbital(o"ks", 0, true))

        @test spin_orbitals(o"1s") == [soα, soβ]
        @test spin_orbitals(o"2p") == [po₋α, po₋β, po₀α, po₀β, po₊α, po₊β]
        for orb in [o"1s", o"2p", o"3d", o"4f", o"5g"]
            @test length(spin_orbitals(orb)) == degeneracy(orb)
        end

        @test "$(soα)" == "1s₀α"
        @test "$(po₊β)" == "2p₁β"
    end
end

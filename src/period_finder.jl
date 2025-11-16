function period_finder(b::Billiard, v::Vector{Int64})
    S = I
    u = nothing
    for i in v
        t = b.faces[i].normal
        S *= (I - 2 .* (t * t'))
    end

    data = eigen(S)
    for i in 1:length(data.values)
        if data.values[i] ≈ 1 && all(imag.(data.vectors[:, i]) .≈ 0)
            u = real.(data.vectors[:, i])
            break
        end
    end

    A = b.faces[v[1]]
    Sa = (I - 2 .* (A.normal * A.normal'))

    if isnothing(u)
        println("No periodic orbit found!")
        return nothing, nothing
    end

    if dot(u, A.normal) > 0
        u = -u
    end

    μ = A.r0 - Sa * A.r0
    s = Sa * b.faces[v[2]].r0 + μ
    N = s - S * b.faces[v[2]].r0

    M = [(S-I) -u; A.normal' 0.0]
    rhs = [-N; dot(A.normal, A.r0)]

    sol = M \ rhs
    m = sol[1:3]
    λ = sol[4]

    if on_surface(A, m)
        return (m, u)
    end
    println("Periodic orbit found!")
    return nothing, nothing
end

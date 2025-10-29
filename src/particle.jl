epsilon = 1e-6

# Particle3D Struct
mutable struct Particle3D
    position::Vector{Float64}
    velocity::Vector{Float64}

    function Particle3D(position::Vector{Float64}, velocity::Vector{Float64})
        new(position, velocity ./ norm(velocity))
    end
end


function evolve!(billiard::Billiard, particle::Particle3D)
    t_min = Inf
    colliding_normals = []
    for face in billiard.faces
        denom = dot(face.normal, particle.velocity)
        if abs(denom) < epsilon
            continue
        end
        new_t = dot(face.normal, face.r0 - particle.position) / denom
        # println("face normal: $(face.normal), new_t=$new_t, denom=$denom")
        # println("t: $new_t , pos: $(particle.position .+ new_t .* particle.velocity) , bool: $(on_surface(face, particle.position .+ new_t .* particle.velocity))")
        if new_t > epsilon && on_surface(face, particle.position .+ new_t .* particle.velocity)
            if abs(new_t - t_min) < epsilon
                push!(colliding_normals, face.normal)

            elseif new_t < t_min
                t_min = new_t
                colliding_normals = [face.normal] # Reset the list
            end
        end
    end

    if isinf(t_min)
        return nothing
    end
    particle.position .+= t_min .* particle.velocity

    n = zeros(3)
    if length(colliding_normals) == 1
        n = colliding_normals[1]
        n /= norm(n)
        particle.velocity = particle.velocity - 2 * dot(particle.velocity, n) * n
    elseif length(colliding_normals) == 2
        for n1 in colliding_normals[1:end]
            n += n1
        end
        n /= norm(n)
        particle.velocity = particle.velocity - 2 * dot(particle.velocity, n) * n
    elseif length(colliding_normals) > 2
        particle.velocity = -particle.velocity
    end

    return (particle.position, particle.velocity)
end

function evolve!(billiard::Billiard, particle::Particle3D, t::Int)
    poss = Vector{Vector{Float64}}()
    vels = Vector{Vector{Float64}}()
    # println("intersection: $(particle.position) | velocity: $(particle.velocity) | norm: $(norm(particle.velocity))")

    push!(poss, copy(particle.position))
    push!(vels, copy(particle.velocity))

    for i in 1:t
        pos, vel = evolve!(billiard, particle)
        # println("intersection: $pos | velocity: $vel | norm: $(norm(vel))")
        push!(poss, copy(pos))
        push!(vels, copy(vel))
    end

    return (poss, vels)
end

function time_matrix(billiard::Billiard, particle::Particle3D, t::Int)
    state_vector = []
    for _ in 1:t
        evolve!(billiard, particle)
        push!(state_vector, vcat(particle.position, particle.velocity)')
    end

    return reduce(vcat, state_vector)
end

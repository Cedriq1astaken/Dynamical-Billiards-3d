using Base: base36digits
using DrWatson
@quickactivate "DynamicalBilliards3d"
include(srcdir("loader.jl"))

function find_periodic_orbit(base_state, tetrahedron; max_attempts=500, n_bounces=100)
    best_state = copy(base_state)
    best_d, _ = is_periodic(time_matrix(tetrahedron, Particle3D(base_state[1:3], base_state[4:6]), n_bounces))

    for scale in [1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9, 1e-10, 1e-11, 1e-12, 1e-13, 1e-14, 1e-15, 1e-16, 1e-17, 1e-18, 1e-19, 1e-20]
        for _ in 1:max_attempts
            trial = best_state .+ (rand(6) .- 0.5) .* (2 * scale)
            p = Particle3D(trial[1:3], trial[4:6])
            d, period = is_periodic(time_matrix(tetrahedron, p, n_bounces))
            if d < best_d
                best_d = d
                best_state = trial
                println("Improved at scale=$scale, d=$d, period=$period")
                if d < 1e-9
                    println("Periodic orbit found, period=$period")
                    return best_state
                end
            end
        end
    end
    return best_state
end

base_state = [0.0, 0.0, -0.19, 1.0, 2.0, 0.0]

tetrahedron = Tetrahedron([0.0, 0.0, 0.0], [[1.0, 1.0, 1.0], [1.0, -1.0, -1.0], [-1.0, 1.0, -1.0], [-1.0, -1.0, 1.0]])


base_state = find_periodic_orbit(base_state, tetrahedron, max_attempts=1000)

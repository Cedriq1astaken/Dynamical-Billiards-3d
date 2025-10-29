function is_periodic(state_vector::Matrix{Float64}, ϵ::Float64=1e-6)
    min_distance = Inf
    best_period = 0
    n_states = size(state_vector, 1)

    for i in 2:n_states
        for j in 1:(i-1)
            pos_i, vel_i = state_vector[i, 1:3], state_vector[i, 4:6]
            pos_j, vel_j = state_vector[j, 1:3], state_vector[j, 4:6]

            vel_i_norm = vel_i / norm(vel_i)
            vel_j_norm = vel_j / norm(vel_j)

            pos_dist = norm(pos_i - pos_j)
            vel_dist = norm(vel_i_norm - vel_j_norm)

            total_dist = pos_dist + vel_dist

            if total_dist < min_distance
                min_distance = total_dist
                best_period = i - j
            end
        end
    end

    return min_distance, best_period
end


function lyapunov_exponent(billiard::Billiard, partical::Particle3D)
    return 0.0
end

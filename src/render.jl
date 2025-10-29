function animate(poss::Vector{Vector{Float64}})
    final = Vector{Vector{Float64}}()
    K = 100.0

    for j in 1:length(poss)-1
        p1 = poss[j]
        p2 = poss[j+1]

        d = norm(p2 - p1)
        n_steps = clamp(Int(round(d * K)), 2, 50)

        for t in range(0, 1, length=n_steps)
            r = (1 - t) .* p1 .+ t .* p2
            push!(final, copy(r))
        end
    end

    return final
end

function visualize(billiard::Billiard, p::Particle3D)
    f = Figure(backgroundcolor=RGBf(1.0, 1.0, 1.0), size=(1000, 1000))
    ax = LScene(f[1, 1])

    sphere = Observable(Sphere(Point3f(p.position), 0.01f0))
    points = Observable([Point3f(p.position)])

    mesh!(ax, to_mesh(billiard), color=(0.4, 0.4, 0.4, 0.1), transparency=true)
    wireframe!(ax, to_mesh(billiard), color=:black, linewidth=1)
    mesh!(ax, sphere, color=(1.0, 0.0, 0.0, 1.0))
    lines!(ax, points, color=:red, linewidth=2)

    poss, vels = evolve!(billiard, p, 100)
    # println(is_periodic(poss, vels))

    poss = animate(poss)

    display(f)

    for i = 1:length(poss)
        sphere[] = Sphere(Point3f(poss[i]), 0.01f0)
        push!(points[], Point3f(poss[i]))
        points[] = points[]
        sleep(1 / 60)  # ~60 FPS
    end
end

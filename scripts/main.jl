using DrWatson
@quickactivate "DynamicalBilliards3d"
include(srcdir("loader.jl"))

cube = Cuboid([0.0, 0.0, 0.0], 1.0, 2.0, 1.0)
tetrahedron = Tetrahedron([0.0, 0.0, 0.0], [[1.0, 1.0, 1.0], [1.0, -1.0, -1.0], [-1.0, 1.0, -1.0], [-1.0, -1.0, 1.0]])
start = [0.0, 0.0, 0.0]
velocity = [1.0, 2.115, -0.05]

p = Particle3D(copy(start), copy(velocity))
println("Period: $(is_periodic(time_matrix(tetrahedron, p, 100)))")
p = Particle3D(copy(start), copy(velocity))
visualize(tetrahedron, p)

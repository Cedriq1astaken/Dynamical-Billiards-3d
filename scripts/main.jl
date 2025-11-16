using DrWatson
@quickactivate "DynamicalBilliards3d"
include(srcdir("loader.jl"))

cube = Cuboid([0.0, 0.0, 0.0], 1.0, 2.0, 1.0)
tetrahedron = Tetrahedron([0.0, 0.0, 0.0], [[-1.0, -1.0, -1.0], [1.0, -1.0, 1.0], [1.0, 1.0, -1.0], [-1.0, 1.0, 1.0]], fill(sqrt(2) / 4, 4))

is_word_valid(word) = all(word[i] != word[i-1] for i in 2:length(word))

# start, velocity = period_finder(tetrahedron, [1, 3, 4, 2])
word = [1, 3, 4, 2]

for i in 1:10
    shuffle!(word)
    if !is_word_valid(word)
        continue
    end

    start, velocity = period_finder(tetrahedron, word)
    println(start, velocity)
    if isnothing(start)
        continue
    end
    p = Particle3D(start, velocity)

    visualize(tetrahedron, p, 20)
    break
end

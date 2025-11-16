# Global Variables
epsilon = 1e-6

# Abstract Types
abstract type Face end
abstract type Billiard end

# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Faces
struct FinitePlaneFace <: Face
    u::Vector{Float64}
    s::Float64
    v::Vector{Float64}
    t::Float64
    r0::Vector{Float64}
    normal::Vector{Float64}
    function FinitePlaneFace(origin::Vector{Float64}, r0::Vector{Float64}, u::Vector{Float64}, s::Float64, v::Vector{Float64}, t::Float64)
        normal = cross(u, v)
        normal /= norm(normal)

        if dot(normal, r0 - origin) < 0
            normal = -normal
        end
        new(u, s, v, t, r0, normal)
    end
end

struct InfinitePlaneFace <: Face
    u::Vector{Float64}
    s::Float64
    v::Vector{Float64}
    t::Float64
    r0::Vector{Float64}
    normal::Vector{Float64}
    function InfinitePlaneFace(origin::Vector{Float64}, r0::Vector{Float64}, u::Vector{Float64}, s::Float64, v::Vector{Float64}, t::Float64)
        normal = cross(u, v)
        normal /= norm(normal)

        if dot(normal, r0 - origin) < 0
            normal = -normal
        end
        new(u, s, v, t, r0, normal)
    end
end

struct FiniteTriangleFace <: Face
    u::Vector{Float64}
    s::Float64
    v::Vector{Float64}
    t::Float64
    r0::Vector{Float64}
    normal::Vector{Float64}
    function FiniteTriangleFace(origin::Vector{Float64}, r0::Vector{Float64}, u::Vector{Float64}, v::Vector{Float64})
        normal = cross(u, v)
        normal /= norm(normal)

        if dot(normal, r0 - origin) < 0
            normal = -normal
        end
        new(u, 1.0, v, 1.0, r0, normal)
    end
end

struct InfiniteTriangleFace <: Face
    u::Vector{Float64}
    s::Float64
    v::Vector{Float64}
    t::Float64
    r0::Vector{Float64}
    normal::Vector{Float64}
    function InfiniteTriangleFace(origin::Vector{Float64}, r0::Vector{Float64}, u::Vector{Float64}, v::Vector{Float64})
        normal = cross(u, v)
        normal /= norm(normal)

        if dot(normal, r0 - origin) < 0
            normal = -normal
        end
        new(u, 1.0, v, 1.0, r0, normal)
    end
end


# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

# Shapes
struct Cuboid <: Billiard
    centroid::Vector{Float64}
    length::Float64
    width::Float64
    height::Float64
    faces::Vector{InfinitePlaneFace}
    function Cuboid(centroid::Vector{Float64}, length::Float64=1.0, width::Float64=1.0, height::Float64=1.0)
        half_length = length / 2
        half_width = width / 2
        half_height = height / 2

        faces = [
            InfinitePlaneFace(centroid, centroid .+ [half_length, 0, 0], [0.0, 1.0, 0.0], half_width, [0.0, 0.0, 1.0], half_height),
            InfinitePlaneFace(centroid, centroid .+ [-half_length, 0, 0], [0.0, 1.0, 0.0], half_width, [0.0, 0.0, 1.0], half_height),
            InfinitePlaneFace(centroid, centroid .+ [0, half_width, 0], [1.0, 0.0, 0.0], half_length, [0.0, 0.0, 1.0], half_height),
            InfinitePlaneFace(centroid, centroid .+ [0, -half_width, 0], [1.0, 0.0, 0.0], half_length, [0.0, 0.0, 1.0], half_height),
            InfinitePlaneFace(centroid, centroid .+ [0, 0, half_height], [1.0, 0.0, 0.0], half_length, [0.0, 1.0, 0.0], half_width),
            InfinitePlaneFace(centroid, centroid .+ [0, 0, -half_height], [1.0, 0.0, 0.0], half_length, [0.0, 1.0, 0.0], half_width)
        ]

        new(centroid, length, width, height, faces)
    end
end

struct Tetrahedron <: Billiard
    centroid::Vector{Float64}
    radii::Vector{Float64}
    vertices::Vector{Vector{Float64}}
    faces::Vector{InfiniteTriangleFace}
    function Tetrahedron(centroid::Vector{Float64}, vertices::Vector{Vector{Float64}}=[
            [0.0, 0.0, 1.0],
            [√8 / 3, 0.0, -1 / 3],
            [-√2 / 3, √6 / 3, -1 / 3],
            [-√2 / 3, -√6 / 3, -1 / 3]], radii::Vector{Float64}=fill(1.0, 4))
        v1, v2, v3, v4 = [centroid .+ radii[i] .* vertices[i] for i in 1:4]
        faces = [
            InfiniteTriangleFace(centroid, v2, v3 - v2, v4 - v2),
            InfiniteTriangleFace(centroid, v1, v3 - v1, v4 - v1),
            InfiniteTriangleFace(centroid, v1, v4 - v1, v2 - v1),
            InfiniteTriangleFace(centroid, v1, v2 - v1, v3 - v1)
        ]
        new(centroid, radii, [v1, v2, v3, v4], faces)
    end
end

# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

# Functions -- distance
function distance(face::FinitePlaneFace, p::Vector{Float64})
    return dot(face.normal, p - face.r0)
end

function distance(face::FiniteTriangleFace, p::Vector{Float64})
    return dot(face.normal, p - face.r0)
end

function distance(face::InfinitePlaneFace, p::Vector{Float64})
    return dot(face.normal, p - face.r0)
end

function distance(face::InfiniteTriangleFace, p::Vector{Float64})
    return dot(face.normal, p - face.r0)
end

# Functions -- on_surface
function on_surface(face::FinitePlaneFace, p::Vector{Float64})
    if abs(distance(face, p)) > epsilon
        return false
    end
    A = hcat(face.u, face.v)
    b = p - face.r0
    s, t = A \ b
    return abs(s) <= face.s + epsilon && abs(t) <= face.t + epsilon
end

function on_surface(face::FiniteTriangleFace, p::Vector{Float64})
    if abs(distance(face, p)) > epsilon
        return false
    end
    A = hcat(face.u, face.v)
    b = p - face.r0
    s, t = A \ b
    # println("s1: $s, t1: $t")
    return -epsilon <= s <= 1 + epsilon && -epsilon <= t <= 1 + epsilon && s + t <= 1 + epsilon
end

function on_surface(face::InfinitePlaneFace, p::Vector{Float64})
    return abs(distance(face, p)) < epsilon
end

function on_surface(face::InfiniteTriangleFace, p::Vector{Float64})
    return abs(distance(face, p)) < epsilon
end

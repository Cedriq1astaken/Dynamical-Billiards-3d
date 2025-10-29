function to_mesh(b)
    if b isa Cuboid
        centroid = b.centroid
        size = [b.length, b.width, b.height]
        return Rect3d(centroid - size ./ 2, size)
    end
    if b isa Tetrahedron
        v1, v2, v3, v4 = b.vertices
        vertices = [Point3(v1...), Point3(v2...), Point3(v3...), Point3(v4...)]
        faces = [
            TriangleFace(1, 2, 3),
            TriangleFace(1, 2, 4),
            TriangleFace(1, 3, 4),
            TriangleFace(2, 3, 4),
        ]

        return GeometryBasics.mesh(vertices, faces)
    end
end
